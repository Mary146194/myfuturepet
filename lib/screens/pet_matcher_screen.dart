import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pet_matcher.dart';
import '../saved_pet_store.dart';
import '../services/pet_matcher_service.dart';
import '../services/pet_service.dart';
import '../services/theme_service.dart';
import '../widgets/swipe_card.dart';
import 'pet_details_screen.dart';
import 'saved_pets_screen.dart';

enum _Phase { quiz, matching, deck, done, failed }

/// "Smart Matching": a rapid-fire lifestyle quiz on swipeable cards, then a
/// deck of real available pets ranked by match score. Swipe right to save a
/// pet to favorites, left to skip.
class PetMatcherScreen extends StatefulWidget {
  /// Start at the quiz even when the user already has answers.
  final bool retake;

  /// Overrides for tests.
  final Future<List<Map<String, dynamic>>> Function()? loadPets;
  final void Function(Map<String, dynamic> pet)? onSavePet;
  final PetMatcherService? service;

  /// Minimum time the "finding your matches" transition stays up.
  final Duration revealDelay;

  /// Set when shown before Home on a user's first sign-in: Skip / Done /
  /// Go to Home call this instead of closing a pushed page.
  final VoidCallback? onFinished;

  const PetMatcherScreen({
    super.key,
    this.retake = false,
    this.loadPets,
    this.onSavePet,
    this.service,
    this.revealDelay = const Duration(milliseconds: 1600),
    this.onFinished,
  });

  static Future<void> open(BuildContext context, {bool retake = false}) =>
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 380),
          pageBuilder: (_, _, _) => PetMatcherScreen(retake: retake),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          ),
        ),
      );

  @override
  State<PetMatcherScreen> createState() => _PetMatcherScreenState();
}

class _PetMatcherScreenState extends State<PetMatcherScreen> {
  static const Color primaryColor = Color(0xFFA94327);
  static const Color tealColor = Color(0xFF008F82);
  static const Color darkText = Color(0xFF062B35);

  /// One color per question card, cycling.
  static const _cardColors = [
    Color(0xFFA94327),
    Color(0xFF008F82),
    Color(0xFF7C4DBA),
    Color(0xFFE08A1E),
    Color(0xFF2F6FB5),
    Color(0xFFC2185B),
    Color(0xFF3D8B40),
  ];

  late final PetMatcherService _service = widget.service ?? PetMatcherService();

  _Phase _phase = _Phase.quiz;
  final Map<String, String> _answers = {};
  int _q = 0;
  String? _pending;
  final _questionSwiper = SwipeCardController();

  List<PetMatch> _matches = const [];
  int _deckIndex = 0;
  final List<PetMatch> _saved = [];
  final _deckSwiper = SwipeCardController();

  int _matchingLine = 0;
  Timer? _matchingTicker;

