import 'dart:async';
import 'dart:typed_data';

import 'package:ar_flutter_plugin_2/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_2/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_2/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_2/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_2/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_2/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_2/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_2/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;

import '../ar_floor_geometry.dart';

/// Real ARCore floor AR inside the app (approach from Mary's branch): ARCore
/// finds horizontal planes, a tap on a detected plane anchors the pet there,
/// and it stays put while the user walks around. Only for ARCore phones; the
/// sensor floor preview in `ar_view_screen.dart` covers the rest.
class ArCorePetView extends StatefulWidget {
  const ArCorePetView({
    super.key,
    required this.modelUrl,
    required this.petName,
    required this.onStatus,
    required this.onPlacedChanged,
  });

  /// Life-size GLB (metres, feet at y = 0), as prepared by `scripts/`.
  final String modelUrl;
  final String petName;

  /// Banner text, and whether the view is ready for the user's next step.
  final void Function(String status, bool ready) onStatus;
  final ValueChanged<bool> onPlacedChanged;

  @override
  State<ArCorePetView> createState() => ArCorePetViewState();
}

class ArCorePetViewState extends State<ArCorePetView> {
  ARSessionManager? _session;
  ARObjectManager? _objects;
  ARAnchorManager? _anchors;
  ARNode? _petNode;
  ARPlaneAnchor? _petAnchor;
  bool _placing = false;
  DateTime? _floorFoundAt;
  String? _trackingFailure;
  Timer? _distanceTimer;

  // What the banner shows when tracking is fine.
  String _status = 'Move the phone slowly over the floor to find it';
  bool _ready = false;

  @override
  void dispose() {
    _distanceTimer?.cancel();
    _session?.dispose();
    super.dispose();
  }

  void _setStatus(String status, bool ready) {
    _status = status;
    _ready = ready;
    _publishStatus();
  }

  /// A tracking problem (too dark, too fast) outranks the normal status.
  void _publishStatus() {
    if (!mounted) return;
    final hint = trackingHint(_trackingFailure);
    widget.onStatus(hint ?? _status, hint == null && _ready);
  }

  String get _placePrompt => _floorFoundAt != null
      ? 'Floor found • tap it to place ${widget.petName}'
      : 'Move the phone slowly over the floor to find it';

  void _onCreated(
    ARSessionManager session,
    ARObjectManager objects,
    ARAnchorManager anchors,
    ARLocationManager location,
  ) {
    _session = session;
    _objects = objects;
    _anchors = anchors;

    session.onPlaneDetected = (count) {
      if (!mounted || _floorFoundAt != null || count <= 0) return;
      _floorFoundAt = DateTime.now();
      if (_petNode == null) _setStatus(_placePrompt, true);
    };
    session.onTrackingFailure = (reason) {
      if (reason == _trackingFailure) return;
      _trackingFailure = reason;
      _publishStatus();
    };
    session.onPlaneOrPointTap = _onTap;
    session.onError = (error) => debugPrint('ARCore error: $error');

    session.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      handleTaps: true,
      handlePans: true,
      // Rotation off so dragging never turns the pet.
      handleRotation: false,
    );
    _setStatus(_placePrompt, false);
  }

  Future<void> _onTap(List<ARHitTestResult> hits) async {
    final planeHits =
        hits.where((h) => h.type == ARHitTestResultType.plane).toList()
          ..sort((a, b) => a.distance.compareTo(b.distance));
    if (planeHits.isEmpty) {
      _snack('No floor detected there yet. Aim at the floor and tap again.');
      return;
    }
    if (_placing) return;
    final hit = planeHits.first;
    final floorAt = _floorFoundAt;
    final blocked = placementBlockReason(
      distanceM: hit.distance,
      trackingFailure: _trackingFailure,
      floorAgeMs: floorAt == null
          ? 0
          : DateTime.now().difference(floorAt).inMilliseconds,
    );
    if (blocked != null) {
      _snack(blocked);
      return;
    }
    await _placeAt(hit);
  }

  /// Anchors the pet on the tapped floor point; tapping again moves it there.
  Future<void> _placeAt(ARHitTestResult hit) async {
    final anchors = _anchors;
    final objects = _objects;
    if (anchors == null || objects == null) return;
    setState(() => _placing = true);
    try {
      final id = DateTime.now().millisecondsSinceEpoch;
      // A node without an anchor ignores its position and floats at the
      // AR world origin, so anchor it to the tapped plane.
      final anchor = ARPlaneAnchor(
        transformation: Matrix4.translation(
          hit.worldTransform.getTranslation(),
        ),
        name: 'pet_anchor_$id',
      );
      if (await anchors.addAnchor(anchor) != true) {
        _snack('Could not anchor ${widget.petName}. Try another spot.');
        return;
      }
      final node = ARNode(
        type: NodeType.webGLB,
        uri: widget.modelUrl,
        name: 'pet_$id',
        // The plugin reads scale.x as "fit the model to this many metres";
        // reset to scale 1 below so the life-size model keeps its own size.
        scale: Vector3.all(1),
      );
      if (await objects.addNode(node, planeAnchor: anchor) != true) {
        anchors.removeAnchor(anchor);
        _snack(
          'Could not load ${widget.petName}\'s 3D model. Check the internet.',
        );
        return;
      }
      node.transformNotifier.value = Matrix4.identity();
      await objects.faceCamera(node);

      // Remove the previous pet only after the new one is in place.
      await _removeCurrent();
      _petNode = node;
      _petAnchor = anchor;
      _session?.showPlanes(false); // clean view; shadows stay on the floor
      widget.onPlacedChanged(true);
      _setStatus('${widget.petName} is on your floor • drag to move', true);
      _startDistanceReadout();
    } catch (e) {
      debugPrint('ARCore placement error: $e');
      _snack('Could not place ${widget.petName}. Try again.');
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  /// Shows how far away the pet stands, so a real-size pet at 3 m is not
  /// mistaken for a small one.
  void _startDistanceReadout() {
    _distanceTimer?.cancel();
    _distanceTimer = Timer.periodic(const Duration(milliseconds: 500), (
      _,
    ) async {
      final anchor = _petAnchor;
      final session = _session;
      if (anchor == null || session == null) return;
      final d = await session.getDistanceFromAnchor(anchor);
      if (!mounted || d == null || _petAnchor != anchor) return;
      _setStatus(
        '${widget.petName} · ${d.toStringAsFixed(1)} m away · drag to move',
        true,
      );
    });
  }

  Future<void> _removeCurrent() async {
    final node = _petNode;
    final anchor = _petAnchor;
    _petNode = null;
    _petAnchor = null;
    _distanceTimer?.cancel();
    if (node != null) _objects?.removeNode(node);
    if (anchor != null) _anchors?.removeAnchor(anchor);
  }

  /// Takes the pet off the floor so the user can place it again.
  Future<void> removePet() async {
    await _removeCurrent();
    _session?.showPlanes(true);
    widget.onPlacedChanged(false);
    _setStatus(_placePrompt, _floorFoundAt != null);
  }

  /// PNG of the AR scene (camera image plus the pet), or null on failure.
  Future<Uint8List?> snapshot() async {
    try {
      final image = await _session?.snapshot();
      return image is MemoryImage ? image.bytes : null;
    } catch (e) {
      debugPrint('ARCore snapshot failed: $e');
      return null;
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ARView(
          onARViewCreated: _onCreated,
          planeDetectionConfig: PlaneDetectionConfig.horizontal,
        ),
        if (_placing)
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      ],
    );
  }
}
