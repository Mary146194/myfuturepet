import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/services/community_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const userId = '00000000-0000-4000-8000-000000000001';

void main() {
  late HttpServer server;
  late SupabaseClient client;
  late CommunityService service;
  late List<Map<String, dynamic>> requests;
  late List<Map<String, dynamic>> created;
  late Set<String> likes;
  late bool avatarsAvailable;
  late bool reject;
  late bool omitConfirmation;
  late int count;

  setUp(() async {
    requests = [];
    created = [];
    likes = {};
    avatarsAvailable = true;
    reject = false;
    omitConfirmation = false;
    count = 4;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response.headers.contentType = ContentType.json;
      final record = <String, dynamic>{
        'path': request.uri.path,
        'method': request.method,
        'query': request.uri.queryParameters,
        'prefer': request.headers.value('prefer'),
      };
      requests.add(record);
      if (request.uri.path == '/auth/v1/token') {
        final expiry = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
        String encode(Object value) =>
            base64UrlEncode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
        request.response.write(
          jsonEncode({
            'access_token':
                '${encode({'alg': 'HS256'})}.'
                '${encode({'sub': userId, 'exp': expiry})}.fixture',
            'refresh_token': 'local-fixture',
            'token_type': 'bearer',
            'expires_at': expiry,
            'expires_in': 3600,
            'user': {
              'id': userId,
              'aud': 'authenticated',
              'app_metadata': {},
              'user_metadata': {},
              'created_at': '2026-10-17T00:00:00Z',
            },
          }),
        );
      } else if (reject) {
        request.response.statusCode = 403;
        request.response.write(
          jsonEncode({'code': '42501', 'message': 'Denied'}),
        );
      } else if (request.uri.path == '/rest/v1/community_posts') {
        if (request.method == 'POST') {
          expect(request.headers.value('content-profile'), 'public');
          final data =
              jsonDecode(await utf8.decoder.bind(request).join())
                  as Map<String, dynamic>;
          created.add(data);
          request.response.statusCode = 201;
          request.response.write(
            jsonEncode({if (!omitConfirmation) 'id': 'new-post'}),
          );
        } else if (request.method == 'PATCH') {
          fail('The client must never overwrite community_posts.like_count');
        } else if (request.uri.queryParameters['select'] == 'like_count') {
          request.response.write(jsonEncode({'like_count': count}));
        } else if (!avatarsAvailable &&
            request.uri.queryParameters['select']!.contains('avatar_url')) {
          request.response.statusCode = 400;
          request.response.write(
            jsonEncode({
              'code': '42703',
              'message': 'column profiles_1.avatar_url does not exist',
            }),
          );
        } else {
          request.response.write(
            jsonEncode([
              {
                'id': 'post-1',
                'content': 'A rescue story',
                'like_count': count,
                'category': 'Success Stories',
                'is_pinned': false,
                'created_at': '2026-10-17T10:00:00Z',
                'author': {
                  'id': userId,
                  'full_name': 'Public author',
                  if (avatarsAvailable)
                    'avatar_url': 'https://example.test/avatar.png',
                },
                'post_comments': [
                  {'count': 2},
                ],
              },
            ]),
          );
        }
      } else if (request.uri.path == '/rest/v1/post_likes') {
        expect(
          request.uri.queryParameters['user_id'] ?? 'eq.$userId',
          'eq.$userId',
        );
        if (request.method == 'POST') {
          final data =
              jsonDecode(await utf8.decoder.bind(request).join())
                  as Map<String, dynamic>;
          expect(data['user_id'], userId);
          record['body'] = data;
          if (likes.add(data['post_id'].toString())) count++;
          request.response.statusCode = 201;
        } else if (request.method == 'DELETE') {
          final id = request.uri.queryParameters['post_id']!.substring(3);
          if (likes.remove(id)) count--;
          request.response.statusCode = 204;
        } else {
          request.response.write(
            jsonEncode(likes.map((id) => {'post_id': id}).toList()),
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
    service = CommunityService(client: client);
  });
  tearDown(() async {
    await client.dispose();
    await server.close(force: true);
  });

  Future<void> signIn() async {
    await client.auth.signInWithPassword(
      email: 'adopter@example.test',
      password: 'fixture-only',
    );
  }

  List<Map<String, dynamic>> postGets() => requests
      .where(
        (r) => r['path'] == '/rest/v1/community_posts' && r['method'] == 'GET',
      )
      .toList();

  test(
    'Fetch is newest first with public author name/avatar and no private profile fields',
    () async {
      final posts = await service.fetchPosts(throwOnError: true);
      final query = postGets().single['query'] as Map;
      expect(query['order'], startsWith('created_at.desc'));
      expect(query['order'], isNot(contains('is_pinned')));
      expect(
        query['select'],
        contains('author:author_id(id,full_name,avatar_url)'),
      );
      for (final privateField in [
        'email',
        'phone',
        'address',
        'adoption_applications',
      ]) {
        expect(query['select'], isNot(contains(privateField)));
      }
      expect(posts.single['author']['full_name'], 'Public author');
      expect(
        posts.single['author']['avatar_url'],
        'https://example.test/avatar.png',
      );
      expect(posts.single['comment_count'], 2);
      expect(posts.single['is_liked_by_me'], isFalse);
    },
  );

  test('Missing live avatar column falls back once to public names', () async {
    avatarsAvailable = false;
    final posts = await service.fetchPosts(throwOnError: true);
    expect(posts.single['author']['full_name'], 'Public author');
    expect(posts.single['author']['avatar_url'], isNull);
    expect(postGets(), hasLength(2));
    await service.fetchPosts(throwOnError: true);
    expect(postGets(), hasLength(3));
    expect(postGets().last['query']['select'], isNot(contains('avatar_url')));
  });

  test(
    'Signed-in feed reads only this adopter likes and applies category filter',
    () async {
      await signIn();
      likes.add('post-1');
      final posts = await service.fetchPosts(
        category: 'Tips',
        throwOnError: true,
      );
      expect(postGets().single['query']['category'], 'eq.Tips');
      expect(posts.single['is_liked_by_me'], isTrue);
      final query = requests.singleWhere(
        (r) => r['path'] == '/rest/v1/post_likes',
      )['query'];
      expect(query['select'], 'post_id');
      expect(query['user_id'], 'eq.$userId');
    },
  );

  test(
    'Like is idempotent, unlike scopes both IDs, and counts remain server-owned',
    () async {
      await signIn();
      expect(await service.toggleLike('post-1', false, 4), isTrue);
      expect(await service.toggleLike('post-1', false, 4), isTrue);
      expect(await service.fetchLikeCount('post-1'), 5);
      final insert = requests.firstWhere(
        (r) => r['path'] == '/rest/v1/post_likes' && r['method'] == 'POST',
      );
      expect(insert['query']['on_conflict'], 'post_id,user_id');
      expect(insert['prefer'], contains('resolution=ignore-duplicates'));
      expect(await service.toggleLike('post-1', true, 5), isFalse);
      final deletion = requests.singleWhere((r) => r['method'] == 'DELETE');
      expect(deletion['query']['post_id'], 'eq.post-1');
      expect(deletion['query']['user_id'], 'eq.$userId');
      expect(await service.fetchLikeCount('post-1'), 4);
      expect(requests.where((r) => r['method'] == 'PATCH'), isEmpty);
    },
  );

  test('Signed-out users cannot create posts or toggle likes', () async {
    await expectLater(service.toggleLike('post-1', false, 0), throwsStateError);
    await expectLater(service.createPost(content: 'Story'), throwsException);
    expect(requests, isEmpty);
  });

  test(
    'Creating a post sends the authenticated author and waits for a server ID',
    () async {
      await signIn();
      expect(
        await service.createPost(
          content: ' A real story ',
          category: 'Success Stories',
          imageUrl: ' https://example.test/pet.jpg ',
          petId: 'pet-1',
        ),
        isTrue,
      );
      expect(created.single, {
        'author_id': userId,
        'content': 'A real story',
        'category': 'Success Stories',
        'image_url': 'https://example.test/pet.jpg',
        'pet_id': 'pet-1',
      });
      omitConfirmation = true;
      await expectLater(
        service.createPost(content: 'No confirmation'),
        throwsStateError,
      );
    },
  );

  test(
    'Invalid content/category/image URL is rejected without insert',
    () async {
      await signIn();
      await expectLater(service.createPost(content: '  '), throwsException);
      await expectLater(
        service.createPost(content: 'x' * 3001),
        throwsException,
      );
      await expectLater(
        service.createPost(content: 'Story', imageUrl: 'javascript:alert(1)'),
        throwsArgumentError,
      );
      await expectLater(
        service.createPost(content: 'Story', category: 'Unknown'),
        throwsArgumentError,
      );
      expect(created, isEmpty);
    },
  );

  test('Fetch/write failures propagate for the UI error boundaries', () async {
    await signIn();
    reject = true;
    await expectLater(
      service.fetchPosts(throwOnError: true),
      throwsA(isA<PostgrestException>()),
    );
    await expectLater(
      service.toggleLike('post-1', false, 0),
      throwsA(isA<PostgrestException>()),
    );
    await expectLater(
      service.createPost(content: 'Story'),
      throwsA(isA<PostgrestException>()),
    );
  });
}
