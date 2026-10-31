import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/theme_service.dart';
import '../tutorial_content.dart';

/// Remembers which guides were opened on this device.
class TutorialProgress {
  static const _key = 'tutorial_read_sections';

  static final ValueNotifier<Set<String>> read = ValueNotifier({});
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      read.value = (prefs.getStringList(_key) ?? const []).toSet();
      _loaded = true;
    } catch (_) {}
  }

  static Future<void> markRead(String id) async {
    if (read.value.contains(id)) return;
    read.value = {...read.value, id};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, read.value.toList());
    } catch (_) {}
  }

  @visibleForTesting
  static void reset() {
    read.value = {};
    _loaded = false;
  }
}

class _Palette {
  final Color bg, card, text, sub, border;
  const _Palette(this.bg, this.card, this.text, this.sub, this.border);

  factory _Palette.of(BuildContext context) => ThemeService.isDarkMode(context)
      ? const _Palette(
          Color(0xFF0F172A),
          Color(0xFF1E293B),
          Color(0xFFF8FAFC),
          Color(0xFF94A3B8),
          Color(0xFF334155),
        )
      : const _Palette(
          Color(0xFFF5FAFD),
          Colors.white,
          Color(0xFF062B35),
          Color(0xFF5B6B70),
          Color(0xFFE2E8F0),
        );
}

/// "How to Use": every feature's step-by-step guide.
class HowToUseScreen extends StatefulWidget {
  const HowToUseScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const HowToUseScreen()));

  @override
  State<HowToUseScreen> createState() => _HowToUseScreenState();
}

class _HowToUseScreenState extends State<HowToUseScreen> {
  @override
  void initState() {
    super.initState();
    TutorialProgress.load();
  }

