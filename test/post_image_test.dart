import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/widgets/post_image.dart';

void main() {
  group('PostMediaAspect.clamp', () {
    test('keeps ordinary photo shapes exactly', () {
      expect(PostMediaAspect.clamp(4 / 3), 4 / 3);
      expect(PostMediaAspect.clamp(1), 1);
      expect(PostMediaAspect.clamp(16 / 9), 16 / 9);
      expect(PostMediaAspect.clamp(4 / 5), 4 / 5);
    });

    test('limits very tall and very wide media', () {
      // A 9:16 phone video or photo becomes 4:5, not a giant column.
      expect(PostMediaAspect.clamp(9 / 16), PostMediaAspect.tallest);
      // A panorama becomes 1.91:1, not a thin strip.
      expect(PostMediaAspect.clamp(4), PostMediaAspect.widest);
    });

    test('uses a neutral 4:3 box until the size is known', () {
      expect(PostMediaAspect.clamp(null), 4 / 3);
      expect(PostMediaAspect.clamp(0), 4 / 3);
      expect(PostMediaAspect.clamp(double.nan), 4 / 3);
    });
  });

  testWidgets('a post photo fills the card width at a sensible shape', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: PostImage(url: 'https://example.test/dog.jpg'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final size = tester.getSize(find.byType(PostImage));
    expect(size.width, 400);
    // 4:3 placeholder while the (unreachable) test image loads.
    expect(size.height, closeTo(300, 0.01));
    expect(tester.takeException(), isNull);
  });
}
