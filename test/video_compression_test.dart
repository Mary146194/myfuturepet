import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myfuturepet/services/video_compression_service.dart';

PreparedVideo _video(int bytes, {int? original}) => PreparedVideo(
  file: XFile.fromData(Uint8List(0), name: 'v.mp4'),
  originalBytes: original ?? bytes,
  bytes: bytes,
);

void main() {
  group('VideoCompressionService.choose', () {
    test('uses the compressed copy when it is smaller', () {
      final original = _video(40 << 20);
      final compressed = _video(4 << 20, original: 40 << 20);
      final chosen = VideoCompressionService.choose(original, compressed);
      expect(chosen, same(compressed));
      expect(chosen.wasCompressed, isTrue);
    });

    test('keeps the original when re-encoding made it bigger', () {
      final original = _video(2 << 20);
      final compressed = _video(3 << 20, original: 2 << 20);
      final chosen = VideoCompressionService.choose(original, compressed);
      expect(chosen, same(original));
      expect(chosen.wasCompressed, isFalse);
    });

    test('keeps the original when the compressed size is unknown', () {
      final original = _video(2 << 20);
      expect(
        VideoCompressionService.choose(original, _video(0, original: 2 << 20)),
        same(original),
      );
    });
  });

  test(
    'passes videos through unchanged where compression is unavailable',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        final service = VideoCompressionService();
        expect(service.supported, isFalse);
        final picked = XFile.fromData(Uint8List(1234), name: 'clip.mp4');
        final prepared = await service.prepare(picked);
        expect(prepared.file, same(picked));
        expect(prepared.bytes, 1234);
        expect(prepared.wasCompressed, isFalse);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );
}
