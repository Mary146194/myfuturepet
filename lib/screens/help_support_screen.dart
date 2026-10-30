import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/theme_service.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const Color primaryColor = Color(0xFFA94327);
  static const Color tealColor = Color(0xFF008F82);

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How does the adoption process work?',
      'answer':
          '1. Find an adoptable pet you love on the Home or Pets tab.\n2. Tap "Adopt Me" to fill in the adoption questionnaire.\n3. Shelter staff review your application and schedule an interview.\n4. Complete the adoption agreement and take your new pet home.',
    },
    {
      'question': 'Is pet adoption really 100% free?',
      'answer':
          'Adoption fees are waived in partnership with Jagna Animal Lover and Rescue Group to encourage loving homes for rescue animals. Adopters only commit to providing lifelong food, healthcare, and safe shelter.',
    },
    {
      'question': 'Can I visit and meet the pet in person first?',
      'answer':
          'Yes. Tap "Schedule Visit" on any pet details page to pick an appointment date and time at the shelter. This gives you and your family time to interact with the pet before applying.',
    },
    {
      'question': 'What requirements or documents are needed?',
      'answer':
          'You will need:\n• One government-issued valid ID\n• Verification of your residence or landlord pet permission\n• Agreement to participate in a standard shelter welfare check-in.',
    },
    {
      'question': 'How do I track my submitted application?',
      'answer':
          'Navigate to your Profile tab and tap "My Applications". Each application shows its review status: Pending, Under Review, Approved or Rejected.',
    },
    {
      'question': 'How does the AR 3D Preview work?',
      'answer':
          'On supported devices, tap "View in AR" on a pet\'s profile, move the phone slowly over the floor, then tap the floor to place the pet at its real size.',
    },
    {
      'question': 'Why can\'t I use AR View on my device?',
      'answer':
          'AR View requires an ARCore-compatible Android device with camera tracking. On other phones, 3D Studio still lets you turn and inspect the pet\'s 3D model.',
    },
    {
      'question': 'How do I save a pet to my favorites?',
      'answer':
          'Tap the heart icon on any pet\'s card or details page. The pet will instantly appear in your Saved Pets list accessible directly from your Profile tab.',
    },
    {
      'question': 'How do I update my profile information?',
      'answer':
          'Navigate to your Profile tab and tap "Edit Profile". You can change your name and profile picture.',
    },
  ];

  Future<void> _openMessenger() async {
    final uri = Uri.parse('https://m.me/jagnaanimallover');
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Messenger. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode(context);
    final bgCol = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5FAFD);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF062B35);
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final appBarBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textCol,
            size: 19,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(
            color: textCol,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: borderCol,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // SHELTER CONTACT CARD
            // ==================================================
            _buildSectionHeader('Partner Shelter Contact', Icons.support_agent_rounded, textCol),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF008F82).withValues(alpha: 0.2)
                              : const Color(0xFFE5F8F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.home_work_outlined,
                          color: tealColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jagna Animal Lover & Rescue',
                              style: TextStyle(
                                color: textCol,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Jagna, Bohol, Philippines',
                              style: TextStyle(
                                color: subTextCol,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: borderCol),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openMessenger,
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                      label: const Text('Chat on Messenger'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tealColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // FAQ ACCORDION
            // ==================================================
            _buildSectionHeader('Frequently Asked Questions', Icons.quiz_outlined, textCol),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _faqs.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: borderCol),
                  itemBuilder: (context, index) {
                    final item = _faqs[index];
                    return Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          14,
                        ),
                        title: Text(
                          item['question']!,
                          style: TextStyle(
                            color: textCol,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        iconColor: tealColor,
                        collapsedIconColor: subTextCol,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item['answer']!,
                              style: TextStyle(
                                color: subTextCol,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 17, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
