import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfuturepet/adoption_journey.dart';
import 'package:myfuturepet/screens/feed_screen.dart';
import 'package:myfuturepet/services/adoption_journey_service.dart';
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
  String? submittedCategory;
  String? submittedPetId;
  String? submittedVideo;

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
    String? videoUrl,
  }) {
    publishCalls++;
    submittedVideo = videoUrl;
    submittedContent = content;
    submittedImage = imageUrl;
    submittedCategory = category;
    submittedPetId = petId;
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
        home: FeedScreen(
          communityService: service,
          unreadCount: unread,
          // No video platform in tests: video stories show their poster.
          storyVideoBuilder: (_) => null,
        ),
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
    await tester.ensureVisible(find.text('Publish Tip'));
    await tester.tap(find.text('Publish Tip'));
    await tester.pump();
    expect(service.publishCalls, 1);
    expect(service.submittedContent, 'My new story');
    expect(service.submittedImage, 'https://example.test/pet.jpg');
    expect(find.text('Share a Tip'), findsOneWidget);
    expect(find.text('Post published.'), findsNothing);
    service.fetch = () async => [
      {...row, 'content': 'My new story'},
    ];
    pending.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('Share a Tip'), findsNothing);
    expect(find.text('My new story'), findsOneWidget);
    expect(find.text('Post published.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('Success Stories reel', () {
    final story = <String, dynamic>{
      ...row,
      'id': 'story-1',
      'content': "Max's first day at the beach!",
      'image_url': 'https://example.test/beach.jpg',
      'pet': {
        'id': 'pet-max',
        'name': 'Max',
        'image_url': '',
        'status': 'adopted',
      },
    };
    final tip = <String, dynamic>{
      ...row,
      'id': 'tip-1',
      'category': 'Tips',
      'content': 'Brush your dog weekly',
    };

    tearDown(() => AdoptionJourneyService().journeys.value = []);

    Future<void> openStories(WidgetTester tester) async {
      service.fetch = () async => [Map.of(story), Map.of(tip)];
      await openFeed(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Success Stories'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows alumni stories full-screen, without tips', (
      tester,
    ) async {
      await openStories(tester);
      expect(find.text("Max's first day at the beach!"), findsOneWidget);
      expect(find.text('JALRG Alumni · Max'), findsOneWidget);
      expect(find.text('🐾 Adopted Max from JALRG'), findsOneWidget);
      expect(find.text('Brush your dog weekly'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('double-tap likes once, never unlikes', (tester) async {
      await openStories(tester);
      // Double-tap the photo (the caption itself toggles "more").
      final photo = find.byKey(const ValueKey('story-story-1'));
      Future<void> doubleTap() async {
        await tester.tap(photo);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(photo);
        await tester.pumpAndSettle();
      }

      await doubleTap();
      expect(service.likeCalls, 1);
      await doubleTap();
      expect(service.likeCalls, 1, reason: 'already liked: no unlike');
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('reel-like-story-1')),
          matching: find.byIcon(Icons.favorite_rounded),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('video stories show a video badge and a mute control', (
      tester,
    ) async {
      final videoStory = {
        ...story,
        'id': 'story-video',
        'video_url': 'https://example.test/max.mp4',
      };
      service.fetch = () async => [videoStory];
      await openFeed(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Success Stories'));
      await tester.pumpAndSettle();
      expect(find.text('Video'), findsOneWidget);
      final mute = find.byKey(const ValueKey('reel-mute-story-video'));
      expect(
        find.descendant(of: mute, matching: find.text('Muted')),
        findsOneWidget,
      );
      await tester.tap(mute);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: mute, matching: find.text('Sound')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('video stories also play inside the regular feed cards', (
      tester,
    ) async {
      final videoStory = {
        ...story,
        'id': 'story-video',
        'video_url': 'https://example.test/max.mp4',
      };
      service.fetch = () async => [videoStory, Map.of(row)];
      await openFeed(tester);
      await tester.pumpAndSettle();
      // Default "All" tab: the video card replaces the still image.
      expect(
        find.byKey(const ValueKey('inline-video-story-video')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('inline-video-post-1')), findsNothing);
      expect(find.text('Video'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('photo stories have no video controls', (tester) async {
      await openStories(tester);
      expect(find.byKey(const ValueKey('reel-mute-story-1')), findsNothing);
      expect(find.text('Video'), findsNothing);
    });

    testWidgets('posting is locked for people who have not adopted', (
      tester,
    ) async {
      await openStories(tester);
      await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
      await tester.pumpAndSettle();
      expect(find.text('For JALRG adopters'), findsOneWidget);
      expect(find.text('Share Story'), findsNothing);
    });

    testWidgets('alumni adopters post a story tagged with their pet', (
      tester,
    ) async {
      AdoptionJourneyService().journeys.value = [
        AdoptionJourney.fromRows({
          'id': 'app-1',
          'pet_id': 'pet-max',
          'status': 'approved',
          'pets': {
            'id': 'pet-max',
            'name': 'Max',
            'image_url': 'https://example.test/max.jpg',
            'status': 'adopted',
          },
        }, const []),
      ];
      await openStories(tester);
      await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Which alumni pet is this about?'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Max loves the sea');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Share Story'));
      await tester.tap(find.text('Share Story'));
      await tester.pumpAndSettle();
      expect(service.submittedCategory, 'Success Stories');
      expect(service.submittedPetId, 'pet-max');
      expect(service.submittedContent, 'Max loves the sea');
      // No photo picked: the pet's shelter portrait is used.
      expect(service.submittedImage, 'https://example.test/max.jpg');
      expect(service.submittedVideo, isNull);
      expect(find.text('Your success story is live!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
