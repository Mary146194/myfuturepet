import 'package:flutter/material.dart';

import '../adoption_application_store.dart';
import 'pets_screen.dart';
import 'visit_appointment_screen.dart';

class MyApplicationsScreen extends StatefulWidget {
  // ============================================================
  // BROWSE PETS CALLBACK
  // ============================================================

  final VoidCallback? onBrowsePets;

  const MyApplicationsScreen({
    super.key,
    this.onBrowsePets,
  });

  @override
  State<MyApplicationsScreen> createState() =>
      _MyApplicationsScreenState();
}

class _MyApplicationsScreenState
    extends State<MyApplicationsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor =
      Color(0xFFA94327);

  static const Color darkText =
      Color(0xFF062B35);

  static const Color backgroundColor =
      Color(0xFFF5FAFD);

  static const Color secondaryText =
      Color(0xFF68777C);

  static const Color lightBlue =
      Color(0xFFE4F5FB);

  static const Color tealColor =
      Color(0xFF008F82);

  static const Color borderColor =
      Color(0xFFD7E3E7);

  @override
  void initState() {
    super.initState();
    AdoptionApplicationStore.syncWithSupabase().then((_) {
      if (mounted) setState(() {});
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> applications =
        AdoptionApplicationStore.getAllApplications();

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(
            Icons.arrow_back_rounded,
            color: darkText,
          ),
        ),

        title: const Text(
          'My Applications',
          style: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: applications.isEmpty
          ? _buildEmptyApplication()
          : _buildApplicationList(applications),
    );
  }

  // ============================================================
  // EMPTY APPLICATION
  // ============================================================

  Widget _buildEmptyApplication() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            // ==================================================
            // ICON
            // ==================================================

            Container(
              width: 100,
              height: 100,

              decoration:
                  const BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.description_outlined,
                color: primaryColor,
                size: 50,
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              'No Adoption Applications Yet',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: darkText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            const Text(
              'You have not submitted an adoption application yet. Browse our available pets and find your future companion.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: secondaryText,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // BROWSE PETS BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: _browsePets,

                icon: const Icon(
                  Icons.pets_rounded,
                  size: 21,
                ),

                label: const Text(
                  'Browse Pets',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

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
                        BorderRadius.circular(26),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ADOPTION STEPS GUIDE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF008F82), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'How Adoption Works',
                        style: TextStyle(
                          color: darkText,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildAdoptionStepRow('1', 'Find a pet you love and submit an adoption application.'),
                  const SizedBox(height: 8),
                  _buildAdoptionStepRow('2', 'Shelter staff reviews your screening within 24–48 hours.'),
                  const SizedBox(height: 8),
                  _buildAdoptionStepRow('3', 'Once approved, book a shelter visit to meet your pet in person!'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdoptionStepRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFE0F2F1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF008F82),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BROWSE PETS
  // ============================================================

  void _browsePets() {
  if (widget.onBrowsePets != null) {
    Navigator.pop(context);
    widget.onBrowsePets!.call();
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const PetsScreen(),
    ),
  );
}

  // ============================================================
  // APPLICATION LIST
  // ============================================================

  Widget _buildApplicationList(
    List<Map<String, dynamic>> applications,
  ) {
    return ListView(
      physics:
          const BouncingScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        30,
      ),

      children: [
        // ======================================================
        // HEADER
        // ======================================================

        const Text(
          'Your Adoption Applications',
          style: TextStyle(
            color: darkText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          '${applications.length} application${applications.length == 1 ? '' : 's'} submitted',
          style: const TextStyle(
            color: secondaryText,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 20),

        // ======================================================
        // APPLICATION CARDS
        // ======================================================

        ...List.generate(
          applications.length,
          (index) {
            final application =
                applications[index];

            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 14,
              ),

              child: _buildApplicationCard(
                application,
                index,
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // APPLICATION CARD
  // ============================================================

  Widget _buildApplicationCard(
    Map<String, dynamic> application,
    int index,
  ) {
    final Map<String, dynamic> pet =
        Map<String, dynamic>.from(
      application['pet'] as Map,
    );

    final String name =
        pet['name']?.toString() ?? 'Pet';

    final String breed =
        pet['breed']?.toString() ?? '';

    final String age =
        pet['age']?.toString() ?? '';

    final String image =
        pet['image']?.toString() ?? '';

    final String status =
        application['status']?.toString() ??
            'Under Review';

    final String submittedAt =
        application['submittedAt']?.toString() ??
            '';

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: borderColor,
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        children: [
          // ====================================================
          // PET INFORMATION
          // ====================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // =================================================
              // PET IMAGE
              // =================================================

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(14),

                child: Image.network(
                  image,

                  width: 90,
                  height: 90,

                  fit: BoxFit.cover,

                  errorBuilder:
                      (context, error, stackTrace) {
                    return Container(
                      width: 90,
                      height: 90,

                      color: lightBlue,

                      child: const Icon(
                        Icons.pets,
                        color: primaryColor,
                        size: 38,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              // =================================================
              // PET DETAILS
              // =================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Applying to adopt',
                      style: TextStyle(
                        color:
                            secondaryText,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        color: darkText,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '$breed • $age',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        color:
                            secondaryText,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // STATUS
                    Builder(
                      builder: (context) {
                          Color badgeBg = const Color(0xFFEAF8F6);
                          Color badgeText = tealColor;
                          final sLower = status.toLowerCase();
                          if (sLower.contains('pend') || sLower.contains('review')) {
                            badgeBg = const Color(0xFFFEF3C7);
                            badgeText = const Color(0xFFD97706);
                          } else if (sLower.contains('reject')) {
                            badgeBg = const Color(0xFFFEE2E2);
                            badgeText = const Color(0xFFDC2626);
                          } else if (!sLower.contains('approv')) {
                            badgeBg = const Color(0xFFE0F2FE);
                            badgeText = const Color(0xFF0284C7);
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: badgeText,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ====================================================
          // DIVIDER
          // ====================================================

          const Divider(
            color: borderColor,
            height: 1,
          ),

          const SizedBox(height: 12),

          // APPROVED CELEBRATION & BOOK VISIT BANNER
          if (status.toLowerCase().contains('approv')) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5D6A7), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.celebration_rounded, color: Color(0xFF2E7D32), size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application Approved! 🎉',
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Schedule a shelter visit to meet your pet.',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _scheduleVisitForApprovedPet(application),
                    icon: const Icon(Icons.calendar_month, size: 14),
                    label: const Text(
                      'Book Visit',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008F82),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // SHELTER REMARKS / NOTES
          if (application['reviewNotes'] != null &&
              application['reviewNotes'].toString().trim().isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.rate_review_outlined, size: 15, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Shelter Note: ${application['reviewNotes']}',
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ====================================================
          // SUBMITTED DATE + VIEW BUTTON
          // ====================================================

          Row(
            children: [
              // DATE
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .calendar_today_outlined,
                      color:
                          secondaryText,
                      size: 15,
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        _formatDate(
                          submittedAt,
                        ),

                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(
                          color:
                              secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // VIEW BUTTON
              SizedBox(
                height: 40,

                child: ElevatedButton(
                  onPressed: () {
                    _viewApplication(
                      application,
                    );
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryColor,

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 18,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                  ),

                  child: const Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      Text(
                        'View Application',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      SizedBox(width: 4),

                      Icon(
                        Icons
                            .arrow_forward_rounded,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCHEDULE VISIT FOR APPROVED PET
  // ============================================================

  void _scheduleVisitForApprovedPet(Map<String, dynamic> application) {
    final Map<String, dynamic> pet =
        Map<String, dynamic>.from(application['pet'] as Map? ?? {});
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VisitAppointmentScreen(pet: pet),
      ),
    );
  }

  // ============================================================
  // VIEW APPLICATION
  // ============================================================

  void _viewApplication(
    Map<String, dynamic> application,
  ) {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            ApplicationDetailsScreen(
          application: application,
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(String value) {
    if (value.isEmpty) {
      return 'Date not available';
    }

    try {
      final DateTime date =
          DateTime.parse(value);

      final String month =
          _monthName(date.month);

      return '$month ${date.day}, ${date.year}';
    } catch (_) {
      return 'Date not available';
    }
  }

  // ============================================================
  // MONTH NAME
  // ============================================================

  String _monthName(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }
}

// =================================================================
// APPLICATION DETAILS SCREEN
// =================================================================

class ApplicationDetailsScreen
    extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailsScreen({
    super.key,
    required this.application,
  });

  // ==============================================================
  // COLORS
  // ==============================================================

  static const Color primaryColor =
      Color(0xFFA94327);

  static const Color darkText =
      Color(0xFF062B35);

  static const Color backgroundColor =
      Color(0xFFF5FAFD);

  static const Color secondaryText =
      Color(0xFF68777C);

  static const Color lightBlue =
      Color(0xFFE4F5FB);

  static const Color tealColor =
      Color(0xFF008F82);

  static const Color borderColor =
      Color(0xFFD7E3E7);

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> pet =
        Map<String, dynamic>.from(
      application['pet'] as Map,
    );

    final String name =
        pet['name']?.toString() ?? 'Pet';

    final String breed =
        pet['breed']?.toString() ?? '';

    final String age =
        pet['age']?.toString() ?? '';

    final String image =
        pet['image']?.toString() ?? '';

    final String status =
        application['status']?.toString() ??
            'Under Review';

    return Scaffold(
      backgroundColor: backgroundColor,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(
            Icons.arrow_back_rounded,
            color: darkText,
          ),
        ),

        title: const Text(
          'Application Details',
          style: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SingleChildScrollView(
        physics:
            const BouncingScrollPhysics(),

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
            // ====================================================
            // PET CARD
            // ====================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(18),

                border: Border.all(
                  color: borderColor,
                ),
              ),

              child: Row(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),

                    child: Image.network(
                      image,

                      width: 90,
                      height: 90,

                      fit: BoxFit.cover,

                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          width: 90,
                          height: 90,

                          color: lightBlue,

                          child: const Icon(
                            Icons.pets,
                            color:
                                primaryColor,
                            size: 38,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        const Text(
                          'Application for',
                          style: TextStyle(
                            color:
                                secondaryText,
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          name,
                          style:
                              const TextStyle(
                            color: darkText,
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '$breed • $age',
                          style:
                              const TextStyle(
                            color:
                                secondaryText,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFEAF8F6,
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
                                  tealColor,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // APPLICATION STATUS
            // ====================================================

            _buildStatusCard(status),

            const SizedBox(height: 18),

            // ====================================================
            // PERSONAL INFORMATION
            // ====================================================

            _buildInformationCard(
              title: 'Applicant Information',
              icon:
                  Icons.person_outline_rounded,
              items: [
                'Name: ${application['fullName'] ?? ''}',
                'Phone: ${application['phone'] ?? ''}',
                'Email: ${application['email'] ?? ''}',
                'Age: ${application['age'] ?? ''}',
                'Occupation: ${application['occupation'] ?? ''}',
              ],
            ),

            const SizedBox(height: 14),

            // ====================================================
            // HOUSEHOLD INFORMATION
            // ====================================================

            _buildInformationCard(
              title: 'Household Information',
              icon: Icons.home_outlined,
              items: [
                'Household: ${application['householdType'] ?? ''}',
                'Address: ${application['address'] ?? ''}',
                'Household Members: ${application['householdMembers'] ?? ''}',
                'Children: ${application['children'] ?? ''}',
              ],
            ),

            const SizedBox(height: 14),

            // ====================================================
            // PET EXPERIENCE
            // ====================================================

            _buildInformationCard(
              title: 'Pet Experience',
              icon: Icons.pets_outlined,
              items: [
                'Experience: ${application['experienceLevel'] ?? ''}',
                'Previous Pets: ${application['previousPets'] ?? ''}',
                'Current Pets: ${application['currentPets'] ?? ''}',
              ],
            ),

            const SizedBox(height: 14),

            // ====================================================
            // LIFESTYLE
            // ====================================================

            _buildInformationCard(
              title: 'Lifestyle',
              icon:
                  Icons.schedule_outlined,
              items: [
                'Home Environment: ${application['homeEnvironment'] ?? ''}',
                'Activity Level: ${application['activityLevel'] ?? ''}',
                'Daily Time Available: ${application['timeAvailable'] ?? ''}',
              ],
            ),

            const SizedBox(height: 14),

            // ====================================================
            // ADOPTION REASON
            // ====================================================

            _buildInformationCard(
              title: 'Adoption Reason',
              icon:
                  Icons.favorite_border_rounded,
              items: [
                application['adoptionReason']
                        ?.toString() ??
                    '',
              ],
            ),

            const SizedBox(height: 18),

            // ====================================================
            // SHELTER MESSAGE
            // ====================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color:
                    const Color(0xFFFFF5EA),

                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color:
                      const Color(0xFFE9C9AF),
                ),
              ),

              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: primaryColor,
                    size: 21,
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Your application is currently under review. The shelter may contact you using the information you provided.',
                      style: TextStyle(
                        color:
                            Color(0xFF6E5145),
                        fontSize: 12,
                        height: 1.5,
                      ),
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

  // ==============================================================
  // STATUS CARD
  // ==============================================================

  Widget _buildStatusCard(
    String status,
  ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F6),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFC8E9E4),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.pending_actions_rounded,
              color: tealColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Application Status',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  status,
                  style: const TextStyle(
                    color: tealColor,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // INFORMATION CARD
  // ==============================================================

  Widget _buildInformationCard({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: borderColor,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFFFF4EF),

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),

                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 19,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          ...items.map(
            (item) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 8,
                ),

                child: Text(
                  item.isEmpty
                      ? 'Not provided'
                      : item,

                  style:
                      const TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
