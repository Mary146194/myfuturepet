import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Representation of an in-app notification or shelter broadcast announcement
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type; // 'announcement', 'broadcast', 'adoption_status', 'appointment', 'message', 'system'
  final String audience; // 'all', 'adopters', 'staff', 'personal'
  final DateTime createdAt;
  final String? imageUrl;
  final bool isBroadcast;
  final bool isRead;
  final Map<String, dynamic>? data;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.audience,
    required this.createdAt,
    this.imageUrl,
    required this.isBroadcast,
    required this.isRead,
    this.data,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      type: type,
      audience: audience,
      createdAt: createdAt,
      imageUrl: imageUrl,
      isBroadcast: isBroadcast,
      isRead: isRead ?? this.isRead,
      data: data,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<NotificationItem>> notificationsNotifier =
      ValueNotifier<List<NotificationItem>>([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  bool _isInitialized = false;
  RealtimeChannel? _announcementsChannel;
  RealtimeChannel? _notificationsChannel;

  Set<String> _readAnnouncementIds = {};

  String get _storageKey {
    final user = _client.auth.currentUser;
    final userId = user?.id ?? 'guest';
    return 'read_announcements_$userId';
  }

  /// Initialize local read tracking, realtime listeners, and initial fetch
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await _loadReadIds();
    _setupRealtime();
    await fetchNotifications();
  }

  Future<void> _loadReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_storageKey) ?? [];
      _readAnnouncementIds = saved.toSet();
    } catch (e) {
      debugPrint('Error loading read announcement IDs: $e');
      _readAnnouncementIds = {};
    }
  }

  Future<void> _saveReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _readAnnouncementIds.toList());
    } catch (e) {
      debugPrint('Error saving read announcement IDs: $e');
    }
  }

  /// Set up Supabase Realtime subscriptions so new announcements broadcast immediately to mobile
  void _setupRealtime() {
    try {
      _announcementsChannel?.unsubscribe();
      _announcementsChannel = _client
          .channel('public:announcements:realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'announcements',
            callback: (payload) {
              debugPrint('Realtime announcement event: ${payload.eventType}');
              fetchNotifications();
            },
          )
          .subscribe();

      final user = _client.auth.currentUser;
      if (user != null) {
        _notificationsChannel?.unsubscribe();
        _notificationsChannel = _client
            .channel('public:notifications:realtime')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'notifications',
              callback: (payload) {
                debugPrint('Realtime personal notification event: ${payload.eventType}');
                fetchNotifications();
              },
            )
            .subscribe();
      }
    } catch (e) {
      debugPrint('Error setting up notification realtime: $e');
    }
  }

  /// Fetch broadcast announcements and personal notifications
  Future<void> fetchNotifications() async {
    isLoadingNotifier.value = true;
    try {
      await _loadReadIds();
      final List<NotificationItem> items = [];

      // 1. Fetch broadcast announcements from Admin
      try {
        final annResponse = await _client
            .from('announcements')
            .select()
            .order('created_at', ascending: false)
            .limit(35);

        final List<dynamic> annData = annResponse as List<dynamic>;
        for (final item in annData) {
          final map = item as Map<String, dynamic>;
          final id = map['id']?.toString() ?? '';
          final audience = map['audience']?.toString() ?? 'all';

          // Exclude staff-only broadcasts for general adopters
          if (audience.toLowerCase() == 'staff') continue;

          final isRead = _readAnnouncementIds.contains(id);
          final createdAt = DateTime.tryParse(map['created_at']?.toString() ?? '') ??
              DateTime.now();

          items.add(
            NotificationItem(
              id: id,
              title: map['title']?.toString() ?? 'Shelter Announcement',
              body: map['body']?.toString() ?? '',
              type: 'announcement',
              audience: audience,
              createdAt: createdAt,
              imageUrl: map['image_url']?.toString(),
              isBroadcast: true,
              isRead: isRead,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error querying announcements: $e');
      }

      // 2. Fetch user-specific notifications if logged in
      final user = _client.auth.currentUser;
      if (user != null) {
        try {
          final notifResponse = await _client
              .from('notifications')
              .select()
              .eq('user_id', user.id)
              .order('created_at', ascending: false)
              .limit(35);

          final List<dynamic> notifData = notifResponse as List<dynamic>;
          for (final item in notifData) {
            final map = item as Map<String, dynamic>;
            // fanout_announcement copies each announcement into every user's
            // notifications; the broadcast itself is already listed above.
            if (map['type'] == 'announcement') continue;
            final id = map['id']?.toString() ?? '';
            final isRead = map['read_at'] != null;
            final createdAt = DateTime.tryParse(map['created_at']?.toString() ?? '') ??
                DateTime.now();

            items.add(
              NotificationItem(
                id: id,
                title: map['title']?.toString() ?? 'Notification',
                body: map['body']?.toString() ?? '',
                type: map['type']?.toString() ?? 'system',
                audience: 'personal',
                createdAt: createdAt,
                imageUrl: null,
                isBroadcast: false,
                isRead: isRead,
                data: map['data'] as Map<String, dynamic>?,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error querying personal notifications: $e');
        }
      }

      // 3. Sort chronologically (latest first)
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      notificationsNotifier.value = items;
      unreadCountNotifier.value = items.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('Error in fetchNotifications: $e');
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  /// Refresh unread count and notifications from Supabase
  Future<void> refreshUnreadCount() => fetchNotifications();

  /// Mark a specific notification as read
  Future<void> markAsRead(NotificationItem item) async {
    if (item.isRead) return;

    if (item.isBroadcast) {
      _readAnnouncementIds.add(item.id);
      await _saveReadIds();
    } else {
      try {
        await _client
            .from('notifications')
            .update({'read_at': DateTime.now().toIso8601String()})
            .eq('id', item.id);
      } catch (e) {
        debugPrint('Error updating read_at in notifications: $e');
      }
    }

    final updated = notificationsNotifier.value.map((n) {
      if (n.id == item.id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    notificationsNotifier.value = updated;
    unreadCountNotifier.value = updated.where((n) => !n.isRead).length;
  }

  /// Mark all current notifications and announcements as read
  Future<void> markAllAsRead() async {
    final current = notificationsNotifier.value;
    if (current.isEmpty) return;

    for (final item in current) {
      if (item.isBroadcast) {
        _readAnnouncementIds.add(item.id);
      }
    }
    await _saveReadIds();

    final user = _client.auth.currentUser;
    if (user != null) {
      try {
        await _client
            .from('notifications')
            .update({'read_at': DateTime.now().toIso8601String()})
            .eq('user_id', user.id)
            .isFilter('read_at', null);
      } catch (e) {
        debugPrint('Error batch updating read_at in notifications: $e');
      }
    }

    final updated = current.map((n) => n.copyWith(isRead: true)).toList();
    notificationsNotifier.value = updated;
    unreadCountNotifier.value = 0;
  }

  void dispose() {
    _announcementsChannel?.unsubscribe();
    _notificationsChannel?.unsubscribe();
  }
}
