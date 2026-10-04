import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() =>
      _PreferencesScreenState();
}

class _PreferencesScreenState
    extends State<PreferencesScreen> {
  // ------------------------------------------------------------
  // COLORS
  // ------------------------------------------------------------

  final Color primaryColor =
      const Color(0xFFA94327);

  final Color darkText =
      const Color(0xFF062B35);

  final Color backgroundColor =
      const Color(0xFFEFF9FD);

  final Color lightBlue =
      const Color(0xFFE4F5FB);

  final Color tealColor =
      const Color(0xFF078F80);

  // ------------------------------------------------------------
  // PREFERENCE VALUES
  // ------------------------------------------------------------

  String selectedLanguage = 'English';

  bool darkMode = false;

  bool availablePetsOnly = false;

  bool largeText = false;

  bool petRecommendations = true;

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // --------------------------------------------------------
      // APP BAR
      // --------------------------------------------------------

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkText,
            size: 22,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          'Preferences',
          style: TextStyle(
            color: primaryColor,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // --------------------------------------------------------
      // BODY
      // --------------------------------------------------------

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ------------------------------------------------
              // DESCRIPTION
              // ------------------------------------------------

              Text(
                'Customize your My Future Pet experience.',
                style: TextStyle(
                  color: darkText.withOpacity(0.65),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // GENERAL
              // ------------------------------------------------

              _buildSectionTitle(
                'General',
                Icons.settings_outlined,
              ),

              const SizedBox(height: 12),

              _buildSettingsCard(
                children: [

                  // LANGUAGE
                  _buildPreferenceTile(
                    icon: Icons.language_rounded,
                    iconColor: primaryColor,
                    title: 'Language',
                    subtitle: selectedLanguage,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey,
                    ),
                    onTap: _showLanguageDialog,
                  ),

                  _buildDivider(),

                  // DARK MODE
                  _buildSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: const Color(0xFF6C63A8),
                    title: 'Dark Mode',
                    subtitle:
                        'Use a darker appearance for the app',
                    value: darkMode,
                    onChanged: (value) {
                      setState(() {
                        darkMode = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // PET BROWSING
              // ------------------------------------------------

              _buildSectionTitle(
                'Pet Browsing',
                Icons.pets_rounded,
              ),

              const SizedBox(height: 12),

              _buildSettingsCard(
                children: [

                  // AVAILABLE PETS ONLY
                  _buildSwitchTile(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: tealColor,
                    title: 'Show Available Pets Only',
                    subtitle:
                        'Hide pets that are no longer available',
                    value: availablePetsOnly,
                    onChanged: (value) {
                      setState(() {
                        availablePetsOnly = value;
                      });
                    },
                  ),

                  _buildDivider(),

                  // PET RECOMMENDATIONS
                  _buildSwitchTile(
                    icon: Icons.recommend_outlined,
                    iconColor: primaryColor,
                    title: 'Pet Recommendations',
                    subtitle:
                        'Receive pet suggestions based on your interests',
                    value: petRecommendations,
                    onChanged: (value) {
                      setState(() {
                        petRecommendations = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // ACCESSIBILITY
              // ------------------------------------------------

              _buildSectionTitle(
                'Accessibility',
                Icons.accessibility_new_rounded,
              ),

              const SizedBox(height: 12),

              _buildSettingsCard(
                children: [

                  // LARGE TEXT
                  _buildSwitchTile(
                    icon: Icons.text_fields_rounded,
                    iconColor: const Color(0xFF008F82),
                    title: 'Large Text',
                    subtitle:
                        'Increase text size throughout the app',
                    value: largeText,
                    onChanged: (value) {
                      setState(() {
                        largeText = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // SAVE BUTTON
              // ------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Preferences',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // RESET BUTTON
              // ------------------------------------------------

              Center(
                child: TextButton(
                  onPressed: _resetPreferences,
                  child: Text(
                    'Reset to Default',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          style: TextStyle(
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
  // NORMAL PREFERENCE TILE
  // ============================================================

  Widget _buildPreferenceTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
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

            const SizedBox(width: 15),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: darkText.withOpacity(0.55),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            trailing,
          ],
        ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
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

          const SizedBox(width: 15),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: darkText.withOpacity(0.55),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // SWITCH
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: primaryColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor:
                Colors.grey.shade300,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 81,
      ),
      child: Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
    );
  }

  // ============================================================
  // LANGUAGE DIALOG
  // ============================================================

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Select Language',
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: selectedLanguage,
                activeColor: primaryColor,
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedLanguage = value;
                  });

                  Navigator.pop(context);
                },
              ),

              RadioListTile<String>(
                title: const Text('Filipino'),
                value: 'Filipino',
                groupValue: selectedLanguage,
                activeColor: primaryColor,
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedLanguage = value;
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SAVE PREFERENCES
  // ============================================================

  void _savePreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Preferences saved successfully.',
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  void _resetPreferences() {
    setState(() {
      selectedLanguage = 'English';
      darkMode = false;
      availablePetsOnly = false;
      largeText = false;
      petRecommendations = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Preferences restored to default.',
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}