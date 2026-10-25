import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Whether this phone is certified for ARCore floor AR.
enum ArSupport { checking, supported, unsupported, unknown }

/// Asks Android (via `MainActivity`) whether Google lists the phone as ARCore
/// capable (`ArCoreApk.checkAvailability`). Anything other than Android, or a
/// check that cannot finish, reports [ArSupport.unknown] so the app does not
/// claim or deny support.
class ArSupportService {
  static const MethodChannel _channel = MethodChannel('myfuturepet/ar_support');

  Future<ArSupport> check() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return ArSupport.unknown;
    }
    try {
      final result = await _channel.invokeMethod<String>('check');
      switch (result) {
        case 'supported':
          return ArSupport.supported;
        case 'unsupported':
          return ArSupport.unsupported;
      }
    } on PlatformException catch (e) {
      debugPrint('ARCore support check failed: $e');
    } on MissingPluginException {
      // Older native build without the channel.
    }
    return ArSupport.unknown;
  }
}