  @override
  void initState() {
    super.initState();
    if (!widget.retake) {
      final existing = _service.profile.value;
      if (existing != null) {
        _answers.addAll(existing.answers);
        _startMatching();
      } else {
        _service.load().then((loaded) {
          if (loaded != null && mounted && _phase == _Phase.quiz && _q == 0) {
            _answers.addAll(loaded.answers);
            _startMatching();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _matchingTicker?.cancel();
    super.dispose();
  }

  // ============================================================
  // QUIZ
  // ============================================================

  MatchQuestion get _question => matchQuestions[_q];

  void _choose(MatchOption option) {
    final q = _question;
    _pending = option.value;
    final index = q.options.indexOf(option);
    _questionSwiper.swipe(
      q.isSwipeable && index == 0 ? SwipeDirection.left : SwipeDirection.right,
    );
  }

  void _onQuestionSwiped(SwipeDirection direction) {
    final q = _question;
    final value =
        _pending ??
        (direction == SwipeDirection.left
            ? q.options.first.value
            : q.options.last.value);
    _pending = null;
    HapticFeedback.selectionClick();
    _answers[q.id] = value;
    if (_q < matchQuestions.length - 1) {
      setState(() => _q++);
    } else {
      _service.save(MatchProfile(Map.of(_answers)));
      _startMatching();
    }
  }

  void _back() {
    if (_q == 0) return;
    setState(() {
      _pending = null;
      _q--;
    });
  }

  // ============================================================
  // MATCHING TRANSITION
  // ============================================================

  static const _matchingLines = [
    'Reading your lifestyle...',
    'Meeting the JALRG rescues...',
    'Finding your perfect match...',
  ];

  Future<void> _startMatching() async {
    setState(() {
      _phase = _Phase.matching;
      _matchingLine = 0;
    });
    _matchingTicker?.cancel();
    _matchingTicker = Timer.periodic(
      Duration(
        milliseconds: math.max(
          200,
          widget.revealDelay.inMilliseconds ~/ _matchingLines.length,
        ),
      ),
      (_) {
        if (!mounted) return;
        setState(
          () => _matchingLine = math.min(
            _matchingLine + 1,
            _matchingLines.length - 1,
          ),
        );
      },
    );
    try {
      final loader =
          widget.loadPets ??
          () => PetService().fetchPets(status: 'available', throwOnError: true);
      final results = await Future.wait([
        loader(),
        Future<void>.delayed(widget.revealDelay),
      ]);
      final pets = results.first as List<Map<String, dynamic>>;
      if (!mounted) return;
      _matchingTicker?.cancel();
      final ranked = PetMatcher.rank(pets, MatchProfile(Map.of(_answers)));
      setState(() {
        _matches = ranked;
        _deckIndex = 0;
        _saved.clear();
        _phase = ranked.isEmpty ? _Phase.done : _Phase.deck;
      });
    } catch (e) {
      debugPrint('Pet Matcher could not load pets: $e');
      _matchingTicker?.cancel();
      if (mounted) setState(() => _phase = _Phase.failed);
    }
  }

  // ============================================================
  // DECK
  // ============================================================

  void _onPetSwiped(SwipeDirection direction) {
    final match = _matches[_deckIndex];
    if (direction == SwipeDirection.right) {
      HapticFeedback.mediumImpact();
      try {
        (widget.onSavePet ?? SavedPetStore.addPet)(match.pet);
        _saved.add(match);
      } catch (e) {
        debugPrint('Could not save ${match.petName}: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save ${match.petName}. Try again.'),
          ),
        );
      }
    }
    setState(() {
      _deckIndex++;
      if (_deckIndex >= _matches.length) _phase = _Phase.done;
    });
  }

  void _openDetails(PetMatch match) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PetDetailsScreen(pet: match.pet)));
  }

  bool get _onboarding => widget.onFinished != null;

