import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pet_matcher.dart';

/// The account's Pet Matcher row in Supabase (`pet_matcher_profiles`).
class PetMatcherRemote {
  const PetMatcherRemote();

  static const table = 'pet_matcher_profiles';

  SupabaseClient get _client => Supabase.instance.client;

  /// `{answers, status}` for the user, or null when they have no row yet.
  Future<Map<String, dynamic>?> fetch(String userId) => _client
      .from(table)
      .select('answers, status')
      .eq('user_id', userId)
      .maybeSingle();

  /// Answers, when given, are saved as completed; otherwise as skipped.
  Future<void> upsert(String userId, {Map<String, String>? answers}) =>
      _client.from(table).upsert({
        'user_id': userId,
        'answers': answers,
        'status': answers == null ? 'skipped' : 'completed',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
}

/// Each user's Pet Matcher answers, and whether they already finished or
/// skipped the quiz shown before Home on their first sign-in.
///
/// Saved to the account in Supabase so it follows the user across phones,
/// with a copy on the device for offline use. Changes made offline are
/// pushed on the next load.
class PetMatcherService {
  static final PetMatcherService _instance = PetMatcherService._internal();
  factory PetMatcherService() => _instance;
  PetMatcherService._internal()
    : _userId = _supabaseUserId,
      _remote = const PetMatcherRemote();

  @visibleForTesting
  PetMatcherService.test(this._userId, [this._remote]);

  final String? Function() _userId;

  /// Null in tests that only exercise the device copy.
  final PetMatcherRemote? _remote;

  /// The signed-in user's answers; null until they finish the quiz.
  final ValueNotifier<MatchProfile?> profile = ValueNotifier(null);
  String? _loadedFor;
  bool _prompted = false;

  static String? _supabaseUserId() {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  String _key(String uid) => 'pet_matcher_answers_$uid';
  String _promptedKey(String uid) => 'pet_matcher_prompted_$uid';

  /// Set while a change has not reached Supabase yet.
  String _dirtyKey(String uid) => 'pet_matcher_unsynced_$uid';

  static MatchProfile? _parse(Object? json) {
    if (json is String) {
      try {
        json = jsonDecode(json);
      } catch (_) {
        return null;
      }
    }
    if (json is! Map) return null;
    final profile = MatchProfile.fromJson(Map<String, dynamic>.from(json));
    return profile.isComplete ? profile : null;
  }

  /// Loads the current user's answers (once per user per app session).
  Future<MatchProfile?> load() async {
    final uid = _userId();
    if (uid == null) {
      _loadedFor = null;
      _prompted = false;
      profile.value = null;
      return null;
    }
    if (_loadedFor == uid) return profile.value;

    SharedPreferences? prefs;
    MatchProfile? answers;
    var prompted = false;
    var unsynced = false;
    try {
      prefs = await SharedPreferences.getInstance();
      answers = _parse(prefs.getString(_key(uid)));
      prompted = prefs.getBool(_promptedKey(uid)) ?? false;
      unsynced = prefs.getBool(_dirtyKey(uid)) ?? false;
    } catch (e) {
      debugPrint('Pet Matcher answers unavailable on device: $e');
    }

    final remote = _remote;
    if (remote != null) {
      try {
        final row = await remote.fetch(uid);
        if (unsynced || (row == null && (answers != null || prompted))) {
          // This phone has newer answers (made offline, or before the table
          // existed): the account copy catches up.
          await remote.upsert(uid, answers: answers?.toJson());
          await prefs?.setBool(_dirtyKey(uid), false);
        } else if (row != null) {
          // The account is the source of truth, e.g. on a new phone.
          answers = _parse(row['answers']);
          prompted = true;
          await prefs?.setBool(_promptedKey(uid), true);
          if (answers != null) {
            await prefs?.setString(_key(uid), jsonEncode(answers.toJson()));
          } else {
            await prefs?.remove(_key(uid));
          }
        }
      } catch (e) {
        // Offline, or pet_matcher_profiles not created yet: use the device.
        debugPrint('Pet Matcher account sync unavailable: $e');
      }
    }

    // The user may have changed while loading.
    if (_userId() != uid) return profile.value;
    _loadedFor = uid;
    _prompted = prompted || answers != null;
    profile.value = answers;
    return answers;
  }

  Future<void> save(MatchProfile answers) async {
    profile.value = answers;
    final uid = _userId();
    if (uid == null) return;
    _loadedFor = uid;
    _prompted = true;
    await _store(uid, answers);
  }

  /// True on a user's first sign-in on any phone (including right after
  /// registering): no answers yet and the quiz was never finished or skipped.
  Future<bool> needsOnboarding() async {
    if (_userId() == null) return false;
    await load();
    return profile.value == null && !_prompted;
  }

  /// Don't show the quiz before Home again (skipped or finished).
  Future<void> markPrompted() async {
    final uid = _userId();
    if (uid == null || (_loadedFor == uid && _prompted)) return;
    _prompted = true;
    await _store(uid, profile.value);
  }

  /// Saves on the device first, then to the account.
  Future<void> _store(String uid, MatchProfile? answers) async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      if (answers != null) {
        await prefs.setString(_key(uid), jsonEncode(answers.toJson()));
      }
      await prefs.setBool(_promptedKey(uid), true);
      await prefs.setBool(_dirtyKey(uid), true);
    } catch (e) {
      debugPrint('Could not save Pet Matcher answers on device: $e');
    }
    final remote = _remote;
    if (remote == null) return;
    try {
      await remote.upsert(uid, answers: answers?.toJson());
      await prefs?.setBool(_dirtyKey(uid), false);
    } catch (e) {
      debugPrint('Pet Matcher answers kept on this phone for now: $e');
    }
  }

  /// Match for one pet, or null when the user hasn't taken the quiz.
  PetMatch? matchFor(Map<String, dynamic> pet) {
    final answers = profile.value;
    return answers == null ? null : PetMatcher.score(pet, answers);
  }
}
