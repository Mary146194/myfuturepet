import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../ar_model_url.dart';
import '../services/pet_service.dart';

typedef ARModelBuilder =
    Widget Function(BuildContext context, String modelUrl, bool studio);
typedef ARSessionLauncher = Future<bool> Function();

class ARViewScreen extends StatefulWidget {
  final Map<String, dynamic>? pet;
  final VoidCallback? onBack;
  final PetService? petService;
  final ARModelBuilder? modelBuilder;
  final bool? cameraSupported;
  final ARSessionLauncher? arSessionLauncher;

  const ARViewScreen({
    super.key,
    this.pet,
    this.onBack,
    this.petService,
    this.modelBuilder,
    this.cameraSupported,
    this.arSessionLauncher,
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
  Offset _petPosition = const Offset(
    0.5,
    0.58,
  ); // Normalized viewport coordinates [0..1]
  double _scale = 1.0; // Sizing factor (0.4 to 2.5)

  String _currentAction = 'Normal'; // 'Normal', 'Sit', 'Wag Tail', 'Speak'
  bool _showSpeechBubble = false;

  // ============================================================
  // AR SURFACE DETECTION & GYROSCOPE MOTION PARALLAX
  // ============================================================

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  bool _surfaceDetected = true;
  String _surfaceStatus = 'Floor Surface Detected (Ground Horizon Locked)';
  bool _isGroundAnchored = true;
  Offset _gyroParallax = Offset.zero;

  // ============================================================
  // 1:1 METRIC LIFE-SCALE ENGINE
  // ============================================================

  bool _isLifeScaleLocked = true;
  double _viewingDistanceMeters =
      1.5; // Default distance: 1.5 meters from floor

  /// Physical shoulder height of the pet in centimeters.
  double get _realLifeHeightCm {
    final size = _petSize.toUpperCase();
    if (_petType == 'cat') return 25.0; // Domestic cat / kitten
    if (size.contains('SMALL') || size.contains('TOY')) {
      return 28.0; // Small dog (Shih Tzu, Chihuahua)
    }
    if (size.contains('LARGE') || size.contains('XL')) {
      return 60.0; // Large dog (Labrador, Golden Retriever, Sky)
    }
    return 45.0; // Medium dog baseline (Standard Aspin)
  }

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

    // Start surface detection and gyro motion parallax
    if (_cameraSupported) {
      _initSensors();
    }
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
        _cameraSupported &&
        !_is3DStudioMode) {
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

    try {
      _accelerometerSubscription = accelerometerEventStream().listen((event) {
        final norm = math.sqrt(event.x * event.x + event.z * event.z);
        final pitchDegrees = (math.atan2(event.y, norm) * 180 / math.pi).abs();

        // Pitch between 18 and 78 degrees indicates pointing toward ground/floor
        final bool detected = pitchDegrees >= 18.0 && pitchDegrees <= 78.0;
        if (detected != _surfaceDetected && mounted) {
          setState(() {
            _surfaceDetected = detected;
            _surfaceStatus = detected
                ? 'Floor Surface Detected (Ground Horizon Locked)'
                : 'Point camera toward floor to align surface';
          });
        }
      }, onError: (_) {});

      _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
        if (!_isGroundAnchored || !mounted) return;
        // Apply counter-motion parallax displacement:
        final dx = _gyroParallax.dx - (event.y * 0.0075);
        final dy = _gyroParallax.dy + (event.x * 0.0075);
        setState(() {
          _gyroParallax = Offset(
            dx.clamp(-0.20, 0.20) * 0.985,
            dy.clamp(-0.16, 0.16) * 0.985,
          );
        });
      }, onError: (_) {});
    } catch (e) {
      debugPrint('Sensor initialization error: $e');
    }
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

