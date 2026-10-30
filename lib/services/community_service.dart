import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityService {
  final SupabaseClient _client;
  bool? _hasAuthorAvatars;

  CommunityService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<Map<String, dynamic>?> fetchMyPublicProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      return await _client
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', user.id)
          .maybeSingle();
    } on PostgrestException catch (error) {
      if (error.code != '42703' || !error.message.contains('avatar_url')) {
        rethrow;
      }
      return await _client
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();
    }
  }

  Future<List<Map<String, dynamic>>> _queryPosts(String? category) async {
    final authorFields = _hasAuthorAvatars == false
        ? 'id, full_name'
        : 'id, full_name, avatar_url';
    var query = _client
        .from('community_posts')
        .select(
          '*, author:author_id($authorFields), shelter:shelter_id(id, name, logo_url), '
          'pet:pet_id(id, name, type, breed, image_url), post_comments(count)',
        );
    if (category != null && category != 'All' && category.isNotEmpty) {
      query = query.eq('category', category);
    }
    // Newest first, regardless of whether an older post is pinned.
    final rows = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  static final Map<String, int> _localCommentCounts = {};
  static bool _loadedFromPrefs = false;

  // Older builds kept failed comments on the device and showed them as
  // posted. They never reached the database, so drop them once.
  static Future<void> _loadLocalComments() async {
    if (_loadedFromPrefs) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('community_local_comments');
      _loadedFromPrefs = true;
    } catch (e) {
      debugPrint('Error clearing old local comments: $e');
    }
  }

  /// Fetch community posts joined with shelter, pet, and author info
  Future<List<Map<String, dynamic>>> fetchPosts({
    String? category,
    bool throwOnError = false,
  }) async {
    try {
      List<Map<String, dynamic>> rows;
      try {
        rows = await _queryPosts(category);
        _hasAuthorAvatars ??= true;
      } on PostgrestException catch (error) {
        // The live profile schema predates avatar_url. Preserve the feed until
        // the optional additive migration is applied; use initials meanwhile.
        if (error.code != '42703' || !error.message.contains('avatar_url')) {
          rethrow;
        }
        _hasAuthorAvatars = false;
        rows = await _queryPosts(category);
      }
      final likedIds = <String>{};
      final user = currentUser;
      if (user != null) {
        final likes = await _client
            .from('post_likes')
            .select('post_id')
            .eq('user_id', user.id);
        likedIds.addAll(likes.map((row) => row['post_id'].toString()));
      }
      return rows.map((row) {
        final post = Map<String, dynamic>.from(row);
        final id = post['id']?.toString() ?? '';
        post['is_liked_by_me'] = likedIds.contains(id);
        final comments = post['post_comments'] as List<dynamic>?;
        final remoteCount = comments != null && comments.isNotEmpty
            ? (comments.first['count'] as num?)?.toInt() ?? 0
            : (post['comment_count'] as num?)?.toInt() ?? 0;
        post['comment_count'] = math.max(
          remoteCount,
          _localCommentCounts[id] ?? 0,
        );
        return post;
      }).toList();
    } catch (error) {
      debugPrint('Error fetching community posts: $error');
      if (throwOnError) rethrow;
      return [];
    }
  }

  /// Toggle the current user's like. The database trigger owns like_count.
  Future<bool> toggleLike(
    String postId,
    bool isCurrentlyLiked,
    int currentLikes,
  ) async {
    final user = currentUser;
    if (user == null) throw StateError('Please log in to like posts.');
    if (postId.trim().isEmpty) throw ArgumentError('Post ID is required.');
    if (isCurrentlyLiked) {
      await _client
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', user.id);
      return false;
    }
    // A repeated request from another tab is harmless and never increments twice.
    await _client
        .from('post_likes')
        .upsert(
          {'post_id': postId, 'user_id': user.id},
          onConflict: 'post_id,user_id',
          ignoreDuplicates: true,
        );
    return true;
  }

  Future<int> fetchLikeCount(String postId) async {
    final row = await _client
        .from('community_posts')
        .select('like_count')
        .eq('id', postId)
        .single();
    return (row['like_count'] as num?)?.toInt() ?? 0;
  }

  /// Fetch real comments for a post
  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    await _loadLocalComments();
    try {
      final response = await _client
          .from('post_comments')
          .select('*, author:user_id(id, full_name)')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      final List<dynamic> list = response as List<dynamic>;
      final remoteComments = list
          .map(
            (item) => Map<String, dynamic>.from(item as Map<String, dynamic>),
          )
          .toList();

      // Comments kept only on this device by older builds never reached the
      // shelter, so they are no longer shown as if they were posted.
      _localCommentCounts[postId] = remoteComments.length;
      return remoteComments;
    } catch (e) {
      debugPrint('Could not load comments: $e');
      return [];
    }
  }

  /// Add a real comment to a post
  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to comment.');
    }

    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw Exception('Comment cannot be empty.');
    }
    if (trimmedContent.length > 1000) {
      throw Exception('Comment exceeds maximum length of 1,000 characters.');
    }

    // Same name as on posts (the profile), not the sign-up metadata.
    Map<String, dynamic>? profile;
    try {
      profile = await fetchMyPublicProfile();
    } catch (_) {}
    final String authorName =
        profile?['full_name']?.toString() ??
        user.userMetadata?['full_name'] ??
        user.userMetadata?['name'] ??
        'User';

    // Only report a comment as posted once the database has it; the
    // trg_sync_comment_count trigger keeps the post's comment_count in step.
    final List<dynamic> res;
    try {
      res = await _client
          .from('post_comments')
          .insert({
            'post_id': postId,
            'user_id': user.id,
            'content': trimmedContent,
          })
          .select();
    } catch (e) {
      debugPrint('Comment insert failed: $e');
      throw Exception(
        'Could not post your comment. The post may have been removed, or you are offline.',
      );
    }
    if (res.isEmpty) {
      throw Exception('Could not post your comment. Please try again.');
    }

    final remote = Map<String, dynamic>.from(res[0] as Map);
    remote['author'] = {'id': user.id, 'full_name': authorName};
    _localCommentCounts[postId] = (_localCommentCounts[postId] ?? 0) + 1;
    return remote;
  }

  /// Create a new community post (users or shelters)
  Future<bool> createPost({
    required String content,
    String? imageUrl,
    String? category,
    String? petId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to create a post.');
    }

    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw Exception('Post content cannot be empty.');
    }
    if (trimmedContent.length > 3000) {
      throw Exception(
        'Post content exceeds maximum length of 3,000 characters.',
      );
    }

    final image = imageUrl?.trim();
    if (image != null && image.isNotEmpty) {
      final uri = Uri.tryParse(image);
      if (uri == null ||
          !const ['https', 'http'].contains(uri.scheme) ||
          uri.host.isEmpty) {
        throw ArgumentError('Please use a valid image URL.');
      }
    }
    if (category != null &&
        !const [
          'Success Stories',
          'Announcements',
          'Tips',
        ].contains(category)) {
      throw ArgumentError('Please choose a valid category.');
    }
    try {
      final insertData = <String, dynamic>{
        'content': trimmedContent,
        'author_id': user.id,
      };

      if (category != null && category.isNotEmpty) {
        insertData['category'] = category;
      }

      if (imageUrl != null && imageUrl.trim().isNotEmpty) {
        insertData['image_url'] = imageUrl.trim();
      }
      if (petId != null && petId.isNotEmpty) {
        insertData['pet_id'] = petId;
      }

      final row = await _client
          .from('community_posts')
          .insert(insertData)
          .select('id')
          .single();
      if (row['id'] == null || row['id'].toString().isEmpty) {
        throw StateError('Post confirmation was missing.');
      }
      return true;
    } catch (e) {
      debugPrint('Error creating community post: $e');
      rethrow;
    }
  }

  /// Fetch active broadcast announcements
  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    try {
      final response = await _client
          .from('announcements')
          .select()
          .order('created_at', ascending: false)
          .limit(5);

      final List<dynamic> list = response as List<dynamic>;
      return list
          .map(
            (item) => Map<String, dynamic>.from(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
      return [];
    }
  }
}
