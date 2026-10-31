import 'dart:math' as math;

/// One answer choice on a Pet Matcher card.
class MatchOption {
  final String value;
  final String label;
  final String emoji;

  const MatchOption(this.value, this.label, this.emoji);
}

/// One rapid-fire lifestyle question.
class MatchQuestion {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final List<MatchOption> options;

  const MatchQuestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.options,
  });

  /// Two-answer cards can be swiped: left picks the first, right the second.
  bool get isSwipeable => options.length == 2;
}

/// The lifestyle quiz shown by the Pet Matcher.
const List<MatchQuestion> matchQuestions = [
  MatchQuestion(
    id: 'species',
    title: 'Who are you dreaming of?',
    subtitle: 'Pick the furry friend you picture at home.',
    emoji: '🐾',
    options: [
      MatchOption('dog', 'A dog', '🐶'),
      MatchOption('cat', 'A cat', '🐱'),
      MatchOption('either', 'Surprise me', '✨'),
    ],
  ),
  MatchQuestion(
    id: 'home',
    title: 'Where do you live?',
    subtitle: 'Bigger pets love a bit more room.',
    emoji: '🏡',
    options: [
      MatchOption('apartment', 'Apartment or boarding house', '🏢'),
      MatchOption('house', 'House, no yard', '🏠'),
      MatchOption('yard', 'House with a yard', '🌳'),
    ],
  ),
  MatchQuestion(
    id: 'activity',
    title: 'How much time do you have for walks and play?',
    subtitle: 'Per day, on a typical week.',
    emoji: '🎾',
    options: [
      MatchOption('low', 'Under 30 minutes', '🛋️'),
      MatchOption('medium', '30 to 60 minutes', '🚶'),
      MatchOption('high', 'More than an hour', '🏃'),
    ],
  ),
  MatchQuestion(
    id: 'kids',
    title: 'Are there kids at home?',
    subtitle: 'Swipe right for yes, left for no.',
    emoji: '👶',
    options: [
      MatchOption('no', 'No kids', '🙅'),
      MatchOption('yes', 'Yes, kids', '🧒'),
    ],
  ),
  MatchQuestion(
    id: 'alone',
    title: 'How long would your pet be alone each day?',
    subtitle: 'School, work, errands — all of it counts.',
    emoji: '⏰',
    options: [
      MatchOption('rarely', 'Rarely, someone is home', '🏠'),
      MatchOption('some', 'A few hours', '🕒'),
      MatchOption('long', 'Most of the day', '💼'),
    ],
  ),
  MatchQuestion(
    id: 'experience',
    title: 'Have you cared for a pet before?',
    subtitle: 'Swipe right for yes, left for first-timer.',
    emoji: '🎓',
    options: [
      MatchOption('first', 'First-timer', '🌱'),
      MatchOption('experienced', 'Yes, I have', '🏅'),
    ],
  ),
  MatchQuestion(
    id: 'vibe',
    title: 'Pick your ideal companion',
    subtitle: 'Go with your heart.',
    emoji: '💛',
    options: [
      MatchOption('cuddly', 'Calm and cuddly', '🧸'),
      MatchOption('playful', 'Playful buddy', '⚡'),
      MatchOption('guardian', 'Loyal guardian', '🛡️'),
    ],
  ),
];

/// A user's quiz answers, keyed by [MatchQuestion.id].
class MatchProfile {
  final Map<String, String> answers;

  const MatchProfile(this.answers);

  String? operator [](String id) => answers[id];

  bool get isComplete => matchQuestions.every((q) => answers[q.id] != null);

  Map<String, String> toJson() => Map.of(answers);

  factory MatchProfile.fromJson(Map<String, dynamic> json) => MatchProfile({
    for (final e in json.entries)
      if (e.value != null) e.key: e.value.toString(),
  });
}

/// What the matcher can read from a live pet row (type, size, age and the
/// shelter's temperament / description notes).
class PetTraits {
  final bool isCat;
  final String size;

  /// 0 = calm, 1 = moderate, 2 = high energy.
  final double energy;
  final bool young;
  final bool kidFriendly;
  final bool guardian;
  final bool loyal;
  final bool cuddly;
  final bool trained;
  final bool shy;
  final bool calm;

  const PetTraits({
    required this.isCat,
    required this.size,
    required this.energy,
    required this.young,
    required this.kidFriendly,
    required this.guardian,
    required this.loyal,
    required this.cuddly,
    required this.trained,
    required this.shy,
    required this.calm,
  });

  static bool _any(String text, List<String> words) =>
      words.any((w) => text.contains(w));

