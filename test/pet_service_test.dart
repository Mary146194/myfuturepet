import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/services/pet_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late HttpServer server;
  late SupabaseClient client;
  late PetService service;
  late List<Map<String, dynamic>> rows;
  late List<Uri> requests;
  late bool failRequest;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    rows = [];
    requests = [];
    failRequest = false;
    server.listen((request) async {
      requests.add(request.uri);
      request.response.headers.contentType = ContentType.json;
      if (failRequest) {
        request.response.statusCode = 403;
        request.response.write(
          jsonEncode({'message': 'Permission denied', 'code': '42501'}),
        );
      } else {
        request.response.write(jsonEncode(rows));
      }
      await request.response.close();
    });
    client = SupabaseClient('http://127.0.0.1:${server.port}', 'test-key');
    service = PetService(client: client);
  });

  tearDown(() async {
    await client.dispose();
    await server.close(force: true);
  });

  test(
    'Home query requests available pets newest first and keeps gallery photos',
    () async {
      rows = [
        {
          'id': 'pet-1',
          'name': 'Muning',
          'type': 'cat',
          'age': '2 years',
          'status': 'available',
          'photo_urls': [
            '',
            ' https://example.com/cat.jpg ',
            'https://example.com/2.jpg',
          ],
          'image_url': 'https://example.com/legacy.jpg',
          'shelters': {'name': 'Rescue shelter'},
        },
      ];
      final pets = await service.fetchPets(
        status: 'available',
        throwOnError: true,
      );
      expect(requests.single.queryParameters['status'], 'eq.available');
      expect(
        requests.single.queryParameters['order'],
        'created_at.desc.nullslast',
      );
      expect(pets.single['image'], 'https://example.com/cat.jpg');
      expect(pets.single['images'], hasLength(2));
      expect(pets.single['age'], '2 years');
      expect(pets.single['shelter'], 'Rescue shelter');
    },
  );

  test(
    'Legacy photo is supported and missing photos do not invent a pet image',
    () async {
      rows = [
        {'id': 'legacy', 'image_url': 'https://example.com/dog.jpg'},
        {'id': 'no-photo'},
      ];
      final pets = await service.fetchPets(status: 'available');
      expect(pets.first['image'], 'https://example.com/dog.jpg');
      expect(pets.last['image'], isEmpty);
    },
  );

  test('Successful empty response remains an empty feed', () async {
    expect(
      await service.fetchPets(status: 'available', throwOnError: true),
      isEmpty,
    );
  });

  test('Home can distinguish query errors from empty results', () async {
    failRequest = true;
    await expectLater(
      service.fetchPets(status: 'available', throwOnError: true),
      throwsA(isA<PostgrestException>()),
    );
    // Preserve the existing behavior for callers outside Home.
    expect(await service.fetchPets(), isEmpty);
  });
  test(
    'Missing medical and shelter records remain explicitly unrecorded',
    () async {
      rows = [
        {'id': 'pet-unknown'},
      ];
      final pet = (await service.fetchPets()).single;
      expect(pet['vaccination_status'], 'Not recorded');
      expect(pet['vaccinated'], isFalse);
      expect(pet['health_condition'], 'Not recorded');
      expect(pet['rabies'], 'Not recorded');
      expect(pet['deworming'], 'Not recorded');
      expect(pet['description'], 'Rescue background not provided.');
      expect(pet['shelterPhone'], isEmpty);
      expect(pet['shelter'], 'Shelter not provided');
    },
  );

  test(
    'Partial vaccination never implies fully vaccinated or rabies immunized',
    () async {
      rows = [
        {'id': 'partial', 'vaccination_status': 'partially_vaccinated'},
      ];
      final pet = (await service.fetchPets()).single;
      expect(pet['vaccination_status'], 'partially_vaccinated');
      expect(pet['vaccinated'], isFalse);
      expect(pet['rabies'], 'Not recorded');
    },
  );

  test('Detail fetch distinguishes deleted pets and server errors', () async {
    expect(await service.fetchPetById('deleted', throwOnError: true), isNull);
    failRequest = true;
    await expectLater(
      service.fetchPetById('pet-1', throwOnError: true),
      throwsA(isA<PostgrestException>()),
    );
  });
}
