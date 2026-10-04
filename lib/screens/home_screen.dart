import 'package:flutter/material.dart';

import '../pet_data.dart';
import 'pets_screen.dart';
import 'ar_view_screen.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // NAVIGATION
  // ============================================================

  int _selectedIndex = 0;

  String _petsCategory = 'All';

  bool _openSearch = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFFF5FAFD);

  // ============================================================
  // OPEN PETS TAB
  // ============================================================

  void _openPets({
    String category = 'All',
    bool search = false,
  }) {
    setState(() {
      _petsCategory = category;
      _openSearch = search;
      _selectedIndex = 1;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeContentScreen(
              onOpenPets: ({
                String category = 'All',
                bool search = false,
              }) {
                _openPets(
                  category: category,
                  search: search,
                );
              },
            ),

            PetsScreen(
              key: ValueKey(
                '$_petsCategory-$_openSearch',
              ),
              initialCategory: _petsCategory,
              autoFocusSearch: _openSearch,
            ),

            const ARViewScreen(),
  
            const FeedScreen(),

            ProfileScreen(
              onBrowsePets: () {
                _openPets(
                  category: 'All',
                  search: false,
                );
              },
            ),
          ],
        ),
      ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2F5FC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [
            _navItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Home',
            ),

            _navItem(
              index: 1,
              icon: Icons.pets,
              label: 'Pets',
            ),

            _navItem(
              index: 2,
              icon: Icons.center_focus_strong,
              label: 'AR View',
            ),

            _navItem(
              index: 3,
              icon: Icons.people_outline,
              label: 'Feed',
            ),

            _navItem(
              index: 4,
              icon: Icons.person_outline,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION ITEM
  // ============================================================

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 1) {
          _openPets();
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),

        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFB15F)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(22),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              icon,
              size: 20,

              color: selected
                  ? const Color(0xFF713711)
                  : const Color(0xFF526069),
            ),

            Text(
              label,

              style: TextStyle(
                fontSize: 8,

                color: selected
                    ? const Color(0xFF713711)
                    : const Color(0xFF526069),

                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// HOME CONTENT
// =================================================================

class HomeContentScreen extends StatelessWidget {
  final Function({
    String category,
    bool search,
  }) onOpenPets;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFA94327);

  static const Color darkText = Color(0xFF062B35);

  const HomeContentScreen({
    super.key,
    required this.onOpenPets,
  });

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(
              10,
              10,
              10,
              20,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                _buildHero(),

                const SizedBox(height: 16),

                _sectionTitle('Categories'),

                const SizedBox(height: 8),

                _buildCategories(),

                const SizedBox(height: 18),

                _sectionTitle(
                  'Featured Pets',
                  seeAll: true,
                  onSeeAll: () {
                    onOpenPets(
                      category: 'All',
                      search: false,
                    );
                  },
                ),

                const SizedBox(height: 8),

                _buildFeaturedPets(),

                const SizedBox(height: 18),

                _sectionTitle(
                  'Recommended for You',
                ),

                const SizedBox(height: 8),

                _buildRecommendedPets(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 58,

      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),

      decoration: const BoxDecoration(
        color: Colors.white,

        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E5E5),
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,

            decoration: const BoxDecoration(
              shape: BoxShape.circle,

              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
                ),

                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 9),

          const Expanded(
            child: Text(
              'My Future Pet',

              style: TextStyle(
                color: primaryColor,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'No new notifications.',
                  ),
                ),
              );
            },

            icon: const Icon(
              Icons.notifications_none_rounded,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      height: 220,

      padding: const EdgeInsets.fromLTRB(
        25,
        27,
        25,
        25,
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            Color(0xFFC95635),
            Color(0xFF99644F),
          ],
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Find your new best\nfriend',

            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              height: 1.05,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Discover pets available for adoption near you.',

            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),

          const Spacer(),

          SizedBox(
            height: 48,

            child: ElevatedButton.icon(
              onPressed: () {
                onOpenPets(
                  category: 'All',
                  search: true,
                );
              },

              icon: const Icon(
                Icons.search_rounded,
              ),

              label: const Text(
                'Start Search',
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAA3F20),
                foregroundColor: Colors.white,
                elevation: 0,

                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title, {
    bool seeAll = false,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,

            style: const TextStyle(
              color: darkText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        if (seeAll)
          GestureDetector(
            onTap: onSeeAll,

            child: const Text(
              'See all ›',

              style: TextStyle(
                color: primaryColor,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    return Row(
      children: [
        Expanded(
          child: _categoryCard(
            title: 'Dogs',
            icon: Icons.pets,

            iconBackground: const Color(
              0xFFFFAF62,
            ),

            onTap: () {
              onOpenPets(
                category: 'Dogs',
                search: false,
              );
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _categoryCard(
            title: 'Cats',
            icon: Icons.cruelty_free,

            iconBackground: const Color(
              0xFF008F82,
            ),

            onTap: () {
              onOpenPets(
                category: 'Cats',
                search: false,
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _categoryCard({
    required String title,
    required IconData icon,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 100,

        decoration: BoxDecoration(
          color: const Color(0xFFE5F5FD),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                color: const Color(0xFF67310F),
                size: 25,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              title,

              style: const TextStyle(
                color: darkText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FEATURED PETS
  // ============================================================

  Widget _buildFeaturedPets() {
    final pets = PetData.pets.take(2).toList();

    return SizedBox(
      height: 164,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemCount: pets.length,

        separatorBuilder: (_, __) {
          return const SizedBox(width: 10);
        },

        itemBuilder: (context, index) {
          return _featuredCard(
            pets[index],
          );
        },
      ),
    );
  }

  // ============================================================
  // FEATURED CARD
  // ============================================================

  Widget _featuredCard(
    Map<String, dynamic> pet,
  ) {
    return GestureDetector(
      onTap: () {
        onOpenPets(
          category: pet['category'].toString(),
          search: true,
        );
      },

      child: Container(
        width: 178,

        decoration: BoxDecoration(
          color: Colors.black,

          borderRadius: BorderRadius.circular(18),
        ),

        clipBehavior: Clip.antiAlias,

        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                pet['image'].toString(),

                fit: BoxFit.cover,

                errorBuilder: (_, __, ___) {
                  return const Center(
                    child: Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 45,
                    ),
                  );
                },
              ),
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,

                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 10,
              right: 10,
              bottom: 10,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    pet['name'].toString(),

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${pet['breed']} • ${pet['age']}',

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
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

  // ============================================================
  // RECOMMENDED PETS
  // ============================================================

  Widget _buildRecommendedPets() {
    final pets = PetData.pets;

    return GridView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: pets.length,

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,

        crossAxisSpacing: 10,

        mainAxisSpacing: 10,

        childAspectRatio: 0.82,
      ),

      itemBuilder: (context, index) {
        return _recommendedCard(
          pets[index],
        );
      },
    );
  }

  // ============================================================
  // RECOMMENDED CARD
  // ============================================================

  Widget _recommendedCard(
    Map<String, dynamic> pet,
  ) {
    return GestureDetector(
      onTap: () {
        onOpenPets(
          category: pet['category'].toString(),
          search: true,
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(11),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),

        clipBehavior: Clip.antiAlias,

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Expanded(
              child: Image.network(
                pet['image'].toString(),

                width: double.infinity,

                fit: BoxFit.cover,

                errorBuilder: (_, __, ___) {
                  return const Center(
                    child: Icon(
                      Icons.pets,
                      color: primaryColor,
                      size: 35,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                8,
                6,
                8,
                7,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    pet['name'].toString(),

                    style: const TextStyle(
                      color: darkText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 1),

                  Text(
                    '${pet['breed']} • ${pet['age']}',

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Color(0xFF6E5D57),
                      fontSize: 8,
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























// import 'package:flutter/material.dart';

// import '../pet_data.dart';
// import 'pets_screen.dart';
// import 'ar_view_screen.dart';
// import 'feed_screen.dart';
// import 'profile_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // ============================================================
//   // NAVIGATION
//   // ============================================================

//   int _selectedIndex = 0;

//   String _petsCategory = 'All';

//   bool _openSearch = false;

//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color backgroundColor = Color(0xFFF5FAFD);

//   // ============================================================
//   // OPEN PETS SCREEN
//   // ============================================================

//   void _openPets({
//     String category = 'All',
//     bool search = false,
//   }) {
//     setState(() {
//       _petsCategory = category;
//       _openSearch = search;
//       _selectedIndex = 1;
//     });
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,

//       body: SafeArea(
//         child: IndexedStack(
//           index: _selectedIndex,
//           children: [
//             HomeContentScreen(
//               onOpenPets: ({
//                 String category = 'All',
//                 bool search = false,
//               }) {
//                 _openPets(
//                   category: category,
//                   search: search,
//                 );
//               },
//             ),

//             PetsScreen(
//               key: ValueKey(
//                 '$_petsCategory-$_openSearch',
//               ),
//               initialCategory: _petsCategory,
//               autoFocusSearch: _openSearch,
//             ),

//             const ARViewScreen(),

//             const FeedScreen(),

//             const ProfileScreen(),
//           ],
//         ),
//       ),

//       bottomNavigationBar: _buildBottomNavigation(),
//     );
//   }

//   // ============================================================
//   // BOTTOM NAVIGATION
//   // ============================================================

//   Widget _buildBottomNavigation() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFE2F5FC),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _navItem(
//               index: 0,
//               icon: Icons.home_rounded,
//               label: 'Home',
//             ),

//             _navItem(
//               index: 1,
//               icon: Icons.pets,
//               label: 'Pets',
//             ),

//             _navItem(
//               index: 2,
//               icon: Icons.center_focus_strong,
//               label: 'AR View',
//             ),

//             _navItem(
//               index: 3,
//               icon: Icons.people_outline,
//               label: 'Feed',
//             ),

//             _navItem(
//               index: 4,
//               icon: Icons.person_outline,
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // NAVIGATION ITEM
//   // ============================================================

//   Widget _navItem({
//     required int index,
//     required IconData icon,
//     required String label,
//   }) {
//     final bool selected = _selectedIndex == index;

//     return GestureDetector(
//       onTap: () {
//         if (index == 1) {
//           _openPets();
//         } else {
//           setState(() {
//             _selectedIndex = index;
//           });
//         }
//       },

//       child: AnimatedContainer(
//         duration: const Duration(
//           milliseconds: 180,
//         ),

//         padding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 7,
//         ),

//         decoration: BoxDecoration(
//           color: selected
//               ? const Color(0xFFFFB15F)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(22),
//         ),

//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 20,
//               color: selected
//                   ? const Color(0xFF713711)
//                   : const Color(0xFF526069),
//             ),

//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 8,
//                 color: selected
//                     ? const Color(0xFF713711)
//                     : const Color(0xFF526069),
//                 fontWeight: selected
//                     ? FontWeight.w600
//                     : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =================================================================
// // HOME CONTENT
// // =================================================================

// class HomeContentScreen extends StatelessWidget {
//   final Function({
//     String category,
//     bool search,
//   }) onOpenPets;

//   // ============================================================
//   // COLORS
//   // ============================================================

//   // IMPORTANT:
//   // These colors are defined here because this class
//   // uses them directly.
//   static const Color primaryColor = Color(0xFFA94327);

//   static const Color darkText = Color(0xFF062B35);

//   const HomeContentScreen({
//     super.key,
//     required this.onOpenPets,
//   });

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildHeader(context),

//         Expanded(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),

//             padding: const EdgeInsets.fromLTRB(
//               10,
//               10,
//               10,
//               20,
//             ),

//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,

//               children: [
//                 _buildHero(),

//                 const SizedBox(
//                   height: 16,
//                 ),

//                 _sectionTitle(
//                   'Categories',
//                 ),

//                 const SizedBox(
//                   height: 8,
//                 ),

//                 _buildCategories(),

//                 const SizedBox(
//                   height: 18,
//                 ),

//                 _sectionTitle(
//                   'Featured Pets',
//                   seeAll: true,
//                   onSeeAll: () {
//                     onOpenPets(
//                       category: 'All',
//                       search: false,
//                     );
//                   },
//                 ),

//                 const SizedBox(
//                   height: 8,
//                 ),

//                 _buildFeaturedPets(),

//                 const SizedBox(
//                   height: 18,
//                 ),

//                 _sectionTitle(
//                   'Recommended for You',
//                 ),

//                 const SizedBox(
//                   height: 8,
//                 ),

//                 _buildRecommendedPets(),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader(
//     BuildContext context,
//   ) {
//     return Container(
//       height: 58,

//       padding: const EdgeInsets.symmetric(
//         horizontal: 10,
//       ),

//       decoration: const BoxDecoration(
//         color: Colors.white,

//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE5E5E5),
//           ),
//         ),
//       ),

//       child: Row(
//         children: [
//           Container(
//             width: 34,
//             height: 34,

//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,

//               image: DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
//                 ),

//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(
//             width: 9,
//           ),

//           const Expanded(
//             child: Text(
//               'My Future Pet',

//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 19,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           IconButton(
//             onPressed: () {
//               ScaffoldMessenger.of(context)
//                   .showSnackBar(
//                 const SnackBar(
//                   content: Text(
//                     'No new notifications.',
//                   ),
//                 ),
//               );
//             },

//             icon: const Icon(
//               Icons.notifications_none_rounded,
//               color: darkText,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HERO
//   // ============================================================

//   Widget _buildHero() {
//     return Container(
//       width: double.infinity,
//       height: 220,

//       padding: const EdgeInsets.fromLTRB(
//         25,
//         27,
//         25,
//         25,
//       ),

//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),

//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,

//           colors: [
//             Color(0xFFC95635),
//             Color(0xFF99644F),
//           ],
//         ),
//       ),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         children: [
//           const Text(
//             'Find your new best\nfriend',

//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 29,
//               height: 1.05,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(
//             height: 10,
//           ),

//           const Text(
//             'Discover pets available for adoption near you.',

//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 13,
//             ),
//           ),

//           const Spacer(),

//           SizedBox(
//             height: 48,

//             child: ElevatedButton.icon(
//               onPressed: () {
//                 onOpenPets(
//                   category: 'All',
//                   search: true,
//                 );
//               },

//               icon: const Icon(
//                 Icons.search_rounded,
//               ),

//               label: const Text(
//                 'Start Search',
//               ),

//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(
//                   0xFFAA3F20,
//                 ),

//                 foregroundColor: Colors.white,

//                 elevation: 0,

//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 30,
//                 ),

//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(
//                     30,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

//   Widget _sectionTitle(
//     String title, {
//     bool seeAll = false,
//     VoidCallback? onSeeAll,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             title,

//             style: const TextStyle(
//               color: darkText,
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),

//         if (seeAll)
//           GestureDetector(
//             onTap: onSeeAll,

//             child: const Text(
//               'See all ›',

//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 9,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   // ============================================================
//   // CATEGORIES
//   // ============================================================

//   Widget _buildCategories() {
//     return Row(
//       children: [
//         Expanded(
//           child: _categoryCard(
//             title: 'Dogs',

//             icon: Icons.pets,

//             iconBackground: const Color(
//               0xFFFFAF62,
//             ),

//             onTap: () {
//               onOpenPets(
//                 category: 'Dogs',
//                 search: false,
//               );
//             },
//           ),
//         ),

//         const SizedBox(
//           width: 10,
//         ),

//         Expanded(
//           child: _categoryCard(
//             title: 'Cats',

//             icon: Icons.cruelty_free,

//             iconBackground: const Color(
//               0xFF008F82,
//             ),

//             onTap: () {
//               onOpenPets(
//                 category: 'Cats',
//                 search: false,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // CATEGORY CARD
//   // ============================================================

//   Widget _categoryCard({
//     required String title,
//     required IconData icon,
//     required Color iconBackground,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,

//       child: Container(
//         height: 100,

//         decoration: BoxDecoration(
//           color: const Color(0xFFE5F5FD),

//           borderRadius: BorderRadius.circular(
//             12,
//           ),
//         ),

//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             Container(
//               width: 42,
//               height: 42,

//               decoration: BoxDecoration(
//                 color: iconBackground,
//                 shape: BoxShape.circle,
//               ),

//               child: Icon(
//                 icon,

//                 color: const Color(
//                   0xFF67310F,
//                 ),

//                 size: 25,
//               ),
//             ),

//             const SizedBox(
//               width: 10,
//             ),

//             Text(
//               title,

//               style: const TextStyle(
//                 color: darkText,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FEATURED PETS
//   // ============================================================

//   Widget _buildFeaturedPets() {
//     final pets = PetData.pets.take(2).toList();

//     return SizedBox(
//       height: 164,

//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,

//         itemCount: pets.length,

//         separatorBuilder: (_, __) =>
//             const SizedBox(
//           width: 10,
//         ),

//         itemBuilder: (context, index) {
//           return _featuredCard(
//             pets[index],
//           );
//         },
//       ),
//     );
//   }

//   // ============================================================
//   // FEATURED CARD
//   // ============================================================

//   Widget _featuredCard(
//     Map<String, dynamic> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         onOpenPets(
//           category: pet['category'].toString(),
//           search: true,
//         );
//       },

//       child: Container(
//         width: 178,

//         decoration: BoxDecoration(
//           color: Colors.black,

//           borderRadius: BorderRadius.circular(
//             18,
//           ),
//         ),

//         clipBehavior: Clip.antiAlias,

//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: Image.network(
//                 pet['image'].toString(),

//                 fit: BoxFit.cover,

//                 errorBuilder: (_, __, ___) {
//                   return const Center(
//                     child: Icon(
//                       Icons.pets,
//                       color: Colors.white,
//                       size: 45,
//                     ),
//                   );
//                 },
//               ),
//             ),

//             Positioned.fill(
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,

//                     end: Alignment.bottomCenter,

//                     colors: [
//                       Colors.transparent,
//                       Colors.black.withOpacity(0.9),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               left: 10,
//               right: 10,
//               bottom: 10,

//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,

//                 children: [
//                   Text(
//                     pet['name'].toString(),

//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   Text(
//                     '${pet['breed']} • ${pet['age']}',

//                     maxLines: 1,

//                     overflow:
//                         TextOverflow.ellipsis,

//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 9,
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

//   // ============================================================
//   // RECOMMENDED PETS
//   // ============================================================

//   Widget _buildRecommendedPets() {
//     final pets = PetData.pets;

//     return GridView.builder(
//       shrinkWrap: true,

//       physics:
//           const NeverScrollableScrollPhysics(),

//       itemCount: pets.length,

//       gridDelegate:
//           const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,

//         crossAxisSpacing: 10,

//         mainAxisSpacing: 10,

//         childAspectRatio: 0.82,
//       ),

//       itemBuilder: (context, index) {
//         return _recommendedCard(
//           pets[index],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // RECOMMENDED CARD
//   // ============================================================

//   Widget _recommendedCard(
//     Map<String, dynamic> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         onOpenPets(
//           category: pet['category'].toString(),
//           search: true,
//         );
//       },

//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,

//           borderRadius: BorderRadius.circular(
//             11,
//           ),

//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),

//               blurRadius: 4,

//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),

//         clipBehavior: Clip.antiAlias,

//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,

//           children: [
//             Expanded(
//               child: Image.network(
//                 pet['image'].toString(),

//                 width: double.infinity,

//                 fit: BoxFit.cover,

//                 errorBuilder: (_, __, ___) {
//                   return const Center(
//                     child: Icon(
//                       Icons.pets,
//                       color: primaryColor,
//                       size: 35,
//                     ),
//                   );
//                 },
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 8,
//                 6,
//                 8,
//                 7,
//               ),

//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,

//                 children: [
//                   Text(
//                     pet['name'].toString(),

//                     style: const TextStyle(
//                       color: darkText,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(
//                     height: 1,
//                   ),

//                   Text(
//                     '${pet['breed']} • ${pet['age']}',

//                     maxLines: 1,

//                     overflow:
//                         TextOverflow.ellipsis,

//                     style: const TextStyle(
//                       color: Color(0xFF6E5D57),
//                       fontSize: 8,
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






























// import 'package:flutter/material.dart';

// import 'pets_screen.dart';
// import 'ar_view_screen.dart';
// import 'feed_screen.dart';
// import 'profile_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;

//   // This controls which category will open
//   // in PetsScreen.
//   String _petsCategory = 'All';

//   final Color backgroundColor =
//       const Color(0xFFF5FAFD);

//   // ============================================================
//   // OPEN PETS SCREEN WITH CATEGORY
//   // ============================================================

//   void _openPetsCategory(String category) {
//     setState(() {
//       _petsCategory = category;
//       _selectedIndex = 1;
//     });
//   }

//   // ============================================================
//   // OPEN ALL PETS
//   // ============================================================

//   void _openAllPets() {
//     setState(() {
//       _petsCategory = 'All';
//       _selectedIndex = 1;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,

//       body: SafeArea(
//         child: IndexedStack(
//           index: _selectedIndex,
//           children: [
//             const HomeContentScreen(),

//             // IMPORTANT:
//             // Pass selected category to PetsScreen
//             PetsScreen(
//               key: ValueKey(_petsCategory),
//               initialCategory: _petsCategory,
//             ),

//             const ARViewScreen(),
//             const FeedScreen(),
//             const ProfileScreen(),
//           ],
//         ),
//       ),

//       bottomNavigationBar:
//           _buildBottomNavigationBar(),
//     );
//   }

//   // ============================================================
//   // BOTTOM NAVIGATION
//   // ============================================================

//   Widget _buildBottomNavigationBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFE2F5FC),
//         boxShadow: [
//           BoxShadow(
//             color:
//                 Colors.black.withOpacity(0.08),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding:
//               const EdgeInsets.symmetric(
//             horizontal: 4,
//             vertical: 4,
//           ),
//           child: Row(
//             mainAxisAlignment:
//                 MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(
//                 index: 0,
//                 icon: Icons.home_rounded,
//                 label: 'Home',
//               ),
//               _buildNavItem(
//                 index: 1,
//                 icon: Icons.pets,
//                 label: 'Pets',
//               ),
//               _buildNavItem(
//                 index: 2,
//                 icon:
//                     Icons.center_focus_strong,
//                 label: 'AR View',
//               ),
//               _buildNavItem(
//                 index: 3,
//                 icon: Icons.people_outline,
//                 label: 'Feed',
//               ),
//               _buildNavItem(
//                 index: 4,
//                 icon: Icons.person_outline,
//                 label: 'Profile',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required int index,
//     required IconData icon,
//     required String label,
//   }) {
//     final bool selected =
//         _selectedIndex == index;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedIndex = index;

//           // When manually opening Pets tab,
//           // show all pets.
//           if (index == 1) {
//             _petsCategory = 'All';
//           }
//         });
//       },
//       child: AnimatedContainer(
//         duration:
//             const Duration(milliseconds: 200),
//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 11,
//           vertical: 5,
//         ),
//         decoration: BoxDecoration(
//           color: selected
//               ? const Color(0xFFFFB15F)
//               : Colors.transparent,
//           borderRadius:
//               BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize:
//               MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 19,
//               color: selected
//                   ? const Color(0xFF713711)
//                   : const Color(0xFF526069),
//             ),
//             const SizedBox(height: 1),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 8,
//                 color: selected
//                     ? const Color(0xFF713711)
//                     : const Color(0xFF526069),
//                 fontWeight: selected
//                     ? FontWeight.w600
//                     : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =================================================================
// // HOME CONTENT
// // =================================================================

// class HomeContentScreen extends StatelessWidget {
//   const HomeContentScreen({super.key});

//   static const Color primaryColor =
//       Color(0xFFA94327);

//   static const Color darkText =
//       Color(0xFF062B35);

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildTopHeader(context),

//         Expanded(
//           child: SingleChildScrollView(
//             physics:
//                 const BouncingScrollPhysics(),
//             padding:
//                 const EdgeInsets.fromLTRB(
//               10,
//               10,
//               10,
//               16,
//             ),
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 _buildHeroBanner(context),

//                 const SizedBox(height: 16),

//                 _buildSectionTitle(
//                   title: 'Categories',
//                   showSeeAll: false,
//                 ),

//                 const SizedBox(height: 8),

//                 _buildCategories(context),

//                 const SizedBox(height: 18),

//                 _buildSectionTitle(
//                   title: 'Featured Pets',
//                   showSeeAll: true,
//                   onSeeAll: () {
//                     final homeState =
//                         context
//                             .findAncestorStateOfType<
//                                 _HomeScreenState>();

//                     homeState?._openAllPets();
//                   },
//                 ),

//                 const SizedBox(height: 8),

//                 _buildFeaturedPets(context),

//                 const SizedBox(height: 18),

//                 _buildSectionTitle(
//                   title:
//                       'Recommended for You',
//                   showSeeAll: false,
//                 ),

//                 const SizedBox(height: 8),

//                 _buildRecommendedPets(
//                     context),

//                 const SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // TOP HEADER
//   // ============================================================

//   Widget _buildTopHeader(
//       BuildContext context) {
//     return Container(
//       height: 58,
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 10,
//       ),
//       decoration:
//           const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE5E5E5),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 34,
//             height: 34,
//             decoration:
//                 BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color:
//                     const Color(0xFFE0E0E0),
//               ),
//               image:
//                   const DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(width: 9),

//           const Expanded(
//             child: Text(
//               'My Future Pet',
//               style: TextStyle(
//                 color:
//                     primaryColor,
//                 fontSize: 19,
//                 fontWeight:
//                     FontWeight.bold,
//               ),
//             ),
//           ),

//           IconButton(
//             padding: EdgeInsets.zero,
//             constraints:
//                 const BoxConstraints(
//               minWidth: 35,
//               minHeight: 35,
//             ),
//             onPressed: () {
//               ScaffoldMessenger.of(
//                       context)
//                   .showSnackBar(
//                 const SnackBar(
//                   content: Text(
//                     'No new notifications.',
//                   ),
//                   behavior:
//                       SnackBarBehavior.floating,
//                 ),
//               );
//             },
//             icon: const Icon(
//               Icons
//                   .notifications_none_rounded,
//               color:
//                   darkText,
//               size: 22,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HERO BANNER
//   // ============================================================

//   Widget _buildHeroBanner(
//       BuildContext context) {
//     return LayoutBuilder(
//       builder:
//           (context, constraints) {
//         final double width =
//             constraints.maxWidth;

//         final double titleSize =
//             width < 400 ? 28 : 36;

//         final double descriptionSize =
//             width < 400 ? 14 : 17;

//         final double buttonHeight =
//             width < 400 ? 48 : 56;

//         final double horizontalPadding =
//             width < 400 ? 24 : 34;

//         return Container(
//           width: double.infinity,
//           height:
//               width < 400 ? 215 : 235,
//           padding:
//               EdgeInsets.fromLTRB(
//             horizontalPadding,
//             28,
//             horizontalPadding,
//             26,
//           ),
//           decoration:
//               BoxDecoration(
//             borderRadius:
//                 BorderRadius.circular(30),
//             gradient:
//                 const LinearGradient(
//               begin:
//                   Alignment.topLeft,
//               end:
//                   Alignment.bottomRight,
//               colors: [
//                 Color(0xFFC95635),
//                 Color(0xFF99644F),
//               ],
//             ),
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                 right: 5,
//                 top: 0,
//                 child: Container(
//                   width:
//                       width < 400 ? 80 : 105,
//                   height:
//                       width < 400 ? 80 : 105,
//                   decoration:
//                       BoxDecoration(
//                     color: Colors.white
//                         .withOpacity(0.08),
//                     shape:
//                         BoxShape.circle,
//                   ),
//                 ),
//               ),

//               Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment
//                         .start,
//                 children: [
//                   Text(
//                     'Find your new best\nfriend',
//                     style:
//                         TextStyle(
//                       color:
//                           Colors.white,
//                       fontSize:
//                           titleSize,
//                       height: 1.05,
//                       fontWeight:
//                           FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(
//                       height: 12),

//                   Text(
//                     'Discover pets available for adoption.',
//                     style:
//                         TextStyle(
//                       color:
//                           Colors.white,
//                       fontSize:
//                           descriptionSize,
//                       height: 1.3,
//                     ),
//                   ),

//                   const Spacer(),

//                   SizedBox(
//                     height:
//                         buttonHeight,
//                     child:
//                         ElevatedButton
//                             .icon(
//                       onPressed: () {
//                         final homeState =
//                             context
//                                 .findAncestorStateOfType<
//                                     _HomeScreenState>();

//                         homeState
//                             ?._openAllPets();
//                       },
//                       icon: Icon(
//                         Icons
//                             .search_rounded,
//                         size:
//                             width < 400
//                                 ? 24
//                                 : 30,
//                       ),
//                       label: Text(
//                         'Start Search',
//                         style:
//                             TextStyle(
//                           fontSize:
//                               width < 400
//                                   ? 16
//                                   : 19,
//                           fontWeight:
//                               FontWeight
//                                   .w600,
//                         ),
//                       ),
//                       style:
//                           ElevatedButton
//                               .styleFrom(
//                         backgroundColor:
//                             const Color(
//                                 0xFFAA3F20),
//                         foregroundColor:
//                             Colors.white,
//                         elevation: 0,
//                         padding:
//                             EdgeInsets
//                                 .symmetric(
//                           horizontal:
//                               width < 500
//                                   ? 32
//                                   : 42,
//                         ),
//                         shape:
//                             RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius
//                                   .circular(
//                             35,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

//   Widget _buildSectionTitle({
//     required String title,
//     required bool showSeeAll,
//     VoidCallback? onSeeAll,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             title,
//             style:
//                 const TextStyle(
//               color: darkText,
//               fontSize: 15,
//               fontWeight:
//                   FontWeight.w700,
//             ),
//           ),
//         ),

//         if (showSeeAll)
//           GestureDetector(
//             onTap: onSeeAll,
//             child:
//                 const Text(
//               'See all ›',
//               style:
//                   TextStyle(
//                 color:
//                     primaryColor,
//                 fontSize: 9,
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   // ============================================================
//   // CATEGORIES
//   // ============================================================

//   Widget _buildCategories(
//       BuildContext context) {
//     final homeState =
//         context.findAncestorStateOfType<
//             _HomeScreenState>();

//     return Row(
//       children: [
//         // ======================================================
//         // DOGS
//         // ======================================================

//         Expanded(
//           child:
//               _buildCategoryCard(
//             title: 'Dogs',
//             icon: Icons.pets,
//             iconBackground:
//                 const Color(0xFFFFAF62),
//             onTap: () {
//               // OPEN PETS SCREEN
//               // AND SELECT DOGS
//               homeState?._openPetsCategory(
//                 'Dogs',
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 10),

//         // ======================================================
//         // CATS
//         // ======================================================

//         Expanded(
//           child:
//               _buildCategoryCard(
//             title: 'Cats',
//             icon:
//                 Icons.cruelty_free,
//             iconBackground:
//                 const Color(0xFF008F82),
//             onTap: () {
//               // OPEN PETS SCREEN
//               // AND SELECT CATS
//               homeState?._openPetsCategory(
//                 'Cats',
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // CATEGORY CARD
//   // ============================================================

//   Widget _buildCategoryCard({
//     required String title,
//     required IconData icon,
//     required Color iconBackground,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 100,
//         decoration:
//             BoxDecoration(
//           color:
//               const Color(0xFFE5F5FD),
//           borderRadius:
//               BorderRadius.circular(12),
//         ),
//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 42,
//               height: 42,
//               decoration:
//                   BoxDecoration(
//                 color:
//                     iconBackground,
//                 shape:
//                     BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color:
//                     const Color(
//                         0xFF67310F),
//                 size: 25,
//               ),
//             ),

//             const SizedBox(
//                 width: 10),

//             Text(
//               title,
//               style:
//                   const TextStyle(
//                 color:
//                     darkText,
//                 fontSize: 13,
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FEATURED PETS
//   // ============================================================

//   Widget _buildFeaturedPets(
//       BuildContext context) {
//     final featuredPets = [
//       {
//         'name': 'Bella',
//         'breed':
//             'Golden Retriever',
//         'age': '2 yrs',
//         'image':
//             'https://images.unsplash.com/photo-1552053831-71594a27632d?w=800',
//         'local': true,
//       },
//       {
//         'name': 'Luna',
//         'breed': 'Calico',
//         'age': '3 yrs',
//         'image':
//             'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=800',
//         'local': false,
//       },
//     ];

//     return SizedBox(
//       height: 164,
//       child: ListView.separated(
//         scrollDirection:
//             Axis.horizontal,
//         physics:
//             const BouncingScrollPhysics(),
//         itemCount:
//             featuredPets.length,
//         separatorBuilder:
//             (_, __) =>
//                 const SizedBox(
//                     width: 10),
//         itemBuilder:
//             (context, index) {
//           return _buildFeaturedPetCard(
//             context,
//             featuredPets[index],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFeaturedPetCard(
//     BuildContext context,
//     Map<String, dynamic> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         final homeState =
//             context
//                 .findAncestorStateOfType<
//                     _HomeScreenState>();

//         if (pet['breed']
//                 .toString()
//                 .toLowerCase()
//                 .contains('calico') ||
//             pet['name'] == 'Luna') {
//           homeState?._openPetsCategory(
//               'Cats');
//         } else {
//           homeState?._openPetsCategory(
//               'Dogs');
//         }
//       },
//       child: Container(
//         width: 178,
//         decoration:
//             BoxDecoration(
//           color: Colors.black,
//           borderRadius:
//               BorderRadius.circular(
//                   18),
//         ),
//         clipBehavior:
//             Clip.antiAlias,
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: Image.network(
//                 pet['image'],
//                 fit: BoxFit.cover,
//                 errorBuilder:
//                     (_, __, ___) {
//                   return Container(
//                     color:
//                         const Color(
//                             0xFF222222),
//                     child:
//                         const Icon(
//                       Icons.pets,
//                       color:
//                           Colors.white,
//                       size: 45,
//                     ),
//                   );
//                 },
//               ),
//             ),

//             Positioned.fill(
//               child: DecoratedBox(
//                 decoration:
//                     BoxDecoration(
//                   gradient:
//                       LinearGradient(
//                     begin: Alignment
//                         .topCenter,
//                     end: Alignment
//                         .bottomCenter,
//                     colors: [
//                       Colors
//                           .transparent,
//                       Colors.black
//                           .withOpacity(
//                               0.9),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 8,
//               right: 8,
//               child: Container(
//                 width: 28,
//                 height: 28,
//                 decoration:
//                     BoxDecoration(
//                   color: Colors.white
//                       .withOpacity(
//                           0.55),
//                   shape:
//                       BoxShape.circle,
//                 ),
//                 child:
//                     const Icon(
//                   Icons
//                       .favorite_border,
//                   color:
//                       Color(0xFF16414A),
//                   size: 18,
//                 ),
//               ),
//             ),

//             Positioned(
//               left: 10,
//               right: 8,
//               bottom: 8,
//               child: Row(
//                 crossAxisAlignment:
//                     CrossAxisAlignment
//                         .end,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment
//                               .start,
//                       children: [
//                         Text(
//                           pet['name'],
//                           style:
//                               const TextStyle(
//                             color:
//                                 Colors.white,
//                             fontSize:
//                                 18,
//                             fontWeight:
//                                 FontWeight
//                                     .bold,
//                           ),
//                         ),
//                         const SizedBox(
//                             height: 1),
//                         Text(
//                           '${pet['breed']} • ${pet['age']}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow
//                                   .ellipsis,
//                           style:
//                               const TextStyle(
//                             color:
//                                 Colors.white,
//                             fontSize:
//                                 8.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   if (pet['local'] ==
//                       true)
//                     Container(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 7,
//                         vertical: 4,
//                       ),
//                       decoration:
//                           BoxDecoration(
//                         color:
//                             const Color(
//                                 0xFF008F82),
//                         borderRadius:
//                             BorderRadius
//                                 .circular(
//                                     15),
//                       ),
//                       child:
//                           const Text(
//                         'Local',
//                         style:
//                             TextStyle(
//                           color:
//                               Colors.white,
//                           fontSize: 7,
//                           fontWeight:
//                               FontWeight
//                                   .w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // RECOMMENDED PETS
//   // ============================================================

//   Widget _buildRecommendedPets(
//       BuildContext context) {
//     final recommendedPets = [
//       {
//         'name': 'Scout',
//         'breed':
//             'Terrier Mix',
//         'age': '1 yr',
//         'image':
//             'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800',
//       },
//       {
//         'name': 'Oliver',
//         'breed':
//             'Domestic Longhair',
//         'age': '4 yrs',
//         'image':
//             'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=800',
//       },
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       physics:
//           const NeverScrollableScrollPhysics(),
//       itemCount:
//           recommendedPets.length,
//       gridDelegate:
//           const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 0.82,
//       ),
//       itemBuilder:
//           (context, index) {
//         return _buildRecommendedPetCard(
//           context,
//           recommendedPets[index],
//         );
//       },
//     );
//   }

//   Widget _buildRecommendedPetCard(
//     BuildContext context,
//     Map<String, String> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         final homeState =
//             context
//                 .findAncestorStateOfType<
//                     _HomeScreenState>();

//         if (pet['name'] ==
//             'Oliver') {
//           homeState?._openPetsCategory(
//               'Cats');
//         } else {
//           homeState?._openPetsCategory(
//               'Dogs');
//         }
//       },
//       child: Container(
//         decoration:
//             BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.circular(
//                   11),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black
//                   .withOpacity(0.05),
//               blurRadius: 4,
//               offset:
//                   const Offset(0, 1),
//             ),
//           ],
//         ),
//         clipBehavior:
//             Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child:
//                   Image.network(
//                 pet['image']!,
//                 width:
//                     double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder:
//                     (_, __, ___) {
//                   return Container(
//                     color:
//                         const Color(
//                             0xFFE9EEF0),
//                     child:
//                         const Center(
//                       child: Icon(
//                         Icons.pets,
//                         size: 35,
//                         color:
//                             primaryColor,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             Padding(
//               padding:
//                   const EdgeInsets
//                       .fromLTRB(
//                 8,
//                 6,
//                 8,
//                 7,
//               ),
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment
//                         .start,
//                 children: [
//                   Text(
//                     pet['name']!,
//                     style:
//                         const TextStyle(
//                       color:
//                           darkText,
//                       fontSize: 12,
//                       fontWeight:
//                           FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(
//                       height: 1),

//                   Text(
//                     '${pet['breed']} • ${pet['age']}',
//                     maxLines: 1,
//                     overflow:
//                         TextOverflow
//                             .ellipsis,
//                     style:
//                         const TextStyle(
//                       color:
//                           Color(
//                               0xFF6E5D57),
//                       fontSize: 8,
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

























// import 'package:flutter/material.dart';

// import 'pets_screen.dart';
// import 'ar_view_screen.dart';
// import 'feed_screen.dart';
// import 'profile_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;

//   final Color backgroundColor = const Color(0xFFF5FAFD);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,

//       body: SafeArea(
//         child: IndexedStack(
//           index: _selectedIndex,
//           children: const [
//             HomeContentScreen(),
//             PetsScreen(),
//             ARViewScreen(),
//             FeedScreen(),
//             ProfileScreen(),
//           ],
//         ),
//       ),

//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   // ============================================================
//   // BOTTOM NAVIGATION
//   // ============================================================

//   Widget _buildBottomNavigationBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFE2F5FC),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 4,
//             vertical: 4,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(
//                 index: 0,
//                 icon: Icons.home_rounded,
//                 label: 'Home',
//               ),

//               _buildNavItem(
//                 index: 1,
//                 icon: Icons.pets,
//                 label: 'Pets',
//               ),

//               _buildNavItem(
//                 index: 2,
//                 icon: Icons.center_focus_strong,
//                 label: 'AR View',
//               ),

//               _buildNavItem(
//                 index: 3,
//                 icon: Icons.people_outline,
//                 label: 'Feed',
//               ),

//               _buildNavItem(
//                 index: 4,
//                 icon: Icons.person_outline,
//                 label: 'Profile',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required int index,
//     required IconData icon,
//     required String label,
//   }) {
//     final bool selected = _selectedIndex == index;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedIndex = index;
//         });
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(
//           horizontal: 11,
//           vertical: 5,
//         ),
//         decoration: BoxDecoration(
//           color: selected
//               ? const Color(0xFFFFB15F)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 19,
//               color: selected
//                   ? const Color(0xFF713711)
//                   : const Color(0xFF526069),
//             ),

//             const SizedBox(height: 1),

//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 8,
//                 color: selected
//                     ? const Color(0xFF713711)
//                     : const Color(0xFF526069),
//                 fontWeight: selected
//                     ? FontWeight.w600
//                     : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ================================================================
// // HOME CONTENT
// // ================================================================

// class HomeContentScreen extends StatefulWidget {
//   const HomeContentScreen({super.key});

//   @override
//   State<HomeContentScreen> createState() =>
//       _HomeContentScreenState();
// }

// class _HomeContentScreenState extends State<HomeContentScreen> {
//   final Color primaryColor = const Color(0xFFA94327);
//   final Color darkText = const Color(0xFF062B35);

//   // ============================================================
//   // SEARCH VARIABLES
//   // ============================================================

//   final TextEditingController _searchController =
//       TextEditingController();

//   String _searchQuery = '';
//   String _selectedCategory = 'All';

//   // ============================================================
//   // AVAILABLE PETS
//   // ============================================================

//   final List<Map<String, dynamic>> _allPets = [
//     {
//       'name': 'Max',
//       'breed': 'Golden Retriever',
//       'age': '2 yrs',
//       'type': 'Dog',
//       'image':
//           'https://images.unsplash.com/photo-1552053831-71594a27632d?w=800',
//     },
//     {
//       'name': 'Luna',
//       'breed': 'Domestic Shorthair',
//       'age': '1 yr',
//       'type': 'Cat',
//       'image':
//           'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=800',
//     },
//     {
//       'name': 'Charlie',
//       'breed': 'Bulldog',
//       'age': '3 yrs',
//       'type': 'Dog',
//       'image':
//           'https://images.unsplash.com/photo-1558788353-f76d92427f16?w=800',
//     },
//     {
//       'name': 'Milo',
//       'breed': 'Siamese',
//       'age': '2 yrs',
//       'type': 'Cat',
//       'image':
//           'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800',
//     },
//     {
//       'name': 'Daisy',
//       'breed': 'Poodle',
//       'age': '1 yr',
//       'type': 'Dog',
//       'image':
//           'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800',
//     },
//     {
//       'name': 'Oliver',
//       'breed': 'Tabby',
//       'age': '4 mos',
//       'type': 'Cat',
//       'image':
//           'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=800',
//     },
//   ];

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildTopHeader(context),

//         Expanded(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(
//               10,
//               10,
//               10,
//               16,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeroBanner(context),

//                 const SizedBox(height: 16),

//                 _buildSectionTitle(
//                   title: 'Categories',
//                   showSeeAll: false,
//                 ),

//                 const SizedBox(height: 8),

//                 _buildCategories(context),

//                 const SizedBox(height: 18),

//                 _buildSectionTitle(
//                   title: 'Featured Pets',
//                   showSeeAll: true,
//                   onSeeAll: () {
//                     final state =
//                         context.findAncestorStateOfType<
//                             _HomeScreenState>();

//                     state?.setState(() {
//                       state._selectedIndex = 1;
//                     });
//                   },
//                 ),

//                 const SizedBox(height: 8),

//                 _buildFeaturedPets(context),

//                 const SizedBox(height: 18),

//                 _buildSectionTitle(
//                   title: 'Recommended for You',
//                   showSeeAll: false,
//                 ),

//                 const SizedBox(height: 8),

//                 _buildRecommendedPets(context),

//                 const SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // TOP HEADER
//   // ============================================================

//   Widget _buildTopHeader(BuildContext context) {
//     return Container(
//       height: 58,
//       padding: const EdgeInsets.symmetric(
//         horizontal: 10,
//       ),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE5E5E5),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: const Color(0xFFE0E0E0),
//               ),
//               image: const DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(width: 9),

//           Expanded(
//             child: Text(
//               'My Future Pet',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 19,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           IconButton(
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 35,
//               minHeight: 35,
//             ),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text(
//                     'No new notifications.',
//                   ),
//                   behavior: SnackBarBehavior.floating,
//                 ),
//               );
//             },
//             icon: Icon(
//               Icons.notifications_none_rounded,
//               color: darkText,
//               size: 22,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HERO BANNER
//   // ============================================================

//   Widget _buildHeroBanner(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final double width = constraints.maxWidth;

//         final double titleSize =
//             width < 400 ? 28 : 36;

//         final double descriptionSize =
//             width < 400 ? 14 : 17;

//         final double buttonHeight =
//             width < 400 ? 48 : 56;

//         final double horizontalPadding =
//             width < 400 ? 24 : 34;

//         return Container(
//           width: double.infinity,
//           height: width < 400 ? 215 : 235,
//           padding: EdgeInsets.fromLTRB(
//             horizontalPadding,
//             28,
//             horizontalPadding,
//             26,
//           ),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(30),
//             gradient: const LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color(0xFFC95635),
//                 Color(0xFF99644F),
//               ],
//             ),
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                 right: 5,
//                 top: 0,
//                 child: Container(
//                   width: width < 400 ? 80 : 105,
//                   height: width < 400 ? 80 : 105,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.08),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),

//               Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Find your new best\nfriend',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: titleSize,
//                       height: 1.05,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: -0.5,
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   Text(
//                     'Discover pets available for adoption near you.',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: descriptionSize,
//                       height: 1.3,
//                     ),
//                   ),

//                   const Spacer(),

//                   SizedBox(
//                     height: buttonHeight,
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         _showSearchDialog(context);
//                       },
//                       icon: Icon(
//                         Icons.search_rounded,
//                         size: width < 400 ? 24 : 30,
//                       ),
//                       label: Text(
//                         'Start Search',
//                         style: TextStyle(
//                           fontSize:
//                               width < 400 ? 16 : 19,
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),
//                       style:
//                           ElevatedButton.styleFrom(
//                         backgroundColor:
//                             const Color(0xFFAA3F20),
//                         foregroundColor:
//                             Colors.white,
//                         elevation: 0,
//                         padding:
//                             EdgeInsets.symmetric(
//                           horizontal:
//                               width < 500
//                                   ? 32
//                                   : 42,
//                         ),
//                         shape:
//                             RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(
//                             35,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // SEARCH DIALOG
//   // ============================================================

//   void _showSearchDialog(BuildContext context) {
//     _searchController.clear();
//     _searchQuery = '';
//     _selectedCategory = 'All';

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             final filteredPets = _allPets.where((pet) {
//               final query =
//                   _searchQuery.toLowerCase().trim();

//               final matchesSearch =
//                   query.isEmpty ||
//                   pet['name']
//                       .toString()
//                       .toLowerCase()
//                       .contains(query) ||
//                   pet['breed']
//                       .toString()
//                       .toLowerCase()
//                       .contains(query);

//               final matchesCategory =
//                   _selectedCategory == 'All' ||
//                   pet['type'] == _selectedCategory;

//               return matchesSearch &&
//                   matchesCategory;
//             }).toList();

//             return Container(
//               height:
//                   MediaQuery.of(context).size.height *
//                       0.88,
//               decoration: const BoxDecoration(
//                 color: Color(0xFFF5FAFD),
//                 borderRadius:
//                     BorderRadius.vertical(
//                   top: Radius.circular(28),
//                 ),
//               ),
//               child: SafeArea(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 10),

//                     // HANDLE
//                     Container(
//                       width: 45,
//                       height: 5,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius:
//                             BorderRadius.circular(10),
//                       ),
//                     ),

//                     const SizedBox(height: 18),

//                     // HEADER
//                     Padding(
//                       padding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 20,
//                       ),
//                       child: Row(
//                         children: [
//                           const Expanded(
//                             child: Text(
//                               'Find a Pet',
//                               style: TextStyle(
//                                 color:
//                                     Color(0xFF062B35),
//                                 fontSize: 22,
//                                 fontWeight:
//                                     FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             icon: const Icon(
//                               Icons.close_rounded,
//                               color:
//                                   Color(0xFF062B35),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     // SEARCH FIELD
//                     Padding(
//                       padding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 20,
//                       ),
//                       child: TextField(
//                         controller:
//                             _searchController,
//                         autofocus: true,
//                         onChanged: (value) {
//                           setModalState(() {
//                             _searchQuery = value;
//                           });
//                         },
//                         decoration: InputDecoration(
//                           hintText:
//                               'Search pet name or breed...',
//                           prefixIcon: const Icon(
//                             Icons.search_rounded,
//                             color:
//                                 Color(0xFFA94327),
//                           ),
//                           suffixIcon:
//                               _searchController
//                                       .text
//                                       .isNotEmpty
//                                   ? IconButton(
//                                       onPressed: () {
//                                         _searchController
//                                             .clear();

//                                         setModalState(() {
//                                           _searchQuery =
//                                               '';
//                                         });
//                                       },
//                                       icon: const Icon(
//                                         Icons
//                                             .clear_rounded,
//                                       ),
//                                     )
//                                   : null,
//                           filled: true,
//                           fillColor: Colors.white,
//                           contentPadding:
//                               const EdgeInsets
//                                   .symmetric(
//                             vertical: 15,
//                             horizontal: 16,
//                           ),
//                           border:
//                               OutlineInputBorder(
//                             borderRadius:
//                                 BorderRadius.circular(
//                               18,
//                             ),
//                             borderSide:
//                                 BorderSide.none,
//                           ),
//                           enabledBorder:
//                               OutlineInputBorder(
//                             borderRadius:
//                                 BorderRadius.circular(
//                               18,
//                             ),
//                             borderSide:
//                                 BorderSide.none,
//                           ),
//                           focusedBorder:
//                               OutlineInputBorder(
//                             borderRadius:
//                                 BorderRadius.circular(
//                               18,
//                             ),
//                             borderSide:
//                                 const BorderSide(
//                               color:
//                                   Color(0xFFA94327),
//                               width: 1.5,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 15),

//                     // CATEGORY FILTERS
//                     SizedBox(
//                       height: 42,
//                       child: ListView(
//                         padding:
//                             const EdgeInsets.symmetric(
//                           horizontal: 20,
//                         ),
//                         scrollDirection:
//                             Axis.horizontal,
//                         children: [
//                           _buildFilterChip(
//                             label: 'All',
//                             selected:
//                                 _selectedCategory ==
//                                     'All',
//                             onTap: () {
//                               setModalState(() {
//                                 _selectedCategory =
//                                     'All';
//                               });
//                             },
//                           ),

//                           const SizedBox(width: 8),

//                           _buildFilterChip(
//                             label: 'Dogs',
//                             selected:
//                                 _selectedCategory ==
//                                     'Dog',
//                             onTap: () {
//                               setModalState(() {
//                                 _selectedCategory =
//                                     'Dog';
//                               });
//                             },
//                           ),

//                           const SizedBox(width: 8),

//                           _buildFilterChip(
//                             label: 'Cats',
//                             selected:
//                                 _selectedCategory ==
//                                     'Cat',
//                             onTap: () {
//                               setModalState(() {
//                                 _selectedCategory =
//                                     'Cat';
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 15),

//                     // RESULT COUNT
//                     Padding(
//                       padding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 20,
//                       ),
//                       child: Row(
//                         children: [
//                           Text(
//                             '${filteredPets.length} pets available',
//                             style:
//                                 const TextStyle(
//                               color:
//                                   Color(0xFF062B35),
//                               fontSize: 15,
//                               fontWeight:
//                                   FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     // RESULTS
//                     Expanded(
//                       child: filteredPets.isEmpty
//                           ? _buildNoSearchResults()
//                           : GridView.builder(
//                               padding:
//                                   const EdgeInsets
//                                       .fromLTRB(
//                                 20,
//                                 5,
//                                 20,
//                                 25,
//                               ),
//                               gridDelegate:
//                                   const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 crossAxisSpacing: 12,
//                                 mainAxisSpacing: 12,
//                                 childAspectRatio:
//                                     0.76,
//                               ),
//                               itemCount:
//                                   filteredPets.length,
//                               itemBuilder:
//                                   (context, index) {
//                                 return _buildSearchPetCard(
//                                   context,
//                                   filteredPets[index],
//                                 );
//                               },
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // ============================================================
//   // FILTER CHIP
//   // ============================================================

//   Widget _buildFilterChip({
//     required String label,
//     required bool selected,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration:
//             const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(
//           horizontal: 18,
//           vertical: 9,
//         ),
//         decoration: BoxDecoration(
//           color: selected
//               ? const Color(0xFFA94327)
//               : Colors.white,
//           borderRadius:
//               BorderRadius.circular(22),
//           border: Border.all(
//             color: selected
//                 ? const Color(0xFFA94327)
//                 : const Color(0xFFD8E2E6),
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               label == 'Dogs'
//                   ? Icons.pets
//                   : label == 'Cats'
//                       ? Icons.cruelty_free
//                       : Icons.apps,
//               size: 17,
//               color: selected
//                   ? Colors.white
//                   : const Color(0xFF526069),
//             ),

//             const SizedBox(width: 6),

//             Text(
//               label,
//               style: TextStyle(
//                 color: selected
//                     ? Colors.white
//                     : const Color(0xFF526069),
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // NO SEARCH RESULTS
//   // ============================================================

//   Widget _buildNoSearchResults() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration:
//                   const BoxDecoration(
//                 color: Color(0xFFE5F5FD),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.search_off_rounded,
//                 size: 40,
//                 color: Color(0xFFA94327),
//               ),
//             ),

//             const SizedBox(height: 16),

//             const Text(
//               'No pets found',
//               style: TextStyle(
//                 color: Color(0xFF062B35),
//                 fontSize: 19,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 6),

//             const Text(
//               'Try searching another pet name or breed.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Color(0xFF6E7B80),
//                 fontSize: 13,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SEARCH PET CARD
//   // ============================================================

//   Widget _buildSearchPetCard(
//     BuildContext context,
//     Map<String, dynamic> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Opening ${pet['name']} profile.',
//             ),
//             behavior:
//                 SnackBarBehavior.floating,
//           ),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color:
//                   Colors.black.withOpacity(0.05),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: Image.network(
//                       pet['image'],
//                       fit: BoxFit.cover,
//                       errorBuilder:
//                           (_, __, ___) {
//                         return Container(
//                           color:
//                               const Color(0xFFE9EEF0),
//                           child: const Center(
//                             child: Icon(
//                               Icons.pets,
//                               size: 40,
//                               color:
//                                   Color(0xFFA94327),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   // FAVORITE BUTTON
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: Container(
//                       width: 32,
//                       height: 32,
//                       decoration:
//                           BoxDecoration(
//                         color: Colors.white
//                             .withOpacity(0.85),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.favorite_border,
//                         size: 19,
//                         color:
//                             Color(0xFF16414A),
//                       ),
//                     ),
//                   ),

//                   // AVAILABLE LABEL
//                   Positioned(
//                     left: 8,
//                     bottom: 8,
//                     child: Container(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration:
//                           BoxDecoration(
//                         color:
//                             const Color(0xFF078F80),
//                         borderRadius:
//                             BorderRadius.circular(
//                           15,
//                         ),
//                       ),
//                       child: const Text(
//                         'Available',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 8,
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Padding(
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 10,
//                 8,
//                 10,
//                 10,
//               ),
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     pet['name'],
//                     maxLines: 1,
//                     overflow:
//                         TextOverflow.ellipsis,
//                     style:
//                         const TextStyle(
//                       color:
//                           Color(0xFF062B35),
//                       fontSize: 14,
//                       fontWeight:
//                           FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 3),

//                   Text(
//                     '${pet['breed']} • ${pet['age']}',
//                     maxLines: 1,
//                     overflow:
//                         TextOverflow.ellipsis,
//                     style:
//                         const TextStyle(
//                       color:
//                           Color(0xFF6E5D57),
//                       fontSize: 9,
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

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

//   Widget _buildSectionTitle({
//     required String title,
//     required bool showSeeAll,
//     VoidCallback? onSeeAll,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             title,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),

//         if (showSeeAll)
//           GestureDetector(
//             onTap: onSeeAll,
//             child: Text(
//               'See all ›',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 9,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   // ============================================================
//   // CATEGORIES
//   // ============================================================

//   Widget _buildCategories(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildCategoryCard(
//             title: 'Dogs',
//             icon: Icons.pets,
//             iconBackground:
//                 const Color(0xFFFFAF62),
//             onTap: () {
//               _showSearchDialogWithCategory(
//                 context,
//                 'Dog',
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 10),

//         Expanded(
//           child: _buildCategoryCard(
//             title: 'Cats',
//             icon: Icons.cruelty_free,
//             iconBackground:
//                 const Color(0xFF008F82),
//             onTap: () {
//               _showSearchDialogWithCategory(
//                 context,
//                 'Cat',
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // OPEN SEARCH WITH CATEGORY
//   // ============================================================

//   void _showSearchDialogWithCategory(
//     BuildContext context,
//     String category,
//   ) {
//     _searchController.clear();
//     _searchQuery = '';
//     _selectedCategory = category;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             final filteredPets =
//                 _allPets.where((pet) {
//               final query =
//                   _searchQuery.toLowerCase().trim();

//               final matchesSearch =
//                   query.isEmpty ||
//                   pet['name']
//                       .toString()
//                       .toLowerCase()
//                       .contains(query) ||
//                   pet['breed']
//                       .toString()
//                       .toLowerCase()
//                       .contains(query);

//               final matchesCategory =
//                   _selectedCategory == 'All' ||
//                   pet['type'] ==
//                       _selectedCategory;

//               return matchesSearch &&
//                   matchesCategory;
//             }).toList();

//             return Container(
//               height:
//                   MediaQuery.of(context)
//                           .size
//                           .height *
//                       0.88,
//               decoration:
//                   const BoxDecoration(
//                 color:
//                     Color(0xFFF5FAFD),
//                 borderRadius:
//                     BorderRadius.vertical(
//                   top: Radius.circular(28),
//                 ),
//               ),
//               child: SafeArea(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 10),

//                     Container(
//                       width: 45,
//                       height: 5,
//                       decoration:
//                           BoxDecoration(
//                         color:
//                             Colors.grey.shade300,
//                         borderRadius:
//                             BorderRadius.circular(
//                           10,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 18),

//                     Padding(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 20,
//                       ),
//                       child: Row(
//                         children: [
//                           const Expanded(
//                             child: Text(
//                               'Find a Pet',
//                               style:
//                                   TextStyle(
//                                 color:
//                                     Color(
//                                         0xFF062B35),
//                                 fontSize: 22,
//                                 fontWeight:
//                                     FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: () {
//                               Navigator.pop(
//                                   context);
//                             },
//                             icon:
//                                 const Icon(
//                               Icons
//                                   .close_rounded,
//                               color:
//                                   Color(
//                                       0xFF062B35),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     // SEARCH FIELD
//                     Padding(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 20,
//                       ),
//                       child: TextField(
//                         controller:
//                             _searchController,
//                         autofocus: true,
//                         onChanged: (value) {
//                           setModalState(() {
//                             _searchQuery =
//                                 value;
//                           });
//                         },
//                         decoration:
//                             InputDecoration(
//                           hintText:
//                               'Search pet name or breed...',
//                           prefixIcon:
//                               const Icon(
//                             Icons
//                                 .search_rounded,
//                             color:
//                                 Color(
//                                     0xFFA94327),
//                           ),
//                           suffixIcon:
//                               _searchController
//                                       .text
//                                       .isNotEmpty
//                                   ? IconButton(
//                                       onPressed:
//                                           () {
//                                         _searchController
//                                             .clear();

//                                         setModalState(
//                                             () {
//                                           _searchQuery =
//                                               '';
//                                         });
//                                       },
//                                       icon:
//                                           const Icon(
//                                         Icons
//                                             .clear_rounded,
//                                       ),
//                                     )
//                                   : null,
//                           filled: true,
//                           fillColor:
//                               Colors.white,
//                           contentPadding:
//                               const EdgeInsets
//                                   .symmetric(
//                             vertical: 15,
//                             horizontal: 16,
//                           ),
//                           border:
//                               OutlineInputBorder(
//                             borderRadius:
//                                 BorderRadius
//                                     .circular(
//                               18,
//                             ),
//                             borderSide:
//                                 BorderSide.none,
//                           ),
//                           enabledBorder:
//                               OutlineInputBorder(
//                             borderRadius:
//                                 BorderRadius
//                                     .circular(
//                               18,
//                             ),
//                             borderSide:
//                                 BorderSide.none,
//                           ),
//                           focusedBorder:
//                               OutlineInputBorder(
//                             borderRadius:
//                                 BorderRadius
//                                     .circular(
//                               18,
//                             ),
//                             borderSide:
//                                 const BorderSide(
//                               color:
//                                   Color(
//                                       0xFFA94327),
//                               width: 1.5,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 15),

//                     // FILTERS
//                     SizedBox(
//                       height: 42,
//                       child: ListView(
//                         padding:
//                             const EdgeInsets
//                                 .symmetric(
//                           horizontal: 20,
//                         ),
//                         scrollDirection:
//                             Axis.horizontal,
//                         children: [
//                           _buildFilterChip(
//                             label: 'All',
//                             selected:
//                                 _selectedCategory ==
//                                     'All',
//                             onTap: () {
//                               setModalState(
//                                   () {
//                                 _selectedCategory =
//                                     'All';
//                               });
//                             },
//                           ),

//                           const SizedBox(
//                               width: 8),

//                           _buildFilterChip(
//                             label: 'Dogs',
//                             selected:
//                                 _selectedCategory ==
//                                     'Dog',
//                             onTap: () {
//                               setModalState(
//                                   () {
//                                 _selectedCategory =
//                                     'Dog';
//                               });
//                             },
//                           ),

//                           const SizedBox(
//                               width: 8),

//                           _buildFilterChip(
//                             label: 'Cats',
//                             selected:
//                                 _selectedCategory ==
//                                     'Cat',
//                             onTap: () {
//                               setModalState(
//                                   () {
//                                 _selectedCategory =
//                                     'Cat';
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 15),

//                     Padding(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 20,
//                       ),
//                       child: Align(
//                         alignment:
//                             Alignment.centerLeft,
//                         child: Text(
//                           '${filteredPets.length} pets available',
//                           style:
//                               const TextStyle(
//                             color:
//                                 Color(
//                                     0xFF062B35),
//                             fontSize: 15,
//                             fontWeight:
//                                 FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     Expanded(
//                       child:
//                           filteredPets.isEmpty
//                               ? _buildNoSearchResults()
//                               : GridView.builder(
//                                   padding:
//                                       const EdgeInsets
//                                           .fromLTRB(
//                                     20,
//                                     5,
//                                     20,
//                                     25,
//                                   ),
//                                   gridDelegate:
//                                       const SliverGridDelegateWithFixedCrossAxisCount(
//                                     crossAxisCount:
//                                         2,
//                                     crossAxisSpacing:
//                                         12,
//                                     mainAxisSpacing:
//                                         12,
//                                     childAspectRatio:
//                                         0.76,
//                                   ),
//                                   itemCount:
//                                       filteredPets
//                                           .length,
//                                   itemBuilder:
//                                       (context,
//                                           index) {
//                                     return _buildSearchPetCard(
//                                       context,
//                                       filteredPets[
//                                           index],
//                                     );
//                                   },
//                                 ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // ============================================================
//   // CATEGORY CARD
//   // ============================================================

//   Widget _buildCategoryCard({
//     required String title,
//     required IconData icon,
//     required Color iconBackground,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 100,
//         decoration: BoxDecoration(
//           color: const Color(0xFFE5F5FD),
//           borderRadius:
//               BorderRadius.circular(12),
//         ),
//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 42,
//               height: 42,
//               decoration: BoxDecoration(
//                 color: iconBackground,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color:
//                     const Color(0xFF67310F),
//                 size: 25,
//               ),
//             ),

//             const SizedBox(width: 10),

//             Text(
//               title,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 13,
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FEATURED PETS
//   // ============================================================

//   Widget _buildFeaturedPets(
//       BuildContext context) {
//     final featuredPets = [
//       {
//         'name': 'Max',
//         'breed': 'Golden Retriever',
//         'age': '2 yrs',
//         'image':
//             'https://images.unsplash.com/photo-1552053831-71594a27632d?w=800',
//         'local': true,
//       },
//       {
//         'name': 'Luna',
//         'breed': 'Domestic Shorthair',
//         'age': '1 yr',
//         'image':
//             'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=800',
//         'local': false,
//       },
//     ];

//     return SizedBox(
//       height: 164,
//       child: ListView.separated(
//         scrollDirection:
//             Axis.horizontal,
//         physics:
//             const BouncingScrollPhysics(),
//         itemCount:
//             featuredPets.length,
//         separatorBuilder: (_, __) =>
//             const SizedBox(width: 10),
//         itemBuilder:
//             (context, index) {
//           return _buildFeaturedPetCard(
//             context,
//             featuredPets[index],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFeaturedPetCard(
//     BuildContext context,
//     Map<String, dynamic> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(
//           SnackBar(
//             content: Text(
//               'Opening ${pet['name']} profile.',
//             ),
//           ),
//         );
//       },
//       child: Container(
//         width: 178,
//         decoration: BoxDecoration(
//           color: Colors.black,
//           borderRadius:
//               BorderRadius.circular(18),
//         ),
//         clipBehavior:
//             Clip.antiAlias,
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: Image.network(
//                 pet['image'],
//                 fit: BoxFit.cover,
//                 errorBuilder:
//                     (_, __, ___) {
//                   return Container(
//                     color:
//                         const Color(0xFF222222),
//                     child: const Icon(
//                       Icons.pets,
//                       color: Colors.white,
//                       size: 45,
//                     ),
//                   );
//                 },
//               ),
//             ),

//             Positioned.fill(
//               child: DecoratedBox(
//                 decoration:
//                     BoxDecoration(
//                   gradient:
//                       LinearGradient(
//                     begin:
//                         Alignment.topCenter,
//                     end:
//                         Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       Colors.black
//                           .withOpacity(0.9),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 8,
//               right: 8,
//               child: GestureDetector(
//                 onTap: () {
//                   ScaffoldMessenger.of(
//                           context)
//                       .showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         '${pet['name']} added to favorites.',
//                       ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration:
//                       BoxDecoration(
//                     color: Colors.white
//                         .withOpacity(0.55),
//                     shape:
//                         BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.favorite_border,
//                     color:
//                         Color(0xFF16414A),
//                     size: 18,
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               left: 10,
//               right: 8,
//               bottom: 8,
//               child: Row(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment
//                               .start,
//                       children: [
//                         Text(
//                           pet['name'],
//                           style:
//                               const TextStyle(
//                             color:
//                                 Colors.white,
//                             fontSize: 18,
//                             fontWeight:
//                                 FontWeight
//                                     .bold,
//                           ),
//                         ),

//                         const SizedBox(
//                             height: 1),

//                         Text(
//                           '${pet['breed']} • ${pet['age']}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow
//                                   .ellipsis,
//                           style:
//                               const TextStyle(
//                             color:
//                                 Colors.white,
//                             fontSize: 8.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   if (pet['local'] == true)
//                     Container(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 7,
//                         vertical: 4,
//                       ),
//                       decoration:
//                           BoxDecoration(
//                         color:
//                             const Color(
//                                 0xFF008F82),
//                         borderRadius:
//                             BorderRadius
//                                 .circular(
//                           15,
//                         ),
//                       ),
//                       child:
//                           const Text(
//                         'Local',
//                         style:
//                             TextStyle(
//                           color:
//                               Colors.white,
//                           fontSize: 7,
//                           fontWeight:
//                               FontWeight
//                                   .w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // RECOMMENDED PETS
//   // ============================================================

//   Widget _buildRecommendedPets(
//       BuildContext context) {
//     final recommendedPets = [
//       {
//         'name': 'Charlie',
//         'breed': 'Bulldog',
//         'age': '3 yrs',
//         'image':
//             'https://images.unsplash.com/photo-1558788353-f76d92427f16?w=800',
//       },
//       {
//         'name': 'Milo',
//         'breed': 'Siamese',
//         'age': '2 yrs',
//         'image':
//             'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800',
//       },
//       {
//         'name': 'Daisy',
//         'breed': 'Poodle',
//         'age': '1 yr',
//         'image':
//             'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800',
//       },
//       {
//         'name': 'Oliver',
//         'breed': 'Tabby',
//         'age': '4 mos',
//         'image':
//             'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=800',
//       },
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       physics:
//           const NeverScrollableScrollPhysics(),
//       itemCount:
//           recommendedPets.length,
//       gridDelegate:
//           const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 0.82,
//       ),
//       itemBuilder:
//           (context, index) {
//         return _buildRecommendedPetCard(
//           context,
//           recommendedPets[index],
//         );
//       },
//     );
//   }

//   Widget _buildRecommendedPetCard(
//     BuildContext context,
//     Map<String, String> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(
//           SnackBar(
//             content: Text(
//               'Opening ${pet['name']} profile.',
//             ),
//           ),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.circular(11),
//           boxShadow: [
//             BoxShadow(
//               color:
//                   Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         clipBehavior:
//             Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Image.network(
//                 pet['image']!,
//                 width:
//                     double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder:
//                     (_, __, ___) {
//                   return Container(
//                     color:
//                         const Color(0xFFE9EEF0),
//                     child: const Center(
//                       child: Icon(
//                         Icons.pets,
//                         size: 35,
//                         color:
//                             Color(0xFFA94327),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             Padding(
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 8,
//                 6,
//                 8,
//                 7,
//               ),
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     pet['name']!,
//                     style: TextStyle(
//                       color: darkText,
//                       fontSize: 12,
//                       fontWeight:
//                           FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(height: 1),

//                   Text(
//                     '${pet['breed']} • ${pet['age']}',
//                     maxLines: 1,
//                     overflow:
//                         TextOverflow.ellipsis,
//                     style:
//                         const TextStyle(
//                       color:
//                           Color(0xFF6E5D57),
//                       fontSize: 8,
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































// import 'package:flutter/material.dart';

// import 'pets_screen.dart';
// import 'ar_view_screen.dart';
// import 'feed_screen.dart';
// import 'profile_screen.dart';
// // import 'community_feed_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;

//   final Color backgroundColor = const Color(0xFFF5FAFD);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,

//       body: SafeArea(
//         child: IndexedStack(
//           index: _selectedIndex,
//           children: const [
//             HomeContentScreen(),
//             PetsScreen(),
//             ARViewScreen(),
//             FeedScreen(),
//             ProfileScreen(),
//           ],
//         ),
//       ),

//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   // ============================================================
//   // BOTTOM NAVIGATION
//   // ============================================================

//   Widget _buildBottomNavigationBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFE2F5FC),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 4,
//             vertical: 4,
//           ),
//           child: Row(
//             mainAxisAlignment:
//                 MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(
//                 index: 0,
//                 icon: Icons.home_rounded,
//                 label: 'Home',
//               ),

//               _buildNavItem(
//                 index: 1,
//                 icon: Icons.pets,
//                 label: 'Pets',
//               ),

//               _buildNavItem(
//                 index: 2,
//                 icon: Icons.center_focus_strong,
//                 label: 'AR View',
//               ),

//               _buildNavItem(
//                 index: 3,
//                 icon: Icons.people_outline,
//                 label: 'Feed',
//               ),

//               _buildNavItem(
//                 index: 4,
//                 icon: Icons.person_outline,
//                 label: 'Profile',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required int index,
//     required IconData icon,
//     required String label,
//   }) {
//     final bool selected = _selectedIndex == index;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedIndex = index;
//         });
//       },
//       child: AnimatedContainer(
//         duration: const Duration(
//           milliseconds: 200,
//         ),
//         padding: const EdgeInsets.symmetric(
//           horizontal: 11,
//           vertical: 5,
//         ),
//         decoration: BoxDecoration(
//           color: selected
//               ? const Color(0xFFFFB15F)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 19,
//               color: selected
//                   ? const Color(0xFF713711)
//                   : const Color(0xFF526069),
//             ),

//             const SizedBox(height: 1),

//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 8,
//                 color: selected
//                     ? const Color(0xFF713711)
//                     : const Color(0xFF526069),
//                 fontWeight: selected
//                     ? FontWeight.w600
//                     : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ================================================================
// // HOME CONTENT
// // ================================================================

// class HomeContentScreen extends StatelessWidget {
//   const HomeContentScreen({super.key});

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color darkText = const Color(0xFF062B35);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildTopHeader(context),

//         Expanded(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(
//               10,
//               10,
//               10,
//               16,
//             ),
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 _buildHeroBanner(context),

//                 const SizedBox(height: 16),

//                 _buildSectionTitle(
//                   title: 'Categories',
//                   showSeeAll: false,
//                 ),

//                 const SizedBox(height: 8),

//                 _buildCategories(context),

//                 const SizedBox(height: 18),

//                 _buildSectionTitle(
//                   title: 'Featured Pets',
//                   showSeeAll: true,
//                   onSeeAll: () {
//                     // Find the parent HomeScreen
//                     final state =
//                         context.findAncestorStateOfType<
//                             _HomeScreenState>();

//                     state?.setState(() {
//                       state._selectedIndex = 1;
//                     });
//                   },
//                 ),

//                 const SizedBox(height: 8),

//                 _buildFeaturedPets(context),

//                 const SizedBox(height: 18),

//                 _buildSectionTitle(
//                   title: 'Recommended for You',
//                   showSeeAll: false,
//                 ),

//                 const SizedBox(height: 8),

//                 _buildRecommendedPets(context),

//                 const SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // TOP HEADER
//   // ============================================================

//   Widget _buildTopHeader(BuildContext context) {
//     return Container(
//       height: 58,
//       padding: const EdgeInsets.symmetric(
//         horizontal: 10,
//       ),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE5E5E5),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: const Color(0xFFE0E0E0),
//               ),
//               image: const DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(width: 9),

//           Expanded(
//             child: Text(
//               'My Future Pet',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 19,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           IconButton(
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 35,
//               minHeight: 35,
//             ),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text(
//                     'No new notifications.',
//                   ),
//                   behavior:
//                       SnackBarBehavior.floating,
//                 ),
//               );
//             },
//             icon: Icon(
//               Icons.notifications_none_rounded,
//               color: darkText,
//               size: 22,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HERO
//   // ============================================================

//   Widget _buildHeroBanner(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final double width = constraints.maxWidth;

//         final double titleSize =
//             width < 400 ? 28 : 36;

//         final double descriptionSize =
//             width < 400 ? 14 : 17;

//         final double buttonHeight =
//             width < 400 ? 48 : 56;

//         final double horizontalPadding =
//             width < 400 ? 24 : 34;

//         return Container(
//           width: double.infinity,
//           height: width < 400 ? 215 : 235,
//           padding: EdgeInsets.fromLTRB(
//             horizontalPadding,
//             28,
//             horizontalPadding,
//             26,
//           ),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(30),
//             gradient: const LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color(0xFFC95635),
//                 Color(0xFF99644F),
//               ],
//             ),
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                 right: 5,
//                 top: 0,
//                 child: Container(
//                   width: width < 400 ? 80 : 105,
//                   height: width < 400 ? 80 : 105,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(
//                       0.08,
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),

//               Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Find your new best\nfriend',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: titleSize,
//                       height: 1.05,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: -0.5,
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   Text(
//                     'Discover pets available for adoption.',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: descriptionSize,
//                       height: 1.3,
//                     ),
//                   ),

//                   const Spacer(),

//                   SizedBox(
//                     height: buttonHeight,
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context)
//                             .showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               'Pet search coming soon.',
//                             ),
//                           ),
//                         );
//                       },
//                       icon: Icon(
//                         Icons.search_rounded,
//                         size: width < 400 ? 24 : 30,
//                       ),
//                       label: Text(
//                         'Start Search',
//                         style: TextStyle(
//                           fontSize:
//                               width < 400 ? 16 : 19,
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),
//                       style:
//                           ElevatedButton.styleFrom(
//                         backgroundColor:
//                             const Color(0xFFAA3F20),
//                         foregroundColor:
//                             Colors.white,
//                         elevation: 0,
//                         padding:
//                             EdgeInsets.symmetric(
//                           horizontal:
//                               width < 500
//                                   ? 32
//                                   : 42,
//                         ),
//                         shape:
//                             RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(
//                             35,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

//   Widget _buildSectionTitle({
//     required String title,
//     required bool showSeeAll,
//     VoidCallback? onSeeAll,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             title,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),

//         if (showSeeAll)
//           GestureDetector(
//             onTap: onSeeAll,
//             child: Text(
//               'See all ›',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 9,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   // ============================================================
//   // CATEGORIES
//   // ============================================================

//   Widget _buildCategories(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildCategoryCard(
//             title: 'Dogs',
//             icon: Icons.pets,
//             iconBackground:
//                 const Color(0xFFFFAF62),
//             onTap: () {
//               ScaffoldMessenger.of(context)
//                   .showSnackBar(
//                 const SnackBar(
//                   content: Text(
//                     'Showing dogs.',
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 10),

//         Expanded(
//           child: _buildCategoryCard(
//             title: 'Cats',
//             icon: Icons.cruelty_free,
//             iconBackground:
//                 const Color(0xFF008F82),
//             onTap: () {
//               ScaffoldMessenger.of(context)
//                   .showSnackBar(
//                 const SnackBar(
//                   content: Text(
//                     'Showing cats.',
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryCard({
//     required String title,
//     required IconData icon,
//     required Color iconBackground,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 100,
//         decoration: BoxDecoration(
//           color: const Color(0xFFE5F5FD),
//           borderRadius:
//               BorderRadius.circular(12),
//         ),
//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 42,
//               height: 42,
//               decoration: BoxDecoration(
//                 color: iconBackground,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: const Color(0xFF67310F),
//                 size: 25,
//               ),
//             ),

//             const SizedBox(width: 10),

//             Text(
//               title,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 13,
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FEATURED PETS
//   // ============================================================

//   Widget _buildFeaturedPets(BuildContext context) {
//     final featuredPets = [
//       {
//         'name': 'Max',
//         'breed': 'Golden Retriever',
//         'age': '2 yrs',
//         'image':
//             'https://images.unsplash.com/photo-1552053831-71594a27632d?w=800',
//         'local': true,
//       },
//       {
//         'name': 'Luna',
//         'breed': 'Domestic Shorthair',
//         'age': '1 yr',
//         'image':
//             'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=800',
//         'local': false,
//       },
//     ];

//     return SizedBox(
//       height: 164,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         itemCount: featuredPets.length,
//         separatorBuilder: (_, __) =>
//             const SizedBox(width: 10),
//         itemBuilder: (context, index) {
//           return _buildFeaturedPetCard(
//             context,
//             featuredPets[index],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFeaturedPetCard(
//     BuildContext context,
//     Map<String, dynamic> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(
//           SnackBar(
//             content: Text(
//               'Opening ${pet['name']} profile.',
//             ),
//           ),
//         );
//       },
//       child: Container(
//         width: 178,
//         decoration: BoxDecoration(
//           color: Colors.black,
//           borderRadius:
//               BorderRadius.circular(18),
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: Image.network(
//                 pet['image'],
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) {
//                   return Container(
//                     color: const Color(0xFF222222),
//                     child: const Icon(
//                       Icons.pets,
//                       color: Colors.white,
//                       size: 45,
//                     ),
//                   );
//                 },
//               ),
//             ),

//             Positioned.fill(
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       Colors.black.withOpacity(0.9),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 8,
//               right: 8,
//               child: GestureDetector(
//                 onTap: () {
//                   ScaffoldMessenger.of(context)
//                       .showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         '${pet['name']} added to favorites.',
//                       ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(
//                       0.55,
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.favorite_border,
//                     color: Color(0xFF16414A),
//                     size: 18,
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               left: 10,
//               right: 8,
//               bottom: 8,
//               child: Row(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           pet['name'],
//                           style:
//                               const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight:
//                                 FontWeight.bold,
//                           ),
//                         ),

//                         const SizedBox(height: 1),

//                         Text(
//                           '${pet['breed']} • ${pet['age']}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style:
//                               const TextStyle(
//                             color: Colors.white,
//                             fontSize: 8.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   if (pet['local'] == true)
//                     Container(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 7,
//                         vertical: 4,
//                       ),
//                       decoration:
//                           BoxDecoration(
//                         color:
//                             const Color(0xFF008F82),
//                         borderRadius:
//                             BorderRadius.circular(
//                           15,
//                         ),
//                       ),
//                       child: const Text(
//                         'Local',
//                         style:
//                             TextStyle(
//                           color: Colors.white,
//                           fontSize: 7,
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // RECOMMENDED PETS
//   // ============================================================

//   Widget _buildRecommendedPets(BuildContext context) {
//     final recommendedPets = [
//       {
//         'name': 'Charlie',
//         'breed': 'Bulldog',
//         'age': '3 yrs',
//         'image':
//             'https://images.unsplash.com/photo-1558788353-f76d92427f16?w=800',
//       },
//       {
//         'name': 'Milo',
//         'breed': 'Siamese',
//         'age': '2 yrs',
//         'image':
//             'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800',
//       },
//       {
//         'name': 'Daisy',
//         'breed': 'Poodle',
//         'age': '1 yr',
//         'image':
//             'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800',
//       },
//       {
//         'name': 'Oliver',
//         'breed': 'Tabby',
//         'age': '4 mos',
//         'image':
//             'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=800',
//       },
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       physics:
//           const NeverScrollableScrollPhysics(),
//       itemCount: recommendedPets.length,
//       gridDelegate:
//           const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 0.82,
//       ),
//       itemBuilder: (context, index) {
//         return _buildRecommendedPetCard(
//           context,
//           recommendedPets[index],
//         );
//       },
//     );
//   }

//   Widget _buildRecommendedPetCard(
//     BuildContext context,
//     Map<String, String> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(
//           SnackBar(
//             content: Text(
//               'Opening ${pet['name']} profile.',
//             ),
//           ),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.circular(11),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Image.network(
//                 pet['image']!,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) {
//                   return Container(
//                     color: const Color(0xFFE9EEF0),
//                     child: const Center(
//                       child: Icon(
//                         Icons.pets,
//                         size: 35,
//                         color: Color(0xFFA94327),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 8,
//                 6,
//                 8,
//                 7,
//               ),
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     pet['name']!,
//                     style: TextStyle(
//                       color: darkText,
//                       fontSize: 12,
//                       fontWeight:
//                           FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(height: 1),

//                   Text(
//                     '${pet['breed']} • ${pet['age']}',
//                     maxLines: 1,
//                     overflow:
//                         TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: Color(0xFF6E5D57),
//                       fontSize: 8,
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








// import 'package:flutter/material.dart';

// import '../services/auth_service.dart';
// import 'login_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color backgroundColor = const Color(0xFFF5FAFD);
//   final Color darkText = const Color(0xFF062B35);

//   // ============================================================
//   // FEATURED PETS
//   // ============================================================

//   final List<Map<String, dynamic>> featuredPets = [
//     {
//       'name': 'Max',
//       'breed': 'Golden Retriever',
//       'age': '2 yrs',
//       'image':
//           'https://images.unsplash.com/photo-1552053831-71594a27632d?w=800',
//       'local': true,
//     },
//     {
//       'name': 'Luna',
//       'breed': 'Domestic Shorthair',
//       'age': '1 yr',
//       'image':
//           'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=800',
//       'local': false,
//     },
//   ];

//   // ============================================================
//   // RECOMMENDED PETS
//   // ============================================================

//   final List<Map<String, String>> recommendedPets = [
//     {
//       'name': 'Charlie',
//       'breed': 'Bulldog',
//       'age': '3 yrs',
//       'image':
//           'https://images.unsplash.com/photo-1558788353-f76d92427f16?w=800',
//     },
//     {
//       'name': 'Milo',
//       'breed': 'Siamese',
//       'age': '2 yrs',
//       'image':
//           'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800',
//     },
//     {
//       'name': 'Daisy',
//       'breed': 'Poodle',
//       'age': '1 yr',
//       'image':
//           'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800',
//     },
//     {
//       'name': 'Oliver',
//       'breed': 'Tabby',
//       'age': '4 mos',
//       'image':
//           'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=800',
//     },
//   ];

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,

//       body: SafeArea(
//         child: IndexedStack(
//           index: _selectedIndex,
//           children: [
//             _buildHomePage(),
//             _buildPetsPage(),
//             _buildARPage(),
//             _buildFeedPage(),
//             _buildProfilePage(),
//           ],
//         ),
//       ),

//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   // ============================================================
//   // HOME PAGE
//   // ============================================================

//   Widget _buildHomePage() {
//     return Column(
//       children: [
//         // TOP HEADER
//         _buildTopHeader(),

//         // HOME CONTENT
//         Expanded(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(
//               10,
//               10,
//               10,
//               16,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // HERO
//                 _buildHeroBanner(),

//                 const SizedBox(height: 16),

//                 // CATEGORIES
//                 _buildSectionTitle(
//                   title: 'Categories',
//                   showSeeAll: false,
//                 ),

//                 const SizedBox(height: 8),

//                 _buildCategories(),

//                 const SizedBox(height: 18),

//                 // FEATURED
//                 _buildSectionTitle(
//                   title: 'Featured Pets',
//                   showSeeAll: true,
//                   onSeeAll: () {
//                     setState(() {
//                       _selectedIndex = 1;
//                     });
//                   },
//                 ),

//                 const SizedBox(height: 8),

//                 _buildFeaturedPets(),

//                 const SizedBox(height: 18),

//                 // RECOMMENDED
//                 _buildSectionTitle(
//                   title: 'Recommended for You',
//                   showSeeAll: false,
//                 ),

//                 const SizedBox(height: 8),

//                 _buildRecommendedPets(),

//                 const SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // TOP HEADER
//   // ============================================================

//   Widget _buildTopHeader() {
//     final user = AuthService().currentUser;

//     return Container(
//       height: 58,
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE5E5E5),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           // PROFILE IMAGE
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: const Color(0xFFE0E0E0),
//               ),
//               image: const DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(width: 9),

//           // APP NAME
//           Expanded(
//             child: Text(
//               'My Future Pet',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 19,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           // NOTIFICATION
//           IconButton(
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 35,
//               minHeight: 35,
//             ),
//             onPressed: () {
//               _showMessage(
//                 'No new notifications.',
//               );
//             },
//             icon: Icon(
//               Icons.notifications_none_rounded,
//               color: darkText,
//               size: 22,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HERO BANNER
//   // ============================================================

//   Widget _buildHeroBanner() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final double width = constraints.maxWidth;

//         // Responsive sizes
//         final double titleSize =
//             width < 400 ? 28 : 36;

//         final double descriptionSize =
//             width < 400 ? 14 : 17;

//         final double buttonHeight =
//             width < 400 ? 48 : 56;

//         final double horizontalPadding =
//             width < 400 ? 24 : 34;

//         return Container(
//           width: double.infinity,

//           // IMPORTANT:
//           // Increased from 108 to prevent overflow
//           height: width < 400 ? 215 : 235,

//           padding: EdgeInsets.fromLTRB(
//             horizontalPadding,
//             28,
//             horizontalPadding,
//             26,
//           ),

//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(30),

//             gradient: const LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color(0xFFC95635),
//                 Color(0xFF99644F),
//               ],
//             ),
//           ),

//           child: Stack(
//             children: [
//               // ==================================================
//               // DECORATIVE CIRCLE
//               // ==================================================

//               Positioned(
//                 right: 5,
//                 top: 0,
//                 child: Container(
//                   width: width < 400 ? 80 : 105,
//                   height: width < 400 ? 80 : 105,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.08),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),

//               // ==================================================
//               // CONTENT
//               // ==================================================

//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // TITLE
//                   Text(
//                     'Find your new best\nfriend',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: titleSize,
//                       height: 1.05,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: -0.5,
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   // DESCRIPTION
//                   Text(
//                     'Discover pets available for adoption near\nyou.',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: descriptionSize,
//                       height: 1.3,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),

//                   const Spacer(),

//                   // ==================================================
//                   // START SEARCH BUTTON
//                   // ==================================================

//                   SizedBox(
//                     height: buttonHeight,

//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         _showMessage(
//                           'Pet search coming soon.',
//                         );
//                       },

//                       icon: Icon(
//                         Icons.search_rounded,
//                         size: width < 400 ? 24 : 30,
//                       ),

//                       label: Text(
//                         'Start Search',
//                         style: TextStyle(
//                           fontSize:
//                               width < 400 ? 16 : 19,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),

//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             const Color(0xFFAA3F20),

//                         foregroundColor:
//                             Colors.white,

//                         elevation: 0,

//                         padding:
//                             EdgeInsets.symmetric(
//                           horizontal:
//                               width < 500 ? 32 : 42,
//                         ),

//                         shape:
//                             RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(
//                             35,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

//   Widget _buildSectionTitle({
//     required String title,
//     required bool showSeeAll,
//     VoidCallback? onSeeAll,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             title,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),

//         if (showSeeAll)
//           GestureDetector(
//             onTap: onSeeAll,
//             child: Text(
//               'See all ›',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 9,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   // ============================================================
//   // CATEGORIES
//   // ============================================================

//   Widget _buildCategories() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildCategoryCard(
//             title: 'Dogs',
//             icon: Icons.pets,
//             iconBackground:
//                 const Color(0xFFFFAF62),
//             onTap: () {
//               _showMessage(
//                 'Showing dogs.',
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 10),

//         Expanded(
//           child: _buildCategoryCard(
//             title: 'Cats',
//             icon: Icons.cruelty_free,
//             iconBackground:
//                 const Color(0xFF008F82),
//             onTap: () {
//               _showMessage(
//                 'Showing cats.',
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryCard({
//     required String title,
//     required IconData icon,
//     required Color iconBackground,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 100,
//         decoration: BoxDecoration(
//           color: const Color(0xFFE5F5FD),
//           borderRadius:
//               BorderRadius.circular(12),
//         ),
//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 42,
//               height: 42,
//               decoration: BoxDecoration(
//                 color: iconBackground,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: const Color(0xFF67310F),
//                 size: 25,
//               ),
//             ),

//             const SizedBox(width: 10),

//             Text(
//               title,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FEATURED PETS
//   // ============================================================

//   Widget _buildFeaturedPets() {
//     return SizedBox(
//       height: 164,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         itemCount: featuredPets.length,
//         separatorBuilder: (_, __) =>
//             const SizedBox(width: 10),
//         itemBuilder: (context, index) {
//           return _buildFeaturedPetCard(
//             featuredPets[index],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFeaturedPetCard(
//     Map<String, dynamic> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         _showMessage(
//           'Opening ${pet['name']} profile.',
//         );
//       },
//       child: Container(
//         width: 178,
//         decoration: BoxDecoration(
//           color: Colors.black,
//           borderRadius:
//               BorderRadius.circular(18),
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Stack(
//           children: [
//             // IMAGE
//             Positioned.fill(
//               child: Image.network(
//                 pet['image'],
//                 fit: BoxFit.cover,
//                 errorBuilder:
//                     (_, __, ___) {
//                   return Container(
//                     color:
//                         const Color(0xFF222222),
//                     child: const Icon(
//                       Icons.pets,
//                       color: Colors.white,
//                       size: 45,
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // GRADIENT
//             Positioned.fill(
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin:
//                         Alignment.topCenter,
//                     end:
//                         Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       Colors.black.withOpacity(
//                         0.9,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // FAVORITE
//             Positioned(
//               top: 8,
//               right: 8,
//               child: GestureDetector(
//                 onTap: () {
//                   _showMessage(
//                     '${pet['name']} added to favorites.',
//                   );
//                 },
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration:
//                       BoxDecoration(
//                     color: Colors.white
//                         .withOpacity(0.55),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.favorite_border,
//                     color:
//                         Color(0xFF16414A),
//                     size: 18,
//                   ),
//                 ),
//               ),
//             ),

//             // INFORMATION
//             Positioned(
//               left: 10,
//               right: 8,
//               bottom: 8,
//               child: Row(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           pet['name'],
//                           style:
//                               const TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight:
//                                 FontWeight.bold,
//                           ),
//                         ),

//                         const SizedBox(height: 1),

//                         Text(
//                           '${pet['breed']} • ${pet['age']}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style:
//                               const TextStyle(
//                             color: Colors.white,
//                             fontSize: 8.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   if (pet['local'] == true)
//                     Container(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 7,
//                         vertical: 4,
//                       ),
//                       decoration:
//                           BoxDecoration(
//                         color:
//                             const Color(
//                           0xFF008F82,
//                         ),
//                         borderRadius:
//                             BorderRadius.circular(
//                           15,
//                         ),
//                       ),
//                       child: const Text(
//                         'Local',
//                         style:
//                             TextStyle(
//                           color: Colors.white,
//                           fontSize: 7,
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // RECOMMENDED PETS
//   // ============================================================

//   Widget _buildRecommendedPets() {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics:
//           const NeverScrollableScrollPhysics(),
//       itemCount: recommendedPets.length,
//       gridDelegate:
//           const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 0.82,
//       ),
//       itemBuilder: (context, index) {
//         return _buildRecommendedPetCard(
//           recommendedPets[index],
//         );
//       },
//     );
//   }

//   Widget _buildRecommendedPetCard(
//     Map<String, String> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         _showMessage(
//           'Opening ${pet['name']} profile.',
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.circular(11),
//           boxShadow: [
//             BoxShadow(
//               color:
//                   Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset:
//                   const Offset(0, 1),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,
//           children: [
//             // IMAGE
//             Expanded(
//               child: Image.network(
//                 pet['image']!,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder:
//                     (_, __, ___) {
//                   return Container(
//                     color:
//                         const Color(0xFFE9EEF0),
//                     child: const Center(
//                       child: Icon(
//                         Icons.pets,
//                         size: 35,
//                         color:
//                             Color(0xFFA94327),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // INFORMATION
//             Padding(
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 8,
//                 6,
//                 8,
//                 7,
//               ),
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     pet['name']!,
//                     style: TextStyle(
//                       color: darkText,
//                       fontSize: 12,
//                       fontWeight:
//                           FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(height: 1),

//                   Text(
//                     '${pet['breed']} • ${pet['age']}',
//                     maxLines: 1,
//                     overflow:
//                         TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color:
//                           Color(0xFF6E5D57),
//                       fontSize: 8,
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

//   // ============================================================
//   // BOTTOM NAVIGATION
//   // ============================================================

//   Widget _buildBottomNavigationBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFE2F5FC),
//         boxShadow: [
//           BoxShadow(
//             color:
//                 Colors.black.withOpacity(0.08),
//             blurRadius: 8,
//             offset:
//                 const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding:
//               const EdgeInsets.symmetric(
//             horizontal: 4,
//             vertical: 4,
//           ),
//           child: Row(
//             mainAxisAlignment:
//                 MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(
//                 index: 0,
//                 icon: Icons.home_rounded,
//                 label: 'Home',
//               ),
//               _buildNavItem(
//                 index: 1,
//                 icon: Icons.pets,
//                 label: 'Pets',
//               ),
//               _buildNavItem(
//                 index: 2,
//                 icon: Icons.center_focus_strong,
//                 label: 'AR View',
//               ),
//               _buildNavItem(
//                 index: 3,
//                 icon: Icons.people_outline,
//                 label: 'Feed',
//               ),
//               _buildNavItem(
//                 index: 4,
//                 icon: Icons.person_outline,
//                 label: 'Profile',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required int index,
//     required IconData icon,
//     required String label,
//   }) {
//     final bool selected =
//         _selectedIndex == index;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedIndex = index;
//         });
//       },
//       child: AnimatedContainer(
//         duration:
//             const Duration(milliseconds: 200),
//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 11,
//           vertical: 5,
//         ),
//         decoration: BoxDecoration(
//           color: selected
//               ? const Color(0xFFFFB15F)
//               : Colors.transparent,
//           borderRadius:
//               BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 19,
//               color: selected
//                   ? const Color(0xFF713711)
//                   : const Color(0xFF526069),
//             ),

//             const SizedBox(height: 1),

//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 8,
//                 color: selected
//                     ? const Color(0xFF713711)
//                     : const Color(0xFF526069),
//                 fontWeight: selected
//                     ? FontWeight.w600
//                     : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PETS PAGE
//   // ============================================================

//   Widget _buildPetsPage() {
//     return _buildPlaceholderPage(
//       icon: Icons.pets,
//       title: 'Pets',
//       description:
//           'Browse pets available for adoption.',
//     );
//   }

//   // ============================================================
//   // AR PAGE
//   // ============================================================

//   Widget _buildARPage() {
//     return _buildPlaceholderPage(
//       icon: Icons.center_focus_strong,
//       title: 'AR View',
//       description:
//           'View pets using Augmented Reality.',
//     );
//   }

//   // ============================================================
//   // FEED PAGE
//   // ============================================================

//   Widget _buildFeedPage() {
//     return _buildPlaceholderPage(
//       icon: Icons.people_outline,
//       title: 'Community Feed',
//       description:
//           'See updates from the pet community.',
//     );
//   }

//   // ============================================================
//   // PROFILE PAGE
//   // ============================================================

//   Widget _buildProfilePage() {
//     final user =
//         AuthService().currentUser;

//     final String displayName =
//         user?.userMetadata?['name']
//                 ?.toString() ??
//             user?.email
//                     ?.split('@')
//                     .first ??
//                 'Pet Lover';

//     return SingleChildScrollView(
//       padding:
//           const EdgeInsets.all(25),
//       child: Column(
//         children: [
//           const SizedBox(height: 30),

//           // PROFILE IMAGE
//           const CircleAvatar(
//             radius: 48,
//             backgroundColor:
//                 Color(0xFFE5F5FD),
//             child: Icon(
//               Icons.person,
//               size: 50,
//               color: Color(0xFFA94327),
//             ),
//           ),

//           const SizedBox(height: 14),

//           // NAME
//           Text(
//             displayName,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 22,
//               fontWeight:
//                   FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 5),

//           // EMAIL
//           Text(
//             user?.email ?? '',
//             style: const TextStyle(
//               color: Colors.grey,
//               fontSize: 13,
//             ),
//           ),

//           const SizedBox(height: 30),

//           // LOGOUT BUTTON
//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: ElevatedButton.icon(
//               onPressed: _logout,
//               icon: const Icon(
//                 Icons.logout,
//                 size: 20,
//               ),
//               label: const Text(
//                 'Logout',
//                 style: TextStyle(
//                   fontWeight:
//                       FontWeight.w600,
//                 ),
//               ),
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
//                     25,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PLACEHOLDER PAGE
//   // ============================================================

//   Widget _buildPlaceholderPage({
//     required IconData icon,
//     required String title,
//     required String description,
//   }) {
//     return Center(
//       child: Padding(
//         padding:
//             const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 70,
//               color: primaryColor,
//             ),

//             const SizedBox(height: 15),

//             Text(
//               title,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 25,
//                 fontWeight:
//                     FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 8),

//             Text(
//               description,
//               textAlign:
//                   TextAlign.center,
//               style:
//                   const TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // LOGOUT
//   // ============================================================

//   Future<void> _logout() async {
//     try {
//       await AuthService().logout();

//       if (!mounted) return;

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(
//           builder: (_) =>
//               const LoginScreen(),
//         ),
//         (route) => false,
//       );
//     } catch (e) {
//       if (!mounted) return;

//       _showMessage(
//         'Logout failed: $e',
//       );
//     }
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior:
//             SnackBarBehavior.floating,
//       ),
//     );
//   }
// }











// import 'package:flutter/material.dart';

// import '../services/auth_service.dart';
// import 'login_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color backgroundColor = const Color(0xFFF5FAFD);
//   final Color darkText = const Color(0xFF062B35);

//   // ============================================================
//   // FEATURED PETS
//   // ============================================================

//   final List<Map<String, dynamic>> featuredPets = [
//     {
//       'name': 'Max',
//       'breed': 'Golden Retriever',
//       'age': '2 yrs',
//       'image':
//           'https://images.unsplash.com/photo-1552053831-71594a27632d?w=800',
//       'local': true,
//     },
//     {
//       'name': 'Luna',
//       'breed': 'Domestic Shorthair',
//       'age': '1 yr',
//       'image':
//           'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=800',
//       'local': false,
//     },
//   ];

//   // ============================================================
//   // RECOMMENDED PETS
//   // ============================================================

//   final List<Map<String, String>> recommendedPets = [
//     {
//       'name': 'Charlie',
//       'breed': 'Bulldog',
//       'age': '3 yrs',
//       'image':
//           'https://images.unsplash.com/photo-1558788353-f76d92427f16?w=800',
//     },
//     {
//       'name': 'Milo',
//       'breed': 'Siamese',
//       'age': '2 yrs',
//       'image':
//           'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800',
//     },
//     {
//       'name': 'Daisy',
//       'breed': 'Poodle',
//       'age': '1 yr',
//       'image':
//           'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800',
//     },
//     {
//       'name': 'Oliver',
//       'breed': 'Tabby',
//       'age': '4 mos',
//       'image':
//           'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=800',
//     },
//   ];

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: IndexedStack(
//           index: _selectedIndex,
//           children: [
//             _buildHomePage(),
//             _buildPetsPage(),
//             _buildARPage(),
//             _buildFeedPage(),
//             _buildProfilePage(),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   // ============================================================
//   // HOME PAGE
//   // ============================================================

//   Widget _buildHomePage() {
//     return Column(
//       children: [
//         _buildTopHeader(),

//         Expanded(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(
//               20,
//               20,
//               20,
//               24,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // HERO
//                 _buildHeroBanner(),

//                 const SizedBox(height: 32),

//                 // CATEGORIES
//                 _buildSectionTitle(
//                   title: 'Categories',
//                   showSeeAll: false,
//                 ),

//                 const SizedBox(height: 16),

//                 _buildCategories(),

//                 const SizedBox(height: 36),

//                 // FEATURED
//                 _buildSectionTitle(
//                   title: 'Featured Pets',
//                   showSeeAll: true,
//                   onSeeAll: () {
//                     setState(() {
//                       _selectedIndex = 1;
//                     });
//                   },
//                 ),

//                 const SizedBox(height: 16),

//                 _buildFeaturedPets(),

//                 const SizedBox(height: 36),

//                 // RECOMMENDED
//                 _buildSectionTitle(
//                   title: 'Recommended for You',
//                   showSeeAll: false,
//                 ),

//                 const SizedBox(height: 16),

//                 _buildRecommendedPets(),

//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // TOP HEADER
//   // ============================================================

//   Widget _buildTopHeader() {
//     return Container(
//       height: 88,
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE5E5E5),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           // PROFILE IMAGE
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: const Color(0xFFE0E0E0),
//               ),
//               image: const DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(width: 14),

//           // APP NAME
//           Expanded(
//             child: Text(
//               'My Future Pet',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           // NOTIFICATION
//           IconButton(
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 45,
//               minHeight: 45,
//             ),
//             onPressed: () {
//               _showMessage(
//                 'No new notifications.',
//               );
//             },
//             icon: Icon(
//               Icons.notifications_none_rounded,
//               color: darkText,
//               size: 32,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HERO BANNER
//   // ============================================================

//   Widget _buildHeroBanner() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final double width = constraints.maxWidth;

//         // Responsive sizes
//         final double titleSize =
//             width < 400 ? 28 : 36;

//         final double descriptionSize =
//             width < 400 ? 14 : 17;

//         final double buttonHeight =
//             width < 400 ? 48 : 56;

//         final double horizontalPadding =
//             width < 400 ? 24 : 34;

//         return Container(
//           width: double.infinity,

//           // IMPORTANT:
//           // Increased from 108 to prevent overflow
//           height: width < 400 ? 215 : 235,

//           padding: EdgeInsets.fromLTRB(
//             horizontalPadding,
//             28,
//             horizontalPadding,
//             26,
//           ),

//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(30),

//             gradient: const LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color(0xFFC95635),
//                 Color(0xFF99644F),
//               ],
//             ),
//           ),

//           child: Stack(
//             children: [
//               // ==================================================
//               // DECORATIVE CIRCLE
//               // ==================================================

//               Positioned(
//                 right: 5,
//                 top: 0,
//                 child: Container(
//                   width: width < 400 ? 80 : 105,
//                   height: width < 400 ? 80 : 105,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.08),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),

//               // ==================================================
//               // CONTENT
//               // ==================================================

//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // TITLE
//                   Text(
//                     'Find your new best\nfriend',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: titleSize,
//                       height: 1.05,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: -0.5,
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   // DESCRIPTION
//                   Text(
//                     'Discover pets available for adoption near\nyou.',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: descriptionSize,
//                       height: 1.3,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),

//                   const Spacer(),

//                   // ==================================================
//                   // START SEARCH BUTTON
//                   // ==================================================

//                   SizedBox(
//                     height: buttonHeight,

//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         _showMessage(
//                           'Pet search coming soon.',
//                         );
//                       },

//                       icon: Icon(
//                         Icons.search_rounded,
//                         size: width < 400 ? 24 : 30,
//                       ),

//                       label: Text(
//                         'Start Search',
//                         style: TextStyle(
//                           fontSize:
//                               width < 400 ? 16 : 19,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),

//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             const Color(0xFFAA3F20),

//                         foregroundColor:
//                             Colors.white,

//                         elevation: 0,

//                         padding:
//                             EdgeInsets.symmetric(
//                           horizontal:
//                               width < 400 ? 22 : 32,
//                         ),

//                         shape:
//                             RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(
//                             35,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

//   Widget _buildSectionTitle({
//     required String title,
//     required bool showSeeAll,
//     VoidCallback? onSeeAll,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             title,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 27,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),

//         if (showSeeAll)
//           GestureDetector(
//             onTap: onSeeAll,
//             child: Text(
//               'See all ›',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   // ============================================================
//   // CATEGORIES
//   // ============================================================

//   Widget _buildCategories() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildCategoryCard(
//             title: 'Dogs',
//             icon: Icons.pets,
//             iconBackground:
//                 const Color(0xFFFFAF62),
//             onTap: () {
//               _showMessage(
//                 'Showing dogs.',
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 18),

//         Expanded(
//           child: _buildCategoryCard(
//             title: 'Cats',
//             icon: Icons.cruelty_free,
//             iconBackground:
//                 const Color(0xFF008F82),
//             onTap: () {
//               _showMessage(
//                 'Showing cats.',
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryCard({
//     required String title,
//     required IconData icon,
//     required Color iconBackground,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,

//       child: Container(
//         height: 148,

//         decoration: BoxDecoration(
//           color: const Color(0xFFE5F5FD),
//           borderRadius:
//               BorderRadius.circular(20),
//         ),

//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             Container(
//               width: 82,
//               height: 82,

//               decoration: BoxDecoration(
//                 color: iconBackground,
//                 shape: BoxShape.circle,
//               ),

//               child: Icon(
//                 icon,
//                 color: const Color(0xFF67310F),
//                 size: 44,
//               ),
//             ),

//             const SizedBox(width: 18),

//             Text(
//               title,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 23,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FEATURED PETS
//   // ============================================================

//   Widget _buildFeaturedPets() {
//     return SizedBox(
//       height: 325,

//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,

//         physics:
//             const BouncingScrollPhysics(),

//         itemCount:
//             featuredPets.length,

//         separatorBuilder: (_, __) =>
//             const SizedBox(width: 18),

//         itemBuilder:
//             (context, index) {
//           return _buildFeaturedPetCard(
//             featuredPets[index],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFeaturedPetCard(
//     Map<String, dynamic> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         _showMessage(
//           'Opening ${pet['name']} profile.',
//         );
//       },

//       child: Container(
//         width: 355,

//         decoration: BoxDecoration(
//           color: Colors.black,
//           borderRadius:
//               BorderRadius.circular(24),
//         ),

//         clipBehavior:
//             Clip.antiAlias,

//         child: Stack(
//           children: [
//             // IMAGE
//             Positioned.fill(
//               child: Image.network(
//                 pet['image'],
//                 fit: BoxFit.cover,

//                 errorBuilder:
//                     (_, __, ___) {
//                   return Container(
//                     color:
//                         const Color(0xFF222222),

//                     child:
//                         const Icon(
//                       Icons.pets,
//                       color:
//                           Colors.white,
//                       size: 60,
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // DARK GRADIENT
//             Positioned.fill(
//               child:
//                   DecoratedBox(
//                 decoration:
//                     BoxDecoration(
//                   gradient:
//                       LinearGradient(
//                     begin:
//                         Alignment.topCenter,
//                     end:
//                         Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       Colors.black
//                           .withOpacity(
//                         0.9,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // FAVORITE
//             Positioned(
//               top: 15,
//               right: 15,

//               child: GestureDetector(
//                 onTap: () {
//                   _showMessage(
//                     '${pet['name']} added to favorites.',
//                   );
//                 },

//                 child: Container(
//                   width: 52,
//                   height: 52,

//                   decoration:
//                       BoxDecoration(
//                     color: Colors.white
//                         .withOpacity(0.7),
//                     shape:
//                         BoxShape.circle,
//                   ),

//                   child:
//                       const Icon(
//                     Icons.favorite_border,
//                     color:
//                         Color(0xFF16414A),
//                     size: 30,
//                   ),
//                 ),
//               ),
//             ),

//             // INFORMATION
//             Positioned(
//               left: 20,
//               right: 18,
//               bottom: 18,

//               child: Row(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.end,

//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,

//                       children: [
//                         Text(
//                           pet['name'],
//                           style:
//                               const TextStyle(
//                             color:
//                                 Colors.white,
//                             fontSize: 28,
//                             fontWeight:
//                                 FontWeight.bold,
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 4,
//                         ),

//                         Text(
//                           '${pet['breed']} • ${pet['age']}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,

//                           style:
//                               const TextStyle(
//                             color:
//                                 Colors.white,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   if (pet['local'] == true)
//                     Container(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 14,
//                         vertical: 8,
//                       ),

//                       decoration:
//                           BoxDecoration(
//                         color:
//                             const Color(
//                           0xFF008F82,
//                         ),

//                         borderRadius:
//                             BorderRadius
//                                 .circular(
//                           20,
//                         ),
//                       ),

//                       child:
//                           const Text(
//                         'Local',
//                         style:
//                             TextStyle(
//                           color:
//                               Colors.white,
//                           fontSize: 12,
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // RECOMMENDED PETS
//   // ============================================================

//   Widget _buildRecommendedPets() {
//     return GridView.builder(
//       shrinkWrap: true,

//       physics:
//           const NeverScrollableScrollPhysics(),

//       itemCount:
//           recommendedPets.length,

//       gridDelegate:
//           const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 18,
//         mainAxisSpacing: 18,
//         childAspectRatio: 0.78,
//       ),

//       itemBuilder:
//           (context, index) {
//         return _buildRecommendedPetCard(
//           recommendedPets[index],
//         );
//       },
//     );
//   }

//   Widget _buildRecommendedPetCard(
//     Map<String, String> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         _showMessage(
//           'Opening ${pet['name']} profile.',
//         );
//       },

//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,

//           borderRadius:
//               BorderRadius.circular(18),

//           boxShadow: [
//             BoxShadow(
//               color:
//                   Colors.black.withOpacity(
//                 0.05,
//               ),
//               blurRadius: 6,
//               offset:
//                   const Offset(0, 2),
//             ),
//           ],
//         ),

//         clipBehavior:
//             Clip.antiAlias,

//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,

//           children: [
//             // IMAGE
//             Expanded(
//               child: Image.network(
//                 pet['image']!,
//                 width:
//                     double.infinity,
//                 fit: BoxFit.cover,

//                 errorBuilder:
//                     (_, __, ___) {
//                   return Container(
//                     color:
//                         const Color(
//                       0xFFE9EEF0,
//                     ),

//                     child:
//                         const Center(
//                       child: Icon(
//                         Icons.pets,
//                         size: 50,
//                         color:
//                             Color(
//                           0xFFA94327,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // INFORMATION
//             Padding(
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 14,
//                 10,
//                 14,
//                 12,
//               ),

//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,

//                 children: [
//                   Text(
//                     pet['name']!,

//                     style: TextStyle(
//                       color: darkText,
//                       fontSize: 17,
//                       fontWeight:
//                           FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(height: 3),

//                   Text(
//                     '${pet['breed']} • ${pet['age']}',

//                     maxLines: 1,

//                     overflow:
//                         TextOverflow.ellipsis,

//                     style:
//                         const TextStyle(
//                       color:
//                           Color(0xFF6E5D57),
//                       fontSize: 12,
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

//   // ============================================================
//   // BOTTOM NAVIGATION
//   // ============================================================

//   Widget _buildBottomNavigationBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color:
//             const Color(0xFFE2F5FC),

//         boxShadow: [
//           BoxShadow(
//             color:
//                 Colors.black.withOpacity(
//               0.08,
//             ),
//             blurRadius: 8,
//             offset:
//                 const Offset(0, -2),
//           ),
//         ],
//       ),

//       child: SafeArea(
//         top: false,

//         child: Padding(
//           padding:
//               const EdgeInsets.symmetric(
//             horizontal: 8,
//             vertical: 8,
//           ),

//           child: Row(
//             mainAxisAlignment:
//                 MainAxisAlignment.spaceAround,

//             children: [
//               _buildNavItem(
//                 index: 0,
//                 icon:
//                     Icons.home_rounded,
//                 label: 'Home',
//               ),

//               _buildNavItem(
//                 index: 1,
//                 icon: Icons.pets,
//                 label: 'Pets',
//               ),

//               _buildNavItem(
//                 index: 2,
//                 icon:
//                     Icons.center_focus_strong,
//                 label: 'AR View',
//               ),

//               _buildNavItem(
//                 index: 3,
//                 icon:
//                     Icons.people_outline,
//                 label: 'Feed',
//               ),

//               _buildNavItem(
//                 index: 4,
//                 icon:
//                     Icons.person_outline,
//                 label: 'Profile',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required int index,
//     required IconData icon,
//     required String label,
//   }) {
//     final bool selected =
//         _selectedIndex == index;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedIndex = index;
//         });
//       },

//       child: AnimatedContainer(
//         duration:
//             const Duration(
//           milliseconds: 200,
//         ),

//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 7,
//         ),

//         decoration: BoxDecoration(
//           color: selected
//               ? const Color(
//                   0xFFFFB15F,
//                 )
//               : Colors.transparent,

//           borderRadius:
//               BorderRadius.circular(25),
//         ),

//         child: Column(
//           mainAxisSize:
//               MainAxisSize.min,

//           children: [
//             Icon(
//               icon,
//               size: 26,

//               color: selected
//                   ? const Color(
//                       0xFF713711,
//                     )
//                   : const Color(
//                       0xFF526069,
//                     ),
//             ),

//             const SizedBox(height: 3),

//             Text(
//               label,

//               style: TextStyle(
//                 fontSize: 11,

//                 color: selected
//                     ? const Color(
//                         0xFF713711,
//                       )
//                     : const Color(
//                         0xFF526069,
//                       ),

//                 fontWeight: selected
//                     ? FontWeight.w600
//                     : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PETS PAGE
//   // ============================================================

//   Widget _buildPetsPage() {
//     return _buildPlaceholderPage(
//       icon: Icons.pets,
//       title: 'Pets',
//       description:
//           'Browse pets available for adoption.',
//     );
//   }

//   // ============================================================
//   // AR PAGE
//   // ============================================================

//   Widget _buildARPage() {
//     return _buildPlaceholderPage(
//       icon:
//           Icons.center_focus_strong,
//       title: 'AR View',
//       description:
//           'View pets using Augmented Reality.',
//     );
//   }

//   // ============================================================
//   // FEED PAGE
//   // ============================================================

//   Widget _buildFeedPage() {
//     return _buildPlaceholderPage(
//       icon:
//           Icons.people_outline,
//       title: 'Community Feed',
//       description:
//           'See updates from the pet community.',
//     );
//   }

//   // ============================================================
//   // PROFILE PAGE
//   // ============================================================

//   Widget _buildProfilePage() {
//     final user =
//         AuthService().currentUser;

//     final String displayName =
//         user?.userMetadata?['name']
//                 ?.toString() ??
//             user?.email
//                     ?.split('@')
//                     .first ??
//                 'Pet Lover';

//     return SingleChildScrollView(
//       padding:
//           const EdgeInsets.all(25),

//       child: Column(
//         children: [
//           const SizedBox(height: 30),

//           const CircleAvatar(
//             radius: 48,

//             backgroundColor:
//                 Color(0xFFE5F5FD),

//             child: Icon(
//               Icons.person,
//               size: 50,
//               color:
//                   Color(0xFFA94327),
//             ),
//           ),

//           const SizedBox(height: 14),

//           Text(
//             displayName,

//             style: TextStyle(
//               color: darkText,
//               fontSize: 22,
//               fontWeight:
//                   FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 5),

//           Text(
//             user?.email ?? '',

//             style:
//                 const TextStyle(
//               color: Colors.grey,
//               fontSize: 13,
//             ),
//           ),

//           const SizedBox(height: 30),

//           SizedBox(
//             width: double.infinity,
//             height: 50,

//             child:
//                 ElevatedButton.icon(
//               onPressed: _logout,

//               icon: const Icon(
//                 Icons.logout,
//                 size: 20,
//               ),

//               label: const Text(
//                 'Logout',

//                 style:
//                     TextStyle(
//                   fontWeight:
//                       FontWeight.w600,
//                 ),
//               ),

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
//                     25,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PLACEHOLDER PAGE
//   // ============================================================

//   Widget _buildPlaceholderPage({
//     required IconData icon,
//     required String title,
//     required String description,
//   }) {
//     return Center(
//       child: Padding(
//         padding:
//             const EdgeInsets.all(30),

//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             Icon(
//               icon,
//               size: 70,
//               color: primaryColor,
//             ),

//             const SizedBox(height: 15),

//             Text(
//               title,

//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 25,
//                 fontWeight:
//                     FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 8),

//             Text(
//               description,

//               textAlign:
//                   TextAlign.center,

//               style:
//                   const TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // LOGOUT
//   // ============================================================

//   Future<void> _logout() async {
//     try {
//       await AuthService().logout();

//       if (!mounted) return;

//       Navigator.pushAndRemoveUntil(
//         context,

//         MaterialPageRoute(
//           builder: (_) =>
//               const LoginScreen(),
//         ),

//         (route) => false,
//       );
//     } catch (e) {
//       if (!mounted) return;

//       _showMessage(
//         'Logout failed: $e',
//       );
//     }
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content:
//             Text(message),

//         behavior:
//             SnackBarBehavior.floating,
//       ),
//     );
//   }
// }















// import 'package:flutter/material.dart';

// import '../services/auth_service.dart';
// import 'login_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color backgroundColor = const Color(0xFFF5FAFD);
//   final Color darkText = const Color(0xFF062B35);

//   final List<Map<String, dynamic>> featuredPets = [
//     {
//       'name': 'Max',
//       'breed': 'Golden Retriever',
//       'age': '2 yrs',
//       'image':
//           'https://images.unsplash.com/photo-1552053831-71594a27632d?w=800',
//       'local': true,
//     },
//     {
//       'name': 'Luna',
//       'breed': 'Domestic Shorthair',
//       'age': '1 yr',
//       'image':
//           'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=800',
//       'local': false,
//     },
//   ];

//   final List<Map<String, String>> recommendedPets = [
//     {
//       'name': 'Charlie',
//       'breed': 'Bulldog',
//       'age': '3 yrs',
//       'image':
//           'https://images.unsplash.com/photo-1558788353-f76d92427f16?w=800',
//     },
//     {
//       'name': 'Milo',
//       'breed': 'Siamese',
//       'age': '2 yrs',
//       'image':
//           'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800',
//     },
//     {
//       'name': 'Daisy',
//       'breed': 'Poodle',
//       'age': '1 yr',
//       'image':
//           'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800',
//     },
//     {
//       'name': 'Oliver',
//       'breed': 'Tabby',
//       'age': '4 mos',
//       'image':
//           'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=800',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,

//       body: SafeArea(
//         child: IndexedStack(
//           index: _selectedIndex,
//           children: [
//             _buildHomePage(),
//             _buildPetsPage(),
//             _buildARPage(),
//             _buildFeedPage(),
//             _buildProfilePage(),
//           ],
//         ),
//       ),

//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   // ============================================================
//   // HOME PAGE
//   // ============================================================

//   Widget _buildHomePage() {
//     final user = AuthService().currentUser;

//     final String displayName =
//         user?.userMetadata?['name']?.toString() ??
//         user?.email?.split('@').first ??
//         'Pet Lover';

//     return CustomScrollView(
//       physics: const BouncingScrollPhysics(),
//       slivers: [
//         // --------------------------------------------------------
//         // TOP APP BAR
//         // --------------------------------------------------------

//         SliverToBoxAdapter(
//           child: Container(
//             height: 68,
//             padding: const EdgeInsets.symmetric(
//               horizontal: 20,
//             ),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               border: Border(
//                 bottom: BorderSide(
//                   color: Color(0xFFE5E5E5),
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 // PROFILE IMAGE
//                 Container(
//                   width: 44,
//                   height: 44,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: const Color(0xFFE5E5E5),
//                     ),
//                     image: const DecorationImage(
//                       image: NetworkImage(
//                         'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
//                       ),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(width: 14),

//                 // APP NAME
//                 Expanded(
//                   child: Text(
//                     'My Future Pet',
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),

//                 // NOTIFICATION
//                 IconButton(
//                   onPressed: () {
//                     _showMessage(
//                       'No new notifications.',
//                     );
//                   },
//                   icon: Icon(
//                     Icons.notifications_none_rounded,
//                     color: darkText,
//                     size: 27,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // --------------------------------------------------------
//         // CONTENT
//         // --------------------------------------------------------

//         SliverPadding(
//           padding: const EdgeInsets.fromLTRB(
//             28,
//             15,
//             28,
//             30,
//           ),
//           sliver: SliverList(
//             delegate: SliverChildListDelegate(
//               [
//                 // HERO BANNER
//                 _buildHeroBanner(),

//                 const SizedBox(height: 34),

//                 // CATEGORIES
//                 _buildSectionTitle(
//                   title: 'Categories',
//                   showSeeAll: false,
//                 ),

//                 const SizedBox(height: 15),

//                 _buildCategories(),

//                 const SizedBox(height: 34),

//                 // FEATURED
//                 _buildSectionTitle(
//                   title: 'Featured Pets',
//                   showSeeAll: true,
//                   onSeeAll: () {
//                     setState(() {
//                       _selectedIndex = 1;
//                     });
//                   },
//                 ),

//                 const SizedBox(height: 14),

//                 _buildFeaturedPets(),

//                 const SizedBox(height: 40),

//                 // RECOMMENDED
//                 _buildSectionTitle(
//                   title: 'Recommended for You',
//                   showSeeAll: false,
//                 ),

//                 const SizedBox(height: 15),

//                 _buildRecommendedPets(),

//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // HERO BANNER
//   // ============================================================

//   Widget _buildHeroBanner() {
//     return Container(
//       width: double.infinity,
//       height: 248,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(25),
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFFC95635),
//             Color(0xFF99644F),
//           ],
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Find your new best\nfriend',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 30,
//               height: 1.15,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 12),

//           const Text(
//             'Discover pets available for adoption near\nyou.',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               height: 1.4,
//             ),
//           ),

//           const Spacer(),

//           ElevatedButton.icon(
//             onPressed: () {
//               _showMessage(
//                 'Pet search coming soon.',
//               );
//             },

//             icon: const Icon(
//               Icons.search,
//               size: 22,
//             ),

//             label: const Text(
//               'Start Search',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),

//             style: ElevatedButton.styleFrom(
//               backgroundColor:
//                   const Color(0xFFAA3F20),
//               foregroundColor: Colors.white,
//               elevation: 0,
//               padding:
//                   const EdgeInsets.symmetric(
//                 horizontal: 22,
//                 vertical: 14,
//               ),
//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(30),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

//   Widget _buildSectionTitle({
//     required String title,
//     required bool showSeeAll,
//     VoidCallback? onSeeAll,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             title,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),

//         if (showSeeAll)
//           GestureDetector(
//             onTap: onSeeAll,
//             child: Text(
//               'See all ›',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   // ============================================================
//   // CATEGORIES
//   // ============================================================

//   Widget _buildCategories() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildCategoryCard(
//             title: 'Dogs',
//             icon: Icons.pets,
//             iconBackground:
//                 const Color(0xFFFFAF62),
//             onTap: () {
//               _showMessage(
//                 'Showing dogs.',
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 14),

//         Expanded(
//           child: _buildCategoryCard(
//             title: 'Cats',
//             icon: Icons.cruelty_free,
//             iconBackground:
//                 const Color(0xFF008F82),
//             onTap: () {
//               _showMessage(
//                 'Showing cats.',
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryCard({
//     required String title,
//     required IconData icon,
//     required Color iconBackground,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 134,
//         decoration: BoxDecoration(
//           color: const Color(0xFFE5F5FD),
//           borderRadius:
//               BorderRadius.circular(17),
//         ),
//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 62,
//               height: 62,
//               decoration: BoxDecoration(
//                 color: iconBackground,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: const Color(0xFF67310F),
//                 size: 35,
//               ),
//             ),

//             const SizedBox(height: 12),

//             Text(
//               title,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 17,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FEATURED PETS
//   // ============================================================

//   Widget _buildFeaturedPets() {
//     return SizedBox(
//       height: 320,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,

//         physics:
//             const BouncingScrollPhysics(),

//         itemCount: featuredPets.length,

//         separatorBuilder:
//             (_, __) =>
//                 const SizedBox(width: 16),

//         itemBuilder: (context, index) {
//           final pet =
//               featuredPets[index];

//           return _buildFeaturedPetCard(
//             pet,
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFeaturedPetCard(
//     Map<String, dynamic> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         _showMessage(
//           'Opening ${pet['name']} profile.',
//         );
//       },

//       child: Container(
//         width: 272,
//         decoration: BoxDecoration(
//           color: Colors.black,
//           borderRadius:
//               BorderRadius.circular(25),
//         ),
//         clipBehavior:
//             Clip.antiAlias,

//         child: Stack(
//           children: [
//             // IMAGE
//             Positioned.fill(
//               child: Image.network(
//                 pet['image'],
//                 fit: BoxFit.cover,

//                 errorBuilder:
//                     (_, __, ___) {
//                   return Container(
//                     color:
//                         const Color(0xFF222222),
//                     child: const Icon(
//                       Icons.pets,
//                       color: Colors.white,
//                       size: 70,
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // DARK GRADIENT
//             Positioned.fill(
//               child: DecoratedBox(
//                 decoration:
//                     BoxDecoration(
//                   gradient:
//                       LinearGradient(
//                     begin:
//                         Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       Colors.black
//                           .withOpacity(0.85),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // FAVORITE BUTTON
//             Positioned(
//               top: 16,
//               right: 16,
//               child: GestureDetector(
//                 onTap: () {
//                   _showMessage(
//                     '${pet['name']} added to favorites.',
//                   );
//                 },
//                 child: Container(
//                   width: 43,
//                   height: 43,
//                   decoration:
//                       BoxDecoration(
//                     color: Colors.white
//                         .withOpacity(0.55),
//                     shape:
//                         BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.favorite_border,
//                     color:
//                         Color(0xFF16414A),
//                     size: 26,
//                   ),
//                 ),
//               ),
//             ),

//             // PET INFORMATION
//             Positioned(
//               left: 16,
//               right: 16,
//               bottom: 14,
//               child: Row(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           pet['name'],
//                           style:
//                               const TextStyle(
//                             color:
//                                 Colors.white,
//                             fontSize: 28,
//                             fontWeight:
//                                 FontWeight.bold,
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 2,
//                         ),

//                         Text(
//                           '${pet['breed']} • ${pet['age']}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style:
//                               const TextStyle(
//                             color:
//                                 Colors.white,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   if (pet['local'] == true)
//                     Container(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration:
//                           BoxDecoration(
//                         color:
//                             const Color(
//                           0xFF008F82,
//                         ),
//                         borderRadius:
//                             BorderRadius.circular(
//                           20,
//                         ),
//                       ),
//                       child: const Text(
//                         'Local',
//                         style:
//                             TextStyle(
//                           color:
//                               Colors.white,
//                           fontSize: 11,
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // RECOMMENDED PETS
//   // ============================================================

//   Widget _buildRecommendedPets() {
//     return GridView.builder(
//       shrinkWrap: true,

//       physics:
//           const NeverScrollableScrollPhysics(),

//       itemCount:
//           recommendedPets.length,

//       gridDelegate:
//           const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 14,
//         mainAxisSpacing: 16,
//         childAspectRatio: 0.76,
//       ),

//       itemBuilder: (context, index) {
//         final pet =
//             recommendedPets[index];

//         return _buildRecommendedPetCard(
//           pet,
//         );
//       },
//     );
//   }

//   Widget _buildRecommendedPetCard(
//     Map<String, String> pet,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         _showMessage(
//           'Opening ${pet['name']} profile.',
//         );
//       },

//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black
//                   .withOpacity(0.05),
//               blurRadius: 6,
//               offset:
//                   const Offset(0, 2),
//             ),
//           ],
//         ),

//         clipBehavior:
//             Clip.antiAlias,

//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,

//           children: [
//             Expanded(
//               child: Image.network(
//                 pet['image']!,
//                 width: double.infinity,
//                 fit: BoxFit.cover,

//                 errorBuilder:
//                     (_, __, ___) {
//                   return Container(
//                     color:
//                         const Color(0xFFE9EEF0),
//                     child: const Center(
//                       child: Icon(
//                         Icons.pets,
//                         size: 50,
//                         color:
//                             Color(0xFFA94327),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             Padding(
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 13,
//                 10,
//                 13,
//                 11,
//               ),

//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,

//                 children: [
//                   Text(
//                     pet['name']!,
//                     style:
//                         TextStyle(
//                       color: darkText,
//                       fontSize: 16,
//                       fontWeight:
//                           FontWeight.w600,
//                     ),
//                   ),

//                   const SizedBox(height: 3),

//                   Text(
//                     '${pet['breed']} • ${pet['age']}',
//                     maxLines: 1,
//                     overflow:
//                         TextOverflow.ellipsis,
//                     style:
//                         const TextStyle(
//                       color:
//                           Color(0xFF6E5D57),
//                       fontSize: 12,
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

//   // ============================================================
//   // BOTTOM NAVIGATION
//   // ============================================================

//   Widget _buildBottomNavigationBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFE2F5FC),
//         boxShadow: [
//           BoxShadow(
//             color:
//                 Colors.black.withOpacity(0.08),
//             blurRadius: 10,
//             offset:
//                 const Offset(0, -2),
//           ),
//         ],
//       ),

//       child: SafeArea(
//         child: Padding(
//           padding:
//               const EdgeInsets.symmetric(
//             horizontal: 8,
//             vertical: 7,
//           ),

//           child: Row(
//             mainAxisAlignment:
//                 MainAxisAlignment.spaceAround,

//             children: [
//               _buildNavItem(
//                 index: 0,
//                 icon: Icons.home_rounded,
//                 label: 'Home',
//               ),

//               _buildNavItem(
//                 index: 1,
//                 icon: Icons.pets,
//                 label: 'Pets',
//               ),

//               _buildNavItem(
//                 index: 2,
//                 icon: Icons.center_focus_strong,
//                 label: 'AR View',
//               ),

//               _buildNavItem(
//                 index: 3,
//                 icon: Icons.people_outline,
//                 label: 'Feed',
//               ),

//               _buildNavItem(
//                 index: 4,
//                 icon: Icons.person_outline,
//                 label: 'Profile',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required int index,
//     required IconData icon,
//     required String label,
//   }) {
//     final bool selected =
//         _selectedIndex == index;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedIndex = index;
//         });
//       },

//       child: AnimatedContainer(
//         duration:
//             const Duration(milliseconds: 200),

//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 7,
//         ),

//         decoration: BoxDecoration(
//           color: selected
//               ? const Color(0xFFFFB15F)
//               : Colors.transparent,
//           borderRadius:
//               BorderRadius.circular(25),
//         ),

//         child: Column(
//           mainAxisSize:
//               MainAxisSize.min,

//           children: [
//             Icon(
//               icon,
//               size: 23,
//               color: selected
//                   ? const Color(0xFF713711)
//                   : const Color(0xFF526069),
//             ),

//             const SizedBox(height: 2),

//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 color: selected
//                     ? const Color(0xFF713711)
//                     : const Color(0xFF526069),
//                 fontWeight: selected
//                     ? FontWeight.w600
//                     : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // OTHER PAGES - TEMPORARY
//   // ============================================================

//   Widget _buildPetsPage() {
//     return _buildPlaceholderPage(
//       icon: Icons.pets,
//       title: 'Pets',
//       description:
//           'Browse pets available for adoption.',
//     );
//   }

//   Widget _buildARPage() {
//     return _buildPlaceholderPage(
//       icon: Icons.center_focus_strong,
//       title: 'AR View',
//       description:
//           'View pets using Augmented Reality.',
//     );
//   }

//   Widget _buildFeedPage() {
//     return _buildPlaceholderPage(
//       icon: Icons.people_outline,
//       title: 'Community Feed',
//       description:
//           'See updates from the pet community.',
//     );
//   }

//   Widget _buildProfilePage() {
//     final user =
//         AuthService().currentUser;

//     return SingleChildScrollView(
//       padding:
//           const EdgeInsets.all(25),

//       child: Column(
//         children: [
//           const SizedBox(height: 30),

//           const CircleAvatar(
//             radius: 50,
//             backgroundColor:
//                 Color(0xFFE5F5FD),
//             child: Icon(
//               Icons.person,
//               size: 55,
//               color: Color(0xFFA94327),
//             ),
//           ),

//           const SizedBox(height: 15),

//           Text(
//             user?.userMetadata?['name']
//                     ?.toString() ??
//                 'Pet Lover',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 23,
//               fontWeight:
//                   FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 5),

//           Text(
//             user?.email ?? '',
//             style: const TextStyle(
//               color: Colors.grey,
//             ),
//           ),

//           const SizedBox(height: 35),

//           SizedBox(
//             width: double.infinity,
//             height: 55,

//             child: ElevatedButton.icon(
//               onPressed: _logout,

//               icon: const Icon(
//                 Icons.logout,
//               ),

//               label: const Text(
//                 'Logout',
//               ),

//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     primaryColor,
//                 foregroundColor:
//                     Colors.white,
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(
//                     30,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlaceholderPage({
//     required IconData icon,
//     required String title,
//     required String description,
//   }) {
//     return Center(
//       child: Padding(
//         padding:
//             const EdgeInsets.all(30),

//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             Icon(
//               icon,
//               size: 80,
//               color: primaryColor,
//             ),

//             const SizedBox(height: 20),

//             Text(
//               title,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 28,
//                 fontWeight:
//                     FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 10),

//             Text(
//               description,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.grey,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // LOGOUT
//   // ============================================================

//   Future<void> _logout() async {
//     try {
//       await AuthService().logout();

//       if (!mounted) return;

//       Navigator.pushAndRemoveUntil(
//         context,

//         MaterialPageRoute(
//           builder: (_) =>
//               const LoginScreen(),
//         ),

//         (route) => false,
//       );
//     } catch (e) {
//       if (!mounted) return;

//       _showMessage(
//         'Logout failed: $e',
//       );
//     }
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior:
//             SnackBarBehavior.floating,
//       ),
//     );
//   }
// }










// import 'package:flutter/material.dart';

// import '../services/auth_service.dart';
// import 'login_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _isLoggingOut = false;

//   // ============================================================
//   // LOGOUT
//   // ============================================================

//   Future<void> _logout() async {
//     // Prevent multiple logout clicks
//     if (_isLoggingOut) return;

//     try {
//       setState(() {
//         _isLoggingOut = true;
//       });

//       // Sign out from Supabase
//       await AuthService().logout();

//       if (!mounted) return;

//       // Remove HomeScreen and go back to LoginScreen
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const LoginScreen(),
//         ),
//         (route) => false,
//       );
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isLoggingOut = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Logout failed: $e',
//           ),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     // Get currently logged-in Supabase user
//     final user = AuthService().currentUser;

//     return Scaffold(
//       // ==========================================================
//       // APP BAR
//       // ==========================================================

//       appBar: AppBar(
//         title: const Text(
//           'My Future Pet',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),

//         backgroundColor: const Color(0xFFA94327),

//         foregroundColor: Colors.white,

//         // ========================================================
//         // LOGOUT BUTTON
//         // ========================================================

//         actions: [
//           IconButton(
//             tooltip: 'Logout',

//             // Disable button while logging out
//             onPressed: _isLoggingOut ? null : _logout,

//             icon: _isLoggingOut
//                 ? const SizedBox(
//                     width: 22,
//                     height: 22,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2.5,
//                       color: Colors.white,
//                     ),
//                   )
//                 : const Icon(
//                     Icons.logout,
//                   ),
//           ),
//         ],
//       ),

//       // ==========================================================
//       // BODY
//       // ==========================================================

//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),

//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,

//             children: [
//               // ==================================================
//               // PET ICON
//               // ==================================================

//               const Icon(
//                 Icons.pets,
//                 size: 80,
//                 color: Color(0xFFA94327),
//               ),

//               const SizedBox(height: 20),

//               // ==================================================
//               // WELCOME
//               // ==================================================

//               const Text(
//                 'Welcome to My Future Pet!',

//                 textAlign: TextAlign.center,

//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 10),

//               // ==================================================
//               // USER EMAIL
//               // ==================================================

//               Text(
//                 user?.email ?? 'No email found',

//                 textAlign: TextAlign.center,

//                 style: const TextStyle(
//                   color: Colors.grey,
//                   fontSize: 16,
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // ==================================================
//               // DASHBOARD MESSAGE
//               // ==================================================

//               const Text(
//                 'Your pet adoption dashboard will go here.',

//                 textAlign: TextAlign.center,

//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.grey,
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // ==================================================
//               // LOGOUT BUTTON
//               // ==================================================
//               //
//               // This is an additional visible logout button.
//               // You can remove this section if you only want
//               // the logout icon in the AppBar.
//               //

//               SizedBox(
//                 width: 220,
//                 height: 50,

//                 child: ElevatedButton.icon(
//                   onPressed:
//                       _isLoggingOut ? null : _logout,

//                   icon: _isLoggingOut
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,

//                           child:
//                               CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Icon(
//                           Icons.logout,
//                         ),

//                   label: Text(
//                     _isLoggingOut
//                         ? 'Logging out...'
//                         : 'Logout',
//                   ),

//                   style:
//                       ElevatedButton.styleFrom(
//                     backgroundColor:
//                         const Color(0xFFA94327),

//                     foregroundColor:
//                         Colors.white,

//                     disabledBackgroundColor:
//                         Colors.grey,

//                     shape:
//                         RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(25),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }









// import 'package:flutter/material.dart';

// import '../services/auth_service.dart';
// import 'login_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user =
//         AuthService().currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'My Future Pet',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),

//         backgroundColor:
//             const Color(0xFFA94327),

//         foregroundColor: Colors.white,

//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),

//             onPressed: () async {
//               await AuthService().logout();

//               if (!context.mounted) return;

//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) =>
//                       const LoginScreen(),
//                 ),
//                 (route) => false,
//               );
//             },
//           ),
//         ],
//       ),

//       body: Center(
//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             const Icon(
//               Icons.pets,
//               size: 80,
//               color: Color(0xFFA94327),
//             ),

//             const SizedBox(height: 20),

//             const Text(
//               'Welcome to My Future Pet!',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 10),

//             Text(
//               user?.email ?? '',
//               style: const TextStyle(
//                 color: Colors.grey,
//               ),
//             ),

//             const SizedBox(height: 30),

//             const Text(
//               'Your pet adoption dashboard will go here.',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }