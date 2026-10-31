import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// System (status bar) notifications on Android/iOS. A no-op elsewhere, so
/// web and desktop builds keep working without notification support.
class LocalPushService {
  static final LocalPushService _instance = LocalPushService._internal();
  factory LocalPushService() => _instance;
  LocalPushService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _journeyChannel = AndroidNotificationDetails(
    'adoption_journey',
    'Adoption journey',
    channelDescription: 'Updates when the shelter moves your adoption forward',
    importance: Importance.high,
    priority: Priority.high,
  );

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> init() async {
    if (_ready || !_supported) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      _ready = true;
    } catch (e) {
      debugPrint('Local notifications unavailable: $e');
    }
  }

  Future<void> showJourneyUpdate({
    required String applicationId,
    required String title,
    required String body,
  }) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        // One notification slot per application; a newer stage replaces it.
        id: applicationId.hashCode & 0x7fffffff,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: _journeyChannel,
          iOS: DarwinNotificationDetails(),
        ),
        payload: applicationId,
      );
    } catch (e) {
      debugPrint('Could not show journey notification: $e');
    }
  }
}
