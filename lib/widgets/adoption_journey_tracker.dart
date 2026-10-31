import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../adoption_journey.dart';

/// The "Progress Road" stepper for one adoption application.
///
/// With [celebrate] set, the road fills from the previous stage to the new
/// one, the new milestone pops, and confetti bursts from it; [onCelebrated]
/// fires once the animation has played.
class AdoptionJourneyTracker extends StatefulWidget {
  final AdoptionJourney journey;
  final bool isDark;
  final bool celebrate;
  final VoidCallback? onCelebrated;
  final VoidCallback? onBookMeetAndGreet;

  /// Shown once the pet is home: opens the Success Stories portal.
  final VoidCallback? onShareStory;
  final VoidCallback? onTap;

  /// Road, caption and action only: for embedding inside another card.
  final bool compact;

  const AdoptionJourneyTracker({
    super.key,
    required this.journey,
    required this.isDark,
    this.celebrate = false,
    this.onCelebrated,
    this.onBookMeetAndGreet,
    this.onShareStory,
    this.onTap,
    this.compact = false,
  });

  @override
  State<AdoptionJourneyTracker> createState() => _AdoptionJourneyTrackerState();
}

class _AdoptionJourneyTrackerState extends State<AdoptionJourneyTracker>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFFA94327);
  static const Color _teal = Color(0xFF008F82);
  static const Color _gold = Color(0xFFF2A93B);
  static const Color _halt = Color(0xFFB4533C);

  static const _icons = [
    Icons.description_outlined,
    Icons.manage_search_rounded,
    Icons.event_available_rounded,
    Icons.pets_rounded,
    Icons.home_rounded,
  ];

  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  double _from = 0;
  double _to = 0;
  bool _celebrating = false;
  int _runId = 0;

  int get _stage => widget.journey.stage.index;

  double get _roadValue =>
      _from + (_to - _from) * Curves.easeInOutCubic.transform(_fill.value);

  @override
  void initState() {
    super.initState();
    _from = _to = _stage.toDouble();
    _fill.value = 1;
    _syncPulse();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.celebrate) _play(from: math.max(0, _stage - 1).toDouble());
    });
  }

  @override
  void didUpdateWidget(AdoptionJourneyTracker old) {
    super.didUpdateWidget(old);
    final stageChanged = old.journey.stage != widget.journey.stage;
    if (widget.celebrate && (!old.celebrate || stageChanged)) {
      _play(from: math.min(_roadValue, math.max(0, _stage - 1).toDouble()));
    } else if (stageChanged) {
      _from = _roadValue;
      _to = _stage.toDouble();
      _fill.forward(from: 0);
    }
    _syncPulse();
  }

  void _syncPulse() {
    final live = !widget.journey.halted && !widget.journey.isComplete;
    if (live && !_pulse.isAnimating) {
      _pulse.repeat();
    } else if (!live && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  Future<void> _play({required double from}) async {
    final run = ++_runId;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.journey.halted || reduceMotion) {
      _from = _to = _stage.toDouble();
      _fill.value = 1;
      widget.onCelebrated?.call();
      return;
    }
    setState(() {
      _from = from;
      _to = _stage.toDouble();
      _celebrating = true;
    });
    _fill.value = 0;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted || run != _runId) return;
    await _fill.forward(from: 0).orCancel.catchError((_) {});
    if (!mounted || run != _runId) return;
    await _burst.forward(from: 0).orCancel.catchError((_) {});
    if (!mounted || run != _runId) return;
    setState(() => _celebrating = false);
    widget.onCelebrated?.call();
  }

  @override
  void dispose() {
    _fill.dispose();
    _pulse.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journey = widget.journey;
    final isDark = widget.isDark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF062B35);
    final subTextCol = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final borderCol = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final accent = journey.halted
        ? _halt
        : (journey.isComplete ? _gold : _teal);

    final body = <Widget>[
      _buildRoad(journey, isDark, subTextCol, textCol),
      const SizedBox(height: 14),
      _buildCaption(journey, isDark, textCol, accent),
      if (journey.needsMeetAndGreet && widget.onBookMeetAndGreet != null) ...[
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: widget.onBookMeetAndGreet,
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.calendar_month_rounded, size: 18),
            label: const Text(
              'Book Meet & Greet',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
      if (journey.isComplete && widget.onShareStory != null) ...[
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onShareStory,
            style: OutlinedButton.styleFrom(
              foregroundColor: _teal,
              side: const BorderSide(color: _teal),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.auto_stories_outlined, size: 18),
            label: Text(
              "Share ${journey.petName}'s Success Story",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    ];

    final semanticsLabel =
        '${journey.petName} adoption journey: step ${journey.stage.index + 1} '
        'of ${JourneyStage.values.length}, ${journey.statusLabel}. '
        '${journey.caption}';

    if (widget.compact) {
      return Semantics(
        container: true,
        label: semanticsLabel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: body,
        ),
      );
    }

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _celebrating ? accent.withValues(alpha: 0.6) : borderCol,
              width: _celebrating ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (_celebrating ? accent : Colors.black).withValues(
                  alpha: _celebrating ? 0.22 : (isDark ? 0 : 0.04),
                ),
                blurRadius: _celebrating ? 22 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(journey, textCol, subTextCol, accent),
              const SizedBox(height: 16),
              ...body,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    AdoptionJourney journey,
    Color textCol,
    Color subTextCol,
    Color accent,
  ) {
    final stepLabel = journey.halted
        ? (journey.applicationStatus == 'withdrawn' ? 'Withdrawn' : 'Closed')
        : journey.isComplete
        ? journey.statusLabel
        : 'Step ${journey.stage.index + 1} of ${JourneyStage.values.length}';
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 40,
            height: 40,
            child: journey.petImage.isEmpty
                ? _petPlaceholder()
                : Image.network(
                    journey.petImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _petPlaceholder(),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${journey.petName}'s journey",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textCol,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _celebrating
                      ? 'New milestone unlocked!'
                      : journey.stage.title,
                  key: ValueKey(_celebrating),
                  style: TextStyle(
                    color: _celebrating ? accent : subTextCol,
                    fontSize: 12,
                    fontWeight: _celebrating
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: widget.isDark ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            stepLabel,
            style: TextStyle(
              color: widget.isDark && !journey.halted
                  ? Color.lerp(accent, Colors.white, 0.3)
                  : accent,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _petPlaceholder() => Container(
    color: _teal.withValues(alpha: 0.15),
    child: const Icon(Icons.pets_rounded, color: _teal, size: 20),
  );

  Widget _buildRoad(
    AdoptionJourney journey,
    bool isDark,
    Color subTextCol,
    Color textCol,
  ) {
    const nodeSize = 32.0;
    final count = JourneyStage.values.length;
    final trackCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final slot = width / count;
        final span = slot * (count - 1);

        return AnimatedBuilder(
          animation: Listenable.merge([_fill, _pulse, _burst]),
          builder: (context, _) {
            final road = _roadValue;
            final fillWidth = span * (road / (count - 1)).clamp(0.0, 1.0);
            final burstX = slot * (_stage + 0.5);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Track
                Positioned(
                  left: slot / 2,
                  width: span,
                  top: nodeSize / 2 - 3,
                  height: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: trackCol,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                // Lit road
                Positioned(
                  left: slot / 2,
                  width: fillWidth,
                  top: nodeSize / 2 - 3,
                  height: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: journey.halted
                            ? [_teal, _halt]
                            : journey.isComplete
                            ? [_teal, _gold]
                            : [_teal, const Color(0xFF2DD4BF)],
                      ),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(count, (i) {
                    return SizedBox(
                      width: slot,
                      child: _buildNode(
                        i,
                        road,
                        nodeSize,
                        journey,
                        trackCol,
                        subTextCol,
                        textCol,
                      ),
                    );
                  }),
                ),
                if (_burst.isAnimating)
                  Positioned(
                    left: burstX - 90,
                    top: nodeSize / 2 - 90,
                    width: 180,
                    height: 180,
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _ConfettiPainter(
                          progress: _burst.value,
                          seed: widget.journey.applicationId.hashCode ^ _stage,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNode(
    int i,
    double road,
    double size,
    AdoptionJourney journey,
    Color trackCol,
    Color subTextCol,
    Color textCol,
  ) {
    final reached = road >= i - 0.001;
    final isCurrent = i == _stage && reached;
    final isHaltPoint = journey.halted && i == _stage;
    final isHome = i == JourneyStage.values.length - 1;

    Color fill;
    Color iconCol;
    IconData icon = _icons[i];
    if (isHaltPoint) {
      fill = _halt;
      iconCol = Colors.white;
      icon = journey.applicationStatus == 'withdrawn'
          ? Icons.undo_rounded
          : Icons.close_rounded;
    } else if (reached && isHome) {
      fill = _gold;
      iconCol = Colors.white;
    } else if (reached && !isCurrent) {
      fill = _teal;
      iconCol = Colors.white;
      icon = Icons.check_rounded;
    } else if (isCurrent) {
      fill = _teal;
      iconCol = Colors.white;
    } else {
      fill = widget.isDark ? const Color(0xFF1E293B) : Colors.white;
      iconCol = subTextCol.withValues(alpha: 0.7);
    }

    // Pop the newly reached milestone as the burst starts.
    var scale = 1.0;
    if (isCurrent && _burst.isAnimating) {
      final t = (_burst.value / 0.35).clamp(0.0, 1.0);
      scale = 1 + 0.35 * math.sin(t * math.pi);
    }

    final live = isCurrent && !journey.halted && !journey.isComplete;
    final ringT = _pulse.value;

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (live)
                Container(
                  width: size + 14 * ringT,
                  height: size + 14 * ringT,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _teal.withValues(alpha: 0.28 * (1 - ringT)),
                  ),
                ),
              Transform.scale(
                scale: scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fill,
                    border: Border.all(
                      color: reached ? fill : trackCol,
                      width: 2,
                    ),
                    boxShadow: reached
                        ? [
                            BoxShadow(
                              color: fill.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(icon, size: 17, color: iconCol),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          JourneyStage.values[i].shortTitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: isCurrent || isHaltPoint ? textCol : subTextCol,
            fontSize: 10,
            height: 1.2,
            fontWeight: isCurrent || isHaltPoint
                ? FontWeight.w800
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCaption(
    AdoptionJourney journey,
    bool isDark,
    Color textCol,
    Color accent,
  ) {
    final when = journey.meetAndGreetAt;
    final showDate =
        when != null &&
        !journey.halted &&
        (journey.stage == JourneyStage.meetAndGreet ||
            journey.meetAndGreetStatus == 'pending');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            journey.halted
                ? Icons.info_outline_rounded
                : journey.isComplete
                ? Icons.celebration_rounded
                : Icons.auto_awesome_rounded,
            size: 16,
            color: accent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journey.caption,
                  style: TextStyle(
                    color: textCol,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showDate) ...[
                  const SizedBox(height: 3),
                  Text(
                    _formatManila(when),
                    style: TextStyle(
                      color: accent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Visits are booked in Philippine time (UTC+8) regardless of device zone.
  static String _formatManila(DateTime instant) {
    final t = instant.toUtc().add(const Duration(hours: 8));
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour < 12 ? 'AM' : 'PM';
    return '${months[t.month - 1]} ${t.day}, ${t.year} · $hour:$minute $period (PH time)';
  }
}

/// A short confetti burst radiating from the centre, pulled down by gravity.
class _ConfettiPainter extends CustomPainter {
  final double progress;
  final int seed;

  _ConfettiPainter({required this.progress, required this.seed});

  static const _colors = [
    Color(0xFFA94327),
    Color(0xFF008F82),
    Color(0xFFF2A93B),
    Color(0xFF2DD4BF),
    Color(0xFFE76F51),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final center = size.center(Offset.zero);
    final fade = (1 - progress).clamp(0.0, 1.0);
    final ease = Curves.easeOutCubic.transform(progress);
    final paint = Paint();

    for (var i = 0; i < 36; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 40 + random.nextDouble() * 55;
      final spin = random.nextDouble() * math.pi * 4;
      final w = 3 + random.nextDouble() * 4;
      final h = 5 + random.nextDouble() * 5;
      final dx = math.cos(angle) * speed * ease;
      final dy = math.sin(angle) * speed * ease + 60 * progress * progress;
      paint.color = _colors[i % _colors.length].withValues(alpha: fade);
      canvas.save();
      canvas.translate(center.dx + dx, center.dy + dy);
      canvas.rotate(spin * progress);
      if (i.isEven) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: w, height: h),
            const Radius.circular(1.5),
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, w / 2, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress || old.seed != seed;
}
