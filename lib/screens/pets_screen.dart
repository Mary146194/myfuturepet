import 'package:flutter/material.dart';

import '../pet_data.dart';
import '../saved_pet_store.dart';
import '../services/favorites_service.dart';
import '../widgets/app_brand_title.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import 'notifications_screen.dart';
import 'pet_details_screen.dart';

class PetsScreen extends StatefulWidget {
  final String initialCategory;
  final bool autoFocusSearch;
  final VoidCallback? onLogoTap;

  const PetsScreen({
    super.key,
    this.initialCategory = 'All',
    this.autoFocusSearch = false,
    this.onLogoTap,
  });

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFA94327);
  static const Color backgroundColor = Color(0xFFF5FAFD);
  static const Color darkText = Color(0xFF062B35);

  static const Color tealColor = Color(0xFF008F82);
  static const Color pendingColor = Color(0xFFB65C32);

  static const Color lightBlue = Color(0xFFE7F5FA);
  static const Color borderColor = Color(0xFFD8E2E5);
  static const Color secondaryText = Color(0xFF697578);

  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController _searchController =
      TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  // ============================================================
  // CATEGORY
  // ============================================================

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Dogs',
    'Cats',
  ];

  // ============================================================
  // EXTRA FILTERS
  // ============================================================

  String selectedBreed = 'All Breeds';
  String selectedAge = 'Any Age';
  String selectedGender = 'Any Gender';
  String selectedStatus = 'All Status';

  // ============================================================
  // FAVORITES / LIKES
  // ============================================================

  final Set<String> _likedPets = {};

  // ============================================================
  // PET DATA
  // ============================================================
  List<Map<String, dynamic>> get pets => PetData.pets;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    selectedCategory = widget.initialCategory;

    // Sync live pets from Supabase database and sync favorites
    FavoritesService().init().then((_) {
      SavedPetStore.syncWithFavorites(PetData.pets);
      if (mounted) setState(() {});
    });

    PetData.syncWithSupabase().then((_) {
      SavedPetStore.syncWithFavorites(PetData.pets);
      if (mounted) setState(() {});
    });

    if (widget.autoFocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }
  }
