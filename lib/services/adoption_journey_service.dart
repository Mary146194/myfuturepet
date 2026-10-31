import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../adoption_application_store.dart';
import '../adoption_journey.dart';
import '../appointment_store.dart';
import 'adoption_service.dart';
import 'appointment_service.dart';
import 'local_push_service.dart';
import 'notification_service.dart';

typedef RowsFetcher = Future<List<Map<String, dynamic>>> Function();
typedef JourneyNotifier =
    Future<void> Function(AdoptionJourney journey, String title, String body);

/// Keeps the adopter's adoption journeys live and spots stage advances.
///
/// When the shelter moves an application forward (application status,
/// confirmed meet & greet, or pet marked adopted), Supabase Realtime triggers
/// a refresh. A stage higher than the one last stored on this device posts a
/// system notification and queues a celebration for the Profile road.
class AdoptionJourneyService {
  static final AdoptionJourneyService _instance =
      AdoptionJourneyService._internal();
  factory AdoptionJourneyService() => _instance;

  AdoptionJourneyService._internal()
    : _fetchApplications = null,
      _fetchAppointments = null,
      _notify = null,
      _userIdOverride = null;

  @visibleForTesting
  AdoptionJourneyService.test({
    required RowsFetcher this._fetchApplications,
    required RowsFetcher this._fetchAppointments,
    required JourneyNotifier this._notify,
    String userId = 'test-user',
  }) : _userIdOverride = userId;

  final RowsFetcher? _fetchApplications;
  final RowsFetcher? _fetchAppointments;
  final JourneyNotifier? _notify;
  final String? _userIdOverride;

  final ValueNotifier<List<AdoptionJourney>> journeys =
      ValueNotifier<List<AdoptionJourney>>([]);

  /// Application ids whose stage advanced since the adopter last saw them.
  final ValueNotifier<Set<String>> celebrations = ValueNotifier<Set<String>>(
    {},
  );

  String? _userId;
  RealtimeChannel? _channel;
  Timer? _debounce;
  Future<void>? _inFlight;
  bool _refreshQueued = false;

  String? get _currentUserId =>
      _userIdOverride ?? Supabase.instance.client.auth.currentUser?.id;

  String get _seenKey => 'journey_seen_$_userId';
  String get _notifiedKey => 'journey_notified_$_userId';

  /// Start (or restart for a different signed-in user). Safe to call often.
  Future<void> init() async {
    final userId = _currentUserId;
    if (userId == null) {
      _reset();
      return;
    }
    if (userId == _userId) return;
    _reset();
    _userId = userId;
    if (_userIdOverride == null) {
      await LocalPushService().init();
      _subscribe(userId);
      NotificationService().notificationsNotifier.addListener(_scheduleRefresh);
    }
    await refresh();
  }

  void _reset() {
    _channel?.unsubscribe();
    _channel = null;
    _debounce?.cancel();
    if (_userIdOverride == null) {
      NotificationService().notificationsNotifier.removeListener(
        _scheduleRefresh,
      );
    }
    _userId = null;
    journeys.value = [];
    celebrations.value = {};
  }

  /// Call on logout so the next account starts clean.
  void signOut() => _reset();