  factory PetTraits.fromPet(Map<String, dynamic> pet, {DateTime? now}) {
    final type = (pet['type'] ?? pet['category'] ?? '')
        .toString()
        .toLowerCase();
    final isCat = type.startsWith('cat');
    final size = (pet['size'] ?? 'medium').toString().toLowerCase();
    final notes = [
      pet['temperament'],
      pet['personalityShort'],
      pet['description'],
    ].whereType<Object>().join(' ').toLowerCase();

    final birth = DateTime.tryParse(pet['birthdate']?.toString() ?? '');
    final ageDays = birth == null
        ? null
        : (now ?? DateTime.now()).difference(birth).inDays;
    final young = ageDays != null && ageDays < 365;

    final lively = _any(notes, const [
      'active',
      'energetic',
      'playful',
      'lively',
      'high-spirited',
      'high spirited',
      'loves to run',
      'zoomies',
      'hyper',
    ]);
    final calm = _any(notes, const [
      'calm',
      'quiet',
      'mellow',
      'relaxed',
      'patient',
      'lap cat',
      'sunbath',
    ]);
    var energy = 1.0;
    if (lively && !calm) energy = 2;
    if (calm && !lively) energy = 0;
    if (young) energy = math.min(2, energy + 0.5);

    final notForKids = _any(notes, const [
      'no kids',
      'no children',
      'not good with children',
      'not good with kids',
      'adults only',
      'adult-only',
    ]);
    return PetTraits(
      isCat: isCat,
      size: size,
      energy: energy,
      young: young,
      kidFriendly:
          !notForKids &&
          _any(notes, const ['child', 'kid', 'family', 'gentle', 'patient']),
      guardian: _any(notes, const ['protective', 'watchdog', 'guard']),
      loyal: _any(notes, const ['loyal', 'devoted']),
      cuddly: _any(notes, const [
        'cuddl',
        'lap',
        'affectionate',
        'belly rub',
        'purr',
        'sweet',
      ]),
      trained: _any(notes, const [
        'trained',
        'obedient',
        'well-behaved',
        'well behaved',
        'leash',
      ]),
      shy: _any(notes, const ['shy', 'timid', 'nervous', 'fearful']),
      calm: calm,
    );
  }
}

/// A pet with its match score (0-100) and the top reasons it fits.
class PetMatch {
  final Map<String, dynamic> pet;
  final int score;
  final List<String> reasons;

  const PetMatch(this.pet, this.score, this.reasons);

  String get petId => pet['id']?.toString() ?? '';
  String get petName => pet['name']?.toString() ?? 'this pet';
}

class _Factor {
  final double weight;
  final double fit;
  final String? reason;

  /// How telling the reason is on a card; obvious ones rank last.
  final int priority;

  const _Factor(this.weight, this.fit, [this.reason, this.priority = 3]);
}

/// Scores live pets against a [MatchProfile].
class PetMatcher {
  const PetMatcher._();

  /// A pet of the other species never scores above this.
  static const speciesMismatchCap = 35;

