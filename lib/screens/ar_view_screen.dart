import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../ar_floor_geometry.dart';
import '../ar_model_url.dart';
import '../pet_clips.dart';
import '../page_js.dart';
import '../services/ar_support_service.dart';
import '../services/pet_service.dart';
import '../widgets/arcore_pet_view.dart';

typedef ARModelBuilder =
    Widget Function(BuildContext context, String modelUrl, bool studio);
typedef ARSessionLauncher = Future<bool> Function();
typedef ARSupportChecker = Future<ArSupport> Function();

class ARViewScreen extends StatefulWidget {
  final Map<String, dynamic>? pet;
  final VoidCallback? onBack;
  final PetService? petService;
  final ARModelBuilder? modelBuilder;
  final bool? cameraSupported;
  final ARSessionLauncher? arSessionLauncher;
  final ARSupportChecker? arSupportChecker;

  const ARViewScreen({
    super.key,
    this.pet,
    this.onBack,
    this.petService,
    this.modelBuilder,
    this.cameraSupported,
    this.arSessionLauncher,
    this.arSupportChecker,
  });

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen>
    with WidgetsBindingObserver {
  // ============================================================
  // PALETTE & STYLING
  // ============================================================

  static const Color primaryColor = Color(0xFFA94327);
  static const Color darkBrown = Color(0xFF604A43);
  static const Color darkText = Color(0xFF24343A);

  Map<String, dynamic>? _selectedPet;
  List<Map<String, dynamic>> _availablePets = const [];
  bool _loadingPets = false;
  bool _petsError = false;
  bool get _cameraSupported =>
      widget.cameraSupported ??
      (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS));

  // ============================================================
  // CAMERA STATE
  // ============================================================

  CameraController? _cameraController;
  Future<void>? _initializeCameraFuture;

  bool _cameraReady = false;
  bool _cameraError = false;
  Future<Object> Function(String)? _runArJavaScript;
  bool _arSessionLaunching = false;

  // ============================================================
  // AR SPATIAL PLACEMENT & GESTURE STATE
  // ============================================================

  bool _isPetPlaced = true;
  double _scale = 1.0; // 3D Studio zoom factor (0.4 to 2.5)

  String _currentAction = 'Normal'; // 'Normal', 'Sit', 'Wag Tail', 'Speak'
  bool _showSpeechBubble = false;

  // ============================================================
  // SENSOR FLOOR PREVIEW (phones without ARCore)
  //
  // Not real surface detection: the phone's tilt gives the angle to the
  // floor, and with an assumed camera height that gives a distance (see
  // FloorGeometry). The pet is pinned to a world heading by integrating the
  // gyroscope, so turning the phone moves it across the screen.
  // ============================================================

  static const FloorGeometry _geo = FloorGeometry();
  // Fixed camera used by the <model-viewer> overlay so its on-screen size
  // follows from the distance alone (see _buildInteractiveSpatialCanvas).
  static const double _orbitMeters = 3.0;
  static const double _viewerFovDeg = 25.0;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  ArSupport _arSupport = ArSupport.checking;
  // On ARCore phones Camera AR is the real in-app ARCore view instead.
  final GlobalKey<ArCorePetViewState> _arCoreKey = GlobalKey();
  String _arCoreStatus = 'Starting ARCore…';
  bool _arCoreReady = false;
  // "Try real AR" forces the ARCore view when Google's check is inconclusive.
  bool _forceArCore = false;
  bool get _useArCore =>
      (opensArCore(_arSupport) || _forceArCore) &&
      _cameraSupported &&
      _modelGlbUrl != null;
  bool _surfaceDetected = false; // true while the phone is aimed at the floor
  double _pitchDownRad = 0.35; // used until sensors report (20 degrees down)
  double _yawRad = 0;
  double _anchorYawRad = 0;
  List<double>? _gravity;
  List<double>? _accel;
  bool _hasGyro = false;
  static const double _gyroDeadZoneRadPerSec = 0.02; // ~1 degree a second
  DateTime? _lastGyroTime;
  DateTime _lastSensorUiUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  // ============================================================
  // 1:1 METRIC LIFE-SCALE ENGINE
  // ============================================================

  bool _isLifeScaleLocked = true;
  double _viewingDistanceMeters =
      1.5; // Distance from the phone to where the pet stands on the floor

  /// Physical shoulder height of the pet in centimeters.
  double get _realLifeHeightCm =>
      shoulderHeightCm(petType: _petType, petSize: _petSize);

  String get _heightLabel =>
      petHeightLabel(petType: _petType, petSize: _petSize);

  /// Calculates optical perspective scale factor based on viewing distance.
  /// Standard baseline: Medium dog (45cm) at 1.5m corresponds to scale factor 1.0.
  double _calculateLifeScale(double distanceMeters) {
    final baseScaleForPet = _realLifeHeightCm / 45.0;
    final distanceFactor = 1.5 / math.max(0.5, distanceMeters);
    return (baseScaleForPet * distanceFactor).clamp(0.40, 2.50);
  }

  // ============================================================
  // RESOLVED PET DATA
  // ============================================================

  Map<String, dynamic> get _resolvedPet {
    return widget.pet ?? _selectedPet ?? const {};
  }

  String get _petName => _resolvedPet['name']?.toString() ?? 'Sky';
  String get _petBreed => _resolvedPet['breed']?.toString() ?? 'Rescue Pet';
  String get _petType =>
      (_resolvedPet['type']?.toString() ?? 'dog').toLowerCase();
  String get _petSize =>
      _resolvedPet['size']?.toString().toUpperCase() ?? 'MEDIUM';
  String get _petImageUrl {
    final direct = _resolvedPet['image_url']?.toString();
    if (direct != null && direct.isNotEmpty) return direct;
    final photos = _resolvedPet['photos'];
    if (photos is List && photos.isNotEmpty) {
      return photos.first.toString();
    }
    return '';
  }

  // ============================================================
  // 3D MODEL & DISPLAY MODE
  // ============================================================

  bool _is3DStudioMode = false;
  int _viewerReset = 0;

  String? get _modelGlbUrl => resolvePetModelUrl(_resolvedPet['model_url']);