  void _subscribe(String userId) {
    try {
      _channel = Supabase.instance.client
          .channel('adoption_journey_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'adoption_applications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'applicant_id',
              value: userId,
            ),
            callback: (_) => _scheduleRefresh(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'appointments',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (_) => _scheduleRefresh(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'pets',
            callback: (payload) {
              final petId = payload.newRecord['id']?.toString();
              if (journeys.value.any((j) => j.petId == petId)) {
                _scheduleRefresh();
              }
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Adoption journey realtime unavailable: $e');
    }
  }

  // Admin saves can touch several tables at once; refresh once for all.
  void _scheduleRefresh() {
    if (_userId == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), refresh);
  }

  Future<void> refresh() async {
    if (_inFlight != null) {
      _refreshQueued = true;
      return _inFlight;
    }
    _inFlight = _load();
    try {
      await _inFlight;
    } finally {
      _inFlight = null;
    }
    if (_refreshQueued) {
      _refreshQueued = false;
      await refresh();
    }
  }

  Future<void> _load() async {
    final userId = _userId;
    if (userId == null) return;
    final List<Map<String, dynamic>> applications;
    List<Map<String, dynamic>> appointments = const [];
    var appointmentsLoaded = false;
    try {
      applications = await (_fetchApplications?.call() ??
          AdoptionService().fetchMyApplications(throwOnError: true));
    } catch (e) {
      // Keep the road we already show rather than blanking it offline.
      debugPrint('Adoption journey refresh failed: $e');
      return;
    }
    try {
      appointments = await (_fetchAppointments?.call() ??
          AppointmentService().fetchMyAppointments(throwOnError: true));
      appointmentsLoaded = true;
    } catch (e) {
      debugPrint('Adoption journey appointments unavailable: $e');
    }
    if (userId != _userId) return;

    final built = applications
        .map((row) => AdoptionJourney.fromRows(row, appointments))
        .where((j) => j.applicationId.isNotEmpty)
        .toList();

    final prefs = await SharedPreferences.getInstance();
    final seen = _readMap(prefs, _seenKey);
    final notified = _readMap(prefs, _notifiedKey);
    final celebrate = {...celebrations.value};

    for (final journey in built) {
      final id = journey.applicationId;
      final current = journey.stage.index;
      final lastSeen = seen[id];
      if (lastSeen == null) {
        // First time on this device: show the road as-is, no fanfare.
        seen[id] = current;
        notified[id] = current;
        continue;
      }
      if (journey.halted || current <= lastSeen) continue;
      celebrate.add(id);
      if ((notified[id] ?? lastSeen) < current) {
        notified[id] = current;
        await _announce(journey);
      }
    }

    await prefs.setString(_seenKey, jsonEncode(seen));
    await prefs.setString(_notifiedKey, jsonEncode(notified));
    if (userId != _userId) return;
    // Same rows feed My Applications and My Appointments, so a realtime
    // change shows up identically on every screen.
    AdoptionApplicationStore.applyRows(applications);
    if (appointmentsLoaded) {
      try {
        AppointmentStore.applyRows(appointments);
      } catch (e) {
        debugPrint('Adoption journey could not update appointments: $e');
      }
    }
    journeys.value = _ordered(built);
    celebrations.value = celebrate;
  }

  Future<void> _announce(AdoptionJourney journey) async {
    final title = journey.isComplete
        ? 'Welcome home, ${journey.petName}! 🎉'
        : 'Your adoption journey moved forward! 🐾';
    final body = '${journey.stage.title}: ${journey.caption}';
    if (_notify != null) return _notify(journey, title, body);
    await LocalPushService().showJourneyUpdate(
      applicationId: journey.applicationId,
      title: title,
      body: body,
    );
  }

  /// The journey for one application, once loaded.
  AdoptionJourney? journeyFor(String? applicationId) => journeys.value
      .where((j) => j.applicationId == applicationId)
      .firstOrNull;

  /// The journey a meet & greet appointment belongs to (same pet).
  AdoptionJourney? journeyForPet(String? petId) {
    if (petId == null || petId.isEmpty) return null;
    return journeys.value
        .where((j) => j.petId == petId && !j.halted)
        .firstOrNull;
  }

  /// The Profile road played its animation; don't repeat it.
  Future<void> markCelebrated(String applicationId) async {
    final journey = journeys.value
        .where((j) => j.applicationId == applicationId)
        .firstOrNull;
    final updated = {...celebrations.value}..remove(applicationId);
    celebrations.value = updated;
    if (journey == null || _userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = _readMap(prefs, _seenKey);
    seen[applicationId] = journey.stage.index;
    await prefs.setString(_seenKey, jsonEncode(seen));
  }

  /// Active journeys first (furthest along on top), then finished, then
  /// halted ones; newest application breaks ties.
  static List<AdoptionJourney> _ordered(List<AdoptionJourney> list) {
    int group(AdoptionJourney j) => j.halted ? 2 : (j.isComplete ? 1 : 0);
    return [...list]..sort((a, b) {
      final byGroup = group(a).compareTo(group(b));
      if (byGroup != 0) return byGroup;
      final byStage = b.stage.index.compareTo(a.stage.index);
      if (byStage != 0) return byStage;
      return (b.submittedAt ?? DateTime(0)).compareTo(
        a.submittedAt ?? DateTime(0),
      );
    });
  }

  static Map<String, int> _readMap(SharedPreferences prefs, String key) {
    try {
      final raw = prefs.getString(key);
      if (raw == null) return {};
      return (jsonDecode(raw) as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      );
    } catch (_) {
      return {};
    }
  }
}
