import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/adoption_application_store.dart';
import 'package:myfuturepet/screens/adoption_process_screen.dart';
import 'package:myfuturepet/services/adoption_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PendingAdoptionService extends AdoptionService {
  PendingAdoptionService(SupabaseClient client) : super(client: client);
  late Completer<Map<String, dynamic>> result;
  int attempts = 0;
  String? screeningAnswers;

  @override
  Future<Map<String, dynamic>> submitApplication({
    required String petId,
    required String fullName,
    required String contactNumber,
    required String address,
    String? occupation,
    required String housingType,
    bool hasOtherPets = false,
    String? otherPetsDetails,
    String? reasonForAdoption,
  }) {
    attempts++;
    screeningAnswers = reasonForAdoption;
    return result.future;
  }
}

void main() {
  late SupabaseClient client;
  late PendingAdoptionService service;

  setUp(() {
    client = SupabaseClient('http://localhost', 'local-test-public-key');
    service = PendingAdoptionService(client);
    AdoptionApplicationStore.clearApplications();
  });
  tearDown(() async {
    await client.dispose();
    AdoptionApplicationStore.clearApplications();
  });

  Future<void> fillForm(WidgetTester tester) async {
    service.result = Completer<Map<String, dynamic>>();
    tester.view.physicalSize = const Size(430, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: AdoptionProcessScreen(
          pet: const {'id': 'pet-1', 'name': 'Test pet'},
          adoptionService: service,
        ),
      ),
    );
    Future<void> enter(String label, String value) async {
      final field = find.byKey(ValueKey(label));
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
    }

    Future<void> select(String label, String value) async {
      final field = find.byKey(ValueKey(label));
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.pumpAndSettle();
      await tester.tap(find.text(value).last);
      await tester.pumpAndSettle();
    }

    Future<void> next() async {
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();
    }

    await enter('Full Name', 'Test Applicant');
    await enter('Phone Number', '09123456789');
    await enter('Email Address', 'adopter@example.test');
    await enter('Age', '26');
    await enter('Occupation', 'Teacher');
    await next();
    await select('Household Type', 'House');
    await select('Yard Availability', 'Fenced yard');
    await enter('Complete Address', 'Test address');
    await enter('Household Members', '3');
    await enter('Children', '0');
    await next();
    await select('Pet Experience Level', 'Experienced pet owner');
    await enter('Previous Pets', 'One dog');
    await enter('Current Pets', 'None');
    await next();
    await select('Home Environment', 'Quiet');
    await select('Activity Level', 'Moderate');
    await enter('Daily Time Available', '4 hours');
    await next();
    await enter('Why do you want to adopt?', 'Provide a permanent home');
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await next();
    expect(find.text('Submit Application'), findsOneWidget);
  }

  testWidgets(
    'Waits for confirmed submission, disables duplicates, then succeeds',
    (tester) async {
      await fillForm(tester);
      await tester.tap(find.text('Submit Application'));
      await tester.pump();
      expect(find.text('Submitting...'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(AdoptionApplicationStore.applications, isEmpty);
      expect(service.attempts, 1);
      expect(
        service.screeningAnswers,
        contains('Yard availability: Fenced yard'),
      );
      expect(service.screeningAnswers, contains('Experienced pet owner'));
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(button.onPressed, isNull);
      expect(
        tester.widget<PopScope>(find.byType(PopScope).first).canPop,
        isFalse,
      );
      service.result.complete({'id': 'confirmed-application'});
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.textContaining('has been submitted successfully'),
        findsOneWidget,
      );
      expect(
        AdoptionApplicationStore.applications.single['id'],
        'confirmed-application',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('A rejected application stays on the form and shows no success', (
    tester,
  ) async {
    await fillForm(tester);
    await tester.tap(find.text('Submit Application'));
    await tester.pump();
    service.result.completeError(
      const PostgrestException(
        message: 'duplicate key violates uq_active_application',
        code: '23505',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.text('You already have an active application for this pet.'),
      findsOneWidget,
    );
    expect(find.text('Submit Application'), findsOneWidget);
    expect(AdoptionApplicationStore.applications, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
