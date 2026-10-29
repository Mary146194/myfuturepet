import 'package:flutter/material.dart';

import '../pet_data.dart';
import '../services/pet_service.dart';
import '../saved_pet_store.dart';
import 'pets_screen.dart';
import 'ar_view_screen.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'pet_details_screen.dart';
import '../services/notification_service.dart';
import '../services/favorites_service.dart';
import '../services/theme_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    NotificationService().init();
    FavoritesService().init().then((_) {
      SavedPetStore.syncWithFavorites(PetData.pets);
    });
    PetData.syncWithSupabase().then((_) {
      SavedPetStore.syncWithFavorites(PetData.pets);
    });
  }

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

  void _openPets({String category = 'All', bool search = false}) {
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
    final isDark = ThemeService.isDarkMode(context);
    final bgCol = isDark ? const Color(0xFF0F172A) : backgroundColor;

    return Scaffold(
      backgroundColor: bgCol,

      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeContentScreen(
              onOpenPets: ({String category = 'All', bool search = false}) {
                _openPets(category: category, search: search);
              },
            ),

            PetsScreen(
              key: ValueKey('$_petsCategory-$_openSearch'),
              initialCategory: _petsCategory,
              autoFocusSearch: _openSearch,
            ),

            if (_selectedIndex == 2)
              ARViewScreen(
                onBack: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              )
            else
              const SizedBox.shrink(),

            const FeedScreen(),

            ProfileScreen(
              onBrowsePets: () {
                _openPets(category: 'All', search: false);
              },
            ),
          ],
        ),
      ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================
      bottomNavigationBar: _buildBottomNavigation(isDark),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2F5FC),
        border: isDark
            ? const Border(top: BorderSide(color: Color(0xFF334155), width: 1))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
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
              isDark: isDark,
            ),

            _navItem(index: 1, icon: Icons.pets, label: 'Pets', isDark: isDark),

            _navItem(
              index: 2,
              icon: Icons.center_focus_strong,
              label: 'AR View',
              isDark: isDark,
            ),

            _navItem(
              index: 3,
              icon: Icons.people_outline,
              label: 'Feed',
              isDark: isDark,
            ),

            _navItem(
              index: 4,
              icon: Icons.person_outline,
              label: 'Profile',
              isDark: isDark,
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
    required bool isDark,
  }) {
    final bool selected = _selectedIndex == index;

    final selectedBg = isDark
        ? const Color(0xFFA94327)
        : const Color(0xFFFFB15F);
    final selectedFg = isDark ? Colors.white : const Color(0xFF713711);
    final unselectedFg = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF526069);

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
        duration: const Duration(milliseconds: 180),

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

        decoration: BoxDecoration(
          color: selected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(icon, size: 20, color: selected ? selectedFg : unselectedFg),

            Text(
              label,

              style: TextStyle(
                fontSize: 8,
                color: selected ? selectedFg : unselectedFg,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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

class HomeContentScreen extends StatefulWidget {
  final Function({String category, bool search}) onOpenPets;

  const HomeContentScreen({super.key, required this.onOpenPets});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  final _homePets = ValueNotifier<List<Map<String, dynamic>>>([]);
  bool _loadingPets = true;
  bool _petLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadHomePets();
  }

  @override
  void dispose() {
    _homePets.dispose();
    super.dispose();
  }

  Future<void> _loadHomePets() async {
    setState(() {
      _loadingPets = true;
      _petLoadFailed = false;
    });
    try {
      final pets = await PetService().fetchPets(
        status: 'available',
        throwOnError: true,
      );
      if (!mounted) return;
      _homePets.value = pets;
    } catch (_) {
      if (!mounted) return;
      _petLoadFailed = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load pets. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _loadingPets = false);
    }
  }

  Widget? _petFeedState() {
    if (_loadingPets) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_petLoadFailed) {
      return Column(
        children: [
          const Text('Unable to load pets. Please check your connection.'),
          TextButton(onPressed: _loadHomePets, child: const Text('Retry')),
        ],
      );
    }
    return null;
  }

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFA94327);

  static const Color darkText = Color(0xFF062B35);

  Future<void> _refresh() async {
    await Future.wait([
      _loadHomePets(),
      PetData.syncWithSupabase(),
      FavoritesService().init(),
      NotificationService().refreshUnreadCount(),
    ]);
    SavedPetStore.syncWithFavorites(PetData.pets);
    if (mounted) setState(() {});
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode(context);

    return Column(
      children: [
        _buildHeader(context),

        Expanded(
          child: RefreshIndicator(
            color: primaryColor,
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),

              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _buildHero(),

                  const SizedBox(height: 16),

                  _sectionTitle(context, 'Categories'),

                  const SizedBox(height: 8),

                  _buildCategories(context),

                  const SizedBox(height: 18),

                  _sectionTitle(
                    context,
                    'Featured Pets',
                    seeAll: true,
                    onSeeAll: () {
                      widget.onOpenPets(category: 'All', search: false);
                    },
                  ),

                  const SizedBox(height: 8),

                  _buildFeaturedPets(),
                ],
              ),
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
    final isDark = ThemeService.isDarkMode(context);

    return Container(
      height: 58,

      padding: const EdgeInsets.symmetric(horizontal: 10),

      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,

        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E5E5),
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8EA),
                width: 1,
              ),
              image: const DecorationImage(
                image: AssetImage('assets/images/app_launcher_icon.png'),
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

          ValueListenableBuilder<int>(
            valueListenable: NotificationService().unreadCountNotifier,
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
                      color: isDark
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFF062B35),
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
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      height: 220,

      padding: const EdgeInsets.fromLTRB(25, 27, 25, 25),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [Color(0xFFC95635), Color(0xFF99644F)],
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

            style: TextStyle(color: Colors.white, fontSize: 13),
          ),

          const Spacer(),

          SizedBox(
            height: 48,

            child: ElevatedButton.icon(
              onPressed: () {
                widget.onOpenPets(category: 'All', search: true);
              },

              icon: const Icon(Icons.search_rounded),

              label: const Text('Start Search'),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAA3F20),
                foregroundColor: Colors.white,
                elevation: 0,

                padding: const EdgeInsets.symmetric(horizontal: 30),

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
    BuildContext context,
    String title, {
    bool seeAll = false,
    VoidCallback? onSeeAll,
  }) {
    final isDark = ThemeService.isDarkMode(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F2830),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        if (seeAll)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See all ›',
              style: TextStyle(
                color: primaryColor,
                fontSize: 13,
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

  Widget _buildCategories(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _categoryCard(
            context,
            title: 'Dogs',
            icon: Icons.pets,

            iconBackground: const Color(0xFFFFAF62),

            onTap: () {
              widget.onOpenPets(category: 'Dogs', search: false);
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _categoryCard(
            context,
            title: 'Cats',
            icon: Icons.cruelty_free,

            iconBackground: const Color(0xFF008F82),

            onTap: () {
              widget.onOpenPets(category: 'Cats', search: false);
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _categoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    final isDark = ThemeService.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 100,

        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5F5FD),
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
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

              child: Icon(icon, color: const Color(0xFF67310F), size: 25),
            ),

            const SizedBox(width: 10),

            Text(
              title,

              style: TextStyle(
                color: isDark ? const Color(0xFFF8FAFC) : darkText,
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
    final state = _petFeedState();
    if (state != null) return state;
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _homePets,
      builder: (context, livePets, child) {
        final isDark = ThemeService.isDarkMode(context);
        final pets = livePets
            .where(
              (p) =>
                  (p['status'] ?? '').toString().toLowerCase() == 'available',
            )
            .take(5)
            .toList();

        if (pets.isEmpty) {
          return Container(
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              'No pets currently available for adoption',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          );
        }

        return SizedBox(
          height: 236,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: pets.length,
            separatorBuilder: (_, unused) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _featuredCard(context, pets[index], index);
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // CARD HELPERS (MATCHING IMAGE 2 DESIGN)
  // ============================================================

  bool _isFemale(Map<String, dynamic> pet) {
    final gender = (pet['gender'] ?? '').toString().toLowerCase();
    return gender.startsWith('f') || gender.contains('female');
  }

  Widget _buildFavoriteButton(Map<String, dynamic> pet) {
    final petName = pet['name']?.toString() ?? '';

    return ValueListenableBuilder<int>(
      valueListenable: SavedPetStore.changeNotifier,
      builder: (context, _, unused) {
        final isSaved = SavedPetStore.isSaved(petName);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              SavedPetStore.togglePet(pet);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 5,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: Icon(
                isSaved
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isSaved
                    ? const Color(0xFFE53935)
                    : const Color(0xFF4A5568),
                size: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // FEATURED CARD (MATCHING IMAGE 2)
  // ============================================================

  Widget _featuredCard(
    BuildContext context,
    Map<String, dynamic> pet,
    int index,
  ) {
    final isFemale = _isFemale(pet);
    final isDark = ThemeService.isDarkMode(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PetDetailsScreen(pet: pet)),
        );
      },
      child: Container(
        width: 182,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                pet['image'].toString(),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    child: Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    child: const Center(
                      child: Icon(Icons.pets, color: primaryColor, size: 45),
                    ),
                  );
                },
              ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.40, 0.70, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.12),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.60),
                      Colors.black.withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(top: 10, right: 10, child: _buildFavoriteButton(pet)),

            // Bottom Content
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pet Name & Gender/Age Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          pet['name'].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.68),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${isFemale ? '♀' : '♂'} ${pet['age'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Breed
                  Text(
                    '${pet['type'] == 'cat' ? 'Cat' : 'Dog'} • ${pet['breed'] ?? 'Unknown Breed'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 7),

                  // Action Row: Available Pill + Meet Me Button
                  Row(
                    children: [
                      // Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF2DD4BF),
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              (pet['status'] ?? 'Available').toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Meet Me Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PetDetailsScreen(pet: pet),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF009688),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF009688,
                                ).withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Meet Me',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