@override
void dispose() {
  _searchController.dispose();
  _searchFocusNode.dispose();
  super.dispose();
}

  Future<void> _refreshPets() async {
    await Future.wait([
      PetData.syncWithSupabase(),
      FavoritesService().init(),
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
    final bgCol = isDark ? const Color(0xFF0F172A) : backgroundColor;

    return Scaffold(
      backgroundColor: bgCol,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return RefreshIndicator(
                    color: primaryColor,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    onRefresh: _refreshPets,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        14,
                        16,
                        28,
                      ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildPageTitle(),

                          const SizedBox(height: 14),

                          _buildSearchBar(),

                          const SizedBox(height: 12),

                          _buildCategoryFilter(),

                          const SizedBox(height: 14),

                          _buildFilterButtons(),

                          const SizedBox(height: 18),

                          _buildResultsLabel(),

                          const SizedBox(height: 10),

                          _buildPetList(),
                        ],
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
    );
  }

  // ============================================================
  // PAGE TITLE
  // ============================================================

  Widget _buildPageTitle() {
    final isDark = ThemeService.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Your Future Pet',
          style: TextStyle(
            color: isDark ? const Color(0xFFF8FAFC) : darkText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Meet pets looking for a loving home.',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : secondaryText,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final isDark = ThemeService.isDarkMode(context);

    return Container(
      width: double.infinity,
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8EA),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // APP LOGO + NAME
          AppBrandTitle(onTap: widget.onLogoTap),

          const Spacer(),

          // NOTIFICATION
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
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    final isDark = ThemeService.isDarkMode(context);

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE1E8EA),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (_) {
          setState(() {});
        },
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: isDark ? const Color(0xFFF8FAFC) : darkText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search by name or breed',
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF92999B),
            fontSize: 12,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 19,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF7C8588),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 45,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY FILTER
  // ============================================================

  Widget _buildCategoryFilter() {
    final isDark = ThemeService.isDarkMode(context);

    return Row(
      children: categories.map((category) {
        final bool selected =
            selectedCategory == category;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 180),
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? primaryColor
                      : (isDark ? const Color(0xFF1E293B) : lightBlue),
                  borderRadius:
                      BorderRadius.circular(16),
                  border: isDark && !selected
                      ? Border.all(
                          color: const Color(0xFF334155),
                          width: 1,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : (isDark ? const Color(0xFF94A3B8) : darkText),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // FILTER BUTTONS
  // ============================================================

  Widget _buildFilterButtons() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics:
            const BouncingScrollPhysics(),
        children: [
          _buildSmallFilter(
            label: selectedBreed == 'All Breeds'
                ? 'Breed'
                : selectedBreed,
            active:
                selectedBreed != 'All Breeds',
            onTap: () {
              _showFilterDialog(
                title: 'Breed',
                currentValue: selectedBreed,
                options: const [
                  'All Breeds',
                  'Golden Retriever',
                  'Domestic Longhair',
                  'Terrier Mix',
                  'Calico',
                ],
                onSelected: (value) {
                  setState(() {
                    selectedBreed = value;
                  });
                },
              );
            },
          ),

          const SizedBox(width: 8),

          _buildSmallFilter(
            label: selectedAge == 'Any Age'
                ? 'Age'
                : selectedAge,
            active:
                selectedAge != 'Any Age',
            onTap: () {
              _showFilterDialog(
                title: 'Age',
                currentValue: selectedAge,
                options: const [
                  'Any Age',
                  'Under 1 year',
                  '1 - 3 years',
                  '4+ years',
                ],
                onSelected: (value) {
                  setState(() {
                    selectedAge = value;
                  });
                },
              );
            },
          ),

          const SizedBox(width: 8),

          _buildSmallFilter(
            label: selectedGender == 'Any Gender'
                ? 'Gender'
                : selectedGender,
            active:
                selectedGender != 'Any Gender',
            onTap: () {
              _showFilterDialog(
                title: 'Gender',
                currentValue: selectedGender,
                options: const [
                  'Any Gender',
                  'Male',
                  'Female',
                ],
                onSelected: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              );
            },
          ),

          const SizedBox(width: 8),

          _buildSmallFilter(
            label: selectedStatus == 'All Status'
                ? 'Status'
                : selectedStatus,
            active:
                selectedStatus != 'All Status',
            onTap: () {
              _showFilterDialog(
                title: 'Status',
                currentValue: selectedStatus,
                options: const [
                  'All Status',
                  'Available',
                  'Pending',
                ],
                onSelected: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              );
            },
          ),

          const SizedBox(width: 8),

          _buildClearFilterButton(),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL FILTER
  // ============================================================

  Widget _buildSmallFilter({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final isDark = ThemeService.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
        ),
        decoration: BoxDecoration(
          color: active
              ? (isDark
                  ? const Color(0xFFA94327).withValues(alpha: 0.25)
                  : const Color(0xFFFFEEE8))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? primaryColor
                : (isDark ? const Color(0xFF334155) : borderColor),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active
                    ? (isDark ? const Color(0xFFFF8A65) : primaryColor)
                    : (isDark ? const Color(0xFFF8FAFC) : darkText),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color: active
                  ? (isDark ? const Color(0xFFFF8A65) : primaryColor)
                  : (isDark ? const Color(0xFF94A3B8) : secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CLEAR FILTER BUTTON
  // ============================================================

  Widget _buildClearFilterButton() {
    final bool hasFilter =
        selectedBreed != 'All Breeds' ||
        selectedAge != 'Any Age' ||
        selectedGender != 'Any Gender' ||
        selectedStatus != 'All Status';

    if (!hasFilter) {
      return const SizedBox.shrink();
    }

    final isDark = ThemeService.isDarkMode(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBreed = 'All Breeds';
          selectedAge = 'Any Age';
          selectedGender = 'Any Gender';
          selectedStatus = 'All Status';
        });
      },
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF3F4),
          borderRadius:
              BorderRadius.circular(10),
          border: isDark
              ? Border.all(
                  color: const Color(0xFF334155),
                  width: 1,
                )
              : null,
        ),
        child: Text(
          'Clear',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RESULTS LABEL
  // ============================================================

  Widget _buildResultsLabel() {
    final List<Map<String, dynamic>> filtered =
        _getFilteredPets();
    final isDark = ThemeService.isDarkMode(context);

    return Row(
      children: [
        Text(
          '${filtered.length} ${filtered.length == 1 ? 'pet' : 'pets'} found',
          style: TextStyle(
            color: isDark ? const Color(0xFFF8FAFC) : darkText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.tune_rounded,
          size: 15,
          color: isDark ? const Color(0xFF94A3B8) : secondaryText,
        ),
      ],
    );
  }

  // ============================================================
  // FILTERED PETS
  // ============================================================

  List<Map<String, dynamic>> _getFilteredPets() {
    final String searchText =
        _searchController.text
            .trim()
            .toLowerCase();

    return pets.where((pet) {
      final bool categoryMatch =
          selectedCategory == 'All' ||
              pet['category'] ==
                  selectedCategory;

      final bool searchMatch =
          searchText.isEmpty ||
              pet['name']
                  .toString()
                  .toLowerCase()
                  .contains(searchText) ||
              pet['breed']
                  .toString()
                  .toLowerCase()
                  .contains(searchText);

      final bool breedMatch =
          selectedBreed == 'All Breeds' ||
              pet['breed'] ==
                  selectedBreed;

      final bool ageMatch =
          _matchesAge(
        pet['age'].toString(),
      );

      final bool genderMatch =
          selectedGender == 'Any Gender' ||
              pet['gender'] ==
                  selectedGender;

      final bool statusMatch =
          selectedStatus == 'All Status' ||
              pet['status'] ==
                  selectedStatus;

      return categoryMatch &&
          searchMatch &&
          breedMatch &&
          ageMatch &&
          genderMatch &&
          statusMatch;
    }).toList();
  }

  // ============================================================
  // AGE MATCH
  // ============================================================

  bool _matchesAge(String age) {
    if (selectedAge == 'Any Age') {
      return true;
    }

    final String numberOnly =
        age.replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );

    final double petAge =
        double.tryParse(numberOnly) ?? 0;

    switch (selectedAge) {
      case 'Under 1 year':
        return petAge < 1;

      case '1 - 3 years':
        return petAge >= 1 &&
            petAge <= 3;

      case '4+ years':
        return petAge >= 4;

      default:
        return true;
    }
  }

  // ============================================================
  // PET LIST
  // ============================================================

  Widget _buildPetList() {
    final List<Map<String, dynamic>> filteredPets =
        _getFilteredPets();

    if (filteredPets.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: filteredPets.map((pet) {
        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 16,
          ),
          child: _buildPetCard(pet),
        );
      }).toList(),
    );
  }

  // ============================================================
  // PET CARD
  // ============================================================

  Widget _buildPetCard(
    Map<String, dynamic> pet,
  ) {
    final isDark = ThemeService.isDarkMode(context);
    final bool isAvailable =
        pet['status'] == 'Available';

    final String petName =
        pet['name'].toString();
    final String petId =
        pet['id']?.toString() ?? petName;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PetDetailsScreen(
              pet: pet,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFDCE7EA),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.035),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ==================================================
            // IMAGE
            // ==================================================

            AspectRatio(
              aspectRatio: 1.35,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    pet['image'].toString(),
                    fit: BoxFit.cover,
                    alignment:
                        Alignment.center,
                    loadingBuilder:
                        (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE9EEF0),
                        child: const Center(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        color:
                            const Color(
                          0xFFE9EEF0,
                        ),
                        child: Icon(
                          pet['category'] ==
                                  'Dogs'
                              ? Icons.pets
                              : Icons
                                  .cruelty_free,
                          color:
                              primaryColor,
                          size: 52,
                        ),
                      );
                    },
                  ),

                  // ==================================================
                  // GRADIENT
                  // ==================================================

                  Positioned.fill(
                    child: DecoratedBox(
                      decoration:
                          BoxDecoration(
                        gradient:
                            LinearGradient(
                          begin: Alignment
                              .topCenter,
                          end: Alignment
                              .bottomCenter,
                          stops: const [
                            0.35,
                            1.0,
                          ],
                          colors: [
                            Colors
                                .transparent,
                            Colors.black
                                .withValues(
                              alpha: 0.78,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // STATUS
                  // ==================================================

                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color: isAvailable
                            ? tealColor
                            : pendingColor,
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),
                      child: Text(
                        pet['status']
                            .toString()
                            .toUpperCase(),
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 8,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing:
                              0.3,
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // FAVORITE / LIKE BUTTON
                  // ==================================================

                  Positioned(
                    right: 11,
                    bottom: 12,
                    child: ValueListenableBuilder<int>(
                      valueListenable: SavedPetStore.changeNotifier,
                      builder: (context, value, child) {
                        final bool isLiked = SavedPetStore.isSaved(petName) ||
                            SavedPetStore.isSaved(petId) ||
                            _likedPets.contains(petName);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                final int currentLikes =
                                    int.tryParse(
                                          pet['likes'].toString(),
                                        ) ??
                                        0;

                                final bool wasLiked =
                                    SavedPetStore.isSaved(petName) ||
                                        SavedPetStore.isSaved(petId) ||
                                        _likedPets.contains(petName);

                                SavedPetStore.togglePet(pet);

                                if (wasLiked) {
                                  _likedPets.remove(petName);
                                  pet['likes'] =
                                      currentLikes > 0 ? currentLikes - 1 : 0;
                                } else {
                                  _likedPets.add(petName);
                                  pet['likes'] = currentLikes + 1;
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A).withValues(alpha: 0.85)
                                    : Colors.white.withValues(alpha: 0.93),
                                borderRadius: BorderRadius.circular(16),
                                border: isDark
                                    ? Border.all(
                                        color: const Color(0xFF334155),
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isLiked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 18,
                                    color: isLiked
                                        ? primaryColor
                                        : (isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF667477)),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${pet['likes'] ?? 0}',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFF8FAFC)
                                          : const Color(0xFF45575B),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ==================================================
                  // PET INFORMATION
                  // ==================================================

                  Positioned(
                    left: 14,
                    right: 90,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        // PET NAME
                        Text(
                          pet['name']
                              .toString(),
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        // BREED + AGE
                        Text(
                          '${pet['breed']} • ${pet['age']}',
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w400,
                          ),
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        // ==================================================
                        // BEHAVIOR + PERSONALITY
                        // ==================================================

                        Row(
                          children: [
                            // BEHAVIOR
                            Flexible(
                              child:
                                  Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .white
                                      .withValues(
                                    alpha: 0.18,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                  border:
                                      Border.all(
                                    color: Colors
                                        .white
                                        .withValues(
                                      alpha: 0.30,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize
                                          .min,
                                  children: [
                                    const Icon(
                                      Icons
                                          .bolt_rounded,
                                      color:
                                          Colors.white,
                                      size: 11,
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Flexible(
                                      child:
                                          Text(
                                        pet['behavior']
                                                ?.toString() ??
                                            'Active',
                                        maxLines:
                                            1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize:
                                              8,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // PERSONALITY (only when the shelter wrote one)
                            if ((pet['personalityShort'] ?? '')
                                .toString()
                                .isNotEmpty) ...[
                            const SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child:
                                  Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .white
                                      .withValues(
                                    alpha: 0.18,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                  border:
                                      Border.all(
                                    color: Colors
                                        .white
                                        .withValues(
                                      alpha: 0.30,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize
                                          .min,
                                  children: [
                                    const Icon(
                                      Icons
                                          .favorite_border_rounded,
                                      color:
                                          Colors.white,
                                      size: 10,
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Flexible(
                                      child:
                                          Text(
                                        pet['personalityShort'].toString(),
                                        maxLines:
                                            1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize:
                                              8,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // TAGS
            // ==================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.fromLTRB(
                11,
                8,
                11,
                10,
              ),
              child: SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,
                physics:
                    const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    if (pet['vaccinated'] ==
                        true)
                      _buildPetTag(
                        icon: Icons
                            .vaccines_rounded,
                        text: 'Vaccinated',
                      ),

                    if (pet['vaccinated'] ==
                            true &&
                        (pet['kidFriendly'] ==
                                true ||
                            pet['energy'] !=
                                null))
                      const SizedBox(
                        width: 6,
                      ),

                    if (pet['kidFriendly'] ==
                        true)
                      _buildPetTag(
                        icon: Icons
                            .child_friendly_rounded,
                        text: 'Good w/ Kids',
                      ),

                    if (pet['kidFriendly'] ==
                            true &&
                        pet['energy'] !=
                            null)
                      const SizedBox(
                        width: 6,
                      ),

                    if (pet['energy'] !=
                        null)
                      _buildPetTag(
                        icon:
                            Icons.bolt_rounded,
                        text:
                            pet['energy']
                                .toString(),
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
  // PET TAG
  // ============================================================

  Widget _buildPetTag({
    required IconData icon,
    required String text,
  }) {
    final isDark = ThemeService.isDarkMode(context);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF008F82).withValues(alpha: 0.18)
            : const Color(0xFFE9F7F6),
        borderRadius:
            BorderRadius.circular(13),
        border: isDark
            ? Border.all(
                color: const Color(0xFF008F82).withValues(alpha: 0.35),
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: isDark ? const Color(0xFF2DD4BF) : tealColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isDark
                  ? const Color(0xFF2DD4BF)
                  : const Color(0xFF34706C),
              fontSize: 8,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final isDark = ThemeService.isDarkMode(context);

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 55,
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE7F5FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 34,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'No pets found',
            style: TextStyle(
              color: isDark ? const Color(0xFFF8FAFC) : darkText,
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Try another search or change your filters.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : secondaryText,
              fontSize: 12,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton(
            onPressed:
                _clearAllFilters,
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  primaryColor,
              side:
                  const BorderSide(
                color: primaryColor,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 18,
                vertical: 10,
              ),
            ),
            child: const Text(
              'Clear Filters',
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER BOTTOM SHEET
  // ============================================================

  void _showFilterDialog({
    required String title,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String>
        onSelected,
  }) {
    final isDark = ThemeService.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                18,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // HANDLE
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFFD5DDDF),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  Text(
                    'Filter by $title',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFF8FAFC) : darkText,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    'Choose an option below.',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : secondaryText,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  ...options.map(
                    (option) {
                      final bool selected =
                          option ==
                              currentValue;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            sheetContext,
                          );

                          onSelected(
                            option,
                          );
                        },
                        child: Container(
                          width:
                              double.infinity,
                          margin:
                              const EdgeInsets
                                  .only(
                            bottom: 7,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 13,
                            vertical: 13,
                          ),
                          decoration:
                              BoxDecoration(
                            color: selected
                                ? (isDark
                                    ? const Color(0xFFA94327).withValues(alpha: 0.25)
                                    : const Color(0xFFFFEEE8))
                                : (isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF7FAFB)),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              11,
                            ),
                            border:
                                Border.all(
                              color: selected
                                  ? primaryColor
                                  : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE4EAEC)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style:
                                      TextStyle(
                                    color:
                                        selected
                                            ? (isDark
                                                ? const Color(0xFFFF8A65)
                                                : primaryColor)
                                            : (isDark
                                                ? const Color(0xFFF8FAFC)
                                                : darkText),
                                    fontSize:
                                        13,
                                    fontWeight:
                                        selected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                  ),
                                ),
                              ),

                              if (selected)
                                Icon(
                                  Icons
                                      .check_circle_rounded,
                                  color: isDark
                                      ? const Color(0xFFFF8A65)
                                      : primaryColor,
                                  size: 19,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CLEAR ALL FILTERS
  // ============================================================

  void _clearAllFilters() {
    setState(() {
      selectedCategory = 'All';
      selectedBreed = 'All Breeds';
      selectedAge = 'Any Age';
      selectedGender = 'Any Gender';
      selectedStatus = 'All Status';
      _searchController.clear();
    });
  }


}
