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

  test('tapping the screen centre at 45 degrees pitch is camera-height away', () {
    final d = geo.distanceForTap(
      pitchDownRad: deg(45),
      tapDyPx: 0,
      screenHeightPx: screenH,
    );
    expect(d, closeTo(1.4, 0.001)); // tan(45) = 1
  });

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

  test('a tap right of centre anchors the pet there, surviving the round trip', () {
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
  });

  test('anchor is only shown when roughly in front of the camera', () {
    expect(geo.isInFront(anchorYawRad: 0, cameraYawRad: deg(30)), isTrue);
    expect(geo.isInFront(anchorYawRad: 0, cameraYawRad: deg(120)), isFalse);
    expect(geo.isInFront(anchorYawRad: deg(179), cameraYawRad: deg(-179)), isTrue);
  });

  test('pitch from gravity: upright phone looks at horizon, flat looks down', () {
    expect(pitchDownFromGravity(0, 9.8, 0), closeTo(0, 0.001));
    expect(pitchDownFromGravity(0, 0, 9.8), closeTo(math.pi / 2, 0.001));
    expect(pitchDownFromGravity(0, 6.9, 6.9), closeTo(math.pi / 4, 0.01));
    expect(pitchDownFromGravity(0, 9.0, -3.0), lessThan(0)); // tilted up
  });

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
}
