import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// REPOST DATA
// ============================================================

class _RepostData {
  final String originalPostId;
  final String reposterName;
  final String reposterImage;

  final String originalProfileImage;
  final String originalAuthor;
  final String originalTime;
  final String originalContent;

  final String? originalPostImage;
  final bool hasImage;

  final String category;

  _RepostData({
    required this.originalPostId,
    required this.reposterName,
    required this.reposterImage,
    required this.originalProfileImage,
    required this.originalAuthor,
    required this.originalTime,
    required this.originalContent,
    required this.originalPostImage,
    required this.hasImage,
    required this.category,
  });
}

// ============================================================
// COMMENTS BOTTOM SHEET
// ============================================================

class _CommentsBottomSheet extends StatefulWidget {
  final Color primaryColor;
  final Color backgroundColor;
  final Color lightBlue;
  final Color darkText;

  final List<String> comments;
  final int totalComments;

  final void Function(String comment) onCommentAdded;

  const _CommentsBottomSheet({
    required this.primaryColor,
    required this.backgroundColor,
    required this.lightBlue,
    required this.darkText,
    required this.comments,
    required this.totalComments,
    required this.onCommentAdded,
  });

  @override
  State<_CommentsBottomSheet> createState() =>
      _CommentsBottomSheetState();
}

