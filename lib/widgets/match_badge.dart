import 'package:flutter/material.dart';

import '../pet_matcher.dart';
import '../services/pet_matcher_service.dart';

/// "92% Match" pill for pet cards; hidden until the user takes the quiz.
class MatchBadge extends StatelessWidget {
  final Map<String, dynamic> pet;
  final PetMatcherService? service;

  const MatchBadge({super.key, required this.pet, this.service});

  static Color colorFor(int score) => score >= 85
      ? const Color(0xFF008F82)
      : score >= 65
      ? const Color(0xFFE08A1E)
      : const Color(0xFF6B7A80);

  @override
  Widget build(BuildContext context) {
    final matcher = service ?? PetMatcherService();
    return ValueListenableBuilder<MatchProfile?>(
      valueListenable: matcher.profile,
      builder: (context, profile, _) {
        if (profile == null) return const SizedBox.shrink();
        final score = PetMatcher.score(pet, profile).score;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: colorFor(score),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 6),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.white, size: 12),
              const SizedBox(width: 4),
              Text(
                '$score% Match',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