  void _openSection(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TutorialSectionScreen(index: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.card,
        elevation: 0,
        foregroundColor: p.text,
        title: Text(
          'How to Use',
          style: TextStyle(color: p.text, fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: TutorialProgress.read,
        builder: (context, read, _) {
          final done = tutorialSections.where((s) => read.contains(s.id));
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _intro(p, done.length),
              const SizedBox(height: 18),
              Text(
                'Guides',
                style: TextStyle(
                  color: p.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap a guide to see its steps. Each one takes about a minute.',
                style: TextStyle(color: p.sub, fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < tutorialSections.length; i++)
                _sectionCard(p, i, read.contains(tutorialSections[i].id)),
            ],
          );
        },
      ),
    );
  }

  Widget _intro(_Palette p, int done) {
    final total = tutorialSections.length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [brandColor, Color(0xFFD9692F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Welcome to My Future Pet!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Simple step-by-step guides for every part of the app, from '
            'creating your account to bringing your new pet home.',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: done / total,
              minHeight: 7,
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            done == total
                ? 'All $total guides read. You\'re a pro! 🎉'
                : '$done of $total guides read',
            key: const ValueKey('tutorial-progress'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey('tutorial-start-tour'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: brandColor,
            ),
            onPressed: () => _openSection(0),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(done == 0 ? 'Start the full tour' : 'Start again'),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(_Palette p, int index, bool read) {
    final s = tutorialSections[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: ValueKey('tutorial-section-${s.id}'),
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openSection(index),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(s.icon, color: s.color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${s.title}',
                        style: TextStyle(
                          color: p.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.subtitle,
                        style: TextStyle(color: p.sub, fontSize: 12.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${s.steps.length} steps',
                        style: TextStyle(
                          color: s.color,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  read
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: read ? const Color(0xFF2E9E5B) : p.sub,
                  semanticLabel: read ? 'Read' : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One guide: where to find the feature, numbered steps with visuals, tips,
/// and buttons to the previous / next guide.
class TutorialSectionScreen extends StatefulWidget {
  final int index;

  const TutorialSectionScreen({super.key, required this.index});

  @override
  State<TutorialSectionScreen> createState() => _TutorialSectionScreenState();
}

class _TutorialSectionScreenState extends State<TutorialSectionScreen> {
  TutorialSection get _section => tutorialSections[widget.index];

  @override
  void initState() {
    super.initState();
    // After the first frame: the guide list listens to this and may be
    // building underneath during the page transition.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => TutorialProgress.markRead(_section.id),
    );
  }

  void _goTo(int index) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, _, _) => TutorialSectionScreen(index: index),
        transitionsBuilder: (_, animation, _, child) => SlideTransition(
          position: Tween(
            begin: Offset(index > widget.index ? 1 : -1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final s = _section;
    final isLast = widget.index == tutorialSections.length - 1;
    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: s.color,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Guide ${widget.index + 1} of ${tutorialSections.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _header(s),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < s.steps.length; i++)
                  _StepCard(
                    number: i + 1,
                    step: s.steps[i],
                    color: s.color,
                    palette: p,
                    isLast: i == s.steps.length - 1,
                  ),
                if (s.iconGuide.isNotEmpty) _iconGuide(p, s),
                if (s.tips.isNotEmpty) _tips(p, s),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            color: p.card,
            border: Border(top: BorderSide(color: p.border)),
          ),
          child: Row(
            children: [
              if (widget.index > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('tutorial-previous'),
                    onPressed: () => _goTo(widget.index - 1),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Previous'),
                  ),
                ),
              if (widget.index > 0) const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('tutorial-next'),
                  style: FilledButton.styleFrom(backgroundColor: s.color),
                  onPressed: isLast
                      ? () => Navigator.of(context).pop()
                      : () => _goTo(widget.index + 1),
                  icon: Icon(
                    isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(
                    isLast
                        ? 'Finish'
                        : 'Next: ${tutorialSections[widget.index + 1].title}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(TutorialSection s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
      color: s.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(s.icon, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      s.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Where to find it: ',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        TextSpan(text: s.whereToFind),
                      ],
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      height: 1.35,
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

  Widget _iconGuide(_Palette p, TutorialSection s) {
    return _panel(
      p,
      icon: Icons.interests_outlined,
      title: 'Icon guide',
      color: s.color,
      child: Column(
        children: [
          for (final (icon, meaning) in s.iconGuide)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: s.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: s.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      meaning,
                      style: TextStyle(color: p.text, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _tips(_Palette p, TutorialSection s) {
    return _panel(
      p,
      icon: Icons.lightbulb_outline_rounded,
      title: 'Helpful tips',
      color: const Color(0xFFE0A100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final tip in s.tips)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 ', style: TextStyle(fontSize: 13, color: p.text)),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 13.5,
                        height: 1.4,
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

  Widget _panel(
    _Palette p, {
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: p.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final TutorialStep step;
  final Color color;
  final _Palette palette;
  final bool isLast;

  const _StepCard({
    required this.number,
    required this.step,
    required this.color,
    required this.palette,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Numbered dot with a line to the next step.
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.body,
                    style: TextStyle(
                      color: p.sub,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                  if (step.visual != null) ...[
                    const SizedBox(height: 12),
                    TutorialVisualView(
                      visual: step.visual!,
                      accent: color,
                      dark: ThemeService.isDarkMode(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a [TutorialVisual] as a small replica of the real control.
class TutorialVisualView extends StatelessWidget {
  final TutorialVisual visual;
  final Color accent;
  final bool dark;

  const TutorialVisualView({
    super.key,
    required this.visual,
    required this.accent,
    this.dark = false,
  });

  Color get _surface =>
      dark ? const Color(0xFF0F172A) : const Color(0xFFF5F8FA);
  Color get _ink => dark ? const Color(0xFFE2E8F0) : const Color(0xFF062B35);

  @override
  Widget build(BuildContext context) {
    final v = visual;
    final Widget content = switch (v) {
      ButtonVisual() => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: v.color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (v.icon != null) ...[
                Icon(v.icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  v.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ChipsVisual() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < v.labels.length; i++)
            _chip(
              v.labels[i],
              selected: v.selected == i,
              icon: v.icons != null && i < v.icons!.length ? v.icons![i] : null,
            ),
        ],
      ),
      FieldsVisual() => Column(
        children: [
          for (final (icon, hint) in v.fields)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: accent),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      hint,
                      style: TextStyle(color: _ink.withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      TabsVisual() => _tabs(v.highlight),
      IconsVisual() => Wrap(
        spacing: 14,
        runSpacing: 10,
        children: [
          for (final (icon, caption) in v.icons)
            SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF1E293B) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Color(0x1A000000), blurRadius: 6),
                      ],
                    ),
                    child: Icon(icon, color: accent, size: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _ink,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      StagesVisual() => Column(
        children: [
          for (var i = 0; i < v.stages.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      v.stages[i],
                      style: TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      GestureVisual() => Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(v.icon, color: accent, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              v.caption,
              style: TextStyle(
                color: _ink,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: content,
    );
  }

  Widget _chip(String label, {bool selected = false, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? accent
            : (dark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? accent : accent.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: selected ? Colors.white : accent),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _ink,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Replica of the app's bottom bar with [highlight] selected.
  Widget _tabs(int highlight) {
    const tabs = [
      (Icons.home_rounded, 'Home'),
      (Icons.pets, 'Pets'),
      (Icons.center_focus_strong, 'AR View'),
      (Icons.people_outline, 'Feed'),
      (Icons.person_outline, 'Profile'),
    ];
    return Row(
      children: [
        for (var i = 0; i < tabs.length; i++)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i == highlight
                    ? const Color(0xFFFFB067)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(
                    tabs[i].$1,
                    size: 20,
                    color: i == highlight
                        ? const Color(0xFF7A2E12)
                        : _ink.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tabs[i].$2,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: i == highlight
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: i == highlight
                          ? const Color(0xFF7A2E12)
                          : _ink.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
