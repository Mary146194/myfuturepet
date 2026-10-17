import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/appointment_store.dart';
import 'package:myfuturepet/services/appointment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const userId = '00000000-0000-4000-8000-000000000001';
const shelterId = '327b47f9-e81c-4ff7-a133-8702563601e6';
const petId = '00000000-0000-4000-8000-000000000002';

void main() {
  late HttpServer server;
  late SupabaseClient client;
  late AppointmentService service;
  late List<Map<String, dynamic>> inserts;
  late List<Uri> fetches;
  late List<Map<String, dynamic>> serverRows;
  late bool reject;
  late bool omitId;

  setUp(() async {
    AppointmentStore.clearAppointments();
    inserts = [];
    fetches = [];
    serverRows = [];
    reject = false;
    omitId = false;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response.headers.contentType = ContentType.json;
      if (request.uri.path == '/auth/v1/token') {
        final expiry = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
        String encode(Object value) =>
            base64UrlEncode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
        final jwt =
            '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
            '${encode({'sub': userId, 'exp': expiry, 'role': 'authenticated'})}.fixture';
        request.response.write(
          jsonEncode({
            'access_token': jwt,
            'refresh_token': 'local-test-refresh',
            'token_type': 'bearer',
            'expires_in': 3600,
            'expires_at': expiry,
            'user': {
              'id': userId,
              'aud': 'authenticated',
              'role': 'authenticated',
              'app_metadata': {},
              'user_metadata': {},
              'created_at': '2026-10-17T00:00:00Z',
            },
          }),
        );
      } else if (request.uri.path == '/rest/v1/appointments') {
        if (request.method == 'POST') {
          expect(request.headers.value('content-profile'), 'public');
          final payload =
              jsonDecode(await utf8.decoder.bind(request).join())
                  as Map<String, dynamic>;
          inserts.add(payload);
          if (!reject) {
            final row = <String, dynamic>{
              ...payload,
              if (!omitId) 'id': 'appointment-1',
              'shelters': {
                'id': shelterId,
                'name': 'Jagna Animal Lover and Rescue Group',
              },
              'pets': {'id': petId, 'name': 'Test pet', 'image_url': ''},
            };
            serverRows = [row];
            request.response.statusCode = 201;
            request.response.write(jsonEncode(row));
          }
        } else {
          fetches.add(request.uri);
          if (!reject) request.response.write(jsonEncode(serverRows));
        }
        if (reject) {
          request.response.statusCode = 403;
          request.response.write(
            jsonEncode({'code': '42501', 'message': 'Denied'}),
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
      'local-test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    service = AppointmentService(
      client: client,
      now: () => DateTime.utc(2026, 10, 19),
    );
  });

  tearDown(() async {
    await client.dispose();
    await server.close(force: true);
    AppointmentStore.clearAppointments();
  });

  Future<void> signIn() => client.auth.signInWithPassword(
    email: 'adopter@example.test',
    password: 'local-fixture-only',
  );

  Future<void> book({Map<String, dynamic>? pet}) =>
      AppointmentStore.saveAppointment(
        service: service,
        pet: pet ?? {'id': petId, 'shelter_id': shelterId, 'name': 'Test pet'},
        appointmentType: 'Meet and Greet',
        date: DateTime(2026, 10, 20),
        time: '1:00 PM',
        shelter: 'Jagna Animal Lover and Rescue Group',
      );

  test(
    'Booking persists authenticated IDs, selected slot, supported type, and pending status',
    () async {
      await signIn();
      await book();
      final payload = inserts.single;
      expect(payload['user_id'], userId);
      expect(payload['shelter_id'], shelterId);
      expect(payload['pet_id'], petId);
      expect(payload['appointment_type'], 'meet_and_greet');
      expect(payload['status'], 'pending');
      expect(
        DateTime.parse(payload['scheduled_at'] as String),
        DateTime.utc(2026, 10, 20, 5),
      );
      expect(payload.containsKey('appointment_date'), isFalse);
      final local = AppointmentStore.appointments.single;
      expect(local['id'], 'appointment-1');
      expect(local['status'], 'Pending');
      expect(local['date'], '2026-10-20');
      expect(local['time'], '1:00 PM');
    },
  );

  test(
    'Fetch filters the current user and displays server-updated status in Manila time',
    () async {
      await signIn();
      await book();
      serverRows.single['status'] = 'confirmed';
      await AppointmentStore.syncWithSupabase(
        service: service,
        throwOnError: true,
      );
      expect(fetches.single.queryParameters['user_id'], 'eq.$userId');
      expect(
        fetches.single.queryParameters['order'],
        startsWith('scheduled_at.asc'),
      );
      expect(fetches.single.queryParameters['select'], contains('shelters('));
      expect(AppointmentStore.appointments.single['time'], '1:00 PM');
      expect(AppointmentStore.appointments.single['status'], 'Confirmed');
      expect(AppointmentStore.appointments.single['pet']['name'], 'Test pet');
    },
  );

  test('Successful empty fetch clears stale appointments', () async {
    await signIn();
    AppointmentStore.appointments.add({'id': 'stale'});
    await AppointmentStore.syncWithSupabase(
      service: service,
      throwOnError: true,
    );
    expect(AppointmentStore.appointments, isEmpty);
  });

  test(
    'Failed booking and missing confirmation never record success',
    () async {
      await signIn();
      reject = true;
      await expectLater(book(), throwsA(isA<PostgrestException>()));
      expect(AppointmentStore.appointments, isEmpty);
      reject = false;
      omitId = true;
      await expectLater(book(), throwsStateError);
      expect(AppointmentStore.appointments, isEmpty);
    },
  );

  test(
    'Fetch failure propagates rather than masquerading as an empty list',
    () async {
      await signIn();
      AppointmentStore.appointments.add({'id': 'previous'});
      reject = true;
      await expectLater(
        AppointmentStore.syncWithSupabase(service: service, throwOnError: true),
        throwsA(isA<PostgrestException>()),
      );
      expect(AppointmentStore.appointments.single['id'], 'previous');
    },
  );

  test(
    'Missing shelter and unauthenticated bookings create no request',
    () async {
      await expectLater(book(), throwsException);
      await signIn();
      await expectLater(book(pet: {'id': petId}), throwsArgumentError);
      expect(inserts, isEmpty);
    },
  );

  test(
    'Invalid appointment types, past times, and Sundays are rejected before insert',
    () async {
      await signIn();
      for (final date in [
        DateTime.utc(2026, 10, 18, 1),
        DateTime.utc(2026, 10, 25, 1),
      ]) {
        await expectLater(
          service.bookAppointment(shelterId: shelterId, scheduledAt: date),
          throwsArgumentError,
        );
      }
      await expectLater(
        service.bookAppointment(
          shelterId: shelterId,
          scheduledAt: DateTime.utc(2026, 10, 20, 1),
          appointmentType: 'interview',
        ),
        throwsArgumentError,
      );
      expect(inserts, isEmpty);
    },
  );

  test(
    'Signed-out fetch clears cached appointments without a database request',
    () async {
      AppointmentStore.appointments.add({'id': 'previous-user'});
      await AppointmentStore.syncWithSupabase(
        service: service,
        throwOnError: true,
      );
      expect(AppointmentStore.appointments, isEmpty);
      expect(fetches, isEmpty);
    },
  );
}
