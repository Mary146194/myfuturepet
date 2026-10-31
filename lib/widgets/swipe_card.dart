import 'dart:math' as math;

import 'package:flutter/material.dart';

enum SwipeDirection { left, right }

/// Lets buttons swipe the top card the same way a finger would.
class SwipeCardController {
  _SwipeCardState? _state;

  Future<void> swipe(SwipeDirection direction) async =>
      _state?._flyOut(direction);
}

/// A Tinder-style card: drag it sideways and let go past the threshold (or
/// flick it) to swipe; otherwise it springs back.
class SwipeCard extends StatefulWidget {
  final Widget child;
  final ValueChanged<SwipeDirection> onSwiped;
  final SwipeCardController? controller;

  /// When false the card only moves through [controller].
  final bool draggable;

  /// Paints feedback over the card; progress runs -1 (left) to 1 (right).
  final Widget Function(BuildContext context, double progress)? overlayBuilder;

  const SwipeCard({
    super.key,
    required this.child,
    required this.onSwiped,
    this.controller,
    this.draggable = true,
    this.overlayBuilder,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this);
  Animation<Offset>? _tween;
  Offset _offset = Offset.zero;
  bool _gone = false;

  static const _flyDuration = Duration(milliseconds: 260);

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _anim.addListener(() {
      final tween = _tween;
      if (tween != null) setState(() => _offset = tween.value);
    });
  }

  @override
  void didUpdateWidget(SwipeCard old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      if (old.controller?._state == this) old.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller?._state = null;
    _anim.dispose();
    super.dispose();
  }

  /// Last laid-out width; read in gestures and animations, not in build.
  double _width = 360;
  double get _progress => (_offset.dx / (_width * 0.45)).clamp(-1.0, 1.0);

  Future<void> _animateTo(Offset target, Duration duration, Curve curve) {
    _tween = Tween(
      begin: _offset,
      end: target,
    ).animate(CurvedAnimation(parent: _anim, curve: curve));
    _anim.duration = duration;
    return _anim.forward(from: 0);
  }

  Future<void> _flyOut(SwipeDirection direction) async {
    if (_gone || !mounted) return;
    _gone = true;
    final sign = direction == SwipeDirection.right ? 1 : -1;
    await _animateTo(
      Offset(sign * _width * 1.6, _offset.dy + 40),
      _flyDuration,
      Curves.easeIn,
    );
    if (mounted) widget.onSwiped(direction);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_gone) return;
    _anim.stop();
    setState(() => _offset += d.delta);
  }

  void _onPanEnd(DragEndDetails d) {
    if (_gone) return;
    final vx = d.velocity.pixelsPerSecond.dx;
    final past = _offset.dx.abs() > _width * 0.3;
    final flicked = vx.abs() > 900 && vx.sign == _offset.dx.sign;
    if (past || flicked) {
      _flyOut(_offset.dx > 0 ? SwipeDirection.right : SwipeDirection.left);
    } else {
      _animateTo(
        Offset.zero,
        const Duration(milliseconds: 420),
        Curves.elasticOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth.isFinite) _width = constraints.maxWidth;
        return _buildCard(context);
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    final angle = _offset.dx / _width * (math.pi / 10);
    final card = Transform.translate(
      offset: _offset,
      child: Transform.rotate(
        angle: angle,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            widget.child,
            if (widget.overlayBuilder != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: widget.overlayBuilder!(context, _progress),
                ),
              ),
          ],
        ),
      ),
    );
    if (!widget.draggable) return card;
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: card,
    );
  }
}
