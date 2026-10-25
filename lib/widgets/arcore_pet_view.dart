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
  bool _floorFound = false;

  @override
  void dispose() {
    _session?.dispose();
    super.dispose();
  }

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
      if (!mounted || _floorFound || count <= 0) return;
      _floorFound = true;
      if (_petNode == null) {
        widget.onStatus(
          'Floor found • tap it to place ${widget.petName}',
          true,
        );
      }
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
    widget.onStatus('Move the phone slowly over the floor to find it', false);
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
    await _placeAt(planeHits.first);
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

      // Remove the previous pet only after the new one is in place.
      await _removeCurrent();
      _petNode = node;
      _petAnchor = anchor;
      widget.onPlacedChanged(true);
      widget.onStatus(
        '${widget.petName} is on your floor at real size • drag to move',
        true,
      );
    } catch (e) {
      debugPrint('ARCore placement error: $e');
      _snack('Could not place ${widget.petName}. Try again.');
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  Future<void> _removeCurrent() async {
    final node = _petNode;
    final anchor = _petAnchor;
    _petNode = null;
    _petAnchor = null;
    if (node != null) _objects?.removeNode(node);
    if (anchor != null) _anchors?.removeAnchor(anchor);
  }

  /// Takes the pet off the floor so the user can place it again.
  Future<void> removePet() async {
    await _removeCurrent();
    widget.onPlacedChanged(false);
    widget.onStatus(
      _floorFound
          ? 'Floor found • tap it to place ${widget.petName}'
          : 'Move the phone slowly over the floor to find it',
      _floorFound,
    );
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