  static PetMatch score(
    Map<String, dynamic> pet,
    MatchProfile profile, {
    DateTime? now,
  }) {
    final t = PetTraits.fromPet(pet, now: now);
    final factors = <_Factor>[];
    var speciesMismatch = false;

    final species = profile['species'];
    if (species != null) {
      final wanted = species == 'either' || (species == 'cat') == t.isCat;
      speciesMismatch = !wanted;
      factors.add(
        _Factor(
          3,
          wanted ? 1 : 0,
          species == 'either'
              ? null
              : t.isCat
              ? '🐱 The cat you wanted'
              : '🐶 The dog you wanted',
          0,
        ),
      );
    }

    final home = profile['home'];
    if (home != null) {
      double fit;
      String? reason;
      final calmBonus = t.energy < 0.8 ? 0.2 : 0.0;
      switch (home) {
        case 'apartment':
          fit = t.isCat
              ? 1
              : switch (t.size) {
                  'small' => 0.85,
                  'large' => 0.3,
                  _ => 0.6,
                };
          fit = math.min(1, fit + (t.isCat ? 0 : calmBonus));
          reason = '🏢 Apartment-friendly';
        case 'house':
          fit = t.isCat || t.size != 'large' ? 0.95 : 0.75 + calmBonus * 0.75;
          reason = '🏠 Fits your home';
        default:
          fit = t.isCat ? 0.95 : 1;
          reason = '🌳 Room to roam in your yard';
      }
      factors.add(_Factor(1.5, fit, reason));
    }

    final activity = profile['activity'];
    if (activity != null) {
      final time = switch (activity) {
        'low' => 0.0,
        'medium' => 1.0,
        _ => 2.0,
      };
      // Cats need far less of your time than a dog of the same energy.
      final need = t.isCat ? t.energy * 0.5 : t.energy;
      final fit = time >= need
          ? 1 - (time - need) * 0.1
          : 1 - (need - time) * 0.45;
      final reason = need >= 1.5 && time >= 1.5
          ? '🏃 Keeps up with your active days'
          : need <= 0.5 && time <= 0.5
          ? '🛋️ Happy with short walks'
          : '🎾 Matches your activity level';
      factors.add(_Factor(2, fit.clamp(0, 1), reason, 2));
    }

    final kids = profile['kids'];
    if (kids != null) {
      final fit = kids == 'no'
          ? 1.0
          : t.kidFriendly
          ? 1.0
          : t.shy
          ? 0.5
          : t.guardian
          ? 0.6
          : (!t.isCat && t.size == 'large' && t.energy >= 1.5)
          ? 0.55
          : 0.75;
      factors.add(
        _Factor(
          1.5,
          fit,
          kids == 'yes' && t.kidFriendly ? '👶 Great with kids' : null,
          5,
        ),
      );
    }

    final alone = profile['alone'];
    if (alone != null) {
      double fit;
      String? reason;
      switch (alone) {
        case 'rarely':
          fit = 1;
        case 'some':
          fit = t.isCat ? 1 : (t.energy >= 1.5 ? 0.75 : 0.9);
        default:
          fit = t.isCat
              ? 0.95
              : (t.young || t.energy >= 1.5)
              ? 0.35
              : t.calm
              ? 0.65
              : 0.5;
          if (t.isCat) reason = '😺 Fine on their own while you are out';
      }
      factors.add(_Factor(1, fit, reason));
    }

    final experience = profile['experience'];
    if (experience != null) {
      double fit;
      String? reason;
      if (experience == 'experienced') {
        fit = 1;
      } else if (t.trained || t.calm) {
        fit = 1;
        reason = '🎓 Easy for first-time owners';
      } else if (t.shy || t.guardian) {
        fit = 0.6;
      } else if (!t.isCat && t.young && t.energy >= 1.5) {
        fit = 0.55;
      } else {
        fit = 0.8;
      }
      factors.add(_Factor(1, fit, reason));
    }

    final vibe = profile['vibe'];
    if (vibe != null) {
      final (double fit, String reason) = switch (vibe) {
        'cuddly' => (
          t.cuddly ? 1.0 : (t.calm ? 0.85 : 0.45),
          '🧸 Calm and cuddly, like you wanted',
        ),
        'playful' => (
          t.energy >= 1.5 ? 1.0 : (t.energy >= 1 ? 0.7 : 0.35),
          '⚡ A playful buddy',
        ),
        _ => (t.guardian ? 1.0 : (t.loyal ? 0.8 : 0.4), '🛡️ A loyal guardian'),
      };
      factors.add(_Factor(2, fit, reason, 4));
    }

    if (factors.isEmpty) return PetMatch(pet, 50, const []);

    final total = factors.fold<double>(0, (s, f) => s + f.weight);
    final fit = factors.fold<double>(0, (s, f) => s + f.weight * f.fit) / total;
    var score = (fit * 100).round().clamp(5, 99);
    if (speciesMismatch) score = math.min(score, speciesMismatchCap);

    final strong =
        factors.where((f) => f.reason != null && f.fit >= 0.85).toList()
          ..sort((a, b) {
            final byPriority = b.priority.compareTo(a.priority);
            return byPriority != 0
                ? byPriority
                : (b.weight * b.fit).compareTo(a.weight * a.fit);
          });
    final reasons = strong.map((f) => f.reason!).take(3).toList();
    return PetMatch(pet, score, reasons);
  }

  /// Available pets, best match first (ties keep the shelter's order).
  static List<PetMatch> rank(
    Iterable<Map<String, dynamic>> pets,
    MatchProfile profile, {
    DateTime? now,
  }) {
    final matches = [
      for (final pet in pets)
        if ((pet['raw_status'] ?? pet['status'] ?? 'available')
                .toString()
                .toLowerCase() ==
            'available')
          score(pet, profile, now: now),
    ];
    final order = {for (var i = 0; i < matches.length; i++) matches[i]: i};
    matches.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : order[a]!.compareTo(order[b]!);
    });
    return matches;
  }
}
