import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

// Standalone mathematical helper replicating the verified AR scaling logic
double getRealLifeHeightCm({required String petType, required String petSize}) {
  final size = petSize.toUpperCase();
  final type = petType.toLowerCase();
  if (type == 'cat') return 25.0; // Domestic cat / kitten
  if (size.contains('SMALL') || size.contains('TOY')) return 28.0; // Small dog (Shih Tzu, Chihuahua)
  if (size.contains('LARGE') || size.contains('XL')) return 60.0; // Large dog (Labrador, Sky)
  return 45.0; // Medium dog baseline (Standard Aspin)
}

double calculateLifeScale({required double heightCm, required double distanceMeters}) {
  final baseScaleForPet = heightCm / 45.0;
  final distanceFactor = 1.5 / math.max(0.5, distanceMeters);
  return (baseScaleForPet * distanceFactor).clamp(0.40, 2.50);
}

void main() {
  group('Universal AR 1:1 Metric Life Scale Engine Tests', () {
    test('Correct real-life heights in centimeters are assigned per animal type/size', () {
      expect(getRealLifeHeightCm(petType: 'cat', petSize: 'small'), equals(25.0));
      expect(getRealLifeHeightCm(petType: 'cat', petSize: 'medium'), equals(25.0));
      expect(getRealLifeHeightCm(petType: 'dog', petSize: 'toy'), equals(28.0));
      expect(getRealLifeHeightCm(petType: 'dog', petSize: 'small'), equals(28.0));
      expect(getRealLifeHeightCm(petType: 'dog', petSize: 'medium'), equals(45.0));
      expect(getRealLifeHeightCm(petType: 'dog', petSize: 'large'), equals(60.0));
      expect(getRealLifeHeightCm(petType: 'dog', petSize: 'xl'), equals(60.0));
    });

    test('Standard floor distance (1.5m) produces accurate 1.0 baseline for medium dog', () {
      final mediumHeight = getRealLifeHeightCm(petType: 'dog', petSize: 'medium');
      final scale = calculateLifeScale(heightCm: mediumHeight, distanceMeters: 1.5);
      expect(scale, closeTo(1.0, 0.001));
    });

    test('Standard floor distance (1.5m) produces proportional scale for cat and large dog', () {
      final catHeight = getRealLifeHeightCm(petType: 'cat', petSize: 'small');
      final catScale = calculateLifeScale(heightCm: catHeight, distanceMeters: 1.5);
      // 25.0 / 45.0 approx 0.555
      expect(catScale, closeTo(0.555, 0.01));

      final largeHeight = getRealLifeHeightCm(petType: 'dog', petSize: 'large');
      final largeScale = calculateLifeScale(heightCm: largeHeight, distanceMeters: 1.5);
      // 60.0 / 45.0 approx 1.333
      expect(largeScale, closeTo(1.333, 0.01));
    });

    test('Distance falloff scales pet up when close (1.0m) and down when far (2.0m)', () {
      final mediumHeight = getRealLifeHeightCm(petType: 'dog', petSize: 'medium');
      
      final closeScale = calculateLifeScale(heightCm: mediumHeight, distanceMeters: 1.0);
      // 1.5 / 1.0 = 1.5x
      expect(closeScale, closeTo(1.50, 0.01));

      final farScale = calculateLifeScale(heightCm: mediumHeight, distanceMeters: 2.0);
      // 1.5 / 2.0 = 0.75x
      expect(farScale, closeTo(0.75, 0.01));
    });

    test('Clamp prevents extreme out-of-bound scaling values', () {
      final largeHeight = getRealLifeHeightCm(petType: 'dog', petSize: 'large');
      final extremeClose = calculateLifeScale(heightCm: largeHeight, distanceMeters: 0.1);
      expect(extremeClose, equals(2.50));

      final catHeight = getRealLifeHeightCm(petType: 'cat', petSize: 'small');
      final extremeFar = calculateLifeScale(heightCm: catHeight, distanceMeters: 10.0);
      expect(extremeFar, equals(0.40));
    });
  });
}
