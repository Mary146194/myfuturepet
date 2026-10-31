import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/pet_matcher.dart';
import 'package:myfuturepet/screens/pet_matcher_screen.dart';
import 'package:myfuturepet/services/pet_matcher_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shaped like PetService's normalized rows, using the live JALRG notes.
Map<String, dynamic> _pet(
  String id,
  String name,
  String type,
  String size,
  String temperament, {
  String description = '',
  String birthdate = '2024-01-01',
  String status = 'available',
}) => {
  'id': id,
  'name': name,
  'type': type,
  'size': size,
  'temperament': temperament,
  'description': description,
  'birthdate': birthdate,
  'raw_status': status,
  'breed': type == 'dog' ? 'Aspin' : 'Puspin',
  'age': '2 yrs',
  'gender': 'Female',
  'image': '',
};

final _now = DateTime(2026, 10, 31);

final _sky = _pet(
  'sky',
  'Sky',
  'dog',
  'large',
  'Calm, highly intelligent, obedient, patient with children',
  description: 'Sky is very gentle, walks gracefully on a leash.',
);
final _coco = _pet(
  'coco',
  'Coco',
  'dog',
  'medium',
  'Active, playful, loyal, good watchdog',
  birthdate: '2026-03-01',
);
final _bruno = _pet(
  'bruno',
  'Bruno',
  'dog',
  'large',
  'Calm demeanor, protective, well-behaved on leash',
);
final _muning = _pet(
  'muning',
  'Muning',
  'cat',
  'small',
  'Affectionate, quiet, purrs when petted, litter-trained',
);
final _mochi = _pet(
  'mochi',
  'Mochi',
  'cat',
  'small',
  'Sweet lap cat, vocal, loves cuddles',
);

MatchProfile _profile(Map<String, String> answers) => MatchProfile(answers);

/// Stands in for the `pet_matcher_profiles` table.
class _FakeRemote extends PetMatcherRemote {
  final Map<String, Map<String, dynamic>> rows = {};
  bool offline = false;
  int writes = 0;

  @override
  Future<Map<String, dynamic>?> fetch(String userId) async {
    if (offline) throw Exception('offline');
    return rows[userId];
  }

  @override
  Future<void> upsert(String userId, {Map<String, String>? answers}) async {
    if (offline) throw Exception('offline');
    writes++;
    rows[userId] = {
      'answers': answers,
      'status': answers == null ? 'skipped' : 'completed',
    };
  }
}

MatchProfile _fullProfile(String Function(MatchQuestion q) pick) =>
    MatchProfile({for (final q in matchQuestions) q.id: pick(q)});