class _CommentsBottomSheetState
    extends State<_CommentsBottomSheet> {
  late final TextEditingController _controller;

  late List<String> _comments;
  late int _totalComments;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();

    _comments = List<String>.from(
      widget.comments,
    );

    _totalComments = widget.totalComments;
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  // ==========================================================
  // ADD COMMENT
  // ==========================================================

  void _addComment() {
    final String comment =
        _controller.text.trim();

    if (comment.isEmpty) {
      return;
    }

    setState(() {
      _comments.add(comment);
      _totalComments++;
    });

    widget.onCommentAdded(comment);

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(
        milliseconds: 150,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context)
            .viewInsets
            .bottom,
      ),
      child: Container(
        height:
            MediaQuery.of(context).size.height *
                0.68,
        decoration:
            const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),
        child: Column(
          children: [
            // ==================================================
            // HANDLE
            // ==================================================

            const SizedBox(
              height: 12,
            ),

            Container(
              width: 45,
              height: 5,
              decoration:
                  BoxDecoration(
                color:
                    Color(0xFFD7DEE0),
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),

            // ==================================================
            // HEADER
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                16,
                16,
                14,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Comments',
                      style: TextStyle(
                        color:
                            widget.darkText,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '$_totalComments',
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color:
                  Colors.grey.shade200,
            ),

            // ==================================================
            // COMMENT LIST
            // ==================================================

            Expanded(
              child: _comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons
                                .chat_bubble_outline_rounded,
                            size: 52,
                            color:
                                widget.primaryColor,
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          Text(
                            'No comments yet',
                            style: TextStyle(
                              color:
                                  widget.darkText,
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            'Be the first to comment.',
                            style: TextStyle(
                              color: Colors
                                  .grey
                                  .shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics:
                          const BouncingScrollPhysics(),
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      itemCount:
                          _comments.length,
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        final String comment =
                            _comments[index];

                        return Container(
                          margin:
                              const EdgeInsets.only(
                            bottom: 11,
                          ),
                          padding:
                              const EdgeInsets.all(
                            13,
                          ),
                          decoration:
                              BoxDecoration(
                            color: widget
                                .backgroundColor,
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    widget.lightBlue,
                                child: Icon(
                                  Icons.person,
                                  size: 20,
                                  color: widget
                                      .primaryColor,
                                ),
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              Expanded(
                                child: Text(
                                  comment,
                                  style:
                                      TextStyle(
                                    color: widget
                                        .darkText,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // ==================================================
            // COMMENT INPUT
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.fromLTRB(
                14,
                10,
                14,
                14,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.07),
                    blurRadius: 10,
                    offset:
                        const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          _controller,
                      minLines: 1,
                      maxLines: 4,
                      keyboardType:
                          TextInputType.multiline,
                      textCapitalization:
                          TextCapitalization
                              .sentences,
                      textInputAction:
                          TextInputAction.newline,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      decoration:
                          InputDecoration(
                        hintText:
                            'Write a comment...',
                        hintStyle:
                            TextStyle(
                          color: Colors
                              .grey
                              .shade500,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor:
                            widget.backgroundColor,
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            24,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 9,
                  ),

                  GestureDetector(
                    onTap: _addComment,
                    behavior:
                        HitTestBehavior.opaque,
                    child: Container(
                      width: 47,
                      height: 47,
                      decoration:
                          BoxDecoration(
                        color:
                            widget.primaryColor,
                        shape:
                            BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color:
                            Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// COMMUNITY FEED SCREEN
// ============================================================

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    super.key,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  final Color primaryColor =
      const Color(0xFFA94327);

  final Color darkText =
      const Color(0xFF062B35);

  final Color backgroundColor =
      const Color(0xFFEFF9FD);

  final Color lightBlue =
      const Color(0xFFE4F5FB);

  // ============================================================
  // SUPABASE
  // ============================================================

  final SupabaseClient supabase =
      Supabase.instance.client;

  // ============================================================
  // CURRENT USER
  // ============================================================

  String _currentUserName = 'User';

  String _currentUserImage =
      'https://i.pravatar.cc/150?img=12';

  bool _loadingUser = true;

  // ============================================================
  // CATEGORY
  // ============================================================

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Success Stories',
    'Announcements',
    'Tips',
  ];

  // ============================================================
  // POST INTERACTION DATA
  // ============================================================

  final Set<String> _likedPostIds = {};

  final Set<String> _repostedPostIds = {};

  final List<_RepostData> _repostedPosts = [];

  final Map<String, int> _likeCounts = {
    'luna_success': 1200,
    'joe_foster': 45,
    'my_future_pet': 86,
  };

  final Map<String, int> _commentCounts = {
    'luna_success': 84,
    'joe_foster': 12,
    'my_future_pet': 18,
  };

  final Map<String, List<String>> _comments = {
    'luna_success': [],
    'joe_foster': [],
    'my_future_pet': [],
  };

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadCurrentUser();
  }

  // ============================================================
  // LOAD CURRENT USER
  // ============================================================

  Future<void> _loadCurrentUser() async {
    try {
      final User? user =
          supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _currentUserName = 'User';
          _loadingUser = false;
        });

        return;
      }

      // --------------------------------------------------------
      // FIRST: AUTH USER METADATA
      // --------------------------------------------------------

      String loadedName =
          user.userMetadata?['full_name']
                  ?.toString()
                  .trim() ??
              '';

      String loadedImage =
          user.userMetadata?['avatar_url']
                  ?.toString()
                  .trim() ??
              '';

      // --------------------------------------------------------
      // FALLBACK: NAME
      // --------------------------------------------------------

      if (loadedName.isEmpty) {
        loadedName =
            user.userMetadata?['name']
                    ?.toString()
                    .trim() ??
                '';
      }

      // --------------------------------------------------------
      // FALLBACK: EMAIL
      // --------------------------------------------------------

      if (loadedName.isEmpty) {
        loadedName =
            user.email?.split('@').first ??
                'User';
      }

      // --------------------------------------------------------
      // GET PROFILE FROM SUPABASE
      // --------------------------------------------------------

      try {
        final profile = await supabase
            .from('profiles')
            .select(
              'full_name, avatar_url',
            )
            .eq(
              'id',
              user.id,
            )
            .maybeSingle();

        if (profile != null) {
          final String databaseName =
              profile['full_name']
                      ?.toString()
                      .trim() ??
                  '';

          final String databaseImage =
              profile['avatar_url']
                      ?.toString()
                      .trim() ??
                  '';

          if (databaseName.isNotEmpty) {
            loadedName = databaseName;
          }

          if (databaseImage.isNotEmpty) {
            loadedImage = databaseImage;
          }
        }
      } catch (_) {
        // Continue using Auth metadata.
      }

      if (loadedName.isEmpty) {
        loadedName = 'User';
      }

      if (loadedImage.isEmpty) {
        loadedImage =
            'https://i.pravatar.cc/150?img=12';
      }

      if (!mounted) return;

      setState(() {
        _currentUserName = loadedName;
        _currentUserImage = loadedImage;
        _loadingUser = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _currentUserName = 'User';
        _loadingUser = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryBar(),

            Expanded(
              child: Stack(
                children: [
                  _buildFeed(),

                  Positioned(
                    right: 18,
                    bottom: 20,
                    child:
                        _buildCreatePostButton(),
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
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding:
          const EdgeInsets.fromLTRB(
        18,
        12,
        16,
        12,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color:
                    const Color(0xFFD9E4E7),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                _loadingUser
                    ? 'https://i.pravatar.cc/150?img=12'
                    : _currentUserImage,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Icon(
                    Icons.pets_rounded,
                    color: primaryColor,
                    size: 25,
                  );
                },
              ),
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Text(
              'Community',
              style: TextStyle(
                color: primaryColor,
                fontSize: 30,
                fontWeight:
                    FontWeight.bold,
                height: 1,
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              _showMessage(
                'No new notifications.',
              );
            },
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(
              minWidth: 42,
              minHeight: 42,
            ),
            icon: Icon(
              Icons.notifications_none_rounded,
              color: primaryColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY BAR
  // ============================================================

  Widget _buildCategoryBar() {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding:
          const EdgeInsets.fromLTRB(
        16,
        4,
        0,
        14,
      ),
      child: SizedBox(
        height: 43,
        child: ListView.separated(
          scrollDirection:
              Axis.horizontal,
          physics:
              const BouncingScrollPhysics(),
          itemCount:
              categories.length,
          separatorBuilder: (
            context,
            index,
          ) {
            return const SizedBox(
              width: 9,
            );
          },
          itemBuilder: (
            context,
            index,
          ) {
            final String category =
                categories[index];

            final bool selected =
                selectedCategory ==
                    category;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory =
                      category;
                });
              },
              child:
                  AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 19,
                ),
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color: selected
                      ? primaryColor
                      : Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(23),
                  border: Border.all(
                    color: selected
                        ? primaryColor
                        : const Color(
                            0xFF8E7771,
                          ),
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : darkText,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // FEED
  // ============================================================

  Widget _buildFeed() {
    final List<Widget> posts = [];

    // ==========================================================
    // REPOSTS FIRST
    // ==========================================================

    for (final _RepostData repost
        in _repostedPosts) {
      if (selectedCategory != 'All' &&
          selectedCategory !=
              repost.category) {
        continue;
      }

      posts.add(
        _buildRepostCard(repost),
      );

      posts.add(
        const SizedBox(height: 14),
      );
    }

    // ==========================================================
    // FIRST ORIGINAL POST
    // ==========================================================

    if (selectedCategory == 'All' ||
        selectedCategory ==
            'Success Stories') {
      posts.add(
        _buildCommunityPost(
          postId: 'luna_success',
          profileImage:
              'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?auto=format&fit=crop&w=200&q=80',
          author:
              'JAGNA ANIMAL LOVER AND RESCUE GROUP Admin',
          time: '2 hours ago',
          postImage:
              'https://images.unsplash.com/photo-1542736667-069246bdbc74?auto=format&fit=crop&w=900&q=80',
          content:
              'Luna has finally found her forever home! After 6 months at the shelter, this sweet girl is going to her new loving family. Thank you to everyone who shared her story. ❤️\n#AdoptionSuccess #HappyTails',
        ),
      );

      posts.add(
        const SizedBox(height: 14),
      );
    }

    // ==========================================================
    // SECOND ORIGINAL POST
    // ==========================================================

    if (selectedCategory == 'All' ||
        selectedCategory == 'Tips') {
      posts.add(
        _buildTextPost(
          postId: 'joe_foster',
          profileImage:
              'https://i.pravatar.cc/150?img=47',
          author: 'JoeAss',
          time: '5 hours ago',
          content:
              'Hi everyone! We just brought home our new foster puppy, Max. He’s a bit anxious around our older dog. Any tips for smooth introductions over the first few days? 🐶',
        ),
      );

      posts.add(
        const SizedBox(height: 14),
      );
    }

    // ==========================================================
    // THIRD ORIGINAL POST
    // ==========================================================

    if (selectedCategory == 'All' ||
        selectedCategory ==
            'Announcements') {
      posts.add(
        _buildTextPost(
          postId: 'my_future_pet',
          profileImage:
              'https://i.pravatar.cc/150?img=32',
          author: 'My Future Pet',
          time: '1 day ago',
          content:
              'Remember that adopting a pet is a lifetime commitment. Give your new companion time, patience, and lots of love while they adjust to their new home. 🐾',
        ),
      );
    }

    // ==========================================================
    // NO POSTS
    // ==========================================================

    if (posts.isEmpty) {
      return _buildEmptyFeed();
    }

    return ListView(
      physics:
          const BouncingScrollPhysics(),
      padding:
          const EdgeInsets.fromLTRB(
        14,
        4,
        14,
        100,
      ),
      children: posts,
    );
  }

  // ============================================================
  // REPOST CARD
  // ============================================================

  Widget _buildRepostCard(
    _RepostData repost,
  ) {
    final String postId =
        repost.originalPostId;

    final bool isLiked =
        _likedPostIds.contains(postId);

    final bool isReposted =
        _repostedPostIds.contains(postId);

    final int likes =
        _likeCounts[postId] ?? 0;

    final int comments =
        _commentCounts[postId] ?? 0;

    return Container(
      width: double.infinity,
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFCFE8F0),
          width: 1,
        ),
      ),
      padding:
          const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ==================================================
          // REPOST HEADER
          // ==================================================

          Row(
            children: [
              ClipOval(
                child: Image.network(
                  repost.reposterImage,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      width: 42,
                      height: 42,
                      color: lightBlue,
                      child: Icon(
                        Icons.person,
                        color:
                            primaryColor,
                        size: 23,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            repost.reposterName,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                TextStyle(
                              color:
                                  darkText,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        Icon(
                          Icons
                              .repeat_rounded,
                          size: 17,
                          color:
                              primaryColor,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      'Reposted just now',
                      style: TextStyle(
                        color: Colors
                            .grey
                            .shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () {
                  _repostPost(
                    postId:
                        repost.originalPostId,
                    author:
                        repost.originalAuthor,
                    content:
                        repost.originalContent,
                    originalProfileImage:
                        repost.originalProfileImage,
                    originalTime:
                        repost.originalTime,
                    originalPostImage:
                        repost.originalPostImage,
                    category:
                        repost.category,
                    hasImage:
                        repost.hasImage,
                  );
                },
                child: Icon(
                  Icons.more_horiz_rounded,
                  color:
                      Colors.grey.shade600,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 13,
          ),

          // ==================================================
          // ORIGINAL POST
          // ==================================================

          Container(
            width: double.infinity,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFFAFCFD),
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color:
                    const Color(0xFFE0ECEF),
              ),
            ),
            clipBehavior:
                Clip.antiAlias,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    12,
                    12,
                    12,
                    10,
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child:
                            Image.network(
                          repost
                              .originalProfileImage,
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              width: 38,
                              height: 38,
                              color:
                                  lightBlue,
                              child: Icon(
                                Icons.person,
                                color:
                                    primaryColor,
                                size: 21,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              repost.originalAuthor,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  TextStyle(
                                color:
                                    darkText,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              repost.originalTime,
                              style: TextStyle(
                                color: Colors
                                    .grey
                                    .shade600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (repost.hasImage &&
                    repost.originalPostImage !=
                        null)
                  SizedBox(
                    width: double.infinity,
                    height: 250,
                    child:
                        Image.network(
                      repost
                          .originalPostImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          color: lightBlue,
                          child: Icon(
                            Icons
                                .image_outlined,
                            color:
                                primaryColor,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    13,
                    13,
                    13,
                    14,
                  ),
                  child: Text(
                    repost.originalContent,
                    style: TextStyle(
                      color: darkText,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // ==================================================
          // ACTIONS
          // ==================================================

          Row(
            children: [
              _buildActionButton(
                icon: isLiked
                    ? Icons.favorite_rounded
                    : Icons
                        .favorite_border_rounded,
                text:
                    _formatCount(likes),
                active: isLiked,
                onTap: () {
                  _toggleLike(postId);
                },
              ),

              const SizedBox(
                width: 18,
              ),

              _buildActionButton(
                icon: Icons
                    .chat_bubble_outline_rounded,
                text:
                    _formatCount(comments),
                onTap: () {
                  _showComments(
                    postId: postId,
                  );
                },
              ),

              const SizedBox(
                width: 18,
              ),

              GestureDetector(
                onTap: () {
                  _repostPost(
                    postId: postId,
                    author:
                        repost.originalAuthor,
                    content:
                        repost.originalContent,
                    originalProfileImage:
                        repost
                            .originalProfileImage,
                    originalTime:
                        repost.originalTime,
                    originalPostImage:
                        repost
                            .originalPostImage,
                    category:
                        repost.category,
                    hasImage:
                        repost.hasImage,
                  );
                },
                behavior:
                    HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.repeat_rounded,
                      size: 21,
                      color: isReposted
                          ? primaryColor
                          : Colors
                              .grey
                              .shade600,
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Text(
                      'Repost',
                      style:
                          TextStyle(
                        color: isReposted
                            ? primaryColor
                            : Colors
                                .grey
                                .shade600,
                        fontSize: 12,
                        fontWeight:
                            isReposted
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: () {
                  _sharePost(
                    author:
                        repost.originalAuthor,
                    content:
                        repost.originalContent,
                  );
                },
                behavior:
                    HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.all(5),
                  child: Icon(
                    Icons.share_outlined,
                    size: 22,
                    color:
                        Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMUNITY POST WITH IMAGE
  // ============================================================

  Widget _buildCommunityPost({
    required String postId,
    required String profileImage,
    required String author,
    required String time,
    required String postImage,
    required String content,
  }) {
    final bool isLiked =
        _likedPostIds.contains(postId);

    final bool isReposted =
        _repostedPostIds.contains(postId);

    final int likes =
        _likeCounts[postId] ?? 0;

    final int comments =
        _commentCounts[postId] ?? 0;

    return Container(
      width: double.infinity,
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFCFE8F0),
          width: 1,
        ),
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ==================================================
          // POST HEADER
          // ==================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              15,
              14,
              13,
              13,
            ),
            child: Row(
              children: [
                ClipOval(
                  child: Image.network(
                    profileImage,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Container(
                        width: 42,
                        height: 42,
                        color: lightBlue,
                        child: Icon(
                          Icons.person,
                          color:
                              primaryColor,
                          size: 23,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(
                  width: 11,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            TextStyle(
                          color:
                              darkText,
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        time,
                        style: TextStyle(
                          color: Colors
                              .grey
                              .shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.more_horiz_rounded,
                  color:
                      Colors.grey.shade600,
                  size: 24,
                ),
              ],
            ),
          ),

          // ==================================================
          // POST IMAGE
          // ==================================================

          SizedBox(
            width: double.infinity,
            height: 285,
            child: Image.network(
              postImage,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  color: lightBlue,
                  child: Icon(
                    Icons.image_outlined,
                    color: primaryColor,
                    size: 55,
                  ),
                );
              },
            ),
          ),

          // ==================================================
          // CONTENT
          // ==================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              15,
              15,
              15,
              10,
            ),
            child: Text(
              content,
              style: TextStyle(
                color: darkText,
                fontSize: 15,
                height: 1.5,
                fontWeight:
                    FontWeight.w400,
              ),
            ),
          ),

          // ==================================================
          // REPOST INDICATOR
          // ==================================================

          if (isReposted)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                15,
                0,
                15,
                10,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.repeat_rounded,
                    size: 17,
                    color: primaryColor,
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    'You reposted this',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // ==================================================
          // DIVIDER
          // ==================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Divider(
              height: 1,
              color:
                  Colors.grey.shade200,
            ),
          ),

          // ==================================================
          // ACTIONS
          // ==================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              15,
              10,
              15,
              12,
            ),
            child: Row(
              children: [
                _buildActionButton(
                  icon: isLiked
                      ? Icons.favorite_rounded
                      : Icons
                          .favorite_border_rounded,
                  text:
                      _formatCount(likes),
                  active: isLiked,
                  onTap: () {
                    _toggleLike(postId);
                  },
                ),

                const SizedBox(
                  width: 18,
                ),

                _buildActionButton(
                  icon: Icons
                      .chat_bubble_outline_rounded,
                  text:
                      _formatCount(comments),
                  onTap: () {
                    _showComments(
                      postId: postId,
                    );
                  },
                ),

                const SizedBox(
                  width: 18,
                ),

                GestureDetector(
                  onTap: () {
                    _repostPost(
                      postId: postId,
                      author: author,
                      content: content,
                      originalProfileImage:
                          profileImage,
                      originalTime: time,
                      originalPostImage:
                          postImage,
                      category:
                          'Success Stories',
                      hasImage: true,
                    );
                  },
                  behavior:
                      HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat_rounded,
                        size: 21,
                        color: isReposted
                            ? primaryColor
                            : Colors
                                .grey
                                .shade600,
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Text(
                        'Repost',
                        style:
                            TextStyle(
                          color: isReposted
                              ? primaryColor
                              : Colors
                                  .grey
                                  .shade600,
                          fontSize: 12,
                          fontWeight:
                              isReposted
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                GestureDetector(
                  onTap: () {
                    _sharePost(
                      author: author,
                      content: content,
                    );
                  },
                  behavior:
                      HitTestBehavior.opaque,
                  child: Padding(
                    padding:
                        const EdgeInsets.all(5),
                    child: Icon(
                      Icons.share_outlined,
                      size: 22,
                      color: Colors
                          .grey
                          .shade600,
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
  // TEXT POST
  // ============================================================

  Widget _buildTextPost({
    required String postId,
    required String profileImage,
    required String author,
    required String time,
    required String content,
  }) {
    final bool isLiked =
        _likedPostIds.contains(postId);

    final bool isReposted =
        _repostedPostIds.contains(postId);

    final int likes =
        _likeCounts[postId] ?? 0;

    final int comments =
        _commentCounts[postId] ?? 0;

    String category = 'Tips';

    if (postId == 'my_future_pet') {
      category = 'Announcements';
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFCFE8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ==================================================
          // HEADER
          // ==================================================

          Row(
            children: [
              ClipOval(
                child: Image.network(
                  profileImage,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      width: 42,
                      height: 42,
                      color: lightBlue,
                      child: Icon(
                        Icons.person,
                        color:
                            primaryColor,
                        size: 23,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        color: darkText,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      time,
                      style: TextStyle(
                        color: Colors
                            .grey
                            .shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.more_horiz_rounded,
                color:
                    Colors.grey.shade600,
                size: 24,
              ),
            ],
          ),

          const SizedBox(
            height: 17,
          ),

          // ==================================================
          // CONTENT
          // ==================================================

          Text(
            content,
            style: TextStyle(
              color: darkText,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          // ==================================================
          // REPOST INDICATOR
          // ==================================================

          if (isReposted)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 12,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.repeat_rounded,
                    size: 17,
                    color: primaryColor,
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    'You reposted this',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(
            height: 14,
          ),

          // ==================================================
          // DIVIDER
          // ==================================================

          Divider(
            height: 1,
            color:
                Colors.grey.shade200,
          ),

          const SizedBox(
            height: 10,
          ),

          // ==================================================
          // ACTIONS
          // ==================================================

          Row(
            children: [
              _buildActionButton(
                icon: isLiked
                    ? Icons.favorite_rounded
                    : Icons
                        .favorite_border_rounded,
                text:
                    _formatCount(likes),
                active: isLiked,
                onTap: () {
                  _toggleLike(postId);
                },
              ),

              const SizedBox(
                width: 18,
              ),

              _buildActionButton(
                icon: Icons
                    .chat_bubble_outline_rounded,
                text:
                    _formatCount(comments),
                onTap: () {
                  _showComments(
                    postId: postId,
                  );
                },
              ),

              const SizedBox(
                width: 18,
              ),

              GestureDetector(
                onTap: () {
                  _repostPost(
                    postId: postId,
                    author: author,
                    content: content,
                    originalProfileImage:
                        profileImage,
                    originalTime: time,
                    originalPostImage:
                        null,
                    category: category,
                    hasImage: false,
                  );
                },
                behavior:
                    HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.repeat_rounded,
                      size: 21,
                      color: isReposted
                          ? primaryColor
                          : Colors
                              .grey
                              .shade600,
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Text(
                      'Repost',
                      style:
                          TextStyle(
                        color: isReposted
                            ? primaryColor
                            : Colors
                                .grey
                                .shade600,
                        fontSize: 12,
                        fontWeight:
                            isReposted
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: () {
                  _sharePost(
                    author: author,
                    content: content,
                  );
                },
                behavior:
                    HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.all(5),
                  child: Icon(
                    Icons.share_outlined,
                    size: 22,
                    color: Colors
                        .grey
                        .shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior:
          HitTestBehavior.opaque,
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 21,
            color: active
                ? primaryColor
                : Colors.grey.shade600,
          ),

          const SizedBox(
            width: 6,
          ),

          Text(
            text,
            style: TextStyle(
              color: active
                  ? primaryColor
                  : Colors.grey.shade600,
              fontSize: 12,
              fontWeight: active
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LIKE / UNLIKE
  // ============================================================

  void _toggleLike(
    String postId,
  ) {
    setState(() {
      if (_likedPostIds.contains(
        postId,
      )) {
        _likedPostIds.remove(
          postId,
        );

        _likeCounts[postId] =
            (_likeCounts[postId] ?? 0) -
                1;
      } else {
        _likedPostIds.add(
          postId,
        );

        _likeCounts[postId] =
            (_likeCounts[postId] ?? 0) +
                1;
      }
    });
  }

  // ============================================================
  // REPOST
  // ============================================================

  void _repostPost({
    required String postId,
    required String author,
    required String content,
    required String originalProfileImage,
    required String originalTime,
    required String? originalPostImage,
    required String category,
    required bool hasImage,
  }) {
    // ----------------------------------------------------------
    // IF ALREADY REPOSTED
    // REMOVE THE REPOST
    // ----------------------------------------------------------

    if (_repostedPostIds.contains(
      postId,
    )) {
      setState(() {
        _repostedPostIds.remove(
          postId,
        );

        _repostedPosts.removeWhere(
          (repost) =>
              repost.originalPostId ==
              postId,
        );
      });

      _showMessage(
        'Repost removed.',
      );

      return;
    }

    // ----------------------------------------------------------
    // CREATE NEW REPOST
    // ----------------------------------------------------------

    final _RepostData newRepost =
        _RepostData(
      originalPostId: postId,

      reposterName:
          _currentUserName,

      reposterImage:
          _currentUserImage,

      originalProfileImage:
          originalProfileImage,

      originalAuthor:
          author,

      originalTime:
          originalTime,

      originalContent:
          content,

      originalPostImage:
          originalPostImage,

      hasImage:
          hasImage,

      category:
          category,
    );

    setState(() {
      _repostedPostIds.add(
        postId,
      );

      _repostedPosts.insert(
        0,
        newRepost,
      );
    });

    _showMessage(
      'Post reposted to the top of your feed.',
    );
  }

  // ============================================================
  // COMMENTS
  // ============================================================

  void _showComments({
    required String postId,
  }) {
    _comments.putIfAbsent(
      postId,
      () => <String>[],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      useSafeArea: true,
      builder: (_) {
        return _CommentsBottomSheet(
          primaryColor:
              primaryColor,
          backgroundColor:
              backgroundColor,
          lightBlue:
              lightBlue,
          darkText:
              darkText,
          comments:
              _comments[postId] ??
                  <String>[],
          totalComments:
              _commentCounts[postId] ??
                  0,
          onCommentAdded:
              (String comment) {
            if (!mounted) return;

            setState(() {
              _comments[postId] ??=
                  <String>[];

              _comments[postId]!
                  .add(comment);

              _commentCounts[postId] =
                  (_commentCounts[postId] ??
                          0) +
                      1;
            });
          },
        );
      },
    );
  }

  // ============================================================
  // EXTERNAL SHARE
  // ============================================================

  Future<void> _sharePost({
    required String author,
    required String content,
  }) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          title:
              'My Future Pet Community',
          text:
              '$author\n\n$content\n\nShared from My Future Pet Community',
        ),
      );
    } catch (e) {
      _showMessage(
        'Unable to share this post.',
      );
    }
  }

  // ============================================================
  // FORMAT COUNT
  // ============================================================

  String _formatCount(
    int count,
  ) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }

    if (count >= 1000) {
      final String value =
          (count / 1000)
              .toStringAsFixed(1);

      if (value.endsWith('.0')) {
        return '${value.substring(
          0,
          value.length - 2,
        )}k';
      }

      return '${value}k';
    }

    return count.toString();
  }

  // ============================================================
  // FLOATING CREATE POST BUTTON
  // ============================================================

  Widget _buildCreatePostButton() {
    return GestureDetector(
      onTap: () {
        _showCreatePostDialog();
      },
      child: Container(
        width: 58,
        height: 58,
        decoration:
            BoxDecoration(
          color: primaryColor,
          borderRadius:
              BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.18,
              ),
              blurRadius: 9,
              offset:
                  const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.edit_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY FEED
  // ============================================================

  Widget _buildEmptyFeed() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.only(
          top: 70,
          left: 20,
          right: 20,
        ),
        child: Column(
          children: [
            Icon(
              Icons.forum_outlined,
              size: 60,
              color: primaryColor,
            ),

            const SizedBox(
              height: 17,
            ),

            Text(
              'No posts found',
              style: TextStyle(
                color: darkText,
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              'There are no posts in this category yet.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            OutlinedButton(
              onPressed: () {
                setState(() {
                  selectedCategory =
                      'All';
                });
              },
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    primaryColor,
                side: BorderSide(
                  color: primaryColor,
                ),
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                ),
              ),
              child:
                  const Text(
                'View All Posts',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CREATE POST DIALOG
  // ============================================================

  void _showCreatePostDialog() {
    final TextEditingController
        controller =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              Colors.white,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
          title: Text(
            'Create Post',
            style: TextStyle(
              color: darkText,
              fontSize: 21,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 5,
            style: TextStyle(
              color: darkText,
              fontSize: 14,
            ),
            decoration:
                InputDecoration(
              hintText:
                  'Share something with the community...',
              hintStyle:
                  TextStyle(
                color:
                    Colors.grey.shade500,
                fontSize: 13,
              ),
              filled: true,
              fillColor:
                  backgroundColor,
              contentPadding:
                  const EdgeInsets.all(
                14,
              ),
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                borderSide:
                    BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if (controller.text
                    .trim()
                    .isEmpty) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                );

                _showMessage(
                  'Post created successfully!',
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
              ),
              child:
                  const Text(
                'Post',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    ).whenComplete(
      controller.dispose,
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              const TextStyle(
            fontSize: 13,
          ),
        ),
        behavior:
            SnackBarBehavior.floating,
        duration:
            const Duration(
          seconds: 2,
        ),
      ),
    );
  }
}


































// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// // ============================================================
// // REPOST DATA
// // ============================================================

// class _RepostData {
//   final String originalPostId;
//   final String reposterName;
//   final String reposterImage;

//   final String originalProfileImage;
//   final String originalAuthor;
//   final String originalTime;
//   final String originalContent;

//   final String? originalPostImage;
//   final bool hasImage;

//   final String category;

//   _RepostData({
//     required this.originalPostId,
//     required this.reposterName,
//     required this.reposterImage,
//     required this.originalProfileImage,
//     required this.originalAuthor,
//     required this.originalTime,
//     required this.originalContent,
//     required this.originalPostImage,
//     required this.hasImage,
//     required this.category,
//   });
// }

// // ============================================================
// // COMMENTS BOTTOM SHEET
// // ============================================================

// class _CommentsBottomSheet extends StatefulWidget {
//   final Color primaryColor;
//   final Color backgroundColor;
//   final Color lightBlue;
//   final Color darkText;

//   final List<String> comments;
//   final int totalComments;

//   final void Function(String comment) onCommentAdded;

//   const _CommentsBottomSheet({
//     required this.primaryColor,
//     required this.backgroundColor,
//     required this.lightBlue,
//     required this.darkText,
//     required this.comments,
//     required this.totalComments,
//     required this.onCommentAdded,
//   });

//   @override
//   State<_CommentsBottomSheet> createState() =>
//       _CommentsBottomSheetState();
// }

// class _CommentsBottomSheetState
//     extends State<_CommentsBottomSheet> {
//   late final TextEditingController _controller;

//   late List<String> _comments;

//   late int _totalComments;

//   @override
//   void initState() {
//     super.initState();

//     _controller = TextEditingController();

//     _comments = List<String>.from(
//       widget.comments,
//     );

//     _totalComments = widget.totalComments;
//   }

//   @override
//   void dispose() {
//     _controller.dispose();

//     super.dispose();
//   }

//   // ==========================================================
//   // ADD COMMENT
//   // ==========================================================

//   void _addComment() {
//     final String comment =
//         _controller.text.trim();

//     if (comment.isEmpty) {
//       return;
//     }

//     // Add to the local comment list first.
//     setState(() {
//       _comments.add(comment);

//       _totalComments++;
//     });

//     // Update the parent FeedScreen.
//     widget.onCommentAdded(comment);

//     // Clear the input.
//     _controller.clear();

//     // Keep the keyboard open so the user can
//     // immediately type another comment.
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedPadding(
//       duration: const Duration(
//         milliseconds: 150,
//       ),
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context)
//             .viewInsets
//             .bottom,
//       ),
//       child: Container(
//         height:
//             MediaQuery.of(context).size.height *
//                 0.65,
//         decoration:
//             const BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.vertical(
//             top: Radius.circular(24),
//           ),
//         ),
//         child: Column(
//           children: [
//             // ==================================================
//             // HANDLE
//             // ==================================================

//             const SizedBox(
//               height: 10,
//             ),

//             Container(
//               width: 42,
//               height: 4,
//               decoration:
//                   BoxDecoration(
//                 color:
//                     Color(0xFFD7DEE0),
//                 borderRadius:
//                     BorderRadius.circular(
//                   10,
//                 ),
//               ),
//             ),

//             // ==================================================
//             // HEADER
//             // ==================================================

//             Padding(
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 18,
//                 15,
//                 14,
//                 12,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'Comments',
//                       style: TextStyle(
//                         color:
//                             widget.darkText,
//                         fontSize: 19,
//                         fontWeight:
//                             FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                   Text(
//                     '$_totalComments',
//                     style: TextStyle(
//                       color:
//                           Colors.grey.shade600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Divider(
//               height: 1,
//               color:
//                   Colors.grey.shade200,
//             ),

//             // ==================================================
//             // COMMENT LIST
//             // ==================================================

//             Expanded(
//               child: _comments.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisSize:
//                             MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons
//                                 .chat_bubble_outline_rounded,
//                             size: 45,
//                             color:
//                                 widget.primaryColor,
//                           ),

//                           const SizedBox(
//                             height: 10,
//                           ),

//                           Text(
//                             'No comments yet',
//                             style: TextStyle(
//                               color:
//                                   widget.darkText,
//                               fontSize: 15,
//                               fontWeight:
//                                   FontWeight.bold,
//                             ),
//                           ),

//                           const SizedBox(
//                             height: 4,
//                           ),

//                           Text(
//                             'Be the first to comment.',
//                             style: TextStyle(
//                               color: Colors
//                                   .grey
//                                   .shade600,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : ListView.builder(
//                       physics:
//                           const BouncingScrollPhysics(),
//                       padding:
//                           const EdgeInsets.all(
//                         15,
//                       ),
//                       itemCount:
//                           _comments.length,
//                       itemBuilder:
//                           (
//                         context,
//                         index,
//                       ) {
//                         final String comment =
//                             _comments[index];

//                         return Container(
//                           margin:
//                               const EdgeInsets.only(
//                             bottom: 10,
//                           ),
//                           padding:
//                               const EdgeInsets.all(
//                             11,
//                           ),
//                           decoration:
//                               BoxDecoration(
//                             color: widget
//                                 .backgroundColor,
//                             borderRadius:
//                                 BorderRadius.circular(
//                               14,
//                             ),
//                           ),
//                           child: Row(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment
//                                     .start,
//                             children: [
//                               CircleAvatar(
//                                 radius: 16,
//                                 backgroundColor:
//                                     widget.lightBlue,
//                                 child: Icon(
//                                   Icons.person,
//                                   size: 18,
//                                   color: widget
//                                       .primaryColor,
//                                 ),
//                               ),

//                               const SizedBox(
//                                 width: 9,
//                               ),

//                               Expanded(
//                                 child: Text(
//                                   comment,
//                                   style:
//                                       TextStyle(
//                                     color: widget
//                                         .darkText,
//                                     fontSize: 12,
//                                     height: 1.4,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//             ),

//             // ==================================================
//             // COMMENT INPUT
//             // ==================================================

//             Container(
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 12,
//                 8,
//                 12,
//                 10,
//               ),
//               decoration:
//                   BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black
//                         .withOpacity(0.06),
//                     blurRadius: 8,
//                     offset:
//                         const Offset(0, -2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller:
//                           _controller,
//                       minLines: 1,
//                       maxLines: 4,
//                       keyboardType:
//                           TextInputType.multiline,
//                       textCapitalization:
//                           TextCapitalization
//                               .sentences,
//                       textInputAction:
//                           TextInputAction.newline,
//                       decoration:
//                           InputDecoration(
//                         hintText:
//                             'Write a comment...',
//                         hintStyle:
//                             TextStyle(
//                           color: Colors
//                               .grey
//                               .shade500,
//                           fontSize: 12,
//                         ),
//                         filled: true,
//                         fillColor:
//                             widget.backgroundColor,
//                         contentPadding:
//                             const EdgeInsets
//                                 .symmetric(
//                           horizontal: 14,
//                           vertical: 11,
//                         ),
//                         border:
//                             OutlineInputBorder(
//                           borderRadius:
//                               BorderRadius
//                                   .circular(
//                             22,
//                           ),
//                           borderSide:
//                               BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(
//                     width: 8,
//                   ),

//                   GestureDetector(
//                     onTap: _addComment,
//                     behavior:
//                         HitTestBehavior.opaque,
//                     child: Container(
//                       width: 43,
//                       height: 43,
//                       decoration:
//                           BoxDecoration(
//                         color:
//                             widget.primaryColor,
//                         shape:
//                             BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.send_rounded,
//                         color:
//                             Colors.white,
//                         size: 18,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }








// // ============================================================
// // COMMUNITY FEED SCREEN
// // ============================================================

// class FeedScreen extends StatefulWidget {
//   const FeedScreen({
//     super.key,
//   });

//   @override
//   State<FeedScreen> createState() => _FeedScreenState();
// }

// class _FeedScreenState extends State<FeedScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color darkText = const Color(0xFF062B35);

//   final Color backgroundColor = const Color(0xFFEFF9FD);
//   final Color lightBlue = const Color(0xFFE4F5FB);

//   // ============================================================
//   // SUPABASE
//   // ============================================================

//   final SupabaseClient supabase =
//       Supabase.instance.client;

//   // ============================================================
//   // CURRENT USER
//   // ============================================================

//   String _currentUserName = 'User';

//   String _currentUserImage =
//       'https://i.pravatar.cc/150?img=12';

//   bool _loadingUser = true;

//   // ============================================================
//   // CATEGORY
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Success Stories',
//     'Announcements',
//     'Tips',
//   ];

//   // ============================================================
//   // POST INTERACTION DATA
//   // ============================================================

//   // Stores which posts the current user has liked.
//   final Set<String> _likedPostIds = {};

//   // Stores which original posts the current user has reposted.
//   final Set<String> _repostedPostIds = {};

//   // Stores the actual repost cards.
//   //
//   // New reposts are inserted at index 0,
//   // so the newest repost appears at the top.
//   final List<_RepostData> _repostedPosts = [];

//   // Like counts.
//   final Map<String, int> _likeCounts = {
//     'luna_success': 1200,
//     'joe_foster': 45,
//     'my_future_pet': 86,
//   };

//   // Comment counts.
//   final Map<String, int> _commentCounts = {
//     'luna_success': 84,
//     'joe_foster': 12,
//     'my_future_pet': 18,
//   };

//   // New comments added during the current app session.
//   final Map<String, List<String>> _comments = {
//     'luna_success': [],
//     'joe_foster': [],
//     'my_future_pet': [],
//   };

//   // ============================================================
//   // INIT
//   // ============================================================

//   @override
//   void initState() {
//     super.initState();

//     _loadCurrentUser();
//   }

//   // ============================================================
//   // LOAD CURRENT USER
//   // ============================================================

//   Future<void> _loadCurrentUser() async {
//     try {
//       final User? user =
//           supabase.auth.currentUser;

//       if (user == null) {
//         if (!mounted) return;

//         setState(() {
//           _currentUserName = 'User';
//           _loadingUser = false;
//         });

//         return;
//       }

//       // --------------------------------------------------------
//       // FIRST: AUTH USER METADATA
//       // --------------------------------------------------------

//       String loadedName =
//           user.userMetadata?['full_name']
//                   ?.toString()
//                   .trim() ??
//               '';

//       String loadedImage =
//           user.userMetadata?['avatar_url']
//                   ?.toString()
//                   .trim() ??
//               '';

//       // --------------------------------------------------------
//       // FALLBACK: name
//       // --------------------------------------------------------

//       if (loadedName.isEmpty) {
//         loadedName =
//             user.userMetadata?['name']
//                     ?.toString()
//                     .trim() ??
//                 '';
//       }

//       // --------------------------------------------------------
//       // FALLBACK: EMAIL
//       // --------------------------------------------------------

//       if (loadedName.isEmpty) {
//         loadedName =
//             user.email?.split('@').first ??
//                 'User';
//       }

//       // --------------------------------------------------------
//       // GET PROFILE FROM SUPABASE
//       // --------------------------------------------------------

//       try {
//         final profile = await supabase
//             .from('profiles')
//             .select(
//               'full_name, avatar_url',
//             )
//             .eq(
//               'id',
//               user.id,
//             )
//             .maybeSingle();

//         if (profile != null) {
//           final String databaseName =
//               profile['full_name']
//                       ?.toString()
//                       .trim() ??
//                   '';

//           final String databaseImage =
//               profile['avatar_url']
//                       ?.toString()
//                       .trim() ??
//                   '';

//           if (databaseName.isNotEmpty) {
//             loadedName = databaseName;
//           }

//           if (databaseImage.isNotEmpty) {
//             loadedImage = databaseImage;
//           }
//         }
//       } catch (_) {
//         // If the profiles table is unavailable,
//         // continue using Auth metadata.
//       }

//       if (loadedName.isEmpty) {
//         loadedName = 'User';
//       }

//       if (loadedImage.isEmpty) {
//         loadedImage =
//             'https://i.pravatar.cc/150?img=12';
//       }

//       if (!mounted) return;

//       setState(() {
//         _currentUserName = loadedName;
//         _currentUserImage = loadedImage;
//         _loadingUser = false;
//       });
//     } catch (_) {
//       if (!mounted) return;

//       setState(() {
//         _currentUserName = 'User';
//         _loadingUser = false;
//       });
//     }
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             _buildCategoryBar(),

//             Expanded(
//               child: Stack(
//                 children: [
//                   _buildFeed(),

//                   Positioned(
//                     right: 14,
//                     bottom: 18,
//                     child: _buildCreatePostButton(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       color: backgroundColor,
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         8,
//         14,
//         8,
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               border: Border.all(
//                 color: const Color(0xFFD9E4E7),
//                 width: 1,
//               ),
//             ),
//             child: ClipOval(
//               child: Image.network(
//                 _loadingUser
//                     ? 'https://i.pravatar.cc/150?img=12'
//                     : _currentUserImage,
//                 fit: BoxFit.cover,
//                 errorBuilder: (
//                   context,
//                   error,
//                   stackTrace,
//                 ) {
//                   return Icon(
//                     Icons.pets_rounded,
//                     color: primaryColor,
//                     size: 20,
//                   );
//                 },
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           Expanded(
//             child: Text(
//               'Community',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 25,
//                 fontWeight: FontWeight.bold,
//                 height: 1,
//               ),
//             ),
//           ),

//           IconButton(
//             onPressed: () {
//               _showMessage(
//                 'No new notifications.',
//               );
//             },
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 34,
//               minHeight: 34,
//             ),
//             icon: Icon(
//               Icons.notifications_none_rounded,
//               color: primaryColor,
//               size: 21,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY BAR
//   // ============================================================

//   Widget _buildCategoryBar() {
//     return Container(
//       width: double.infinity,
//       color: backgroundColor,
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         2,
//         0,
//         10,
//       ),
//       child: SizedBox(
//         height: 34,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           physics:
//               const BouncingScrollPhysics(),
//           itemCount: categories.length,
//           separatorBuilder: (
//             context,
//             index,
//           ) {
//             return const SizedBox(width: 7);
//           },
//           itemBuilder: (
//             context,
//             index,
//           ) {
//             final String category =
//                 categories[index];

//             final bool selected =
//                 selectedCategory == category;

//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(
//                   milliseconds: 180,
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(
//                   horizontal: 16,
//                 ),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? primaryColor
//                       : Colors.white,
//                   borderRadius:
//                       BorderRadius.circular(20),
//                   border: Border.all(
//                     color: selected
//                         ? primaryColor
//                         : const Color(0xFF8E7771),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected
//                         ? Colors.white
//                         : darkText,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FEED
//   // ============================================================

//   Widget _buildFeed() {
//     final List<Widget> posts = [];

//     // ==========================================================
//     // REPOSTS FIRST
//     // ==========================================================

//     for (final _RepostData repost
//         in _repostedPosts) {
//       if (selectedCategory != 'All' &&
//           selectedCategory != repost.category) {
//         continue;
//       }

//       posts.add(
//         _buildRepostCard(repost),
//       );

//       posts.add(
//         const SizedBox(height: 12),
//       );
//     }

//     // ==========================================================
//     // FIRST ORIGINAL POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Success Stories') {
//       posts.add(
//         _buildCommunityPost(
//           postId: 'luna_success',
//           profileImage:
//               'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?auto=format&fit=crop&w=200&q=80',
//           author:
//               'JAGNA ANIMAL LOVER AND RESCUE GROUP Admin',
//           time: '2 hours ago',
//           postImage:
//               'https://images.unsplash.com/photo-1542736667-069246bdbc74?auto=format&fit=crop&w=900&q=80',
//           content:
//               'Luna has finally found her forever home! After 6 months at the shelter, this sweet girl is going to her new loving family. Thank you to everyone who shared her story. ❤️\n#AdoptionSuccess #HappyTails',
//         ),
//       );

//       posts.add(
//         const SizedBox(height: 12),
//       );
//     }

//     // ==========================================================
//     // SECOND ORIGINAL POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Tips') {
//       posts.add(
//         _buildTextPost(
//           postId: 'joe_foster',
//           profileImage:
//               'https://i.pravatar.cc/150?img=47',
//           author: 'JoeAss',
//           time: '5 hours ago',
//           content:
//               'Hi everyone! We just brought home our new foster puppy, Max. He’s a bit anxious around our older dog. Any tips for smooth introductions over the first few days? 🐶',
//         ),
//       );

//       posts.add(
//         const SizedBox(height: 12),
//       );
//     }

//     // ==========================================================
//     // THIRD ORIGINAL POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Announcements') {
//       posts.add(
//         _buildTextPost(
//           postId: 'my_future_pet',
//           profileImage:
//               'https://i.pravatar.cc/150?img=32',
//           author: 'My Future Pet',
//           time: '1 day ago',
//           content:
//               'Remember that adopting a pet is a lifetime commitment. Give your new companion time, patience, and lots of love while they adjust to their new home. 🐾',
//         ),
//       );
//     }

//     // ==========================================================
//     // NO POSTS
//     // ==========================================================

//     if (posts.isEmpty) {
//       return _buildEmptyFeed();
//     }

//     return ListView(
//       physics:
//           const BouncingScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         2,
//         14,
//         85,
//       ),
//       children: posts,
//     );
//   }

//   // ============================================================
//   // REPOST CARD
//   // ============================================================

//   Widget _buildRepostCard(
//     _RepostData repost,
//   ) {
//     final String postId =
//         repost.originalPostId;

//     final bool isLiked =
//         _likedPostIds.contains(postId);

//     final bool isReposted =
//         _repostedPostIds.contains(postId);

//     final int likes =
//         _likeCounts[postId] ?? 0;

//     final int comments =
//         _commentCounts[postId] ?? 0;

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFCFE8F0),
//           width: 1,
//         ),
//       ),
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // ==================================================
//           // REPOST HEADER
//           // ==================================================

//           Row(
//             children: [
//               ClipOval(
//                 child: Image.network(
//                   repost.reposterImage,
//                   width: 34,
//                   height: 34,
//                   fit: BoxFit.cover,
//                   errorBuilder: (
//                     context,
//                     error,
//                     stackTrace,
//                   ) {
//                     return Container(
//                       width: 34,
//                       height: 34,
//                       color: lightBlue,
//                       child: Icon(
//                         Icons.person,
//                         color: primaryColor,
//                         size: 20,
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(width: 9),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Flexible(
//                           child: Text(
//                             repost.reposterName,
//                             maxLines: 1,
//                             overflow:
//                                 TextOverflow.ellipsis,
//                             style: TextStyle(
//                               color: darkText,
//                               fontSize: 13,
//                               fontWeight:
//                                   FontWeight.bold,
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 5),

//                         Icon(
//                           Icons.repeat_rounded,
//                           size: 14,
//                           color: primaryColor,
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 3),

//                     Text(
//                       'Reposted just now',
//                       style: TextStyle(
//                         color:
//                             Colors.grey.shade600,
//                         fontSize: 9,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               GestureDetector(
//                 onTap: () {
//                   _repostPost(
//                     postId:
//                         repost.originalPostId,
//                     author:
//                         repost.originalAuthor,
//                     content:
//                         repost.originalContent,
//                     originalProfileImage:
//                         repost.originalProfileImage,
//                     originalTime:
//                         repost.originalTime,
//                     originalPostImage:
//                         repost.originalPostImage,
//                     category:
//                         repost.category,
//                     hasImage:
//                         repost.hasImage,
//                   );
//                 },
//                 child: Icon(
//                   Icons.more_horiz_rounded,
//                   color:
//                       Colors.grey.shade600,
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 10),

//           // ==================================================
//           // ORIGINAL POST
//           // ==================================================

//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: const Color(0xFFFAFCFD),
//               borderRadius:
//                   BorderRadius.circular(13),
//               border: Border.all(
//                 color:
//                     const Color(0xFFE0ECEF),
//               ),
//             ),
//             clipBehavior:
//                 Clip.antiAlias,
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding:
//                       const EdgeInsets.fromLTRB(
//                     10,
//                     10,
//                     10,
//                     9,
//                   ),
//                   child: Row(
//                     children: [
//                       ClipOval(
//                         child: Image.network(
//                           repost.originalProfileImage,
//                           width: 30,
//                           height: 30,
//                           fit: BoxFit.cover,
//                           errorBuilder: (
//                             context,
//                             error,
//                             stackTrace,
//                           ) {
//                             return Container(
//                               width: 30,
//                               height: 30,
//                               color:
//                                   lightBlue,
//                               child: Icon(
//                                 Icons.person,
//                                 color:
//                                     primaryColor,
//                                 size: 18,
//                               ),
//                             );
//                           },
//                         ),
//                       ),

//                       const SizedBox(width: 8),

//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               repost.originalAuthor,
//                               maxLines: 2,
//                               overflow:
//                                   TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 color:
//                                     darkText,
//                                 fontSize: 11,
//                                 fontWeight:
//                                     FontWeight.bold,
//                               ),
//                             ),

//                             const SizedBox(
//                               height: 2,
//                             ),

//                             Text(
//                               repost.originalTime,
//                               style: TextStyle(
//                                 color: Colors
//                                     .grey
//                                     .shade600,
//                                 fontSize: 8,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 if (repost.hasImage &&
//                     repost.originalPostImage !=
//                         null)
//                   SizedBox(
//                     width: double.infinity,
//                     height: 220,
//                     child: Image.network(
//                       repost.originalPostImage!,
//                       fit: BoxFit.cover,
//                       errorBuilder: (
//                         context,
//                         error,
//                         stackTrace,
//                       ) {
//                         return Container(
//                           color: lightBlue,
//                           child: Icon(
//                             Icons.image_outlined,
//                             color:
//                                 primaryColor,
//                             size: 40,
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                 Padding(
//                   padding:
//                       const EdgeInsets.fromLTRB(
//                     11,
//                     11,
//                     11,
//                     12,
//                   ),
//                   child: Text(
//                     repost.originalContent,
//                     style: TextStyle(
//                       color: darkText,
//                       fontSize: 11,
//                       height: 1.42,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 9),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Row(
//             children: [
//               _buildActionButton(
//                 icon: isLiked
//                     ? Icons.favorite_rounded
//                     : Icons.favorite_border_rounded,
//                 text: _formatCount(likes),
//                 active: isLiked,
//                 onTap: () {
//                   _toggleLike(postId);
//                 },
//               ),

//               const SizedBox(width: 16),

//               _buildActionButton(
//                 icon:
//                     Icons.chat_bubble_outline_rounded,
//                 text:
//                     _formatCount(comments),
//                 onTap: () {
//                   _showComments(
//                     postId: postId,
//                   );
//                 },
//               ),

//               const SizedBox(width: 16),

//               GestureDetector(
//                 onTap: () {
//                   _repostPost(
//                     postId: postId,
//                     author:
//                         repost.originalAuthor,
//                     content:
//                         repost.originalContent,
//                     originalProfileImage:
//                         repost.originalProfileImage,
//                     originalTime:
//                         repost.originalTime,
//                     originalPostImage:
//                         repost.originalPostImage,
//                     category:
//                         repost.category,
//                     hasImage:
//                         repost.hasImage,
//                   );
//                 },
//                 behavior:
//                     HitTestBehavior.opaque,
//                 child: Row(
//                   mainAxisSize:
//                       MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.repeat_rounded,
//                       size: 18,
//                       color: isReposted
//                           ? primaryColor
//                           : Colors.grey.shade600,
//                     ),

//                     const SizedBox(width: 4),

//                     Text(
//                       'Repost',
//                       style: TextStyle(
//                         color: isReposted
//                             ? primaryColor
//                             : Colors.grey.shade600,
//                         fontSize: 10,
//                         fontWeight:
//                             isReposted
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Spacer(),

//               GestureDetector(
//                 onTap: () {
//                   _sharePost(
//                     author:
//                         repost.originalAuthor,
//                     content:
//                         repost.originalContent,
//                   );
//                 },
//                 behavior:
//                     HitTestBehavior.opaque,
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.all(4),
//                   child: Icon(
//                     Icons.share_outlined,
//                     size: 18,
//                     color:
//                         Colors.grey.shade600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // COMMUNITY POST WITH IMAGE
//   // ============================================================

//   Widget _buildCommunityPost({
//     required String postId,
//     required String profileImage,
//     required String author,
//     required String time,
//     required String postImage,
//     required String content,
//   }) {
//     final bool isLiked =
//         _likedPostIds.contains(postId);

//     final bool isReposted =
//         _repostedPostIds.contains(postId);

//     final int likes =
//         _likeCounts[postId] ?? 0;

//     final int comments =
//         _commentCounts[postId] ?? 0;

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFCFE8F0),
//           width: 1,
//         ),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // ==================================================
//           // POST HEADER
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               12,
//               11,
//               10,
//               10,
//             ),
//             child: Row(
//               children: [
//                 ClipOval(
//                   child: Image.network(
//                     profileImage,
//                     width: 34,
//                     height: 34,
//                     fit: BoxFit.cover,
//                     errorBuilder: (
//                       context,
//                       error,
//                       stackTrace,
//                     ) {
//                       return Container(
//                         width: 34,
//                         height: 34,
//                         color: lightBlue,
//                         child: Icon(
//                           Icons.person,
//                           color: primaryColor,
//                           size: 20,
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 9),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         author,
//                         maxLines: 2,
//                         overflow:
//                             TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: darkText,
//                           fontSize: 13,
//                           fontWeight:
//                               FontWeight.bold,
//                           height: 1.15,
//                         ),
//                       ),

//                       const SizedBox(height: 3),

//                       Text(
//                         time,
//                         style: TextStyle(
//                           color:
//                               Colors.grey.shade600,
//                           fontSize: 9,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Icon(
//                   Icons.more_horiz_rounded,
//                   color: Colors.grey.shade600,
//                   size: 20,
//                 ),
//               ],
//             ),
//           ),

//           // ==================================================
//           // POST IMAGE
//           // ==================================================

//           SizedBox(
//             width: double.infinity,
//             height: 274,
//             child: Image.network(
//               postImage,
//               fit: BoxFit.cover,
//               errorBuilder: (
//                 context,
//                 error,
//                 stackTrace,
//               ) {
//                 return Container(
//                   color: lightBlue,
//                   child: Icon(
//                     Icons.image_outlined,
//                     color: primaryColor,
//                     size: 45,
//                   ),
//                 );
//               },
//             ),
//           ),

//           // ==================================================
//           // CONTENT
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               13,
//               13,
//               13,
//               8,
//             ),
//             child: Text(
//               content,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 12,
//                 height: 1.42,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),

//           // ==================================================
//           // REPOST INDICATOR
//           // ==================================================

//           if (isReposted)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 13,
//                 0,
//                 13,
//                 8,
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.repeat_rounded,
//                     size: 14,
//                     color: primaryColor,
//                   ),
//                   const SizedBox(width: 5),
//                   Text(
//                     'You reposted this',
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//           // ==================================================
//           // DIVIDER
//           // ==================================================

//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(
//               horizontal: 13,
//             ),
//             child: Divider(
//               height: 1,
//               color: Colors.grey.shade200,
//             ),
//           ),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               13,
//               8,
//               13,
//               9,
//             ),
//             child: Row(
//               children: [
//                 _buildActionButton(
//                   icon: isLiked
//                       ? Icons.favorite_rounded
//                       : Icons.favorite_border_rounded,
//                   text:
//                       _formatCount(likes),
//                   active: isLiked,
//                   onTap: () {
//                     _toggleLike(postId);
//                   },
//                 ),

//                 const SizedBox(width: 16),

//                 _buildActionButton(
//                   icon:
//                       Icons.chat_bubble_outline_rounded,
//                   text:
//                       _formatCount(comments),
//                   onTap: () {
//                     _showComments(
//                       postId: postId,
//                     );
//                   },
//                 ),

//                 const SizedBox(width: 16),

//                 GestureDetector(
//                   onTap: () {
//                     _repostPost(
//                       postId: postId,
//                       author: author,
//                       content: content,
//                       originalProfileImage:
//                           profileImage,
//                       originalTime: time,
//                       originalPostImage:
//                           postImage,
//                       category:
//                           'Success Stories',
//                       hasImage: true,
//                     );
//                   },
//                   behavior:
//                       HitTestBehavior.opaque,
//                   child: Row(
//                     mainAxisSize:
//                         MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.repeat_rounded,
//                         size: 18,
//                         color: isReposted
//                             ? primaryColor
//                             : Colors.grey.shade600,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Repost',
//                         style: TextStyle(
//                           color: isReposted
//                               ? primaryColor
//                               : Colors.grey.shade600,
//                           fontSize: 10,
//                           fontWeight:
//                               isReposted
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const Spacer(),

//                 GestureDetector(
//                   onTap: () {
//                     _sharePost(
//                       author: author,
//                       content: content,
//                     );
//                   },
//                   behavior:
//                       HitTestBehavior.opaque,
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.all(4),
//                     child: Icon(
//                       Icons.share_outlined,
//                       size: 18,
//                       color:
//                           Colors.grey.shade600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // TEXT POST
//   // ============================================================

//   Widget _buildTextPost({
//     required String postId,
//     required String profileImage,
//     required String author,
//     required String time,
//     required String content,
//   }) {
//     final bool isLiked =
//         _likedPostIds.contains(postId);

//     final bool isReposted =
//         _repostedPostIds.contains(postId);

//     final int likes =
//         _likeCounts[postId] ?? 0;

//     final int comments =
//         _commentCounts[postId] ?? 0;

//     String category = 'Tips';

//     if (postId == 'my_future_pet') {
//       category = 'Announcements';
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(13),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFCFE8F0),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // ==================================================
//           // HEADER
//           // ==================================================

//           Row(
//             children: [
//               ClipOval(
//                 child: Image.network(
//                   profileImage,
//                   width: 34,
//                   height: 34,
//                   fit: BoxFit.cover,
//                   errorBuilder: (
//                     context,
//                     error,
//                     stackTrace,
//                   ) {
//                     return Container(
//                       width: 34,
//                       height: 34,
//                       color: lightBlue,
//                       child: Icon(
//                         Icons.person,
//                         color: primaryColor,
//                         size: 20,
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(width: 9),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       author,
//                       maxLines: 1,
//                       overflow:
//                           TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: darkText,
//                         fontSize: 13,
//                         fontWeight:
//                             FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 3),

//                     Text(
//                       time,
//                       style: TextStyle(
//                         color:
//                             Colors.grey.shade600,
//                         fontSize: 9,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Icon(
//                 Icons.more_horiz_rounded,
//                 color: Colors.grey.shade600,
//                 size: 20,
//               ),
//             ],
//           ),

//           const SizedBox(height: 14),

//           // ==================================================
//           // CONTENT
//           // ==================================================

//           Text(
//             content,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 12,
//               height: 1.45,
//             ),
//           ),

//           // ==================================================
//           // REPOST INDICATOR
//           // ==================================================

//           if (isReposted)
//             Padding(
//               padding:
//                   const EdgeInsets.only(
//                 top: 10,
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.repeat_rounded,
//                     size: 14,
//                     color: primaryColor,
//                   ),
//                   const SizedBox(width: 5),
//                   Text(
//                     'You reposted this',
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//           const SizedBox(height: 12),

//           // ==================================================
//           // DIVIDER
//           // ==================================================

//           Divider(
//             height: 1,
//             color: Colors.grey.shade200,
//           ),

//           const SizedBox(height: 8),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Row(
//             children: [
//               _buildActionButton(
//                 icon: isLiked
//                     ? Icons.favorite_rounded
//                     : Icons.favorite_border_rounded,
//                 text:
//                     _formatCount(likes),
//                 active: isLiked,
//                 onTap: () {
//                   _toggleLike(postId);
//                 },
//               ),

//               const SizedBox(width: 16),

//               _buildActionButton(
//                 icon:
//                     Icons.chat_bubble_outline_rounded,
//                 text:
//                     _formatCount(comments),
//                 onTap: () {
//                   _showComments(
//                     postId: postId,
//                   );
//                 },
//               ),

//               const SizedBox(width: 16),

//               GestureDetector(
//                 onTap: () {
//                   _repostPost(
//                     postId: postId,
//                     author: author,
//                     content: content,
//                     originalProfileImage:
//                         profileImage,
//                     originalTime: time,
//                     originalPostImage:
//                         null,
//                     category: category,
//                     hasImage: false,
//                   );
//                 },
//                 behavior:
//                     HitTestBehavior.opaque,
//                 child: Row(
//                   mainAxisSize:
//                       MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.repeat_rounded,
//                       size: 18,
//                       color: isReposted
//                           ? primaryColor
//                           : Colors.grey.shade600,
//                     ),

//                     const SizedBox(width: 4),

//                     Text(
//                       'Repost',
//                       style: TextStyle(
//                         color: isReposted
//                             ? primaryColor
//                             : Colors.grey.shade600,
//                         fontSize: 10,
//                         fontWeight:
//                             isReposted
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Spacer(),

//               GestureDetector(
//                 onTap: () {
//                   _sharePost(
//                     author: author,
//                     content: content,
//                   );
//                 },
//                 behavior:
//                     HitTestBehavior.opaque,
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.all(4),
//                   child: Icon(
//                     Icons.share_outlined,
//                     size: 18,
//                     color:
//                         Colors.grey.shade600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // ACTION BUTTON
//   // ============================================================

//   Widget _buildActionButton({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//     bool active = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       behavior:
//           HitTestBehavior.opaque,
//       child: Row(
//         mainAxisSize:
//             MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 16,
//             color: active
//                 ? primaryColor
//                 : Colors.grey.shade600,
//           ),

//           const SizedBox(width: 5),

//           Text(
//             text,
//             style: TextStyle(
//               color: active
//                   ? primaryColor
//                   : Colors.grey.shade600,
//               fontSize: 10,
//               fontWeight: active
//                   ? FontWeight.bold
//                   : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // LIKE / UNLIKE
//   // ============================================================

//   void _toggleLike(
//     String postId,
//   ) {
//     setState(() {
//       if (_likedPostIds.contains(postId)) {
//         _likedPostIds.remove(postId);

//         _likeCounts[postId] =
//             (_likeCounts[postId] ?? 0) - 1;
//       } else {
//         _likedPostIds.add(postId);

//         _likeCounts[postId] =
//             (_likeCounts[postId] ?? 0) + 1;
//       }
//     });
//   }

//   // ============================================================
//   // REPOST
//   // ============================================================

//   void _repostPost({
//     required String postId,
//     required String author,
//     required String content,
//     required String originalProfileImage,
//     required String originalTime,
//     required String? originalPostImage,
//     required String category,
//     required bool hasImage,
//   }) {
//     // ----------------------------------------------------------
//     // IF ALREADY REPOSTED
//     // REMOVE THE REPOST
//     // ----------------------------------------------------------

//     if (_repostedPostIds.contains(postId)) {
//       setState(() {
//         _repostedPostIds.remove(postId);

//         _repostedPosts.removeWhere(
//           (repost) =>
//               repost.originalPostId ==
//               postId,
//         );
//       });

//       _showMessage(
//         'Repost removed.',
//       );

//       return;
//     }

//     // ----------------------------------------------------------
//     // CREATE NEW REPOST
//     // ----------------------------------------------------------

//     final _RepostData newRepost =
//         _RepostData(
//       originalPostId: postId,

//       // IMPORTANT:
//       // This is the LOGGED-IN USER,
//       // NOT the original author.
//       reposterName:
//           _currentUserName,

//       reposterImage:
//           _currentUserImage,

//       originalProfileImage:
//           originalProfileImage,

//       originalAuthor:
//           author,

//       originalTime:
//           originalTime,

//       originalContent:
//           content,

//       originalPostImage:
//           originalPostImage,

//       hasImage:
//           hasImage,

//       category:
//           category,
//     );

//     setState(() {
//       _repostedPostIds.add(postId);

//       // INSERT AT THE TOP.
//       _repostedPosts.insert(
//         0,
//         newRepost,
//       );
//     });

//     _showMessage(
//       'Post reposted to the top of your feed.',
//     );
//   }

//   // ============================================================
//   // COMMENTS
//   // ============================================================

//   // ============================================================
// // COMMENTS
// // ============================================================

// void _showComments({
//   required String postId,
// }) {
//   _comments.putIfAbsent(
//     postId,
//     () => <String>[],
//   );

//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     useSafeArea: true,
//     builder: (_) {
//       return _CommentsBottomSheet(
//         primaryColor: primaryColor,
//         backgroundColor: backgroundColor,
//         lightBlue: lightBlue,
//         darkText: darkText,
//         comments: _comments[postId] ?? <String>[],
//         totalComments: _commentCounts[postId] ?? 0,
//         onCommentAdded: (String comment) {
//           if (!mounted) return;

//           setState(() {
//             _comments[postId] ??= <String>[];

//             _comments[postId]!.add(comment);

//             _commentCounts[postId] =
//                 (_commentCounts[postId] ?? 0) + 1;
//           });
//         },
//       );
//     },
//   );
// }

//   // ============================================================
//   // EXTERNAL SHARE
//   // ============================================================

//   Future<void> _sharePost({
//     required String author,
//     required String content,
//   }) async {
//     try {
//       await SharePlus.instance.share(
//         ShareParams(
//           title:
//               'My Future Pet Community',
//           text:
//               '$author\n\n$content\n\nShared from My Future Pet Community',
//         ),
//       );
//     } catch (e) {
//       _showMessage(
//         'Unable to share this post.',
//       );
//     }
//   }

//   // ============================================================
//   // FORMAT COUNT
//   // ============================================================

//   String _formatCount(
//     int count,
//   ) {
//     if (count >= 1000000) {
//       return '${(count / 1000000).toStringAsFixed(1)}M';
//     }

//     if (count >= 1000) {
//       final String value =
//           (count / 1000).toStringAsFixed(1);

//       if (value.endsWith('.0')) {
//         return '${value.substring(
//           0,
//           value.length - 2,
//         )}k';
//       }

//       return '${value}k';
//     }

//     return count.toString();
//   }

//   // ============================================================
//   // FLOATING CREATE POST BUTTON
//   // ============================================================

//   Widget _buildCreatePostButton() {
//     return GestureDetector(
//       onTap: () {
//         _showCreatePostDialog();
//       },
//       child: Container(
//         width: 49,
//         height: 49,
//         decoration: BoxDecoration(
//           color: primaryColor,
//           borderRadius:
//               BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color:
//                   Colors.black.withOpacity(
//                 0.18,
//               ),
//               blurRadius: 7,
//               offset:
//                   const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: const Icon(
//           Icons.edit_rounded,
//           color: Colors.white,
//           size: 19,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY FEED
//   // ============================================================

//   Widget _buildEmptyFeed() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.only(
//           top: 70,
//           left: 20,
//           right: 20,
//         ),
//         child: Column(
//           children: [
//             Icon(
//               Icons.forum_outlined,
//               size: 55,
//               color: primaryColor,
//             ),

//             const SizedBox(
//               height: 15,
//             ),

//             Text(
//               'No posts found',
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 19,
//                 fontWeight:
//                     FontWeight.bold,
//               ),
//             ),

//             const SizedBox(
//               height: 6,
//             ),

//             Text(
//               'There are no posts in this category yet.',
//               textAlign:
//                   TextAlign.center,
//               style: TextStyle(
//                 color:
//                     Colors.grey.shade600,
//                 fontSize: 12,
//               ),
//             ),

//             const SizedBox(
//               height: 18,
//             ),

//             OutlinedButton(
//               onPressed: () {
//                 setState(() {
//                   selectedCategory =
//                       'All';
//                 });
//               },
//               style:
//                   OutlinedButton.styleFrom(
//                 foregroundColor:
//                     primaryColor,
//                 side: BorderSide(
//                   color: primaryColor,
//                 ),
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(
//                     20,
//                   ),
//                 ),
//               ),
//               child: const Text(
//                 'View All Posts',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CREATE POST DIALOG
//   // ============================================================

//   void _showCreatePostDialog() {
//     final TextEditingController
//         controller =
//         TextEditingController();

//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor:
//               Colors.white,
//           shape:
//               RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(
//               18,
//             ),
//           ),
//           title: Text(
//             'Create Post',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 19,
//               fontWeight:
//                   FontWeight.bold,
//             ),
//           ),
//           content: TextField(
//             controller: controller,
//             maxLines: 5,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 13,
//             ),
//             decoration:
//                 InputDecoration(
//               hintText:
//                   'Share something with the community...',
//               hintStyle: TextStyle(
//                 color:
//                     Colors.grey.shade500,
//                 fontSize: 12,
//               ),
//               filled: true,
//               fillColor:
//                   backgroundColor,
//               border:
//                   OutlineInputBorder(
//                 borderRadius:
//                     BorderRadius.circular(
//                   12,
//                 ),
//                 borderSide:
//                     BorderSide.none,
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                 );
//               },
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color:
//                       Colors.grey.shade600,
//                 ),
//               ),
//             ),

//             ElevatedButton(
//               onPressed: () {
//                 if (controller.text
//                     .trim()
//                     .isEmpty) {
//                   return;
//                 }

//                 Navigator.pop(
//                   dialogContext,
//                 );

//                 _showMessage(
//                   'Post created successfully!',
//                 );
//               },
//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     primaryColor,
//                 foregroundColor:
//                     Colors.white,
//                 elevation: 0,
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(
//                     18,
//                   ),
//                 ),
//               ),
//               child:
//                   const Text(
//                 'Post',
//               ),
//             ),
//           ],
//         );
//       },
//     ).whenComplete(
//       controller.dispose,
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior:
//             SnackBarBehavior.floating,
//         duration:
//             const Duration(
//           seconds: 2,
//         ),
//       ),
//     );
//   }
// }
















































// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';

// // ============================================================
// // COMMUNITY FEED SCREEN
// // ============================================================

// class FeedScreen extends StatefulWidget {
//   const FeedScreen({
//     super.key,
//   });

//   @override
//   State<FeedScreen> createState() => _FeedScreenState();
// }

// class _FeedScreenState extends State<FeedScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color darkText = const Color(0xFF062B35);

//   final Color backgroundColor = const Color(0xFFEFF9FD);
//   final Color lightBlue = const Color(0xFFE4F5FB);

//   // ============================================================
//   // CATEGORY
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Success Stories',
//     'Announcements',
//     'Tips',
//   ];

//   // ============================================================
//   // POST INTERACTION DATA
//   // ============================================================

//   // Stores which posts the current user has liked.
//   final Set<String> _likedPostIds = {};

//   // Stores which posts the current user has reposted.
//   final Set<String> _repostedPostIds = {};

//   // Like counts.
//   final Map<String, int> _likeCounts = {
//     'luna_success': 1200,
//     'joe_foster': 45,
//     'my_future_pet': 86,
//   };

//   // Comment counts.
//   final Map<String, int> _commentCounts = {
//     'luna_success': 84,
//     'joe_foster': 12,
//     'my_future_pet': 18,
//   };

//   // New comments added during the current app session.
//   final Map<String, List<String>> _comments = {
//     'luna_success': [],
//     'joe_foster': [],
//     'my_future_pet': [],
//   };

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             _buildCategoryBar(),

//             Expanded(
//               child: Stack(
//                 children: [
//                   _buildFeed(),

//                   Positioned(
//                     right: 14,
//                     bottom: 18,
//                     child: _buildCreatePostButton(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       color: backgroundColor,
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         8,
//         14,
//         8,
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               border: Border.all(
//                 color: const Color(0xFFD9E4E7),
//                 width: 1,
//               ),
//             ),
//             child: ClipOval(
//               child: Image.network(
//                 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=200',
//                 fit: BoxFit.cover,
//                 errorBuilder: (
//                   context,
//                   error,
//                   stackTrace,
//                 ) {
//                   return Icon(
//                     Icons.pets_rounded,
//                     color: primaryColor,
//                     size: 20,
//                   );
//                 },
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           Expanded(
//             child: Text(
//               'Community',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 25,
//                 fontWeight: FontWeight.bold,
//                 height: 1,
//               ),
//             ),
//           ),

//           IconButton(
//             onPressed: () {
//               _showMessage(
//                 'No new notifications.',
//               );
//             },
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 34,
//               minHeight: 34,
//             ),
//             icon: Icon(
//               Icons.notifications_none_rounded,
//               color: primaryColor,
//               size: 21,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY BAR
//   // ============================================================

//   Widget _buildCategoryBar() {
//     return Container(
//       width: double.infinity,
//       color: backgroundColor,
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         2,
//         0,
//         10,
//       ),
//       child: SizedBox(
//         height: 34,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           physics: const BouncingScrollPhysics(),
//           itemCount: categories.length,
//           separatorBuilder: (
//             context,
//             index,
//           ) {
//             return const SizedBox(width: 7);
//           },
//           itemBuilder: (
//             context,
//             index,
//           ) {
//             final String category =
//                 categories[index];

//             final bool selected =
//                 selectedCategory == category;

//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(
//                   milliseconds: 180,
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(
//                   horizontal: 16,
//                 ),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? primaryColor
//                       : Colors.white,
//                   borderRadius:
//                       BorderRadius.circular(20),
//                   border: Border.all(
//                     color: selected
//                         ? primaryColor
//                         : const Color(0xFF8E7771),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected
//                         ? Colors.white
//                         : darkText,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FEED
//   // ============================================================

//   Widget _buildFeed() {
//     final List<Widget> posts = [];

//     // ==========================================================
//     // FIRST POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Success Stories') {
//       posts.add(
//         _buildCommunityPost(
//           postId: 'luna_success',
//           profileImage:
//               'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?auto=format&fit=crop&w=200&q=80',
//           author:
//               'JAGNA ANIMAL LOVER AND RESCUE GROUP Admin',
//           time: '2 hours ago',
//           postImage:
//               'https://images.unsplash.com/photo-1542736667-069246bdbc74?auto=format&fit=crop&w=900&q=80',
//           content:
//               'Luna has finally found her forever home! After 6 months at the shelter, this sweet girl is going to her new loving family. Thank you to everyone who shared her story. ❤️\n#AdoptionSuccess #HappyTails',
//         ),
//       );

//       posts.add(
//         const SizedBox(height: 12),
//       );
//     }

//     // ==========================================================
//     // SECOND POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Tips') {
//       posts.add(
//         _buildTextPost(
//           postId: 'joe_foster',
//           profileImage:
//               'https://i.pravatar.cc/150?img=47',
//           author: 'JoeAss',
//           time: '5 hours ago',
//           content:
//               'Hi everyone! We just brought home our new foster puppy, Max. He’s a bit anxious around our older dog. Any tips for smooth introductions over the first few days? 🐶',
//         ),
//       );

//       posts.add(
//         const SizedBox(height: 12),
//       );
//     }

//     // ==========================================================
//     // THIRD POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Announcements') {
//       posts.add(
//         _buildTextPost(
//           postId: 'my_future_pet',
//           profileImage:
//               'https://i.pravatar.cc/150?img=32',
//           author: 'My Future Pet',
//           time: '1 day ago',
//           content:
//               'Remember that adopting a pet is a lifetime commitment. Give your new companion time, patience, and lots of love while they adjust to their new home. 🐾',
//         ),
//       );
//     }

//     // ==========================================================
//     // NO POSTS
//     // ==========================================================

//     if (posts.isEmpty) {
//       return _buildEmptyFeed();
//     }

//     return ListView(
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         2,
//         14,
//         85,
//       ),
//       children: posts,
//     );
//   }

//   // ============================================================
//   // COMMUNITY POST WITH IMAGE
//   // ============================================================

//   Widget _buildCommunityPost({
//     required String postId,
//     required String profileImage,
//     required String author,
//     required String time,
//     required String postImage,
//     required String content,
//   }) {
//     final bool isLiked =
//         _likedPostIds.contains(postId);

//     final bool isReposted =
//         _repostedPostIds.contains(postId);

//     final int likes =
//         _likeCounts[postId] ?? 0;

//     final int comments =
//         _commentCounts[postId] ?? 0;

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFCFE8F0),
//           width: 1,
//         ),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // ==================================================
//           // POST HEADER
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               12,
//               11,
//               10,
//               10,
//             ),
//             child: Row(
//               children: [
//                 ClipOval(
//                   child: Image.network(
//                     profileImage,
//                     width: 34,
//                     height: 34,
//                     fit: BoxFit.cover,
//                     errorBuilder: (
//                       context,
//                       error,
//                       stackTrace,
//                     ) {
//                       return Container(
//                         width: 34,
//                         height: 34,
//                         color: lightBlue,
//                         child: Icon(
//                           Icons.person,
//                           color: primaryColor,
//                           size: 20,
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 9),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         author,
//                         maxLines: 2,
//                         overflow:
//                             TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: darkText,
//                           fontSize: 13,
//                           fontWeight:
//                               FontWeight.bold,
//                           height: 1.15,
//                         ),
//                       ),

//                       const SizedBox(height: 3),

//                       Text(
//                         time,
//                         style: TextStyle(
//                           color:
//                               Colors.grey.shade600,
//                           fontSize: 9,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Icon(
//                   Icons.more_horiz_rounded,
//                   color: Colors.grey.shade600,
//                   size: 20,
//                 ),
//               ],
//             ),
//           ),

//           // ==================================================
//           // POST IMAGE
//           // ==================================================

//           SizedBox(
//             width: double.infinity,
//             height: 274,
//             child: Image.network(
//               postImage,
//               fit: BoxFit.cover,
//               errorBuilder: (
//                 context,
//                 error,
//                 stackTrace,
//               ) {
//                 return Container(
//                   color: lightBlue,
//                   child: Icon(
//                     Icons.image_outlined,
//                     color: primaryColor,
//                     size: 45,
//                   ),
//                 );
//               },
//             ),
//           ),

//           // ==================================================
//           // CONTENT
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               13,
//               13,
//               13,
//               8,
//             ),
//             child: Text(
//               content,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 12,
//                 height: 1.42,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),

//           // ==================================================
//           // REPOST INDICATOR
//           // ==================================================

//           if (isReposted)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 13,
//                 0,
//                 13,
//                 8,
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.repeat_rounded,
//                     size: 14,
//                     color: primaryColor,
//                   ),
//                   const SizedBox(width: 5),
//                   Text(
//                     'You reposted this',
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//           // ==================================================
//           // DIVIDER
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 13,
//             ),
//             child: Divider(
//               height: 1,
//               color: Colors.grey.shade200,
//             ),
//           ),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               13,
//               8,
//               13,
//               9,
//             ),
//             child: Row(
//               children: [
//                 // ❤️ LIKE
//                 _buildActionButton(
//                   icon: isLiked
//                       ? Icons.favorite_rounded
//                       : Icons.favorite_border_rounded,
//                   text: _formatCount(likes),
//                   active: isLiked,
//                   onTap: () {
//                     _toggleLike(postId);
//                   },
//                 ),

//                 const SizedBox(width: 16),

//                 // 💬 COMMENT
//                 _buildActionButton(
//                   icon:
//                       Icons.chat_bubble_outline_rounded,
//                   text: _formatCount(comments),
//                   onTap: () {
//                     _showComments(
//                       postId: postId,
//                     );
//                   },
//                 ),

//                 const SizedBox(width: 16),

//                 // 🔁 REPOST
//                 GestureDetector(
//                   onTap: () {
//                     _repostPost(
//                       postId: postId,
//                       author: author,
//                       content: content,
//                     );
//                   },
//                   behavior: HitTestBehavior.opaque,
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.repeat_rounded,
//                         size: 18,
//                         color: isReposted
//                             ? primaryColor
//                             : Colors.grey.shade600,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Repost',
//                         style: TextStyle(
//                           color: isReposted
//                               ? primaryColor
//                               : Colors.grey.shade600,
//                           fontSize: 10,
//                           fontWeight: isReposted
//                               ? FontWeight.bold
//                               : FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const Spacer(),

//                 // ↗️ EXTERNAL SHARE
//                 GestureDetector(
//                   onTap: () {
//                     _sharePost(
//                       author: author,
//                       content: content,
//                     );
//                   },
//                   behavior: HitTestBehavior.opaque,
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.all(4),
//                     child: Icon(
//                       Icons.share_outlined,
//                       size: 18,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // TEXT POST
//   // ============================================================

//   Widget _buildTextPost({
//     required String postId,
//     required String profileImage,
//     required String author,
//     required String time,
//     required String content,
//   }) {
//     final bool isLiked =
//         _likedPostIds.contains(postId);

//     final bool isReposted =
//         _repostedPostIds.contains(postId);

//     final int likes =
//         _likeCounts[postId] ?? 0;

//     final int comments =
//         _commentCounts[postId] ?? 0;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(13),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFCFE8F0),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // ==================================================
//           // HEADER
//           // ==================================================

//           Row(
//             children: [
//               ClipOval(
//                 child: Image.network(
//                   profileImage,
//                   width: 34,
//                   height: 34,
//                   fit: BoxFit.cover,
//                   errorBuilder: (
//                     context,
//                     error,
//                     stackTrace,
//                   ) {
//                     return Container(
//                       width: 34,
//                       height: 34,
//                       color: lightBlue,
//                       child: Icon(
//                         Icons.person,
//                         color: primaryColor,
//                         size: 20,
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(width: 9),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       author,
//                       maxLines: 1,
//                       overflow:
//                           TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: darkText,
//                         fontSize: 13,
//                         fontWeight:
//                             FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 3),

//                     Text(
//                       time,
//                       style: TextStyle(
//                         color:
//                             Colors.grey.shade600,
//                         fontSize: 9,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Icon(
//                 Icons.more_horiz_rounded,
//                 color: Colors.grey.shade600,
//                 size: 20,
//               ),
//             ],
//           ),

//           const SizedBox(height: 14),

//           // ==================================================
//           // CONTENT
//           // ==================================================

//           Text(
//             content,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 12,
//               height: 1.45,
//             ),
//           ),

//           // ==================================================
//           // REPOST INDICATOR
//           // ==================================================

//           if (isReposted)
//             Padding(
//               padding: const EdgeInsets.only(
//                 top: 10,
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.repeat_rounded,
//                     size: 14,
//                     color: primaryColor,
//                   ),
//                   const SizedBox(width: 5),
//                   Text(
//                     'You reposted this',
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//           const SizedBox(height: 12),

//           // ==================================================
//           // DIVIDER
//           // ==================================================

//           Divider(
//             height: 1,
//             color: Colors.grey.shade200,
//           ),

//           const SizedBox(height: 8),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Row(
//             children: [
//               // ❤️ LIKE
//               _buildActionButton(
//                 icon: isLiked
//                     ? Icons.favorite_rounded
//                     : Icons.favorite_border_rounded,
//                 text: _formatCount(likes),
//                 active: isLiked,
//                 onTap: () {
//                   _toggleLike(postId);
//                 },
//               ),

//               const SizedBox(width: 16),

//               // 💬 COMMENT
//               _buildActionButton(
//                 icon:
//                     Icons.chat_bubble_outline_rounded,
//                 text: _formatCount(comments),
//                 onTap: () {
//                   _showComments(
//                     postId: postId,
//                   );
//                 },
//               ),

//               const SizedBox(width: 16),

//               // 🔁 REPOST
//               GestureDetector(
//                 onTap: () {
//                   _repostPost(
//                     postId: postId,
//                     author: author,
//                     content: content,
//                   );
//                 },
//                 behavior: HitTestBehavior.opaque,
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.repeat_rounded,
//                       size: 18,
//                       color: isReposted
//                           ? primaryColor
//                           : Colors.grey.shade600,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Repost',
//                       style: TextStyle(
//                         color: isReposted
//                             ? primaryColor
//                             : Colors.grey.shade600,
//                         fontSize: 10,
//                         fontWeight: isReposted
//                             ? FontWeight.bold
//                             : FontWeight.normal,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Spacer(),

//               // ↗️ EXTERNAL SHARE
//               GestureDetector(
//                 onTap: () {
//                   _sharePost(
//                     author: author,
//                     content: content,
//                   );
//                 },
//                 behavior: HitTestBehavior.opaque,
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.all(4),
//                   child: Icon(
//                     Icons.share_outlined,
//                     size: 18,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // ACTION BUTTON
//   // ============================================================

//   Widget _buildActionButton({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//     bool active = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       behavior: HitTestBehavior.opaque,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 16,
//             color: active
//                 ? primaryColor
//                 : Colors.grey.shade600,
//           ),

//           const SizedBox(width: 5),

//           Text(
//             text,
//             style: TextStyle(
//               color: active
//                   ? primaryColor
//                   : Colors.grey.shade600,
//               fontSize: 10,
//               fontWeight: active
//                   ? FontWeight.bold
//                   : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // LIKE / UNLIKE
//   // ============================================================

//   void _toggleLike(String postId) {
//     setState(() {
//       if (_likedPostIds.contains(postId)) {
//         _likedPostIds.remove(postId);

//         _likeCounts[postId] =
//             (_likeCounts[postId] ?? 0) - 1;
//       } else {
//         _likedPostIds.add(postId);

//         _likeCounts[postId] =
//             (_likeCounts[postId] ?? 0) + 1;
//       }
//     });
//   }

//   // ============================================================
//   // REPOST
//   // ============================================================

//   void _repostPost({
//     required String postId,
//     required String author,
//     required String content,
//   }) {
//     setState(() {
//       if (_repostedPostIds.contains(postId)) {
//         _repostedPostIds.remove(postId);
//       } else {
//         _repostedPostIds.add(postId);
//       }
//     });

//     final bool isReposted =
//         _repostedPostIds.contains(postId);

//     _showMessage(
//       isReposted
//           ? 'Post reposted to your community feed.'
//           : 'Repost removed.',
//     );
//   }

//   // ============================================================
//   // COMMENTS
//   // ============================================================

//   void _showComments({
//     required String postId,
//   }) {
//     final TextEditingController controller =
//         TextEditingController();

//     _comments.putIfAbsent(
//       postId,
//       () => <String>[],
//     );

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       useSafeArea: true,
//       builder: (sheetContext) {
//         return StatefulBuilder(
//           builder: (
//             context,
//             setSheetState,
//           ) {
//             final List<String> postComments =
//                 _comments[postId] ?? <String>[];

//             final int totalComments =
//                 _commentCounts[postId] ?? 0;

//             return Container(
//               height:
//                   MediaQuery.of(context).size.height *
//                       0.65,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(
//                   top: Radius.circular(24),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   // ==================================================
//                   // HANDLE
//                   // ==================================================

//                   const SizedBox(height: 10),

//                   Container(
//                     width: 42,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color:
//                           const Color(0xFFD7DEE0),
//                       borderRadius:
//                           BorderRadius.circular(10),
//                     ),
//                   ),

//                   // ==================================================
//                   // HEADER
//                   // ==================================================

//                   Padding(
//                     padding:
//                         const EdgeInsets.fromLTRB(
//                       18,
//                       15,
//                       14,
//                       12,
//                     ),
//                     child: Row(
//                       children: [
//                         const Expanded(
//                           child: Text(
//                             'Comments',
//                             style: TextStyle(
//                               color:
//                                   Color(0xFF062B35),
//                               fontSize: 19,
//                               fontWeight:
//                                   FontWeight.bold,
//                             ),
//                           ),
//                         ),

//                         Text(
//                           '$totalComments',
//                           style: TextStyle(
//                             color:
//                                 Colors.grey.shade600,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   Divider(
//                     height: 1,
//                     color: Colors.grey.shade200,
//                   ),

//                   // ==================================================
//                   // COMMENT LIST
//                   // ==================================================

//                   Expanded(
//                     child: postComments.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisSize:
//                                   MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons
//                                       .chat_bubble_outline_rounded,
//                                   size: 45,
//                                   color:
//                                       primaryColor,
//                                 ),

//                                 const SizedBox(
//                                   height: 10,
//                                 ),

//                                 const Text(
//                                   'No comments yet',
//                                   style: TextStyle(
//                                     color:
//                                         Color(
//                                       0xFF062B35,
//                                     ),
//                                     fontSize: 15,
//                                     fontWeight:
//                                         FontWeight
//                                             .bold,
//                                   ),
//                                 ),

//                                 const SizedBox(
//                                   height: 4,
//                                 ),

//                                 Text(
//                                   'Be the first to comment.',
//                                   style: TextStyle(
//                                     color:
//                                         Colors
//                                             .grey
//                                             .shade600,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : ListView.builder(
//                             physics:
//                                 const BouncingScrollPhysics(),
//                             padding:
//                                 const EdgeInsets
//                                     .all(15),
//                             itemCount:
//                                 postComments.length,
//                             itemBuilder:
//                                 (
//                               context,
//                               index,
//                             ) {
//                               final String comment =
//                                   postComments[index];

//                               return Container(
//                                 margin:
//                                     const EdgeInsets
//                                         .only(
//                                   bottom: 10,
//                                 ),
//                                 padding:
//                                     const EdgeInsets
//                                         .all(
//                                   11,
//                                 ),
//                                 decoration:
//                                     BoxDecoration(
//                                   color:
//                                       backgroundColor,
//                                   borderRadius:
//                                       BorderRadius
//                                           .circular(
//                                     14,
//                                   ),
//                                 ),
//                                 child: Row(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment
//                                           .start,
//                                   children: [
//                                     CircleAvatar(
//                                       radius: 16,
//                                       backgroundColor:
//                                           lightBlue,
//                                       child: Icon(
//                                         Icons.person,
//                                         size: 18,
//                                         color:
//                                             primaryColor,
//                                       ),
//                                     ),

//                                     const SizedBox(
//                                       width: 9,
//                                     ),

//                                     Expanded(
//                                       child: Text(
//                                         comment,
//                                         style:
//                                             const TextStyle(
//                                           color:
//                                               Color(
//                                             0xFF062B35,
//                                           ),
//                                           fontSize: 12,
//                                           height: 1.4,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                   ),

//                   // ==================================================
//                   // COMMENT INPUT
//                   // ==================================================

//                   Container(
//                     padding: EdgeInsets.fromLTRB(
//                       12,
//                       8,
//                       12,
//                       MediaQuery.of(context)
//                               .viewInsets
//                               .bottom +
//                           10,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color:
//                               Colors.black.withOpacity(
//                             0.06,
//                           ),
//                           blurRadius: 8,
//                           offset:
//                               const Offset(0, -2),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.end,
//                       children: [
//                         // TEXT FIELD

//                         Expanded(
//                           child: TextField(
//                             controller: controller,
//                             minLines: 1,
//                             maxLines: 4,
//                             keyboardType:
//                                 TextInputType.multiline,
//                             textCapitalization:
//                                 TextCapitalization
//                                     .sentences,
//                             decoration:
//                                 InputDecoration(
//                               hintText:
//                                   'Write a comment...',
//                               hintStyle: TextStyle(
//                                 color:
//                                     Colors.grey.shade500,
//                                 fontSize: 12,
//                               ),
//                               filled: true,
//                               fillColor:
//                                   backgroundColor,
//                               contentPadding:
//                                   const EdgeInsets
//                                       .symmetric(
//                                 horizontal: 14,
//                                 vertical: 11,
//                               ),
//                               border:
//                                   OutlineInputBorder(
//                                 borderRadius:
//                                     BorderRadius
//                                         .circular(
//                                   22,
//                                 ),
//                                 borderSide:
//                                     BorderSide.none,
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 8),

//                         // SEND BUTTON

//                         GestureDetector(
//                           onTap: () {
//                             final String comment =
//                                 controller.text.trim();

//                             if (comment.isEmpty) {
//                               return;
//                             }

//                             _comments[postId]!.add(
//                               comment,
//                             );

//                             _commentCounts[postId] =
//                                 (_commentCounts[
//                                             postId] ??
//                                         0) +
//                                     1;

//                             controller.clear();

//                             setSheetState(() {});
//                           },
//                           child: Container(
//                             width: 43,
//                             height: 43,
//                             decoration:
//                                 BoxDecoration(
//                               color: primaryColor,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.send_rounded,
//                               color: Colors.white,
//                               size: 18,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     ).whenComplete(
//       controller.dispose,
//     );
//   }

//   // ============================================================
//   // EXTERNAL SHARE
//   // ============================================================

//   Future<void> _sharePost({
//     required String author,
//     required String content,
//   }) async {
//     try {
//       await SharePlus.instance.share(
//         ShareParams(
//           title: 'My Future Pet Community',
//           text:
//               '$author\n\n$content\n\nShared from My Future Pet Community',
//         ),
//       );
//     } catch (e) {
//       _showMessage(
//         'Unable to share this post.',
//       );
//     }
//   }

//   // ============================================================
//   // FORMAT COUNT
//   // ============================================================

//   String _formatCount(int count) {
//     if (count >= 1000000) {
//       return '${(count / 1000000).toStringAsFixed(1)}M';
//     }

//     if (count >= 1000) {
//       final String value =
//           (count / 1000).toStringAsFixed(1);

//       if (value.endsWith('.0')) {
//         return '${value.substring(
//           0,
//           value.length - 2,
//         )}k';
//       }

//       return '${value}k';
//     }

//     return count.toString();
//   }

//   // ============================================================
//   // FLOATING CREATE POST BUTTON
//   // ============================================================

//   Widget _buildCreatePostButton() {
//     return GestureDetector(
//       onTap: () {
//         _showCreatePostDialog();
//       },
//       child: Container(
//         width: 49,
//         height: 49,
//         decoration: BoxDecoration(
//           color: primaryColor,
//           borderRadius:
//               BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color:
//                   Colors.black.withOpacity(0.18),
//               blurRadius: 7,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: const Icon(
//           Icons.edit_rounded,
//           color: Colors.white,
//           size: 19,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY FEED
//   // ============================================================

//   Widget _buildEmptyFeed() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.only(
//           top: 70,
//           left: 20,
//           right: 20,
//         ),
//         child: Column(
//           children: [
//             Icon(
//               Icons.forum_outlined,
//               size: 55,
//               color: primaryColor,
//             ),

//             const SizedBox(height: 15),

//             Text(
//               'No posts found',
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 19,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 6),

//             Text(
//               'There are no posts in this category yet.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 12,
//               ),
//             ),

//             const SizedBox(height: 18),

//             OutlinedButton(
//               onPressed: () {
//                 setState(() {
//                   selectedCategory = 'All';
//                 });
//               },
//               style:
//                   OutlinedButton.styleFrom(
//                 foregroundColor:
//                     primaryColor,
//                 side: BorderSide(
//                   color: primaryColor,
//                 ),
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(20),
//                 ),
//               ),
//               child: const Text(
//                 'View All Posts',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CREATE POST DIALOG
//   // ============================================================

//   void _showCreatePostDialog() {
//     final TextEditingController controller =
//         TextEditingController();

//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape:
//               RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(18),
//           ),
//           title: Text(
//             'Create Post',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 19,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: TextField(
//             controller: controller,
//             maxLines: 5,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 13,
//             ),
//             decoration:
//                 InputDecoration(
//               hintText:
//                   'Share something with the community...',
//               hintStyle: TextStyle(
//                 color: Colors.grey.shade500,
//                 fontSize: 12,
//               ),
//               filled: true,
//               fillColor: backgroundColor,
//               border:
//                   OutlineInputBorder(
//                 borderRadius:
//                     BorderRadius.circular(12),
//                 borderSide:
//                     BorderSide.none,
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                 );
//               },
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color:
//                       Colors.grey.shade600,
//                 ),
//               ),
//             ),

//             ElevatedButton(
//               onPressed: () {
//                 if (controller.text
//                     .trim()
//                     .isEmpty) {
//                   return;
//                 }

//                 Navigator.pop(
//                   dialogContext,
//                 );

//                 _showMessage(
//                   'Post created successfully!',
//                 );
//               },
//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     primaryColor,
//                 foregroundColor:
//                     Colors.white,
//                 elevation: 0,
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(
//                     18,
//                   ),
//                 ),
//               ),
//               child: const Text(
//                 'Post',
//               ),
//             ),
//           ],
//         );
//       },
//     ).whenComplete(
//       controller.dispose,
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior:
//             SnackBarBehavior.floating,
//         duration:
//             const Duration(seconds: 2),
//       ),
//     );
//   }
// }









































// import 'package:flutter/material.dart';

// // ============================================================
// // COMMUNITY FEED SCREEN
// // ============================================================

// class FeedScreen extends StatefulWidget {
//   const FeedScreen({
//     super.key,
//   });

//   @override
//   State<FeedScreen> createState() => _FeedScreenState();
// }

// class _FeedScreenState extends State<FeedScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color darkText = const Color(0xFF062B35);

//   final Color backgroundColor = const Color(0xFFEFF9FD);
//   final Color lightBlue = const Color(0xFFE4F5FB);

//   // ============================================================
//   // CATEGORY
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Success Stories',
//     'Announcements',
//     'Tips',
//   ];

//   // ============================================================
//   // POST INTERACTION DATA
//   // ============================================================

//   // Stores which posts the current user has liked.
//   final Set<String> _likedPostIds = {};

//   // Stores which posts the current user has reposted.
//   final Set<String> _repostedPostIds = {};

//   // Like counts.
//   final Map<String, int> _likeCounts = {
//     'luna_success': 1200,
//     'joe_foster': 45,
//     'my_future_pet': 86,
//   };

//   // Comment counts.
//   final Map<String, int> _commentCounts = {
//     'luna_success': 84,
//     'joe_foster': 12,
//     'my_future_pet': 18,
//   };

//   // Repost counts.
//   final Map<String, int> _repostCounts = {
//     'luna_success': 24,
//     'joe_foster': 7,
//     'my_future_pet': 11,
//   };

//   // New comments added during the current app session.
//   final Map<String, List<String>> _comments = {
//     'luna_success': [],
//     'joe_foster': [],
//     'my_future_pet': [],
//   };

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             _buildCategoryBar(),

//             Expanded(
//               child: Stack(
//                 children: [
//                   _buildFeed(),

//                   Positioned(
//                     right: 14,
//                     bottom: 18,
//                     child: _buildCreatePostButton(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       color: backgroundColor,
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         8,
//         14,
//         8,
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               border: Border.all(
//                 color: const Color(0xFFD9E4E7),
//                 width: 1,
//               ),
//             ),
//             child: ClipOval(
//               child: Image.network(
//                 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=200',
//                 fit: BoxFit.cover,
//                 errorBuilder: (
//                   context,
//                   error,
//                   stackTrace,
//                 ) {
//                   return Icon(
//                     Icons.pets_rounded,
//                     color: primaryColor,
//                     size: 20,
//                   );
//                 },
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           Expanded(
//             child: Text(
//               'Community',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 25,
//                 fontWeight: FontWeight.bold,
//                 height: 1,
//               ),
//             ),
//           ),

//           IconButton(
//             onPressed: () {
//               _showMessage(
//                 'No new notifications.',
//               );
//             },
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 34,
//               minHeight: 34,
//             ),
//             icon: Icon(
//               Icons.notifications_none_rounded,
//               color: primaryColor,
//               size: 21,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY BAR
//   // ============================================================

//   Widget _buildCategoryBar() {
//     return Container(
//       width: double.infinity,
//       color: backgroundColor,
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         2,
//         0,
//         10,
//       ),
//       child: SizedBox(
//         height: 34,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           physics: const BouncingScrollPhysics(),
//           itemCount: categories.length,
//           separatorBuilder: (
//             context,
//             index,
//           ) {
//             return const SizedBox(width: 7);
//           },
//           itemBuilder: (
//             context,
//             index,
//           ) {
//             final String category =
//                 categories[index];

//             final bool selected =
//                 selectedCategory == category;

//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(
//                   milliseconds: 180,
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(
//                   horizontal: 16,
//                 ),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? primaryColor
//                       : Colors.white,
//                   borderRadius:
//                       BorderRadius.circular(20),
//                   border: Border.all(
//                     color: selected
//                         ? primaryColor
//                         : const Color(0xFF8E7771),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected
//                         ? Colors.white
//                         : darkText,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FEED
//   // ============================================================

//   Widget _buildFeed() {
//     final List<Widget> posts = [];

//     // ==========================================================
//     // REPOSTED POSTS
//     // ==========================================================
//     //
//     // Reposted posts appear first in the feed.
//     // ==========================================================

//     if (selectedCategory == 'All') {
//       if (_repostedPostIds.contains('luna_success')) {
//         posts.add(
//           _buildRepostedPost(
//             postId: 'luna_success',
//             profileImage:
//                 'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?auto=format&fit=crop&w=200&q=80',
//             author:
//                 'JAGNA ANIMAL LOVER AND RESCUE GROUP Admin',
//             time: '2 hours ago',
//             postImage:
//                 'https://images.unsplash.com/photo-1542736667-069246bdbc74?auto=format&fit=crop&w=900&q=80',
//             content:
//                 'Luna has finally found her forever home! After 6 months at the shelter, this sweet girl is going to her new loving family. Thank you to everyone who shared her story. ❤️\n#AdoptionSuccess #HappyTails',
//           ),
//         );

//         posts.add(
//           const SizedBox(height: 12),
//         );
//       }

//       if (_repostedPostIds.contains('joe_foster')) {
//         posts.add(
//           _buildRepostedPost(
//             postId: 'joe_foster',
//             profileImage:
//                 'https://i.pravatar.cc/150?img=47',
//             author: 'JoeAss',
//             time: '5 hours ago',
//             content:
//                 'Hi everyone! We just brought home our new foster puppy, Max. He’s a bit anxious around our older dog. Any tips for smooth introductions over the first few days? 🐶',
//           ),
//         );

//         posts.add(
//           const SizedBox(height: 12),
//         );
//       }

//       if (_repostedPostIds.contains('my_future_pet')) {
//         posts.add(
//           _buildRepostedPost(
//             postId: 'my_future_pet',
//             profileImage:
//                 'https://i.pravatar.cc/150?img=32',
//             author: 'My Future Pet',
//             time: '1 day ago',
//             content:
//                 'Remember that adopting a pet is a lifetime commitment. Give your new companion time, patience, and lots of love while they adjust to their new home. 🐾',
//           ),
//         );

//         posts.add(
//           const SizedBox(height: 12),
//         );
//       }
//     }

//     // ==========================================================
//     // FIRST ORIGINAL POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Success Stories') {
//       posts.add(
//         _buildCommunityPost(
//           postId: 'luna_success',
//           profileImage:
//               'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?auto=format&fit=crop&w=200&q=80',
//           author:
//               'JAGNA ANIMAL LOVER AND RESCUE GROUP Admin',
//           time: '2 hours ago',
//           postImage:
//               'https://images.unsplash.com/photo-1542736667-069246bdbc74?auto=format&fit=crop&w=900&q=80',
//           content:
//               'Luna has finally found her forever home! After 6 months at the shelter, this sweet girl is going to her new loving family. Thank you to everyone who shared her story. ❤️\n#AdoptionSuccess #HappyTails',
//         ),
//       );

//       posts.add(
//         const SizedBox(height: 12),
//       );
//     }

//     // ==========================================================
//     // SECOND ORIGINAL POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Tips') {
//       posts.add(
//         _buildTextPost(
//           postId: 'joe_foster',
//           profileImage:
//               'https://i.pravatar.cc/150?img=47',
//           author: 'JoeAss',
//           time: '5 hours ago',
//           content:
//               'Hi everyone! We just brought home our new foster puppy, Max. He’s a bit anxious around our older dog. Any tips for smooth introductions over the first few days? 🐶',
//         ),
//       );

//       posts.add(
//         const SizedBox(height: 12),
//       );
//     }

//     // ==========================================================
//     // THIRD ORIGINAL POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Announcements') {
//       posts.add(
//         _buildTextPost(
//           postId: 'my_future_pet',
//           profileImage:
//               'https://i.pravatar.cc/150?img=32',
//           author: 'My Future Pet',
//           time: '1 day ago',
//           content:
//               'Remember that adopting a pet is a lifetime commitment. Give your new companion time, patience, and lots of love while they adjust to their new home. 🐾',
//         ),
//       );
//     }

//     // ==========================================================
//     // NO POSTS
//     // ==========================================================

//     if (posts.isEmpty) {
//       return _buildEmptyFeed();
//     }

//     return ListView(
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         2,
//         14,
//         85,
//       ),
//       children: posts,
//     );
//   }

//   // ============================================================
//   // COMMUNITY POST WITH IMAGE
//   // ============================================================

//   Widget _buildCommunityPost({
//     required String postId,
//     required String profileImage,
//     required String author,
//     required String time,
//     required String postImage,
//     required String content,
//   }) {
//     final bool isLiked =
//         _likedPostIds.contains(postId);

//     final bool isReposted =
//         _repostedPostIds.contains(postId);

//     final int likes =
//         _likeCounts[postId] ?? 0;

//     final int comments =
//         _commentCounts[postId] ?? 0;

//     final int reposts =
//         _repostCounts[postId] ?? 0;

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFCFE8F0),
//           width: 1,
//         ),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // ==================================================
//           // POST HEADER
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               12,
//               11,
//               10,
//               10,
//             ),
//             child: Row(
//               children: [
//                 ClipOval(
//                   child: Image.network(
//                     profileImage,
//                     width: 34,
//                     height: 34,
//                     fit: BoxFit.cover,
//                     errorBuilder: (
//                       context,
//                       error,
//                       stackTrace,
//                     ) {
//                       return Container(
//                         width: 34,
//                         height: 34,
//                         color: lightBlue,
//                         child: Icon(
//                           Icons.person,
//                           color: primaryColor,
//                           size: 20,
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 9),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         author,
//                         maxLines: 2,
//                         overflow:
//                             TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: darkText,
//                           fontSize: 13,
//                           fontWeight:
//                               FontWeight.bold,
//                           height: 1.15,
//                         ),
//                       ),

//                       const SizedBox(height: 3),

//                       Text(
//                         time,
//                         style: TextStyle(
//                           color:
//                               Colors.grey.shade600,
//                           fontSize: 9,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Icon(
//                   Icons.more_horiz_rounded,
//                   color: Colors.grey.shade600,
//                   size: 20,
//                 ),
//               ],
//             ),
//           ),

//           // ==================================================
//           // POST IMAGE
//           // ==================================================

//           SizedBox(
//             width: double.infinity,
//             height: 274,
//             child: Image.network(
//               postImage,
//               fit: BoxFit.cover,
//               errorBuilder: (
//                 context,
//                 error,
//                 stackTrace,
//               ) {
//                 return Container(
//                   color: lightBlue,
//                   child: Icon(
//                     Icons.image_outlined,
//                     color: primaryColor,
//                     size: 45,
//                   ),
//                 );
//               },
//             ),
//           ),

//           // ==================================================
//           // CONTENT
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               13,
//               13,
//               13,
//               8,
//             ),
//             child: Text(
//               content,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 12,
//                 height: 1.42,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),

//           // ==================================================
//           // DIVIDER
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 13,
//             ),
//             child: Divider(
//               height: 1,
//               color: Colors.grey.shade200,
//             ),
//           ),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               13,
//               8,
//               13,
//               9,
//             ),
//             child: Row(
//               children: [
//                 // LIKE
//                 _buildActionButton(
//                   icon: isLiked
//                       ? Icons.favorite_rounded
//                       : Icons.favorite_border_rounded,
//                   text: _formatCount(likes),
//                   active: isLiked,
//                   onTap: () {
//                     _toggleLike(postId);
//                   },
//                 ),

//                 const SizedBox(width: 18),

//                 // COMMENT
//                 _buildActionButton(
//                   icon:
//                       Icons.chat_bubble_outline_rounded,
//                   text: _formatCount(comments),
//                   onTap: () {
//                     _showComments(
//                       postId: postId,
//                     );
//                   },
//                 ),

//                 const SizedBox(width: 18),

//                 // REPOST
//                 _buildActionButton(
//                   icon: isReposted
//                       ? Icons.repeat_on_rounded
//                       : Icons.repeat_rounded,
//                   text: _formatCount(reposts),
//                   active: isReposted,
//                   onTap: () {
//                     _handleRepost(
//                       postId: postId,
//                       author: author,
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // TEXT POST
//   // ============================================================

//   Widget _buildTextPost({
//     required String postId,
//     required String profileImage,
//     required String author,
//     required String time,
//     required String content,
//   }) {
//     final bool isLiked =
//         _likedPostIds.contains(postId);

//     final bool isReposted =
//         _repostedPostIds.contains(postId);

//     final int likes =
//         _likeCounts[postId] ?? 0;

//     final int comments =
//         _commentCounts[postId] ?? 0;

//     final int reposts =
//         _repostCounts[postId] ?? 0;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(13),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFCFE8F0),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // ==================================================
//           // HEADER
//           // ==================================================

//           Row(
//             children: [
//               ClipOval(
//                 child: Image.network(
//                   profileImage,
//                   width: 34,
//                   height: 34,
//                   fit: BoxFit.cover,
//                   errorBuilder: (
//                     context,
//                     error,
//                     stackTrace,
//                   ) {
//                     return Container(
//                       width: 34,
//                       height: 34,
//                       color: lightBlue,
//                       child: Icon(
//                         Icons.person,
//                         color: primaryColor,
//                         size: 20,
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(width: 9),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       author,
//                       maxLines: 1,
//                       overflow:
//                           TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: darkText,
//                         fontSize: 13,
//                         fontWeight:
//                             FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 3),

//                     Text(
//                       time,
//                       style: TextStyle(
//                         color:
//                             Colors.grey.shade600,
//                         fontSize: 9,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Icon(
//                 Icons.more_horiz_rounded,
//                 color: Colors.grey.shade600,
//                 size: 20,
//               ),
//             ],
//           ),

//           const SizedBox(height: 14),

//           // ==================================================
//           // CONTENT
//           // ==================================================

//           Text(
//             content,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 12,
//               height: 1.45,
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ==================================================
//           // DIVIDER
//           // ==================================================

//           Divider(
//             height: 1,
//             color: Colors.grey.shade200,
//           ),

//           const SizedBox(height: 8),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Row(
//             children: [
//               // LIKE
//               _buildActionButton(
//                 icon: isLiked
//                     ? Icons.favorite_rounded
//                     : Icons.favorite_border_rounded,
//                 text: _formatCount(likes),
//                 active: isLiked,
//                 onTap: () {
//                   _toggleLike(postId);
//                 },
//               ),

//               const SizedBox(width: 18),

//               // COMMENT
//               _buildActionButton(
//                 icon:
//                     Icons.chat_bubble_outline_rounded,
//                 text: _formatCount(comments),
//                 onTap: () {
//                   _showComments(
//                     postId: postId,
//                   );
//                 },
//               ),

//               const SizedBox(width: 18),

//               // REPOST
//               _buildActionButton(
//                 icon: isReposted
//                     ? Icons.repeat_on_rounded
//                     : Icons.repeat_rounded,
//                 text: _formatCount(reposts),
//                 active: isReposted,
//                 onTap: () {
//                   _handleRepost(
//                     postId: postId,
//                     author: author,
//                   );
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // REPOSTED POST
//   // ============================================================

//   Widget _buildRepostedPost({
//     required String postId,
//     required String profileImage,
//     required String author,
//     required String time,
//     required String content,
//     String? postImage,
//   }) {
//     final bool isLiked =
//         _likedPostIds.contains(postId);

//     final bool isReposted =
//         _repostedPostIds.contains(postId);

//     final int likes =
//         _likeCounts[postId] ?? 0;

//     final int comments =
//         _commentCounts[postId] ?? 0;

//     final int reposts =
//         _repostCounts[postId] ?? 0;

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFCFE8F0),
//           width: 1,
//         ),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // ==================================================
//           // REPOST LABEL
//           // ==================================================

//           Container(
//             width: double.infinity,
//             padding:
//                 const EdgeInsets.fromLTRB(
//               13,
//               9,
//               13,
//               9,
//             ),
//             color: const Color(0xFFF8F3F1),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.repeat_rounded,
//                   size: 17,
//                   color: primaryColor,
//                 ),

//                 const SizedBox(width: 7),

//                 Text(
//                   'You reposted',
//                   style: TextStyle(
//                     color: primaryColor,
//                     fontSize: 11,
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ==================================================
//           // ORIGINAL POST
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               12,
//               11,
//               10,
//               10,
//             ),
//             child: Row(
//               children: [
//                 ClipOval(
//                   child: Image.network(
//                     profileImage,
//                     width: 34,
//                     height: 34,
//                     fit: BoxFit.cover,
//                     errorBuilder: (
//                       context,
//                       error,
//                       stackTrace,
//                     ) {
//                       return Container(
//                         width: 34,
//                         height: 34,
//                         color: lightBlue,
//                         child: Icon(
//                           Icons.person,
//                           color: primaryColor,
//                           size: 20,
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 9),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         author,
//                         maxLines: 2,
//                         overflow:
//                             TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: darkText,
//                           fontSize: 13,
//                           fontWeight:
//                               FontWeight.bold,
//                           height: 1.15,
//                         ),
//                       ),

//                       const SizedBox(height: 3),

//                       Text(
//                         time,
//                         style: TextStyle(
//                           color:
//                               Colors.grey.shade600,
//                           fontSize: 9,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ==================================================
//           // ORIGINAL IMAGE
//           // ==================================================

//           if (postImage != null)
//             SizedBox(
//               width: double.infinity,
//               height: 274,
//               child: Image.network(
//                 postImage,
//                 fit: BoxFit.cover,
//                 errorBuilder: (
//                   context,
//                   error,
//                   stackTrace,
//                 ) {
//                   return Container(
//                     color: lightBlue,
//                     child: Icon(
//                       Icons.image_outlined,
//                       color: primaryColor,
//                       size: 45,
//                     ),
//                   );
//                 },
//               ),
//             ),

//           // ==================================================
//           // ORIGINAL CONTENT
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               13,
//               13,
//               13,
//               8,
//             ),
//             child: Text(
//               content,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 12,
//                 height: 1.42,
//               ),
//             ),
//           ),

//           // ==================================================
//           // DIVIDER
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 13,
//             ),
//             child: Divider(
//               height: 1,
//               color: Colors.grey.shade200,
//             ),
//           ),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               13,
//               8,
//               13,
//               9,
//             ),
//             child: Row(
//               children: [
//                 // LIKE
//                 _buildActionButton(
//                   icon: isLiked
//                       ? Icons.favorite_rounded
//                       : Icons.favorite_border_rounded,
//                   text: _formatCount(likes),
//                   active: isLiked,
//                   onTap: () {
//                     _toggleLike(postId);
//                   },
//                 ),

//                 const SizedBox(width: 18),

//                 // COMMENT
//                 _buildActionButton(
//                   icon:
//                       Icons.chat_bubble_outline_rounded,
//                   text: _formatCount(comments),
//                   onTap: () {
//                     _showComments(
//                       postId: postId,
//                     );
//                   },
//                 ),

//                 const SizedBox(width: 18),

//                 // REPOST
//                 _buildActionButton(
//                   icon: isReposted
//                       ? Icons.repeat_on_rounded
//                       : Icons.repeat_rounded,
//                   text: _formatCount(reposts),
//                   active: isReposted,
//                   onTap: () {
//                     _handleRepost(
//                       postId: postId,
//                       author: author,
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // ACTION BUTTON
//   // ============================================================

//   Widget _buildActionButton({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//     bool active = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       behavior: HitTestBehavior.opaque,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 16,
//             color: active
//                 ? primaryColor
//                 : Colors.grey.shade600,
//           ),

//           const SizedBox(width: 5),

//           Text(
//             text,
//             style: TextStyle(
//               color: active
//                   ? primaryColor
//                   : Colors.grey.shade600,
//               fontSize: 10,
//               fontWeight: active
//                   ? FontWeight.bold
//                   : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // LIKE / UNLIKE
//   // ============================================================

//   void _toggleLike(String postId) {
//     setState(() {
//       if (_likedPostIds.contains(postId)) {
//         _likedPostIds.remove(postId);

//         _likeCounts[postId] =
//             (_likeCounts[postId] ?? 0) - 1;
//       } else {
//         _likedPostIds.add(postId);

//         _likeCounts[postId] =
//             (_likeCounts[postId] ?? 0) + 1;
//       }
//     });
//   }

//   // ============================================================
//   // REPOST
//   // ============================================================

//   Future<void> _handleRepost({
//     required String postId,
//     required String author,
//   }) async {
//     final bool alreadyReposted =
//         _repostedPostIds.contains(postId);

//     // ==========================================================
//     // REMOVE REPOST
//     // ==========================================================

//     if (alreadyReposted) {
//       final bool? removeRepost =
//           await showDialog<bool>(
//         context: context,
//         builder: (dialogContext) {
//           return AlertDialog(
//             backgroundColor: Colors.white,
//             shape:
//                 RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(18),
//             ),
//             title: Text(
//               'Remove Repost?',
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             content: Text(
//               'This post will be removed from your reposts.',
//               style: TextStyle(
//                 color: Colors.grey.shade700,
//                 fontSize: 13,
//                 height: 1.4,
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(
//                     dialogContext,
//                     false,
//                   );
//                 },
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(
//                     color:
//                         Colors.grey.shade600,
//                   ),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(
//                     dialogContext,
//                     true,
//                   );
//                 },
//                 style:
//                     ElevatedButton.styleFrom(
//                   backgroundColor:
//                       primaryColor,
//                   foregroundColor:
//                       Colors.white,
//                   elevation: 0,
//                   shape:
//                       RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(
//                       18,
//                     ),
//                   ),
//                 ),
//                 child: const Text(
//                   'Remove',
//                 ),
//               ),
//             ],
//           );
//         },
//       );

//       if (removeRepost == true) {
//         setState(() {
//           _repostedPostIds.remove(postId);

//           _repostCounts[postId] =
//               (_repostCounts[postId] ?? 1) - 1;

//           if ((_repostCounts[postId] ?? 0) < 0) {
//             _repostCounts[postId] = 0;
//           }
//         });

//         _showMessage(
//           'Repost removed.',
//         );
//       }

//       return;
//     }

//     // ==========================================================
//     // CONFIRM REPOST
//     // ==========================================================

//     final bool? shouldRepost =
//         await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape:
//               RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(18),
//           ),
//           title: Text(
//             'Repost this post?',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Text(
//             'This post will appear in your community feed as a repost.',
//             style: TextStyle(
//               color: Colors.grey.shade700,
//               fontSize: 13,
//               height: 1.4,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                   false,
//                 );
//               },
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                   true,
//                 );
//               },
//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     primaryColor,
//                 foregroundColor:
//                     Colors.white,
//                 elevation: 0,
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(
//                     18,
//                   ),
//                 ),
//               ),
//               child: const Text(
//                 'Repost',
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     // ==========================================================
//     // ADD REPOST
//     // ==========================================================

//     if (shouldRepost == true) {
//       setState(() {
//         _repostedPostIds.add(postId);

//         _repostCounts[postId] =
//             (_repostCounts[postId] ?? 0) + 1;
//       });

//       _showMessage(
//         'Post reposted successfully!',
//       );
//     }
//   }

//   // ============================================================
//   // COMMENTS
//   // ============================================================

//   void _showComments({
//     required String postId,
//   }) {
//     final TextEditingController controller =
//         TextEditingController();

//     _comments.putIfAbsent(
//       postId,
//       () => <String>[],
//     );

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       useSafeArea: true,
//       builder: (sheetContext) {
//         return StatefulBuilder(
//           builder: (
//             context,
//             setSheetState,
//           ) {
//             final List<String> postComments =
//                 _comments[postId] ?? <String>[];

//             final int totalComments =
//                 _commentCounts[postId] ?? 0;

//             return Container(
//               height:
//                   MediaQuery.of(context).size.height *
//                       0.65,
//               decoration:
//                   const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius:
//                     BorderRadius.vertical(
//                   top: Radius.circular(24),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 10),

//                   Container(
//                     width: 42,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color:
//                           const Color(0xFFD7DEE0),
//                       borderRadius:
//                           BorderRadius.circular(10),
//                     ),
//                   ),

//                   // ==================================================
//                   // HEADER
//                   // ==================================================

//                   Padding(
//                     padding:
//                         const EdgeInsets.fromLTRB(
//                       18,
//                       15,
//                       14,
//                       12,
//                     ),
//                     child: Row(
//                       children: [
//                         const Expanded(
//                           child: Text(
//                             'Comments',
//                             style: TextStyle(
//                               color:
//                                   Color(0xFF062B35),
//                               fontSize: 19,
//                               fontWeight:
//                                   FontWeight.bold,
//                             ),
//                           ),
//                         ),

//                         Text(
//                           '$totalComments',
//                           style: TextStyle(
//                             color:
//                                 Colors.grey.shade600,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   Divider(
//                     height: 1,
//                     color:
//                         Colors.grey.shade200,
//                   ),

//                   // ==================================================
//                   // COMMENT LIST
//                   // ==================================================

//                   Expanded(
//                     child:
//                         postComments.isEmpty
//                             ? Center(
//                                 child: Column(
//                                   mainAxisSize:
//                                       MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons
//                                           .chat_bubble_outline_rounded,
//                                       size: 45,
//                                       color:
//                                           primaryColor,
//                                     ),

//                                     const SizedBox(
//                                       height: 10,
//                                     ),

//                                     const Text(
//                                       'No comments yet',
//                                       style:
//                                           TextStyle(
//                                         color:
//                                             Color(
//                                           0xFF062B35,
//                                         ),
//                                         fontSize: 15,
//                                         fontWeight:
//                                             FontWeight
//                                                 .bold,
//                                       ),
//                                     ),

//                                     const SizedBox(
//                                       height: 4,
//                                     ),

//                                     Text(
//                                       'Be the first to comment.',
//                                       style:
//                                           TextStyle(
//                                         color: Colors
//                                             .grey
//                                             .shade600,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : ListView.builder(
//                                 physics:
//                                     const BouncingScrollPhysics(),
//                                 padding:
//                                     const EdgeInsets
//                                         .all(15),
//                                 itemCount:
//                                     postComments.length,
//                                 itemBuilder:
//                                     (
//                                   context,
//                                   index,
//                                 ) {
//                                   final String
//                                       comment =
//                                       postComments[
//                                           index];

//                                   return Container(
//                                     margin:
//                                         const EdgeInsets
//                                             .only(
//                                       bottom: 10,
//                                     ),
//                                     padding:
//                                         const EdgeInsets
//                                             .all(11),
//                                     decoration:
//                                         BoxDecoration(
//                                       color:
//                                           backgroundColor,
//                                       borderRadius:
//                                           BorderRadius
//                                               .circular(
//                                         14,
//                                       ),
//                                     ),
//                                     child: Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment
//                                               .start,
//                                       children: [
//                                         CircleAvatar(
//                                           radius: 16,
//                                           backgroundColor:
//                                               lightBlue,
//                                           child:
//                                               Icon(
//                                             Icons
//                                                 .person,
//                                             size: 18,
//                                             color:
//                                                 primaryColor,
//                                           ),
//                                         ),

//                                         const SizedBox(
//                                           width: 9,
//                                         ),

//                                         Expanded(
//                                           child:
//                                               Text(
//                                             comment,
//                                             style:
//                                                 const TextStyle(
//                                               color:
//                                                   Color(
//                                                 0xFF062B35,
//                                               ),
//                                               fontSize:
//                                                   12,
//                                               height:
//                                                   1.4,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                   ),

//                   // ==================================================
//                   // COMMENT INPUT
//                   // ==================================================

//                   Container(
//                     padding:
//                         EdgeInsets.fromLTRB(
//                       12,
//                       8,
//                       12,
//                       MediaQuery.of(context)
//                               .viewInsets
//                               .bottom +
//                           10,
//                     ),
//                     decoration:
//                         BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black
//                               .withOpacity(
//                             0.06,
//                           ),
//                           blurRadius: 8,
//                           offset:
//                               const Offset(
//                             0,
//                             -2,
//                           ),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.end,
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller:
//                                 controller,
//                             minLines: 1,
//                             maxLines: 4,
//                             keyboardType:
//                                 TextInputType
//                                     .multiline,
//                             textCapitalization:
//                                 TextCapitalization
//                                     .sentences,
//                             decoration:
//                                 InputDecoration(
//                               hintText:
//                                   'Write a comment...',
//                               hintStyle:
//                                   TextStyle(
//                                 color: Colors
//                                     .grey
//                                     .shade500,
//                                 fontSize: 12,
//                               ),
//                               filled: true,
//                               fillColor:
//                                   backgroundColor,
//                               contentPadding:
//                                   const EdgeInsets
//                                       .symmetric(
//                                 horizontal: 14,
//                                 vertical: 11,
//                               ),
//                               border:
//                                   OutlineInputBorder(
//                                 borderRadius:
//                                     BorderRadius
//                                         .circular(
//                                   22,
//                                 ),
//                                 borderSide:
//                                     BorderSide.none,
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 8),

//                         GestureDetector(
//                           onTap: () {
//                             final String
//                                 comment =
//                                 controller.text
//                                     .trim();

//                             if (comment.isEmpty) {
//                               return;
//                             }

//                             _comments[postId]!
//                                 .add(comment);

//                             _commentCounts[postId] =
//                                 (_commentCounts[
//                                             postId] ??
//                                         0) +
//                                     1;

//                             controller.clear();

//                             setSheetState(() {});
//                           },
//                           child: Container(
//                             width: 43,
//                             height: 43,
//                             decoration:
//                                 BoxDecoration(
//                               color:
//                                   primaryColor,
//                               shape:
//                                   BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.send_rounded,
//                               color:
//                                   Colors.white,
//                               size: 18,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // ============================================================
//   // FORMAT COUNT
//   // ============================================================

//   String _formatCount(int count) {
//     if (count >= 1000000) {
//       return '${(count / 1000000).toStringAsFixed(1)}M';
//     }

//     if (count >= 1000) {
//       final String value =
//           (count / 1000).toStringAsFixed(1);

//       if (value.endsWith('.0')) {
//         return '${value.substring(
//           0,
//           value.length - 2,
//         )}k';
//       }

//       return '${value}k';
//     }

//     return count.toString();
//   }

//   // ============================================================
//   // FLOATING CREATE POST BUTTON
//   // ============================================================

//   Widget _buildCreatePostButton() {
//     return GestureDetector(
//       onTap: () {
//         _showCreatePostDialog();
//       },
//       child: Container(
//         width: 49,
//         height: 49,
//         decoration: BoxDecoration(
//           color: primaryColor,
//           borderRadius:
//               BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color:
//                   Colors.black.withOpacity(0.18),
//               blurRadius: 7,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: const Icon(
//           Icons.edit_rounded,
//           color: Colors.white,
//           size: 19,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY FEED
//   // ============================================================

//   Widget _buildEmptyFeed() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.only(
//           top: 70,
//           left: 20,
//           right: 20,
//         ),
//         child: Column(
//           children: [
//             Icon(
//               Icons.forum_outlined,
//               size: 55,
//               color: primaryColor,
//             ),

//             const SizedBox(height: 15),

//             Text(
//               'No posts found',
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 19,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 6),

//             Text(
//               'There are no posts in this category yet.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 12,
//               ),
//             ),

//             const SizedBox(height: 18),

//             OutlinedButton(
//               onPressed: () {
//                 setState(() {
//                   selectedCategory = 'All';
//                 });
//               },
//               style:
//                   OutlinedButton.styleFrom(
//                 foregroundColor:
//                     primaryColor,
//                 side: BorderSide(
//                   color: primaryColor,
//                 ),
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(20),
//                 ),
//               ),
//               child: const Text(
//                 'View All Posts',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CREATE POST DIALOG
//   // ============================================================

//   Future<void> _showCreatePostDialog() async {
//     final TextEditingController controller =
//         TextEditingController();

//     await showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape:
//               RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(18),
//           ),
//           title: Text(
//             'Create Post',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 19,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: TextField(
//             controller: controller,
//             maxLines: 5,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 13,
//             ),
//             decoration:
//                 InputDecoration(
//               hintText:
//                   'Share something with the community...',
//               hintStyle: TextStyle(
//                 color: Colors.grey.shade500,
//                 fontSize: 12,
//               ),
//               filled: true,
//               fillColor: backgroundColor,
//               border:
//                   OutlineInputBorder(
//                 borderRadius:
//                     BorderRadius.circular(12),
//                 borderSide:
//                     BorderSide.none,
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                 );
//               },
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color:
//                       Colors.grey.shade600,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (controller.text
//                     .trim()
//                     .isEmpty) {
//                   return;
//                 }

//                 Navigator.pop(
//                   dialogContext,
//                 );

//                 _showMessage(
//                   'Post created successfully!',
//                 );
//               },
//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     primaryColor,
//                 foregroundColor:
//                     Colors.white,
//                 elevation: 0,
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(
//                     18,
//                   ),
//                 ),
//               ),
//               child: const Text(
//                 'Post',
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     // Dispose only AFTER the dialog is completely closed.
//     controller.dispose();
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior:
//             SnackBarBehavior.floating,
//         duration:
//             const Duration(seconds: 2),
//       ),
//     );
//   }
// }



























//saktooo


// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';

// // ============================================================
// // COMMUNITY FEED SCREEN
// // ============================================================

// class FeedScreen extends StatefulWidget {
//   const FeedScreen({
//     super.key,
//   });

//   @override
//   State<FeedScreen> createState() => _FeedScreenState();
// }

// class _FeedScreenState extends State<FeedScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color darkText = const Color(0xFF062B35);

//   final Color backgroundColor = const Color(0xFFEFF9FD);
//   final Color lightBlue = const Color(0xFFE4F5FB);

//   // ============================================================
//   // CATEGORY
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Success Stories',
//     'Announcements',
//     'Tips',
//   ];

//   // ============================================================
//   // POST INTERACTION DATA
//   // ============================================================

//   // Stores which posts the current user has liked.
//   final Set<String> _likedPostIds = {};

//   // Like counts.
//   final Map<String, int> _likeCounts = {
//     'luna_success': 1200,
//     'joe_foster': 45,
//     'my_future_pet': 86,
//   };

//   // Comment counts.
//   final Map<String, int> _commentCounts = {
//     'luna_success': 84,
//     'joe_foster': 12,
//     'my_future_pet': 18,
//   };

//   // New comments added during the current app session.
//   final Map<String, List<String>> _comments = {
//     'luna_success': [],
//     'joe_foster': [],
//     'my_future_pet': [],
//   };

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             _buildCategoryBar(),

//             Expanded(
//               child: Stack(
//                 children: [
//                   _buildFeed(),

//                   Positioned(
//                     right: 14,
//                     bottom: 18,
//                     child: _buildCreatePostButton(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       color: backgroundColor,
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         8,
//         14,
//         8,
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               border: Border.all(
//                 color: const Color(0xFFD9E4E7),
//                 width: 1,
//               ),
//             ),
//             child: ClipOval(
//               child: Image.network(
//                 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=200',
//                 fit: BoxFit.cover,
//                 errorBuilder: (
//                   context,
//                   error,
//                   stackTrace,
//                 ) {
//                   return Icon(
//                     Icons.pets_rounded,
//                     color: primaryColor,
//                     size: 20,
//                   );
//                 },
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           Expanded(
//             child: Text(
//               'Community',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 25,
//                 fontWeight: FontWeight.bold,
//                 height: 1,
//               ),
//             ),
//           ),

//           IconButton(
//             onPressed: () {
//               _showMessage(
//                 'No new notifications.',
//               );
//             },
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 34,
//               minHeight: 34,
//             ),
//             icon: Icon(
//               Icons.notifications_none_rounded,
//               color: primaryColor,
//               size: 21,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY BAR
//   // ============================================================

//   Widget _buildCategoryBar() {
//     return Container(
//       width: double.infinity,
//       color: backgroundColor,
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         2,
//         0,
//         10,
//       ),
//       child: SizedBox(
//         height: 34,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           physics: const BouncingScrollPhysics(),
//           itemCount: categories.length,
//           separatorBuilder: (
//             context,
//             index,
//           ) {
//             return const SizedBox(width: 7);
//           },
//           itemBuilder: (
//             context,
//             index,
//           ) {
//             final String category =
//                 categories[index];

//             final bool selected =
//                 selectedCategory == category;

//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(
//                   milliseconds: 180,
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(
//                   horizontal: 16,
//                 ),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? primaryColor
//                       : Colors.white,
//                   borderRadius:
//                       BorderRadius.circular(20),
//                   border: Border.all(
//                     color: selected
//                         ? primaryColor
//                         : const Color(0xFF8E7771),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected
//                         ? Colors.white
//                         : darkText,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FEED
//   // ============================================================

//   Widget _buildFeed() {
//     final List<Widget> posts = [];

//     // ==========================================================
//     // FIRST POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Success Stories') {
//       posts.add(
//         _buildCommunityPost(
//           postId: 'luna_success',
//           profileImage:
//               'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?auto=format&fit=crop&w=200&q=80',
//           author:
//               'JAGNA ANIMAL LOVER AND RESCUE GROUP Admin',
//           time: '2 hours ago',
//           postImage:
//               'https://images.unsplash.com/photo-1542736667-069246bdbc74?auto=format&fit=crop&w=900&q=80',
//           content:
//               'Luna has finally found her forever home! After 6 months at the shelter, this sweet girl is going to her new loving family. Thank you to everyone who shared her story. ❤️\n#AdoptionSuccess #HappyTails',
//         ),
//       );

//       posts.add(
//         const SizedBox(height: 12),
//       );
//     }

//     // ==========================================================
//     // SECOND POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Tips') {
//       posts.add(
//         _buildTextPost(
//           postId: 'joe_foster',
//           profileImage:
//               'https://i.pravatar.cc/150?img=47',
//           author: 'JoeAss',
//           time: '5 hours ago',
//           content:
//               'Hi everyone! We just brought home our new foster puppy, Max. He’s a bit anxious around our older dog. Any tips for smooth introductions over the first few days? 🐶',
//         ),
//       );

//       posts.add(
//         const SizedBox(height: 12),
//       );
//     }

//     // ==========================================================
//     // THIRD POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Announcements') {
//       posts.add(
//         _buildTextPost(
//           postId: 'my_future_pet',
//           profileImage:
//               'https://i.pravatar.cc/150?img=32',
//           author: 'My Future Pet',
//           time: '1 day ago',
//           content:
//               'Remember that adopting a pet is a lifetime commitment. Give your new companion time, patience, and lots of love while they adjust to their new home. 🐾',
//         ),
//       );
//     }

//     // ==========================================================
//     // NO POSTS
//     // ==========================================================

//     if (posts.isEmpty) {
//       return _buildEmptyFeed();
//     }

//     return ListView(
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         2,
//         14,
//         85,
//       ),
//       children: posts,
//     );
//   }

//   // ============================================================
//   // COMMUNITY POST WITH IMAGE
//   // ============================================================

//   Widget _buildCommunityPost({
//     required String postId,
//     required String profileImage,
//     required String author,
//     required String time,
//     required String postImage,
//     required String content,
//   }) {
//     final bool isLiked =
//         _likedPostIds.contains(postId);

//     final int likes =
//         _likeCounts[postId] ?? 0;

//     final int comments =
//         _commentCounts[postId] ?? 0;

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFCFE8F0),
//           width: 1,
//         ),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // ==================================================
//           // POST HEADER
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               12,
//               11,
//               10,
//               10,
//             ),
//             child: Row(
//               children: [
//                 ClipOval(
//                   child: Image.network(
//                     profileImage,
//                     width: 34,
//                     height: 34,
//                     fit: BoxFit.cover,
//                     errorBuilder: (
//                       context,
//                       error,
//                       stackTrace,
//                     ) {
//                       return Container(
//                         width: 34,
//                         height: 34,
//                         color: lightBlue,
//                         child: Icon(
//                           Icons.person,
//                           color: primaryColor,
//                           size: 20,
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 9),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         author,
//                         maxLines: 2,
//                         overflow:
//                             TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: darkText,
//                           fontSize: 13,
//                           fontWeight:
//                               FontWeight.bold,
//                           height: 1.15,
//                         ),
//                       ),

//                       const SizedBox(height: 3),

//                       Text(
//                         time,
//                         style: TextStyle(
//                           color:
//                               Colors.grey.shade600,
//                           fontSize: 9,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Icon(
//                   Icons.more_horiz_rounded,
//                   color: Colors.grey.shade600,
//                   size: 20,
//                 ),
//               ],
//             ),
//           ),

//           // ==================================================
//           // POST IMAGE
//           // ==================================================

//           SizedBox(
//             width: double.infinity,
//             height: 274,
//             child: Image.network(
//               postImage,
//               fit: BoxFit.cover,
//               errorBuilder: (
//                 context,
//                 error,
//                 stackTrace,
//               ) {
//                 return Container(
//                   color: lightBlue,
//                   child: Icon(
//                     Icons.image_outlined,
//                     color: primaryColor,
//                     size: 45,
//                   ),
//                 );
//               },
//             ),
//           ),

//           // ==================================================
//           // CONTENT
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               13,
//               13,
//               13,
//               8,
//             ),
//             child: Text(
//               content,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 12,
//                 height: 1.42,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),

//           // ==================================================
//           // DIVIDER
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 13,
//             ),
//             child: Divider(
//               height: 1,
//               color: Colors.grey.shade200,
//             ),
//           ),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               13,
//               8,
//               13,
//               9,
//             ),
//             child: Row(
//               children: [
//                 // LIKE
//                 _buildActionButton(
//                   icon: isLiked
//                       ? Icons.favorite_rounded
//                       : Icons.favorite_border_rounded,
//                   text: _formatCount(likes),
//                   active: isLiked,
//                   onTap: () {
//                     _toggleLike(postId);
//                   },
//                 ),

//                 const SizedBox(width: 20),

//                 // COMMENT
//                 _buildActionButton(
//                   icon:
//                       Icons.chat_bubble_outline_rounded,
//                   text: _formatCount(comments),
//                   onTap: () {
//                     _showComments(
//                       postId: postId,
//                     );
//                   },
//                 ),

//                 const Spacer(),

//                 // SHARE
//                 GestureDetector(
//                   onTap: () {
//                     _sharePost(
//                       author: author,
//                       content: content,
//                     );
//                   },
//                   child: Icon(
//                     Icons.share_outlined,
//                     size: 17,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // TEXT POST
//   // ============================================================

//   Widget _buildTextPost({
//     required String postId,
//     required String profileImage,
//     required String author,
//     required String time,
//     required String content,
//   }) {
//     final bool isLiked =
//         _likedPostIds.contains(postId);

//     final int likes =
//         _likeCounts[postId] ?? 0;

//     final int comments =
//         _commentCounts[postId] ?? 0;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(13),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFCFE8F0),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // ==================================================
//           // HEADER
//           // ==================================================

//           Row(
//             children: [
//               ClipOval(
//                 child: Image.network(
//                   profileImage,
//                   width: 34,
//                   height: 34,
//                   fit: BoxFit.cover,
//                   errorBuilder: (
//                     context,
//                     error,
//                     stackTrace,
//                   ) {
//                     return Container(
//                       width: 34,
//                       height: 34,
//                       color: lightBlue,
//                       child: Icon(
//                         Icons.person,
//                         color: primaryColor,
//                         size: 20,
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(width: 9),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       author,
//                       maxLines: 1,
//                       overflow:
//                           TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: darkText,
//                         fontSize: 13,
//                         fontWeight:
//                             FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 3),

//                     Text(
//                       time,
//                       style: TextStyle(
//                         color:
//                             Colors.grey.shade600,
//                         fontSize: 9,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Icon(
//                 Icons.more_horiz_rounded,
//                 color: Colors.grey.shade600,
//                 size: 20,
//               ),
//             ],
//           ),

//           const SizedBox(height: 14),

//           // ==================================================
//           // CONTENT
//           // ==================================================

//           Text(
//             content,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 12,
//               height: 1.45,
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ==================================================
//           // DIVIDER
//           // ==================================================

//           Divider(
//             height: 1,
//             color: Colors.grey.shade200,
//           ),

//           const SizedBox(height: 8),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Row(
//             children: [
//               // LIKE
//               _buildActionButton(
//                 icon: isLiked
//                     ? Icons.favorite_rounded
//                     : Icons.favorite_border_rounded,
//                 text: _formatCount(likes),
//                 active: isLiked,
//                 onTap: () {
//                   _toggleLike(postId);
//                 },
//               ),

//               const SizedBox(width: 20),

//               // COMMENT
//               _buildActionButton(
//                 icon:
//                     Icons.chat_bubble_outline_rounded,
//                 text: _formatCount(comments),
//                 onTap: () {
//                   _showComments(
//                     postId: postId,
//                   );
//                 },
//               ),

//               const Spacer(),

//               // SHARE
//               GestureDetector(
//                 onTap: () {
//                   _sharePost(
//                     author: author,
//                     content: content,
//                   );
//                 },
//                 child: Icon(
//                   Icons.share_outlined,
//                   size: 17,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // ACTION BUTTON
//   // ============================================================

//   Widget _buildActionButton({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//     bool active = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       behavior: HitTestBehavior.opaque,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 16,
//             color: active
//                 ? primaryColor
//                 : Colors.grey.shade600,
//           ),

//           const SizedBox(width: 5),

//           Text(
//             text,
//             style: TextStyle(
//               color: active
//                   ? primaryColor
//                   : Colors.grey.shade600,
//               fontSize: 10,
//               fontWeight: active
//                   ? FontWeight.bold
//                   : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // LIKE / UNLIKE
//   // ============================================================

//   void _toggleLike(String postId) {
//     setState(() {
//       if (_likedPostIds.contains(postId)) {
//         _likedPostIds.remove(postId);

//         _likeCounts[postId] =
//             (_likeCounts[postId] ?? 0) - 1;
//       } else {
//         _likedPostIds.add(postId);

//         _likeCounts[postId] =
//             (_likeCounts[postId] ?? 0) + 1;
//       }
//     });
//   }

//   // ============================================================
//   // COMMENTS
//   // ============================================================

//   void _showComments({
//   required String postId,
// }) {
//   final TextEditingController controller =
//       TextEditingController();

//   // Make sure this post has a comment list.
//   _comments.putIfAbsent(
//     postId,
//     () => <String>[],
//   );

//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     useSafeArea: true,
//     builder: (sheetContext) {
//       return StatefulBuilder(
//         builder: (
//           context,
//           setSheetState,
//         ) {
//           final List<String> postComments =
//               _comments[postId] ?? <String>[];

//           final int totalComments =
//               _commentCounts[postId] ?? 0;

//           return Container(
//             height:
//                 MediaQuery.of(context).size.height *
//                     0.65,
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(
//                 top: Radius.circular(24),
//               ),
//             ),
//             child: Column(
//               children: [
//                 // ==================================================
//                 // HANDLE
//                 // ==================================================

//                 const SizedBox(height: 10),

//                 Container(
//                   width: 42,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFD7DEE0),
//                     borderRadius:
//                         BorderRadius.circular(10),
//                   ),
//                 ),

//                 // ==================================================
//                 // HEADER
//                 // ==================================================

//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(
//                     18,
//                     15,
//                     14,
//                     12,
//                   ),
//                   child: Row(
//                     children: [
//                       const Expanded(
//                         child: Text(
//                           'Comments',
//                           style: TextStyle(
//                             color: Color(0xFF062B35),
//                             fontSize: 19,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),

//                       Text(
//                         '$totalComments',
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Divider(
//                   height: 1,
//                   color: Colors.grey.shade200,
//                 ),

//                 // ==================================================
//                 // COMMENT LIST
//                 // ==================================================

//                 Expanded(
//                   child: postComments.isEmpty
//                       ? Center(
//                           child: Column(
//                             mainAxisSize:
//                                 MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons
//                                     .chat_bubble_outline_rounded,
//                                 size: 45,
//                                 color: primaryColor,
//                               ),

//                               const SizedBox(
//                                 height: 10,
//                               ),

//                               const Text(
//                                 'No comments yet',
//                                 style: TextStyle(
//                                   color:
//                                       Color(0xFF062B35),
//                                   fontSize: 15,
//                                   fontWeight:
//                                       FontWeight.bold,
//                                 ),
//                               ),

//                               const SizedBox(
//                                 height: 4,
//                               ),

//                               Text(
//                                 'Be the first to comment.',
//                                 style: TextStyle(
//                                   color:
//                                       Colors.grey.shade600,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : ListView.builder(
//                           physics:
//                               const BouncingScrollPhysics(),
//                           padding:
//                               const EdgeInsets.all(15),
//                           itemCount:
//                               postComments.length,
//                           itemBuilder:
//                               (
//                             context,
//                             index,
//                           ) {
//                             final String comment =
//                                 postComments[index];

//                             return Container(
//                               margin:
//                                   const EdgeInsets.only(
//                                 bottom: 10,
//                               ),
//                               padding:
//                                   const EdgeInsets.all(
//                                 11,
//                               ),
//                               decoration:
//                                   BoxDecoration(
//                                 color: backgroundColor,
//                                 borderRadius:
//                                     BorderRadius.circular(
//                                   14,
//                                 ),
//                               ),
//                               child: Row(
//                                 crossAxisAlignment:
//                                     CrossAxisAlignment
//                                         .start,
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 16,
//                                     backgroundColor:
//                                         lightBlue,
//                                     child: Icon(
//                                       Icons.person,
//                                       size: 18,
//                                       color:
//                                           primaryColor,
//                                     ),
//                                   ),

//                                   const SizedBox(
//                                     width: 9,
//                                   ),

//                                   Expanded(
//                                     child: Text(
//                                       comment,
//                                       style:
//                                           const TextStyle(
//                                         color:
//                                             Color(
//                                           0xFF062B35,
//                                         ),
//                                         fontSize: 12,
//                                         height: 1.4,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                 ),

//                 // ==================================================
//                 // COMMENT INPUT
//                 // ==================================================

//                 Container(
//                   padding: EdgeInsets.fromLTRB(
//                     12,
//                     8,
//                     12,
//                     MediaQuery.of(context)
//                             .viewInsets
//                             .bottom +
//                         10,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color:
//                             Colors.black.withOpacity(
//                           0.06,
//                         ),
//                         blurRadius: 8,
//                         offset: const Offset(0, -2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.end,
//                     children: [
//                       // ==========================================
//                       // TEXT FIELD
//                       // ==========================================

//                       Expanded(
//                         child: TextField(
//                           controller: controller,
//                           minLines: 1,
//                           maxLines: 4,
//                           keyboardType:
//                               TextInputType.multiline,
//                           textCapitalization:
//                               TextCapitalization.sentences,
//                           decoration:
//                               InputDecoration(
//                             hintText:
//                                 'Write a comment...',
//                             hintStyle: TextStyle(
//                               color:
//                                   Colors.grey.shade500,
//                               fontSize: 12,
//                             ),
//                             filled: true,
//                             fillColor:
//                                 backgroundColor,
//                             contentPadding:
//                                 const EdgeInsets
//                                     .symmetric(
//                               horizontal: 14,
//                               vertical: 11,
//                             ),
//                             border:
//                                 OutlineInputBorder(
//                               borderRadius:
//                                   BorderRadius.circular(
//                                 22,
//                               ),
//                               borderSide:
//                                   BorderSide.none,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(width: 8),

//                       // ==========================================
//                       // SEND BUTTON
//                       // ==========================================

//                       GestureDetector(
//                         onTap: () {
//                           final String comment =
//                               controller.text.trim();

//                           // Don't allow empty comments.
//                           if (comment.isEmpty) {
//                             return;
//                           }

//                           // Add comment.
//                           _comments[postId]!.add(
//                             comment,
//                           );

//                           // Increase comment count.
//                           _commentCounts[postId] =
//                               (_commentCounts[postId] ??
//                                       0) +
//                                   1;

//                           // Clear text field.
//                           controller.clear();

//                           // Rebuild comment sheet.
//                           setSheetState(() {});
//                         },
//                         child: Container(
//                           width: 43,
//                           height: 43,
//                           decoration: BoxDecoration(
//                             color: primaryColor,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.send_rounded,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }

//   // ============================================================
//   // SHARE POST
//   // ============================================================

//   Future<void> _sharePost({
//     required String author,
//     required String content,
//   }) async {
//     try {
//       await SharePlus.instance.share(
//         ShareParams(
//           title: 'My Future Pet Community',
//           text:
//               '$author\n\n$content\n\nShared from My Future Pet Community',
//         ),
//       );
//     } catch (e) {
//       _showMessage(
//         'Unable to share this post.',
//       );
//     }
//   }

//   // ============================================================
//   // FORMAT COUNT
//   // ============================================================

//   String _formatCount(int count) {
//     if (count >= 1000000) {
//       return '${(count / 1000000).toStringAsFixed(1)}M';
//     }

//     if (count >= 1000) {
//       final String value =
//           (count / 1000).toStringAsFixed(1);

//       if (value.endsWith('.0')) {
//         return '${value.substring(
//           0,
//           value.length - 2,
//         )}k';
//       }

//       return '${value}k';
//     }

//     return count.toString();
//   }

//   // ============================================================
//   // FLOATING CREATE POST BUTTON
//   // ============================================================

//   Widget _buildCreatePostButton() {
//     return GestureDetector(
//       onTap: () {
//         _showCreatePostDialog();
//       },
//       child: Container(
//         width: 49,
//         height: 49,
//         decoration: BoxDecoration(
//           color: primaryColor,
//           borderRadius:
//               BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color:
//                   Colors.black.withOpacity(0.18),
//               blurRadius: 7,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: const Icon(
//           Icons.edit_rounded,
//           color: Colors.white,
//           size: 19,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY FEED
//   // ============================================================

//   Widget _buildEmptyFeed() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.only(
//           top: 70,
//           left: 20,
//           right: 20,
//         ),
//         child: Column(
//           children: [
//             Icon(
//               Icons.forum_outlined,
//               size: 55,
//               color: primaryColor,
//             ),

//             const SizedBox(height: 15),

//             Text(
//               'No posts found',
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 19,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 6),

//             Text(
//               'There are no posts in this category yet.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 12,
//               ),
//             ),

//             const SizedBox(height: 18),

//             OutlinedButton(
//               onPressed: () {
//                 setState(() {
//                   selectedCategory = 'All';
//                 });
//               },
//               style:
//                   OutlinedButton.styleFrom(
//                 foregroundColor:
//                     primaryColor,
//                 side: BorderSide(
//                   color: primaryColor,
//                 ),
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(20),
//                 ),
//               ),
//               child: const Text(
//                 'View All Posts',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CREATE POST DIALOG
//   // ============================================================

//   void _showCreatePostDialog() {
//     final TextEditingController controller =
//         TextEditingController();

//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape:
//               RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(18),
//           ),

//           title: Text(
//             'Create Post',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 19,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           content: TextField(
//             controller: controller,
//             maxLines: 5,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 13,
//             ),
//             decoration:
//                 InputDecoration(
//               hintText:
//                   'Share something with the community...',
//               hintStyle: TextStyle(
//                 color: Colors.grey.shade500,
//                 fontSize: 12,
//               ),
//               filled: true,
//               fillColor: backgroundColor,
//               border:
//                   OutlineInputBorder(
//                 borderRadius:
//                     BorderRadius.circular(12),
//                 borderSide:
//                     BorderSide.none,
//               ),
//             ),
//           ),

//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                 );
//               },
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color:
//                       Colors.grey.shade600,
//                 ),
//               ),
//             ),

//             ElevatedButton(
//               onPressed: () {
//                 if (controller.text
//                     .trim()
//                     .isEmpty) {
//                   return;
//                 }

//                 Navigator.pop(
//                   dialogContext,
//                 );

//                 _showMessage(
//                   'Post created successfully!',
//                 );
//               },
//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     primaryColor,
//                 foregroundColor:
//                     Colors.white,
//                 elevation: 0,
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(
//                     18,
//                   ),
//                 ),
//               ),
//               child: const Text(
//                 'Post',
//               ),
//             ),
//           ],
//         );
//       },
//     ).whenComplete(
//       controller.dispose,
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior:
//             SnackBarBehavior.floating,
//         duration:
//             const Duration(seconds: 2),
//       ),
//     );
//   }
// }






































// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';

// // ============================================================
// // COMMUNITY FEED SCREEN
// // ============================================================

// class FeedScreen extends StatefulWidget {
//   const FeedScreen({
//     super.key,
//   });

//   @override
//   State<FeedScreen> createState() => _FeedScreenState();
// }

// class _FeedScreenState extends State<FeedScreen> {

//     // ============================================================
//   // POST INTERACTION STATE
//   // ============================================================

//   final Set<String> _likedPostIds = {};

//   final Map<String, int> _likeCounts = {
//     'luna_success': 1200,
//     'joe_foster': 45,
//     'my_future_pet': 86,
//   };

//   final Map<String, int> _commentCounts = {
//     'luna_success': 84,
//     'joe_foster': 12,
//     'my_future_pet': 18,
//   };

//   final Map<String, List<String>> _comments = {
//     'luna_success': [],
//     'joe_foster': [],
//     'my_future_pet': [],
//   };

//   void _toggleLike(String postId) {
//     setState(() {
//       if (_likedPostIds.contains(postId)) {
//         _likedPostIds.remove(postId);

//         _likeCounts[postId] =
//             (_likeCounts[postId] ?? 0) - 1;
//       } else {
//         _likedPostIds.add(postId);

//         _likeCounts[postId] =
//             (_likeCounts[postId] ?? 0) + 1;
//       }
//     });
//   }


//   void _showComments({
//     required String postId,
//   }) {
//     final TextEditingController controller =
//         TextEditingController();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (sheetContext) {
//         return StatefulBuilder(
//           builder: (context, setSheetState) {
//             final List<String> postComments =
//                 _comments[postId] ?? [];

//             return Container(
//               height: MediaQuery.of(context).size.height * 0.65,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(
//                   top: Radius.circular(24),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 10),

//                   Container(
//                     width: 42,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Color(0xFFD7DEE0),
//                       borderRadius:
//                           BorderRadius.circular(10),
//                     ),
//                   ),

//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(
//                       18,
//                       15,
//                       14,
//                       12,
//                     ),
//                     child: Row(
//                       children: [
//                         const Expanded(
//                           child: Text(
//                             'Comments',
//                             style: TextStyle(
//                               color: darkText,
//                               fontSize: 19,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           '${postComments.length + (_commentCounts[postId] ?? 0)}',
//                           style: TextStyle(
//                             color: Colors.grey.shade600,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   Divider(
//                     height: 1,
//                     color: Colors.grey.shade200,
//                   ),

//                   Expanded(
//                     child: postComments.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.chat_bubble_outline_rounded,
//                                   size: 45,
//                                   color: primaryColor,
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Text(
//                                   'No new comments yet',
//                                   style: TextStyle(
//                                     color: darkText,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Be the first to comment.',
//                                   style: TextStyle(
//                                     color: Colors.grey.shade600,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : ListView.builder(
//                             padding: const EdgeInsets.all(15),
//                             itemCount: postComments.length,
//                             itemBuilder: (context, index) {
//                               return Container(
//                                 margin: const EdgeInsets.only(
//                                   bottom: 10,
//                                 ),
//                                 padding:
//                                     const EdgeInsets.all(11),
//                                 decoration: BoxDecoration(
//                                   color: backgroundColor,
//                                   borderRadius:
//                                       BorderRadius.circular(14),
//                                 ),
//                                 child: Row(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                   children: [
//                                     CircleAvatar(
//                                       radius: 16,
//                                       backgroundColor:
//                                           lightBlue,
//                                       child: Icon(
//                                         Icons.person,
//                                         size: 18,
//                                         color: primaryColor,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 9),
//                                     Expanded(
//                                       child: Text(
//                                         postComments[index],
//                                         style: const TextStyle(
//                                           color: darkText,
//                                           fontSize: 12,
//                                           height: 1.4,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                   ),

//                   Container(
//                     padding: EdgeInsets.fromLTRB(
//                       12,
//                       8,
//                       12,
//                       MediaQuery.of(context)
//                           .viewInsets
//                           .bottom +
//                           10,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.06),
//                           blurRadius: 8,
//                           offset: const Offset(0, -2),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: controller,
//                             minLines: 1,
//                             maxLines: 3,
//                             textInputAction:
//                                 TextInputAction.newline,
//                             decoration: InputDecoration(
//                               hintText:
//                                   'Write a comment...',
//                               hintStyle: TextStyle(
//                                 color: Colors.grey.shade500,
//                                 fontSize: 12,
//                               ),
//                               filled: true,
//                               fillColor: backgroundColor,
//                               contentPadding:
//                                   const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 11,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius:
//                                     BorderRadius.circular(22),
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         GestureDetector(
//                           onTap: () {
//                             final String comment =
//                                 controller.text.trim();

//                             if (comment.isEmpty) {
//                               return;
//                             }

//                             setState(() {
//                               _comments
//                                   .putIfAbsent(
//                                     postId,
//                                     () => [],
//                                   )
//                                   .add(comment);

//                               _commentCounts[postId] =
//                                   (_commentCounts[postId] ??
//                                       0) +
//                                   1;
//                             });

//                             controller.clear();
//                             setSheetState(() {});
//                           },
//                           child: Container(
//                             width: 43,
//                             height: 43,
//                             decoration: BoxDecoration(
//                               color: primaryColor,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.send_rounded,
//                               color: Colors.white,
//                               size: 18,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     ).whenComplete(controller.dispose);
//   }





//   // ============================================================
//   // COLORS
//   // ============================================================

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color darkText = const Color(0xFF062B35);

//   final Color backgroundColor = const Color(0xFFEFF9FD);
//   final Color lightBlue = const Color(0xFFE4F5FB);

//   // ============================================================
//   // CATEGORY
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Success Stories',
//     'Announcements',
//     'Tips',
//   ];

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,

//       body: SafeArea(
//         child: Column(
//           children: [
//             // ==================================================
//             // HEADER
//             // ==================================================

//             _buildHeader(),

//             // ==================================================
//             // CATEGORY BAR
//             // ==================================================

//             _buildCategoryBar(),

//             // ==================================================
//             // FEED
//             // ==================================================

//             Expanded(
//               child: Stack(
//                 children: [
//                   _buildFeed(),

//                   // ==================================================
//                   // FLOATING CREATE POST BUTTON
//                   // ==================================================

//                   Positioned(
//                     right: 14,
//                     bottom: 18,
//                     child: _buildCreatePostButton(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       color: backgroundColor,
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         8,
//         14,
//         8,
//       ),
//       child: Row(
//         children: [
//           // ==================================================
//           // COMMUNITY LOGO
//           // ==================================================

//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               border: Border.all(
//                 color: const Color(0xFFD9E4E7),
//                 width: 1,
//               ),
//             ),
//             child: ClipOval(
//               child: Image.network(
//                 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=200',
//                 fit: BoxFit.cover,
//                 errorBuilder: (
//                   context,
//                   error,
//                   stackTrace,
//                 ) {
//                   return Icon(
//                     Icons.pets_rounded,
//                     color: primaryColor,
//                     size: 20,
//                   );
//                 },
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           // ==================================================
//           // TITLE
//           // ==================================================

//           Expanded(
//             child: Text(
//               'Community',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 25,
//                 fontWeight: FontWeight.bold,
//                 height: 1,
//               ),
//             ),
//           ),

//           // ==================================================
//           // NOTIFICATION
//           // ==================================================

//           IconButton(
//             onPressed: () {
//               _showMessage(
//                 'No new notifications.',
//               );
//             },
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 34,
//               minHeight: 34,
//             ),
//             icon: Icon(
//               Icons.notifications_none_rounded,
//               color: primaryColor,
//               size: 21,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY BAR
//   // ============================================================

//   Widget _buildCategoryBar() {
//     return Container(
//       width: double.infinity,
//       color: backgroundColor,
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         2,
//         0,
//         10,
//       ),
//       child: SizedBox(
//         height: 34,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           physics: const BouncingScrollPhysics(),
//           itemCount: categories.length,
//           separatorBuilder: (
//             context,
//             index,
//           ) {
//             return const SizedBox(width: 7);
//           },
//           itemBuilder: (
//             context,
//             index,
//           ) {
//             final String category =
//                 categories[index];

//             final bool selected =
//                 selectedCategory == category;

//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(
//                   milliseconds: 180,
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(
//                   horizontal: 16,
//                 ),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? primaryColor
//                       : Colors.white,
//                   borderRadius:
//                       BorderRadius.circular(20),
//                   border: Border.all(
//                     color: selected
//                         ? primaryColor
//                         : const Color(0xFF8E7771),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected
//                         ? Colors.white
//                         : darkText,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FEED
//   // ============================================================

//   Widget _buildFeed() {
//     final List<Widget> posts = [];

//     // ==========================================================
//     // FIRST POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Success Stories') {
//       posts.add(
//         _buildCommunityPost(
//           postId: 'luna_success',
//           profileImage:
//               'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?auto=format&fit=crop&w=200&q=80',
//           author:
//               'JAGNA ANIMAL LOVER AND RESCUE GROUP Admin',
//           time: '2 hours ago',
//           postImage:
//               'https://images.unsplash.com/photo-1542736667-069246bdbc74?auto=format&fit=crop&w=900&q=80',
//           content:
//               'Luna has finally found her forever home! After 6 months at the shelter, this sweet girl is going to her new loving family. Thank you to everyone who shared her story. ❤️\n#AdoptionSuccess #HappyTails',
//           likes: '1.2k',
//           comments: '84',
//         ),
//       );

//       posts.add(
//         const SizedBox(height: 12),
//       );
//     }

//     // ==========================================================
//     // SECOND POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Tips') {
//       posts.add(
//         _buildTextPost(
//           postId: 'joe_foster',
//           profileImage:
//               'https://i.pravatar.cc/150?img=47',
//           author: 'JoeAss',
//           time: '5 hours ago',
//           content:
//               'Hi everyone! We just brought home our new foster puppy, Max. He’s a bit anxious around our older dog. Any tips for smooth introductions over the first few days? 🐶',
//           // likes: '45',
//           // comments: '12',
//           likes: _likeCounts['joe_foster'] ?? 45,
//           comments: _commentCounts['joe_foster'] ?? 12,
//         ),
//       );

//       posts.add(
//         const SizedBox(height: 12),
//       );
//     }

//     // ==========================================================
//     // THIRD POST
//     // ==========================================================

//     if (selectedCategory == 'All' ||
//         selectedCategory == 'Announcements') {
//       posts.add(
//         _buildTextPost(
//           postId: 'my_future_pet',
//           profileImage:
//               'https://i.pravatar.cc/150?img=32',
//           author: 'My Future Pet',
//           time: '1 day ago',
//           content:
//               'Remember that adopting a pet is a lifetime commitment. Give your new companion time, patience, and lots of love while they adjust to their new home. 🐾',
//           // likes: '86',
//           // comments: '18',
//           likes: _likeCounts['my_future_pet'] ?? 86,
//           comments: _commentCounts['my_future_pet'] ?? 18,   
//         ),
//       );
//     }

//     // ==========================================================
//     // NO POSTS
//     // ==========================================================

//     if (posts.isEmpty) {
//       return _buildEmptyFeed();
//     }

//     return ListView(
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(
//         14,
//         2,
//         14,
//         85,
//       ),
//       children: posts,
//     );
//   }

//   // ============================================================
//   // COMMUNITY POST WITH IMAGE
//   // ============================================================

//   Widget _buildCommunityPost({
//   required String postId,
//   required String profileImage,
//   required String author,
//   required String time,
//   required String postImage,
//   required String content,
//   required int likes,
//   required int comments,
//   }) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFCFE8F0),
//           width: 1,
//         ),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // ==================================================
//           // POST HEADER
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               12,
//               11,
//               10,
//               10,
//             ),
//             child: Row(
//               children: [
//                 // PROFILE IMAGE
//                 ClipOval(
//                   child: Image.network(
//                     profileImage,
//                     width: 34,
//                     height: 34,
//                     fit: BoxFit.cover,
//                     errorBuilder: (
//                       context,
//                       error,
//                       stackTrace,
//                     ) {
//                       return Container(
//                         width: 34,
//                         height: 34,
//                         color: lightBlue,
//                         child: Icon(
//                           Icons.person,
//                           color: primaryColor,
//                           size: 20,
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 9),

//                 // AUTHOR
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         author,
//                         maxLines: 2,
//                         overflow:
//                             TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: darkText,
//                           fontSize: 13,
//                           fontWeight: FontWeight.bold,
//                           height: 1.15,
//                         ),
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         time,
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 9,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // MORE
//                 Icon(
//                   Icons.more_horiz_rounded,
//                   color: Colors.grey.shade600,
//                   size: 20,
//                 ),
//               ],
//             ),
//           ),

//           // ==================================================
//           // POST IMAGE
//           // ==================================================

//           SizedBox(
//             width: double.infinity,
//             height: 274,
//             child: Image.network(
//               postImage,
//               fit: BoxFit.cover,
//               errorBuilder: (
//                 context,
//                 error,
//                 stackTrace,
//               ) {
//                 return Container(
//                   color: lightBlue,
//                   child: Icon(
//                     Icons.image_outlined,
//                     color: primaryColor,
//                     size: 45,
//                   ),
//                 );
//               },
//             ),
//           ),

//           // ==================================================
//           // CONTENT
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               13,
//               13,
//               13,
//               8,
//             ),
//             child: Text(
//               content,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 12,
//                 height: 1.42,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),

//           // ==================================================
//           // DIVIDER
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 13,
//             ),
//             child: Divider(
//               height: 1,
//               color: Colors.grey.shade200,
//             ),
//           ),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               13,
//               8,
//               13,
//               9,
//             ),
//             child: Row(
//               children: [
//                 _buildActionButton(
//                   icon:
//                       Icons.favorite_border_rounded,
//                   text: likes,
//                 ),

//                 const SizedBox(width: 20),

//                 _buildActionButton(
//                   icon:
//                       Icons.chat_bubble_outline_rounded,
//                   text: comments,
//                 ),

//                 const Spacer(),

//                 GestureDetector(
//                   onTap: () {
//                     _showMessage(
//                       'Post shared.',
//                     );
//                   },
//                   child: Icon(
//                     Icons.share_outlined,
//                     size: 17,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // TEXT POST
//   // ============================================================

//   Widget _buildTextPost({
//   required String postId,
//   required String profileImage,
//   required String author,
//   required String time,
//   required String content,
//   required int likes,
//   required int comments,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(13),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFCFE8F0),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           // ==================================================
//           // HEADER
//           // ==================================================

//           Row(
//             children: [
//               ClipOval(
//                 child: Image.network(
//                   profileImage,
//                   width: 34,
//                   height: 34,
//                   fit: BoxFit.cover,
//                   errorBuilder: (
//                     context,
//                     error,
//                     stackTrace,
//                   ) {
//                     return Container(
//                       width: 34,
//                       height: 34,
//                       color: lightBlue,
//                       child: Icon(
//                         Icons.person,
//                         color: primaryColor,
//                         size: 20,
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(width: 9),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       author,
//                       maxLines: 1,
//                       overflow:
//                           TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: darkText,
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 3),

//                     Text(
//                       time,
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 9,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Icon(
//                 Icons.more_horiz_rounded,
//                 color: Colors.grey.shade600,
//                 size: 20,
//               ),
//             ],
//           ),

//           const SizedBox(height: 14),

//           // ==================================================
//           // CONTENT
//           // ==================================================

//           Text(
//             content,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 12,
//               height: 1.45,
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ==================================================
//           // DIVIDER
//           // ==================================================

//           Divider(
//             height: 1,
//             color: Colors.grey.shade200,
//           ),

//           const SizedBox(height: 8),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Row(
//             children: [
//               _buildActionButton(
//                 icon:
//                     Icons.favorite_border_rounded,
//                 text: likes,
//               ),

//               const SizedBox(width: 20),

//               _buildActionButton(
//                 icon:
//                     Icons.chat_bubble_outline_rounded,
//                 text: comments,
//               ),

//               const Spacer(),

//               GestureDetector(
//                 onTap: () {
//                   _showMessage(
//                     'Post shared.',
//                   );
//                 },
//                 child: Icon(
//                   Icons.share_outlined,
//                   size: 17,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // ACTION BUTTON
//   // ============================================================

//   Widget _buildActionButton({
//     required String postId,
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//     bool active = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       behavior: HitTestBehavior.opaque,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 17,
//             color: active
//                 ? primaryColor
//                 : Colors.grey.shade600,
//           ),
//           const SizedBox(width: 5),
//           Text(
//             text,
//             style: TextStyle(
//               color: active
//                   ? primaryColor
//                   : Colors.grey.shade600,
//               fontSize: 10,
//               fontWeight: active
//                   ? FontWeight.bold
//                   : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // FLOATING CREATE POST BUTTON
//   // ============================================================

//   Widget _buildCreatePostButton() {
//     return GestureDetector(
//       onTap: () {
//         _showCreatePostDialog();
//       },
//       child: Container(
//         width: 49,
//         height: 49,
//         decoration: BoxDecoration(
//           color: primaryColor,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.18),
//               blurRadius: 7,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: const Icon(
//           Icons.edit_rounded,
//           color: Colors.white,
//           size: 19,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY FEED
//   // ============================================================

//   Widget _buildEmptyFeed() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.only(
//           top: 70,
//           left: 20,
//           right: 20,
//         ),
//         child: Column(
//           children: [
//             Icon(
//               Icons.forum_outlined,
//               size: 55,
//               color: primaryColor,
//             ),

//             const SizedBox(height: 15),

//             Text(
//               'No posts found',
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 19,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 6),

//             Text(
//               'There are no posts in this category yet.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 12,
//               ),
//             ),

//             const SizedBox(height: 18),

//             OutlinedButton(
//               onPressed: () {
//                 setState(() {
//                   selectedCategory = 'All';
//                 });
//               },
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: primaryColor,
//                 side: BorderSide(
//                   color: primaryColor,
//                 ),
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(20),
//                 ),
//               ),
//               child: const Text(
//                 'View All Posts',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CREATE POST DIALOG
//   // ============================================================

//   void _showCreatePostDialog() {
//     final TextEditingController controller =
//         TextEditingController();

//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),

//           // ==================================================
//           // TITLE
//           // ==================================================

//           title: Text(
//             'Create Post',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 19,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           // ==================================================
//           // CONTENT
//           // ==================================================

//           content: TextField(
//             controller: controller,
//             maxLines: 5,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 13,
//             ),
//             decoration: InputDecoration(
//               hintText:
//                   'Share something with the community...',
//               hintStyle: TextStyle(
//                 color: Colors.grey.shade500,
//                 fontSize: 12,
//               ),
//               filled: true,
//               fillColor: backgroundColor,
//               border: OutlineInputBorder(
//                 borderRadius:
//                     BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ),

//             ElevatedButton(
//               onPressed: () {
//                 if (controller.text
//                     .trim()
//                     .isEmpty) {
//                   return;
//                 }

//                 Navigator.pop(dialogContext);

//                 _showMessage(
//                   'Post created successfully!',
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryColor,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(18),
//                 ),
//               ),
//               child: const Text(
//                 'Post',
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(
//           seconds: 2,
//         ),
//       ),
//     );
//   }
// }




















// import 'package:flutter/material.dart';

// // ============================================================
// // COMMUNITY FEED SCREEN
// // ============================================================

// class FeedScreen extends StatefulWidget {
//   const FeedScreen({
//     super.key,
//   });

//   @override
//   State<FeedScreen> createState() =>
//       _FeedScreenState();
// }

// class _FeedScreenState
//     extends State<FeedScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color darkText = const Color(0xFF062B35);
//   final Color tealColor = const Color(0xFF008F82);
//   final Color detailBrown = const Color(0xFF604A45);
//   final Color detailBlue = const Color(0xFFEFF9FD);
//   final Color lightBlue = const Color(0xFFE4F5FB);

//   // ============================================================
//   // SELECTED CATEGORY
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Success Stories',
//     'Announcements',
//     'Tips',
//   ];

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: detailBrown,

//       // ========================================================
//       // BODY
//       // ========================================================

//       body: SafeArea(
//         child: Column(
//           children: [

//             // ==================================================
//             // TOP HEADER
//             // ==================================================

//             Container(
//               color: detailBlue,

//               padding: const EdgeInsets.fromLTRB(
//                 16,
//                 10,
//                 16,
//                 8,
//               ),

//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,

//                 children: [

//                   // COMMUNITY TITLE
//                   Row(
//                     mainAxisAlignment:
//                         MainAxisAlignment.spaceBetween,

//                     children: [

//                       Text(
//                         'Community',
//                         style: TextStyle(
//                           color: primaryColor,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       Icon(
//                         Icons.notifications_none,
//                         color: primaryColor,
//                         size: 18,
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 10),

//                   // ==================================================
//                   // CATEGORY FILTER
//                   // ==================================================

//                   SizedBox(
//                     height: 30,

//                     child: ListView.separated(
//                       scrollDirection: Axis.horizontal,

//                       itemCount: categories.length,

//                       separatorBuilder:
//                           (context, index) =>
//                               const SizedBox(
//                         width: 6,
//                       ),

//                       itemBuilder:
//                           (context, index) {
//                         final category =
//                             categories[index];

//                         final isSelected =
//                             selectedCategory ==
//                                 category;

//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               selectedCategory =
//                                   category;
//                             });
//                           },

//                           child: Container(
//                             padding:
//                                 const EdgeInsets
//                                     .symmetric(
//                               horizontal: 12,
//                             ),

//                             alignment:
//                                 Alignment.center,

//                             decoration:
//                                 BoxDecoration(
//                               color: isSelected
//                                   ? primaryColor
//                                   : Colors.white,

//                               borderRadius:
//                                   BorderRadius.circular(
//                                 15,
//                               ),

//                               border: Border.all(
//                                 color: isSelected
//                                     ? primaryColor
//                                     : Colors
//                                         .grey
//                                         .shade400,
//                               ),
//                             ),

//                             child: Text(
//                               category,
//                               style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight:
//                                     FontWeight.w500,
//                                 color: isSelected
//                                     ? Colors.white
//                                     : darkText,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==================================================
//             // FEED
//             // ==================================================

//             Expanded(
//               child: Container(
//                 color: detailBlue,

//                 child: Stack(
//                   children: [

//                     // ==================================================
//                     // POSTS
//                     // ==================================================

//                     ListView(
//                       padding:
//                           const EdgeInsets.fromLTRB(
//                         16,
//                         8,
//                         16,
//                         80,
//                       ),

//                       children: [

//                         // ==================================================
//                         // FIRST POST
//                         // ==================================================

//                         _buildCommunityPost(
//                           profileImage:
//                               'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?auto=format&fit=crop&w=200&q=80',

//                           author:
//                               'JAGNA ANIMAL LOVER AND RESCUE GROUP Admin',

//                           time:
//                               '2 hours ago',

//                           postImage:
//                               'https://images.unsplash.com/photo-1542736667-069246bdbc74?auto=format&fit=crop&w=900&q=80',

//                           content:
//                               'Luna has finally found her forever home! After 6 months at the shelter, this sweet girl is going to her new loving family. Thank you to everyone who shared her story. ❤️\n#AdoptionSuccess #HappyTails',

//                           likes: '1.2k',

//                           comments: '84',

//                           category:
//                               'Success Stories',
//                         ),

//                         const SizedBox(height: 12),

//                         // ==================================================
//                         // SECOND POST
//                         // ==================================================

//                         _buildTextPost(
//                           profileImage:
//                               'https://i.pravatar.cc/150?img=47',

//                           author: 'JoeAss',

//                           time: '5 hours ago',

//                           content:
//                               'Hi everyone! We just brought home our new foster puppy, Max. He’s a bit anxious around older dogs. Any tips for smooth introductions over the first few days? 🐶',

//                           likes: '45',

//                           comments: '12',

//                           category: 'Tips',
//                         ),

//                         const SizedBox(height: 12),

//                         // ==================================================
//                         // THIRD POST
//                         // ==================================================

//                         _buildTextPost(
//                           profileImage:
//                               'https://i.pravatar.cc/150?img=32',

//                           author: 'My Future Pet',

//                           time: '1 day ago',

//                           content:
//                               'Remember that adopting a pet is a lifetime commitment. Give your new companion time, patience, and lots of love while they adjust to their new home. 🐾',

//                           likes: '86',

//                           comments: '18',

//                           category:
//                               'Announcements',
//                         ),
//                       ],
//                     ),

//                     // ==================================================
//                     // FLOATING CREATE BUTTON
//                     // ==================================================

//                     Positioned(
//                       right: 10,
//                       bottom: 18,

//                       child: GestureDetector(
//                         onTap: () {
//                           _showCreatePostDialog();
//                         },

//                         child: Container(
//                           width: 42,
//                           height: 42,

//                           decoration:
//                               BoxDecoration(
//                             color: primaryColor,
//                             borderRadius:
//                                 BorderRadius.circular(
//                               11,
//                             ),

//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black
//                                     .withOpacity(
//                                   0.18,
//                                 ),
//                                 blurRadius: 6,
//                                 offset:
//                                     const Offset(
//                                   0,
//                                   3,
//                                 ),
//                               ),
//                             ],
//                           ),

//                           child: const Icon(
//                             Icons.edit,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // COMMUNITY POST WITH IMAGE
//   // ============================================================

//   Widget _buildCommunityPost({
//     required String profileImage,
//     required String author,
//     required String time,
//     required String postImage,
//     required String content,
//     required String likes,
//     required String comments,
//     required String category,
//   }) {
//     if (selectedCategory != 'All' &&
//         selectedCategory != category) {
//       return const SizedBox.shrink();
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(14),

//         border: Border.all(
//           color: const Color(0xFFD2E7ED),
//         ),
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [

//           // ==================================================
//           // POST HEADER
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               10,
//               10,
//               10,
//               8,
//             ),

//             child: Row(
//               children: [

//                 // PROFILE IMAGE
//                 ClipOval(
//                   child: Image.network(
//                     profileImage,
//                     width: 28,
//                     height: 28,
//                     fit: BoxFit.cover,

//                     errorBuilder:
//                         (context, error, stackTrace) {
//                       return Container(
//                         width: 28,
//                         height: 28,
//                         color: lightBlue,
//                         child: Icon(
//                           Icons.person,
//                           color: primaryColor,
//                           size: 17,
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 8),

//                 // AUTHOR
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,

//                     children: [
//                       Text(
//                         author,
//                         maxLines: 2,
//                         overflow:
//                             TextOverflow.ellipsis,

//                         style: TextStyle(
//                           fontSize: 9,
//                           fontWeight:
//                               FontWeight.bold,
//                           color: darkText,
//                         ),
//                       ),

//                       const SizedBox(height: 2),

//                       Text(
//                         time,
//                         style: TextStyle(
//                           fontSize: 7,
//                           color:
//                               Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Icon(
//                   Icons.more_horiz,
//                   color: Colors.grey.shade500,
//                   size: 18,
//                 ),
//               ],
//             ),
//           ),

//           // ==================================================
//           // POST IMAGE
//           // ==================================================

//           ClipRRect(
//             borderRadius:
//                 const BorderRadius.vertical(
//               top: Radius.zero,
//             ),

//             child: Image.network(
//               postImage,

//               width: double.infinity,
//               height: 180,

//               fit: BoxFit.cover,

//               errorBuilder:
//                   (context, error, stackTrace) {
//                 return Container(
//                   width: double.infinity,
//                   height: 180,
//                   color: lightBlue,

//                   child: Icon(
//                     Icons.image_outlined,
//                     color: primaryColor,
//                     size: 40,
//                   ),
//                 );
//               },
//             ),
//           ),

//           // ==================================================
//           // POST CONTENT
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               10,
//               10,
//               10,
//               5,
//             ),

//             child: Text(
//               content,
//               style: TextStyle(
//                 fontSize: 9,
//                 color: darkText,
//                 height: 1.45,
//               ),
//             ),
//           ),

//           // ==================================================
//           // DIVIDER
//           // ==================================================

//           Divider(
//             height: 1,
//             color: Colors.grey.shade200,
//           ),

//           // ==================================================
//           // POST ACTIONS
//           // ==================================================

//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 10,
//               vertical: 7,
//             ),

//             child: Row(
//               children: [

//                 _buildActionButton(
//                   icon: Icons.favorite_border,
//                   text: likes,
//                 ),

//                 const SizedBox(width: 18),

//                 _buildActionButton(
//                   icon: Icons.chat_bubble_outline,
//                   text: comments,
//                 ),

//                 const Spacer(),

//                 Icon(
//                   Icons.share_outlined,
//                   size: 14,
//                   color: Colors.grey.shade600,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // TEXT POST
//   // ============================================================

//   Widget _buildTextPost({
//     required String profileImage,
//     required String author,
//     required String time,
//     required String content,
//     required String likes,
//     required String comments,
//     required String category,
//   }) {
//     if (selectedCategory != 'All' &&
//         selectedCategory != category) {
//       return const SizedBox.shrink();
//     }

//     return Container(
//       padding: const EdgeInsets.all(10),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(14),

//         border: Border.all(
//           color: const Color(0xFFD2E7ED),
//         ),
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [

//           // ==================================================
//           // USER HEADER
//           // ==================================================

//           Row(
//             children: [

//               ClipOval(
//                 child: Image.network(
//                   profileImage,

//                   width: 28,
//                   height: 28,

//                   fit: BoxFit.cover,

//                   errorBuilder:
//                       (context, error, stackTrace) {
//                     return Container(
//                       width: 28,
//                       height: 28,
//                       color: lightBlue,
//                       child: Icon(
//                         Icons.person,
//                         size: 17,
//                         color: primaryColor,
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(width: 8),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,

//                   children: [

//                     Text(
//                       author,
//                       style: TextStyle(
//                         fontSize: 9,
//                         fontWeight:
//                             FontWeight.bold,
//                         color: darkText,
//                       ),
//                     ),

//                     const SizedBox(height: 2),

//                     Text(
//                       time,
//                       style: TextStyle(
//                         fontSize: 7,
//                         color:
//                             Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Icon(
//                 Icons.more_horiz,
//                 color: Colors.grey.shade500,
//                 size: 18,
//               ),
//             ],
//           ),

//           const SizedBox(height: 10),

//           // ==================================================
//           // CONTENT
//           // ==================================================

//           Text(
//             content,
//             style: TextStyle(
//               fontSize: 9,
//               color: darkText,
//               height: 1.45,
//             ),
//           ),

//           const SizedBox(height: 8),

//           Divider(
//             height: 1,
//             color: Colors.grey.shade200,
//           ),

//           const SizedBox(height: 7),

//           // ==================================================
//           // ACTIONS
//           // ==================================================

//           Row(
//             children: [

//               _buildActionButton(
//                 icon: Icons.favorite_border,
//                 text: likes,
//               ),

//               const SizedBox(width: 18),

//               _buildActionButton(
//                 icon: Icons.chat_bubble_outline,
//                 text: comments,
//               ),

//               const Spacer(),

//               Icon(
//                 Icons.share_outlined,
//                 size: 14,
//                 color: Colors.grey.shade600,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // ACTION BUTTON
//   // ============================================================

//   Widget _buildActionButton({
//     required IconData icon,
//     required String text,
//   }) {
//     return Row(
//       children: [

//         Icon(
//           icon,
//           size: 13,
//           color: Colors.grey.shade600,
//         ),

//         const SizedBox(width: 4),

//         Text(
//           text,
//           style: TextStyle(
//             fontSize: 8,
//             color: Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // CREATE POST DIALOG
//   // ============================================================

//   void _showCreatePostDialog() {
//     final TextEditingController controller =
//         TextEditingController();

//     showDialog(
//       context: context,

//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: Colors.white,

//           shape: RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(18),
//           ),

//           title: Text(
//             'Create Post',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           content: TextField(
//             controller: controller,

//             maxLines: 4,

//             decoration: InputDecoration(
//               hintText:
//                   'Share something with the community...',

//               hintStyle: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey.shade500,
//               ),

//               filled: true,

//               fillColor: detailBlue,

//               border: OutlineInputBorder(
//                 borderRadius:
//                     BorderRadius.circular(12),

//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),

//           actions: [

//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },

//               child: Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ),

//             ElevatedButton(
//               onPressed: () {
//                 if (controller.text.trim().isEmpty) {
//                   return;
//                 }

//                 Navigator.pop(dialogContext);

//                 ScaffoldMessenger.of(context)
//                     .showSnackBar(
//                   const SnackBar(
//                     content: Text(
//                       'Post created successfully!',
//                     ),
//                   ),
//                 );
//               },

//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     primaryColor,

//                 foregroundColor:
//                     Colors.white,

//                 elevation: 0,

//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(18),
//                 ),
//               ),

//               child: const Text(
//                 'Post',
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }













// import 'package:flutter/material.dart';

// class FeedScreen extends StatelessWidget {
//   const FeedScreen({super.key});

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color backgroundColor = const Color(0xFFF5FAFD);
//   final Color darkText = const Color(0xFF062B35);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: false,
//         title: Text(
//           'Community Feed',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.people_outline,
//               size: 70,
//               color: primaryColor,
//             ),

//             const SizedBox(height: 20),

//             Text(
//               'Community Feed',
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 8),

//             const Text(
//               'See updates from the pet community.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }