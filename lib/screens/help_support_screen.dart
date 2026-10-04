import 'package:flutter/material.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() =>
      _HelpSupportScreenState();
}

class _HelpSupportScreenState
    extends State<HelpSupportScreen> {
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

  final Color tealColor =
      const Color(0xFF078F80);

  // ============================================================
  // FAQ STATES
  // ============================================================

  final Set<int> expandedQuestions = {};

  // ============================================================
  // FAQ DATA
  // ============================================================

  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I adopt a pet?',
      'answer':
          'Browse the available pets and select a pet you are interested in. Open the pet details and tap the adoption option to start the application process. Follow the required steps and provide the requested information.',
    },
    {
      'question': 'How do I save a pet?',
      'answer':
          'Open a pet from the Pets section and tap the heart icon on the Pet Details screen. The pet will be added to your Saved Pets list in your Profile.',
    },
    {
      'question': 'Where can I see my applications?',
      'answer':
          'Go to your Profile and select My Applications. You can view the adoption applications you have submitted and check their current status.',
    },
    {
      'question': 'How do I schedule an appointment?',
      'answer':
          'Open the pet you are interested in and select the appropriate appointment option. Choose an available date and time, then confirm your appointment.',
    },
    {
      'question': 'What is AR View?',
      'answer':
          'AR View allows you to preview a pet using augmented reality when your device supports the feature. This helps you visualize the pet in your surroundings.',
    },
    {
      'question': 'Why I cannot use AR View?',
      'answer':
          'AR View requires a compatible Android device that supports the required AR features. If your device is not supported, the AR option may not be available.',
    },
    {
      'question': 'How do I change my profile information?',
      'answer':
          'Go to your Profile and select the Edit Profile option. You can update the available profile information from there.',
    },
    {
      'question': 'How do I contact the shelter?',
      'answer':
          'You may use the available communication or appointment features in the application to contact or coordinate with the shelter regarding adoption concerns.',
    },
  ];

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
          'Help & Support',
          style: TextStyle(
            color: primaryColor,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

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

              // ==================================================
              // INTRO
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Row(
                  children: [

                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.support_agent_rounded,
                        color: primaryColor,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Text(
                            'How can we help?',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Find answers to common questions or contact support.',
                            style: TextStyle(
                              color: darkText
                                  .withOpacity(0.65),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // QUICK HELP
              // ==================================================

              _buildSectionTitle(
                'Quick Help',
                Icons.help_outline_rounded,
              ),

              const SizedBox(height: 12),

              _buildQuickHelpCard(
                icon: Icons.pets_rounded,
                iconColor: primaryColor,
                title: 'Pet Adoption Help',
                subtitle:
                    'Learn how the adoption process works.',
                onTap: () {
                  _showInfoDialog(
                    title: 'Pet Adoption Help',
                    icon: Icons.pets_rounded,
                    message:
                        'To adopt a pet, browse the available pets, open the pet details, and start the adoption application. Make sure to provide the required information and follow the shelter requirements.',
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildQuickHelpCard(
                icon: Icons.phone_android_rounded,
                iconColor: tealColor,
                title: 'App Usage Help',
                subtitle:
                    'Learn how to use the features of the app.',
                onTap: () {
                  _showInfoDialog(
                    title: 'App Usage Help',
                    icon: Icons.phone_android_rounded,
                    message:
                        'Use the bottom navigation bar to access Home, Pets, AR View, Feed, and Profile. From Profile, you can manage your applications, saved pets, appointments, and app settings.',
                  );
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // FAQ
              // ==================================================

              _buildSectionTitle(
                'Frequently Asked Questions',
                Icons.question_answer_outlined,
              ),

              const SizedBox(height: 12),

              _buildFaqCard(),

              const SizedBox(height: 28),

              // ==================================================
              // CONTACT SUPPORT
              // ==================================================

              _buildSectionTitle(
                'Support',
                Icons.support_agent_rounded,
              ),

              const SizedBox(height: 12),

              _buildSupportCard(
                icon: Icons.email_outlined,
                iconColor: primaryColor,
                title: 'Contact Support',
                subtitle:
                    'Send us a message if you need assistance.',
                onTap: () {
                  _showContactDialog();
                },
              ),

              const SizedBox(height: 10),

              _buildSupportCard(
                icon: Icons.report_problem_outlined,
                iconColor: Colors.orange.shade700,
                title: 'Report a Problem',
                subtitle:
                    'Tell us about an issue you encountered.',
                onTap: () {
                  _showReportDialog();
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // ABOUT
              // ==================================================

              _buildSectionTitle(
                'About',
                Icons.info_outline_rounded,
              ),

              const SizedBox(height: 12),

              _buildSupportCard(
                icon: Icons.pets_rounded,
                iconColor: tealColor,
                title: 'About My Future Pet',
                subtitle:
                    'Learn more about the application.',
                onTap: () {
                  _showAboutDialog();
                },
              ),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  'My Future Pet',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Center(
                child: Text(
                  'Pet Adoption & AR Visualization',
                  style: TextStyle(
                    color: darkText.withOpacity(0.55),
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: darkText.withOpacity(0.40),
                    fontSize: 11,
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
  // QUICK HELP CARD
  // ============================================================

  Widget _buildQuickHelpCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
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
        child: Row(
          children: [

            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    iconColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 25,
              ),
            ),

            const SizedBox(width: 15),

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
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color:
                          darkText.withOpacity(0.55),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FAQ CARD
  // ============================================================

  Widget _buildFaqCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
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
        children: List.generate(
          faqs.length,
          (index) {
            final bool isExpanded =
                expandedQuestions.contains(index);

            return Column(
              children: [

                InkWell(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        expandedQuestions
                            .remove(index);
                      } else {
                        expandedQuestions
                            .add(index);
                      }
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Expanded(
                          child: Text(
                            faqs[index]['question']!,
                            style: TextStyle(
                              color: darkText,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Icon(
                          isExpanded
                              ? Icons
                                  .keyboard_arrow_up_rounded
                              : Icons
                                  .keyboard_arrow_down_rounded,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),

                if (isExpanded)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.fromLTRB(
                      18,
                      0,
                      18,
                      18,
                    ),
                    child: Text(
                      faqs[index]['answer']!,
                      style: TextStyle(
                        color:
                            darkText.withOpacity(0.70),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),

                if (index != faqs.length - 1)
                  Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                    indent: 18,
                    endIndent: 18,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // SUPPORT CARD
  // ============================================================

  Widget _buildSupportCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
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
        child: Row(
          children: [

            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    iconColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 25,
              ),
            ),

            const SizedBox(width: 15),

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
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color:
                          darkText.withOpacity(0.55),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO DIALOG
  // ============================================================

  void _showInfoDialog({
    required String title,
    required IconData icon,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: Row(
            children: [

              Icon(
                icon,
                color: primaryColor,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: darkText.withOpacity(0.70),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CONTACT SUPPORT DIALOG
  // ============================================================

  void _showContactDialog() {
    final TextEditingController controller =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: Text(
            'Contact Support',
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText:
                  'Describe your concern...',
              filled: true,
              fillColor: backgroundColor,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
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
                Navigator.pop(context);

                _showMessage(
                  'Your message has been submitted.',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Send',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // REPORT PROBLEM DIALOG
  // ============================================================

  void _showReportDialog() {
    final TextEditingController controller =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: Text(
            'Report a Problem',
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText:
                  'What problem did you encounter?',
              filled: true,
              fillColor: backgroundColor,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
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
                Navigator.pop(context);

                _showMessage(
                  'Problem report submitted.',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Submit',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ABOUT DIALOG
  // ============================================================

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: Row(
            children: [

              Icon(
                Icons.pets_rounded,
                color: primaryColor,
              ),

              const SizedBox(width: 10),

              Text(
                'My Future Pet',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'My Future Pet is a mobile-based pet adoption application designed to help users discover available pets, learn about them, save pets they are interested in, submit adoption applications, schedule appointments, and experience pet visualization through augmented reality.',
            style: TextStyle(
              color: darkText.withOpacity(0.70),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    );
  }
}