void main() {
  group('PetMatcher scoring', () {
    test('a calm, kid-friendly dog tops a family of first-timers', () {
      final profile = _profile({
        'species': 'dog',
        'home': 'house',
        'activity': 'medium',
        'kids': 'yes',
        'alone': 'some',
        'experience': 'first',
        'vibe': 'cuddly',
      });
      final ranked = PetMatcher.rank(
        [_coco, _bruno, _sky, _muning],
        profile,
        now: _now,
      );
      expect(ranked.first.petName, 'Sky');
      expect(ranked.first.score, greaterThanOrEqualTo(85));
      expect(ranked.first.reasons, contains('👶 Great with kids'));
      // A cat never outranks dogs for someone who wants a dog.
      expect(ranked.last.petName, 'Muning');
      expect(ranked.last.score, lessThanOrEqualTo(35));
    });

    test('an active yard owner wanting a playful buddy gets Coco', () {
      final match = PetMatcher.rank(
        [_sky, _bruno, _coco],
        _profile({
          'species': 'dog',
          'home': 'yard',
          'activity': 'high',
          'kids': 'no',
          'alone': 'rarely',
          'experience': 'experienced',
          'vibe': 'playful',
        }),
        now: _now,
      ).first;
      expect(match.petName, 'Coco');
      expect(match.reasons, contains('⚡ A playful buddy'));
    });

    test('a busy apartment dweller is steered to the cats', () {
      final ranked = PetMatcher.rank(
        [_bruno, _coco, _mochi, _muning],
        _profile({
          'species': 'either',
          'home': 'apartment',
          'activity': 'low',
          'kids': 'no',
          'alone': 'long',
          'experience': 'first',
          'vibe': 'cuddly',
        }),
        now: _now,
      );
      expect(
        ranked.take(2).map((m) => m.petName),
        containsAll(['Mochi', 'Muning']),
      );
      expect(ranked.first.score, greaterThan(ranked.last.score + 20));
    });

    test('a guardian lover gets the protective dog', () {
      final top = PetMatcher.rank(
        [_sky, _coco, _bruno],
        _profile({
          'species': 'dog',
          'home': 'yard',
          'activity': 'medium',
          'kids': 'no',
          'alone': 'some',
          'experience': 'experienced',
          'vibe': 'guardian',
        }),
        now: _now,
      ).first;
      expect(top.reasons, contains('🛡️ A loyal guardian'));
      expect(['Bruno', 'Coco'], contains(top.petName));
    });

    test('only available pets are ranked, scores stay within 5-99', () {
      final adopted = _pet(
        'old',
        'Old',
        'dog',
        'small',
        'calm',
        status: 'adopted',
      );
      final ranked = PetMatcher.rank(
        [_sky, adopted, _mochi],
        _profile({'species': 'either'}),
        now: _now,
      );
      expect(ranked.map((m) => m.petId), isNot(contains('old')));
      for (final m in ranked) {
        expect(m.score, inInclusiveRange(5, 99));
      }
    });

    test('profiles round-trip and report completeness', () {
      final answers = {
        for (final q in matchQuestions) q.id: q.options.first.value,
      };
      final profile = MatchProfile.fromJson(MatchProfile(answers).toJson());
      expect(profile.isComplete, isTrue);
      expect(_profile({'species': 'dog'}).isComplete, isFalse);
    });
  });

  group('PetMatcherService', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('keeps answers per user', () async {
      var uid = 'user-a';
      final service = PetMatcherService.test(() => uid);
      final answers = MatchProfile({
        for (final q in matchQuestions) q.id: q.options.last.value,
      });
      await service.save(answers);
      uid = 'user-b';
      expect(await service.load(), isNull);
      uid = 'user-a';
      expect((await service.load())?['species'], 'either');
    });

    test(
      'shows the quiz before Home until it is finished or skipped',
      () async {
        var uid = 'first-login';
        final service = PetMatcherService.test(() => uid);
        expect(await service.needsOnboarding(), isTrue);
        // Still pending if the app closes mid-quiz.
        expect(await service.needsOnboarding(), isTrue);
        await service.markPrompted();
        expect(await service.needsOnboarding(), isFalse);

        // Each account gets its own first sign-in.
        uid = 'just-registered';
        expect(await service.needsOnboarding(), isTrue);
        await service.save(
          MatchProfile({
            for (final q in matchQuestions) q.id: q.options.first.value,
          }),
        );
        expect(await service.needsOnboarding(), isFalse);

        expect(
          await PetMatcherService.test(() => null).needsOnboarding(),
          isFalse,
        );
      },
    );
  });

  group('PetMatcherService account sync', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    /// A fresh install: nothing on the device, same account in Supabase.
    PetMatcherService newPhone(String uid, _FakeRemote remote) {
      SharedPreferences.setMockInitialValues({});
      return PetMatcherService.test(() => uid, remote);
    }

    test('answers follow the account to another phone', () async {
      final remote = _FakeRemote();
      final phoneA = PetMatcherService.test(() => 'mary', remote);
      expect(await phoneA.needsOnboarding(), isTrue);
      await phoneA.save(_fullProfile((q) => q.options.last.value));
      expect(remote.rows['mary']?['status'], 'completed');

      final phoneB = newPhone('mary', remote);
      expect(await phoneB.needsOnboarding(), isFalse);
      expect(phoneB.profile.value?['species'], 'either');
    });

    test('skipping on one phone is remembered on the next', () async {
      final remote = _FakeRemote();
      final phoneA = PetMatcherService.test(() => 'ana', remote);
      expect(await phoneA.needsOnboarding(), isTrue);
      await phoneA.markPrompted();
      expect(remote.rows['ana'], {'answers': null, 'status': 'skipped'});

      final phoneB = newPhone('ana', remote);
      expect(await phoneB.needsOnboarding(), isFalse);
      expect(phoneB.profile.value, isNull);
    });

    test('a brand-new account sees the quiz on any phone', () async {
      final remote = _FakeRemote();
      expect(await newPhone('new', remote).needsOnboarding(), isTrue);
      expect(remote.writes, 0);
    });

    test('answers saved offline reach the account later', () async {
      final remote = _FakeRemote()..offline = true;
      final phone = PetMatcherService.test(() => 'leo', remote);
      expect(await phone.needsOnboarding(), isTrue);
      await phone.save(_fullProfile((q) => q.options.first.value));
      expect(remote.rows, isEmpty);

      // Next app start, back online.
      remote.offline = false;
      final restarted = PetMatcherService.test(() => 'leo', remote);
      expect(await restarted.needsOnboarding(), isFalse);
      expect(remote.rows['leo']?['status'], 'completed');
      expect(await newPhone('leo', remote).needsOnboarding(), isFalse);
    });

    test('answers from before the table existed are uploaded once', () async {
      final remote = _FakeRemote();
      final local = PetMatcherService.test(() => 'early');
      await local.save(_fullProfile((q) => q.options.first.value));

      final synced = PetMatcherService.test(() => 'early', remote);
      await synced.load();
      expect(remote.rows['early']?['status'], 'completed');
    });

    test('without the table, the phone copy still works', () async {
      final remote = _FakeRemote()..offline = true;
      final phone = PetMatcherService.test(() => 'zoe', remote);
      await phone.markPrompted();
      final again = PetMatcherService.test(() => 'zoe', remote);
      expect(await again.needsOnboarding(), isFalse);
    });
  });

  group('PetMatcherScreen', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<List<Map<String, dynamic>>> Function() pets(
      List<Map<String, dynamic>> rows,
    ) =>
        () async => rows;

    Future<void> answerQuiz(
      WidgetTester tester,
      Map<String, String> picks,
    ) async {
      for (final q in matchQuestions) {
        final option = find.byKey(
          ValueKey('match-option-${q.id}-${picks[q.id]}'),
        );
        expect(option, findsOneWidget, reason: q.id);
        await tester.tap(option);
        await tester.pumpAndSettle();
      }
    }

    Future<void> pumpMatcher(
      WidgetTester tester, {
      required PetMatcherService service,
      required Future<List<Map<String, dynamic>>> Function() loadPets,
      required List<String> saved,
    }) async {
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: PetMatcherScreen(
            service: service,
            loadPets: loadPets,
            onSavePet: (pet) => saved.add(pet['name'].toString()),
            revealDelay: const Duration(milliseconds: 300),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    const familyPicks = {
      'species': 'dog',
      'home': 'house',
      'activity': 'medium',
      'kids': 'yes',
      'alone': 'some',
      'experience': 'first',
      'vibe': 'cuddly',
    };

    testWidgets('quiz leads to a ranked deck; swipe right saves', (
      tester,
    ) async {
      final service = PetMatcherService.test(() => 'tester');
      final saved = <String>[];
      await pumpMatcher(
        tester,
        service: service,
        loadPets: pets([_coco, _sky, _muning]),
        saved: saved,
      );
      expect(
        find.text('Question 1 of ${matchQuestions.length}'),
        findsOneWidget,
      );

      await answerQuiz(tester, familyPicks);
      // The answers are remembered for match badges and next visits.
      expect(service.profile.value?['kids'], 'yes');

      expect(
        find.textContaining('Match with Sky!', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('🏆 Top match'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('matcher-save')));
      await tester.pumpAndSettle();
      expect(saved, ['Sky']);

      // Drag the next card off to the left to skip it.
      await tester.drag(
        find.byKey(const ValueKey('meter-coco')),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();
      expect(saved, ['Sky']);

      await tester.tap(find.byKey(const ValueKey('matcher-skip')));
      await tester.pumpAndSettle();
      expect(find.text('You saved 1 pet!'), findsOneWidget);
      expect(find.text('View Saved Pets'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('yes/no cards can be answered by swiping', (tester) async {
      final service = PetMatcherService.test(() => 'swiper');
      await pumpMatcher(
        tester,
        service: service,
        loadPets: pets([_sky]),
        saved: [],
      );
      for (final id in ['species', 'home', 'activity']) {
        await tester.tap(
          find.byKey(ValueKey('match-option-$id-${familyPicks[id]}')),
        );
        await tester.pumpAndSettle();
      }
      expect(find.text('Are there kids at home?'), findsOneWidget);
      await tester.drag(
        find.text('Are there kids at home?'),
        const Offset(400, 0),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('How long would your pet be alone each day?'),
        findsOneWidget,
      );

      // Back returns to the previous card with the answer kept.
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Are there kids at home?'), findsOneWidget);
    });

    testWidgets('returning users skip straight to their matches', (
      tester,
    ) async {
      final service = PetMatcherService.test(() => 'returning');
      await service.save(MatchProfile(Map.of(familyPicks)));
      await pumpMatcher(
        tester,
        service: service,
        loadPets: pets([_sky, _coco]),
        saved: [],
      );
      expect(
        find.textContaining('Match with Sky!', findRichText: true),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('matcher-retake')));
      await tester.pumpAndSettle();
      expect(
        find.text('Question 1 of ${matchQuestions.length}'),
        findsOneWidget,
      );
    });

    testWidgets('first sign-in: Skip goes to Home and is remembered', (
      tester,
    ) async {
      final service = PetMatcherService.test(() => 'skipper');
      var finished = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: PetMatcherScreen(
            service: service,
            loadPets: pets([_sky]),
            revealDelay: Duration.zero,
            onFinished: () => finished++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('matcher-welcome')), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('matcher-finish')));
      await tester.pumpAndSettle();
      expect(finished, 1);
      expect(await service.needsOnboarding(), isFalse);
    });

    testWidgets('first sign-in: after the deck, Go to Home finishes', (
      tester,
    ) async {
      final service = PetMatcherService.test(() => 'finisher');
      var finished = 0;
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: PetMatcherScreen(
            service: service,
            loadPets: pets([_sky]),
            onSavePet: (_) {},
            revealDelay: Duration.zero,
            onFinished: () => finished++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await answerQuiz(tester, familyPicks);
      expect(find.text('Go to Home'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('matcher-skip')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('matcher-done')));
      await tester.pumpAndSettle();
      expect(finished, 1);
      expect(await service.needsOnboarding(), isFalse);
    });

    testWidgets('a failed pet load offers a retry', (tester) async {
      var fail = true;
      final service = PetMatcherService.test(() => 'offline');
      await service.save(MatchProfile(Map.of(familyPicks)));
      await pumpMatcher(
        tester,
        service: service,
        loadPets: () async {
          if (fail) throw Exception('offline');
          return [_sky];
        },
        saved: [],
      );
      expect(find.text('Could not load the pets'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Match with Sky!', findRichText: true),
        findsOneWidget,
      );
    });
  });
}
