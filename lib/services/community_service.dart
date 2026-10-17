import 'dart:convert';
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

  // Local comments cache backed by SharedPreferences
  static final Map<String, List<Map<String, dynamic>>> _localComments = {};
  static final Map<String, int> _localCommentCounts = {};
  static bool _loadedFromPrefs = false;

  static Future<void> _loadLocalComments() async {
    if (_loadedFromPrefs) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('community_local_comments');
      if (saved != null && saved.isNotEmpty) {
        final decoded = jsonDecode(saved) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          if (value is List) {
            _localComments[key] = value
                .map((c) => Map<String, dynamic>.from(c as Map))
                .toList();
            _localCommentCounts[key] = _localComments[key]!.length;
          }
        });
      }
      _loadedFromPrefs = true;
    } catch (e) {
      debugPrint('Error loading local comments from prefs: $e');
    }
  }

  static Future<void> _saveLocalComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'community_local_comments',
        jsonEncode(_localComments),
      );
    } catch (e) {
      debugPrint('Error saving local comments to prefs: $e');
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

      // Merge with any local comments
      final local = _localComments[postId] ?? [];
      final Set<String> existingIds = remoteComments
          .map((c) => c['id']?.toString() ?? '')
          .toSet();
      for (final loc in local) {
        if (!existingIds.contains(loc['id'])) {
          remoteComments.add(loc);
        }
      }

      _localCommentCounts[postId] = remoteComments.length;
      return remoteComments;
    } catch (e) {
      debugPrint('Notice: Remote post_comments fallback to local memory: $e');
      return _localComments[postId] ?? [];
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

    final String authorName =
        user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'User';

    final newComment = <String, dynamic>{
      'id': 'cmt_${DateTime.now().millisecondsSinceEpoch}',
      'post_id': postId,
      'user_id': user.id,
      'content': trimmedContent,
      'created_at': DateTime.now().toIso8601String(),
      'author': {'id': user.id, 'full_name': authorName},
    };

    // Store in local cache and save immediately
    if (!_localComments.containsKey(postId)) {
      _localComments[postId] = [];
    }
    _localComments[postId]!.add(newComment);
    _localCommentCounts[postId] = _localComments[postId]!.length;
    await _saveLocalComments();

    // Attempt remote save to Supabase
    try {
      final insertData = {
        'post_id': postId,
        'user_id': user.id,
        'content': content.trim(),
      };
      final res = await _client
          .from('post_comments')
          .insert(insertData)
          .select();
      if (res.isNotEmpty) {
        final remote = Map<String, dynamic>.from(res[0]);
        remote['author'] = newComment['author'];
        return remote;
      }
    } catch (e) {
      debugPrint('Saved locally, remote sync pending migration: $e');
    }

    // Try incrementing comment_count on post
    try {
      final current = _localCommentCounts[postId] ?? 1;
      await _client
          .from('community_posts')
          .update({'comment_count': current})
          .eq('id', postId);
    } catch (_) {}

    return newComment;
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
