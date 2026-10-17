import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/screens/feed_screen.dart';
import 'package:myfuturepet/services/community_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FixtureCommunityService extends CommunityService {
  FixtureCommunityService(SupabaseClient client) : super(client: client);
  late Future<List<Map<String, dynamic>>> Function() fetch;
  late Future<bool> Function() like;
  late Future<bool> Function() publish;
  int likeCalls = 0;
  int publishCalls = 0;
  int serverCount = 7;
  String? submittedContent;
  String? submittedImage;

  @override
  Future<List<Map<String, dynamic>>> fetchPosts({
    String? category,
    bool throwOnError = false,
  }) => fetch();
  @override
  Future<bool> toggleLike(
    String postId,
    bool isCurrentlyLiked,
    int currentLikes,
  ) {
    likeCalls++;
    return like();
  }

  @override
  Future<int> fetchLikeCount(String postId) async => serverCount;
  @override
  Future<bool> createPost({
    required String content,
    String? imageUrl,
    String? category,
    String? petId,
  }) {
    publishCalls++;
    submittedContent = content;
    submittedImage = imageUrl;
    return publish();
  }
}

void main() {
  late SupabaseClient client;
  late FixtureCommunityService service;
  late ValueNotifier<int> unread;
  final row = <String, dynamic>{
    'id': 'post-1',
    'content': 'A rescue story',
    'like_count': 4,
    'comment_count': 2,
    'is_liked_by_me': false,
    'category': 'Success Stories',
    'created_at': '2026-10-17T10:00:00Z',
    'author': {
      'id': 'public-author',
      'full_name': 'Alice',
      'avatar_url': 'https://example.test/avatar.png',
    },
  };

  setUp(() {
    client = SupabaseClient('http://localhost', 'local-test-key');
    service = FixtureCommunityService(client);
    service.fetch = () async => [Map.of(row)];
    service.like = () async => true;
    service.publish = () async => true;
    unread = ValueNotifier(0);
  });
  tearDown(() async {
    unread.dispose();
    await client.dispose();
  });

  Future<void> openFeed(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: FeedScreen(communityService: service, unreadCount: unread),
      ),
    );
    await tester.pump();
  }

  Finder likeButton() => find.byKey(const ValueKey('like-post-1'));
  Finder likeCount(String value) =>
      find.descendant(of: likeButton(), matching: find.text(value));

  testWidgets('Loading resolves to public author and avatar fallback', (
    tester,
  ) async {
    final pending = Completer<List<Map<String, dynamic>>>();
    service.fetch = () => pending.future;
    await openFeed(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete([Map.of(row)]);
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('A rescue story'), findsOneWidget);
    expect(
      find.text('A'),
      findsOneWidget,
    ); // Failed avatar image falls back safely.
    expect(likeCount('4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Rapid taps send one like request and reconcile the server count',
    (tester) async {
      await openFeed(tester);
      await tester.pumpAndSettle();
      final pending = Completer<bool>();
      service.like = () => pending.future;
      await tester.tap(likeButton());
      await tester.pump();
      await tester.tap(likeButton());
      expect(service.likeCalls, 1);
      expect(likeCount('5'), findsOneWidget);
      expect(tester.widget<GestureDetector>(likeButton()).onTap, isNull);
      pending.complete(true);
      await tester.pumpAndSettle();
      expect(likeCount('7'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(tester.widget<GestureDetector>(likeButton()).onTap, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Rejected like restores the original state with a friendly error',
    (tester) async {
      await openFeed(tester);
      await tester.pumpAndSettle();
      service.like = () async => throw Exception('offline');
      await tester.tap(likeButton());
      await tester.pumpAndSettle();
      expect(likeCount('4'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(
        find.textContaining('Unable to update your like.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Fetch error offers retry; a successful empty result is not an error',
    (tester) async {
      service.fetch = () async => throw Exception('offline');
      await openFeed(tester);
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      service.fetch = () async => [];
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No community posts yet'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Composer waits for persistence, then reloads the new story', (
    tester,
  ) async {
    await openFeed(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_rounded));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'My new story');
    await tester.enterText(
      find.byType(TextField).last,
      'https://example.test/pet.jpg',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    final pending = Completer<bool>();
    service.publish = () => pending.future;
    await tester.ensureVisible(find.text('Publish Post'));
    await tester.tap(find.text('Publish Post'));
    await tester.pump();
    expect(service.publishCalls, 1);
    expect(service.submittedContent, 'My new story');
    expect(service.submittedImage, 'https://example.test/pet.jpg');
    expect(find.text('Create Community Post'), findsOneWidget);
    expect(find.text('Post published to Community Feed!'), findsNothing);
    service.fetch = () async => [
      {...row, 'content': 'My new story'},
    ];
    pending.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('Create Community Post'), findsNothing);
    expect(find.text('My new story'), findsOneWidget);
    expect(find.text('Post published to Community Feed!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
