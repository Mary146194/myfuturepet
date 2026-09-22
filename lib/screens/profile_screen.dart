import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'my_applications_screen.dart';
import '../adoption_application_store.dart';

import 'my_appointments_screen.dart';
import '../appointment_store.dart';

import 'saved_pets_screen.dart';
import '../saved_pet_store.dart';

import 'login_screen.dart';

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBrowsePets;

  const ProfileScreen({
    super.key,
    this.onBrowsePets,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  final Color primaryColor =
      const Color(0xFFA94327);

  final Color darkText =
      const Color(0xFF062B35);

  final Color tealColor =
      const Color(0xFF008F82);

  final Color detailBrown =
      const Color(0xFF604A45);

  final Color detailBlue =
      const Color(0xFFEFF9FD);

  final Color lightBlue =
      const Color(0xFFE4F5FB);

  // ============================================================
  // PROFILE DATA
  // ============================================================

  String userName = 'Loading...';

  String userRole =
      'Aspiring Pet Parent';

  String profileImage =
      'https://i.pravatar.cc/300?img=12';

  bool isLoadingProfile = true;

  // ============================================================
  // SUPABASE CLIENT
  // ============================================================

  final SupabaseClient supabase =
      Supabase.instance.client;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadUserProfile();
  }

  // ============================================================
  // LOAD CURRENT LOGGED-IN USER
  // ============================================================

  Future<void> _loadUserProfile() async {
    try {
      // --------------------------------------------------------
      // GET CURRENT SUPABASE USER
      // --------------------------------------------------------

      final User? user =
          supabase.auth.currentUser;

      // --------------------------------------------------------
      // NO USER
      // --------------------------------------------------------

      if (user == null) {
        if (!mounted) {
          return;
        }

        setState(() {
          userName = 'User';
          isLoadingProfile = false;
        });

        return;
      }

      // --------------------------------------------------------
      // DEFAULT VALUES FROM SUPABASE AUTH
      // --------------------------------------------------------

      String loadedName =
          user.userMetadata?['full_name']
                  ?.toString()
                  .trim() ??
              '';

      String loadedRole =
          user.userMetadata?['role']
                  ?.toString()
                  .trim() ??
              '';

      String loadedImage =
          user.userMetadata?['avatar_url']
                  ?.toString()
                  .trim() ??
              '';

      // --------------------------------------------------------
      // FALLBACK NAME
      // --------------------------------------------------------

      if (loadedName.isEmpty) {
        loadedName =
            user.userMetadata?['name']
                    ?.toString()
                    .trim() ??
                '';
      }

      if (loadedName.isEmpty) {
        loadedName =
            user.email
                    ?.split('@')
                    .first ??
                'User';
      }

      // --------------------------------------------------------
      // GET PROFILE FROM DATABASE
      //
      // Assumed table:
      // profiles
      //
      // Columns:
      // id
      // full_name
      // role
      // avatar_url
      // --------------------------------------------------------

      try {
        final profile = await supabase
            .from('profiles')
            .select(
              'full_name, role, avatar_url',
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

          final String databaseRole =
              profile['role']
                      ?.toString()
                      .trim() ??
                  '';

          final String databaseImage =
              profile['avatar_url']
                      ?.toString()
                      .trim() ??
                  '';

          // ----------------------------------------------------
          // NAME
          // ----------------------------------------------------

          if (databaseName.isNotEmpty) {
            loadedName = databaseName;
          }

          // ----------------------------------------------------
          // ROLE
          // ----------------------------------------------------

          if (databaseRole.isNotEmpty) {
            loadedRole = databaseRole;
          }

          // ----------------------------------------------------
          // PROFILE IMAGE
          // ----------------------------------------------------

          if (databaseImage.isNotEmpty) {
            loadedImage = databaseImage;
          }
        }
      } catch (_) {
        // ------------------------------------------------------
        // IF PROFILES QUERY FAILS,
        // KEEP USING SUPABASE AUTH DATA.
        // ------------------------------------------------------
      }

      // --------------------------------------------------------
      // DEFAULT ROLE
      // --------------------------------------------------------

      if (loadedRole.isEmpty) {
        loadedRole =
            'Aspiring Pet Parent';
      }

      // --------------------------------------------------------
      // DEFAULT IMAGE
      // --------------------------------------------------------

      if (loadedImage.isEmpty) {
        loadedImage =
            'https://i.pravatar.cc/300?img=12';
      }

      // --------------------------------------------------------
      // UPDATE SCREEN
      // --------------------------------------------------------

      if (!mounted) {
        return;
      }

      setState(() {
        userName = loadedName;
        userRole = loadedRole;
        profileImage = loadedImage;

        isLoadingProfile = false;
      });
    } catch (error) {
      // --------------------------------------------------------
      // FINAL FALLBACK
      // --------------------------------------------------------

      if (!mounted) {
        return;
      }

      final User? user =
          supabase.auth.currentUser;

      String fallbackName = 'User';

      if (user != null) {
        fallbackName =
            user.userMetadata?['full_name']
                    ?.toString()
                    .trim() ??
                '';

        if (fallbackName.isEmpty) {
          fallbackName =
              user.userMetadata?['name']
                      ?.toString()
                      .trim() ??
                  '';
        }

        if (fallbackName.isEmpty) {
          fallbackName =
              user.email
                      ?.split('@')
                      .first ??
                  'User';
        }
      }

      setState(() {
        userName = fallbackName;
        isLoadingProfile = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: detailBrown,

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // TOP HEADER
            // ==================================================

            Container(
              color: detailBlue,

              padding: const EdgeInsets.fromLTRB(
                14,
                10,
                14,
                10,
              ),

              child: Row(
                children: [

                  // ==================================================
                  // PROFILE IMAGE
                  // ==================================================

                  ClipOval(
                    child: Image.network(
                      profileImage,

                      width: 32,
                      height: 32,

                      fit: BoxFit.cover,

                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          width: 32,
                          height: 32,

                          color: lightBlue,

                          child: Icon(
                            Icons.person,
                            size: 19,
                            color: primaryColor,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 9),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    'Profile',

                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  // ==================================================
                  // NOTIFICATION
                  // ==================================================

                  Icon(
                    Icons.notifications_none,
                    size: 21,
                    color: darkText,
                  ),
                ],
              ),
            ),

            // ==================================================
            // PROFILE CONTENT
            // ==================================================

            Expanded(
              child: Container(
                color: Colors.white,

                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  padding:
                      const EdgeInsets.fromLTRB(
                    14,
                    16,
                    14,
                    30,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // ==================================================
                      // PROFILE CARD
                      // ==================================================

                      _buildProfileCard(),

                      const SizedBox(height: 24),

                      // ==================================================
                      // MY ACTIVITY
                      // ==================================================

                      _buildSectionTitle(
                        'My Activity',
                      ),

                      const SizedBox(height: 12),

                      // ==================================================
                      // MY APPLICATIONS
                      // ==================================================

                      _buildActivityCard(
                        icon:
                            Icons.description_outlined,

                        iconColor:
                            const Color(0xFFA94327),

                        title:
                            'My Applications',

                        count:
                            AdoptionApplicationStore
                                .applicationCount,

                        countLabel:
                            'application',

                        status:
                            AdoptionApplicationStore
                                    .hasApplication
                                ? 'Under Review'
                                : null,

                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MyApplicationsScreen(
                                onBrowsePets:
                                    widget.onBrowsePets,
                              ),
                            ),
                          );

                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 9),

                      // ==================================================
                      // SAVED PETS
                      // ==================================================

                      _buildActivityCard(
                        icon:
                            Icons.favorite_border,

                        iconColor:
                            primaryColor,

                        title:
                            'Saved Pets',

                        count:
                            SavedPetStore.savedCount,

                        countLabel:
                            'saved pet',

                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SavedPetsScreen(
                                onBrowsePets:
                                    widget.onBrowsePets,
                              ),
                            ),
                          );

                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 9),

                      // ==================================================
                      // MY APPOINTMENTS
                      // ==================================================

                      _buildActivityCard(
                        icon:
                            Icons.calendar_month_outlined,

                        iconColor:
                            const Color(0xFF008F82),

                        title:
                            'My Appointments',

                        count:
                            AppointmentStore
                                .appointmentCount,

                        countLabel:
                            'appointment',

                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MyAppointmentsScreen(
                                onBrowsePets:
                                    widget.onBrowsePets,
                              ),
                            ),
                          );

                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // APP SETTINGS
                      // ==================================================

                      _buildSectionTitle(
                        'App Settings',

                        icon:
                            Icons.settings_outlined,
                      ),

                      const SizedBox(height: 8),

                      _buildSettingsCard(),

                      const SizedBox(height: 22),

                      // ==================================================
                      // LOGOUT
                      // ==================================================

                      Center(
                        child: TextButton.icon(
                          onPressed:
                              _showLogoutDialog,

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
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        12,
        14,
        12,
        16,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: Colors.grey.shade100,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.025),

            blurRadius: 7,

            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        children: [

          // ==================================================
          // PROFILE IMAGE
          // ==================================================

          Container(
            width: 88,
            height: 88,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.white,
                width: 3,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(
                    0.13,
                  ),

                  blurRadius: 9,

                  offset:
                      const Offset(0, 3),
                ),
              ],
            ),

            child: ClipOval(
              child: Image.network(
                profileImage,

                fit: BoxFit.cover,

                errorBuilder:
                    (context, error, stackTrace) {
                  return Container(
                    color: lightBlue,

                    child: Icon(
                      Icons.person,
                      size: 42,
                      color: primaryColor,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ==================================================
          // NAME
          // ==================================================

          Text(
            userName,

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color: darkText,
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          // ==================================================
          // ROLE
          // ==================================================

          Text(
            userRole,

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color:
                  Colors.grey.shade600,

              fontSize: 11,
            ),
          ),

          const SizedBox(height: 12),

          // ==================================================
          // EDIT PROFILE
          // ==================================================

          OutlinedButton.icon(
            onPressed:
                _showEditProfileDialog,

            icon: Icon(
              Icons.edit_outlined,
              size: 14,
              color: primaryColor,
            ),

            label: Text(
              'Edit Profile',

              style: TextStyle(
                color: darkText,
                fontSize: 12,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            style:
                OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 8,
              ),

              minimumSize:
                  Size.zero,

              tapTargetSize:
                  MaterialTapTargetSize
                      .shrinkWrap,

              side: BorderSide(
                color: primaryColor,
                width: 1.2,
              ),

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  20,
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
            fontWeight:
                FontWeight.w600,
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
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,

        margin:
            const EdgeInsets.only(
          bottom: 12,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color:
              const Color(0xFFEFF9FD),

          borderRadius:
              BorderRadius.circular(18),
        ),

        child: Row(
          children: [

            // =====================================================
            // ICON CIRCLE
            // =====================================================

            Container(
              width: 52,
              height: 52,

              decoration:
                  BoxDecoration(
                color:
                    iconColor.withOpacity(
                  0.12,
                ),

                shape:
                    BoxShape.circle,
              ),

              child: Icon(
                icon,
                color: iconColor,
                size: 27,
              ),
            ),

            const SizedBox(width: 18),

            // =====================================================
            // TITLE
            // =====================================================

            Expanded(
              child: Text(
                title,

                maxLines: 1,

                overflow:
                    TextOverflow.ellipsis,

                style:
                    const TextStyle(
                  color:
                      Color(0xFF062B35),

                  fontSize: 16,

                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // =====================================================
            // BADGES
            // =====================================================

            if (count > 0 ||
                status != null)
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,

                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  // =================================================
                  // COUNT
                  // =================================================

                  if (count > 0)
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(
                        color: iconColor,

                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),

                      child: Text(
                        '$count '
                        '$countLabel'
                        '${count == 1 ? '' : 's'}',

                        style:
                            const TextStyle(
                          color:
                              Colors.white,

                          fontSize: 10,

                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),

                  // =================================================
                  // SPACE
                  // =================================================

                  if (count > 0 &&
                      status != null)
                    const SizedBox(
                      height: 5,
                    ),

                  // =================================================
                  // STATUS
                  // =================================================

                  if (status != null)
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFD9F2F0,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),

                      child: Text(
                        status,

                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF008F82,
                          ),

                          fontSize: 10,

                          fontWeight:
                              FontWeight.w700,
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
  // REMINDER CARD
  // ============================================================

  Widget _buildReminderCard() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color:
            const Color(0xFFF2FAF9),

        borderRadius:
            BorderRadius.circular(11),

        border: Border.all(
          color:
              const Color(0xFFD5EAE7),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: tealColor,
              shape:
                  BoxShape.circle,
            ),

            child: const Icon(
              Icons.vaccines_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),

          const SizedBox(width: 11),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(13),

        border: Border.all(
          color:
              Colors.grey.shade100,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.02,
            ),

            blurRadius: 5,

            offset:
                const Offset(0, 1),
          ),
        ],
      ),

      child: Column(
        children: [

          // ==================================================
          // APP SETTINGS
          // ==================================================

          _buildSettingItem(
            icon:
                Icons.settings_outlined,

            title:
                'App Settings',

            onTap: () {
              _showMessage(
                'App Settings selected.',
              );
            },
          ),

          // ==================================================
          // NOTIFICATIONS
          // ==================================================

          _buildSettingItem(
            icon:
                Icons.notifications_none,

            title:
                'Notifications',

            onTap: () {
              _showMessage(
                'Notifications settings selected.',
              );
            },
          ),

          // ==================================================
          // PREFERENCES
          // ==================================================

          _buildSettingItem(
            icon:
                Icons.tune,

            title:
                'Preferences',

            onTap: () {
              _showMessage(
                'Preferences selected.',
              );
            },
          ),

          // ==================================================
          // HELP
          // ==================================================

          _buildSettingItem(
            icon:
                Icons.help_outline,

            title:
                'Help & Support',

            onTap:
                _showHelpDialog,
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),

        child: Row(
          children: [

            Icon(
              icon,
              size: 16,
              color: darkText,
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Text(
                title,

                style: TextStyle(
                  color: darkText,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w400,
                ),
              ),
            ),

            Icon(
              Icons.chevron_right,
              size: 18,
              color:
                  Colors.grey.shade400,
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
    final nameController =
        TextEditingController(
      text: userName,
    );

    final roleController =
        TextEditingController(
      text: userRole,
    );

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
              18,
            ),
          ),

          title: Text(
            'Edit Profile',

            style: TextStyle(
              color: darkText,
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [

              // ==================================================
              // NAME
              // ==================================================

              TextField(
                controller:
                    nameController,

                style: TextStyle(
                  color: darkText,
                  fontSize: 14,
                ),

                decoration:
                    InputDecoration(
                  labelText:
                      'Name',

                  labelStyle:
                      TextStyle(
                    fontSize: 13,
                    color:
                        Colors.grey
                            .shade600,
                  ),

                  filled: true,

                  fillColor:
                      detailBlue,

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(
                height: 11,
              ),

              // ==================================================
              // PROFILE
              // ==================================================

              TextField(
                controller:
                    roleController,

                style: TextStyle(
                  color: darkText,
                  fontSize: 14,
                ),

                decoration:
                    InputDecoration(
                  labelText:
                      'Profile',

                  labelStyle:
                      TextStyle(
                    fontSize: 13,
                    color:
                        Colors.grey
                            .shade600,
                  ),

                  filled: true,

                  fillColor:
                      detailBlue,

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),
            ],
          ),

          actions: [

            // ==================================================
            // CANCEL
            // ==================================================

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
                      Colors.grey
                          .shade600,

                  fontSize: 13,
                ),
              ),
            ),

            // ==================================================
            // SAVE
            // ==================================================

            ElevatedButton(
              onPressed: () {
                setState(() {

                  if (nameController
                      .text
                      .trim()
                      .isNotEmpty) {
                    userName =
                        nameController
                            .text
                            .trim();
                  }

                  if (roleController
                      .text
                      .trim()
                      .isNotEmpty) {
                    userRole =
                        roleController
                            .text
                            .trim();
                  }
                });

                Navigator.pop(
                  dialogContext,
                );
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,

                foregroundColor:
                    Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
              ),

              child:
                  const Text(
                'Save',

                style:
                    TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOGOUT CONFIRMATION
  // ============================================================

  void _showLogoutDialog() {
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
              18,
            ),
          ),

          title: Text(
            'Logout',

            style: TextStyle(
              color: darkText,
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: Text(
            'Are you sure you want to logout?',

            style: TextStyle(
              color: darkText,
              fontSize: 14,
            ),
          ),

          actions: [

            // ==================================================
            // CANCEL
            // ==================================================

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
                      Colors.grey
                          .shade600,

                  fontSize: 13,
                ),
              ),
            ),

            // ==================================================
            // LOGOUT
            // ==================================================

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(
                  dialogContext,
                );

                await _logout();
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,

                foregroundColor:
                    Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
              ),

              child:
                  const Text(
                'Logout',

                style:
                    TextStyle(
                  fontSize: 13,
                ),
              ),
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
      // ========================================================
      // SIGN OUT FROM SUPABASE
      // ========================================================

      await supabase.auth.signOut(
        scope:
            SignOutScope.local,
      );

      // ========================================================
      // CHECK WIDGET
      // ========================================================

      if (!mounted) {
        return;
      }

      // ========================================================
      // RETURN TO LOGIN
      // ========================================================

      Navigator.of(context)
          .pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              const LoginScreen(),
        ),
        (route) => false,
      );
    }

    // ==========================================================
    // SUPABASE AUTH ERROR
    // ==========================================================

    on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: ${error.message}',

            style:
                const TextStyle(
              fontSize: 13,
            ),
          ),

          backgroundColor:
              Colors.red.shade700,

          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }

    // ==========================================================
    // OTHER ERROR
    // ==========================================================

    catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: $error',

            style:
                const TextStyle(
              fontSize: 13,
            ),
          ),

          backgroundColor:
              Colors.red.shade700,

          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // HELP DIALOG
  // ============================================================

  void _showHelpDialog() {
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
              18,
            ),
          ),

          title: Text(
            'Help & Support',

            style: TextStyle(
              color: darkText,
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: Text(
            'Need help with adoption, appointments, or your account? Our support team is here to help.',

            style: TextStyle(
              color: darkText,
              fontSize: 13,
              height: 1.5,
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
                'Close',

                style: TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
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
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'my_applications_screen.dart';
// import '../adoption_application_store.dart';
// import 'my_appointments_screen.dart';
// import '../appointment_store.dart';
// import 'saved_pets_screen.dart';
// import '../saved_pet_store.dart';

// import 'login_screen.dart';

// // ============================================================
// // PROFILE SCREEN
// // ============================================================

// class ProfileScreen extends StatefulWidget {
//   final VoidCallback? onBrowsePets;

//   const ProfileScreen({
//     super.key,
//     this.onBrowsePets,
//   });

//   @override
//   State<ProfileScreen> createState() =>
//       _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
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
//   // PROFILE DATA
//   // ============================================================

//   String userName = 'John Miares';
//   String userRole = 'Aspiring Pet Parent';

//   String profileImage =
//       'https://i.pravatar.cc/300?img=12';

//   // ============================================================
//   // SUPABASE CLIENT
//   // ============================================================

//   final SupabaseClient supabase =
//       Supabase.instance.client;

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: detailBrown,

//       body: SafeArea(
//         child: Column(
//           children: [

//             // ==================================================
//             // TOP HEADER
//             // ==================================================

//             Container(
//               color: detailBlue,

//               padding: const EdgeInsets.fromLTRB(
//                 14,
//                 10,
//                 14,
//                 10,
//               ),

//               child: Row(
//                 children: [

//                   // PROFILE IMAGE
//                   ClipOval(
//                     child: Image.network(
//                       profileImage,
//                       width: 32,
//                       height: 32,
//                       fit: BoxFit.cover,

//                       errorBuilder:
//                           (context, error, stackTrace) {
//                         return Container(
//                           width: 32,
//                           height: 32,
//                           color: lightBlue,
//                           child: Icon(
//                             Icons.person,
//                             size: 19,
//                             color: primaryColor,
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   const SizedBox(width: 9),

//                   // TITLE
//                   Text(
//                     'Profile',
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const Spacer(),

//                   // NOTIFICATION
//                   Icon(
//                     Icons.notifications_none,
//                     size: 21,
//                     color: darkText,
//                   ),
//                 ],
//               ),
//             ),

//             // ==================================================
//             // PROFILE CONTENT
//             // ==================================================

//             Expanded(
//               child: Container(
//                 color: Colors.white,

//                 child: SingleChildScrollView(
//                   physics:
//                       const BouncingScrollPhysics(),

//                   padding:
//                       const EdgeInsets.fromLTRB(
//                     14,
//                     16,
//                     14,
//                     30,
//                   ),

//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,

//                     children: [

//                       // ==================================================
//                       // PROFILE CARD
//                       // ==================================================

//                       _buildProfileCard(),

//                       const SizedBox(height: 24),

//                       // ==================================================
//                       // MY ACTIVITY
//                       // ==================================================

//                       _buildSectionTitle(
//                         'My Activity',
//                       ),

//                       const SizedBox(height: 12),

//                       // _buildActivityCard(
//                       //   icon: Icons.description_outlined,
//                       //   iconColor: const Color(0xFFA94327),
//                       //   title: 'My Applications',
//                       //   status: AdoptionApplicationStore.hasApplication
//                       //       ? '${AdoptionApplicationStore.applicationCount} Application${AdoptionApplicationStore.applicationCount == 1 ? '' : 's'}'
//                       //       : null,
//                       //   onTap: () {
//                       //     Navigator.push(
//                       //       context,
//                       //       MaterialPageRoute(
//                       //         builder: (_) => MyApplicationsScreen(
//                       //           onBrowsePets: widget.onBrowsePets,
//                       //         ),
//                       //       ),
//                       //     ).then((_) {
//                       //       setState(() {});
//                       //     });
//                       //   },
//                       // ),

//                       _buildActivityCard(
//                         icon: Icons.description_outlined,
//                         iconColor: const Color(0xFFA94327),
//                         title: 'My Applications',
//                         count: AdoptionApplicationStore.applicationCount,
//                         countLabel: 'application',
//                         status: AdoptionApplicationStore.hasApplication
//                             ? 'Under Review'
//                             : null,
//                         onTap: () async {
//                           await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => MyApplicationsScreen(onBrowsePets: widget.onBrowsePets,),
//                             ),
//                           );

//                           setState(() {});
//                         },
//                       ),

                      

//                       const SizedBox(height: 9),

//                       _buildActivityCard(
//                         icon: Icons.favorite_border,
//                         iconColor: primaryColor,
//                         title: 'Saved Pets',

//                         count: SavedPetStore.savedCount,
//                         countLabel: 'saved pet',

//                         onTap: () async {
//                           await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => SavedPetsScreen(
//                                 onBrowsePets: widget.onBrowsePets,
//                               ),
//                             ),
//                           );

//                           setState(() {});
//                         },
//                       ),

//                       const SizedBox(height: 9),

//                       _buildActivityCard(
//                         icon: Icons.calendar_month_outlined,
//                         iconColor: const Color(0xFF008F82),
//                         title: 'My Appointments',
//                         count: AppointmentStore.appointmentCount,
                        
//                         countLabel: 'appointment',
//                         onTap: () async {
//                           await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => MyAppointmentsScreen(
//                                 onBrowsePets: widget.onBrowsePets,
//                               ),
//                             ),
//                           );

//                           setState(() {});
//                         },
//                       ),

//                       const SizedBox(height: 24),

//                       // ==================================================
//                       // PET CARE REMINDERS
//                       // ==================================================

//                       // _buildSectionTitle(
//                       //   'Pet Care Reminders',
//                       //   icon: Icons
//                       //       .notifications_active_outlined,
//                       // ),

//                       // const SizedBox(height: 10),

//                       // _buildReminderCard(),

//                       // const SizedBox(height: 24),

//                       // ==================================================
//                       // APP SETTINGS
//                       // ==================================================

//                       _buildSectionTitle(
//                         'App Settings',
//                         icon:
//                             Icons.settings_outlined,
//                       ),

//                       const SizedBox(height: 8),

//                       _buildSettingsCard(),

//                       const SizedBox(height: 22),

//                       // ==================================================
//                       // LOGOUT
//                       // ==================================================

//                       Center(
//                         child: TextButton.icon(
//                           onPressed:
//                               _showLogoutDialog,

//                           icon: Icon(
//                             Icons.logout,
//                             color: primaryColor,
//                             size: 17,
//                           ),

//                           label: Text(
//                             'Logout',
//                             style: TextStyle(
//                               color: primaryColor,
//                               fontSize: 13,
//                               fontWeight:
//                                   FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PROFILE CARD
//   // ============================================================

//   Widget _buildProfileCard() {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.fromLTRB(
//         12,
//         14,
//         12,
//         16,
//       ),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(16),

//         border: Border.all(
//           color: Colors.grey.shade100,
//         ),

//         boxShadow: [
//           BoxShadow(
//             color:
//                 Colors.black.withOpacity(0.025),
//             blurRadius: 7,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),

//       child: Column(
//         children: [

//           // ==================================================
//           // PROFILE IMAGE
//           // ==================================================

//           Container(
//             width: 88,
//             height: 88,

//             decoration: BoxDecoration(
//               shape: BoxShape.circle,

//               border: Border.all(
//                 color: Colors.white,
//                 width: 3,
//               ),

//               boxShadow: [
//                 BoxShadow(
//                   color:
//                       Colors.black.withOpacity(
//                     0.13,
//                   ),
//                   blurRadius: 9,
//                   offset:
//                       const Offset(0, 3),
//                 ),
//               ],
//             ),

//             child: ClipOval(
//               child: Image.network(
//                 profileImage,

//                 fit: BoxFit.cover,

//                 errorBuilder:
//                     (context, error, stackTrace) {
//                   return Container(
//                     color: lightBlue,

//                     child: Icon(
//                       Icons.person,
//                       size: 42,
//                       color: primaryColor,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ==================================================
//           // NAME
//           // ==================================================

//           Text(
//             userName,
//             textAlign: TextAlign.center,

//             style: TextStyle(
//               color: darkText,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 3),

//           // ==================================================
//           // ROLE
//           // ==================================================

//           Text(
//             userRole,
//             textAlign: TextAlign.center,

//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: 11,
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ==================================================
//           // EDIT PROFILE
//           // ==================================================

//           OutlinedButton.icon(
//             onPressed:
//                 _showEditProfileDialog,

//             icon: Icon(
//               Icons.edit_outlined,
//               size: 14,
//               color: primaryColor,
//             ),

//             label: Text(
//               'Edit Profile',
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),

//             style:
//                 OutlinedButton.styleFrom(
//               padding:
//                   const EdgeInsets.symmetric(
//                 horizontal: 17,
//                 vertical: 8,
//               ),

//               minimumSize: Size.zero,

//               tapTargetSize:
//                   MaterialTapTargetSize
//                       .shrinkWrap,

//               side: BorderSide(
//                 color: primaryColor,
//                 width: 1.2,
//               ),

//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(20),
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

//   Widget _buildSectionTitle(
//     String title, {
//     IconData? icon,
//   }) {
//     return Row(
//       children: [

//         if (icon != null) ...[
//           Icon(
//             icon,
//             size: 15,
//             color: primaryColor,
//           ),

//           const SizedBox(width: 6),
//         ],

//         Text(
//           title,
//           style: TextStyle(
//             color: primaryColor,
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // ACTIVITY CARD
//   // ============================================================

//   // Widget _buildActivityCard({
//   //   required IconData icon,
//   //   required String title,
//   //   String? status,
//   //   VoidCallback? onTap,
//   // }) {
//   //   return GestureDetector(
//   //     onTap: onTap,
//   //     child: Container(
//   //       width: double.infinity,
//   //       margin: const EdgeInsets.only(bottom: 12),
//   //       padding: const EdgeInsets.symmetric(
//   //         horizontal: 18,
//   //         vertical: 14,
//   //       ),
//   //       decoration: BoxDecoration(
//   //         color: const Color(0xFFEFF9FD),
//   //         borderRadius: BorderRadius.circular(18),
//   //       ),
//   //       child: Row(
//   //         children: [
//   //           Container(
//   //             width: 52,
//   //             height: 52,
//   //             decoration: const BoxDecoration(
//   //               color: Color(0xFFE8E5E3),
//   //               shape: BoxShape.circle,
//   //             ),
//   //             child: Icon(
//   //               icon,
//   //               color: const Color(0xFFA94327),
//   //               size: 27,
//   //             ),
//   //           ),

//   //           const SizedBox(width: 18),

//   //           Expanded(
//   //             child: Text(
//   //               title,
//   //               style: const TextStyle(
//   //                 color: Color(0xFF062B35),
//   //                 fontSize: 16,
//   //                 fontWeight: FontWeight.w600,
//   //               ),
//   //             ),
//   //           ),

//   //           if (status != null)
//   //             Container(
//   //               padding: const EdgeInsets.symmetric(
//   //                 horizontal: 14,
//   //                 vertical: 8,
//   //               ),
//   //               decoration: BoxDecoration(
//   //                 color: const Color(0xFFD9F2F0),
//   //                 borderRadius: BorderRadius.circular(20),
//   //               ),
//   //               child: Text(
//   //                 status,
//   //                 style: const TextStyle(
//   //                   color: Color(0xFF008F82),
//   //                   fontSize: 12,
//   //                   fontWeight: FontWeight.w700,
//   //                 ),
//   //               ),
//   //             ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }





//   Widget _buildActivityCard({
//   required IconData icon,
//   required Color iconColor,
//   required String title,
//   int count = 0,
//   String countLabel = '',
//   String? status,
//   VoidCallback? onTap,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.symmetric(
//         horizontal: 8,
//         vertical: 8,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFFEFF9FD),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Row(
//         children: [
//           // =====================================================
//           // ICON CIRCLE
//           // =====================================================

//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: iconColor.withOpacity(0.12),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               color: iconColor,
//               size: 27,
//             ),
//           ),

//           const SizedBox(width: 18),

//           // =====================================================
//           // TITLE
//           // =====================================================

//           Expanded(
//             child: Text(
//               title,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 color: Color(0xFF062B35),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),

//           const SizedBox(width: 8),

//           // =====================================================
//           // BADGES
//           // =====================================================

//           if (count > 0 || status != null)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // COUNT
//                 if (count > 0)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: iconColor,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       '$count $countLabel${count == 1 ? '' : 's'}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),

//                 // SPACE BETWEEN BADGES
//                 if (count > 0 && status != null)
//                   const SizedBox(height: 5),

//                 // STATUS
//                 if (status != null)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFD9F2F0),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       status,
//                       style: const TextStyle(
//                         color: Color(0xFF008F82),
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//         ],
//       ),
//     ),
//   );
// }





//   // Widget _buildActivityCard({
//   //   required IconData icon,
//   //   required Color iconColor,
//   //   required String title,
//   //   String? trailing,
//   //   Color? trailingColor,
//   //   required VoidCallback onTap,
//   // }) {
//   //   return GestureDetector(
//   //     onTap: onTap,

//   //     child: Container(
//   //       width: double.infinity,

//   //       padding:
//   //           const EdgeInsets.symmetric(
//   //         horizontal: 10,
//   //         vertical: 10,
//   //       ),

//   //       decoration: BoxDecoration(
//   //         color:
//   //             lightBlue.withOpacity(0.65),

//   //         borderRadius:
//   //             BorderRadius.circular(11),
//   //       ),

//   //       child: Row(
//   //         children: [

//   //           // ==================================================
//   //           // ICON
//   //           // ==================================================

//   //           Container(
//   //             width: 34,
//   //             height: 34,

//   //             decoration: BoxDecoration(
//   //               color:
//   //                   iconColor.withOpacity(
//   //                 0.10,
//   //               ),

//   //               shape: BoxShape.circle,
//   //             ),

//   //             child: Icon(
//   //               icon,
//   //               size: 16,
//   //               color: iconColor,
//   //             ),
//   //           ),

//   //           const SizedBox(width: 11),

//   //           // ==================================================
//   //           // TITLE
//   //           // ==================================================

//   //           Expanded(
//   //             child: Text(
//   //               title,
//   //               style: TextStyle(
//   //                 color: darkText,
//   //                 fontSize: 11,
//   //                 fontWeight:
//   //                     FontWeight.w500,
//   //               ),
//   //             ),
//   //           ),

//   //           // ==================================================
//   //           // STATUS
//   //           // ==================================================

//   //           if (trailing != null)
//   //             Container(
//   //               padding:
//   //                   const EdgeInsets
//   //                       .symmetric(
//   //                 horizontal: 9,
//   //                 vertical: 5,
//   //               ),

//   //               decoration:
//   //                   BoxDecoration(
//   //                 color:
//   //                     (trailingColor ??
//   //                             tealColor)
//   //                         .withOpacity(
//   //                   0.10,
//   //                 ),

//   //                 borderRadius:
//   //                     BorderRadius.circular(
//   //                   12,
//   //                 ),
//   //               ),

//   //               child: Text(
//   //                 trailing,
//   //                 textAlign: TextAlign.center,

//   //                 style: TextStyle(
//   //                   color:
//   //                       trailingColor ??
//   //                           tealColor,
//   //                   fontSize: 9,
//   //                   fontWeight:
//   //                       FontWeight.w600,
//   //                 ),
//   //               ),
//   //             ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }




//   // ============================================================
//   // REMINDER CARD
//   // ============================================================

//   Widget _buildReminderCard() {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.all(12),

//       decoration: BoxDecoration(
//         color: const Color(0xFFF2FAF9),

//         borderRadius:
//             BorderRadius.circular(11),

//         border: Border.all(
//           color: const Color(0xFFD5EAE7),
//         ),
//       ),

//       child: Row(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [

//           // ==================================================
//           // REMINDER ICON
//           // ==================================================

//           Container(
//             width: 38,
//             height: 38,

//             decoration: BoxDecoration(
//               color: tealColor,
//               shape: BoxShape.circle,
//             ),

//             child: const Icon(
//               Icons.vaccines_outlined,
//               color: Colors.white,
//               size: 18,
//             ),
//           ),

//           const SizedBox(width: 11),

//           // ==================================================
//           // REMINDER CONTENT
//           // ==================================================

//           // Expanded(
//           //   child: Column(
//           //     crossAxisAlignment:
//           //         CrossAxisAlignment.start,

//           //     children: [

//           //       Text(
//           //         'Vaccination Due',
//           //         style: TextStyle(
//           //           color: darkText,
//           //           fontSize: 12,
//           //           fontWeight:
//           //               FontWeight.bold,
//           //         ),
//           //       ),

//           //       const SizedBox(height: 4),

//           //       Text(
//           //         'Fido’s annual booster is due in 2 days. Schedule an appointment soon.',
//           //         style: TextStyle(
//           //           color:
//           //               Colors.grey.shade700,
//           //           fontSize: 10,
//           //           height: 1.4,
//           //         ),
//           //       ),

//           //       const SizedBox(height: 7),

//           //       GestureDetector(
//           //         onTap: () {
//           //           _showMessage(
//           //             'Schedule vaccination selected.',
//           //           );
//           //         },

//           //         child: Text(
//           //           'SCHEDULE NOW',
//           //           style: TextStyle(
//           //             color: tealColor,
//           //             fontSize: 10,
//           //             fontWeight:
//           //                 FontWeight.bold,
//           //           ),
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SETTINGS CARD
//   // ============================================================

//   Widget _buildSettingsCard() {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.symmetric(
//         vertical: 6,
//       ),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(13),

//         border: Border.all(
//           color: Colors.grey.shade100,
//         ),

//         boxShadow: [
//           BoxShadow(
//             color:
//                 Colors.black.withOpacity(0.02),
//             blurRadius: 5,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),

//       child: Column(
//         children: [

//           // APP SETTINGS
//           _buildSettingItem(
//             icon: Icons.settings_outlined,
//             title: 'App Settings',

//             onTap: () {
//               _showMessage(
//                 'App Settings selected.',
//               );
//             },
//           ),

//           // NOTIFICATIONS
//           _buildSettingItem(
//             icon: Icons.notifications_none,
//             title: 'Notifications',

//             onTap: () {
//               _showMessage(
//                 'Notifications settings selected.',
//               );
//             },
//           ),

//           // PREFERENCES
//           _buildSettingItem(
//             icon: Icons.tune,
//             title: 'Preferences',

//             onTap: () {
//               _showMessage(
//                 'Preferences selected.',
//               );
//             },
//           ),

//           // HELP
//           _buildSettingItem(
//             icon: Icons.help_outline,
//             title: 'Help & Support',

//             onTap: () {
//               _showHelpDialog();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SETTING ITEM
//   // ============================================================

//   Widget _buildSettingItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,

//       child: Padding(
//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 11,
//         ),

//         child: Row(
//           children: [

//             // ICON
//             Icon(
//               icon,
//               size: 16,
//               color: darkText,
//             ),

//             const SizedBox(width: 11),

//             // TITLE
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 12,
//                   fontWeight:
//                       FontWeight.w400,
//                 ),
//               ),
//             ),

//             // ARROW
//             Icon(
//               Icons.chevron_right,
//               size: 18,
//               color: Colors.grey.shade400,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EDIT PROFILE
//   // ============================================================

//   void _showEditProfileDialog() {
//     final nameController =
//         TextEditingController(
//       text: userName,
//     );

//     final roleController =
//         TextEditingController(
//       text: userRole,
//     );

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
//             'Edit Profile',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 19,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           content: Column(
//             mainAxisSize:
//                 MainAxisSize.min,

//             children: [

//               // NAME
//               TextField(
//                 controller: nameController,

//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 14,
//                 ),

//                 decoration:
//                     InputDecoration(
//                   labelText: 'Name',

//                   labelStyle:
//                       TextStyle(
//                     fontSize: 13,
//                     color:
//                         Colors.grey.shade600,
//                   ),

//                   filled: true,

//                   fillColor: detailBlue,

//                   border:
//                       OutlineInputBorder(
//                     borderRadius:
//                         BorderRadius.circular(
//                       10,
//                     ),

//                     borderSide:
//                         BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 11),

//               // PROFILE
//               TextField(
//                 controller: roleController,

//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 14,
//                 ),

//                 decoration:
//                     InputDecoration(
//                   labelText: 'Profile',

//                   labelStyle:
//                       TextStyle(
//                     fontSize: 13,
//                     color:
//                         Colors.grey.shade600,
//                   ),

//                   filled: true,

//                   fillColor: detailBlue,

//                   border:
//                       OutlineInputBorder(
//                     borderRadius:
//                         BorderRadius.circular(
//                       10,
//                     ),

//                     borderSide:
//                         BorderSide.none,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           actions: [

//             // CANCEL
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
//                   fontSize: 13,
//                 ),
//               ),
//             ),

//             // SAVE
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   if (nameController
//                       .text
//                       .trim()
//                       .isNotEmpty) {
//                     userName =
//                         nameController
//                             .text
//                             .trim();
//                   }

//                   if (roleController
//                       .text
//                       .trim()
//                       .isNotEmpty) {
//                     userRole =
//                         roleController
//                             .text
//                             .trim();
//                   }
//                 });

//                 Navigator.pop(
//                   dialogContext,
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
//                 'Save',
//                 style: TextStyle(
//                   fontSize: 13,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // LOGOUT CONFIRMATION
//   // ============================================================

//   void _showLogoutDialog() {
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
//             'Logout',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 19,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           content: Text(
//             'Are you sure you want to logout?',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 14,
//             ),
//           ),

//           actions: [

//             // CANCEL
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
//                   fontSize: 13,
//                 ),
//               ),
//             ),

//             // LOGOUT
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(
//                   dialogContext,
//                 );

//                 await _logout();
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
//                 'Logout',
//                 style: TextStyle(
//                   fontSize: 13,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // ACTUAL SUPABASE LOGOUT
//   // ============================================================

//   Future<void> _logout() async {
//     try {
//       // ========================================================
//       // SIGN OUT FROM SUPABASE
//       // ========================================================

//       await supabase.auth.signOut(
//         scope: SignOutScope.local,
//       );

//       // ========================================================
//       // CHECK WIDGET
//       // ========================================================

//       if (!mounted) {
//         return;
//       }

//       // ========================================================
//       // RETURN TO LOGIN
//       // ========================================================

//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder: (context) =>
//               const LoginScreen(),
//         ),
//         (route) => false,
//       );
//     }

//     // ==========================================================
//     // SUPABASE AUTH ERROR
//     // ==========================================================

//     on AuthException catch (error) {
//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Logout failed: ${error.message}',
//             style: const TextStyle(
//               fontSize: 13,
//             ),
//           ),

//           backgroundColor:
//               Colors.red.shade700,

//           behavior:
//               SnackBarBehavior.floating,
//         ),
//       );
//     }

//     // ==========================================================
//     // OTHER ERROR
//     // ==========================================================

//     catch (error) {
//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Logout failed: $error',
//             style: const TextStyle(
//               fontSize: 13,
//             ),
//           ),

//           backgroundColor:
//               Colors.red.shade700,

//           behavior:
//               SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // HELP DIALOG
//   // ============================================================

//   void _showHelpDialog() {
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
//             'Help & Support',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 19,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           content: Text(
//             'Need help with adoption, appointments, or your account? Our support team is here to help.',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 13,
//               height: 1.5,
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
//                 'Close',
//                 style: TextStyle(
//                   color: primaryColor,
//                   fontSize: 13,
//                   fontWeight:
//                       FontWeight.bold,
//                 ),
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

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(
//             fontSize: 13,
//           ),
//         ),

//         behavior:
//             SnackBarBehavior.floating,

//         duration:
//             const Duration(seconds: 2),
//       ),
//     );
//   }
// }





















// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'login_screen.dart';

// // ============================================================
// // PROFILE SCREEN
// // ============================================================

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({
//     super.key,
//   });

//   @override
//   State<ProfileScreen> createState() =>
//       _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color darkText = const Color(0xFF062B35);
//   final Color tealColor = const Color(0xFF008F82);

//   final Color detailBlue = const Color(0xFFEFF9FD);
//   final Color lightBlue = const Color(0xFFE4F5FB);

//   // ============================================================
//   // PROFILE DATA
//   // ============================================================

//   String userName = 'John Miares';
//   String userRole = 'Aspiring Pet Parent';

//   String profileImage =
//       'https://i.pravatar.cc/300?img=12';

//   // ============================================================
//   // SUPABASE
//   // ============================================================

//   final SupabaseClient supabase =
//       Supabase.instance.client;

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: detailBlue,
//       child: Column(
//         children: [

//           // ======================================================
//           // HEADER
//           // ======================================================

//           _buildHeader(),

//           // ======================================================
//           // SCROLLABLE CONTENT
//           // ======================================================

//           Expanded(
//             child: Container(
//               color: Colors.white,
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),

//                 padding: const EdgeInsets.fromLTRB(
//                   14,
//                   12,
//                   14,
//                   30,
//                 ),

//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,

//                   children: [

//                     // ==================================================
//                     // PROFILE CARD
//                     // ==================================================

//                     _buildProfileCard(),

//                     const SizedBox(height: 20),

//                     // ==================================================
//                     // MY ACTIVITY
//                     // ==================================================

//                     _buildSectionTitle(
//                       'My Activity',
//                     ),

//                     const SizedBox(height: 8),

//                     // APPLICATIONS
//                     _buildActivityCard(
//                       icon:
//                           Icons.description_outlined,
//                       iconColor: primaryColor,
//                       title: 'My Applications',
//                       trailing: 'Under Review',
//                       trailingColor: tealColor,
//                       onTap: () {
//                         _showMessage(
//                           'My Applications selected.',
//                         );
//                       },
//                     ),

//                     const SizedBox(height: 7),

//                     // SAVED PETS
//                     _buildActivityCard(
//                       icon:
//                           Icons.favorite_border_rounded,
//                       iconColor: primaryColor,
//                       title: 'Saved Pets',
//                       onTap: () {
//                         _showMessage(
//                           'Saved Pets selected.',
//                         );
//                       },
//                     ),

//                     const SizedBox(height: 7),

//                     // APPOINTMENTS
//                     _buildActivityCard(
//                       icon:
//                           Icons.calendar_month_outlined,
//                       iconColor: tealColor,
//                       title: 'My Appointments',
//                       onTap: () {
//                         _showMessage(
//                           'My Appointments selected.',
//                         );
//                       },
//                     ),

//                     const SizedBox(height: 20),

//                     // ==================================================
//                     // PET CARE REMINDERS
//                     // ==================================================

//                     _buildSectionTitle(
//                       'Pet Care Reminders',
//                       icon:
//                           Icons.notifications_active_outlined,
//                     ),

//                     const SizedBox(height: 8),

//                     _buildReminderCard(),

//                     const SizedBox(height: 20),

//                     // ==================================================
//                     // APP SETTINGS
//                     // ==================================================

//                     _buildSectionTitle(
//                       'App Settings',
//                       icon:
//                           Icons.settings_outlined,
//                     ),

//                     const SizedBox(height: 6),

//                     _buildSettingsCard(),

//                     const SizedBox(height: 20),

//                     // ==================================================
//                     // LOGOUT
//                     // ==================================================

//                     Center(
//                       child: TextButton.icon(
//                         onPressed:
//                             _showLogoutDialog,

//                         icon: Icon(
//                           Icons.logout_rounded,
//                           color: primaryColor,
//                           size: 13,
//                         ),

//                         label: Text(
//                           'Logout',
//                           style: TextStyle(
//                             color: primaryColor,
//                             fontSize: 10,
//                             fontWeight:
//                                 FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 10),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       height: 54,

//       padding: const EdgeInsets.symmetric(
//         horizontal: 14,
//       ),

//       color: detailBlue,

//       child: Row(
//         children: [

//           // ========================================================
//           // SMALL PROFILE IMAGE
//           // ========================================================

//           Container(
//             width: 30,
//             height: 30,

//             decoration: BoxDecoration(
//               shape: BoxShape.circle,

//               border: Border.all(
//                 color: Colors.white,
//                 width: 1,
//               ),
//             ),

//             child: ClipOval(
//               child: Image.network(
//                 profileImage,

//                 width: 30,
//                 height: 30,

//                 fit: BoxFit.cover,

//                 errorBuilder:
//                     (context, error, stackTrace) {
//                   return Container(
//                     color: lightBlue,

//                     child: Icon(
//                       Icons.person,
//                       size: 17,
//                       color: primaryColor,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),

//           const SizedBox(width: 9),

//           // ========================================================
//           // TITLE
//           // ========================================================

//           Text(
//             'Profile',
//             style: TextStyle(
//               color: primaryColor,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const Spacer(),

//           // ========================================================
//           // NOTIFICATION
//           // ========================================================

//           IconButton(
//             onPressed: () {
//               _showMessage(
//                 'No new notifications.',
//               );
//             },

//             padding: EdgeInsets.zero,

//             constraints:
//                 const BoxConstraints(
//               minWidth: 30,
//               minHeight: 30,
//             ),

//             icon: Icon(
//               Icons.notifications_none_rounded,
//               color: darkText,
//               size: 18,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PROFILE CARD
//   // ============================================================

//   Widget _buildProfileCard() {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.fromLTRB(
//         10,
//         14,
//         10,
//         16,
//       ),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(14),

//         border: Border.all(
//           color: Colors.grey.shade100,
//         ),

//         boxShadow: [
//           BoxShadow(
//             color:
//                 Colors.black.withOpacity(0.025),
//             blurRadius: 6,
//             offset:
//                 const Offset(0, 2),
//           ),
//         ],
//       ),

//       child: Column(
//         children: [

//           // ========================================================
//           // PROFILE PHOTO
//           // ========================================================

//           Container(
//             width: 92,
//             height: 92,

//             padding: const EdgeInsets.all(3),

//             decoration: BoxDecoration(
//               shape: BoxShape.circle,

//               color: Colors.white,

//               boxShadow: [
//                 BoxShadow(
//                   color:
//                       Colors.black.withOpacity(0.12),
//                   blurRadius: 9,
//                   offset:
//                       const Offset(0, 3),
//                 ),
//               ],
//             ),

//             child: ClipOval(
//               child: Image.network(
//                 profileImage,

//                 width: 86,
//                 height: 86,

//                 fit: BoxFit.cover,

//                 errorBuilder:
//                     (context, error, stackTrace) {
//                   return Container(
//                     color: lightBlue,

//                     child: Icon(
//                       Icons.person,
//                       size: 42,
//                       color: primaryColor,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),

//           const SizedBox(height: 10),

//           // ========================================================
//           // NAME
//           // ========================================================

//           Text(
//             userName,

//             textAlign: TextAlign.center,

//             maxLines: 1,

//             overflow:
//                 TextOverflow.ellipsis,

//             style: TextStyle(
//               color: darkText,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 3),

//           // ========================================================
//           // ROLE
//           // ========================================================

//           Text(
//             userRole,

//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: 11,
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ========================================================
//           // EDIT PROFILE
//           // ========================================================

//           OutlinedButton.icon(
//             onPressed:
//                 _showEditProfileDialog,

//             icon: Icon(
//               Icons.edit_outlined,
//               size: 12,
//               color: primaryColor,
//             ),

//             label: Text(
//               'Edit Profile',

//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 11,
//                 fontWeight:
//                     FontWeight.w500,
//               ),
//             ),

//             style:
//                 OutlinedButton.styleFrom(
//               padding:
//                   const EdgeInsets.symmetric(
//                 horizontal: 17,
//                 vertical: 7,
//               ),

//               minimumSize: Size.zero,

//               tapTargetSize:
//                   MaterialTapTargetSize
//                       .shrinkWrap,

//               side: BorderSide(
//                 color: primaryColor,
//                 width: 1.2,
//               ),

//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(20),
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

//   Widget _buildSectionTitle(
//     String title, {
//     IconData? icon,
//   }) {
//     return Row(
//       children: [

//         if (icon != null) ...[
//           Icon(
//             icon,
//             size: 12,
//             color: primaryColor,
//           ),

//           const SizedBox(width: 5),
//         ],

//         Text(
//           title,

//           style: TextStyle(
//             color: primaryColor,
//             fontSize: 12,
//             fontWeight:
//                 FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // ACTIVITY CARD
//   // ============================================================

//   Widget _buildActivityCard({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     String? trailing,
//     Color? trailingColor,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,

//       child: InkWell(
//         onTap: onTap,

//         borderRadius:
//             BorderRadius.circular(11),

//         child: Container(
//           width: double.infinity,

//           padding:
//               const EdgeInsets.symmetric(
//             horizontal: 10,
//             vertical: 10,
//           ),

//           decoration: BoxDecoration(
//             color:
//                 lightBlue.withOpacity(0.68),

//             borderRadius:
//                 BorderRadius.circular(11),
//           ),

//           child: Row(
//             children: [

//               // ==================================================
//               // ICON
//               // ==================================================

//               Container(
//                 width: 32,
//                 height: 32,

//                 decoration: BoxDecoration(
//                   color:
//                       iconColor.withOpacity(
//                     0.10,
//                   ),

//                   shape: BoxShape.circle,
//                 ),

//                 child: Icon(
//                   icon,
//                   size: 15,
//                   color: iconColor,
//                 ),
//               ),

//               const SizedBox(width: 10),

//               // ==================================================
//               // TITLE
//               // ==================================================

//               Expanded(
//                 child: Text(
//                   title,

//                   style: TextStyle(
//                     color: darkText,
//                     fontSize: 11,
//                     fontWeight:
//                         FontWeight.w500,
//                   ),
//                 ),
//               ),

//               // ==================================================
//               // STATUS
//               // ==================================================

//               if (trailing != null)
//                 Container(
//                   constraints:
//                       const BoxConstraints(
//                     maxWidth: 105,
//                   ),

//                   padding:
//                       const EdgeInsets
//                           .symmetric(
//                     horizontal: 9,
//                     vertical: 5,
//                   ),

//                   decoration:
//                       BoxDecoration(
//                     color:
//                         (trailingColor ??
//                                 tealColor)
//                             .withOpacity(
//                       0.10,
//                     ),

//                     borderRadius:
//                         BorderRadius.circular(
//                       14,
//                     ),
//                   ),

//                   child: Text(
//                     trailing,

//                     textAlign:
//                         TextAlign.center,

//                     maxLines: 2,

//                     overflow:
//                         TextOverflow.ellipsis,

//                     style: TextStyle(
//                       color:
//                           trailingColor ??
//                               tealColor,
//                       fontSize: 8,
//                       fontWeight:
//                           FontWeight.w600,
//                     ),
//                   ),
//                 ),

//               const SizedBox(width: 4),

//               Icon(
//                 Icons.chevron_right_rounded,
//                 size: 17,
//                 color:
//                     Colors.grey.shade400,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // REMINDER CARD
//   // ============================================================

//   Widget _buildReminderCard() {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.all(12),

//       decoration: BoxDecoration(
//         color:
//             const Color(0xFFF2FAF9),

//         borderRadius:
//             BorderRadius.circular(11),

//         border: Border.all(
//           color:
//               const Color(0xFFD5EAE7),
//         ),
//       ),

//       child: Row(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [

//           // ========================================================
//           // VACCINATION ICON
//           // ========================================================

//           Container(
//             width: 38,
//             height: 38,

//             decoration: BoxDecoration(
//               color: tealColor,
//               shape: BoxShape.circle,
//             ),

//             child: const Icon(
//               Icons.vaccines_outlined,
//               color: Colors.white,
//               size: 17,
//             ),
//           ),

//           const SizedBox(width: 11),

//           // ========================================================
//           // REMINDER INFORMATION
//           // ========================================================

//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: [

//                 Text(
//                   'Vaccination Due',

//                   style: TextStyle(
//                     color: darkText,
//                     fontSize: 12,
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 4),

//                 Text(
//                   'Fido’s annual booster is due in 2 days. Schedule an appointment soon.',

//                   style: TextStyle(
//                     color:
//                         Colors.grey.shade700,
//                     fontSize: 10,
//                     height: 1.4,
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 GestureDetector(
//                   onTap: () {
//                     _showMessage(
//                       'Schedule vaccination selected.',
//                     );
//                   },

//                   child: Text(
//                     'SCHEDULE NOW',

//                     style: TextStyle(
//                       color: tealColor,
//                       fontSize: 9,
//                       fontWeight:
//                           FontWeight.bold,
//                       letterSpacing: 0.2,
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
//   // SETTINGS CARD
//   // ============================================================

//   Widget _buildSettingsCard() {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.symmetric(
//         vertical: 5,
//       ),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(12),

//         border: Border.all(
//           color: Colors.grey.shade100,
//         ),

//         boxShadow: [
//           BoxShadow(
//             color:
//                 Colors.black.withOpacity(0.02),
//             blurRadius: 5,
//             offset:
//                 const Offset(0, 2),
//           ),
//         ],
//       ),

//       child: Column(
//         children: [

//           // ========================================================
//           // APP SETTINGS
//           // ========================================================

//           _buildSettingItem(
//             icon:
//                 Icons.settings_outlined,
//             title: 'App Settings',

//             onTap: () {
//               _showMessage(
//                 'App Settings selected.',
//               );
//             },
//           ),

//           // ========================================================
//           // NOTIFICATIONS
//           // ========================================================

//           _buildSettingItem(
//             icon:
//                 Icons.notifications_none_rounded,
//             title: 'Notifications',

//             onTap: () {
//               _showMessage(
//                 'Notifications settings selected.',
//               );
//             },
//           ),

//           // ========================================================
//           // PREFERENCES
//           // ========================================================

//           _buildSettingItem(
//             icon: Icons.tune_rounded,
//             title: 'Preferences',

//             onTap: () {
//               _showMessage(
//                 'Preferences selected.',
//               );
//             },
//           ),

//           // ========================================================
//           // HELP
//           // ========================================================

//           _buildSettingItem(
//             icon:
//                 Icons.help_outline_rounded,
//             title: 'Help & Support',

//             onTap: () {
//               _showHelpDialog();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SETTING ITEM
//   // ============================================================

//   Widget _buildSettingItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,

//       child: InkWell(
//         onTap: onTap,

//         child: Padding(
//           padding:
//               const EdgeInsets.symmetric(
//             horizontal: 12,
//             vertical: 12,
//           ),

//           child: Row(
//             children: [

//               // ==================================================
//               // ICON
//               // ==================================================

//               Icon(
//                 icon,
//                 size: 14,
//                 color: darkText,
//               ),

//               const SizedBox(width: 10),

//               // ==================================================
//               // TITLE
//               // ==================================================

//               Expanded(
//                 child: Text(
//                   title,

//                   style: TextStyle(
//                     color: darkText,
//                     fontSize: 11,
//                     fontWeight:
//                         FontWeight.w400,
//                   ),
//                 ),
//               ),

//               // ==================================================
//               // ARROW
//               // ==================================================

//               Icon(
//                 Icons.chevron_right_rounded,
//                 size: 16,
//                 color:
//                     Colors.grey.shade400,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EDIT PROFILE DIALOG
//   // ============================================================

//   void _showEditProfileDialog() {
//     final TextEditingController nameController =
//         TextEditingController(
//       text: userName,
//     );

//     final TextEditingController roleController =
//         TextEditingController(
//       text: userRole,
//     );

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
//             'Edit Profile',

//             style: TextStyle(
//               color: darkText,
//               fontSize: 18,
//               fontWeight:
//                   FontWeight.bold,
//             ),
//           ),

//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize:
//                   MainAxisSize.min,

//               children: [

//                 // ==================================================
//                 // NAME
//                 // ==================================================

//                 TextField(
//                   controller:
//                       nameController,

//                   textCapitalization:
//                       TextCapitalization.words,

//                   decoration:
//                       InputDecoration(
//                     labelText: 'Name',

//                     labelStyle: TextStyle(
//                       color:
//                           Colors.grey.shade600,
//                     ),

//                     filled: true,

//                     fillColor:
//                         detailBlue,

//                     border:
//                         OutlineInputBorder(
//                       borderRadius:
//                           BorderRadius.circular(
//                         10,
//                       ),

//                       borderSide:
//                           BorderSide.none,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // ==================================================
//                 // ROLE
//                 // ==================================================

//                 TextField(
//                   controller:
//                       roleController,

//                   decoration:
//                       InputDecoration(
//                     labelText: 'Profile',

//                     labelStyle: TextStyle(
//                       color:
//                           Colors.grey.shade600,
//                     ),

//                     filled: true,

//                     fillColor:
//                         detailBlue,

//                     border:
//                         OutlineInputBorder(
//                       borderRadius:
//                           BorderRadius.circular(
//                         10,
//                       ),

//                       borderSide:
//                           BorderSide.none,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           actions: [

//             // ==================================================
//             // CANCEL
//             // ==================================================

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

//             // ==================================================
//             // SAVE
//             // ==================================================

//             ElevatedButton(
//               onPressed: () {
//                 final String newName =
//                     nameController.text
//                         .trim();

//                 final String newRole =
//                     roleController.text
//                         .trim();

//                 setState(() {
//                   if (newName.isNotEmpty) {
//                     userName = newName;
//                   }

//                   if (newRole.isNotEmpty) {
//                     userRole = newRole;
//                   }
//                 });

//                 Navigator.pop(
//                   dialogContext,
//                 );

//                 _showMessage(
//                   'Profile updated successfully.',
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
//                   const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // LOGOUT DIALOG
//   // ============================================================

//   void _showLogoutDialog() {
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
//             'Logout',

//             style: TextStyle(
//               color: darkText,
//               fontSize: 18,
//               fontWeight:
//                   FontWeight.bold,
//             ),
//           ),

//           content: const Text(
//             'Are you sure you want to logout?',

//             style: TextStyle(
//               fontSize: 13,
//             ),
//           ),

//           actions: [

//             // ==================================================
//             // CANCEL
//             // ==================================================

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

//             // ==================================================
//             // LOGOUT
//             // ==================================================

//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(
//                   dialogContext,
//                 );

//                 await _logout();
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
//                   const Text('Logout'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // SUPABASE LOGOUT
//   // ============================================================

//   Future<void> _logout() async {
//     try {
//       // ========================================================
//       // SIGN OUT
//       // ========================================================

//       await supabase.auth.signOut(
//         scope: SignOutScope.local,
//       );

//       // ========================================================
//       // CHECK WIDGET
//       // ========================================================

//       if (!mounted) {
//         return;
//       }

//       // ========================================================
//       // RETURN TO LOGIN
//       // ========================================================

//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder: (context) =>
//               const LoginScreen(),
//         ),
//         (route) => false,
//       );
//     } on AuthException catch (error) {
//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(context)
//           .hideCurrentSnackBar();

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Logout failed: ${error.message}',
//           ),

//           backgroundColor:
//               Colors.red.shade700,

//           behavior:
//               SnackBarBehavior.floating,
//         ),
//       );
//     } catch (error) {
//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(context)
//           .hideCurrentSnackBar();

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Logout failed: $error',
//           ),

//           backgroundColor:
//               Colors.red.shade700,

//           behavior:
//               SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // HELP DIALOG
//   // ============================================================

//   void _showHelpDialog() {
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
//             'Help & Support',

//             style: TextStyle(
//               color: darkText,
//               fontWeight:
//                   FontWeight.bold,
//             ),
//           ),

//           content: const Text(
//             'Need help with adoption, appointments, or your account? Our support team is here to help.',

//             style: TextStyle(
//               fontSize: 12,
//               height: 1.5,
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
//                 'Close',

//                 style: TextStyle(
//                   color: primaryColor,
//                   fontWeight:
//                       FontWeight.bold,
//                 ),
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
//     if (!mounted) {
//       return;
//     }

//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(
//           message,

//           style: const TextStyle(
//             fontSize: 12,
//           ),
//         ),

//         behavior:
//             SnackBarBehavior.floating,

//         duration:
//             const Duration(seconds: 2),
//       ),
//     );
//   }
// }

















// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'login_screen.dart';

// // ============================================================
// // PROFILE SCREEN
// // ============================================================

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({
//     super.key,
//   });

//   @override
//   State<ProfileScreen> createState() =>
//       _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
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
//   // PROFILE DATA
//   // ============================================================

//   String userName = 'John Miares';
//   String userRole = 'Aspiring Pet Parent';

//   String profileImage =
//       'https://i.pravatar.cc/300?img=12';

//   // ============================================================
//   // SUPABASE CLIENT
//   // ============================================================

//   final SupabaseClient supabase =
//       Supabase.instance.client;

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: detailBrown,

//       body: SafeArea(
//         child: Column(
//           children: [

//             // ==================================================
//             // TOP HEADER
//             // ==================================================

//             Container(
//               color: detailBlue,

//               padding: const EdgeInsets.fromLTRB(
//                 12,
//                 8,
//                 12,
//                 8,
//               ),

//               child: Row(
//                 children: [

//                   // PROFILE IMAGE
//                   ClipOval(
//                     child: Image.network(
//                       profileImage,

//                       width: 27,
//                       height: 27,

//                       fit: BoxFit.cover,

//                       errorBuilder:
//                           (context, error, stackTrace) {
//                         return Container(
//                           width: 27,
//                           height: 27,
//                           color: lightBlue,

//                           child: Icon(
//                             Icons.person,
//                             size: 16,
//                             color: primaryColor,
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   const SizedBox(width: 7),

//                   // TITLE
//                   Text(
//                     'Profile',
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const Spacer(),

//                   // NOTIFICATION
//                   Icon(
//                     Icons.notifications_none,
//                     size: 16,
//                     color: darkText,
//                   ),
//                 ],
//               ),
//             ),

//             // ==================================================
//             // PROFILE CONTENT
//             // ==================================================

//             Expanded(
//               child: Container(
//                 color: Colors.white,

//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.fromLTRB(
//                     14,
//                     12,
//                     14,
//                     30,
//                   ),

//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,

//                     children: [

//                       // ==================================================
//                       // PROFILE CARD
//                       // ==================================================

//                       _buildProfileCard(),

//                       const SizedBox(height: 20),

//                       // ==================================================
//                       // MY ACTIVITY
//                       // ==================================================

//                       _buildSectionTitle(
//                         'My Activity',
//                       ),

//                       const SizedBox(height: 8),

//                       _buildActivityCard(
//                         icon:
//                             Icons.description_outlined,
//                         iconColor: primaryColor,
//                         title:
//                             'My Applications',
//                         trailing:
//                             'Under Review',
//                         trailingColor: tealColor,

//                         onTap: () {
//                           _showMessage(
//                             'My Applications selected.',
//                           );
//                         },
//                       ),

//                       const SizedBox(height: 7),

//                       _buildActivityCard(
//                         icon:
//                             Icons.favorite_border,
//                         iconColor: primaryColor,
//                         title: 'Saved Pets',

//                         onTap: () {
//                           _showMessage(
//                             'Saved Pets selected.',
//                           );
//                         },
//                       ),

//                       const SizedBox(height: 7),

//                       _buildActivityCard(
//                         icon:
//                             Icons.calendar_month_outlined,
//                         iconColor: tealColor,
//                         title:
//                             'My Appointments',

//                         onTap: () {
//                           _showMessage(
//                             'My Appointments selected.',
//                           );
//                         },
//                       ),

//                       const SizedBox(height: 20),

//                       // ==================================================
//                       // PET CARE REMINDERS
//                       // ==================================================

//                       _buildSectionTitle(
//                         'Pet Care Reminders',
//                         icon: Icons
//                             .notifications_active_outlined,
//                       ),

//                       const SizedBox(height: 8),

//                       _buildReminderCard(),

//                       const SizedBox(height: 20),

//                       // ==================================================
//                       // APP SETTINGS
//                       // ==================================================

//                       _buildSectionTitle(
//                         'App Settings',
//                         icon:
//                             Icons.settings_outlined,
//                       ),

//                       const SizedBox(height: 6),

//                       _buildSettingsCard(),

//                       const SizedBox(height: 20),

//                       // ==================================================
//                       // LOGOUT
//                       // ==================================================

//                       Center(
//                         child: TextButton.icon(
//                           onPressed:
//                               _showLogoutDialog,

//                           icon: Icon(
//                             Icons.logout,
//                             color: primaryColor,
//                             size: 13,
//                           ),

//                           label: Text(
//                             'Logout',
//                             style: TextStyle(
//                               color: primaryColor,
//                               fontSize: 10,
//                               fontWeight:
//                                   FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PROFILE CARD
//   // ============================================================

//   Widget _buildProfileCard() {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.fromLTRB(
//         10,
//         8,
//         10,
//         12,
//       ),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(12),

//         border: Border.all(
//           color: Colors.grey.shade100,
//         ),
//       ),

//       child: Column(
//         children: [

//           // PROFILE IMAGE
//           Container(
//             width: 65,
//             height: 65,

//             decoration: BoxDecoration(
//               shape: BoxShape.circle,

//               border: Border.all(
//                 color: Colors.white,
//                 width: 3,
//               ),

//               boxShadow: [
//                 BoxShadow(
//                   color:
//                       Colors.black.withOpacity(
//                     0.12,
//                   ),

//                   blurRadius: 8,

//                   offset:
//                       const Offset(0, 3),
//                 ),
//               ],
//             ),

//             child: ClipOval(
//               child: Image.network(
//                 profileImage,

//                 fit: BoxFit.cover,

//                 errorBuilder:
//                     (context, error, stackTrace) {
//                   return Container(
//                     color: lightBlue,

//                     child: Icon(
//                       Icons.person,
//                       size: 32,
//                       color: primaryColor,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),

//           const SizedBox(height: 8),

//           // NAME
//           Text(
//             userName,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 2),

//           // ROLE
//           Text(
//             userRole,
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: 8,
//             ),
//           ),

//           const SizedBox(height: 9),

//           // EDIT PROFILE
//           OutlinedButton.icon(
//             onPressed:
//                 _showEditProfileDialog,

//             icon: Icon(
//               Icons.edit_outlined,
//               size: 11,
//               color: primaryColor,
//             ),

//             label: Text(
//               'Edit Profile',
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 9,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),

//             style:
//                 OutlinedButton.styleFrom(
//               padding:
//                   const EdgeInsets.symmetric(
//                 horizontal: 12,
//                 vertical: 5,
//               ),

//               minimumSize: Size.zero,

//               tapTargetSize:
//                   MaterialTapTargetSize
//                       .shrinkWrap,

//               side: BorderSide(
//                 color: primaryColor,
//               ),

//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(16),
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

//   Widget _buildSectionTitle(
//     String title, {
//     IconData? icon,
//   }) {
//     return Row(
//       children: [

//         if (icon != null) ...[
//           Icon(
//             icon,
//             size: 11,
//             color: primaryColor,
//           ),

//           const SizedBox(width: 4),
//         ],

//         Text(
//           title,
//           style: TextStyle(
//             color: primaryColor,
//             fontSize: 9,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // ACTIVITY CARD
//   // ============================================================

//   Widget _buildActivityCard({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     String? trailing,
//     Color? trailingColor,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,

//       child: Container(
//         width: double.infinity,

//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 8,
//           vertical: 8,
//         ),

//         decoration: BoxDecoration(
//           color:
//               lightBlue.withOpacity(0.65),

//           borderRadius:
//               BorderRadius.circular(8),
//         ),

//         child: Row(
//           children: [

//             // ICON
//             Container(
//               width: 25,
//               height: 25,

//               decoration: BoxDecoration(
//                 color:
//                     iconColor.withOpacity(
//                   0.10,
//                 ),

//                 shape: BoxShape.circle,
//               ),

//               child: Icon(
//                 icon,
//                 size: 12,
//                 color: iconColor,
//               ),
//             ),

//             const SizedBox(width: 9),

//             // TITLE
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 8,
//                   fontWeight:
//                       FontWeight.w500,
//                 ),
//               ),
//             ),

//             // STATUS
//             if (trailing != null)
//               Container(
//                 padding:
//                     const EdgeInsets
//                         .symmetric(
//                   horizontal: 7,
//                   vertical: 3,
//                 ),

//                 decoration:
//                     BoxDecoration(
//                   color:
//                       (trailingColor ??
//                               tealColor)
//                           .withOpacity(
//                     0.10,
//                   ),

//                   borderRadius:
//                       BorderRadius.circular(
//                     10,
//                   ),
//                 ),

//                 child: Text(
//                   trailing,
//                   style: TextStyle(
//                     color:
//                         trailingColor ??
//                             tealColor,
//                     fontSize: 7,
//                     fontWeight:
//                         FontWeight.w600,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // REMINDER CARD
//   // ============================================================

//   Widget _buildReminderCard() {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.all(10),

//       decoration: BoxDecoration(
//         color: const Color(0xFFF2FAF9),

//         borderRadius:
//             BorderRadius.circular(9),

//         border: Border.all(
//           color: const Color(0xFFD5EAE7),
//         ),
//       ),

//       child: Row(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [

//           Container(
//             width: 27,
//             height: 27,

//             decoration: BoxDecoration(
//               color: tealColor,
//               shape: BoxShape.circle,
//             ),

//             child: const Icon(
//               Icons.vaccines_outlined,
//               color: Colors.white,
//               size: 13,
//             ),
//           ),

//           const SizedBox(width: 9),

//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: [

//                 Text(
//                   'Vaccination Due',
//                   style: TextStyle(
//                     color: darkText,
//                     fontSize: 9,
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 3),

//                 Text(
//                   'Fido’s annual booster is due in 2 days. Schedule an appointment soon.',
//                   style: TextStyle(
//                     color:
//                         Colors.grey.shade700,
//                     fontSize: 7,
//                     height: 1.4,
//                   ),
//                 ),

//                 const SizedBox(height: 5),

//                 GestureDetector(
//                   onTap: () {
//                     _showMessage(
//                       'Schedule vaccination selected.',
//                     );
//                   },

//                   child: Text(
//                     'SCHEDULE NOW',
//                     style: TextStyle(
//                       color: tealColor,
//                       fontSize: 7,
//                       fontWeight:
//                           FontWeight.bold,
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
//   // SETTINGS CARD
//   // ============================================================

//   Widget _buildSettingsCard() {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.symmetric(
//         vertical: 5,
//       ),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(10),

//         border: Border.all(
//           color: Colors.grey.shade100,
//         ),
//       ),

//       child: Column(
//         children: [

//           _buildSettingItem(
//             icon: Icons.notifications_none,
//             title: 'Notifications',

//             onTap: () {
//               _showMessage(
//                 'Notifications settings selected.',
//               );
//             },
//           ),

//           _buildSettingItem(
//             icon: Icons.tune,
//             title: 'Preferences',

//             onTap: () {
//               _showMessage(
//                 'Preferences selected.',
//               );
//             },
//           ),

//           _buildSettingItem(
//             icon: Icons.help_outline,
//             title: 'Help & Support',

//             onTap: () {
//               _showHelpDialog();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SETTING ITEM
//   // ============================================================

//   Widget _buildSettingItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,

//       child: Padding(
//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 8,
//           vertical: 8,
//         ),

//         child: Row(
//           children: [

//             Icon(
//               icon,
//               size: 11,
//               color: darkText,
//             ),

//             const SizedBox(width: 8),

//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 8,
//                 ),
//               ),
//             ),

//             Icon(
//               Icons.chevron_right,
//               size: 13,
//               color: Colors.grey.shade400,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EDIT PROFILE
//   // ============================================================

//   void _showEditProfileDialog() {
//     final nameController =
//         TextEditingController(
//       text: userName,
//     );

//     final roleController =
//         TextEditingController(
//       text: userRole,
//     );

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
//             'Edit Profile',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 17,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           content: Column(
//             mainAxisSize:
//                 MainAxisSize.min,

//             children: [

//               TextField(
//                 controller: nameController,

//                 decoration:
//                     InputDecoration(
//                   labelText: 'Name',

//                   filled: true,

//                   fillColor: detailBlue,

//                   border:
//                       OutlineInputBorder(
//                     borderRadius:
//                         BorderRadius.circular(
//                       10,
//                     ),

//                     borderSide:
//                         BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 10),

//               TextField(
//                 controller: roleController,

//                 decoration:
//                     InputDecoration(
//                   labelText: 'Profile',

//                   filled: true,

//                   fillColor: detailBlue,

//                   border:
//                       OutlineInputBorder(
//                     borderRadius:
//                         BorderRadius.circular(
//                       10,
//                     ),

//                     borderSide:
//                         BorderSide.none,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           actions: [

//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                 );
//               },

//               child: const Text(
//                 'Cancel',
//               ),
//             ),

//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   if (nameController
//                       .text
//                       .trim()
//                       .isNotEmpty) {
//                     userName =
//                         nameController
//                             .text
//                             .trim();
//                   }

//                   if (roleController
//                       .text
//                       .trim()
//                       .isNotEmpty) {
//                     userRole =
//                         roleController
//                             .text
//                             .trim();
//                   }
//                 });

//                 Navigator.pop(
//                   dialogContext,
//                 );
//               },

//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     primaryColor,

//                 foregroundColor:
//                     Colors.white,

//                 elevation: 0,
//               ),

//               child:
//                   const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // LOGOUT CONFIRMATION
//   // ============================================================

//   void _showLogoutDialog() {
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
//             'Logout',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           content: const Text(
//             'Are you sure you want to logout?',
//             style: TextStyle(
//               fontSize: 13,
//             ),
//           ),

//           actions: [

//             // CANCEL
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

//             // LOGOUT
//             ElevatedButton(
//               onPressed: () async {
//                 // Close confirmation dialog
//                 Navigator.pop(
//                   dialogContext,
//                 );

//                 // Perform actual Supabase logout
//                 await _logout();
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
//                   const Text('Logout'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // ACTUAL SUPABASE LOGOUT
//   // ============================================================

//   Future<void> _logout() async {
//     try {
//       // ========================================================
//       // SIGN OUT FROM SUPABASE
//       // ========================================================

//       await supabase.auth.signOut(
//         scope: SignOutScope.local,
//       );

//       // ========================================================
//       // CHECK THAT WIDGET STILL EXISTS
//       // ========================================================

//       if (!mounted) {
//         return;
//       }

//       // ========================================================
//       // REMOVE ALL PREVIOUS ROUTES
//       // AND RETURN TO LOGIN SCREEN
//       // ========================================================

//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder: (context) =>
//               const LoginScreen(),
//         ),
//         (route) => false,
//       );
//     } on AuthException catch (error) {
//       // ========================================================
//       // SUPABASE AUTH ERROR
//       // ========================================================

//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Logout failed: ${error.message}',
//           ),

//           backgroundColor:
//               Colors.red.shade700,

//           behavior:
//               SnackBarBehavior.floating,
//         ),
//       );
//     } catch (error) {
//       // ========================================================
//       // OTHER ERROR
//       // ========================================================

//       if (!mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Logout failed: $error',
//           ),

//           backgroundColor:
//               Colors.red.shade700,

//           behavior:
//               SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // HELP DIALOG
//   // ============================================================

//   void _showHelpDialog() {
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
//             'Help & Support',
//             style: TextStyle(
//               color: darkText,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           content: const Text(
//             'Need help with adoption, appointments, or your account? Our support team is here to help.',
//             style: TextStyle(
//               fontSize: 12,
//               height: 1.5,
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
//                 'Close',
//                 style: TextStyle(
//                   color: primaryColor,
//                   fontWeight:
//                       FontWeight.bold,
//                 ),
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
//         .showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(
//             fontSize: 12,
//           ),
//         ),

//         behavior:
//             SnackBarBehavior.floating,
//       ),
//     );
//   }
// }












// import 'package:flutter/material.dart';

// // ============================================================
// // PROFILE SCREEN
// // ============================================================

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({
//     super.key,
//   });

//   @override
//   State<ProfileScreen> createState() =>
//       _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
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
//   // PROFILE INFORMATION
//   // ============================================================

//   String userName = 'John Miares';
//   String userRole = 'Aspiring Pet Parent';

//   String profileImage =
//       'https://i.pravatar.cc/300?img=12';

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: detailBrown,

//       body: SafeArea(
//         child: Column(
//           children: [

//             // ==================================================
//             // TOP HEADER
//             // ==================================================

//             Container(
//               color: detailBlue,

//               padding: const EdgeInsets.fromLTRB(
//                 12,
//                 8,
//                 12,
//                 8,
//               ),

//               child: Row(
//                 children: [

//                   // SMALL PROFILE IMAGE
//                   ClipOval(
//                     child: Image.network(
//                       profileImage,
//                       width: 27,
//                       height: 27,
//                       fit: BoxFit.cover,

//                       errorBuilder:
//                           (context, error, stackTrace) {
//                         return Container(
//                           width: 27,
//                           height: 27,
//                           color: lightBlue,
//                           child: Icon(
//                             Icons.person,
//                             size: 16,
//                             color: primaryColor,
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   const SizedBox(width: 7),

//                   Text(
//                     'Profile',
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const Spacer(),

//                   Icon(
//                     Icons.notifications_none,
//                     size: 16,
//                     color: darkText,
//                   ),
//                 ],
//               ),
//             ),

//             // ==================================================
//             // PROFILE CONTENT
//             // ==================================================

//             Expanded(
//               child: Container(
//                 color: Colors.white,

//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.fromLTRB(
//                     14,
//                     12,
//                     14,
//                     30,
//                   ),

//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,

//                     children: [

//                       // ==================================================
//                       // PROFILE CARD
//                       // ==================================================

//                       _buildProfileCard(),

//                       const SizedBox(height: 20),

//                       // ==================================================
//                       // MY ACTIVITY
//                       // ==================================================

//                       _buildSectionTitle(
//                         'My Activity',
//                       ),

//                       const SizedBox(height: 8),

//                       _buildActivityCard(
//                         icon: Icons.description_outlined,
//                         iconColor: primaryColor,
//                         title: 'My Applications',
//                         trailing: 'Under Review',
//                         trailingColor: tealColor,
//                         onTap: () {
//                           _showMessage(
//                             'My Applications selected.',
//                           );
//                         },
//                       ),

//                       const SizedBox(height: 7),

//                       _buildActivityCard(
//                         icon: Icons.favorite_border,
//                         iconColor: primaryColor,
//                         title: 'Saved Pets',
//                         onTap: () {
//                           _showMessage(
//                             'Saved Pets selected.',
//                           );
//                         },
//                       ),

//                       const SizedBox(height: 7),

//                       _buildActivityCard(
//                         icon: Icons.calendar_month_outlined,
//                         iconColor: tealColor,
//                         title: 'My Appointments',
//                         onTap: () {
//                           _showMessage(
//                             'My Appointments selected.',
//                           );
//                         },
//                       ),

//                       const SizedBox(height: 20),

//                       // ==================================================
//                       // PET CARE REMINDERS
//                       // ==================================================

//                       _buildSectionTitle(
//                         'Pet Care Reminders',
//                         icon: Icons
//                             .notifications_active_outlined,
//                       ),

//                       const SizedBox(height: 8),

//                       _buildReminderCard(),

//                       const SizedBox(height: 20),

//                       // ==================================================
//                       // APP SETTINGS
//                       // ==================================================

//                       _buildSectionTitle(
//                         'App Settings',
//                         icon: Icons.settings_outlined,
//                       ),

//                       const SizedBox(height: 6),

//                       _buildSettingsCard(),

//                       const SizedBox(height: 20),

//                       // ==================================================
//                       // LOGOUT
//                       // ==================================================

//                       Center(
//                         child: TextButton.icon(
//                           onPressed: () {
//                             _showLogoutDialog();
//                           },

//                           icon: Icon(
//                             Icons.logout,
//                             color: primaryColor,
//                             size: 13,
//                           ),

//                           label: Text(
//                             'Logout',
//                             style: TextStyle(
//                               color: primaryColor,
//                               fontSize: 10,
//                               fontWeight:
//                                   FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PROFILE CARD
//   // ============================================================

//   Widget _buildProfileCard() {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.fromLTRB(
//         10,
//         8,
//         10,
//         12,
//       ),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(12),

//         border: Border.all(
//           color: Colors.grey.shade100,
//         ),
//       ),

//       child: Column(
//         children: [

//           // ==================================================
//           // PROFILE IMAGE
//           // ==================================================

//           Container(
//             width: 65,
//             height: 65,

//             decoration: BoxDecoration(
//               shape: BoxShape.circle,

//               border: Border.all(
//                 color: Colors.white,
//                 width: 3,
//               ),

//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(
//                     0.12,
//                   ),
//                   blurRadius: 8,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),

//             child: ClipOval(
//               child: Image.network(
//                 profileImage,

//                 fit: BoxFit.cover,

//                 errorBuilder:
//                     (context, error, stackTrace) {
//                   return Container(
//                     color: lightBlue,

//                     child: Icon(
//                       Icons.person,
//                       size: 32,
//                       color: primaryColor,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),

//           const SizedBox(height: 8),

//           // ==================================================
//           // NAME
//           // ==================================================

//           Text(
//             userName,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 2),

//           // ==================================================
//           // ROLE
//           // ==================================================

//           Text(
//             userRole,
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: 8,
//             ),
//           ),

//           const SizedBox(height: 9),

//           // ==================================================
//           // EDIT PROFILE BUTTON
//           // ==================================================

//           OutlinedButton.icon(
//             onPressed: () {
//               _showEditProfileDialog();
//             },

//             icon: Icon(
//               Icons.edit_outlined,
//               size: 11,
//               color: primaryColor,
//             ),

//             label: Text(
//               'Edit Profile',
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 9,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),

//             style: OutlinedButton.styleFrom(
//               padding:
//                   const EdgeInsets.symmetric(
//                 horizontal: 12,
//                 vertical: 5,
//               ),

//               minimumSize: Size.zero,

//               tapTargetSize:
//                   MaterialTapTargetSize
//                       .shrinkWrap,

//               side: BorderSide(
//                 color: primaryColor,
//               ),

//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(16),
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

//   Widget _buildSectionTitle(
//     String title, {
//     IconData? icon,
//   }) {
//     return Row(
//       children: [

//         if (icon != null) ...[
//           Icon(
//             icon,
//             size: 11,
//             color: primaryColor,
//           ),

//           const SizedBox(width: 4),
//         ],

//         Text(
//           title,
//           style: TextStyle(
//             color: primaryColor,
//             fontSize: 9,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // ACTIVITY CARD
//   // ============================================================

//   Widget _buildActivityCard({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     String? trailing,
//     Color? trailingColor,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,

//       child: Container(
//         width: double.infinity,

//         padding: const EdgeInsets.symmetric(
//           horizontal: 8,
//           vertical: 8,
//         ),

//         decoration: BoxDecoration(
//           color: lightBlue.withOpacity(0.65),

//           borderRadius:
//               BorderRadius.circular(8),
//         ),

//         child: Row(
//           children: [

//             // ICON
//             Container(
//               width: 25,
//               height: 25,

//               decoration: BoxDecoration(
//                 color: iconColor.withOpacity(
//                   0.10,
//                 ),

//                 shape: BoxShape.circle,
//               ),

//               child: Icon(
//                 icon,
//                 size: 12,
//                 color: iconColor,
//               ),
//             ),

//             const SizedBox(width: 9),

//             // TITLE
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 8,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),

//             // STATUS
//             if (trailing != null)
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(
//                   horizontal: 7,
//                   vertical: 3,
//                 ),

//                 decoration: BoxDecoration(
//                   color: (trailingColor ??
//                           tealColor)
//                       .withOpacity(0.10),

//                   borderRadius:
//                       BorderRadius.circular(
//                     10,
//                   ),
//                 ),

//                 child: Text(
//                   trailing,
//                   style: TextStyle(
//                     color:
//                         trailingColor ??
//                             tealColor,
//                     fontSize: 7,
//                     fontWeight:
//                         FontWeight.w600,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // REMINDER CARD
//   // ============================================================

//   Widget _buildReminderCard() {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.all(10),

//       decoration: BoxDecoration(
//         color: const Color(0xFFF2FAF9),

//         borderRadius:
//             BorderRadius.circular(9),

//         border: Border.all(
//           color: const Color(0xFFD5EAE7),
//         ),
//       ),

//       child: Row(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [

//           // ==================================================
//           // REMINDER ICON
//           // ==================================================

//           Container(
//             width: 27,
//             height: 27,

//             decoration: BoxDecoration(
//               color: tealColor,
//               shape: BoxShape.circle,
//             ),

//             child: const Icon(
//               Icons.vaccines_outlined,
//               color: Colors.white,
//               size: 13,
//             ),
//           ),

//           const SizedBox(width: 9),

//           // ==================================================
//           // REMINDER CONTENT
//           // ==================================================

//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: [

//                 Text(
//                   'Vaccination Due',
//                   style: TextStyle(
//                     color: darkText,
//                     fontSize: 9,
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 3),

//                 Text(
//                   'Fido’s annual booster is due in 2 days. Schedule an appointment soon.',
//                   style: TextStyle(
//                     color:
//                         Colors.grey.shade700,
//                     fontSize: 7,
//                     height: 1.4,
//                   ),
//                 ),

//                 const SizedBox(height: 5),

//                 GestureDetector(
//                   onTap: () {
//                     _showMessage(
//                       'Schedule vaccination selected.',
//                     );
//                   },

//                   child: Text(
//                     'SCHEDULE NOW',
//                     style: TextStyle(
//                       color: tealColor,
//                       fontSize: 7,
//                       fontWeight:
//                           FontWeight.bold,
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
//   // SETTINGS CARD
//   // ============================================================

//   Widget _buildSettingsCard() {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.symmetric(
//         vertical: 5,
//       ),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(10),

//         border: Border.all(
//           color: Colors.grey.shade100,
//         ),
//       ),

//       child: Column(
//         children: [

//           _buildSettingItem(
//             icon: Icons.notifications_none,
//             title: 'Notifications',
//             onTap: () {
//               _showMessage(
//                 'Notifications settings selected.',
//               );
//             },
//           ),

//           _buildSettingItem(
//             icon: Icons.tune,
//             title: 'Preferences',
//             onTap: () {
//               _showMessage(
//                 'Preferences selected.',
//               );
//             },
//           ),

//           _buildSettingItem(
//             icon: Icons.help_outline,
//             title: 'Help & Support',
//             onTap: () {
//               _showHelpDialog();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SETTING ITEM
//   // ============================================================

//   Widget _buildSettingItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,

//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 8,
//           vertical: 8,
//         ),

//         child: Row(
//           children: [

//             Icon(
//               icon,
//               size: 11,
//               color: darkText,
//             ),

//             const SizedBox(width: 8),

//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 8,
//                 ),
//               ),
//             ),

//             Icon(
//               Icons.chevron_right,
//               size: 13,
//               color: Colors.grey.shade400,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EDIT PROFILE DIALOG
//   // ============================================================

//   void _showEditProfileDialog() {
//     final nameController =
//         TextEditingController(
//       text: userName,
//     );

//     final roleController =
//         TextEditingController(
//       text: userRole,
//     );

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
//             'Edit Profile',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 17,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           content: Column(
//             mainAxisSize:
//                 MainAxisSize.min,

//             children: [

//               // NAME
//               TextField(
//                 controller: nameController,

//                 decoration:
//                     InputDecoration(
//                   labelText: 'Name',

//                   labelStyle: TextStyle(
//                     fontSize: 11,
//                     color:
//                         Colors.grey.shade600,
//                   ),

//                   filled: true,

//                   fillColor: detailBlue,

//                   border:
//                       OutlineInputBorder(
//                     borderRadius:
//                         BorderRadius.circular(
//                       10,
//                     ),

//                     borderSide:
//                         BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 10),

//               // ROLE
//               TextField(
//                 controller: roleController,

//                 decoration:
//                     InputDecoration(
//                   labelText: 'Profile',

//                   labelStyle: TextStyle(
//                     fontSize: 11,
//                     color:
//                         Colors.grey.shade600,
//                   ),

//                   filled: true,

//                   fillColor: detailBlue,

//                   border:
//                       OutlineInputBorder(
//                     borderRadius:
//                         BorderRadius.circular(
//                       10,
//                     ),

//                     borderSide:
//                         BorderSide.none,
//                   ),
//                 ),
//               ),
//             ],
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
//                 setState(() {
//                   userName =
//                       nameController.text
//                           .trim()
//                           .isEmpty
//                       ? userName
//                       : nameController.text
//                           .trim();

//                   userRole =
//                       roleController.text
//                           .trim()
//                           .isEmpty
//                       ? userRole
//                       : roleController.text
//                           .trim();
//                 });

//                 Navigator.pop(
//                   dialogContext,
//                 );
//               },

//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     primaryColor,

//                 foregroundColor:
//                     Colors.white,

//                 elevation: 0,
//               ),

//               child: const Text(
//                 'Save',
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // LOGOUT DIALOG
//   // ============================================================

//   void _showLogoutDialog() {
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
//             'Logout',
//             style: TextStyle(
//               color: darkText,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           content: const Text(
//             'Are you sure you want to logout?',
//             style: TextStyle(
//               fontSize: 13,
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
//                 Navigator.pop(
//                   dialogContext,
//                 );

//                 _showMessage(
//                   'Logged out successfully.',
//                 );
//               },

//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     primaryColor,

//                 foregroundColor:
//                     Colors.white,

//                 elevation: 0,
//               ),

//               child: const Text(
//                 'Logout',
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // HELP DIALOG
//   // ============================================================

//   void _showHelpDialog() {
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
//             'Help & Support',
//             style: TextStyle(
//               color: darkText,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           content: const Text(
//             'Need help with adoption, appointments, or your account? Our support team is here to help.',
//             style: TextStyle(
//               fontSize: 12,
//               height: 1.5,
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
//                 'Close',
//                 style: TextStyle(
//                   color: primaryColor,
//                   fontWeight:
//                       FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // SHOW MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(
//             fontSize: 12,
//           ),
//         ),

//         behavior:
//             SnackBarBehavior.floating,
//       ),
//     );
//   }
// }











// import 'package:flutter/material.dart';

// import '../services/auth_service.dart';
// import 'login_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final Color primaryColor = const Color(0xFFA94327);
//   final Color backgroundColor = const Color(0xFFF5FAFD);
//   final Color darkText = const Color(0xFF062B35);

//   @override
//   Widget build(BuildContext context) {
//     final user = AuthService().currentUser;

//     final String displayName =
//         user?.userMetadata?['name']?.toString() ??
//             user?.email?.split('@').first ??
//             'Pet Lover';

//     return Scaffold(
//       backgroundColor: backgroundColor,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: false,
//         title: Text(
//           'Profile',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(25),
//         child: Column(
//           children: [
//             const SizedBox(height: 30),

//             // PROFILE IMAGE
//             const CircleAvatar(
//               radius: 48,
//               backgroundColor: Color(0xFFE5F5FD),
//               child: Icon(
//                 Icons.person,
//                 size: 50,
//                 color: Color(0xFFA94327),
//               ),
//             ),

//             const SizedBox(height: 14),

//             // NAME
//             Text(
//               displayName,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 5),

//             // EMAIL
//             Text(
//               user?.email ?? '',
//               style: const TextStyle(
//                 color: Colors.grey,
//                 fontSize: 13,
//               ),
//             ),

//             const SizedBox(height: 30),

//             // ACCOUNT INFORMATION
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Account Information',
//                     style: TextStyle(
//                       color: darkText,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 15),

//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.email_outlined,
//                         color: Color(0xFFA94327),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         child: Text(
//                           user?.email ?? 'No email',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 30),

//             // LOGOUT
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton.icon(
//                 onPressed: _logout,
//                 icon: const Icon(
//                   Icons.logout,
//                   size: 20,
//                 ),
//                 label: const Text(
//                   'Logout',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _logout() async {
//     try {
//       await AuthService().logout();

//       if (!mounted) return;

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const LoginScreen(),
//         ),
//         (route) => false,
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Logout failed: $e',
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
// }