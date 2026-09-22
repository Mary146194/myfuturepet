import 'package:flutter/material.dart';

// ============================================================
// COMMUNITY FEED SCREEN
// ============================================================

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({
    super.key,
  });

  @override
  State<CommunityFeedScreen> createState() =>
      _CommunityFeedScreenState();
}

class _CommunityFeedScreenState
    extends State<CommunityFeedScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  final Color primaryColor = const Color(0xFFA94327);
  final Color darkText = const Color(0xFF062B35);
  final Color tealColor = const Color(0xFF008F82);
  final Color detailBrown = const Color(0xFF604A45);
  final Color detailBlue = const Color(0xFFEFF9FD);
  final Color lightBlue = const Color(0xFFE4F5FB);

  // ============================================================
  // SELECTED CATEGORY
  // ============================================================

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Success Stories',
    'Announcements',
    'Tips',
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: detailBrown,

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // TOP HEADER
            // ==================================================

            Container(
              color: detailBlue,

              padding: const EdgeInsets.fromLTRB(
                16,
                10,
                16,
                8,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // COMMUNITY TITLE
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [

                      Text(
                        'Community',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Icon(
                        Icons.notifications_none,
                        color: primaryColor,
                        size: 18,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // CATEGORY FILTER
                  // ==================================================

                  SizedBox(
                    height: 30,

                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,

                      itemCount: categories.length,

                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(
                        width: 6,
                      ),

                      itemBuilder:
                          (context, index) {
                        final category =
                            categories[index];

                        final isSelected =
                            selectedCategory ==
                                category;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory =
                                  category;
                            });
                          },

                          child: Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                            ),

                            alignment:
                                Alignment.center,

                            decoration:
                                BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.white,

                              borderRadius:
                                  BorderRadius.circular(
                                15,
                              ),

                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors
                                        .grey
                                        .shade400,
                              ),
                            ),

                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight:
                                    FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : darkText,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // FEED
            // ==================================================

            Expanded(
              child: Container(
                color: detailBlue,

                child: Stack(
                  children: [

                    // ==================================================
                    // POSTS
                    // ==================================================

                    ListView(
                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        80,
                      ),

                      children: [

                        // ==================================================
                        // FIRST POST
                        // ==================================================

                        _buildCommunityPost(
                          profileImage:
                              'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?auto=format&fit=crop&w=200&q=80',

                          author:
                              'JAGNA ANIMAL LOVER AND RESCUE GROUP Admin',

                          time:
                              '2 hours ago',

                          postImage:
                              'https://images.unsplash.com/photo-1542736667-069246bdbc74?auto=format&fit=crop&w=900&q=80',

                          content:
                              'Luna has finally found her forever home! After 6 months at the shelter, this sweet girl is going to her new loving family. Thank you to everyone who shared her story. ❤️\n#AdoptionSuccess #HappyTails',

                          likes: '1.2k',

                          comments: '84',

                          category:
                              'Success Stories',
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // SECOND POST
                        // ==================================================

                        _buildTextPost(
                          profileImage:
                              'https://i.pravatar.cc/150?img=47',

                          author: 'JoeAss',

                          time: '5 hours ago',

                          content:
                              'Hi everyone! We just brought home our new foster puppy, Max. He’s a bit anxious around older dogs. Any tips for smooth introductions over the first few days? 🐶',

                          likes: '45',

                          comments: '12',

                          category: 'Tips',
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // THIRD POST
                        // ==================================================

                        _buildTextPost(
                          profileImage:
                              'https://i.pravatar.cc/150?img=32',

                          author: 'My Future Pet',

                          time: '1 day ago',

                          content:
                              'Remember that adopting a pet is a lifetime commitment. Give your new companion time, patience, and lots of love while they adjust to their new home. 🐾',

                          likes: '86',

                          comments: '18',

                          category:
                              'Announcements',
                        ),
                      ],
                    ),

                    // ==================================================
                    // FLOATING CREATE BUTTON
                    // ==================================================

                    Positioned(
                      right: 10,
                      bottom: 18,

                      child: GestureDetector(
                        onTap: () {
                          _showCreatePostDialog();
                        },

                        child: Container(
                          width: 42,
                          height: 42,

                          decoration:
                              BoxDecoration(
                            color: primaryColor,
                            borderRadius:
                                BorderRadius.circular(
                              11,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(
                                  0.18,
                                ),
                                blurRadius: 6,
                                offset:
                                    const Offset(
                                  0,
                                  3,
                                ),
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COMMUNITY POST WITH IMAGE
  // ============================================================

  Widget _buildCommunityPost({
    required String profileImage,
    required String author,
    required String time,
    required String postImage,
    required String content,
    required String likes,
    required String comments,
    required String category,
  }) {
    if (selectedCategory != 'All' &&
        selectedCategory != category) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: const Color(0xFFD2E7ED),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // ==================================================
          // POST HEADER
          // ==================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              10,
              10,
              10,
              8,
            ),

            child: Row(
              children: [

                // PROFILE IMAGE
                ClipOval(
                  child: Image.network(
                    profileImage,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,

                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        width: 28,
                        height: 28,
                        color: lightBlue,
                        child: Icon(
                          Icons.person,
                          color: primaryColor,
                          size: 17,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // AUTHOR
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

                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                              FontWeight.bold,
                          color: darkText,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 7,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.more_horiz,
                  color: Colors.grey.shade500,
                  size: 18,
                ),
              ],
            ),
          ),

          // ==================================================
          // POST IMAGE
          // ==================================================

          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.zero,
            ),

            child: Image.network(
              postImage,

              width: double.infinity,
              height: 180,

              fit: BoxFit.cover,

              errorBuilder:
                  (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 180,
                  color: lightBlue,

                  child: Icon(
                    Icons.image_outlined,
                    color: primaryColor,
                    size: 40,
                  ),
                );
              },
            ),
          ),

          // ==================================================
          // POST CONTENT
          // ==================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              10,
              10,
              10,
              5,
            ),

            child: Text(
              content,
              style: TextStyle(
                fontSize: 9,
                color: darkText,
                height: 1.45,
              ),
            ),
          ),

          // ==================================================
          // DIVIDER
          // ==================================================

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          // ==================================================
          // POST ACTIONS
          // ==================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),

            child: Row(
              children: [

                _buildActionButton(
                  icon: Icons.favorite_border,
                  text: likes,
                ),

                const SizedBox(width: 18),

                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  text: comments,
                ),

                const Spacer(),

                Icon(
                  Icons.share_outlined,
                  size: 14,
                  color: Colors.grey.shade600,
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
    required String profileImage,
    required String author,
    required String time,
    required String content,
    required String likes,
    required String comments,
    required String category,
  }) {
    if (selectedCategory != 'All' &&
        selectedCategory != category) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: const Color(0xFFD2E7ED),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // ==================================================
          // USER HEADER
          // ==================================================

          Row(
            children: [

              ClipOval(
                child: Image.network(
                  profileImage,

                  width: 28,
                  height: 28,

                  fit: BoxFit.cover,

                  errorBuilder:
                      (context, error, stackTrace) {
                    return Container(
                      width: 28,
                      height: 28,
                      color: lightBlue,
                      child: Icon(
                        Icons.person,
                        size: 17,
                        color: primaryColor,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      author,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight:
                            FontWeight.bold,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 7,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.more_horiz,
                color: Colors.grey.shade500,
                size: 18,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ==================================================
          // CONTENT
          // ==================================================

          Text(
            content,
            style: TextStyle(
              fontSize: 9,
              color: darkText,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 8),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          const SizedBox(height: 7),

          // ==================================================
          // ACTIONS
          // ==================================================

          Row(
            children: [

              _buildActionButton(
                icon: Icons.favorite_border,
                text: likes,
              ),

              const SizedBox(width: 18),

              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                text: comments,
              ),

              const Spacer(),

              Icon(
                Icons.share_outlined,
                size: 14,
                color: Colors.grey.shade600,
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
  }) {
    return Row(
      children: [

        Icon(
          icon,
          size: 13,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 4),

        Text(
          text,
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CREATE POST DIALOG
  // ============================================================

  void _showCreatePostDialog() {
    final TextEditingController controller =
        TextEditingController();

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),

          title: Text(
            'Create Post',
            style: TextStyle(
              color: darkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: TextField(
            controller: controller,

            maxLines: 4,

            decoration: InputDecoration(
              hintText:
                  'Share something with the community...',

              hintStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),

              filled: true,

              fillColor: detailBlue,

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),

                borderSide: BorderSide.none,
              ),
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Post created successfully!',
                    ),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,

                foregroundColor:
                    Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
              ),

              child: const Text(
                'Post',
              ),
            ),
          ],
        );
      },
    );
  }
}