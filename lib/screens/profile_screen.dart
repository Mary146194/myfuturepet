import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'my_applications_screen.dart';
import '../adoption_application_store.dart';
import '../adoption_journey.dart';
import '../services/adoption_journey_service.dart';
import '../widgets/adoption_history_tile.dart';
import '../widgets/adoption_journey_tracker.dart';
import 'success_story_composer.dart';
import 'visit_appointment_screen.dart';

import 'my_appointments_screen.dart';
import '../appointment_store.dart';

import 'saved_pets_screen.dart';
import '../saved_pet_store.dart';
import '../pet_data.dart';
import '../services/favorites_service.dart';

import 'login_screen.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';
import 'app_settings_screen.dart';
import 'help_support_screen.dart';
import 'how_to_use_screen.dart';
import '../services/theme_service.dart';
import '../widgets/app_brand_title.dart';

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBrowsePets;
  final VoidCallback? onLogoTap;

  const ProfileScreen({
    super.key,
    this.onBrowsePets,
    this.onLogoTap,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  final Color primaryColor = const Color(0xFFA94327);
  final Color darkText = const Color(0xFF062B35);
  final Color tealColor = const Color(0xFF008F82);
  final Color detailBlue = const Color(0xFFEFF9FD);
  final Color lightBlue = const Color(0xFFE4F5FB);

  // ============================================================
  // PROFILE DATA
  // ============================================================

  String userName = 'Loading...';
  String userRole = 'Aspiring Pet Parent';
  String profileImage = '';
  bool isLoadingProfile = true;

  /// Application shown on the Progress Road when several are in flight.
  String? _selectedJourneyId;

  // ============================================================
  // SUPABASE CLIENT
  // ============================================================

  final SupabaseClient supabase = Supabase.instance.client;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    FavoritesService().init().then((_) {
      SavedPetStore.syncWithFavorites(PetData.pets);
      if (mounted) setState(() {});
    });

    AdoptionApplicationStore.syncWithSupabase().then((_) {
      if (mounted) setState(() {});
    });

    AppointmentStore.syncWithSupabase().then((_) {
      if (mounted) setState(() {});
    });

    AdoptionJourneyService().init();

    _loadUserProfile();
  }

  // ============================================================
  // LOAD CURRENT LOGGED-IN USER
  // ============================================================

  Future<void> _loadUserProfile() async {
    try {
      final User? user = supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;
        setState(() {
          userName = 'User';
          isLoadingProfile = false;
        });
        return;
      }

      String loadedName = user.userMetadata?['full_name']?.toString().trim() ?? '';
      String loadedRole = user.userMetadata?['role']?.toString().trim() ?? '';
      String loadedImage = user.userMetadata?['avatar_url']?.toString().trim() ?? '';

      if (loadedName.isEmpty) {
        loadedName = user.userMetadata?['name']?.toString().trim() ?? '';
      }

      if (loadedName.isEmpty) {
        loadedName = user.email?.split('@').first ?? 'User';
      }

      try {
        final profile = await supabase
            .from('profiles')
            .select('full_name, role')
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null) {
          final String databaseName = profile['full_name']?.toString().trim() ?? '';
          final String databaseRole = profile['role']?.toString().trim() ?? '';

          if (databaseName.isNotEmpty) loadedName = databaseName;
          if (databaseRole.isNotEmpty) loadedRole = databaseRole;
        }
      } catch (_) {}

      if (loadedRole.isEmpty) {
        loadedRole = 'Aspiring Pet Parent';
      }

      if (loadedImage.contains('pravatar')) {
        loadedImage = '';
      }

      if (!mounted) return;

      setState(() {
        userName = loadedName;
        userRole = loadedRole;
        profileImage = loadedImage;
        isLoadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;

      final User? user = supabase.auth.currentUser;
      String fallbackName = 'User';

      if (user != null) {
        fallbackName = user.userMetadata?['full_name']?.toString().trim() ?? '';
        if (fallbackName.isEmpty) {
          fallbackName = user.userMetadata?['name']?.toString().trim() ?? '';
        }
        if (fallbackName.isEmpty) {
          fallbackName = user.email?.split('@').first ?? 'User';
        }
      }

      setState(() {
        userName = fallbackName;
        isLoadingProfile = false;
      });
    }
  }

  Future<void> _refreshProfile() async {
    await Future.wait([
      _loadUserProfile(),
      FavoritesService().init(),
      NotificationService().refreshUnreadCount(),
      AdoptionApplicationStore.syncWithSupabase(),
      AppointmentStore.syncWithSupabase(),
      AdoptionJourneyService().refresh(),
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
    final bgCol = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5FAFD);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF062B35);
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final headerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF9FD);
    final activityCardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF9FD);

    return Scaffold(
      backgroundColor: bgCol,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // TOP HEADER
            // ==================================================
            Container(
              color: headerBg,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  AppBrandTitle(onTap: widget.onLogoTap),
                  const Spacer(),
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
                              color: textCol,
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
            ),

            // ==================================================
            // PROFILE CONTENT
            // ==================================================
            Expanded(
              child: Container(
                color: bgCol,
                child: RefreshIndicator(
                  color: primaryColor,
                  backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  onRefresh: _refreshProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Card
                      _buildProfileCard(isDark, cardBg, borderCol, textCol, subTextCol),

                      const SizedBox(height: 24),

                      _buildAdoptionJourney(isDark),

                      // My Activity
                      _buildSectionTitle('My Activity'),

                      const SizedBox(height: 12),

                      // My Applications (status word follows the journey)
                      ValueListenableBuilder<List<AdoptionJourney>>(
                        valueListenable: AdoptionJourneyService().journeys,
                        builder: (context, journeys, _) {
                          // Count only applications still in progress; once
                          // all are done the pill shows the latest outcome.
                          final active = journeys
                              .where((j) => j.isActive)
                              .toList();
                          final pool = active.isNotEmpty ? active : journeys;
                          final latest = pool.isEmpty
                              ? null
                              : pool.reduce(
                                  (a, b) =>
                                      (b.submittedAt ?? DateTime(0)).isAfter(
                                        a.submittedAt ?? DateTime(0),
                                      )
                                      ? b
                                      : a,
                                );
                          final activeCount = journeys.isEmpty
                              ? AdoptionApplicationStore.activeCount
                              : active.length;
                          return _buildActivityCard(
                            icon: Icons.description_outlined,
                            iconColor: const Color(0xFFA94327),
                            title: 'My Applications',
                            count: activeCount,
                            countLabel: 'application',
                            status:
                                latest?.statusLabel ??
                                (AdoptionApplicationStore.hasApplication &&
                                        activeCount == 0
                                    ? 'Done'
                                    : AdoptionApplicationStore.latestStatus),
                            isDark: isDark,
                            activityCardBg: activityCardBg,
                            borderCol: borderCol,
                            textCol: textCol,
                            onTap: _openMyApplications,
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // Saved Pets
                      ValueListenableBuilder<int>(
                        valueListenable: SavedPetStore.changeNotifier,
                        builder: (context, value, child) {
                          return _buildActivityCard(
                            icon: Icons.favorite_border,
                            iconColor: primaryColor,
                            title: 'Saved Pets',
                            count: SavedPetStore.savedCount,
                            countLabel: 'saved pet',
                            isDark: isDark,
                            activityCardBg: activityCardBg,
                            borderCol: borderCol,
                            textCol: textCol,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SavedPetsScreen(
                                    onBrowsePets: widget.onBrowsePets,
                                  ),
                                ),
                              );
                              setState(() {});
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // My Appointments: count upcoming only; "Done" once
                      // every appointment is completed or cancelled.
                      ValueListenableBuilder<List<AdoptionJourney>>(
                        valueListenable: AdoptionJourneyService().journeys,
                        builder: (context, _, _) => _buildActivityCard(
                          icon: Icons.calendar_month_outlined,
                          iconColor: const Color(0xFF008F82),
                          title: 'My Appointments',
                          count: AppointmentStore.activeCount,
                          countLabel: 'appointment',
                          status:
                              AppointmentStore.hasAppointment &&
                                  AppointmentStore.activeCount == 0
                              ? 'Done'
                              : null,
                          isDark: isDark,
                          activityCardBg: activityCardBg,
                          borderCol: borderCol,
                          textCol: textCol,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MyAppointmentsScreen(
                                  onBrowsePets: widget.onBrowsePets,
                                ),
                              ),
                            );
                            setState(() {});
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // App Settings, Help & Support
                      _buildSectionTitle(
                        'More',
                        icon: Icons.settings_outlined,
                      ),

                      const SizedBox(height: 8),

                      _buildSettingsCard(isDark, cardBg, borderCol, textCol, subTextCol),

                      const SizedBox(height: 22),

                      // Logout
                      Center(
                        child: TextButton.icon(
                          onPressed: _showLogoutDialog,
                          icon: Icon(
                            Icons.logout,
                            color: primaryColor,
                            size: 17,
                          ),
                          label: Text(
                            'Logout',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================

  Widget _buildProfileCard(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color textCol,
    Color subTextCol,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.025),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: (profileImage.isNotEmpty)
                  ? Image.network(
                      profileImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark ? const Color(0xFF0F172A) : lightBlue,
                          alignment: Alignment.center,
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: isDark ? const Color(0xFF0F172A) : lightBlue,
                      alignment: Alignment.center,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textCol,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userRole,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subTextCol,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _showEditProfileDialog,
            icon: Icon(
              Icons.edit_outlined,
              size: 14,
              color: primaryColor,
            ),
            label: Text(
              'Edit Profile',
              style: TextStyle(
                color: textCol,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 8,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(
                color: primaryColor,
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADOPTION JOURNEY (PROGRESS ROAD)
  // ============================================================

  Widget _buildAdoptionJourney(bool isDark) {
    final service = AdoptionJourneyService();
    return ValueListenableBuilder<List<AdoptionJourney>>(
      valueListenable: service.journeys,
      builder: (context, journeys, _) {
        if (journeys.isEmpty) return const SizedBox.shrink();
        return ValueListenableBuilder<Set<String>>(
          valueListenable: service.celebrations,
          builder: (context, celebrations, _) {
            // Finished adoptions move to history once a new one is in
            // progress (after their celebration has played).
            final board = JourneyBoard.of(journeys, celebrating: celebrations);
            final tracked = board.tracked;
            // A fresh milestone takes the spotlight over the user's pick.
            final celebrating = tracked
                .where((j) => celebrations.contains(j.applicationId))
                .firstOrNull;
            final selected =
                celebrating ??
                tracked
                    .where((j) => j.applicationId == _selectedJourneyId)
                    .firstOrNull ??
                tracked.first;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                  'My Adoption Journey',
                  icon: Icons.route_rounded,
                ),
                const SizedBox(height: 10),
                if (tracked.length > 1) ...[
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: tracked.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final j = tracked[i];
                        final active = j.applicationId == selected.applicationId;
                        return ChoiceChip(
                          label: Text(j.petName),
                          selected: active,
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? Colors.white
                                : (isDark
                                      ? const Color(0xFFF8FAFC)
                                      : darkText),
                          ),
                          selectedColor: tealColor,
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          side: BorderSide(
                            color: active
                                ? tealColor
                                : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0)),
                          ),
                          onSelected: (_) => setState(
                            () => _selectedJourneyId = j.applicationId,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                AdoptionJourneyTracker(
                  key: ValueKey(selected.applicationId),
                  journey: selected,
                  isDark: isDark,
                  celebrate: celebrations.contains(selected.applicationId),
                  onCelebrated: () =>
                      service.markCelebrated(selected.applicationId),
                  onBookMeetAndGreet: () =>
                      VisitAppointmentScreen.openMeetAndGreet(context, selected),
                  onShareStory: () => _shareStory(selected),
                  onTap: _openMyApplications,
                ),
                if (board.history.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildSectionTitle(
                    'Adoption History',
                    icon: Icons.history_rounded,
                  ),
                  const SizedBox(height: 10),
                  for (final j in board.history) ...[
                    AdoptionHistoryTile(
                      journey: j,
                      isDark: isDark,
                      onTap: () => _openApplicationDetails(j.applicationId),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
                const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _shareStory(AdoptionJourney journey) async {
    final messenger = ScaffoldMessenger.of(context);
    final posted = await SuccessStoryComposer.open(
      context,
      initialPet: journey,
    );
    if (posted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "${journey.petName}'s story is live in Community › Success Stories!",
          ),
        ),
      );
    }
  }

  void _openApplicationDetails(String applicationId) {
    final application = AdoptionApplicationStore.applications
        .where((a) => a['id'] == applicationId)
        .firstOrNull;
    if (application == null) {
      _openMyApplications();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicationDetailsScreen(application: application),
      ),
    );
  }

  Future<void> _openMyApplications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyApplicationsScreen(onBrowsePets: widget.onBrowsePets),
      ),
    );
    if (mounted) setState(() {});
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    String title, {
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 15,
            color: primaryColor,
          ),
          const SizedBox(width: 6),
        ],
        Text(
          title,
          style: TextStyle(
            color: primaryColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTIVITY CARD
  // ============================================================

  Widget _buildActivityCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    int count = 0,
    String countLabel = '',
    String? status,
    VoidCallback? onTap,
    required bool isDark,
    required Color activityCardBg,
    required Color borderCol,
    required Color textCol,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: activityCardBg,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: borderCol) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 27,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textCol,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (count > 0 || status != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$count $countLabel${count == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (count > 0 && status != null) const SizedBox(height: 4),
                  if (status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF008F82).withValues(alpha: 0.2)
                            : const Color(0xFFD9F2F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF008F82),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _buildSettingsCard(
    bool isDark,
    Color cardBg,
    Color borderCol,
    Color textCol,
    Color subTextCol,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.menu_book_outlined,
            title: 'How to Use',
            textCol: textCol,
            subTextCol: subTextCol,
            onTap: () => HowToUseScreen.open(context),
          ),
          _buildSettingItem(
            icon: Icons.settings_outlined,
            title: 'App Settings',
            textCol: textCol,
            subTextCol: subTextCol,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppSettingsScreen(),
                ),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            textCol: textCol,
            subTextCol: subTextCol,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HelpSupportScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTING ITEM
  // ============================================================

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Color textCol,
    required Color subTextCol,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: textCol,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textCol,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: subTextCol,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  void _showEditProfileDialog() {
    final isDark = ThemeService.isDarkMode(context);
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dialogText = isDark ? const Color(0xFFF8FAFC) : darkText;
    final dialogSubText = isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600;
    final dialogInputBg = isDark ? const Color(0xFF0F172A) : detailBlue;

    final nameController = TextEditingController(text: userName);

    XFile? pickedPhoto;
    Uint8List? pickedPhotoBytes;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Edit Profile',
                style: TextStyle(
                  color: dialogText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Photo Avatar with Edit Badge
                    GestureDetector(
                      onTap: isSaving
                          ? null
                          : () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 800,
                                maxHeight: 800,
                                imageQuality: 85,
                              );
                              if (picked != null) {
                                final bytes = await picked.readAsBytes();
                                setModalState(() {
                                  pickedPhoto = picked;
                                  pickedPhotoBytes = bytes;
                                });
                              }
                            },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: pickedPhotoBytes != null
                                  ? Image.memory(
                                      pickedPhotoBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : (profileImage.isNotEmpty)
                                      ? Image.network(
                                          profileImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: isDark ? const Color(0xFF0F172A) : lightBlue,
                                            alignment: Alignment.center,
                                            child: Text(
                                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: isDark ? const Color(0xFF0F172A) : lightBlue,
                                          alignment: Alignment.center,
                                          child: Text(
                                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFA94327),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap to change photo',
                      style: TextStyle(
                        fontSize: 11,
                        color: dialogSubText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      enabled: !isSaving,
                      style: TextStyle(color: dialogText, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(fontSize: 13, color: dialogSubText),
                        filled: true,
                        fillColor: dialogInputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: dialogSubText, fontSize: 13),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          setModalState(() => isSaving = true);
                          try {
                            String newAvatarUrl = profileImage;
                            final currentUser = supabase.auth.currentUser;

                            // 1. Upload photo if selected
                            if (currentUser != null && pickedPhoto != null && pickedPhotoBytes != null) {
                              final fileName =
                                  'avatar_${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                              final storagePath = 'avatars/$fileName';
                              await supabase.storage.from('pet-photos').uploadBinary(
                                    storagePath,
                                    pickedPhotoBytes!,
                                    fileOptions: const FileOptions(
                                      contentType: 'image/jpeg',
                                      upsert: true,
                                    ),
                                  );
                              newAvatarUrl =
                                  supabase.storage.from('pet-photos').getPublicUrl(storagePath);
                            }

                            final updatedName = nameController.text.trim().isNotEmpty
                                ? nameController.text.trim()
                                : userName;

                            // 2. Persist to profiles database and auth
                            if (currentUser != null) {
                              final Map<String, dynamic> profileUpdates = {
                                'full_name': updatedName,
                              };
                              await supabase
                                  .from('profiles')
                                  .update(profileUpdates)
                                  .eq('id', currentUser.id);

                              final Map<String, dynamic> authUpdates = {
                                'full_name': updatedName,
                              };
                              if (newAvatarUrl.isNotEmpty) {
                                authUpdates['avatar_url'] = newAvatarUrl;
                              }
                              await supabase.auth.updateUser(UserAttributes(data: authUpdates));
                            }

                            if (!mounted) return;
                            setState(() {
                              userName = updatedName;
                              profileImage = newAvatarUrl;
                            });
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            if (dialogContext.mounted) {
                              setModalState(() => isSaving = false);
                            }
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Failed to update profile: $e'),
                                backgroundColor: Colors.red.shade700,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save', style: TextStyle(fontSize: 13)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // LOGOUT CONFIRMATION
  // ============================================================

  void _showLogoutDialog() {
    final isDark = ThemeService.isDarkMode(context);
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dialogText = isDark ? const Color(0xFFF8FAFC) : darkText;
    final dialogSubText = isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              color: dialogText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: dialogSubText,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: dialogSubText, fontSize: 13),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 13)),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ACTUAL SUPABASE LOGOUT
  // ============================================================

  Future<void> _logout() async {
    try {
      AdoptionApplicationStore.clear();
      AppointmentStore.clear();
      AdoptionJourneyService().signOut();
      await supabase.auth.signOut(scope: SignOutScope.local);
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: ${error.message}',
            style: const TextStyle(fontSize: 13),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: $error',
            style: const TextStyle(fontSize: 13),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}