  /// Standing height of the normalized 3D model in metres (top of head).
  double get _modelHeightM =>
      modelHeightMeters(petType: _petType, petSize: _petSize);

  void _showArProjectionOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6D6D6),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.view_in_ar,
                      color: Color(0xFF008F82),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AR Display Options',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        Text(
                          'View $_petName in physical space or 3D showroom',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Camera mode uses a virtual room when a camera is unavailable.
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _is3DStudioMode = false;
                    _isPetPlaced = true;
                    _runArJavaScript = null;
                  });
                  _showMessage(
                    _cameraReady
                        ? 'Camera preview active. Drag to position $_petName.'
                        : 'Virtual floor room active. Drag to position $_petName.',
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF008F82),
                      width: 1.6,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFF0FDF4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF008F82),
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Camera preview',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                    color: darkText,
                                  ),
                                ),
                                SizedBox(width: 6),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Overlay the 3D model on a camera preview or virtual floor room.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Option 2: 3D Model Inspection Studio
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _is3DStudioMode = true;
                    _runArJavaScript = null;
                  });
                  _showMessage('Switched to 3D Inspection Studio.');
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFF9FAFB),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.view_in_ar_rounded,
                        color: Color(0xFF616161),
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '3D Inspection Studio',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: darkText,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'High-contrast 360° rotation booth for detailed inspection of fur textures and body build.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _is3DStudioMode = !_cameraSupported;
    if (widget.pet == null) {
      _loadAvailablePets();
    }

    _scale = _calculateLifeScale(_viewingDistanceMeters);

    // Initial camera startup
    if (_cameraSupported) {
      _initializeCamera();
    }

    // Orientation sensors for the floor preview
    if (_cameraSupported) {
      _initSensors();
    }
    _loadArSupport();
  }

  Future<void> _loadArSupport({int attempt = 0}) async {
    final checker = widget.arSupportChecker ?? ArSupportService().check;
    ArSupport support;
    try {
      support = await checker();
    } catch (e) {
      ArSupportService.lastUnknownReason = '${e.runtimeType}';
      support = ArSupport.unknown;
    }
    if (!mounted) return;
    if (opensArCore(support) && _cameraSupported) {
      // ARCore needs the camera to itself: stop the plain preview first. A
      // failure here must not demote a supported phone to the preview.
      try {
        await _releaseCameraForArCore();
      } catch (e) {
        debugPrint('Releasing the camera for ARCore failed: $e');
      }
      if (!mounted) return;
      _isPetPlaced = false;
    }
    setState(() => _arSupport = support);
    // Google's check can be slow or fail once (first launch, weak signal):
    // keep asking for ~20 s instead of settling on the preview.
    if (support == ArSupport.unknown &&
        widget.arSupportChecker == null &&
        attempt < 10) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _arSupport == ArSupport.unknown) {
          _loadArSupport(attempt: attempt + 1);
        }
      });
    }
  }

  Future<void> _releaseCameraForArCore() async {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    try {
      await _initializeCameraFuture;
    } catch (_) {}
    final controller = _cameraController;
    _cameraController = null;
    _cameraReady = false;
    await controller?.dispose();
  }

  Future<void> _loadAvailablePets() async {
    setState(() {
      _loadingPets = true;
      _petsError = false;
    });
    try {
      final pets = await (widget.petService ?? PetService()).fetchPets(
        status: 'available',
        throwOnError: true,
      );
      if (!mounted) return;
      setState(() {
        _availablePets = pets;
        _loadingPets = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingPets = false;
        _petsError = true;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _runArJavaScript = null;
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    final controller = _cameraController;
    _cameraController = null;
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (_cameraController != null) {
        setState(() {
          _cameraReady = false;
        });
        final controller = _cameraController;
        _cameraController = null;
        controller?.dispose();
      }
    } else if (state == AppLifecycleState.resumed &&
        _arSupport == ArSupport.unknown) {
      _loadArSupport(); // retry an inconclusive check
    }
    if (state == AppLifecycleState.resumed &&
        _cameraSupported &&
        !_is3DStudioMode &&
        !_useArCore) {
      // The preview needs its sensors again if ARCore had taken over.
      if (_accelerometerSubscription == null) _initSensors();
      _initializeCamera();
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _initSensors() {
    if (kIsWeb) return;

    // The default 200 ms sampling made the pet jump 5 times a second.
    const period = SensorInterval.gameInterval;
    try {
      _accelerometerSubscription =
          accelerometerEventStream(samplingPeriod: period).listen((event) {
            _accel = [event.x, event.y, event.z];
            // With a gyro, gravity is fused in the gyro listener. Without one
            // (some budget phones), fall back to a heavy low-pass here.
            if (_gravity != null && _hasGyro) return;
            final g = _gravity;
            const a = 0.1;
            final gx = g == null ? event.x : g[0] + a * (event.x - g[0]);
            final gy = g == null ? event.y : g[1] + a * (event.y - g[1]);
            final gz = g == null ? event.z : g[2] + a * (event.z - g[2]);
            _gravity = [gx, gy, gz];
            _pitchDownRad = pitchDownFromGravity(gx, gy, gz);
            _refreshFromSensors();
          }, onError: (_) {});

      _gyroscopeSubscription = gyroscopeEventStream(samplingPeriod: period)
          .listen((event) {
            _hasGyro = true;
            final g = _gravity;
            final a = _accel;
            final last = _lastGyroTime;
            _lastGyroTime = event.timestamp;
            if (g == null || a == null || last == null) return;
            final dt = event.timestamp.difference(last).inMicroseconds / 1e6;
            if (dt <= 0 || dt > 0.5) return;
            final fused = fuseGravity(
              g,
              gx: event.x,
              gy: event.y,
              gz: event.z,
              ax: a[0],
              ay: a[1],
              az: a[2],
              dt: dt,
            );
            _gravity = fused;
            _pitchDownRad = pitchDownFromGravity(fused[0], fused[1], fused[2]);
            final yawRate = yawRateFromGyro(
              gx: event.x,
              gy: event.y,
              gz: event.z,
              ax: fused[0],
              ay: fused[1],
              az: fused[2],
            );
            // Ignore tiny rates: that is gyro bias, and integrating it slides the
            // pet sideways while the phone is held still.
            if (yawRate.abs() > _gyroDeadZoneRadPerSec) _yawRad += yawRate * dt;
            _refreshFromSensors();
          }, onError: (_) {});
    } catch (e) {
      debugPrint('Sensor initialization error: $e');
    }
  }

  /// Repaints at most ~60 times a second; sensors can fire more often.
  void _refreshFromSensors() {
    if (!mounted) return;
    final now = DateTime.now();
    if (now.difference(_lastSensorUiUpdate).inMilliseconds < 16) return;
    _lastSensorUiUpdate = now;
    final aimed =
        _pitchDownRad >= _geo.minFloorAngleRad && _pitchDownRad <= 1.45;
    setState(() => _surfaceDetected = aimed);
  }

  /// Puts the pet on the floor point under [localPosition] (screen pixels).
  void _placeFromTap(Offset localPosition, Size size) {
    final distance = _geo.distanceForTap(
      pitchDownRad: _pitchDownRad,
      tapDyPx: localPosition.dy - size.height / 2,
      screenHeightPx: size.height,
    );
    if (distance == null) {
      _showMessage('Tap the floor, below the horizon line.');
      return;
    }
    setState(() {
      _viewingDistanceMeters = distance;
      _anchorYawRad = _geo.yawForTap(
        cameraYawRad: _yawRad,
        tapDxPx: localPosition.dx - size.width / 2,
        screenHeightPx: size.height,
      );
      _isPetPlaced = true;
    });
    _showMessage(
      '$_petName placed about ${distance.toStringAsFixed(1)} m away (approximate).',
    );
  }

  // ============================================================
  // CAMERA INITIALIZATION
  // ============================================================

  Future<void> _initializeCamera() async {
    if (!_cameraSupported) return;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _cameraError = true;
          _cameraReady = false;
          _is3DStudioMode = true;
        });
        return;
      }

      CameraDescription selectedCamera = cameras.first;
      for (final cam in cameras) {
        if (cam.lensDirection == CameraLensDirection.back) {
          selectedCamera = cam;
          break;
        }
      }

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _cameraController = controller;
      _initializeCameraFuture = controller.initialize();
      await _initializeCameraFuture;

      if (!mounted) return;
      if (_useArCore || _cameraController != controller) {
        // ARCore took over while the preview was starting.
        if (_cameraController == controller) _cameraController = null;
        await controller.dispose();
        return;
      }
      setState(() {
        _cameraReady = true;
        _cameraError = false;
      });
    } catch (e) {
      debugPrint(
        'Camera initialization error (using AR Virtual Room fallback): $e',
      );
      if (!mounted) return;
      setState(() {
        _cameraError = true;
        _cameraReady = false;
        _is3DStudioMode = true;
      });
    }
  }

  // ============================================================
  // ACTIONS (SIT, WAG TAIL, SPEAK)
  // ============================================================

  void _triggerAction(String tapped) {
    final previous = _currentAction;
    // Tapping the active Sit / Wag Tail again stands the pet back up.
    final action = tapped == previous && tapped != 'Speak' ? 'Normal' : tapped;
    setState(() {
      _currentAction = action;
      _showSpeechBubble = false;
    });
    if (_useArCore && !_is3DStudioMode && action != 'Speak') {
      _playArCoreClip(previous, action);
    }

    if (action == 'Normal') {
      _showMessage('$_petName is standing.');
    } else if (action == 'Wag Tail') {
      _showMessage('$_petName is wagging tail.');
    } else if (action == 'Sit') {
      _showMessage('$_petName is in sit posture.');
    } else if (action == 'Speak') {
      setState(() => _showSpeechBubble = true);
      final sound = _petType == 'cat' ? 'Meow! Purrr...' : 'Woof! Woof!';
      _showMessage('$_petName vocalizes: $sound');

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _currentAction == 'Speak') {
          setState(() => _showSpeechBubble = false);
        }
      });
    }
  }

  /// Real AR: Sit plays once and holds, Wag Tail loops, Normal stands (getting
  /// up from a sit plays the sit backwards).
  void _playArCoreClip(String previous, String action) {
    final view = _arCoreKey.currentState;
    if (view == null) return;
    final clips = _clipNames ?? const <String>[];
    final clip = petClipFor(action, clips);
    final sit = petClipFor('Sit', clips);
    if (action == 'Normal' && previous == 'Sit' && sit != null) {
      view.playClip(sit, loop: false, reverse: true);
    } else if (clip != null) {
      view.playClip(clip, loop: action != 'Sit');
    } else {
      view.restPose();
    }
  }

  void _resetAR() {
    if (_useArCore && !_is3DStudioMode) {
      _arCoreKey.currentState?.removePet();
      return;
    }
    // Reset also re-asks Google, in case real floor AR is now available.
    if (_arSupport == ArSupport.unknown) _loadArSupport();
    setState(() {
      _viewerReset++;
      _anchorYawRad = _yawRad; // straight ahead of where the phone points now
      _isLifeScaleLocked = true;
      _viewingDistanceMeters = 1.5;
      _scale = _calculateLifeScale(1.5);
      _currentAction = 'Normal';
      _showSpeechBubble = false;
    });
    _showMessage(
      _is3DStudioMode
          ? '3D turntable reset.'
          : 'AR view reset to default scale placement.',
    );
  }

  void _togglePlacement() {
    setState(() {
      _isPetPlaced = !_isPetPlaced;
    });
    if (_isPetPlaced) {
      _showMessage(
        '$_petName placed in your surroundings. Drag handle to move.',
      );
    } else {
      _showMessage('Aim reticle at a flat surface and tap to place $_petName.');
    }
  }

  Future<void> _onCameraShutter() async {
    if (_arSessionLaunching) return;
    if (_useArCore) {
      // Already in real floor AR: the shutter lifts the pet to place again.
      await _arCoreKey.currentState?.removePet();
      return;
    }
    if (!_cameraSupported && widget.arSessionLauncher == null) {
      _togglePlacement();
      return;
    }

    setState(() => _arSessionLaunching = true);
    try {
      final launcher = widget.arSessionLauncher;
      final launched = launcher != null
          ? await launcher()
          : await _launchModelViewerAR();
      if (!mounted) return;
      if (!launched) {
        _showMessage(
          'Floor AR is unavailable on this phone or still loading. Use the floor preview or 3D Studio.',
        );
      }
    } catch (error) {
      debugPrint('Could not start native AR: $error');
      if (!mounted) return;
      _showMessage(
        'Could not start floor AR. Use the floor preview or 3D Studio.',
      );
    } finally {
      if (mounted) setState(() => _arSessionLaunching = false);
    }
  }

  Future<bool> _launchModelViewerAR() async {
    final runJavaScript = _runArJavaScript;
    if (runJavaScript == null) return false;
    final result = await runJavaScript('''
      (() => {
        const viewer = document.querySelector('model-viewer');
        if (!viewer || !viewer.canActivateAR) return false;
        viewer.activateAR();
        return true;
      })()
    ''');
    return result == true || result.toString() == 'true';
  }

  // ============================================================
  // BUILD
  // ============================================================

  Widget _buildPetPicker() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR View'),
        leading: BackButton(onPressed: _handleBack),
      ),
      body: _loadingPets
          ? const Center(child: CircularProgressIndicator())
          : _petsError
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load pets. Please try again.'),
                  TextButton(
                    onPressed: _loadAvailablePets,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _availablePets.isEmpty
          ? const Center(
              child: Text('No adoptable pets are available right now.'),
            )
          : ListView.builder(
              itemCount: _availablePets.length,
              itemBuilder: (context, index) {
                final pet = _availablePets[index];
                final hasModel = resolvePetModelUrl(pet['model_url']) != null;
                return ListTile(
                  key: ValueKey('ar-pet-${pet['id']}'),
                  leading: const Icon(Icons.pets),
                  title: Text(pet['name']?.toString() ?? 'Unnamed pet'),
                  subtitle: Text(
                    hasModel
                        ? 'View interactive 3D model'
                        : '3D model unavailable',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => setState(() => _selectedPet = pet),
                );
              },
            ),
    );
  }

  Widget _buildModel({required bool studio}) {
    final url = _modelGlbUrl!;
    if (widget.modelBuilder != null) {
      return widget.modelBuilder!(context, url, studio);
    }
    // On web the viewer never calls onWebViewCreated: probe the page instead,
    // once per model.
    if (kIsWeb && _webProbedUrl != url) {
      _webProbedUrl = url;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _probeAnimations(evalPageJs),
      );
    }
    // Until the viewer reports its clips, keep the older models' names.
    final names = _clipNames;
    final viewerClip = names == null
        ? (_currentAction == 'Sit' ? 'sit' : 'idle')
        : petClipFor(_currentAction, names);
    if (kIsWeb && _currentAction == 'Sit' && viewerClip != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _playOnceWhenLoaded(evalPageJs),
      );
    }
    return ModelViewer(
      key: ValueKey(
        '${url}_${studio ? 'studio' : 'camera'}_$_currentAction'
        '_${_viewerReset}_${studio ? _scale : 1}',
      ),
      src: url,
      alt: '3D model of $_petName',
      // Show the pet's photo in 3D Studio until the model has downloaded.
      poster: studio && _petImageUrl.isNotEmpty ? _petImageUrl : null,
      ar: !studio,
      arModes: const ['scene-viewer', 'quick-look', 'webxr'],
      arPlacement: ArPlacement.floor,
      arScale: ArScale.fixed,
      onWebViewCreated: (controller) {
        if (!studio) {
          _runArJavaScript = controller.runJavaScriptReturningResult;
        }
        _probeAnimations(controller.runJavaScriptReturningResult);
        if (_currentAction == 'Sit' && viewerClip != null) {
          _playOnceWhenLoaded(controller.runJavaScriptReturningResult);
        }
      },
      autoRotate: studio,
      cameraControls: true,
      // Sit plays once (started below) and holds; the others loop.
      autoPlay: viewerClip != null && _currentAction != 'Sit',
      animationName: viewerClip,
      backgroundColor: studio ? const Color(0xFF1E2833) : Colors.transparent,
      shadowIntensity: 0.85,
      shadowSoftness: 0.9,
      cameraOrbit: studio
          ? '0deg 75deg ${(105 / _scale).clamp(40, 260).toStringAsFixed(0)}%'
          : '0deg 85deg ${_orbitMeters}m',
      // Preview overlay: fixed camera aimed at the middle of the standing pet,
      // so the pet's pixel height is set only by the size of this widget.
      fieldOfView: studio ? null : '${_viewerFovDeg}deg',
      minCameraOrbit: studio ? null : 'auto auto ${_orbitMeters}m',
      maxCameraOrbit: studio ? null : 'auto auto ${_orbitMeters}m',
      disableZoom: studio ? null : true,
      cameraTarget: studio
          ? null
          : '0m ${(_modelHeightM / 2).toStringAsFixed(3)}m 0m',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pet == null && _selectedPet == null) {
      return _buildPetPicker();
    }
    if (_modelGlbUrl == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_resolvedPet['name']?.toString() ?? 'AR View'),
          leading: BackButton(onPressed: _handleBack),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.view_in_ar_outlined, size: 56),
              const SizedBox(height: 12),
              const Text('No 3D model is available for this pet yet.'),
              if (widget.pet == null)
                TextButton(
                  onPressed: () => setState(() => _selectedPet = null),
                  child: const Text('Choose another pet'),
                ),
            ],
          ),
        ),
      );
    }
    final media = MediaQuery.of(context);
    // The stack lives inside SafeArea and a 500px wide column.
    final size = Size(
      math.min(media.size.width, 500.0),
      media.size.height - media.padding.vertical,
    );

    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.onBack != null) {
          widget.onBack!();
        }
      },
      child: Scaffold(
        backgroundColor: darkBrown,
        body: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Stack(
                children: [
                  // 1. Live Camera or Virtual Room Fallback (when in Camera mode)
                  if (!_is3DStudioMode && _useArCore)
                    Positioned.fill(
                      child: ArCorePetView(
                        key: _arCoreKey,
                        modelUrl: _modelGlbUrl!,
                        petName: _petName,
                        onStatus: (status, ready) => setState(() {
                          _arCoreStatus = status;
                          _arCoreReady = ready;
                        }),
                        onPlacedChanged: (placed) => setState(() {
                          _isPetPlaced = placed;
                          _currentAction = 'Normal'; // a new pet stands
                        }),
                        onFailed: _onArCoreFailed,
                        onClips: (clips) => setState(() => _clipNames = clips),
                      ),
                    ),
                  if (!_is3DStudioMode && !_useArCore)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapUp: (details) =>
                            _placeFromTap(details.localPosition, size),
                        child: _buildCameraOrFallback(size),
                      ),
                    ),

                  // 1b. 3D Studio Model Viewer (when in 3D Studio inspection mode)
                  if (_is3DStudioMode)
                    Positioned.fill(
                      child: Container(
                        color: const Color(0xFF1E2833),
                        child: _buildModel(studio: true),
                      ),
                    ),

                  // 1.5 Floor Placement Guide Reticle (only when placing in camera mode)
                  if (!_is3DStudioMode && !_isPetPlaced && !_useArCore)
                    Positioned(
                      bottom: size.height * 0.35,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00E5D0),
                              width: 1.2,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  color: Color(0xFF00E5D0),
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Aim below the horizon and tap the floor to place your pet',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 2. Interactive 3D Pet Spatial Canvas (only in camera mode)
                  if (!_is3DStudioMode && !_useArCore)
                    _buildInteractiveSpatialCanvas(size),

                  // 3. Top Header Bar (Back, Mode Tabs, Options)
                  Positioned(
                    top: 14,
                    left: 14,
                    right: 14,
                    child: _buildTopHeaderBar(),
                  ),

                  // 3.5 Surface Detection HUD Status Banner
                  Positioned(
                    top: 68,
                    left: 16,
                    right: 16,
                    child: _buildSurfaceStatusBanner(),
                  ),

                  // Distance calibration remains available in both views.
                  // ARCore measures real distance, so no calibration there.
                  if (_is3DStudioMode || (_isLifeScaleLocked && !_useArCore))
                    Positioned(
                      top: 114,
                      left: 16,
                      right: 16,
                      child: _buildDistanceSelector(),
                    ),

                  if (_is3DStudioMode)
                    Positioned(
                      top: 162,
                      left: 16,
                      right: 16,
                      child: Center(child: _buildStudioScaleIndicator()),
                    ),

                  // Scale, reset, snapshot, and help remain available in both views.
                  Positioned(
                    right: 14,
                    bottom: 230,
                    child: _buildRightControls(),
                  ),

                  // 5. Behavior Action Pills (Sit, Wag Tail, Speak)
                  Positioned(
                    bottom: 175,
                    left: 0,
                    right: 0,
                    child: _buildActionRow(),
                  ),

                  // 6. Selected Pet Information Card
                  Positioned(
                    bottom: 92,
                    left: 20,
                    right: 20,
                    child: _buildPetInfoCard(),
                  ),

                  // 7. Bottom Shutter / Placement Button
                  // In real floor AR the pet is placed by tapping the floor and
                  // re-placed with the side reset button, so no shutter there;
                  // 3D Studio already has the side reset button too.
                  if (!_useArCore && !_is3DStudioMode)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: _buildPlacementShutterButton(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CAMERA PASSTHROUGH OR VIRTUAL ROOM FALLBACK
  // ============================================================

  Widget _buildCameraOrFallback(Size size) {
    if (!_cameraError &&
        _cameraReady &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      return ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              height: size.width * _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),
      );
    }

    // AR Failsafe Rule: Virtual Room Floor Perspective
    return _buildVirtualRoomFallback(size);
  }

  Widget _buildVirtualRoomFallback(Size size) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C3E50), Color(0xFF1E2833), Color(0xFF141920)],
        ),
      ),
      child: Stack(
        children: [
          // Room Wall Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Perspective Floor Base
          Positioned(
            top: size.height * 0.42,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(painter: _FloorPerspectivePainter()),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SPATIAL CANVAS: 3D MODEL, SHADOW, DRAG, 1:1 METRIC TAG
  // ============================================================

  Widget _buildInteractiveSpatialCanvas(Size size) {
    if (!_isPetPlaced) {
      // Reticle targeting guide centered on screen
      final aimColor = _surfaceDetected
          ? const Color(0xFF00E5D0)
          : const Color(0xFFFFA65C);
      return Positioned.fill(
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: aimColor.withValues(alpha: 0.85),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: aimColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: aimColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Where the pet's feet land on screen, from the floor geometry.
    final h = size.height;
    final distance = _viewingDistanceMeters;
    final feetY =
        h / 2 +
        _geo.feetOffsetY(
          pitchDownRad: _pitchDownRad,
          distanceM: distance,
          screenHeightPx: h,
        );
    final feetX =
        size.width / 2 +
        _geo.offsetX(
          anchorYawRad: _anchorYawRad,
          cameraYawRad: _yawRad,
          screenHeightPx: h,
        );
    final petPx = _geo.pixelHeight(
      realHeightM: _modelHeightM,
      distanceM: distance,
      screenHeightPx: h,
    );
    // The overlay's camera is fixed, so its widget size sets the pet's size:
    // the pet fills petPx of a square viewportPx x viewportPx widget.
    final viewportPx =
        _geo.focalPx(h) *
        2 *
        _orbitMeters *
        math.tan(_viewerFovDeg * math.pi / 360) /
        distance;
    final visible =
        _geo.isInFront(anchorYawRad: _anchorYawRad, cameraYawRad: _yawRad) &&
        viewportPx.isFinite &&
        viewportPx < size.height * 4;

    final left = feetX - viewportPx / 2;
    final top = feetY - petPx / 2 - viewportPx / 2;
    final shadowWidth = (petPx * 0.9).clamp(30.0, 400.0);

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Keep the viewer mounted (it launches native AR) but off-screen and
          // invisible when the anchor is behind the camera.
          Positioned(
            left: visible ? left : -4000,
            top: visible ? top : 0,
            width: viewportPx.isFinite ? viewportPx.clamp(40.0, 3000.0) : 40,
            height: viewportPx.isFinite ? viewportPx.clamp(40.0, 3000.0) : 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ground contact shadow where the feet touch the floor.
                Positioned(
                  bottom: (viewportPx - petPx) / 2 - shadowWidth * 0.07,
                  child: _buildFloorContactShadow(shadowWidth),
                ),
                // Rigged 3D GLB model
                _buildModel(studio: false),
              ],
            ),
          ),

          if (visible) ...[
            // Height tag above the pet's head
            Positioned(
              left: feetX - 110,
              width: 220,
              top: (feetY - petPx - 34).clamp(70.0, size.height - 200),
              child: Center(
                child: _showSpeechBubble
                    ? _buildSpeechBubble()
                    : _buildMetricRulerTag(),
              ),
            ),

            // Drag handle at the feet: moves the pet across the floor.
            Positioned(
              left: feetX - 120,
              width: 240,
              top: (feetY + 6).clamp(0.0, size.height - 40),
              child: Center(
                child: GestureDetector(
                  onPanUpdate: (details) {
                    final newDistance = _geo.distanceForTap(
                      pitchDownRad: _pitchDownRad,
                      tapDyPx: feetY + details.delta.dy - h / 2,
                      screenHeightPx: h,
                    );
                    setState(() {
                      _anchorYawRad = _geo.yawForTap(
                        cameraYawRad: _yawRad,
                        tapDxPx: feetX + details.delta.dx - size.width / 2,
                        screenHeightPx: h,
                      );
                      if (newDistance != null) {
                        _viewingDistanceMeters = newDistance;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_with, color: Colors.white, size: 11),
                        SizedBox(width: 4),
                        Text(
                          'Drag to Move',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRulerTag() {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF008F82),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.straighten, color: Colors.white, size: 12),
            const SizedBox(width: 5),
            Text(
              _arSupport == ArSupport.supported
                  ? _heightLabel
                  : '~$_heightLabel • approximate preview',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    final sound = _petType == 'cat' ? 'Meow! Purrr...' : 'Woof! Woof!';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        sound,
        style: const TextStyle(
          color: darkBrown,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFloorContactShadow(double shadowWidth) {
    final shadowHeight = shadowWidth * 0.16;
    final blur = shadowWidth * 0.12;

    return Container(
      width: shadowWidth,
      height: shadowHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.elliptical(shadowWidth / 2, shadowHeight / 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: blur,
            spreadRadius: blur / 8,
            offset: Offset(0, blur / 6),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR (BACK, TITLE PILL, OPTIONS)
  // ============================================================

  Widget _buildTopHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _roundButton(icon: Icons.arrow_back, onTap: _handleBack),

        // Mode switch tabs: Camera AR vs 3D Studio
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModeTab(
                title: 'Camera AR',
                icon: Icons.camera_alt_outlined,
                isSelected: !_is3DStudioMode,
                onTap: () {
                  setState(() {
                    _is3DStudioMode = false;
                    _runArJavaScript = null;
                  });
                  _showMessage(
                    _cameraReady
                        ? 'Switched to camera preview'
                        : 'Switched to virtual floor room',
                  );
                },
              ),
              _buildModeTab(
                title: '3D Studio',
                icon: Icons.view_in_ar_rounded,
                isSelected: _is3DStudioMode,
                onTap: () {
                  setState(() {
                    _is3DStudioMode = true;
                    _runArJavaScript = null;
                  });
                  _showMessage('Switched to Interactive 3D Model Studio');
                },
              ),
            ],
          ),
        ),

        // Options button
        _roundButton(
          icon: Icons.tune,
          tooltip: 'AR Options',
          backgroundColor: const Color(0xFF008F82),
          iconColor: Colors.white,
          onTap: _showArProjectionOptionsDialog,
        ),
      ],
    );
  }

  Widget _buildModeTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : darkText),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : darkText,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SURFACE STATUS HUD BANNER
  // ============================================================

  String get _cameraStatusText {
    switch (_arSupport) {
      case ArSupport.supported:
      case ArSupport.needsInstall:
        return _surfaceDetected
            ? 'Shutter = real floor AR • tap the floor to preview'
            : 'Aim at the floor • shutter = real floor AR';
      case ArSupport.unsupported:
        return 'Preview only: no ARCore on this phone • size approximate';
      case ArSupport.checking:
        return 'Checking Google AR support… • preview for now';
      case ArSupport.unknown:
        final reason = ArSupportService.lastUnknownReason ?? 'no answer';
        return 'Google AR check: $reason • preview for now';
    }
  }

  /// Google's check gave no clear answer: let the user open ARCore anyway.
  bool get _canTryRealAr =>
      !_is3DStudioMode &&
      !_useArCore &&
      _cameraSupported &&
      _modelGlbUrl != null &&
      (_arSupport == ArSupport.unknown || _arSupport == ArSupport.checking);

  Future<void> _tryRealAr() async {
    try {
      await _releaseCameraForArCore();
    } catch (e) {
      debugPrint('Releasing the camera for ARCore failed: $e');
    }
    if (!mounted) return;
    setState(() {
      _forceArCore = true;
      _isPetPlaced = false;
    });
  }

  /// ARCore could not start after "Try real AR": back to the sensor preview.
  void _onArCoreFailed(String error) {
    if (!mounted || !_forceArCore) return;
    setState(() => _forceArCore = false);
    if (_accelerometerSubscription == null) _initSensors();
    _initializeCamera();
    _showMessage(
      'Real AR could not start on this phone ($error). Using the floor preview.',
    );
  }

  Widget _buildSurfaceStatusBanner() {
    final statusText = _is3DStudioMode
        ? (_hasAnimations
              ? '3D Studio • drag to turn 360° • try Sit or Wag Tail'
              : '3D Studio • drag to turn 360° • pinch to zoom')
        : _useArCore
        ? _arCoreStatus
        : !_cameraReady
        ? 'Virtual floor room • tap the floor to place the model'
        : _cameraStatusText;
    final isReady = _is3DStudioMode
        ? true
        : _useArCore
        ? _arCoreReady
        : !_cameraReady || _surfaceDetected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isReady ? const Color(0xFF00E5D0) : const Color(0xFFFFA65C),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _is3DStudioMode
                ? Icons.view_in_ar_rounded
                : _useArCore
                ? (_arCoreReady
                      ? Icons.touch_app_rounded
                      : Icons.search_rounded)
                : !_cameraReady
                ? Icons.grid_on_rounded
                : (_surfaceDetected
                      ? Icons.touch_app_rounded
                      : Icons.search_rounded),
            size: 15,
            color: isReady ? const Color(0xFF00E5D0) : const Color(0xFFFFA65C),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_canTryRealAr)
            TextButton(
              key: const ValueKey('try-real-ar'),
              onPressed: _tryRealAr,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00E5D0),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 28),
              ),
              child: const Text('Try real AR'),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // DISTANCE SELECTOR FOR 1:1 METRIC SCALE CALIBRATION
  // ============================================================

  Widget _buildDistanceSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.straighten, size: 13, color: Color(0xFF00E5D0)),
                SizedBox(width: 6),
                Text(
                  'Distance:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _distanceChip(1.0, '1.0m Close'),
                const SizedBox(width: 4),
                _distanceChip(1.5, '1.5m Floor'),
                const SizedBox(width: 4),
                _distanceChip(2.0, '2.0m Room'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudioScaleIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'Viewing scale: ${(_scale * 100).round()}% • Estimated shoulder height: '
        '${_realLifeHeightCm.toStringAsFixed(0)} cm',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  Widget _distanceChip(double dist, String label) {
    final isSelected = (_viewingDistanceMeters - dist).abs() < 0.1;
    return GestureDetector(
      onTap: () {
        setState(() {
          _viewingDistanceMeters = dist;
          _isLifeScaleLocked = true;
          _scale = _calculateLifeScale(dist);
        });
        _showMessage(
          _is3DStudioMode
              ? 'Set to $label: $_petName is calibrated at ${_realLifeHeightCm.toStringAsFixed(0)} cm life-scale.'
              : '$_petName now stands $label from you.',
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF008F82) : Colors.white12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 9.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RIGHT SIDE CONTROLS (1:1 SCALE LOCK, RESET, ZOOM, PHOTO)
  // ============================================================

  Future<void> _takeSnapshot() async {
    if (!mounted) return;
    if (_useArCore && !_is3DStudioMode) {
      // Apps like Instagram drop shared text, so the details go on the photo.
      final png = await _arCoreKey.currentState?.snapshot(
        caption: [
          _petName,
          '$_petBreed • $_petSize • $_heightLabel',
          'Adopt me on My Future Pet',
        ],
      );
      if (!mounted) return;
      if (png == null) {
        _showMessage('Could not capture the AR view. Try again.');
        return;
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              png,
              mimeType: 'image/jpeg',
              name: 'my_future_pet_ar.jpg',
            ),
          ],
          text: 'Meet $_petName in my room, with My Future Pet!',
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Capture this view'),
        content: const Text(
          'Use your device or browser screenshot shortcut to save the 3D view. '
          'The model viewer cannot export its WebGL canvas through this button.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRightControls() {
    return Column(
      children: [
        // Studio zoom controls. In camera preview the size comes from the
        // distance, so resizing is not offered (it would break life size).
        if (_is3DStudioMode) ...[
          _roundButton(
            icon: Icons.straighten,
            tooltip: _isLifeScaleLocked
                ? '1:1 Life Size: LOCKED'
                : '1:1 Life Size: OFF',
            backgroundColor: _isLifeScaleLocked
                ? const Color(0xFF008F82)
                : Colors.white,
            iconColor: _isLifeScaleLocked ? Colors.white : darkBrown,
            onTap: () {
              setState(() {
                _isLifeScaleLocked = !_isLifeScaleLocked;
                if (_isLifeScaleLocked) {
                  _scale = _calculateLifeScale(_viewingDistanceMeters);
                }
              });
              _showMessage(
                _isLifeScaleLocked
                    ? '1:1 Life Size locked: ${_realLifeHeightCm.toStringAsFixed(0)} cm true scale.'
                    : 'Manual scaling enabled.',
              );
            },
          ),
          const SizedBox(height: 10),
        ],
        _roundButton(
          icon: Icons.refresh,
          tooltip: 'Reset AR Position',
          onTap: _resetAR,
        ),
        const SizedBox(height: 10),
        if (_is3DStudioMode) ...[
          _roundButton(
            icon: Icons.zoom_in,
            tooltip: 'Enlarge Pet',
            onTap: () {
              setState(() {
                _isLifeScaleLocked = false;
                _scale = (_scale + 0.15).clamp(0.4, 2.5);
              });
              _showMessage('Scale: ${(_scale * 100).toInt()}% (Custom)');
            },
          ),
          const SizedBox(height: 10),
          _roundButton(
            icon: Icons.zoom_out,
            tooltip: 'Shrink Pet',
            onTap: () {
              setState(() {
                _isLifeScaleLocked = false;
                _scale = (_scale - 0.15).clamp(0.4, 2.5);
              });
              _showMessage('Scale: ${(_scale * 100).toInt()}% (Custom)');
            },
          ),
          const SizedBox(height: 10),
        ],
        _roundButton(
          icon: Icons.camera_alt,
          tooltip: 'Snapshot options',
          backgroundColor: const Color(0xFF008F82),
          iconColor: Colors.white,
          onTap: _takeSnapshot,
        ),
        const SizedBox(height: 10),
        _roundButton(
          icon: Icons.help_outline,
          tooltip: 'How to Use AR',
          onTap: _showHelpDialog,
        ),
      ],
    );
  }

  // ============================================================
  // BEHAVIOR ACTIONS (SIT, WAG TAIL, SPEAK)
  // ============================================================

  /// Clip names of the loaded model, from the 3D viewer or real AR; null until
  /// one reports (and always in tests). Sit / Wag Tail show only when the model
  /// has that clip, so a still model never offers a button that does nothing.
  List<String>? _clipNames;
  bool get _hasAnimations => _clipNames?.isNotEmpty ?? true;
  int _animProbeGeneration = 0;
  String? _webProbedUrl;

  Future<void> _probeAnimations(Future<Object> Function(String) run) async {
    final generation = ++_animProbeGeneration;
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || generation != _animProbeGeneration) return;
      try {
        final result = await run(
          "(() => { const v = document.querySelector('model-viewer'); "
          "return v && v.loaded ? '#' + v.availableAnimations.join('|') : ''; })()",
        );
        // Android returns the string JSON-quoted.
        final text = result.toString().replaceAll('"', '');
        if (text.startsWith('#')) {
          final names = text.substring(1).split('|')
            ..removeWhere((n) => n.isEmpty);
          if (mounted && generation == _animProbeGeneration) {
            setState(() => _clipNames = names);
          }
          return;
        }
      } catch (_) {
        // The viewer is not ready yet; try again.
      }
    }
  }

  /// Starts the Sit clip once in the 3D viewer, so the pet stays seated.
  Future<void> _playOnceWhenLoaded(Future<Object> Function(String) run) async {
    for (var i = 0; i < 40; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted || _currentAction != 'Sit') return;
      try {
        final result = await run(
          "(() => { const v = document.querySelector('model-viewer'); "
          'if (!v || !v.loaded) return 0; '
          'v.play({repetitions: 1}); return 1; })()',
        );
        if (result.toString().contains('1')) return;
      } catch (_) {
        // The viewer is not ready yet; try again.
      }
    }
  }

  Widget _buildActionRow() {
    final clips = _clipNames;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (clips == null || petClipFor('Sit', clips) != null) ...[
          // While sitting, the same button stands the pet back up.
          _actionButton(
            label: _currentAction == 'Sit' ? 'Stand' : 'Sit',
            icon: _currentAction == 'Sit'
                ? Icons.accessibility_new
                : Icons.airline_seat_recline_normal,
            isSelected: false,
            onTap: () => _triggerAction('Sit'),
          ),
          const SizedBox(width: 8),
        ],
        if (clips == null || petClipFor('Wag Tail', clips) != null) ...[
          _actionButton(
            label: 'Wag Tail',
            icon: Icons.pets,
            isSelected: _currentAction == 'Wag Tail',
            onTap: () => _triggerAction('Wag Tail'),
          ),
          const SizedBox(width: 8),
        ],
        _actionButton(
          label: 'Speak',
          icon: Icons.record_voice_over,
          isSelected: _currentAction == 'Speak',
          onTap: () => _triggerAction('Speak'),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : darkBrown),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : darkBrown,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PET SUMMARY BOTTOM CARD
  // ============================================================

  Widget _buildPetInfoCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 52,
              height: 52,
              child: _petImageUrl.isNotEmpty
                  ? Image.network(
                      _petImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildThumbFallback(),
                    )
                  : _buildThumbFallback(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _petName,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$_petBreed • $_petSize • $_heightLabel',
                  style: const TextStyle(
                    color: Color(0xFF6A7982),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _isPetPlaced
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPetPlaced ? Icons.check_circle : Icons.touch_app,
                  size: 13,
                  color: _isPetPlaced
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFE65100),
                ),
                const SizedBox(width: 4),
                Text(
                  _isPetPlaced ? 'Placed' : 'Tap to Place',
                  style: TextStyle(
                    color: _isPetPlaced
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE65100),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbFallback() {
    return Container(
      color: const Color(0xFFE0E0E0),
      child: const Icon(Icons.pets, color: Color(0xFF757575), size: 26),
    );
  }

  // ============================================================
  // PLACEMENT SHUTTER BUTTON
  // ============================================================

  Widget _buildPlacementShutterButton() {
    return Center(
      child: GestureDetector(
        key: const ValueKey('camera-ar-shutter'),
        onTap: _arSessionLaunching ? null : _onCameraShutter,
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPetPlaced ? primaryColor : const Color(0xFF078F80),
            ),
            child: Icon(
              _isPetPlaced ? Icons.crop_free : Icons.add_location_alt,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: iconColor ?? darkBrown),
        ),
      ),
    );
  }

  // ============================================================
  // HELP DIALOG
  // ============================================================

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.view_in_ar, color: primaryColor),
              SizedBox(width: 8),
              Text(
                'How to use AR View',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpRow(
                Icons.touch_app,
                'Camera AR: move the phone slowly over a lit floor. When the floor is found, tap it to place $_petName at real size.',
              ),
              const SizedBox(height: 10),
              _buildHelpRow(
                Icons.open_with,
                'Drag $_petName to move it. Reset lifts it so you can place it again.',
              ),
              const SizedBox(height: 10),
              _buildHelpRow(
                Icons.pets,
                'Sit, Wag Tail and Speak make $_petName react.',
              ),
              const SizedBox(height: 10),
              _buildHelpRow(
                Icons.camera_alt,
                'The camera button captures this view to save or share.',
              ),
              const SizedBox(height: 10),
              _buildHelpRow(
                Icons.view_in_ar,
                '3D Studio: turn the model with a finger to see $_petName from every side.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Got it!',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF078F80)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
        ),
      ],
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 13)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ============================================================
// FLOOR PERSPECTIVE PAINTER (BUDGET / WEBCAM FALLBACK)
// ============================================================

class _FloorPerspectivePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4A342B).withValues(alpha: 0.85),
          const Color(0xFF281C16),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Floor planks / grid perspective lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    final vanishingX = size.width / 2;
    const vanishingY = -60.0;

    for (
      double x = -size.width * 0.4;
      x <= size.width * 1.4;
      x += size.width * 0.15
    ) {
      canvas.drawLine(
        Offset(vanishingX, vanishingY),
        Offset(x, size.height),
        linePaint,
      );
    }

    // Horizontal perspective lines
    for (double i = 0.15; i < 1.0; i += 0.16) {
      final y = size.height * math.pow(i, 1.8);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
