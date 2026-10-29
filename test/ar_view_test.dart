import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/ar_model_url.dart';
import 'package:myfuturepet/screens/ar_view_screen.dart';
import 'package:myfuturepet/services/ar_support_service.dart';
import 'package:myfuturepet/services/pet_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FixturePetService extends PetService {
  FixturePetService(SupabaseClient client) : super(client: client);

  List<Map<String, dynamic>> pets = const [];
  bool fail = false;
  String? requestedStatus;

  @override
  Future<List<Map<String, dynamic>>> fetchPets({
    String? category,
    String? searchQuery,
    String? breed,
    String? gender,
    String? status,
    bool throwOnError = false,
  }) async {
    requestedStatus = status;
    if (fail) throw Exception('fixture failure');
    return pets;
  }
}

void main() {
  test('resolves assigned Supabase GLB URL and bucket path only', () {
    expect(
      resolvePetModelUrl('https://example.test/pet.glb'),
      'https://example.test/pet.glb',
    );
    expect(
      resolvePetModelUrl('pet-models/rescue pet.glb'),
      contains('/storage/v1/object/public/pet-models/rescue%20pet.glb'),
    );
    expect(resolvePetModelUrl(null), isNull);
    expect(resolvePetModelUrl(''), isNull);
    expect(resolvePetModelUrl('https://example.test/pet.jpg'), isNull);
    expect(resolvePetModelUrl('http://example.test/pet.glb'), isNull);
  });

  late SupabaseClient client;
  late FixturePetService service;

  setUp(() {
    client = SupabaseClient('http://localhost', 'local-test-key');
    service = FixturePetService(client);
  });
  tearDown(() async {
    await client.dispose();
  });

  Future<void> pumpAR(
    WidgetTester tester, {
    Map<String, dynamic>? pet,
    ARSessionLauncher? arSessionLauncher,
    ArSupport support = ArSupport.unknown,
  }) async {
    tester.view.physicalSize = const Size(430, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: ARViewScreen(
          pet: pet,
          petService: service,
          cameraSupported: false,
          arSessionLauncher: arSessionLauncher,
          arSupportChecker: () async => support,
          modelBuilder: (_, url, studio) => Text(
            '${studio ? 'Studio' : 'Camera'}: $url',
            key: const ValueKey('model-url'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('detail route renders its exact model in desktop orbit mode', (
    tester,
  ) async {
    await pumpAR(
      tester,
      pet: {
        'id': 'one',
        'name': 'Muning',
        'type': 'cat',
        'model_url': 'https://example.test/muning.glb',
      },
    );
    expect(
      find.text('Studio: https://example.test/muning.glb'),
      findsOneWidget,
    );
    expect(find.text('Camera AR'), findsOneWidget);
    expect(find.text('3D Studio'), findsOneWidget);
    expect(find.text('Reset Turntable'), findsNothing);
    expect(find.byTooltip('Reset AR Position'), findsOneWidget);
    expect(find.text('Distance:'), findsOneWidget);
    expect(find.byTooltip('Enlarge Pet'), findsOneWidget);
    expect(find.byTooltip('Shrink Pet'), findsOneWidget);
    expect(find.byTooltip('Snapshot options'), findsOneWidget);
    expect(find.byTooltip('How to Use AR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('studio controls adjust scale and reset the turntable', (
    tester,
  ) async {
    await pumpAR(
      tester,
      pet: {
        'id': 'one',
        'name': 'Muning',
        'type': 'cat',
        'model_url': 'https://example.test/muning.glb',
      },
    );
    expect(find.textContaining('Viewing scale: 56%'), findsOneWidget);
    await tester.tap(find.byTooltip('Enlarge Pet'));
    await tester.pump();
    expect(find.textContaining('Viewing scale: 71%'), findsOneWidget);
    await tester.tap(find.byTooltip('Reset AR Position'));
    await tester.pump();
    expect(find.textContaining('Viewing scale: 56%'), findsOneWidget);
    await tester.tap(find.byTooltip('Snapshot options'));
    await tester.pumpAndSettle();
    expect(find.text('Capture this view'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Camera AR tab falls back to virtual room without a camera', (
    tester,
  ) async {
    await pumpAR(
      tester,
      pet: {
        'id': 'one',
        'name': 'Muning',
        'type': 'cat',
        'model_url': 'https://example.test/muning.glb',
      },
    );
    await tester.tap(find.text('Camera AR'));
    await tester.pump();
    expect(
      find.text('Camera: https://example.test/muning.glb'),
      findsOneWidget,
    );
    expect(find.textContaining('Virtual floor room'), findsOneWidget);
    expect(find.textContaining('Floor Surface Detected'), findsNothing);
    expect(find.text('3D Studio'), findsOneWidget);
    // Life size comes from distance in camera mode, so resizing is not offered.
    expect(find.byTooltip('Enlarge Pet'), findsNothing);
    expect(find.byTooltip('Shrink Pet'), findsNothing);
    expect(find.byTooltip('Floor Anchor: ON'), findsNothing);
    expect(find.text('Distance:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview labels itself approximate unless ARCore is supported', (
    tester,
  ) async {
    const pet = {
      'id': 'one',
      'name': 'Muning',
      'type': 'cat',
      'model_url': 'https://example.test/muning.glb',
    };
    await pumpAR(tester, pet: pet, support: ArSupport.unsupported);
    await tester.tap(find.text('Camera AR'));
    await tester.pump();
    expect(find.textContaining('approximate preview'), findsOneWidget);
    expect(find.textContaining('Floor Surface Detected'), findsNothing);

    await tester.pumpWidget(const SizedBox()); // drop the previous screen state
    await pumpAR(tester, pet: pet, support: ArSupport.supported);
    await tester.tap(find.text('Camera AR'));
    await tester.pump();
    expect(find.textContaining('approximate preview'), findsNothing);
    expect(find.text('30 cm tall • 25 cm at shoulder'), findsOneWidget);
  });

  testWidgets('Camera shutter requests native floor placement', (tester) async {
    var launches = 0;
    await pumpAR(
      tester,
      pet: {
        'id': 'one',
        'name': 'Muning',
        'model_url': 'https://example.test/muning.glb',
      },
      arSessionLauncher: () async {
        launches++;
        return true;
      },
    );
    await tester.tap(find.text('Camera AR'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('camera-ar-shutter')));
    await tester.pump();
    expect(launches, 1);
    expect(find.textContaining('Floor AR is unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed native launch keeps the virtual floor available', (
    tester,
  ) async {
    await pumpAR(
      tester,
      pet: {
        'id': 'one',
        'name': 'Muning',
        'model_url': 'https://example.test/muning.glb',
      },
      arSessionLauncher: () async => false,
    );
    await tester.tap(find.text('Camera AR'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('camera-ar-shutter')));
    await tester.pump();
    expect(find.textContaining('Floor AR is unavailable'), findsOneWidget);
    expect(find.textContaining('Virtual floor room'), findsOneWidget);
    expect(find.byKey(const ValueKey('camera-ar-shutter')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom tab selects a live available pet and forwards its URL', (
    tester,
  ) async {
    service.pets = [
      {'id': 'one', 'name': 'Bantay', 'type': 'dog', 'model_url': 'bantay.glb'},
    ];
    await pumpAR(tester);
    expect(service.requestedStatus, 'available');
    await tester.tap(find.byKey(const ValueKey('ar-pet-one')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Studio: ', findRichText: true), findsOneWidget);
    expect(find.textContaining('/pet-models/bantay.glb'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing model is explicit and never loads a generic animal', (
    tester,
  ) async {
    await pumpAR(tester, pet: {'id': 'one', 'name': 'Bantay'});
    expect(
      find.text('No 3D model is available for this pet yet.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('model-url')), findsNothing);
  });

  testWidgets('pet list failure has a working retry', (tester) async {
    service.fail = true;
    await pumpAR(tester);
    expect(find.text('Could not load pets. Please try again.'), findsOneWidget);
    service.fail = false;
    service.pets = [
      {'id': 'two', 'name': 'Sky', 'model_url': null},
    ];
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Sky'), findsOneWidget);
    expect(find.text('3D model unavailable'), findsOneWidget);
  });
}
