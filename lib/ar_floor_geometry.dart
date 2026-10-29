import 'dart:math' as math;

/// Overall standing height (top of head) of the pet 3D model, in metres.
/// Keep in sync with `EXPECTED_HEIGHT_M` in `scripts/glb_tools.py`.
double modelHeightMeters({required String petType, required String petSize}) {
  if (petType.toLowerCase() == 'cat') return 0.30;
  final size = petSize.toUpperCase();
  if (size.contains('SMALL') || size.contains('TOY')) return 0.35;
  if (size.contains('LARGE') || size.contains('XL')) return 0.75;
  return 0.56;
}

/// Shoulder (withers) height in centimetres for the same size classes. The
/// model is taller than this because its height includes the raised head.
double shoulderHeightCm({required String petType, required String petSize}) {
  if (petType.toLowerCase() == 'cat') return 25;
  final size = petSize.toUpperCase();
  if (size.contains('SMALL') || size.contains('TOY')) return 28;
  if (size.contains('LARGE') || size.contains('XL')) return 60;
  return 45;
}

/// One wording for pet height everywhere, e.g. "56 cm tall • 45 cm at shoulder".
String petHeightLabel({required String petType, required String petSize}) {
  final tall = modelHeightMeters(petType: petType, petSize: petSize) * 100;
  final shoulder = shoulderHeightCm(petType: petType, petSize: petSize);
  return '${tall.round()} cm tall • ${shoulder.round()} cm at shoulder';
}

/// ARCore placement is only trusted on a floor tracked for a moment, without a
/// tracking problem, and within this range: farther planes have the weakest
/// scale and the pet just looks small.
const double minPlacementDistanceM = 0.5;
const double maxPlacementDistanceM = 4.0;
const int minFloorAgeMs = 400;

/// User-facing advice for an ARCore TrackingFailureReason name, or null when
/// tracking is fine.
String? trackingHint(String? reason) {
  switch (reason) {
    case null:
    case 'NONE':
      return null;
    case 'INSUFFICIENT_LIGHT':
      return 'Too dark: turn on a light';
    case 'EXCESSIVE_MOTION':
      return 'Moving too fast: move the phone slower';
    case 'INSUFFICIENT_FEATURES':
      return 'Floor too plain: aim at a textured part of the floor';
    case 'CAMERA_UNAVAILABLE':
      return 'Camera busy: close other camera apps';
    default:
      return 'Tracking lost: move the phone slowly';
  }
}

/// Why a tap on the floor must not place the pet yet, or null when it may.
String? placementBlockReason({
  required double distanceM,
  required String? trackingFailure,
  required int floorAgeMs,
}) {
  final hint = trackingHint(trackingFailure);
  if (hint != null) return hint;
  if (floorAgeMs < minFloorAgeMs) {
    return 'Hold on, the floor is still settling. Tap again in a second.';
  }
  if (distanceM > maxPlacementDistanceM) {
    return 'That spot is too far. Tap the floor within 4 m.';
  }
  if (distanceM < minPlacementDistanceM) {
    return 'Too close. Step back a little and tap again.';
  }
  return null;
}

/// Sensor-only floor placement for phones without ARCore.
///
/// Treats the floor as a flat plane [cameraHeightM] below the phone. A point on
/// that plane that appears [angle] below the horizon is `cameraHeightM / tan(angle)`
/// metres away, and a pet standing there is `realHeight * focal / distance` pixels
/// tall. This is an approximation (no depth, no walking), accurate to roughly
/// +/-15 % when the assumed camera height is right.
///
/// Conventions: pitch is radians the camera looks *below* the horizon; yaw is
/// radians turned *left* (counter-clockwise seen from above).
class FloorGeometry {
  const FloorGeometry({
    this.cameraHeightM = 1.4,
    this.verticalFovRad = 65 * math.pi / 180,
    this.minFloorAngleRad = 8 * math.pi / 180,
    this.minDistanceM = 0.6,
    this.maxDistanceM = 5.0,
  });

  final double cameraHeightM;
  final double verticalFovRad;

  /// Taps closer to the horizon than this are rejected (the floor is "at infinity").
  final double minFloorAngleRad;
  final double minDistanceM;
  final double maxDistanceM;