  /// Leave the matcher: into Home on first sign-in, otherwise close the page.
  void _finish() {
    _service.markPrompted();
    final done = widget.onFinished;
    if (done != null) {
      done();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _viewSavedPets() {
    final navigator = Navigator.of(context);
    final route = MaterialPageRoute<void>(
      builder: (_) => const SavedPetsScreen(),
    );
    if (_onboarding) {
      _finish();
      navigator.push(route);
    } else {
      navigator.pushReplacement(route);
    }
  }

  void _retake() {
    setState(() {
      _answers.clear();
      _q = 0;
      _pending = null;
      _phase = _Phase.quiz;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode(context);
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFFFF7F2);
    final text = isDark ? const Color(0xFFF8FAFC) : darkText;
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF5B6B70);

    final Widget body = switch (_phase) {
      _Phase.quiz => _buildQuiz(text, sub),
      _Phase.matching => _buildMatching(text, sub),
      _Phase.deck => _buildDeck(text, sub, isDark),
      _Phase.done => _buildDone(text, sub, isDark),
      _Phase.failed => _buildFailed(text, sub),
    };

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(text, sub),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.92, end: 1.0).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(key: ValueKey(_phase), child: body),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Color text, Color sub) {
    final inQuiz = _phase == _Phase.quiz;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
      child: Row(
        children: [
          if (_onboarding)
            TextButton.icon(
              key: const ValueKey('matcher-finish'),
              onPressed: _finish,
              icon: Icon(
                inQuiz ? Icons.skip_next_rounded : Icons.home_rounded,
                size: 18,
              ),
              label: Text(inQuiz ? 'Skip' : 'Go to Home'),
            )
          else
            IconButton(
              tooltip: 'Close',
              icon: Icon(Icons.close_rounded, color: text),
              onPressed: _finish,
            ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Pet Matcher',
              style: TextStyle(
                color: text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (inQuiz && _q > 0)
            TextButton.icon(
              onPressed: _back,
              icon: const Icon(Icons.undo_rounded, size: 18),
              label: const Text('Back'),
            ),
          if (_phase == _Phase.deck || _phase == _Phase.done)
            TextButton.icon(
              key: const ValueKey('matcher-retake'),
              onPressed: _retake,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retake'),
            ),
        ],
      ),
    );
  }

  // ---------------- Quiz ----------------

  Widget _buildQuiz(Color text, Color sub) {
    final total = matchQuestions.length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Row(
            children: [
              for (var i = 0; i < total; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 5,
                    margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
                    decoration: BoxDecoration(
                      color: i <= _q
                          ? _cardColors[_q % _cardColors.length]
                          : sub.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_onboarding && _q == 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Text(
              "Welcome to My Future Pet! Let's find your perfect match first.",
              key: const ValueKey('matcher-welcome'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Question ${_q + 1} of $total',
          style: TextStyle(
            color: sub,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Peek at the next cards for a "deck" feel.
                for (var depth = 2; depth >= 1; depth--)
                  if (_q + depth < total)
                    _behindCard(
                      depth,
                      _cardColors[(_q + depth) % _cardColors.length],
                    ),
                SwipeCard(
                  key: ValueKey('question-${_question.id}'),
                  controller: _questionSwiper,
                  draggable: _question.isSwipeable,
                  onSwiped: _onQuestionSwiped,
                  overlayBuilder: _question.isSwipeable
                      ? (context, progress) => _swipeStamps(
                          progress,
                          left: _question.options.first.label,
                          right: _question.options.last.label,
                          leftColor: Colors.white,
                          rightColor: Colors.white,
                        )
                      : null,
                  child: _questionCard(
                    _question,
                    _cardColors[_q % _cardColors.length],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _behindCard(int depth, Color color) => Positioned.fill(
    child: Transform.translate(
      offset: Offset(0, depth * 12.0),
      child: Transform.scale(
        scale: 1 - depth * 0.05,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.35 / depth),
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    ),
  );

  Widget _questionCard(MatchQuestion q, Color color) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Text(q.emoji, style: const TextStyle(fontSize: 42)),
          ),
          const SizedBox(height: 18),
          Text(
            q.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            q.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          if (q.isSwipeable)
            Row(
              children: [
                for (final option in q.options) ...[
                  Expanded(child: _optionTile(q, option, compact: true)),
                  if (option != q.options.last) const SizedBox(width: 10),
                ],
              ],
            )
          else
            for (final option in q.options) ...[
              _optionTile(q, option),
              const SizedBox(height: 10),
            ],
          if (q.isSwipeable) ...[
            const SizedBox(height: 14),
            Text(
              '← swipe or tap →',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _optionTile(
    MatchQuestion q,
    MatchOption option, {
    bool compact = false,
  }) {
    final selected = _answers[q.id] == option.value;
    return Material(
      color: Colors.white.withValues(alpha: selected ? 0.32 : 0.16),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: ValueKey('match-option-${q.id}-${option.value}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () => _choose(option),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: compact ? 18 : 14,
          ),
          child: compact
              ? Column(
                  children: [
                    Text(option.emoji, style: const TextStyle(fontSize: 30)),
                    const SizedBox(height: 6),
                    Text(
                      option.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Text(option.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.chevron_right_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// "SAVE" / "SKIP" style stamps that fade in as the card is dragged.
  Widget _swipeStamps(
    double progress, {
    required String left,
    required String right,
    required Color leftColor,
    required Color rightColor,
  }) {
    Widget stamp(String label, Color color, double opacity, double angle) =>
        Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: angle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 3),
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withValues(alpha: 0.15),
              ),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        );
    return Stack(
      children: [
        Positioned(
          top: 24,
          left: 20,
          child: stamp(right, rightColor, progress * 1.6, -0.25),
        ),
        Positioned(
          top: 24,
          right: 20,
          child: stamp(left, leftColor, -progress * 1.6, 0.25),
        ),
      ],
    );
  }

  // ---------------- Matching transition ----------------

  Widget _buildMatching(Color text, Color sub) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: primaryColor,
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.elasticOut,
                  builder: (_, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: const Text('🐾', style: TextStyle(fontSize: 54)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _matchingLines[_matchingLine],
              key: ValueKey(_matchingLine),
              style: TextStyle(
                color: text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Scoring every available pet against your answers',
            style: TextStyle(color: sub, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFailed(Color text, Color sub) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 52, color: sub),
            const SizedBox(height: 12),
            Text(
              'Could not load the pets',
              style: TextStyle(
                color: text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your answers are saved. Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: sub, fontSize: 13),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: primaryColor),
              onPressed: _startMatching,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Deck ----------------

  static Color scoreColor(int score) => score >= 85
      ? tealColor
      : score >= 65
      ? const Color(0xFFE08A1E)
      : const Color(0xFF8A9599);

  Widget _buildDeck(Color text, Color sub, bool isDark) {
    final current = _matches[_deckIndex];
    return Column(
      children: [
        const SizedBox(height: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text.rich(
            key: ValueKey('headline-${current.petId}'),
            TextSpan(
              children: [
                TextSpan(
                  text: '${current.score}% Match',
                  style: TextStyle(color: scoreColor(current.score)),
                ),
                TextSpan(text: ' with ${current.petName}!'),
              ],
            ),
            style: TextStyle(
              color: text,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${_deckIndex + 1} of ${_matches.length}  •  '
          'Swipe right to save, left to skip',
          style: TextStyle(color: sub, fontSize: 12),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Stack(
              children: [
                for (var depth = 2; depth >= 1; depth--)
                  if (_deckIndex + depth < _matches.length)
                    Positioned.fill(
                      child: Transform.translate(
                        offset: Offset(0, depth * 10.0),
                        child: Transform.scale(
                          scale: 1 - depth * 0.04,
                          alignment: Alignment.bottomCenter,
                          child: _petCard(
                            _matches[_deckIndex + depth],
                            isDark,
                            behind: true,
                          ),
                        ),
                      ),
                    ),
                Positioned.fill(
                  child: SwipeCard(
                    key: ValueKey('pet-${current.petId}-$_deckIndex'),
                    controller: _deckSwiper,
                    onSwiped: _onPetSwiped,
                    overlayBuilder: (context, progress) => _swipeStamps(
                      progress,
                      left: 'Skip',
                      right: 'Save ❤',
                      leftColor: const Color(0xFFE53935),
                      rightColor: const Color(0xFF2ECC71),
                    ),
                    child: GestureDetector(
                      onTap: () => _openDetails(current),
                      child: _petCard(current, isDark, top: _deckIndex == 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _roundButton(
                key: const ValueKey('matcher-skip'),
                icon: Icons.close_rounded,
                color: const Color(0xFFE53935),
                label: 'Skip',
                onTap: () => _deckSwiper.swipe(SwipeDirection.left),
              ),
              _roundButton(
                key: const ValueKey('matcher-info'),
                icon: Icons.info_outline_rounded,
                color: const Color(0xFF2F6FB5),
                label: 'Details',
                small: true,
                onTap: () => _openDetails(current),
              ),
              _roundButton(
                key: const ValueKey('matcher-save'),
                icon: Icons.favorite_rounded,
                color: const Color(0xFF2ECC71),
                label: 'Save',
                onTap: () => _deckSwiper.swipe(SwipeDirection.right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roundButton({
    required Key key,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    bool small = false,
  }) {
    final size = small ? 50.0 : 64.0;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: color.withValues(alpha: 0.4),
        child: InkWell(
          key: key,
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: color, size: small ? 24 : 32),
          ),
        ),
      ),
    );
  }

  Widget _petCard(
    PetMatch match,
    bool isDark, {
    bool behind = false,
    bool top = false,
  }) {
    final pet = match.pet;
    final image =
        pet['image']?.toString() ?? pet['image_url']?.toString() ?? '';
    final details = [
      pet['age'],
      pet['breed'],
      pet['gender'],
    ].where((v) => v != null && v.toString().isNotEmpty).join(' • ');

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE9EEF0),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image.isNotEmpty)
              Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(Icons.pets, size: 64, color: primaryColor),
                ),
              )
            else
              const Center(
                child: Icon(Icons.pets, size: 64, color: primaryColor),
              ),
            if (behind)
              ColoredBox(color: Colors.black.withValues(alpha: 0.25))
            else ...[
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.4, 1.0],
                    colors: [
                      Color(0x55000000),
                      Colors.transparent,
                      Color(0xE6000000),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 16,
                child: _MatchMeter(
                  key: ValueKey('meter-${match.petId}'),
                  score: match.score,
                  color: scoreColor(match.score),
                ),
              ),
              if (top)
                Positioned(
                  right: 16,
                  top: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC233),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      '🏆 Top match',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.petName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (details.isNotEmpty)
                      Text(
                        details,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13.5,
                        ),
                      ),
                    if (match.reasons.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final reason in match.reasons)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                reason,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Tap the card for full details',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------- Done ----------------

  Widget _buildDone(Color text, Color sub, bool isDark) {
    final none = _matches.isEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      child: Column(
        children: [
          Text(none ? '🐾' : '🎉', style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            none
                ? 'No pets are available right now'
                : _saved.isEmpty
                ? "You've seen all your matches"
                : 'You saved ${_saved.length} '
                      '${_saved.length == 1 ? 'pet' : 'pets'}!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: text,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            none
                ? 'JALRG adds rescues often. Check back soon!'
                : _saved.isEmpty
                ? 'Retake the quiz or browse every pet to find more.'
                : 'They are in your Saved Pets. Visit them at the shelter '
                      'or start an application.',
            textAlign: TextAlign.center,
            style: TextStyle(color: sub, fontSize: 13.5),
          ),
          if (_saved.isNotEmpty) ...[
            const SizedBox(height: 20),
            for (final match in _saved)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: ListTile(
                  onTap: () => _openDetails(match),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFECD9),
                    foregroundImage:
                        (match.pet['image']?.toString() ?? '').isEmpty
                        ? null
                        : NetworkImage(match.pet['image'].toString()),
                    child: const Icon(Icons.pets, color: primaryColor),
                  ),
                  title: Text(
                    match.petName,
                    style: TextStyle(color: text, fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    match.pet['breed']?.toString() ?? '',
                    style: TextStyle(color: sub),
                  ),
                  trailing: Text(
                    '${match.score}%',
                    style: TextStyle(
                      color: scoreColor(match.score),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 18),
          if (_saved.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: primaryColor),
                onPressed: _viewSavedPets,
                icon: const Icon(Icons.favorite_rounded),
                label: const Text('View Saved Pets'),
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _retake,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retake the quiz'),
            ),
          ),
          TextButton(
            key: const ValueKey('matcher-done'),
            onPressed: _finish,
            child: Text(_onboarding ? 'Go to Home' : 'Done'),
          ),
        ],
      ),
    );
  }
}

/// Circular score that counts up from 0 when a card appears.
class _MatchMeter extends StatelessWidget {
  final int score;
  final Color color;

  const _MatchMeter({super.key, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score.toDouble()),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Container(
        width: 78,
        height: 78,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: value / 100,
              strokeWidth: 5,
              color: color,
              backgroundColor: Colors.white24,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${value.round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'MATCH',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
