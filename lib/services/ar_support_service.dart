import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Whether this phone is certified for ARCore floor AR.
///
/// [needsInstall]: the phone can do ARCore but Google Play Services for AR is
/// missing or too old.
enum ArSupport { checking, supported, needsInstall, unsupported, unknown }

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
        case 'needs_install':
          return ArSupport.needsInstall;
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

  /// Opens Google's install/update flow for Play Services for AR. The result
  /// arrives when the user comes back to the app, so callers re-run [check].
  Future<void> requestInstall() async {
    try {
      await _channel.invokeMethod<String>('install');
    } on PlatformException catch (e) {
      debugPrint('ARCore install request failed: $e');
    } on MissingPluginException {
      // Older native build without the method.
    }
  }
}
