import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ARViewScreen extends StatefulWidget {
  const ARViewScreen({super.key});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen>
    with WidgetsBindingObserver {
  // ============================================================
  // COLORS
  // ============================================================

  final Color brown = const Color(0xFFA94327);
  final Color darkBrown = const Color(0xFF604A43);
  final Color lightBlue = const Color(0xFFDDF3FF);
  final Color green = const Color(0xFF078F80);
  final Color darkText = const Color(0xFF24343A);
  final Color orange = const Color(0xFFFFA65C);

  // ============================================================
  // CAMERA
  // ============================================================

  CameraController? _cameraController;
  Future<void>? _initializeCameraFuture;

  bool _cameraReady = false;
  bool _cameraError = false;

  // ============================================================
  // UI STATE
  // ============================================================

  int selectedNavIndex = 2;

  String selectedAction = 'Wag Tail';

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // Automatically open camera when AR View screen opens
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _cameraController?.dispose();

    super.dispose();
  }

  // ============================================================
  // CAMERA INITIALIZATION
  // ============================================================

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _cameraError = true;
        });
        return;
      }

      // Prefer the rear/main camera
      CameraDescription selectedCamera = cameras.first;

      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          selectedCamera = camera;
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
      });
    } catch (e) {
      debugPrint('Camera initialization error: $e');

      if (!mounted) return;

      setState(() {
        _cameraError = true;
      });
    }
  }

  // ============================================================
  // CAMERA LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBrown,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),
            child: Column(
              children: [
                // ==================================================
                // MAIN AR / CAMERA AREA
                // ==================================================

                Expanded(
                  child: Stack(
                    children: [
                      // ==================================================
                      // REAL PHONE CAMERA
                      // ==================================================

                      Positioned.fill(
                        child: _buildCameraPreview(),
                      ),

                      // ==================================================
                      // DARK TRANSPARENT OVERLAY
                      // ==================================================

                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ),
                      ),

                      // ==================================================
                      // BACK BUTTON
                      // ==================================================

                      Positioned(
                        top: 25,
                        left: 15,
                        child: _roundButton(
                          icon: Icons.arrow_back,
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      // ==================================================
                      // CENTER AR PREVIEW PILL
                      // ==================================================

                      Positioned(
                        top: 25,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'AR Preview',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ==================================================
                      // HELP BUTTON
                      // ==================================================

                      Positioned(
                        top: 25,
                        right: 15,
                        child: _roundButton(
                          icon: Icons.help_outline,
                          onTap: () {
                            _showHelpDialog();
                          },
                        ),
                      ),

                      // ==================================================
                      // CAMERA STATUS
                      // ==================================================

                      if (!_cameraReady && !_cameraError)
                        Positioned(
                          top: 85,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Opening camera...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // ==================================================
                      // INSTRUCTION MESSAGE
                      // ==================================================

                      Positioned(
                        top: 113,
                        left: 40,
                        right: 40,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Point your camera at a flat surface\n'
                            'and tap to place your pet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // ==================================================
                      // AR PLACEMENT CIRCLE
                      // ==================================================

                      Positioned(
                        bottom: 230,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SizedBox(
                            width: 160,
                            height: 160,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 155,
                                  height: 155,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.60),
                                      width: 2,
                                    ),
                                  ),
                                ),

                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ==================================================
                      // RIGHT SIDE AR CONTROLS
                      // ==================================================

                      Positioned(
                        right: 14,
                        bottom: 250,
                        child: Column(
                          children: [
                            _roundButton(
                              icon: Icons.refresh,
                              onTap: () {
                                _resetAR();
                              },
                            ),

                            const SizedBox(height: 10),

                            _roundButton(
                              icon: Icons.open_with,
                              onTap: () {
                                _showMessage(
                                  'Move mode selected.',
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            _roundButton(
                              icon: Icons.crop_free,
                              onTap: () {
                                _showMessage(
                                  'Resize mode selected.',
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // ACTION BUTTONS
                      // ==================================================

                      Positioned(
                        bottom: 180,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _actionButton(
                              label: 'Sit',
                              isSelected: selectedAction == 'Sit',
                              onTap: () {
                                setState(() {
                                  selectedAction = 'Sit';
                                });

                                _showMessage(
                                  'Sit selected.',
                                );
                              },
                            ),

                            const SizedBox(width: 10),

                            _actionButton(
                              label: 'Wag Tail',
                              isSelected: selectedAction == 'Wag Tail',
                              onTap: () {
                                setState(() {
                                  selectedAction = 'Wag Tail';
                                });

                                _showMessage(
                                  'Wag Tail selected.',
                                );
                              },
                            ),

                            const SizedBox(width: 10),

                            _actionButton(
                              label: 'Speak',
                              isSelected: selectedAction == 'Speak',
                              onTap: () {
                                setState(() {
                                  selectedAction = 'Speak';
                                });

                                _showMessage(
                                  'Speak selected.',
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // PET CARD
                      // ==================================================

                      Positioned(
                        bottom: 95,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 85,
                            padding: const EdgeInsets.only(
                              top: 3,
                              bottom: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.asset(
                                    'assets/images/husky.jpg',
                                    width: 78,
                                    height: 66,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Container(
                                        width: 78,
                                        height: 66,
                                        color: const Color(0xFF777777),
                                        child: const Icon(
                                          Icons.pets,
                                          color: Colors.white,
                                          size: 34,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 3),

                                const Text(
                                  'Husky',
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ==================================================
                      // MAIN PLACE / CAMERA BUTTON
                      // ==================================================

                      Positioned(
                        bottom: 15,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _placePet();
                            },
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.20),
                                    blurRadius: 7,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFE2E2E2),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CAMERA PREVIEW
  // ============================================================

  Widget _buildCameraPreview() {
    if (_cameraError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 55,
                ),

                const SizedBox(height: 15),

                const Text(
                  'Camera unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Please allow camera permission and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _cameraError = false;
                      _cameraReady = false;
                    });

                    _initializeCamera();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brown,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Try Again',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraReady) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return FutureBuilder<void>(
      future: _initializeCameraFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _cameraController != null &&
            _cameraController!.value.isInitialized) {
          return SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize!.height,
                height: _cameraController!.value.previewSize!.width,
                child: CameraPreview(
                  _cameraController!,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: Text(
                'Unable to start camera.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        return Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ROUND BUTTON
  // ============================================================

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: darkText,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? brown : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : darkText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }


  // ============================================================
  // PLACE PET
  // ============================================================

  void _placePet() {
    if (!_cameraReady) {
      _showMessage(
        'Camera is still loading.',
      );
      return;
    }

    _showMessage(
      'Pet placement selected.',
    );

    // ==========================================================
    // FUTURE AR FUNCTION
    // ==========================================================
    //
    // Later, this is where we will connect the actual AR system.
    //
    // Example:
    //
    // 1. Detect flat surface
    // 2. Detect tap position
    // 3. Place 3D Husky
    // 4. Allow moving / resizing
    //
    // ==========================================================
  }

  // ============================================================
  // RESET AR
  // ============================================================

  void _resetAR() {
    setState(() {
      selectedAction = 'Wag Tail';
    });

    _showMessage(
      'AR view reset.',
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
          title: const Text(
            'How to use AR',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Point your camera at a flat surface. '
            'When the surface is detected, tap the place button '
            'to position your selected pet.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Got it',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
















// import 'package:flutter/material.dart';

// class ARViewScreen extends StatefulWidget {
//   const ARViewScreen({super.key});

//   @override
//   State<ARViewScreen> createState() => _ARViewScreenState();
// }

// class _ARViewScreenState extends State<ARViewScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   final Color brown = const Color(0xFFA94327);
//   final Color darkBrown = const Color(0xFF604A43);
//   final Color lightBlue = const Color(0xFFDDF3FF);
//   final Color green = const Color(0xFF078F80);
//   final Color darkText = const Color(0xFF24343A);

//   int selectedNavIndex = 2;
//   String selectedAction = 'Wag Tail';

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: darkBrown,
//       body: SafeArea(
//         child: Center(
//           child: Container(
//             constraints: const BoxConstraints(
//               maxWidth: 430,
//             ),
//             child: Column(
//               children: [
//                 // ==================================================
//                 // MAIN AR AREA
//                 // ==================================================

//                 Expanded(
//                   child: Stack(
//                     children: [
//                       // --------------------------------------------
//                       // BACKGROUND / CAMERA AREA
//                       // --------------------------------------------

//                       Positioned.fill(
//                         child: Container(
//                           decoration: const BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                               colors: [
//                                 Color(0xFFD9C6AE),
//                                 Color(0xFFEDE3D5),
//                                 Color(0xFFD8C4A7),
//                               ],
//                             ),
//                           ),
//                           child: Stack(
//                             children: [
//                               // Fake room background
//                               Positioned(
//                                 left: -25,
//                                 bottom: 130,
//                                 child: Icon(
//                                   Icons.local_florist,
//                                   size: 100,
//                                   color: Colors.green.shade800.withOpacity(
//                                     0.65,
//                                   ),
//                                 ),
//                               ),

//                               // Floor
//                               Positioned(
//                                 left: 0,
//                                 right: 0,
//                                 bottom: 0,
//                                 child: Container(
//                                   height: 210,
//                                   decoration: const BoxDecoration(
//                                     gradient: LinearGradient(
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                       colors: [
//                                         Color(0xFFC9A879),
//                                         Color(0xFFE2C99D),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                               // Simple sofa
//                               Positioned(
//                                 left: 38,
//                                 right: 38,
//                                 bottom: 220,
//                                 child: Container(
//                                   height: 100,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFCDBBA3),
//                                     borderRadius: BorderRadius.circular(18),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.15),
//                                         blurRadius: 12,
//                                         offset: const Offset(0, 7),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       Expanded(
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: Container(
//                                                 margin: const EdgeInsets.only(
//                                                   left: 8,
//                                                   top: 8,
//                                                   bottom: 8,
//                                                   right: 4,
//                                                 ),
//                                                 decoration: BoxDecoration(
//                                                   color:
//                                                       const Color(0xFFD9C8B2),
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Container(
//                                                 margin: const EdgeInsets.only(
//                                                   left: 4,
//                                                   top: 8,
//                                                   bottom: 8,
//                                                   right: 8,
//                                                 ),
//                                                 decoration: BoxDecoration(
//                                                   color:
//                                                       const Color(0xFFD9C8B2),
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),

//                               // Small table
//                               Positioned(
//                                 left: 75,
//                                 right: 75,
//                                 bottom: 170,
//                                 child: Container(
//                                   height: 16,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFB17D42),
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                 ),
//                               ),

//                               Positioned(
//                                 left: 100,
//                                 bottom: 130,
//                                 child: Container(
//                                   width: 8,
//                                   height: 55,
//                                   color: const Color(0xFF9A6938),
//                                 ),
//                               ),

//                               Positioned(
//                                 right: 100,
//                                 bottom: 130,
//                                 child: Container(
//                                   width: 8,
//                                   height: 55,
//                                   color: const Color(0xFF9A6938),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
                     

//                       // ==================================================
//                       // BACK BUTTON
//                       // ==================================================

//                       Positioned(
//                         top: 25,
//                         left: 15,
//                         child: _roundButton(
//                           icon: Icons.arrow_back,
//                           onTap: () {
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ),

//                       // ==================================================
//                       // CENTER AR PREVIEW PILL
//                       // ==================================================

//                       Positioned(
//                         top: 25,
//                         left: 0,
//                         right: 0,
//                         child: Center(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 18,
//                               vertical: 9,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(30),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.08),
//                                   blurRadius: 8,
//                                 ),
//                               ],
//                             ),
//                             child: Text(
//                               'AR Preview',
//                               style: TextStyle(
//                                 color: darkText,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                       // ==================================================
//                       // HELP BUTTON
//                       // ==================================================

//                       Positioned(
//                         top: 25,
//                         right: 15,
//                         child: _roundButton(
//                           icon: Icons.help_outline,
//                           onTap: () {
//                             _showHelpDialog();
//                           },
//                         ),
//                       ),

//                       // ==================================================
//                       // INSTRUCTION MESSAGE
//                       // ==================================================

//                       Positioned(
//                         top: 113,
//                         left: 40,
//                         right: 40,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             color: green,
//                             borderRadius: BorderRadius.circular(35),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.10),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ],
//                           ),
//                           child: const Text(
//                             'Point your camera at a flat surface\nand tap to place your pet.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               height: 1.35,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ),

//                       // ==================================================
//                       // AR PLACEMENT CIRCLE
//                       // ==================================================

//                       Positioned(
//                         bottom: 230,
//                         left: 0,
//                         right: 0,
//                         child: Center(
//                           child: SizedBox(
//                             width: 160,
//                             height: 160,
//                             child: Stack(
//                               alignment: Alignment.center,
//                               children: [
//                                 Container(
//                                   width: 155,
//                                   height: 155,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: Colors.white.withOpacity(0.55),
//                                       width: 2,
//                                     ),
//                                   ),
//                                 ),

//                                 Container(
//                                   width: 7,
//                                   height: 7,
//                                   decoration: const BoxDecoration(
//                                     color: Colors.white,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),

//                       // ==================================================
//                       // RIGHT SIDE AR CONTROLS
//                       // ==================================================

//                       Positioned(
//                         right: 14,
//                         bottom: 250,
//                         child: Column(
//                           children: [
//                             _roundButton(
//                               icon: Icons.refresh,
//                               onTap: () {
//                                 _showMessage('AR view reset.');
//                               },
//                             ),

//                             const SizedBox(height: 10),

//                             _roundButton(
//                               icon: Icons.open_with,
//                               onTap: () {
//                                 _showMessage('Move mode selected.');
//                               },
//                             ),

//                             const SizedBox(height: 10),

//                             _roundButton(
//                               icon: Icons.crop_free,
//                               onTap: () {
//                                 _showMessage('Resize mode selected.');
//                               },
//                             ),
//                           ],
//                         ),
//                       ),

//                       // ==================================================
//                       // ACTION BUTTONS
//                       // ==================================================

//                       Positioned(
//                         bottom: 180,
//                         left: 0,
//                         right: 0,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             _actionButton(
//                               label: 'Sit',
//                               isSelected: selectedAction == 'Sit',
//                               onTap: () {
//                                 setState(() {
//                                   selectedAction = 'Sit';
//                                 });
//                               },
//                             ),

//                             const SizedBox(width: 10),

//                             _actionButton(
//                               label: 'Wag Tail',
//                               isSelected: selectedAction == 'Wag Tail',
//                               onTap: () {
//                                 setState(() {
//                                   selectedAction = 'Wag Tail';
//                                 });
//                               },
//                             ),

//                             const SizedBox(width: 10),

//                             _actionButton(
//                               label: 'Speak',
//                               isSelected: selectedAction == 'Speak',
//                               onTap: () {
//                                 setState(() {
//                                   selectedAction = 'Speak';
//                                 });
//                               },
//                             ),
//                           ],
//                         ),
//                       ),

//                       // ==================================================
//                       // PET CARD
//                       // ==================================================

//                       Positioned(
//                         bottom: 95,
//                         left: 0,
//                         right: 0,
//                         child: Center(
//                           child: Container(
//                             width: 85,
//                             padding: const EdgeInsets.only(
//                               top: 3,
//                               bottom: 7,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(14),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.15),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 3),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(11),
//                                   child: Image.asset(
//                                     'assets/images/husky.jpg',
//                                     width: 78,
//                                     height: 66,
//                                     fit: BoxFit.cover,

//                                     // Fallback if image does not exist yet
//                                     errorBuilder:
//                                         (context, error, stackTrace) {
//                                       return Container(
//                                         width: 78,
//                                         height: 66,
//                                         color: const Color(0xFF777777),
//                                         child: const Icon(
//                                           Icons.pets,
//                                           color: Colors.white,
//                                           size: 34,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),

//                                 const SizedBox(height: 3),

//                                 const Text(
//                                   'Husky',
//                                   style: TextStyle(
//                                     color: Color(0xFF333333),
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),

//                       // ==================================================
//                       // MAIN PLACE BUTTON
//                       // ==================================================

//                       Positioned(
//                         bottom: 15,
//                         left: 0,
//                         right: 0,
//                         child: Center(
//                           child: GestureDetector(
//                             onTap: () {
//                               _showMessage(
//                                 'Tap on a flat surface to place your pet.',
//                               );
//                             },
//                             child: Container(
//                               width: 58,
//                               height: 58,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white,
//                                 border: Border.all(
//                                   color: Colors.white,
//                                   width: 4,
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.18),
//                                     blurRadius: 7,
//                                     offset: const Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                               child: Container(
//                                 margin: const EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.white,
//                                   border: Border.all(
//                                     color: const Color(0xFFE6E6E6),
//                                     width: 2,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // ========================================================
//                 // BOTTOM NAVIGATION
//                 // ========================================================

//                 // _buildBottomNavigation(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // ROUND BUTTON
//   // ============================================================

//   Widget _roundButton({
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(30),
//         child: Container(
//           width: 43,
//           height: 43,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.94),
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 6,
//               ),
//             ],
//           ),
//           child: Icon(
//             icon,
//             color: darkText,
//             size: 20,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // ACTION BUTTON
//   // ============================================================

//   Widget _actionButton({
//     required String label,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(
//           horizontal: 17,
//           vertical: 8,
//         ),
//         decoration: BoxDecoration(
//           color: isSelected ? brown : Colors.white,
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 5,
//             ),
//           ],
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? Colors.white : darkText,
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // BOTTOM NAVIGATION
//   // ============================================================

//   // Widget _buildBottomNavigation() {
//   //   return Container(
//   //     height: 70,
//   //     decoration: BoxDecoration(
//   //       color: lightBlue,
//   //       borderRadius: const BorderRadius.only(
//   //         topLeft: Radius.circular(10),
//   //         topRight: Radius.circular(10),
//   //       ),
//   //     ),
//   //     child: Row(
//   //       mainAxisAlignment: MainAxisAlignment.spaceAround,
//   //       children: [
//   //         _navItem(
//   //           index: 0,
//   //           icon: Icons.home_outlined,
//   //           label: 'Home',
//   //         ),

//   //         _navItem(
//   //           index: 1,
//   //           icon: Icons.pets_outlined,
//   //           label: 'Pets',
//   //         ),

//   //         _navItem(
//   //           index: 2,
//   //           icon: Icons.view_in_ar_outlined,
//   //           label: 'AR\nView',
//   //         ),

//   //         _navItem(
//   //           index: 3,
//   //           icon: Icons.people_outline,
//   //           label: 'Feed',
//   //         ),

//   //         _navItem(
//   //           index: 4,
//   //           icon: Icons.person_outline,
//   //           label: 'Profile',
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // ============================================================
//   // NAV ITEM
//   // ============================================================

//   // Widget _navItem({
//   //   required int index,
//   //   required IconData icon,
//   //   required String label,
//   // }) {
//   //   final bool isSelected = selectedNavIndex == index;

//   //   return GestureDetector(
//   //     onTap: () {
//   //       setState(() {
//   //         selectedNavIndex = index;
//   //       });

//   //       // --------------------------------------------------------
//   //       // TEMPORARY NAVIGATION
//   //       // --------------------------------------------------------
//   //       // You can connect your actual screens here later.
//   //       // --------------------------------------------------------

//   //       if (index != 2) {
//   //         _showMessage('$label selected.');
//   //       }
//   //     },
//   //     child: SizedBox(
//   //       width: 60,
//   //       height: 65,
//   //       child: Column(
//   //         mainAxisAlignment: MainAxisAlignment.center,
//   //         children: [
//   //           AnimatedContainer(
//   //             duration: const Duration(milliseconds: 180),
//   //             width: isSelected ? 65 : 40,
//   //             height: isSelected ? 43 : 35,
//   //             decoration: BoxDecoration(
//   //               color: isSelected ? const Color(0xFFFFA65C) : Colors.transparent,
//   //               borderRadius: BorderRadius.circular(25),
//   //             ),
//   //             child: Icon(
//   //               icon,
//   //               size: 18,
//   //               color: darkText,
//   //             ),
//   //           ),

//   //           const SizedBox(height: 1),

//   //           Text(
//   //             label,
//   //             textAlign: TextAlign.center,
//   //             style: TextStyle(
//   //               color: darkText,
//   //               fontSize: 10,
//   //               height: 1.0,
//   //               fontWeight: isSelected
//   //                   ? FontWeight.w600
//   //                   : FontWeight.w400,
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   // ============================================================
//   // HELP DIALOG
//   // ============================================================

//   void _showHelpDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: const Text(
//             'How to use AR',
//             style: TextStyle(
//               fontSize: 19,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: const Text(
//             'Point your camera at a flat surface. '
//             'When the surface is detected, tap the place button '
//             'to position your selected pet.',
//             style: TextStyle(
//               fontSize: 14,
//               height: 1.4,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('Got it'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // SNACKBAR
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(
//             fontSize: 13,
//           ),
//         ),
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
// }



















// import 'package:flutter/material.dart';

// class ARViewScreen extends StatelessWidget {
//   const ARViewScreen({super.key});

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color backgroundColor = const Color(0xFFF5FAFD);
//   final Color darkText = const Color(0xFF062B35);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: false,
//         title: Text(
//           'AR View',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.center_focus_strong,
//               size: 70,
//               color: primaryColor,
//             ),

//             const SizedBox(height: 20),

//             Text(
//               'AR Pet View',
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 8),

//             const Text(
//               'View pets using Augmented Reality.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14,
//               ),
//             ),

//             const SizedBox(height: 25),

//             ElevatedButton.icon(
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text(
//                       'AR camera coming soon.',
//                     ),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.camera_alt),
//               label: const Text('Start AR'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryColor,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 25,
//                   vertical: 13,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }