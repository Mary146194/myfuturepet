import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/ar_floor_geometry.dart';

double deg(double d) => d * math.pi / 180;

void main() {
  const geo = FloorGeometry(cameraHeightM: 1.4, verticalFovRad: 1.0);
  const screenH = 900.0;

  test('model heights match the normalized GLB targets', () {
    expect(modelHeightMeters(petType: 'cat', petSize: 'small'), 0.30);
    expect(modelHeightMeters(petType: 'dog', petSize: 'small'), 0.35);
    expect(modelHeightMeters(petType: 'dog', petSize: 'medium'), 0.56);
    expect(modelHeightMeters(petType: 'dog', petSize: 'large'), 0.75);
  });

  test(
    'tapping the screen centre at 45 degrees pitch is camera-height away',
    () {
      final d = geo.distanceForTap(
        pitchDownRad: deg(45),
        tapDyPx: 0,
        screenHeightPx: screenH,
      );
      expect(d, closeTo(1.4, 0.001)); // tan(45) = 1
    },
  );

  test('tapping lower on the screen is closer, higher is farther', () {
    final low = geo.distanceForTap(
      pitchDownRad: deg(30),
      tapDyPx: 200,
      screenHeightPx: screenH,
    )!;
    final high = geo.distanceForTap(
      pitchDownRad: deg(30),
      tapDyPx: -100,
      screenHeightPx: screenH,
    )!;
    expect(low, lessThan(high));
  });

  test('taps at or above the horizon are rejected so the pet cannot float', () {
    expect(
      geo.distanceForTap(
        pitchDownRad: deg(0),
        tapDyPx: -200,
        screenHeightPx: screenH,
      ),
      isNull,
    );
    expect(
      geo.distanceForTap(
        pitchDownRad: deg(3),
        tapDyPx: 0,
        screenHeightPx: screenH,
      ),
      isNull,
    );
  });

  test('distance is clamped to a usable range', () {
    final near = geo.distanceForTap(
      pitchDownRad: deg(85),
      tapDyPx: 0,
      screenHeightPx: screenH,
    );
    expect(near, geo.minDistanceM);
    final far = geo.distanceForTap(
      pitchDownRad: deg(9),
      tapDyPx: 0,
      screenHeightPx: screenH,
    );
    expect(far, geo.maxDistanceM);
  });

  test('feet position round-trips with the tap that chose the distance', () {
    const pitch = 0.6;
    const tapDy = 150.0;
    final d = geo.distanceForTap(
      pitchDownRad: pitch,
      tapDyPx: tapDy,
      screenHeightPx: screenH,
    )!;
    final dy = geo.feetOffsetY(
      pitchDownRad: pitch,
      distanceM: d,
      screenHeightPx: screenH,
    );
    expect(dy, closeTo(tapDy, 0.5));
  });

  test('pet gets smaller with distance and has a real-world pixel size', () {
    final f = geo.focalPx(screenH);
    final near = geo.pixelHeight(
      realHeightM: 0.56,
      distanceM: 1.0,
      screenHeightPx: screenH,
    );
    final far = geo.pixelHeight(
      realHeightM: 0.56,
      distanceM: 2.0,
      screenHeightPx: screenH,
    );
    expect(near, closeTo(0.56 * f, 0.001));
    expect(far, closeTo(near / 2, 0.001));
  });

  test('turning the phone left moves a world-fixed pet right on screen', () {
    // Pet straight ahead (yaw 0). Camera turns left by 10 degrees.
    final x = geo.offsetX(
      anchorYawRad: 0,
      cameraYawRad: deg(10),
      screenHeightPx: screenH,
    );
    expect(x, greaterThan(0));
    // Turning right moves it left.
    final y = geo.offsetX(
      anchorYawRad: 0,
      cameraYawRad: deg(-10),
      screenHeightPx: screenH,
    );
    expect(y, lessThan(0));
  });

  test(
    'a tap right of centre anchors the pet there, surviving the round trip',
    () {
      final yaw = geo.yawForTap(
        cameraYawRad: 0.3,
        tapDxPx: 120,
        screenHeightPx: screenH,
      );
      final x = geo.offsetX(
        anchorYawRad: yaw,
        cameraYawRad: 0.3,
        screenHeightPx: screenH,
      );
      expect(x, closeTo(120, 0.5));
    },
  );

  test('anchor is only shown when roughly in front of the camera', () {
    expect(geo.isInFront(anchorYawRad: 0, cameraYawRad: deg(30)), isTrue);
    expect(geo.isInFront(anchorYawRad: 0, cameraYawRad: deg(120)), isFalse);
    expect(
      geo.isInFront(anchorYawRad: deg(179), cameraYawRad: deg(-179)),
      isTrue,
    );
  });

  test(
    'pitch from gravity: upright phone looks at horizon, flat looks down',
    () {
      expect(pitchDownFromGravity(0, 9.8, 0), closeTo(0, 0.001));
      expect(pitchDownFromGravity(0, 0, 9.8), closeTo(math.pi / 2, 0.001));
      expect(pitchDownFromGravity(0, 6.9, 6.9), closeTo(math.pi / 4, 0.01));
      expect(pitchDownFromGravity(0, 9.0, -3.0), lessThan(0)); // tilted up
    },
  );

  test('yaw rate: spinning about the vertical axis is turning', () {
    // Upright phone, rotating about device y (vertical) at 1 rad/s.
    expect(
      yawRateFromGyro(gx: 0, gy: 1, gz: 0, ax: 0, ay: 9.8, az: 0),
      closeTo(1, 1e-6),
    );
    // Pitching (rotation about device x) is not turning.
    expect(
      yawRateFromGyro(gx: 1, gy: 0, gz: 0, ax: 0, ay: 9.8, az: 0),
      closeTo(0, 1e-6),
    );
  });

  test('height label: one wording for model and shoulder height', () {
    expect(
      petHeightLabel(petType: 'dog', petSize: 'MEDIUM'),
      '56 cm tall • 45 cm at shoulder',
    );
    expect(
      petHeightLabel(petType: 'cat', petSize: 'SMALL'),
      '30 cm tall • 25 cm at shoulder',
    );
  });

  test('placement gate: tracking, settling time and distance', () {
    String? block(double d, {String? fail, int age = 5000}) =>
        placementBlockReason(
          distanceM: d,
          trackingFailure: fail,
          floorAgeMs: age,
        );
    expect(block(1.5), isNull);
    expect(block(1.5, fail: 'NONE'), isNull);
    expect(block(1.5, fail: 'INSUFFICIENT_LIGHT'), contains('dark'));
    expect(block(1.5, age: 300), contains('settling'));
    expect(block(5.0), contains('too far'));
    expect(block(0.3), contains('Too close'));
    expect(trackingHint('EXCESSIVE_MOTION'), contains('slower'));
    expect(trackingHint('SOMETHING_NEW'), isNotNull);
  });

  test('gravity fusion: gyro tilt moves pitch, hand jolts barely do', () {
    // Upright phone tipping its camera down (negative rotation about device x)
    // by 0.5 rad over 50 steps; the accelerometer still says "upright"
    // (lagging), so the gyro must lead.
    var g = [0.0, 9.81, 0.0];
    for (var i = 0; i < 50; i++) {
      g = fuseGravity(
        g,
        gx: -1,
        gy: 0,
        gz: 0,
        ax: 0,
        ay: 9.81,
        az: 0,
        dt: 0.01,
      );
    }
    expect(pitchDownFromGravity(g[0], g[1], g[2]), greaterThan(0.3));

    // Held still, a 2 g hand jolt along z is ignored entirely.
    final still = [0.0, 9.81, 0.0];
    final jolted = fuseGravity(
      still,
      gx: 0,
      gy: 0,
      gz: 0,
      ax: 0,
      ay: 9.81,
      az: 19.6,
      dt: 0.01,
    );
    expect(
      pitchDownFromGravity(jolted[0], jolted[1], jolted[2]),
      closeTo(0, 1e-9),
    );

    // Held still, a wrong estimate converges back to the accelerometer.
    var drifted = [0.0, 6.9, 6.9];
    for (var i = 0; i < 400; i++) {
      drifted = fuseGravity(
        drifted,
        gx: 0,
        gy: 0,
        gz: 0,
        ax: 0,
        ay: 9.81,
        az: 0,
        dt: 0.01,
      );
    }
    expect(
      pitchDownFromGravity(drifted[0], drifted[1], drifted[2]),
      closeTo(0, 0.01),
    );
  });
}
