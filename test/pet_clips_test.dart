import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/pet_clips.dart';

void main() {
  test('Scar (Blender rig) has Sit and Wag but no idle', () {
    const scar = ['Wag', 'Sit'];
    expect(petClipFor('Sit', scar), 'Sit');
    expect(petClipFor('Wag Tail', scar), 'Wag');
    expect(petClipFor('Normal', scar), isNull);
  });

  test('older dog model: sit and idle, no wag, sitidle is not sit', () {
    const dog = ['attack', 'idle', 'sit', 'sitidle', 'walk'];
    expect(petClipFor('Sit', dog), 'sit');
    expect(petClipFor('Wag Tail', dog), isNull);
    expect(petClipFor('Normal', dog), 'idle');
  });

  test('static model has no clips', () {
    expect(petClipFor('Sit', const []), isNull);
  });
}
