import 'dart:async';

import 'package:flutter/material.dart';

import '../screens/how_to_use_screen.dart';

/// Floating "How to Use" button for the Home tab. A speech bubble ("Click
/// this to know how to use the app") pops up when Home opens so new users
/// notice the tutorial; it hides after a few seconds, when closed, or when
/// the button is used. Long-press the button to see the hint again.
class HowToUseFab extends StatefulWidget {
  /// How long the bubble stays up on its own.
  final Duration bubbleDuration;

  /// Opens the tutorial; replaceable in tests.
  final void Function(BuildContext context)? onOpen;

  const HowToUseFab({
    super.key,
    this.bubbleDuration = const Duration(seconds: 8),
    this.onOpen,
  });

  static const hint = 'Click this to know how to use the app';

  /// The bubble pops up once per app launch, not on every tab switch.
  static bool _shownThisLaunch = false;

  @visibleForTesting
  static void resetForTest() => _shownThisLaunch = false;

  @override
  State<HowToUseFab> createState() => _HowToUseFabState();
}

class _HowToUseFabState extends State<HowToUseFab>
    with SingleTickerProviderStateMixin {
  static const Color _brand = Color(0xFFA94327);

  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _bubble = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    if (!HowToUseFab._shownThisLaunch) {
      HowToUseFab._shownThisLaunch = true;
      // Let Home settle first so the bubble catches the eye.
      _hideTimer = Timer(const Duration(milliseconds: 700), _showBubble);
    }
  }

  void _showBubble() {
    if (!mounted) return;
    setState(() => _bubble = true);
    _bounce.repeat(reverse: true);
    _hideTimer?.cancel();
    _hideTimer = Timer(widget.bubbleDuration, _hideBubble);
  }

  void _hideBubble() {
    _hideTimer?.cancel();
    if (!mounted) return;
    _bounce.stop();
    _bounce.value = 0;
    setState(() => _bubble = false);
  }

  void _open() {
    _hideBubble();
    (widget.onOpen ?? HowToUseScreen.open)(context);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              alignment: Alignment.bottomRight,
              child: child,
            ),
          ),
          child: _bubble ? _speechBubble() : const SizedBox.shrink(),
        ),
        AnimatedBuilder(
          animation: _bounce,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, -6 * Curves.easeOut.transform(_bounce.value)),
            child: child,
          ),
          child: Tooltip(
            message: HowToUseFab.hint,
            child: FloatingActionButton(
              key: const ValueKey('how-to-use-fab'),
              // Feed keeps its own FAB alive in the tab stack.
              heroTag: 'how-to-use-fab',
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              onPressed: _open,
              child: const Icon(Icons.menu_book_rounded, size: 26),
            ),
          ),
        ),
      ],
    );
  }

  Widget _speechBubble() {
    return Padding(
      key: const ValueKey('how-to-use-bubble'),
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Material(
            color: Colors.white,
            elevation: 6,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _open,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 230),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👋', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          HowToUseFab.hint,
                          style: TextStyle(
                            color: Color(0xFF062B35),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                      IconButton(
                        key: const ValueKey('how-to-use-bubble-close'),
                        tooltip: 'Hide',
                        visualDensity: VisualDensity.compact,
                        iconSize: 16,
                        color: const Color(0xFF5B6B70),
                        icon: const Icon(Icons.close_rounded),
                        onPressed: _hideBubble,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Little tail pointing down at the button.
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CustomPaint(
              size: const Size(16, 9),
              painter: _TailPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawShadow(path, Colors.black26, 2, false);
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
