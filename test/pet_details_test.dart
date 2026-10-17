import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/screens/adoption_process_screen.dart';
import 'package:myfuturepet/screens/ar_view_screen.dart';
import 'package:myfuturepet/screens/pet_details_screen.dart';
import 'package:myfuturepet/services/pet_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FixturePetService extends PetService {
  FixturePetService(this.client) : super(client: client);
  final SupabaseClient client;
  Future<Map<String, dynamic>?> Function() load = () async => null;

  @override
  Future<Map<String, dynamic>?> fetchPetById(
    String id, {
    bool throwOnError = false,
  }) => load();
}

class RecordingNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? lastRoute;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastRoute = route;
  }
}

void main() {
  late SupabaseClient client;
  late FixturePetService service;
  late RecordingNavigatorObserver observer;
  final livePet = <String, dynamic>{
    'id': 'pet-1',
    'name': 'Live pet',
    'type': 'cat',
    'breed': 'Puspin',
    'status': 'Available',
    'gender': 'Female',
    'age': '2 yrs',
    'description': 'Rescued from a flooded road.',
    'vaccination_status': 'partially_vaccinated',
    'shelter': 'Live rescue shelter',
    'shelterAddress': 'Live shelter address',
    'shelterPhone': '09123456789',
    'model_url': 'https://example.test/live-cat.glb',
  };

  setUp(() {
    client = SupabaseClient('http://localhost', 'local-test-key');
    service = FixturePetService(client);
    observer = RecordingNavigatorObserver();
    service.load = () async => Map.of(livePet);
  });

  tearDown(() async => client.dispose());

  Future<void> openDetail(
    WidgetTester tester, {
    Future<bool> Function(Uri uri, LaunchMode mode)? linkLauncher,
  }) async {
    tester.view.physicalSize = const Size(430, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: PetDetailsScreen(
          pet: const {
            'id': 'pet-1',
            'name': 'Stale name',
            'status': 'Available',
          },
          petService: service,
          linkLauncher: linkLauncher,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'Refreshes rescue, vaccination, and shelter data from live result',
    (tester) async {
      await openDetail(tester);
      await tester.pumpAndSettle();
      expect(find.text('Live pet'), findsOneWidget);
      expect(find.text('Stale name'), findsNothing);
      expect(find.text('Rescued from a flooded road.'), findsOneWidget);
      expect(find.text('Partially Vaccinated'), findsOneWidget);
      expect(find.textContaining('Live rescue shelter'), findsOneWidget);
      expect(find.textContaining('Live shelter address'), findsWidgets);
      expect(find.textContaining('09123456789'), findsOneWidget);
      expect(find.text('Immunized'), findsNothing);
      expect(find.text('Vet Checked'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Shelter buttons open Messenger and dial the live number', (
    tester,
  ) async {
    service.load = () async => {...livePet, 'shelterPhone': '+63 912-345-6789'};
    final opened = <Uri>[];
    final modes = <LaunchMode>[];
    await openDetail(
      tester,
      linkLauncher: (uri, mode) async {
        opened.add(uri);
        modes.add(mode);
        return true;
      },
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Chat on Messenger'));
    await tester.tap(find.text('Chat on Messenger'));
    await tester.pump();
    await tester.tap(find.text('Call Shelter'));
    await tester.pump();
    expect(opened.map((uri) => uri.toString()), [
      'https://m.me/jagnaanimallover',
      'tel:+639123456789',
    ]);
    expect(modes, [
      LaunchMode.externalApplication,
      LaunchMode.externalApplication,
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Missing shelter number does not try to dial', (tester) async {
    service.load = () async => {...livePet, 'shelterPhone': ''};
    final opened = <Uri>[];
    await openDetail(
      tester,
      linkLauncher: (uri, mode) async {
        opened.add(uri);
        return true;
      },
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Call Shelter'));
    await tester.tap(find.text('Call Shelter'));
    await tester.pump();
    expect(opened, isEmpty);
    expect(find.text('Shelter contact number not provided.'), findsOneWidget);
  });

  testWidgets('Adopt Me opens the form with the refreshed pet', (tester) async {
    await openDetail(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adopt Me'));
    await tester.pumpAndSettle();
    final form = tester.widget<AdoptionProcessScreen>(
      find.byType(AdoptionProcessScreen),
    );
    expect(form.pet['name'], 'Live pet');
    expect(form.pet['id'], 'pet-1');
    expect(tester.takeException(), isNull);
  });

  testWidgets('View in AR forwards the live pet and its model URL', (
    tester,
  ) async {
    await openDetail(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View in AR'));
    // Inspect the destination before mounting device-only camera/WebView plugins.
    final route = observer.lastRoute! as MaterialPageRoute<dynamic>;
    final ar =
        route.builder(tester.element(find.byType(PetDetailsScreen)))
            as ARViewScreen;
    expect(ar.pet!['id'], 'pet-1');
    expect(ar.pet!['model_url'], 'https://example.test/live-cat.glb');
    route.navigator!.removeRoute(route);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Adoption is disabled while loading and after refresh failure', (
    tester,
  ) async {
    final pending = Completer<Map<String, dynamic>?>();
    service.load = () => pending.future;
    await openDetail(tester);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    ElevatedButton button() =>
        tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
    expect(button().onPressed, isNull);
    pending.completeError(Exception('offline'));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(button().onPressed, isNull);
    service.load = () async => Map.of(livePet);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Adopt Me'), findsOneWidget);
    expect(button().onPressed, isNotNull);
  });

  testWidgets('An adopted or deleted pet cannot open adoption', (tester) async {
    service.load = () async => {...livePet, 'status': 'Adopted'};
    await openDetail(tester);
    await tester.pumpAndSettle();
    expect(find.text('Already Adopted'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byType(ElevatedButton).first)
          .onPressed,
      isNull,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    service.load = () async => null;
    await openDetail(tester);
    await tester.pumpAndSettle();
    expect(find.text('This pet is no longer available.'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byType(ElevatedButton).first)
          .onPressed,
      isNull,
    );
  });
}
