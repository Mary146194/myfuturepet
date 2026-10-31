import 'package:flutter/material.dart';

import '../adoption_journey.dart';

/// One finished adoption journey in the "Adoption History" list.
class AdoptionHistoryTile extends StatelessWidget {
  final AdoptionJourney journey;
  final bool isDark;
  final VoidCallback? onTap;

  const AdoptionHistoryTile({
    super.key,
    required this.journey,
    required this.isDark,
    this.onTap,
  });

  static const Color _success = Color(0xFF2E7D32);
  static const Color _halt = Color(0xFFB4533C);
  static const Color _teal = Color(0xFF008F82);

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF062B35);
    final subTextCol = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final borderCol = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final adopted = journey.isComplete;
    final accent = adopted ? _success : (journey.halted ? _halt : _teal);
    final label = journey.statusLabel;
    final when = journey.finishedAt ?? journey.submittedAt;
    final subtitle = when == null
        ? (adopted ? 'Welcome home!' : 'Application closed')
        : '${adopted ? 'Went home' : 'Closed'} ${formatHistoryDate(when)}';

    return Semantics(
      button: onTap != null,
      label: '${journey.petName}, $label. $subtitle',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderCol),
          ),
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: journey.petImage.isEmpty
                      ? _placeholder()
                      : Image.network(
                          journey.petImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey.petName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textCol,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: subTextCol, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      adopted
                          ? Icons.check_circle_rounded
                          : Icons.history_rounded,
                      size: 13,
                      color: accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: accent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: _teal.withValues(alpha: 0.15),
    child: const Icon(Icons.pets_rounded, color: _teal, size: 18),
  );
}

/// "Oct 31, 2026" in Philippine time, matching the rest of the app.
String formatHistoryDate(DateTime instant) {
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
  final t = instant.toUtc().add(const Duration(hours: 8));
  return '${months[t.month - 1]} ${t.day}, ${t.year}';
}