  void _triggerAction(String action) {
    setState(() {
      _currentAction = action;
      _showSpeechBubble = false;
    });

    if (action == 'Wag Tail') {
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

  void _resetAR() {
    setState(() {
      _viewerReset++;
      _petPosition = const Offset(0.5, 0.58);
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
          'Camera AR is unavailable or still loading. Use the virtual floor or try again.',
        );
      }
    } catch (error) {
      debugPrint('Could not start native AR: $error');
      if (!mounted) return;
      _showMessage(
        'Could not start Camera AR. Use the virtual floor or try again.',
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
    return ModelViewer(
      key: ValueKey(
        '${url}_${studio ? 'studio' : 'camera'}_$_currentAction'
        '_${_viewerReset}_${studio ? _scale : 1}',
      ),
      src: url,
      alt: '3D model of $_petName',
      ar: !studio,
      arModes: const ['scene-viewer', 'quick-look', 'webxr'],
      arPlacement: ArPlacement.floor,
      arScale: ArScale.fixed,
      onWebViewCreated: studio
          ? null
          : (controller) {
              _runArJavaScript = controller.runJavaScriptReturningResult;
            },
      autoRotate: studio,
      cameraControls: true,
      autoPlay: true,
      animationName: _currentAction == 'Sit' ? 'sit' : 'idle',
      backgroundColor: studio ? const Color(0xFF1E2833) : Colors.transparent,
      shadowIntensity: 0.85,
      shadowSoftness: 0.9,
      cameraOrbit: studio
          ? '0deg 75deg ${(105 / _scale).clamp(40, 260).toStringAsFixed(0)}%'
          : '0deg 75deg 105%',
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
    final size = media.size;

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
                  if (!_is3DStudioMode)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapUp: (details) {
                          // Tap anywhere on the floor to position pet
                          final tappedX =
                              (details.localPosition.dx / size.width).clamp(
                                0.10,
                                0.90,
                              );
                          final tappedY =
                              (details.localPosition.dy / size.height).clamp(
                                0.20,
                                0.85,
                              );
                          setState(() {
                            _petPosition = Offset(tappedX, tappedY);
                            _isPetPlaced = true;
                          });
                          _showMessage('$_petName positioned on floor.');
                        },
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
                  if (!_is3DStudioMode && !_isPetPlaced)
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
                                  'Aim at floor & tap surface or shutter to place pet',
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
                  if (!_is3DStudioMode) _buildInteractiveSpatialCanvas(size),

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
                  if (_is3DStudioMode || _isLifeScaleLocked)
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
      return Positioned.fill(
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    (_surfaceDetected
                            ? const Color(0xFF00E5D0)
                            : const Color(0xFFFFA65C))
                        .withValues(alpha: 0.85),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (_surfaceDetected
                              ? const Color(0xFF00E5D0)
                              : const Color(0xFFFFA65C))
                          .withValues(alpha: 0.3),
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
                  color: _surfaceDetected
                      ? const Color(0xFF00E5D0)
                      : const Color(0xFFFFA65C),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final viewportW = (280.0 * _scale).clamp(160.0, size.width * 0.95);
    final viewportH = (340.0 * _scale).clamp(200.0, size.height * 0.70);

    // Position calculations with ground parallax anchoring
    final effectiveX =
        (_petPosition.dx + (_isGroundAnchored ? _gyroParallax.dx : 0.0)).clamp(
          0.05,
          0.95,
        );
    final effectiveY =
        (_petPosition.dy + (_isGroundAnchored ? _gyroParallax.dy : 0.0)).clamp(
          0.15,
          0.90,
        );

    // Mathematically centered horizontally on screen
    final petX = (effectiveX * size.width) - (viewportW / 2);
    final petY = (effectiveY * size.height) - (viewportH / 2);

    final maxLeft = math.max(0.0, size.width - viewportW);
    final leftPos = petX.clamp(0.0, maxLeft).toDouble();
    final maxTop = math.max(60.0, size.height - viewportH - 120.0);
    final topPos = petY.clamp(60.0, math.max(60.0, maxTop)).toDouble();

    return Positioned(
      left: leftPos,
      top: topPos,
      width: viewportW,
      height: viewportH,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Metric Life-Scale Ruler Tag or Speech Bubble
          if (_showSpeechBubble)
            _buildSpeechBubble()
          else if (_isLifeScaleLocked)
            _buildMetricRulerTag(),

          // The 3D Model Viewer directly over the camera with transparent WebGL
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ground Contact Shadow on the Floor
                Positioned(
                  bottom: 14 * _scale,
                  child: _buildFloorContactShadow(),
                ),

                // Rigged 3D GLB Model
                _buildModel(studio: false),

                // Floating Drag Handle
                Positioned(
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        final newDx =
                            _petPosition.dx + (details.delta.dx / size.width);
                        final newDy =
                            _petPosition.dy + (details.delta.dy / size.height);
                        _petPosition = Offset(
                          newDx.clamp(0.1, 0.9),
                          newDy.clamp(0.2, 0.85),
                        );
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRulerTag() {
    final heightCm = _realLifeHeightCm.toStringAsFixed(0);
    final heightIn = (_realLifeHeightCm / 2.54).toStringAsFixed(1);
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
              'Height: $heightCm cm ($heightIn in) • 1:1 Life Scale',
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

  Widget _buildFloorContactShadow() {
    final shadowWidth = (140.0 * _scale).clamp(80.0, 300.0);
    final shadowHeight = (22.0 * _scale).clamp(12.0, 50.0);

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
            blurRadius: 18 * _scale,
            spreadRadius: 2 * _scale,
            offset: Offset(0, 3 * _scale),
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

  Widget _buildSurfaceStatusBanner() {
    final statusText = _is3DStudioMode
        ? '3D Interactive Studio • 360° Inspection & Rigged Animations'
        : !_cameraReady
        ? 'Virtual floor room • drag to position the model'
        : _surfaceStatus;
    final isDetected = _is3DStudioMode || !_cameraReady || _surfaceDetected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDetected ? const Color(0xFF00E5D0) : const Color(0xFFFFA65C),
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
                : !_cameraReady
                ? Icons.grid_on_rounded
                : (_surfaceDetected
                      ? Icons.check_circle_rounded
                      : Icons.search_rounded),
            size: 15,
            color: isDetected
                ? const Color(0xFF00E5D0)
                : const Color(0xFFFFA65C),
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
          if (!_is3DStudioMode && _cameraReady && _surfaceDetected) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isGroundAnchored = !_isGroundAnchored;
                  _gyroParallax = Offset.zero;
                });
                _showMessage(
                  _isGroundAnchored
                      ? 'Floor surface locked. Pet stays fixed on ground.'
                      : 'Floor lock off (free-floating).',
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _isGroundAnchored
                      ? const Color(0xFF008F82)
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isGroundAnchored ? 'LOCKED' : 'UNLOCK',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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
          'Set to $label: $_petName is calibrated at ${_realLifeHeightCm.toStringAsFixed(0)} cm life-scale.',
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
        // 1:1 Life Size Mode Button
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
        if (!_is3DStudioMode)
          _roundButton(
            icon: _isGroundAnchored ? Icons.anchor : Icons.anchor_outlined,
            tooltip: _isGroundAnchored
                ? 'Floor Anchor: ON'
                : 'Floor Anchor: OFF',
            backgroundColor: _isGroundAnchored
                ? const Color(0xFF008F82)
                : Colors.white,
            iconColor: _isGroundAnchored ? Colors.white : darkBrown,
            onTap: () {
              setState(() {
                _isGroundAnchored = !_isGroundAnchored;
                _gyroParallax = Offset.zero;
              });
              _showMessage(
                _isGroundAnchored
                    ? 'Floor surface lock enabled.'
                    : 'Free-floating mode enabled.',
              );
            },
          ),
        if (!_is3DStudioMode) const SizedBox(height: 10),
        _roundButton(
          icon: Icons.refresh,
          tooltip: 'Reset AR Position',
          onTap: _resetAR,
        ),
        const SizedBox(height: 10),
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

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _actionButton(
          label: 'Sit',
          icon: Icons.airline_seat_recline_normal,
          isSelected: _currentAction == 'Sit',
          onTap: () => _triggerAction('Sit'),
        ),
        const SizedBox(width: 8),
        _actionButton(
          label: 'Wag Tail',
          icon: Icons.pets,
          isSelected: _currentAction == 'Wag Tail',
          onTap: () => _triggerAction('Wag Tail'),
        ),
        const SizedBox(width: 8),
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
    final heightText = '${_realLifeHeightCm.toStringAsFixed(0)} cm';
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
                  '$_petBreed • $_petSize ($heightText height)',
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
    if (_is3DStudioMode) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: _resetAR,
          icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
          label: const Text(
            'Reset Turntable',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF008F82),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 6,
          ),
        ),
      );
    }

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
                'Tap anywhere on your floor to position $_petName instantly.',
              ),
              const SizedBox(height: 10),
              _buildHelpRow(
                Icons.open_with,
                'Use the "Drag to Move" handle beneath the pet to slide across the room.',
              ),
              const SizedBox(height: 10),
              _buildHelpRow(
                Icons.straighten,
                'Tap 1:1 Life Size on the right to lock accurate physical dimensions (cm/inches).',
              ),
              const SizedBox(height: 10),
              _buildHelpRow(
                Icons.pin_drop,
                'Select distance (1.0m, 1.5m, 2.0m) to calibrate perspective depth.',
              ),
              const SizedBox(height: 10),
              _buildHelpRow(
                Icons.camera_alt,
                'Tap the snapshot button for instructions to save this view with your device or browser.',
              ),
              const SizedBox(height: 10),
              _buildHelpRow(
                Icons.pets,
                'Tap Sit, Wag Tail, or Speak to trigger real-time reactions.',
              ),
              const SizedBox(height: 10),
              _buildHelpRow(
                Icons.refresh,
                'Tap Reset to return $_petName to the center with 1:1 life-scale.',
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
