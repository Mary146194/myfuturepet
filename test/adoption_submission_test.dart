import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/adoption_application_store.dart';
import 'package:myfuturepet/services/adoption_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const applicantId = '00000000-0000-4000-8000-000000000001';
const petId = '00000000-0000-4000-8000-000000000002';

void main() {
  late HttpServer server;
  late SupabaseClient client;
  late AdoptionService service;
  late List<Map<String, dynamic>> submissions;
  late bool rejectSubmission;
  late bool omitConfirmation;

  setUp(() async {
    AdoptionApplicationStore.clearApplications();
    submissions = [];
    rejectSubmission = false;
    omitConfirmation = false;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response.headers.contentType = ContentType.json;
      if (request.uri.path == '/auth/v1/token') {
        final expiry = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
        String encode(Object value) =>
            base64UrlEncode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
        final token =
            '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
            '${encode({'sub': applicantId, 'exp': expiry, 'role': 'authenticated'})}.'
            'test-signature';
        request.response.write(
          jsonEncode({
            'access_token': token,
            'refresh_token': 'local-test-refresh-token',
            'token_type': 'bearer',
            'expires_in': 3600,
            'expires_at': expiry,
            'user': {
              'id': applicantId,
              'aud': 'authenticated',
              'role': 'authenticated',
              'email': 'adopter@example.test',
              'app_metadata': {},
              'user_metadata': {},
              'created_at': '2026-10-17T00:00:00Z',
            },
          }),
        );
      } else if (request.uri.path == '/rest/v1/adoption_applications' &&
          request.method == 'POST') {
        expect(request.headers.value('content-profile'), 'public');
        expect(request.headers.value('authorization'), startsWith('Bearer '));
        final payload =
            jsonDecode(await utf8.decoder.bind(request).join())
                as Map<String, dynamic>;
        submissions.add(payload);
        if (rejectSubmission) {
          request.response.statusCode = 409;
          request.response.write(
            jsonEncode({
              'code': '23505',
              'message': 'duplicate key violates uq_active_application',
            }),
          );
        } else {
          request.response.statusCode = 201;
          request.response.write(
            jsonEncode({
              ...payload,
              if (!omitConfirmation) 'id': 'confirmed-application',
            }),
          );
        }
      } else {
        request.response.statusCode = 404;
        request.response.write('{}');
      }
      await request.response.close();
    });
    client = SupabaseClient(
      'http://127.0.0.1:${server.port}',
      'local-test-public-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    service = AdoptionService(client: client);
  });

  tearDown(() async {
    await client.dispose();
    await server.close(force: true);
    AdoptionApplicationStore.clearApplications();
  });

  Future<void> signIn() async {
    await client.auth.signInWithPassword(
      email: 'adopter@example.test',
      password: 'local-fixture-only',
    );
  }

  Future<void> submit({String currentPets = 'One cat'}) =>
      AdoptionApplicationStore.saveApplication(
        service: service,
        pet: {'id': petId, 'name': 'Test pet'},
        fullName: ' Test Applicant ',
        phone: ' 09123456789 ',
        email: 'adopter@example.test',
        age: '26',
        occupation: ' Teacher ',
        householdType: 'Condominium',
        address: ' Test address ',
        householdMembers: '3',
        children: '0',
        experienceLevel: 'Experienced',
        previousPets: 'Two dogs',
        currentPets: currentPets,
        homeEnvironment: 'Quiet',
        yardAvailability: 'Fenced yard',
        activityLevel: 'Moderate',
        timeAvailable: '4 hours daily',
        adoptionReason: 'Provide a permanent home',
      );

  test(
    'Signed-in form responses reach the public Admin queue payload',
    () async {
      await signIn();
      await submit();
      final payload = submissions.single;
      expect(payload['pet_id'], petId);
      expect(payload['applicant_id'], applicantId);
      expect(payload['status'], 'pending');
      expect(payload['full_name'], 'Test Applicant');
      expect(payload['contact_number'], '09123456789');
      expect(payload['address'], 'Test address');
      expect(payload['occupation'], 'Teacher');
      expect(payload['housing_type'], 'apartment');
      expect(payload['has_other_pets'], isTrue);
      expect(payload['other_pets_details'], 'One cat');
      final reason = payload['reason_for_adoption'] as String;
      for (final answer in [
        'Provide a permanent home',
        '26',
        '3',
        'children: 0',
        'Experienced',
        'Two dogs',
        'Quiet',
        'Fenced yard',
        'Moderate',
        '4 hours daily',
        'adopter@example.test',
      ]) {
        expect(reason, contains(answer));
      }
      expect(payload.containsKey('questionnaire_answers'), isFalse);
      expect(
        AdoptionApplicationStore.applications.single['id'],
        'confirmed-application',
      );
    },
  );

  test('No current pets is sent as false and null detail', () async {
    await signIn();
    await submit(currentPets: 'None');
    expect(submissions.single['has_other_pets'], isFalse);
    expect(submissions.single['other_pets_details'], isNull);
  });

  test(
    'Unauthenticated submission fails without creating a local success',
    () async {
      await expectLater(submit(), throwsException);
      expect(submissions, isEmpty);
      expect(AdoptionApplicationStore.applications, isEmpty);
    },
  );

  test(
    'Server rejection propagates and never creates a local success',
    () async {
      await signIn();
      rejectSubmission = true;
      await expectLater(submit(), throwsA(isA<PostgrestException>()));
      expect(AdoptionApplicationStore.applications, isEmpty);
    },
  );

  test('Missing server confirmation never creates a local success', () async {
    await signIn();
    omitConfirmation = true;
    await expectLater(submit(), throwsStateError);
    expect(AdoptionApplicationStore.applications, isEmpty);
  });
}