  /// Focal length in pixels for a screen [screenHeightPx] tall.
  double focalPx(double screenHeightPx) =>
      (screenHeightPx / 2) / math.tan(verticalFovRad / 2);

  /// Distance to the floor point tapped [tapDyPx] pixels below the screen centre,
  /// or null when the tap is at or above the horizon.
  double? distanceForTap({
    required double pitchDownRad,
    required double tapDyPx,
    required double screenHeightPx,
  }) {
    final angle = pitchDownRad + math.atan(tapDyPx / focalPx(screenHeightPx));
    if (angle < minFloorAngleRad) return null;
    return (cameraHeightM / math.tan(angle)).clamp(minDistanceM, maxDistanceM);
  }

  /// Pixels below the screen centre at which the feet of a pet [distanceM] away appear.
  double feetOffsetY({
    required double pitchDownRad,
    required double distanceM,
    required double screenHeightPx,
  }) {
    final floorAngle = math.atan(cameraHeightM / distanceM);
    return focalPx(screenHeightPx) * math.tan(floorAngle - pitchDownRad);
  }

  /// Horizontal pixel offset from the screen centre of a pet whose world heading is
  /// [anchorYawRad] while the camera heading is [cameraYawRad].
  double offsetX({
    required double anchorYawRad,
    required double cameraYawRad,
    required double screenHeightPx,
  }) => -focalPx(screenHeightPx) * math.tan(anchorYawRad - cameraYawRad);

  /// World heading of something seen [tapDxPx] pixels right of the screen centre.
  double yawForTap({
    required double cameraYawRad,
    required double tapDxPx,
    required double screenHeightPx,
  }) => cameraYawRad - math.atan(tapDxPx / focalPx(screenHeightPx));

  /// Apparent height in pixels of an object [realHeightM] tall at [distanceM].
  double pixelHeight({
    required double realHeightM,
    required double distanceM,
    required double screenHeightPx,
  }) => realHeightM * focalPx(screenHeightPx) / distanceM;

  /// True when the anchor is roughly in front of the camera (within ~70 degrees).
  bool isInFront({
    required double anchorYawRad,
    required double cameraYawRad,
  }) => _wrap(anchorYawRad - cameraYawRad).abs() < 70 * math.pi / 180;

  static double _wrap(double a) {
    final twoPi = 2 * math.pi;
    return a - twoPi * ((a + math.pi) / twoPi).floorToDouble();
  }
}

/// Camera pitch below the horizon from a gravity vector in device axes
/// (Android accelerometer, portrait). 0 = looking at the horizon, pi/2 = at the floor.
double pitchDownFromGravity(double ax, double ay, double az) =>
    math.atan2(az, math.sqrt(ax * ax + ay * ay));

/// Gravity vector (device axes, as the accelerometer reads it at rest) carried
/// forward by the gyroscope over [dt] seconds, then nudged toward the
/// accelerometer reading by [blend]. The gyro is smooth but drifts; the
/// accelerometer never drifts but feels every hand movement, so it only
/// corrects slowly and is ignored while the phone is being accelerated.
List<double> fuseGravity(
  List<double> g, {
  required double gx,
  required double gy,
  required double gz,
  required double ax,
  required double ay,
  required double az,
  required double dt,
  double blend = 0.02,
}) {
  // A world-fixed vector seen from a phone turning at w turns the other way:
  // dg/dt = -(w x g).
  final x = g[0] - (gy * g[2] - gz * g[1]) * dt;
  final y = g[1] - (gz * g[0] - gx * g[2]) * dt;
  final z = g[2] - (gx * g[1] - gy * g[0]) * dt;
  final accelNorm = math.sqrt(ax * ax + ay * ay + az * az);
  final k = (accelNorm - 9.81).abs() < 1.5 ? blend : 0.0;
  return [x + k * (ax - x), y + k * (ay - y), z + k * (az - z)];
}

/// Rate of turning about the vertical (left = positive) from a gyroscope reading
/// and the accelerometer gravity vector, both in device axes.
double yawRateFromGyro({
  required double gx,
  required double gy,
  required double gz,
  required double ax,
  required double ay,
  required double az,
}) {
  final norm = math.sqrt(ax * ax + ay * ay + az * az);
  if (norm < 1e-6) return 0;
  return (gx * ax + gy * ay + gz * az) / norm;
}
