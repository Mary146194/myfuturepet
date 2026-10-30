import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'notifications_screen.dart';
import '../services/community_service.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';

class FeedScreen extends StatefulWidget {
  final CommunityService? communityService;
  final ValueNotifier<int>? unreadCount;
  const FeedScreen({super.key, this.communityService, this.unreadCount});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final CommunityService _communityService;
  bool _postsFailed = false;
  int _loadVersion = 0;
  final Set<String> _pendingLikes = {};

  static const Color primaryColor = Color(0xFFA94327);
  static const Color backgroundColor = Color(0xFFF6F8F9);
  static const Color darkText = Color(0xFF263238);

  String selectedCategory = 'All';
  final List<String> categories = const [
    'All',
    'Success Stories',
    'Announcements',
    'Tips',
  ];

  bool _loadingPosts = true;
  List<Map<String, dynamic>> _posts = [];
  final Map<String, bool> _likedPostIds = {};
  final Map<String, int> _likeCounts = {};
  final Map<String, int> _commentCounts = {};

  String _currentUserName = 'User';
  String _currentUserImage = '';

  @override
  void initState() {
    super.initState();
    _communityService = widget.communityService ?? CommunityService();
    _loadCurrentUser();
    _loadPosts();
  }

  // ============================================================
  // LOAD USER
  // ============================================================
  Future<void> _loadCurrentUser() async {
    try {
      final user = _communityService.currentUser;
      if (user == null) return;

      String name = user.userMetadata?['full_name']?.toString().trim() ?? '';
      String avatar = user.userMetadata?['avatar_url']?.toString().trim() ?? '';

      if (name.isEmpty) {
        name = 'Community member';
      }

      try {
        final profile = await _communityService.fetchMyPublicProfile();

        if (profile != null) {
          final dbName = profile['full_name']?.toString().trim() ?? '';
          if (dbName.isNotEmpty) name = dbName;
          final dbAvatar = profile['avatar_url']?.toString().trim() ?? '';
          if (dbAvatar.isNotEmpty) avatar = dbAvatar;
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _currentUserName = name;
          _currentUserImage = avatar;
        });
      }
    } catch (_) {}
  }

  // ============================================================
  // LOAD POSTS FROM SUPABASE
  // ============================================================
  Future<void> _loadPosts() async {
    final version = ++_loadVersion;
    setState(() { _loadingPosts = true; _postsFailed = false; });
    try {
      final fetched = await _communityService.fetchPosts(throwOnError: true);

      if (mounted && version == _loadVersion) {
        setState(() {
          _posts = fetched;
          for (final post in fetched) {
            final id = post['id']?.toString() ?? '';
            if (_pendingLikes.contains(id)) continue;
            _likedPostIds[id] = post['is_liked_by_me'] == true;
            _likeCounts[id] = (post['like_count'] as num?)?.toInt() ?? 0;
            _commentCounts[id] = (post['comment_count'] as num?)?.toInt() ?? 0;
          }
          _loadingPosts = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading community posts: $e');
      if (mounted && version == _loadVersion) setState(() { _loadingPosts = false; _postsFailed = true; });
    }
  }

  // ============================================================
  // LIKE TOGGLE (REAL DATABASE PERSISTENCE)
  // ============================================================
  Future<void> _toggleLike(String postId) async {
    if (!_pendingLikes.add(postId)) return;
    final bool currentLiked = _likedPostIds[postId] ?? false;
    final int currentCount = _likeCounts[postId] ?? 0;

    // Optimistic UI update
    setState(() {
      _likedPostIds[postId] = !currentLiked;
      _likeCounts[postId] = currentLiked
          ? (currentCount > 0 ? currentCount - 1 : 0)
          : currentCount + 1;
    });

    try {
      final bool newLiked = await _communityService.toggleLike(
        postId,
        currentLiked,
        currentCount,
      );
      int? serverCount;
      try { serverCount = await _communityService.fetchLikeCount(postId); } catch (_) {}
      if (mounted) {
        setState(() {
          if (serverCount != null) _likeCounts[postId] = serverCount;
          _likedPostIds[postId] = newLiked;
        });
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _likedPostIds[postId] = currentLiked;
          _likeCounts[postId] = currentCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update your like. Check your connection and sign-in, then try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _pendingLikes.remove(postId));
      } else {
        _pendingLikes.remove(postId);
      }
    }
  }

  // ============================================================
  // SHARE POST (NATIVE SHARE)
  // ============================================================
  void _sharePost({required String author, required String content}) {
    SharePlus.instance.share(
      ShareParams(
        text:
            '$author shared on My Future Pet:\n\n$content\n\n'
            'Download My Future Pet to adopt and support rescue pets!',
        subject: 'My Future Pet Story',
      ),
    );
  }

  // ============================================================
  // COMMENTS BOTTOM SHEET (REAL DATA)
  // ============================================================
  void _showCommentsModal(String postId, String authorName) {
    final bool isDark = ThemeService.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CommentsSheet(
        postId: postId,
        postAuthor: authorName,
        isDark: isDark,
        communityService: _communityService,
        onCommentAdded: () {
          setState(() {
            _commentCounts[postId] = (_commentCounts[postId] ?? 0) + 1;
          });
        },
      ),
    );
  }


  // CREATE POST MODAL (USER POSTING)
  // ============================================================
  void _openCreatePostModal() {
    final bool isDark = ThemeService.isDarkMode(context);
    final TextEditingController contentController = TextEditingController();
    final TextEditingController imageController = TextEditingController();
    String postCategory = 'Success Stories';
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Create Community Post',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Success Stories', 'Announcements', 'Tips'].map((cat) {
                        final selected = postCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : (isDark ? const Color(0xFFE2E8F0) : darkText),
                            fontSize: 12,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          onSelected: (val) {
                            if (val) setModalState(() => postCategory = cat);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      style: TextStyle(color: isDark ? const Color(0xFFF8FAFC) : darkText),
                      decoration: InputDecoration(
                        hintText: "Share your pet story, update, or tip...",
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imageController,
                      style: TextStyle(color: isDark ? const Color(0xFFF8FAFC) : darkText),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.link_rounded, color: primaryColor),
                        hintText: "Optional image URL (https://...)",
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: submitting
                            ? null
                            : () async {
                                final text = contentController.text.trim();
                                final messenger = ScaffoldMessenger.of(context);
                                if (text.isEmpty) {
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Please enter your post content.')),
                                  );
                                  return;
                                }

                                setModalState(() => submitting = true);
                                try {
                                  await _communityService.createPost(
                                    content: text,
                                    category: postCategory,
                                    imageUrl: imageController.text.trim().isNotEmpty
                                        ? imageController.text.trim()
                                        : null,
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (!mounted) return;
                                  _loadPosts();
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Post published to Community Feed!')),
                                  );
                                } catch (err) {
                                  if (!ctx.mounted) return;
                                  setModalState(() => submitting = false);
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Unable to publish. Check the post, image URL, and your sign-in, then try again.')),
                                  );
                                }
                              },
                        child: submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Publish Post',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // FORMAT NUMBER
  // ============================================================
  String _formatCount(int count) {
    if (count >= 1000) {
      final double k = count / 1000.0;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return count.toString();
  }

  String _formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    try {
      final dt = DateTime.parse(timestamp.toString()).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays >= 7) {
        return '${dt.month}/${dt.day}/${dt.year}';
      } else if (diff.inDays >= 1) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours >= 1) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes >= 1) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return 'Recently';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode(context);
    final bgCol = isDark ? const Color(0xFF0F172A) : backgroundColor;

    return Scaffold(
      backgroundColor: bgCol,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryBar(),
            Expanded(
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _loadPosts,
                    color: primaryColor,
                    child: _buildFeed(),
                  ),
                  Positioned(
                    right: 18,
                    bottom: 20,
                    child: _buildCreatePostButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader() {
    final isDark = ThemeService.isDarkMode(context);

    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF1E293B) : backgroundColor,
      padding: const EdgeInsets.fromLTRB(18, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFD9E4E7),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: _currentUserImage.isNotEmpty
                  ? Image.network(
                      _currentUserImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets_rounded, color: primaryColor, size: 24),
                    )
                  : Center(
                      child: Text(
                        _currentUserName.isNotEmpty ? _currentUserName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 18),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Community',
            style: TextStyle(
              color: isDark ? const Color(0xFFF8FAFC) : primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<int>(
            valueListenable: widget.unreadCount ?? NotificationService().unreadCountNotifier,
            builder: (context, unreadCount, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      size: 24,
                      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF062B35),
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFA94327),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY BAR
  // ============================================================
  Widget _buildCategoryBar() {
    final isDark = ThemeService.isDarkMode(context);

    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF1E293B) : backgroundColor,
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: categories.map((cat) {
            final isSelected = selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => selectedCategory = cat);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : (isDark ? const Color(0xFF0F172A) : Colors.white),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFF94A3B8) : darkText),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // POSTS LIST
  // ============================================================
  Widget _buildFeed() {
    if (_loadingPosts) {
      return const Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (_postsFailed) {
      return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
        const SizedBox(height: 60),
        const Center(child: Text('Unable to load community posts. Please try again.')),
        Center(child: TextButton(onPressed: _loadPosts, child: const Text('Retry'))),
      ]);
    }
    final filtered = selectedCategory == 'All'
        ? _posts
        : _posts.where((p) => p['category'] == selectedCategory).toList();

    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              children: [
                Icon(Icons.feed_outlined, size: 54, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No community posts yet in "$selectedCategory"',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildPostCard(filtered[index]);
      },
    );
  }

  // ============================================================
  // POST CARD (MATCHES FIGMA / USER SCREENSHOT + REPOST)
  // ============================================================
  Widget _authorInitial(String name) => ColoredBox(
    color: const Color(0xFFFFECD9),
    child: Center(child: Text(name.isEmpty ? 'U' : name[0].toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor))),
  );

  Widget _buildPostCard(Map<String, dynamic> post) {
    final bool isDark = ThemeService.isDarkMode(context);
    final String postId = post['id']?.toString() ?? '';
    final String content = post['content']?.toString() ?? '';
    final String? imageUrl = post['image_url']?.toString();
    final String timeAgo = _formatTimeAgo(post['created_at']);

    // Author info
    final authorMap = post['author'] as Map<String, dynamic>?;
    final shelterMap = post['shelter'] as Map<String, dynamic>?;

    String authorName = 'Community member';
    String? authorAvatar;

    final name = authorMap?['full_name']?.toString().trim() ?? '';
    if (name.isNotEmpty) {
      authorName = name;
      authorAvatar = authorMap?['avatar_url']?.toString();
    } else if (shelterMap != null && shelterMap['name'] != null) {
      authorName = shelterMap['name'].toString();
      authorAvatar = shelterMap['logo_url']?.toString();
    }
    final bool isLiked = _likedPostIds[postId] ?? false;
    final int likes = _likeCounts[postId] ?? ((post['like_count'] as num?)?.toInt() ?? 0);
    final int comments = _commentCounts[postId] ?? ((post['comment_count'] as num?)?.toInt() ?? 0);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCFE8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Time
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(width: 40, height: 40,
                    child: authorAvatar != null && authorAvatar.isNotEmpty
                      ? Image.network(authorAvatar, fit: BoxFit.cover,
                          errorBuilder: (_, error, stack) => _authorInitial(authorName))
                      : _authorInitial(authorName),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: isDark ? const Color(0xFFF8FAFC) : darkText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Post Image (if present)
          if (imageUrl != null && imageUrl.trim().isNotEmpty)
            Container(
              width: double.infinity,
              height: 230,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
                ),
              ),
            ),

          // Post Text Content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
          ),

          // Faint divider line
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),

          // ACTION BAR: Heart, Comment, Share
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                // Heart / Like
                GestureDetector(
                  key: ValueKey('like-$postId'),
                  onTap: _pendingLikes.contains(postId) ? null : () => _toggleLike(postId),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 21,
                        color: isLiked ? Colors.red : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatCount(likes),
                        style: TextStyle(
                          color: isLiked ? Colors.red : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Comment
                GestureDetector(
                  onTap: () => _showCommentsModal(postId, authorName),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatCount(comments),
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Share
                GestureDetector(
                  onTap: () => _sharePost(author: authorName, content: content),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.share_outlined,
                      size: 21,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FLOATING CREATE POST BUTTON
  // ============================================================
  Widget _buildCreatePostButton() {
    return GestureDetector(
      onTap: _openCreatePostModal,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.edit_rounded,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }
}

// ============================================================
// REAL COMMENTS BOTTOM SHEET
// ============================================================
class _CommentsSheet extends StatefulWidget {
  final String postId;
  final String postAuthor;
  final bool isDark;
  final CommunityService communityService;
  final VoidCallback onCommentAdded;

  const _CommentsSheet({
    required this.postId,
    required this.postAuthor,
    required this.isDark,
    required this.communityService,
    required this.onCommentAdded,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentCtrl = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final list = await widget.communityService.fetchComments(widget.postId);
    if (mounted) {
      setState(() {
        _comments = list;
        _loading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a comment.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_submitting) return;

    setState(() => _submitting = true);
    _commentCtrl.clear();

    try {
      final newComment = await widget.communityService.addComment(
        postId: widget.postId,
        content: text,
      );

      if (mounted) {
        setState(() {
          _comments.add(newComment);
          _submitting = false;
        });
        widget.onCommentAdded();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        // Give the text back so a failed comment is not lost.
        _commentCtrl.text = text;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = widget.isDark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comments (${_comments.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),

          // Comments List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFA94327)))
                : _comments.isEmpty
                    ? Center(
                        child: Text(
                          'No comments yet. Start the conversation!',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final c = _comments[index];
                          final author = c['author'] as Map<String, dynamic>?;
                          final name = author?['full_name']?.toString() ?? 'User';
                          final content = c['content']?.toString() ?? '';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFFD0E3EA),
                                  backgroundImage: (author?['avatar_url'] != null &&
                                          author!['avatar_url'].toString().isNotEmpty)
                                      ? NetworkImage(author['avatar_url'].toString())
                                      : null,
                                  child: (author?['avatar_url'] == null ||
                                          author!['avatar_url'].toString().isEmpty)
                                      ? Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFFA94327),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          content,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    style: TextStyle(color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFFA94327)),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}