import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() =>
      _AppSettingsScreenState();
}

class _AppSettingsScreenState
    extends State<AppSettingsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor =
      Color(0xFFA94327);

  static const Color darkText =
      Color(0xFF062B35);

  static const Color backgroundColor =
      Color(0xFFEFF9FD);

  static const Color lightBlue =
      Color(0xFFE4F5FB);

  static const Color tealColor =
      Color(0xFF078F80);

  // ============================================================
  // SETTINGS
  // ============================================================

  bool notificationsEnabled = true;
  bool adoptionUpdatesEnabled = true;
  bool appointmentRemindersEnabled = true;
  bool communityNotificationsEnabled = true;
  bool petRecommendationsEnabled = true;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkText,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'App Settings',
          style: TextStyle(
            color: primaryColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          children: [

            // ==================================================
            // NOTIFICATIONS
            // ==================================================

            _buildSectionTitle(
              'Notifications',
              Icons.notifications_none_rounded,
            ),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [

                _buildSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  iconColor: primaryColor,
                  title: 'Allow Notifications',
                  subtitle:
                      'Receive notifications from My Future Pet',
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;

                      if (!value) {
                        adoptionUpdatesEnabled = false;
                        appointmentRemindersEnabled = false;
                        communityNotificationsEnabled = false;
                      }
                    });
                  },
                ),

                _buildDivider(),

                _buildSwitchTile(
                  icon: Icons.pets_outlined,
                  iconColor: primaryColor,
                  title: 'Adoption Updates',
                  subtitle:
                      'Get updates about your adoption applications',
                  value: adoptionUpdatesEnabled,
                  enabled: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      adoptionUpdatesEnabled = value;
                    });
                  },
                ),

                _buildDivider(),

                _buildSwitchTile(
                  icon: Icons.calendar_month_outlined,
                  iconColor: tealColor,
                  title: 'Appointment Reminders',
                  subtitle:
                      'Receive reminders for your appointments',
                  value: appointmentRemindersEnabled,
                  enabled: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      appointmentRemindersEnabled = value;
                    });
                  },
                ),

                _buildDivider(),

                _buildSwitchTile(
                  icon: Icons.forum_outlined,
                  iconColor: tealColor,
                  title: 'Community Notifications',
                  subtitle:
                      'Get notifications from the community',
                  value: communityNotificationsEnabled,
                  enabled: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      communityNotificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==================================================
            // PET PREFERENCES
            // ==================================================

            _buildSectionTitle(
              'Pet Preferences',
              Icons.pets_outlined,
            ),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [

                _buildSwitchTile(
                  icon: Icons.recommend_outlined,
                  iconColor: primaryColor,
                  title: 'Pet Recommendations',
                  subtitle:
                      'Show pets that may match your interests',
                  value: petRecommendationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      petRecommendationsEnabled = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==================================================
            // APP INFORMATION
            // ==================================================

            _buildSectionTitle(
              'App Information',
              Icons.info_outline_rounded,
            ),

            const SizedBox(height: 10),

            _buildSettingsCard(
              children: [

                _buildInfoTile(
                  icon: Icons.phone_android_rounded,
                  title: 'Application',
                  value: 'My Future Pet',
                ),

                _buildDivider(),

                _buildInfoTile(
                  icon: Icons.code_rounded,
                  title: 'Version',
                  value: '1.0.0',
                ),

                _buildDivider(),

                _buildInfoTile(
                  icon: Icons.cloud_outlined,
                  title: 'Backend',
                  value: 'Supabase',
                ),
              ],
            ),

            const SizedBox(height: 35),

            // ==================================================
            // RESET SETTINGS
            // ==================================================

            Center(
              child: TextButton.icon(
                onPressed: _showResetDialog,
                icon: const Icon(
                  Icons.restore_rounded,
                  color: primaryColor,
                ),
                label: const Text(
                  'Reset Settings',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                'My Future Pet',
                style: TextStyle(
                  color: darkText.withOpacity(0.45),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 22,
        ),

        const SizedBox(width: 8),

        Text(
          title,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _buildSettingsCard({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFE5EEF1),
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        children: children,
      ),
    );
  }

  // ============================================================
  // SWITCH TILE
  // ============================================================

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      child: Row(
        children: [

          // ICON
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: iconColor,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: TextStyle(
                    color: enabled
                        ? darkText
                        : darkText.withOpacity(0.40),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: enabled
                        ? darkText.withOpacity(0.55)
                        : darkText.withOpacity(0.30),
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // SWITCH
          Switch(
            value: value,
            onChanged: enabled
                ? onChanged
                : null,

            activeColor: Colors.white,

            activeTrackColor: primaryColor,

            inactiveThumbColor:
                Colors.white,

            inactiveTrackColor:
                Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO TILE
  // ============================================================

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      child: Row(
        children: [

          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: lightBlue,
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: darkText,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: TextStyle(
                    color:
                        darkText.withOpacity(0.55),
                    fontSize: 13,
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
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(
        left: 78,
      ),
      child: Divider(
        height: 1,
        color: Color(0xFFE8EEF0),
      ),
    );
  }

  // ============================================================
  // RESET DIALOG
  // ============================================================

  void _showResetDialog() {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Reset Settings?',
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const Text(
            'This will restore all app settings to their default values.',
            style: TextStyle(
              color: darkText,
              height: 1.4,
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: darkText,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),

              onPressed: () {
                setState(() {
                  notificationsEnabled = true;
                  adoptionUpdatesEnabled = true;
                  appointmentRemindersEnabled = true;
                  communityNotificationsEnabled = true;
                  petRecommendationsEnabled = true;
                });

                Navigator.pop(dialogContext);

                _showMessage(
                  'Settings restored to default.',
                );
              },

              child: const Text(
                'Reset',
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: primaryColor,

        behavior:
            SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        margin: const EdgeInsets.all(16),
      ),
    );
  }
}