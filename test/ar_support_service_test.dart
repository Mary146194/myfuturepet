import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/services/ar_support_service.dart';

void main() {
  test('ARCore view opens for supported and needs-install phones', () {
    // v1.0.9 kept needs-install phones in the preview; v1.0.8 opened ARCore
    // and let its session ask Google to update. Keep v1.0.8's behaviour.
    expect(opensArCore(ArSupport.supported), isTrue);
    expect(opensArCore(ArSupport.needsInstall), isTrue);
    expect(opensArCore(ArSupport.unsupported), isFalse);
    expect(opensArCore(ArSupport.unknown), isFalse);
    expect(opensArCore(ArSupport.checking), isFalse);
  });
}
