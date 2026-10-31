import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/screens/help_support_screen.dart';
import 'package:myfuturepet/screens/how_to_use_screen.dart';
import 'package:myfuturepet/tutorial_content.dart';
import 'package:myfuturepet/widgets/how_to_use_fab.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TutorialProgress.reset();
  });

  group('tutorial content', () {
    test('covers the requested features, each with steps', () {
      expect(tutorialSections.map((s) => s.title), [
        'Getting Started',
        'Navigating the App',
        'Browsing & Searching',
        'Pet Profiles',
        'AR Pet Visualization',
        'Interactive 3D Preview',
        'Adoption Requests',
        'Notifications',
      ]);
      expect(tutorialSections.map((s) => s.id).toSet().length, 8);
      for (final s in tutorialSections) {
        expect(s.steps, isNotEmpty, reason: s.id);
        expect(s.whereToFind, isNotEmpty, reason: s.id);
      }
    });

    test('leaves out Lost & Found and messaging', () {
      final text = tutorialSections
          .expand(
            (s) => [
              s.title,
              s.subtitle,
              ...s.tips,
              ...s.steps.expand((t) => [t.title, t.body]),
            ],
          )
          .join(' ')
          .toLowerCase();
      for (final word in ['lost', 'found dog', 'sighting', 'messag', 'chat']) {
        expect(text, isNot(contains(word)), reason: word);
      }
    });
  });

  Future<void> phone(WidgetTester tester) async {
    // A small Android phone, to catch overflowing guides.
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('every guide renders on a small phone, light and dark', (
    tester,
  ) async {
    await phone(tester);
    for (final brightness in Brightness.values) {
      for (var i = 0; i < tutorialSections.length; i++) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: TutorialSectionScreen(key: ValueKey(i), index: i),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(tutorialSections[i].title), findsOneWidget);
        // Scroll through all steps so every visual is laid out.
        await tester.drag(find.byType(ListView), const Offset(0, -6000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: tutorialSections[i].id);
      }
    }
  });

  testWidgets('the tour walks through every guide and tracks progress', (
    tester,
  ) async {
    await phone(tester);
    await tester.pumpWidget(const MaterialApp(home: HowToUseScreen()));
    await tester.pumpAndSettle();
    expect(find.text('0 of 8 guides read'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tutorial-start-tour')));
    await tester.pumpAndSettle();
    for (var i = 0; i < tutorialSections.length; i++) {
      expect(find.text('Guide ${i + 1} of 8'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tutorial-next')));
      await tester.pumpAndSettle();
    }
    // Finish returns to the guide list with everything ticked.
    expect(find.byType(HowToUseScreen), findsOneWidget);
    expect(find.textContaining('All 8 guides read'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getStringList(
        'tutorial_read_sections',
      ),
      hasLength(8),
    );
  });

  testWidgets('a single guide can be opened and left with Previous', (
    tester,
  ) async {
    await phone(tester);
    await tester.pumpWidget(const MaterialApp(home: HowToUseScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('tutorial-section-ar')),
      200,
    );
    await tester.tap(find.byKey(const ValueKey('tutorial-section-ar')));
    await tester.pumpAndSettle();
    expect(find.text('AR Pet Visualization'), findsOneWidget);
    expect(find.text('Allow the camera'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tutorial-previous')));
    await tester.pumpAndSettle();
    expect(find.text('Pet Profiles'), findsOneWidget);
    expect(TutorialProgress.read.value, containsAll(['ar', 'pet-profile']));
  });

  testWidgets('Help & Support links to How to Use', (tester) async {
    // Existing Help & Support headers need a typical phone width with the
    // wide test font.
    tester.view.physicalSize = const Size(480, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // The existing FAQ tiles raise a debug-only ink warning; ignore just that.
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains(
        'ink splashes may be invisible',
      )) {
        return;
      }
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);
    await tester.pumpWidget(const MaterialApp(home: HelpSupportScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('help-how-to-use')));
    await tester.pumpAndSettle();
    expect(find.byType(HowToUseScreen), findsOneWidget);
    expect(find.text('Welcome to My Future Pet!'), findsOneWidget);
  });

  group('Home "How to Use" floating button', () {
    setUp(HowToUseFab.resetForTest);

    Widget home({Duration bubble = const Duration(seconds: 2)}) => MaterialApp(
      home: Scaffold(
        body: const SizedBox.expand(),
        floatingActionButton: HowToUseFab(bubbleDuration: bubble),
      ),
    );

    Finder bubble() => find.byKey(const ValueKey('how-to-use-bubble'));

    testWidgets('pops up the hint, then hides it by itself', (tester) async {
      await tester.pumpWidget(home());
      expect(bubble(), findsNothing);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 300));
      expect(bubble(), findsOneWidget);
      expect(find.text(HowToUseFab.hint), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(bubble(), findsNothing);
      // The button stays.
      expect(find.byKey(const ValueKey('how-to-use-fab')), findsOneWidget);
    });

    testWidgets('the hint can be closed', (tester) async {
      await tester.pumpWidget(home(bubble: const Duration(seconds: 30)));
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.tap(find.byKey(const ValueKey('how-to-use-bubble-close')));
      await tester.pumpAndSettle();
      expect(bubble(), findsNothing);
    });

    testWidgets('tapping the button opens How to Use', (tester) async {
      await tester.pumpWidget(home(bubble: const Duration(seconds: 30)));
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.tap(find.byKey(const ValueKey('how-to-use-fab')));
      await tester.pumpAndSettle();
      expect(find.byType(HowToUseScreen), findsOneWidget);
    });

    testWidgets('pops up only once per app launch', (tester) async {
      await tester.pumpWidget(home());
      await tester.pump(const Duration(milliseconds: 1100));
      expect(bubble(), findsOneWidget);
      // Leaving Home and coming back (the button is rebuilt).
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(home());
      await tester.pump(const Duration(milliseconds: 1100));
      expect(bubble(), findsNothing);
      expect(find.byKey(const ValueKey('how-to-use-fab')), findsOneWidget);
    });
  });
}
