import 'package:flutter/material.dart';

import '../adoption_application_store.dart';
import 'pets_screen.dart';

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
            fontSize: 19,
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
                fontSize: 21,
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
          ],
        ),
      ),
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
                      (_, __, ___) {
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
                        fontSize: 19,
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

                    const SizedBox(height: 9),

                    // STATUS
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),

                      decoration:
                          BoxDecoration(
                        color: const Color(
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
                          color: tealColor,
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

          const SizedBox(height: 14),

          // ====================================================
          // DIVIDER
          // ====================================================

          const Divider(
            color: borderColor,
            height: 1,
          ),

          const SizedBox(height: 12),

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

                      SizedBox(width: 5),

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
            fontSize: 19,
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
                          (_, __, ___) {
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
                            fontSize: 21,
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
                    fontSize: 15,
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
                  bottom: 7,
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
































// import 'package:flutter/material.dart';

// import '../adoption_application_store.dart';

// class MyApplicationsScreen extends StatefulWidget {
//   final VoidCallback? onBrowsePets;

//   const MyApplicationsScreen({
//     super.key,
//     this.onBrowsePets,
//   });

//   @override
//   State<MyApplicationsScreen> createState() =>
//       _MyApplicationsScreenState();
// }

// class _MyApplicationsScreenState
//     extends State<MyApplicationsScreen> {

//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor =
//       Color(0xFFA94327);

//   static const Color darkText =
//       Color(0xFF062B35);

//   static const Color backgroundColor =
//       Color(0xFFF5FAFD);

//   static const Color secondaryText =
//       Color(0xFF68777C);

//   static const Color lightBlue =
//       Color(0xFFE4F5FB);

//   static const Color tealColor =
//       Color(0xFF008F82);

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final applications =
//         AdoptionApplicationStore.getAllApplications();

//     final bool hasApplication =
//         applications.isNotEmpty;

//     return Scaffold(
//       backgroundColor: backgroundColor,

//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         elevation: 0,

//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },

//           icon: const Icon(
//             Icons.arrow_back_rounded,
//             color: darkText,
//           ),
//         ),

//         title: const Text(
//           'My Applications',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 19,
//             fontWeight: FontWeight.w800,
//           ),
//         ),

//         centerTitle: true,
//       ),

//       body: hasApplication
//           ? _buildApplicationsList(applications)
//           : _buildEmptyApplication(),
//     );
//   }

//   // ============================================================
//   // EMPTY APPLICATION
//   // ============================================================

//   Widget _buildEmptyApplication() {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),

//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [

//             // ICON
//             Container(
//               width: 100,
//               height: 100,

//               decoration:
//                   const BoxDecoration(
//                 color: lightBlue,
//                 shape: BoxShape.circle,
//               ),

//               child: const Icon(
//                 Icons.description_outlined,
//                 color: primaryColor,
//                 size: 50,
//               ),
//             ),

//             const SizedBox(height: 24),

//             // TITLE
//             const Text(
//               'No Adoption Applications Yet',
//               textAlign: TextAlign.center,

//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 21,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),

//             const SizedBox(height: 10),

//             // DESCRIPTION
//             const Text(
//               'You have not submitted an adoption application yet. Browse our available pets and find your future companion.',
//               textAlign: TextAlign.center,

//               style: TextStyle(
//                 color: secondaryText,
//                 fontSize: 13,
//                 height: 1.5,
//               ),
//             ),

//             const SizedBox(height: 28),

//             // BROWSE PETS BUTTON
//             SizedBox(
//               width: double.infinity,
//               height: 52,

//               child: ElevatedButton.icon(
//                 onPressed: _browsePets,

//                 icon: const Icon(
//                   Icons.pets_rounded,
//                   size: 21,
//                 ),

//                 label: const Text(
//                   'Browse Pets',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),

//                 style:
//                     ElevatedButton.styleFrom(
//                   backgroundColor:
//                       primaryColor,

//                   foregroundColor:
//                       Colors.white,

//                   elevation: 0,

//                   shape:
//                       RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(26),
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
//   // BROWSE PETS
//   // ============================================================

//   void _browsePets() {
//     // ==========================================================
//     // IF OPENED FROM PROFILE / HOME NAVIGATION
//     // ==========================================================

//     if (widget.onBrowsePets != null) {
//       Navigator.pop(context);

//       widget.onBrowsePets!.call();

//       return;
//     }

//     // ==========================================================
//     // FALLBACK
//     // ==========================================================
//     //
//     // If this screen was opened somewhere without the callback,
//     // simply go back instead of creating another navigation
//     // stack.
//     //
//     // ==========================================================

//     Navigator.pop(context);
//   }

//   // ============================================================
//   // APPLICATIONS LIST
//   // ============================================================

//   Widget _buildApplicationsList(
//     List<Map<String, dynamic>> applications,
//   ) {
//     return RefreshIndicator(
//       color: primaryColor,

//       onRefresh: () async {
//         setState(() {});
//       },

//       child: ListView.builder(
//         physics:
//             const AlwaysScrollableScrollPhysics(
//           parent: BouncingScrollPhysics(),
//         ),

//         padding: const EdgeInsets.fromLTRB(
//           20,
//           14,
//           20,
//           30,
//         ),

//         itemCount:
//             applications.length + 1,

//         itemBuilder:
//             (context, index) {

//           // ====================================================
//           // HEADER
//           // ====================================================

//           if (index == 0) {
//             return Padding(
//               padding:
//                   const EdgeInsets.only(
//                 bottom: 18,
//               ),

//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,

//                 children: [

//                   Text(
//                     '${applications.length} Adoption '
//                     '${applications.length == 1 ? 'Application' : 'Applications'}',
//                     style:
//                         const TextStyle(
//                       color: darkText,
//                       fontSize: 22,
//                       fontWeight:
//                           FontWeight.w800,
//                     ),
//                   ),

//                   const SizedBox(height: 6),

//                   const Text(
//                     'Here are the pets you have applied to adopt.',
//                     style: TextStyle(
//                       color: secondaryText,
//                       fontSize: 13,
//                       height: 1.4,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           // ====================================================
//           // APPLICATION
//           // ====================================================

//           final application =
//               applications[index - 1];

//           return _buildApplicationCard(
//             application,
//             index - 1,
//           );
//         },
//       ),
//     );
//   }

//   // ============================================================
//   // APPLICATION CARD
//   // ============================================================

//   Widget _buildApplicationCard(
//     Map<String, dynamic> application,
//     int index,
//   ) {
//     final Map<String, dynamic> pet =
//         Map<String, dynamic>.from(
//       application['pet'] as Map,
//     );

//     final String name =
//         pet['name']?.toString() ?? 'Pet';

//     final String breed =
//         pet['breed']?.toString() ?? '';

//     final String age =
//         pet['age']?.toString() ?? '';

//     final String status =
//         application['status']?.toString() ??
//             'Under Review';

//     final String image =
//         pet['image']?.toString() ?? '';

//     return Container(
//       width: double.infinity,

//       margin:
//           const EdgeInsets.only(bottom: 14),

//       padding:
//           const EdgeInsets.all(14),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(18),

//         border: Border.all(
//           color: const Color(
//             0xFFD7E3E7,
//           ),
//         ),

//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x0A000000),
//             blurRadius: 8,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),

//       child: Column(
//         children: [

//           // ====================================================
//           // PET INFORMATION
//           // ====================================================

//           Row(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,

//             children: [

//               // PET IMAGE
//               ClipRRect(
//                 borderRadius:
//                     BorderRadius.circular(13),

//                 child: Image.network(
//                   image,

//                   width: 88,
//                   height: 88,

//                   fit: BoxFit.cover,

//                   errorBuilder:
//                       (_, __, ___) {
//                     return Container(
//                       width: 88,
//                       height: 88,

//                       color: lightBlue,

//                       child:
//                           const Icon(
//                         Icons.pets,
//                         color:
//                             primaryColor,
//                         size: 35,
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(width: 14),

//               // PET DETAILS
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,

//                   children: [

//                     const Text(
//                       'Applying to adopt',
//                       style: TextStyle(
//                         color:
//                             secondaryText,
//                         fontSize: 11,
//                       ),
//                     ),

//                     const SizedBox(height: 4),

//                     Text(
//                       name,
//                       style:
//                           const TextStyle(
//                         color: darkText,
//                         fontSize: 20,
//                         fontWeight:
//                             FontWeight.w800,
//                       ),
//                     ),

//                     const SizedBox(height: 4),

//                     Text(
//                       '$breed • $age',
//                       style:
//                           const TextStyle(
//                         color:
//                             secondaryText,
//                         fontSize: 12,
//                       ),
//                     ),

//                     const SizedBox(height: 9),

//                     // STATUS
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
//                           0xFFEAF8F6,
//                         ),

//                         borderRadius:
//                             BorderRadius
//                                 .circular(
//                           20,
//                         ),
//                       ),

//                       child: Text(
//                         status,
//                         style:
//                             const TextStyle(
//                           color:
//                               tealColor,
//                           fontSize: 11,
//                           fontWeight:
//                               FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Icon(
//                 Icons.favorite_rounded,
//                 color: primaryColor,
//                 size: 22,
//               ),
//             ],
//           ),

//           const SizedBox(height: 14),

//           // ====================================================
//           // APPLICATION NUMBER
//           // ====================================================

//           Container(
//             width: double.infinity,

//             padding:
//                 const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 9,
//             ),

//             decoration: BoxDecoration(
//               color: const Color(
//                 0xFFF5FAFD,
//               ),

//               borderRadius:
//                   BorderRadius.circular(10),
//             ),

//             child: Row(
//               children: [

//                 const Icon(
//                   Icons.description_outlined,
//                   color: secondaryText,
//                   size: 17,
//                 ),

//                 const SizedBox(width: 8),

//                 Text(
//                   'Application #${index + 1}',
//                   style:
//                       const TextStyle(
//                     color: secondaryText,
//                     fontSize: 11,
//                     fontWeight:
//                         FontWeight.w600,
//                   ),
//                 ),

//                 const Spacer(),

//                 const Text(
//                   'Submitted',
//                   style: TextStyle(
//                     color: secondaryText,
//                     fontSize: 11,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




























// import 'package:flutter/material.dart';

// import '../adoption_application_store.dart';

// class MyApplicationsScreen extends StatefulWidget {
//   // ============================================================
//   // BROWSE PETS CALLBACK
//   // ============================================================

//   final VoidCallback? onBrowsePets;

//   const MyApplicationsScreen({
//     super.key,
//     this.onBrowsePets,
//   });

//   @override
//   State<MyApplicationsScreen> createState() =>
//       _MyApplicationsScreenState();
// }

// class _MyApplicationsScreenState
//     extends State<MyApplicationsScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor =
//       Color(0xFFA94327);

//   static const Color darkText =
//       Color(0xFF062B35);

//   static const Color backgroundColor =
//       Color(0xFFF5FAFD);

//   static const Color secondaryText =
//       Color(0xFF68777C);

//   static const Color lightBlue =
//       Color(0xFFE4F5FB);

//   static const Color tealColor =
//       Color(0xFF008F82);

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final applications =
//         AdoptionApplicationStore.applications;

//     return Scaffold(
//       backgroundColor: backgroundColor,

//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         elevation: 0,

//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },

//           icon: const Icon(
//             Icons.arrow_back_rounded,
//             color: darkText,
//           ),
//         ),

//         title: const Text(
//           'My Applications',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 19,
//             fontWeight: FontWeight.w800,
//           ),
//         ),

//         centerTitle: true,
//       ),

//       body: applications.isEmpty
//           ? _buildEmptyApplication()
//           : _buildApplicationList(),
//     );
//   }

//   // ============================================================
//   // EMPTY APPLICATION
//   // ============================================================

//   Widget _buildEmptyApplication() {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),

//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             // ICON
//             Container(
//               width: 100,
//               height: 100,

//               decoration:
//                   const BoxDecoration(
//                 color: lightBlue,
//                 shape: BoxShape.circle,
//               ),

//               child: const Icon(
//                 Icons.description_outlined,
//                 color: primaryColor,
//                 size: 50,
//               ),
//             ),

//             const SizedBox(height: 24),

//             // TITLE
//             const Text(
//               'No Adoption Applications Yet',
//               textAlign: TextAlign.center,

//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 21,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),

//             const SizedBox(height: 10),

//             // DESCRIPTION
//             const Text(
//               'You have not submitted an adoption application yet. Browse our available pets and find your future companion.',
//               textAlign: TextAlign.center,

//               style: TextStyle(
//                 color: secondaryText,
//                 fontSize: 13,
//                 height: 1.5,
//               ),
//             ),

//             const SizedBox(height: 28),

//             // BROWSE PETS BUTTON
//             SizedBox(
//               width: double.infinity,
//               height: 52,

//               child: ElevatedButton.icon(
//                 onPressed: _browsePets,

//                 icon: const Icon(
//                   Icons.pets_rounded,
//                   size: 21,
//                 ),

//                 label: const Text(
//                   'Browse Pets',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),

//                 style:
//                     ElevatedButton.styleFrom(
//                   backgroundColor:
//                       primaryColor,

//                   foregroundColor:
//                       Colors.white,

//                   elevation: 0,

//                   shape:
//                       RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(26),
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
//   // BROWSE PETS
//   // ============================================================

//   void _browsePets() {
//     Navigator.pop(context);

//     widget.onBrowsePets?.call();
//   }

//   // ============================================================
//   // APPLICATION LIST
//   // ============================================================

//   Widget _buildApplicationList() {
//     final applications =
//         AdoptionApplicationStore.applications;

//     return ListView(
//       physics:
//           const BouncingScrollPhysics(),

//       padding: const EdgeInsets.fromLTRB(
//         20,
//         12,
//         20,
//         30,
//       ),

//       children: [
//         // ========================================================
//         // HEADER
//         // ========================================================

//         const Text(
//           'Your Adoption Applications',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 22,
//             fontWeight: FontWeight.w800,
//           ),
//         ),

//         const SizedBox(height: 6),

//         Text(
//           '${applications.length} application${applications.length == 1 ? '' : 's'} submitted',
//           style: const TextStyle(
//             color: secondaryText,
//             fontSize: 13,
//           ),
//         ),

//         const SizedBox(height: 20),

//         // ========================================================
//         // APPLICATION CARDS
//         // ========================================================

//         ...List.generate(
//           applications.length,
//           (index) {
//             return _buildApplicationCard(
//               applications[index],
//               index,
//             );
//           },
//         ),

//         const SizedBox(height: 8),

//         // ========================================================
//         // BROWSE MORE PETS
//         // ========================================================

//         SizedBox(
//           width: double.infinity,
//           height: 50,

//           child: OutlinedButton.icon(
//             onPressed: _browsePets,

//             icon: const Icon(
//               Icons.pets_rounded,
//               size: 20,
//             ),

//             label: const Text(
//               'Browse More Pets',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),

//             style:
//                 OutlinedButton.styleFrom(
//               foregroundColor:
//                   primaryColor,

//               side: const BorderSide(
//                 color: primaryColor,
//                 width: 1.4,
//               ),

//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(26),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // APPLICATION CARD
//   // ============================================================

//   Widget _buildApplicationCard(
//     Map<String, dynamic> application,
//     int index,
//   ) {
//     final Map<String, dynamic> pet =
//         application['pet'] is Map
//             ? Map<String, dynamic>.from(
//                 application['pet'] as Map,
//               )
//             : {};

//     final String name =
//         pet['name']?.toString() ?? 'Pet';

//     final String breed =
//         pet['breed']?.toString() ?? '';

//     final String age =
//         pet['age']?.toString() ?? '';

//     final String status =
//         application['status']?.toString() ??
//             'Under Review';

//     final String image =
//         pet['image']?.toString() ?? '';

//     return GestureDetector(
//       onTap: () {
//         _showApplicationDetails(
//           application,
//           index,
//         );
//       },

//       child: Container(
//         width: double.infinity,

//         margin:
//             const EdgeInsets.only(bottom: 14),

//         padding:
//             const EdgeInsets.all(14),

//         decoration: BoxDecoration(
//           color: Colors.white,

//           borderRadius:
//               BorderRadius.circular(18),

//           border: Border.all(
//             color: const Color(
//               0xFFD7E3E7,
//             ),
//           ),

//           boxShadow: [
//             BoxShadow(
//               color:
//                   Colors.black.withOpacity(0.03),
//               blurRadius: 8,
//               offset:
//                   const Offset(0, 3),
//             ),
//           ],
//         ),

//         child: Row(
//           crossAxisAlignment:
//               CrossAxisAlignment.center,

//           children: [
//             // ==================================================
//             // PET IMAGE
//             // ==================================================

//             ClipRRect(
//               borderRadius:
//                   BorderRadius.circular(13),

//               child: image.isNotEmpty
//                   ? Image.network(
//                       image,

//                       width: 90,
//                       height: 90,

//                       fit: BoxFit.cover,

//                       errorBuilder:
//                           (_, __, ___) {
//                         return _petPlaceholder();
//                       },
//                     )
//                   : _petPlaceholder(),
//             ),

//             const SizedBox(width: 14),

//             // ==================================================
//             // PET INFORMATION
//             // ==================================================

//             Expanded(
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,

//                 children: [
//                   const Text(
//                     'Applying to adopt',
//                     style: TextStyle(
//                       color:
//                           secondaryText,
//                       fontSize: 11,
//                     ),
//                   ),

//                   const SizedBox(height: 3),

//                   Text(
//                     name,

//                     maxLines: 1,
//                     overflow:
//                         TextOverflow.ellipsis,

//                     style:
//                         const TextStyle(
//                       color: darkText,
//                       fontSize: 19,
//                       fontWeight:
//                           FontWeight.w800,
//                     ),
//                   ),

//                   const SizedBox(height: 3),

//                   Text(
//                     '$breed • $age',

//                     maxLines: 1,
//                     overflow:
//                         TextOverflow.ellipsis,

//                     style:
//                         const TextStyle(
//                       color:
//                           secondaryText,
//                       fontSize: 12,
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   // STATUS
//                   Container(
//                     padding:
//                         const EdgeInsets
//                             .symmetric(
//                       horizontal: 10,
//                       vertical: 5,
//                     ),

//                     decoration:
//                         BoxDecoration(
//                       color:
//                           const Color(
//                         0xFFEAF8F6,
//                       ),

//                       borderRadius:
//                           BorderRadius.circular(
//                         20,
//                       ),
//                     ),

//                     child: Text(
//                       status,

//                       style:
//                           const TextStyle(
//                         color: tealColor,
//                         fontSize: 11,
//                         fontWeight:
//                             FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==================================================
//             // ARROW
//             // ==================================================

//             const Icon(
//               Icons.chevron_right_rounded,
//               color: Color(0xFF9AA9AE),
//               size: 25,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PET PLACEHOLDER
//   // ============================================================

//   Widget _petPlaceholder() {
//     return Container(
//       width: 90,
//       height: 90,

//       color: lightBlue,

//       child: const Icon(
//         Icons.pets,
//         color: primaryColor,
//         size: 35,
//       ),
//     );
//   }

//   // ============================================================
//   // APPLICATION DETAILS
//   // ============================================================

//   void _showApplicationDetails(
//     Map<String, dynamic> application,
//     int index,
//   ) {
//     final Map<String, dynamic> pet =
//         application['pet'] is Map
//             ? Map<String, dynamic>.from(
//                 application['pet'] as Map,
//               )
//             : {};

//     final String name =
//         pet['name']?.toString() ?? 'Pet';

//     final String breed =
//         pet['breed']?.toString() ?? '';

//     final String age =
//         pet['age']?.toString() ?? '';

//     final String status =
//         application['status']?.toString() ??
//             'Under Review';

//     final String image =
//         pet['image']?.toString() ?? '';

//     showModalBottomSheet(
//       context: context,

//       isScrollControlled: true,

//       backgroundColor:
//           Colors.transparent,

//       builder: (context) {
//         return Container(
//           constraints:
//               const BoxConstraints(
//             maxHeight: 650,
//           ),

//           decoration:
//               const BoxDecoration(
//             color: backgroundColor,

//             borderRadius:
//                 BorderRadius.vertical(
//               top: Radius.circular(28),
//             ),
//           ),

//           child: SingleChildScrollView(
//             physics:
//                 const BouncingScrollPhysics(),

//             padding:
//                 const EdgeInsets.fromLTRB(
//               20,
//               14,
//               20,
//               30,
//             ),

//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: [
//                 // HANDLE
//                 Center(
//                   child: Container(
//                     width: 45,
//                     height: 5,

//                     decoration:
//                         BoxDecoration(
//                       color:
//                           const Color(
//                         0xFFD2DDE0,
//                       ),

//                       borderRadius:
//                           BorderRadius.circular(
//                         10,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 // ==================================================
//                 // PET IMAGE
//                 // ==================================================

//                 if (image.isNotEmpty)
//                   ClipRRect(
//                     borderRadius:
//                         BorderRadius.circular(
//                       18,
//                     ),

//                     child: Image.network(
//                       image,

//                       width: double.infinity,
//                       height: 210,

//                       fit: BoxFit.cover,

//                       errorBuilder:
//                           (_, __, ___) {
//                         return _largePetPlaceholder();
//                       },
//                     ),
//                   )
//                 else
//                   _largePetPlaceholder(),

//                 const SizedBox(height: 18),

//                 // ==================================================
//                 // PET NAME
//                 // ==================================================

//                 Text(
//                   name,

//                   style:
//                       const TextStyle(
//                     color: darkText,
//                     fontSize: 24,
//                     fontWeight:
//                         FontWeight.w800,
//                   ),
//                 ),

//                 const SizedBox(height: 5),

//                 Text(
//                   '$breed • $age',

//                   style:
//                       const TextStyle(
//                     color: secondaryText,
//                     fontSize: 13,
//                   ),
//                 ),

//                 const SizedBox(height: 14),

//                 // ==================================================
//                 // STATUS
//                 // ==================================================

//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(
//                     horizontal: 14,
//                     vertical: 8,
//                   ),

//                   decoration:
//                       BoxDecoration(
//                     color:
//                         const Color(
//                       0xFFEAF8F6,
//                     ),

//                     borderRadius:
//                         BorderRadius.circular(
//                       20,
//                     ),
//                   ),

//                   child: Text(
//                     'Application Status: $status',

//                     style:
//                         const TextStyle(
//                       color: tealColor,
//                       fontSize: 12,
//                       fontWeight:
//                           FontWeight.w700,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // ==================================================
//                 // APPLICATION INFORMATION
//                 // ==================================================

//                 _buildInformationCard(
//                   title:
//                       'Applicant Information',
//                   icon:
//                       Icons.person_outline_rounded,
//                   items: [
//                     'Name: ${application['fullName'] ?? ''}',
//                     'Phone: ${application['phone'] ?? ''}',
//                     'Email: ${application['email'] ?? ''}',
//                     'Age: ${application['age'] ?? ''}',
//                     'Occupation: ${application['occupation'] ?? ''}',
//                   ],
//                 ),

//                 const SizedBox(height: 14),

//                 _buildInformationCard(
//                   title:
//                       'Household Information',
//                   icon:
//                       Icons.home_outlined,
//                   items: [
//                     'Household: ${application['householdType'] ?? ''}',
//                     'Address: ${application['address'] ?? ''}',
//                     'Household Members: ${application['householdMembers'] ?? ''}',
//                     'Children: ${application['children'] ?? ''}',
//                   ],
//                 ),

//                 const SizedBox(height: 14),

//                 _buildInformationCard(
//                   title:
//                       'Pet Experience',
//                   icon:
//                       Icons.pets_outlined,
//                   items: [
//                     'Experience: ${application['experienceLevel'] ?? ''}',
//                     'Previous Pets: ${application['previousPets'] ?? ''}',
//                     'Current Pets: ${application['currentPets'] ?? ''}',
//                   ],
//                 ),

//                 const SizedBox(height: 14),

//                 _buildInformationCard(
//                   title: 'Lifestyle',
//                   icon:
//                       Icons.schedule_outlined,
//                   items: [
//                     'Home Environment: ${application['homeEnvironment'] ?? ''}',
//                     'Activity Level: ${application['activityLevel'] ?? ''}',
//                     'Daily Time Available: ${application['timeAvailable'] ?? ''}',
//                   ],
//                 ),

//                 const SizedBox(height: 14),

//                 _buildInformationCard(
//                   title:
//                       'Adoption Reason',
//                   icon:
//                       Icons.favorite_border_rounded,
//                   items: [
//                     application[
//                               'adoptionReason']
//                           ?.toString() ??
//                       '',
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // ==================================================
//                 // SHELTER MESSAGE
//                 // ==================================================

//                 Container(
//                   width: double.infinity,

//                   padding:
//                       const EdgeInsets.all(16),

//                   decoration:
//                       BoxDecoration(
//                     color:
//                         const Color(
//                       0xFFFFF5EA,
//                     ),

//                     borderRadius:
//                         BorderRadius.circular(
//                       16,
//                     ),

//                     border: Border.all(
//                       color:
//                           const Color(
//                         0xFFE9C9AF,
//                       ),
//                     ),
//                   ),

//                   child: const Row(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,

//                     children: [
//                       Icon(
//                         Icons
//                             .info_outline_rounded,
//                         color:
//                             primaryColor,
//                         size: 21,
//                       ),

//                       SizedBox(width: 10),

//                       Expanded(
//                         child: Text(
//                           'Your application is currently under review. The shelter may contact you using the information you provided.',
//                           style:
//                               TextStyle(
//                             color:
//                                 Color(
//                               0xFF6E5145,
//                             ),
//                             fontSize: 12,
//                             height: 1.5,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // ==================================================
//                 // CLOSE
//                 // ==================================================

//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,

//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(
//                         context,
//                       );
//                     },

//                     style:
//                         ElevatedButton.styleFrom(
//                       backgroundColor:
//                           primaryColor,

//                       foregroundColor:
//                           Colors.white,

//                       elevation: 0,

//                       shape:
//                           RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(
//                           26,
//                         ),
//                       ),
//                     ),

//                     child: const Text(
//                       'Close',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight:
//                             FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // LARGE PET PLACEHOLDER
//   // ============================================================

//   Widget _largePetPlaceholder() {
//     return Container(
//       width: double.infinity,
//       height: 210,

//       decoration:
//           BoxDecoration(
//         color: lightBlue,

//         borderRadius:
//             BorderRadius.circular(18),
//       ),

//       child: const Icon(
//         Icons.pets,
//         color: primaryColor,
//         size: 60,
//       ),
//     );
//   }

//   // ============================================================
//   // INFORMATION CARD
//   // ============================================================

//   Widget _buildInformationCard({
//     required String title,
//     required IconData icon,
//     required List<String> items,
//   }) {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.all(16),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(16),

//         border: Border.all(
//           color: const Color(
//             0xFFD7E3E7,
//           ),
//         ),
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 35,
//                 height: 35,

//                 decoration:
//                     BoxDecoration(
//                   color: const Color(
//                     0xFFFFF4EF,
//                   ),

//                   borderRadius:
//                       BorderRadius.circular(
//                     10,
//                   ),
//                 ),

//                 child: Icon(
//                   icon,
//                   color: primaryColor,
//                   size: 19,
//                 ),
//               ),

//               const SizedBox(width: 10),

//               Expanded(
//                 child: Text(
//                   title,

//                   style:
//                       const TextStyle(
//                     color: darkText,
//                     fontSize: 15,
//                     fontWeight:
//                         FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 13),

//           ...items.map(
//             (item) {
//               return Padding(
//                 padding:
//                     const EdgeInsets.only(
//                   bottom: 7,
//                 ),

//                 child: Text(
//                   item.isEmpty
//                       ? 'Not provided'
//                       : item,

//                   style:
//                       const TextStyle(
//                     color: secondaryText,
//                     fontSize: 12,
//                     height: 1.4,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }



























// import 'package:flutter/material.dart';

// import '../adoption_application_store.dart';

// class MyApplicationsScreen extends StatefulWidget {
//   // Callback gikan sa Profile/HomeScreen
//   final VoidCallback? onBrowsePets;

//   const MyApplicationsScreen({
//     super.key,
//     this.onBrowsePets,
//   });

//   @override
//   State<MyApplicationsScreen> createState() =>
//       _MyApplicationsScreenState();
// }

// class _MyApplicationsScreenState
//     extends State<MyApplicationsScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor =
//       Color(0xFFA94327);

//   static const Color darkText =
//       Color(0xFF062B35);

//   static const Color backgroundColor =
//       Color(0xFFF5FAFD);

//   static const Color secondaryText =
//       Color(0xFF68777C);

//   static const Color lightBlue =
//       Color(0xFFE4F5FB);

//   static const Color tealColor =
//       Color(0xFF008F82);

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final bool hasApplication =
//         AdoptionApplicationStore.hasApplication;

//     return Scaffold(
//       backgroundColor: backgroundColor,

//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         elevation: 0,

//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },

//           icon: const Icon(
//             Icons.arrow_back_rounded,
//             color: darkText,
//           ),
//         ),

//         title: const Text(
//           'My Applications',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 19,
//             fontWeight: FontWeight.w800,
//           ),
//         ),

//         centerTitle: true,
//       ),

//       body: hasApplication
//           ? _buildApplication()
//           : _buildEmptyApplication(),
//     );
//   }

//   // ============================================================
//   // EMPTY APPLICATION
//   // ============================================================

//   Widget _buildEmptyApplication() {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),

//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             // ICON
//             Container(
//               width: 100,
//               height: 100,

//               decoration:
//                   const BoxDecoration(
//                 color: lightBlue,
//                 shape: BoxShape.circle,
//               ),

//               child: const Icon(
//                 Icons.description_outlined,
//                 color: primaryColor,
//                 size: 50,
//               ),
//             ),

//             const SizedBox(height: 24),

//             // TITLE
//             const Text(
//               'No Adoption Applications Yet',
//               textAlign: TextAlign.center,

//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 21,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),

//             const SizedBox(height: 10),

//             // DESCRIPTION
//             const Text(
//               'You have not submitted an adoption application yet. Browse our available pets and find your future companion.',
//               textAlign: TextAlign.center,

//               style: TextStyle(
//                 color: secondaryText,
//                 fontSize: 13,
//                 height: 1.5,
//               ),
//             ),

//             const SizedBox(height: 28),

//             // BROWSE PETS BUTTON
//             SizedBox(
//               width: double.infinity,
//               height: 52,

//               child: ElevatedButton.icon(
//                 onPressed: _browsePets,

//                 icon: const Icon(
//                   Icons.pets_rounded,
//                   size: 21,
//                 ),

//                 label: const Text(
//                   'Browse Pets',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),

//                 style:
//                     ElevatedButton.styleFrom(
//                   backgroundColor:
//                       primaryColor,

//                   foregroundColor:
//                       Colors.white,

//                   elevation: 0,

//                   shape:
//                       RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(26),
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
//   // BROWSE PETS
//   // ============================================================

//   void _browsePets() {
//     // Close My Applications first
//     Navigator.pop(context);

//     // Tell HomeScreen to switch to the Pets tab
//     // so the bottom navigation remains visible.
//     widget.onBrowsePets?.call();
//   }

//   // ============================================================
//   // APPLICATION CARD
//   // ============================================================

//   Widget _buildApplication() {
//     final application =
//         AdoptionApplicationStore.application!;

//     final Map<String, dynamic> pet =
//         Map<String, dynamic>.from(
//       application['pet'] as Map,
//     );

//     final String name =
//         pet['name']?.toString() ?? 'Pet';

//     final String breed =
//         pet['breed']?.toString() ?? '';

//     final String age =
//         pet['age']?.toString() ?? '';

//     final String status =
//         application['status']?.toString() ??
//             'Under Review';

//     final String image =
//         pet['image']?.toString() ?? '';

//     return SingleChildScrollView(
//       physics:
//           const BouncingScrollPhysics(),

//       padding: const EdgeInsets.fromLTRB(
//         20,
//         12,
//         20,
//         30,
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           // ======================================================
//           // HEADER
//           // ======================================================

//           const Text(
//             'Your Adoption Application',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 22,
//               fontWeight: FontWeight.w800,
//             ),
//           ),

//           const SizedBox(height: 6),

//           const Text(
//             'Here is the application you submitted to the shelter.',
//             style: TextStyle(
//               color: secondaryText,
//               fontSize: 13,
//               height: 1.4,
//             ),
//           ),

//           const SizedBox(height: 20),

//           // ======================================================
//           // APPLICATION STATUS
//           // ======================================================

//           Container(
//             width: double.infinity,

//             padding:
//                 const EdgeInsets.all(16),

//             decoration: BoxDecoration(
//               color: const Color(
//                 0xFFEAF8F6,
//               ),

//               borderRadius:
//                   BorderRadius.circular(16),

//               border: Border.all(
//                 color: const Color(
//                   0xFFC8E9E4,
//                 ),
//               ),
//             ),

//             child: Row(
//               children: [
//                 Container(
//                   width: 42,
//                   height: 42,

//                   decoration:
//                       const BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                   ),

//                   child: const Icon(
//                     Icons.pending_actions_rounded,
//                     color: tealColor,
//                     size: 22,
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,

//                     children: [
//                       const Text(
//                         'Application Status',
//                         style: TextStyle(
//                           color: darkText,
//                           fontSize: 12,
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),

//                       const SizedBox(height: 4),

//                       Text(
//                         status,
//                         style:
//                             const TextStyle(
//                           color: tealColor,
//                           fontSize: 16,
//                           fontWeight:
//                               FontWeight.w800,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 20),

//           // ======================================================
//           // PET CARD
//           // ======================================================

//           Container(
//             width: double.infinity,

//             padding:
//                 const EdgeInsets.all(14),

//             decoration: BoxDecoration(
//               color: Colors.white,

//               borderRadius:
//                   BorderRadius.circular(18),

//               border: Border.all(
//                 color: const Color(
//                   0xFFD7E3E7,
//                 ),
//               ),
//             ),

//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius:
//                       BorderRadius.circular(13),

//                   child: Image.network(
//                     image,

//                     width: 85,
//                     height: 85,

//                     fit: BoxFit.cover,

//                     errorBuilder:
//                         (_, __, ___) {
//                       return Container(
//                         width: 85,
//                         height: 85,

//                         color: lightBlue,

//                         child:
//                             const Icon(
//                           Icons.pets,
//                           color:
//                               primaryColor,
//                           size: 35,
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 14),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,

//                     children: [
//                       const Text(
//                         'Applying to adopt',
//                         style: TextStyle(
//                           color:
//                               secondaryText,
//                           fontSize: 11,
//                         ),
//                       ),

//                       const SizedBox(height: 4),

//                       Text(
//                         name,
//                         style:
//                             const TextStyle(
//                           color: darkText,
//                           fontSize: 20,
//                           fontWeight:
//                               FontWeight.w800,
//                         ),
//                       ),

//                       const SizedBox(height: 4),

//                       Text(
//                         '$breed • $age',
//                         style:
//                             const TextStyle(
//                           color:
//                               secondaryText,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 20),

//           // ======================================================
//           // APPLICATION INFORMATION
//           // ======================================================

//           _buildInformationCard(
//             title: 'Applicant Information',
//             icon: Icons.person_outline_rounded,
//             items: [
//               'Name: ${application['fullName'] ?? ''}',
//               'Phone: ${application['phone'] ?? ''}',
//               'Email: ${application['email'] ?? ''}',
//               'Age: ${application['age'] ?? ''}',
//               'Occupation: ${application['occupation'] ?? ''}',
//             ],
//           ),

//           const SizedBox(height: 14),

//           _buildInformationCard(
//             title: 'Household Information',
//             icon: Icons.home_outlined,
//             items: [
//               'Household: ${application['householdType'] ?? ''}',
//               'Address: ${application['address'] ?? ''}',
//               'Household Members: ${application['householdMembers'] ?? ''}',
//               'Children: ${application['children'] ?? ''}',
//             ],
//           ),

//           const SizedBox(height: 14),

//           _buildInformationCard(
//             title: 'Pet Experience',
//             icon: Icons.pets_outlined,
//             items: [
//               'Experience: ${application['experienceLevel'] ?? ''}',
//               'Previous Pets: ${application['previousPets'] ?? ''}',
//               'Current Pets: ${application['currentPets'] ?? ''}',
//             ],
//           ),

//           const SizedBox(height: 14),

//           _buildInformationCard(
//             title: 'Lifestyle',
//             icon: Icons.schedule_outlined,
//             items: [
//               'Home Environment: ${application['homeEnvironment'] ?? ''}',
//               'Activity Level: ${application['activityLevel'] ?? ''}',
//               'Daily Time Available: ${application['timeAvailable'] ?? ''}',
//             ],
//           ),

//           const SizedBox(height: 14),

//           _buildInformationCard(
//             title: 'Adoption Reason',
//             icon: Icons.favorite_border_rounded,
//             items: [
//               application['adoptionReason']
//                       ?.toString() ??
//                   '',
//             ],
//           ),

//           const SizedBox(height: 22),

//           // ======================================================
//           // SHELTER MESSAGE
//           // ======================================================

//           Container(
//             width: double.infinity,

//             padding:
//                 const EdgeInsets.all(16),

//             decoration: BoxDecoration(
//               color: const Color(
//                 0xFFFFF5EA,
//               ),

//               borderRadius:
//                   BorderRadius.circular(16),

//               border: Border.all(
//                 color: const Color(
//                   0xFFE9C9AF,
//                 ),
//               ),
//             ),

//             child: const Row(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: [
//                 Icon(
//                   Icons.info_outline_rounded,
//                   color: primaryColor,
//                   size: 21,
//                 ),

//                 SizedBox(width: 10),

//                 Expanded(
//                   child: Text(
//                     'Your application is currently under review. The shelter may contact you using the information you provided.',
//                     style: TextStyle(
//                       color: Color(
//                         0xFF6E5145,
//                       ),
//                       fontSize: 12,
//                       height: 1.5,
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
//   // INFORMATION CARD
//   // ============================================================

//   Widget _buildInformationCard({
//     required String title,
//     required IconData icon,
//     required List<String> items,
//   }) {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.all(16),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(16),

//         border: Border.all(
//           color: const Color(
//             0xFFD7E3E7,
//           ),
//         ),
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 35,
//                 height: 35,

//                 decoration:
//                     BoxDecoration(
//                   color: const Color(
//                     0xFFFFF4EF,
//                   ),

//                   borderRadius:
//                       BorderRadius.circular(
//                     10,
//                   ),
//                 ),

//                 child: Icon(
//                   icon,
//                   color: primaryColor,
//                   size: 19,
//                 ),
//               ),

//               const SizedBox(width: 10),

//               Expanded(
//                 child: Text(
//                   title,
//                   style:
//                       const TextStyle(
//                     color: darkText,
//                     fontSize: 15,
//                     fontWeight:
//                         FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 13),

//           ...items.map(
//             (item) {
//               return Padding(
//                 padding:
//                     const EdgeInsets.only(
//                   bottom: 7,
//                 ),

//                 child: Text(
//                   item.isEmpty
//                       ? 'Not provided'
//                       : item,

//                   style:
//                       const TextStyle(
//                     color: secondaryText,
//                     fontSize: 12,
//                     height: 1.4,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }





















// import 'package:flutter/material.dart';

// import '../adoption_application_store.dart';
// import 'pets_screen.dart';

// class MyApplicationsScreen extends StatefulWidget {
//   const MyApplicationsScreen({super.key});

//   @override
//   State<MyApplicationsScreen> createState() =>
//       _MyApplicationsScreenState();
// }

// class _MyApplicationsScreenState
//     extends State<MyApplicationsScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor =
//       Color(0xFFA94327);

//   static const Color darkText =
//       Color(0xFF062B35);

//   static const Color backgroundColor =
//       Color(0xFFF5FAFD);

//   static const Color secondaryText =
//       Color(0xFF68777C);

//   static const Color lightBlue =
//       Color(0xFFE4F5FB);

//   static const Color tealColor =
//       Color(0xFF008F82);

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final bool hasApplication =
//         AdoptionApplicationStore.hasApplication;

//     return Scaffold(
//       backgroundColor: backgroundColor,

//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         elevation: 0,

//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },

//           icon: const Icon(
//             Icons.arrow_back_rounded,
//             color: darkText,
//           ),
//         ),

//         title: const Text(
//           'My Applications',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 19,
//             fontWeight: FontWeight.w800,
//           ),
//         ),

//         centerTitle: true,
//       ),

//       body: hasApplication
//           ? _buildApplication()
//           : _buildEmptyApplication(),
//     );
//   }

//   // ============================================================
//   // EMPTY APPLICATION
//   // ============================================================

//   Widget _buildEmptyApplication() {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),

//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             // ICON
//             Container(
//               width: 100,
//               height: 100,

//               decoration:
//                   const BoxDecoration(
//                 color: lightBlue,
//                 shape: BoxShape.circle,
//               ),

//               child: const Icon(
//                 Icons.description_outlined,
//                 color: primaryColor,
//                 size: 50,
//               ),
//             ),

//             const SizedBox(height: 24),

//             // TITLE
//             const Text(
//               'No Adoption Applications Yet',
//               textAlign: TextAlign.center,

//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 21,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),

//             const SizedBox(height: 10),

//             // DESCRIPTION
//             const Text(
//               'You have not submitted an adoption application yet. Browse our available pets and find your future companion.',
//               textAlign: TextAlign.center,

//               style: TextStyle(
//                 color: secondaryText,
//                 fontSize: 13,
//                 height: 1.5,
//               ),
//             ),

//             const SizedBox(height: 28),

//             // BROWSE PETS BUTTON
//             SizedBox(
//               width: double.infinity,
//               height: 52,

//               child: ElevatedButton.icon(
//                 onPressed: _browsePets,

//                 icon: const Icon(
//                   Icons.pets_rounded,
//                   size: 21,
//                 ),

//                 label: const Text(
//                   'Browse Pets',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),

//                 style:
//                     ElevatedButton.styleFrom(
//                   backgroundColor:
//                       primaryColor,

//                   foregroundColor:
//                       Colors.white,

//                   elevation: 0,

//                   shape:
//                       RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(26),
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
//   // BROWSE PETS
//   // ============================================================

//   void _browsePets() {
//     Navigator.push(
//       context,

//       MaterialPageRoute(
//         builder: (_) =>
//             const PetsScreen(),
//       ),
//     );
//   }

//   // ============================================================
//   // APPLICATION CARD
//   // ============================================================

//   Widget _buildApplication() {
//     final application =
//         AdoptionApplicationStore.application!;

//     final Map<String, dynamic> pet =
//         Map<String, dynamic>.from(
//       application['pet'] as Map,
//     );

//     final String name =
//         pet['name']?.toString() ?? 'Pet';

//     final String breed =
//         pet['breed']?.toString() ?? '';

//     final String age =
//         pet['age']?.toString() ?? '';

//     final String status =
//         application['status']?.toString() ??
//             'Under Review';

//     final String image =
//         pet['image']?.toString() ?? '';

//     return SingleChildScrollView(
//       physics:
//           const BouncingScrollPhysics(),

//       padding: const EdgeInsets.fromLTRB(
//         20,
//         12,
//         20,
//         30,
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           // ======================================================
//           // HEADER
//           // ======================================================

//           const Text(
//             'Your Adoption Application',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 22,
//               fontWeight: FontWeight.w800,
//             ),
//           ),

//           const SizedBox(height: 6),

//           const Text(
//             'Here is the application you submitted to the shelter.',
//             style: TextStyle(
//               color: secondaryText,
//               fontSize: 13,
//               height: 1.4,
//             ),
//           ),

//           const SizedBox(height: 20),

//           // ======================================================
//           // APPLICATION STATUS
//           // ======================================================

//           Container(
//             width: double.infinity,

//             padding:
//                 const EdgeInsets.all(16),

//             decoration: BoxDecoration(
//               color: const Color(
//                 0xFFEAF8F6,
//               ),

//               borderRadius:
//                   BorderRadius.circular(16),

//               border: Border.all(
//                 color: const Color(
//                   0xFFC8E9E4,
//                 ),
//               ),
//             ),

//             child: Row(
//               children: [
//                 Container(
//                   width: 42,
//                   height: 42,

//                   decoration:
//                       const BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                   ),

//                   child: const Icon(
//                     Icons.pending_actions_rounded,
//                     color: tealColor,
//                     size: 22,
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,

//                     children: [
//                       const Text(
//                         'Application Status',
//                         style: TextStyle(
//                           color: darkText,
//                           fontSize: 12,
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),

//                       const SizedBox(height: 4),

//                       Text(
//                         status,
//                         style:
//                             const TextStyle(
//                           color: tealColor,
//                           fontSize: 16,
//                           fontWeight:
//                               FontWeight.w800,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 20),

//           // ======================================================
//           // PET CARD
//           // ======================================================

//           Container(
//             width: double.infinity,

//             padding:
//                 const EdgeInsets.all(14),

//             decoration: BoxDecoration(
//               color: Colors.white,

//               borderRadius:
//                   BorderRadius.circular(18),

//               border: Border.all(
//                 color: const Color(
//                   0xFFD7E3E7,
//                 ),
//               ),
//             ),

//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius:
//                       BorderRadius.circular(13),

//                   child: Image.network(
//                     image,

//                     width: 85,
//                     height: 85,

//                     fit: BoxFit.cover,

//                     errorBuilder:
//                         (_, __, ___) {
//                       return Container(
//                         width: 85,
//                         height: 85,

//                         color: lightBlue,

//                         child:
//                             const Icon(
//                           Icons.pets,
//                           color:
//                               primaryColor,
//                           size: 35,
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 14),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,

//                     children: [
//                       const Text(
//                         'Applying to adopt',
//                         style: TextStyle(
//                           color:
//                               secondaryText,
//                           fontSize: 11,
//                         ),
//                       ),

//                       const SizedBox(height: 4),

//                       Text(
//                         name,
//                         style:
//                             const TextStyle(
//                           color: darkText,
//                           fontSize: 20,
//                           fontWeight:
//                               FontWeight.w800,
//                         ),
//                       ),

//                       const SizedBox(height: 4),

//                       Text(
//                         '$breed • $age',
//                         style:
//                             const TextStyle(
//                           color:
//                               secondaryText,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 20),

//           // ======================================================
//           // APPLICATION INFORMATION
//           // ======================================================

//           _buildInformationCard(
//             title: 'Applicant Information',
//             icon: Icons.person_outline_rounded,
//             items: [
//               'Name: ${application['fullName'] ?? ''}',
//               'Phone: ${application['phone'] ?? ''}',
//               'Email: ${application['email'] ?? ''}',
//               'Age: ${application['age'] ?? ''}',
//               'Occupation: ${application['occupation'] ?? ''}',
//             ],
//           ),

//           const SizedBox(height: 14),

//           _buildInformationCard(
//             title: 'Household Information',
//             icon: Icons.home_outlined,
//             items: [
//               'Household: ${application['householdType'] ?? ''}',
//               'Address: ${application['address'] ?? ''}',
//               'Household Members: ${application['householdMembers'] ?? ''}',
//               'Children: ${application['children'] ?? ''}',
//             ],
//           ),

//           const SizedBox(height: 14),

//           _buildInformationCard(
//             title: 'Pet Experience',
//             icon: Icons.pets_outlined,
//             items: [
//               'Experience: ${application['experienceLevel'] ?? ''}',
//               'Previous Pets: ${application['previousPets'] ?? ''}',
//               'Current Pets: ${application['currentPets'] ?? ''}',
//             ],
//           ),

//           const SizedBox(height: 14),

//           _buildInformationCard(
//             title: 'Lifestyle',
//             icon: Icons.schedule_outlined,
//             items: [
//               'Home Environment: ${application['homeEnvironment'] ?? ''}',
//               'Activity Level: ${application['activityLevel'] ?? ''}',
//               'Daily Time Available: ${application['timeAvailable'] ?? ''}',
//             ],
//           ),

//           const SizedBox(height: 14),

//           _buildInformationCard(
//             title: 'Adoption Reason',
//             icon: Icons.favorite_border_rounded,
//             items: [
//               application['adoptionReason']
//                       ?.toString() ??
//                   '',
//             ],
//           ),

//           const SizedBox(height: 22),

//           // ======================================================
//           // SHELTER MESSAGE
//           // ======================================================

//           Container(
//             width: double.infinity,

//             padding:
//                 const EdgeInsets.all(16),

//             decoration: BoxDecoration(
//               color: const Color(
//                 0xFFFFF5EA,
//               ),

//               borderRadius:
//                   BorderRadius.circular(16),

//               border: Border.all(
//                 color: const Color(
//                   0xFFE9C9AF,
//                 ),
//               ),
//             ),

//             child: const Row(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: [
//                 Icon(
//                   Icons.info_outline_rounded,
//                   color: primaryColor,
//                   size: 21,
//                 ),

//                 SizedBox(width: 10),

//                 Expanded(
//                   child: Text(
//                     'Your application is currently under review. The shelter may contact you using the information you provided.',
//                     style: TextStyle(
//                       color: Color(
//                         0xFF6E5145,
//                       ),
//                       fontSize: 12,
//                       height: 1.5,
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
//   // INFORMATION CARD
//   // ============================================================

//   Widget _buildInformationCard({
//     required String title,
//     required IconData icon,
//     required List<String> items,
//   }) {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.all(16),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(16),

//         border: Border.all(
//           color: const Color(
//             0xFFD7E3E7,
//           ),
//         ),
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 35,
//                 height: 35,

//                 decoration:
//                     BoxDecoration(
//                   color: const Color(
//                     0xFFFFF4EF,
//                   ),

//                   borderRadius:
//                       BorderRadius.circular(
//                     10,
//                   ),
//                 ),

//                 child: Icon(
//                   icon,
//                   color: primaryColor,
//                   size: 19,
//                 ),
//               ),

//               const SizedBox(width: 10),

//               Expanded(
//                 child: Text(
//                   title,
//                   style:
//                       const TextStyle(
//                     color: darkText,
//                     fontSize: 15,
//                     fontWeight:
//                         FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 13),

//           ...items.map(
//             (item) {
//               return Padding(
//                 padding:
//                     const EdgeInsets.only(
//                   bottom: 7,
//                 ),

//                 child: Text(
//                   item.isEmpty
//                       ? 'Not provided'
//                       : item,

//                   style:
//                       const TextStyle(
//                     color: secondaryText,
//                     fontSize: 12,
//                     height: 1.4,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }





















// import 'package:flutter/material.dart';
// import '../adoption_application_store.dart';

// class MyApplicationsScreen extends StatefulWidget {
//   const MyApplicationsScreen({super.key});

//   @override
//   State<MyApplicationsScreen> createState() =>
//       _MyApplicationsScreenState();
// }

// class _MyApplicationsScreenState
//     extends State<MyApplicationsScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor = Color(0xFFA94327);
//   static const Color darkText = Color(0xFF062B35);
//   static const Color backgroundColor = Color(0xFFEFF9FD);
//   static const Color secondaryText = Color(0xFF68777C);
//   static const Color lightBlue = Color(0xFFE4F5FB);
//   static const Color lightPrimary = Color(0xFFFFF4EF);
//   static const Color borderColor = Color(0xFFD7E3E7);

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final applications =
//         AdoptionApplicationStore.getApplications();

//     return Scaffold(
//       backgroundColor: backgroundColor,

//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         elevation: 0,
//         centerTitle: true,

//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(
//             Icons.arrow_back_rounded,
//             color: darkText,
//           ),
//         ),

//         title: const Text(
//           'My Applications',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 18,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ),

//       body: applications.isEmpty
//           ? _buildEmptyState()
//           : RefreshIndicator(
//               color: primaryColor,
//               onRefresh: () async {
//                 setState(() {});
//               },
//               child: ListView.builder(
//                 physics: const BouncingScrollPhysics(
//                   parent: AlwaysScrollableScrollPhysics(),
//                 ),
//                 padding: const EdgeInsets.fromLTRB(
//                   20,
//                   10,
//                   20,
//                   30,
//                 ),
//                 itemCount: applications.length,
//                 itemBuilder: (context, index) {
//                   return _buildApplicationCard(
//                     applications[index],
//                   );
//                 },
//               ),
//             ),
//     );
//   }

//   // ============================================================
//   // EMPTY STATE
//   // ============================================================

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),

//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,

//           children: [
//             Container(
//               width: 90,
//               height: 90,

//               decoration: const BoxDecoration(
//                 color: lightPrimary,
//                 shape: BoxShape.circle,
//               ),

//               child: const Icon(
//                 Icons.description_outlined,
//                 color: primaryColor,
//                 size: 44,
//               ),
//             ),

//             const SizedBox(height: 22),

//             const Text(
//               'No Applications Yet',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 22,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),

//             const SizedBox(height: 10),

//             const Text(
//               'When you apply to adopt a pet, your application will appear here.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: secondaryText,
//                 fontSize: 13,
//                 height: 1.5,
//               ),
//             ),

//             const SizedBox(height: 25),

//             SizedBox(
//               height: 48,

//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },

//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   foregroundColor: Colors.white,
//                   elevation: 0,

//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                   ),

//                   shape: RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(25),
//                   ),
//                 ),

//                 icon: const Icon(
//                   Icons.pets_rounded,
//                   size: 19,
//                 ),

//                 label: const Text(
//                   'Browse Pets',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
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
//   // APPLICATION CARD
//   // ============================================================

//   Widget _buildApplicationCard(
//     Map<String, dynamic> application,
//   ) {
//     final Map<String, dynamic> pet =
//         Map<String, dynamic>.from(
//       application['pet'] ?? {},
//     );

//     final String petName =
//         pet['name']?.toString() ?? 'Pet';

//     final String breed =
//         pet['breed']?.toString() ?? '';

//     final String age =
//         pet['age']?.toString() ?? '';

//     final String image =
//         pet['image']?.toString() ?? '';

//     final String status =
//         application['status']?.toString() ??
//             'Under Review';

//     final DateTime? submittedAt =
//         application['submittedAt'] is DateTime
//             ? application['submittedAt']
//             : null;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),

//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),

//         border: Border.all(
//           color: borderColor,
//         ),

//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x10000000),
//             blurRadius: 10,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),

//       child: Column(
//         children: [
//           // ====================================================
//           // PET INFORMATION
//           // ====================================================

//           Padding(
//             padding: const EdgeInsets.all(15),

//             child: Row(
//               children: [
//                 // IMAGE
//                 ClipRRect(
//                   borderRadius:
//                       BorderRadius.circular(13),

//                   child: Image.network(
//                     image,

//                     width: 82,
//                     height: 82,

//                     fit: BoxFit.cover,

//                     errorBuilder:
//                         (_, __, ___) {
//                       return Container(
//                         width: 82,
//                         height: 82,
//                         color: lightBlue,

//                         child: const Icon(
//                           Icons.pets,
//                           color: primaryColor,
//                           size: 32,
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 14),

//                 // DETAILS
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,

//                     children: [
//                       const Text(
//                         'Adoption Application',
//                         style: TextStyle(
//                           color: secondaryText,
//                           fontSize: 11,
//                         ),
//                       ),

//                       const SizedBox(height: 4),

//                       Text(
//                         petName,
//                         style: const TextStyle(
//                           color: darkText,
//                           fontSize: 19,
//                           fontWeight:
//                               FontWeight.w800,
//                         ),
//                       ),

//                       const SizedBox(height: 4),

//                       Text(
//                         '$breed • $age',
//                         style: const TextStyle(
//                           color: secondaryText,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ====================================================
//           // STATUS
//           // ====================================================

//           Container(
//             width: double.infinity,

//             padding: const EdgeInsets.symmetric(
//               horizontal: 15,
//               vertical: 12,
//             ),

//             decoration: const BoxDecoration(
//               color: Color(0xFFF8FCFD),

//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(18),
//                 bottomRight: Radius.circular(18),
//               ),
//             ),

//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.access_time_rounded,
//                   color: Color(0xFF078F80),
//                   size: 18,
//                 ),

//                 const SizedBox(width: 8),

//                 const Expanded(
//                   child: Text(
//                     'Application Status',
//                     style: TextStyle(
//                       color: darkText,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),

//                 _buildStatusBadge(status),
//               ],
//             ),
//           ),

//           // ====================================================
//           // SUBMITTED DATE
//           // ====================================================

//           if (submittedAt != null)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 15,
//                 0,
//                 15,
//                 13,
//               ),

//               child: Align(
//                 alignment: Alignment.centerLeft,

//                 child: Text(
//                   'Submitted: ${_formatDate(submittedAt)}',
//                   style: const TextStyle(
//                     color: secondaryText,
//                     fontSize: 11,
//                   ),
//                 ),
//               ),
//             ),

//           // ====================================================
//           // VIEW APPLICATION
//           // ====================================================

//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               15,
//               0,
//               15,
//               15,
//             ),

//             child: SizedBox(
//               width: double.infinity,
//               height: 44,

//               child: OutlinedButton(
//                 onPressed: () {
//                   _showApplicationDetails(
//                     application,
//                   );
//                 },

//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: primaryColor,

//                   side: const BorderSide(
//                     color: primaryColor,
//                     width: 1.2,
//                   ),

//                   shape: RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(22),
//                   ),
//                 ),

//                 child: const Text(
//                   'View Application',
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
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
//   // STATUS BADGE
//   // ============================================================

//   Widget _buildStatusBadge(String status) {
//     Color background;
//     Color textColor;
//     IconData icon;

//     switch (status) {
//       case 'Approved':
//         background = const Color(0xFFE2F6ED);
//         textColor = const Color(0xFF16804B);
//         icon = Icons.check_circle_outline_rounded;
//         break;

//       case 'Rejected':
//         background = const Color(0xFFFFE9E9);
//         textColor = const Color(0xFFC0392B);
//         icon = Icons.cancel_outlined;
//         break;

//       default:
//         background = const Color(0xFFE1F4F1);
//         textColor = const Color(0xFF078F80);
//         icon = Icons.hourglass_top_rounded;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 11,
//         vertical: 7,
//       ),

//       decoration: BoxDecoration(
//         color: background,
//         borderRadius: BorderRadius.circular(20),
//       ),

//       child: Row(
//         mainAxisSize: MainAxisSize.min,

//         children: [
//           Icon(
//             icon,
//             color: textColor,
//             size: 15,
//           ),

//           const SizedBox(width: 5),

//           Text(
//             status,
//             style: TextStyle(
//               color: textColor,
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // APPLICATION DETAILS
//   // ============================================================

//   void _showApplicationDetails(
//     Map<String, dynamic> application,
//   ) {
//     final Map<String, dynamic> pet =
//         Map<String, dynamic>.from(
//       application['pet'] ?? {},
//     );

//     showModalBottomSheet(
//       context: context,

//       backgroundColor: Colors.transparent,

//       isScrollControlled: true,

//       builder: (context) {
//         return Container(
//           height:
//               MediaQuery.of(context).size.height *
//                   0.82,

//           decoration: const BoxDecoration(
//             color: Colors.white,

//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(25),
//               topRight: Radius.circular(25),
//             ),
//           ),

//           child: Column(
//             children: [
//               // HANDLE
//               const SizedBox(height: 10),

//               Container(
//                 width: 45,
//                 height: 5,

//                 decoration: BoxDecoration(
//                   color: const Color(0xFFD0D8DA),
//                   borderRadius:
//                       BorderRadius.circular(10),
//                 ),
//               ),

//               const SizedBox(height: 15),

//               // TITLE
//               const Text(
//                 'Application Details',
//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 19,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),

//               const SizedBox(height: 15),

//               Expanded(
//                 child: SingleChildScrollView(
//                   physics:
//                       const BouncingScrollPhysics(),

//                   padding:
//                       const EdgeInsets.fromLTRB(
//                     20,
//                     0,
//                     20,
//                     30,
//                   ),

//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,

//                     children: [
//                       _buildDetailPetCard(pet),

//                       const SizedBox(height: 18),

//                       _buildDetailSection(
//                         title:
//                             'Personal Information',
//                         items: [
//                           _detail(
//                             'Full Name',
//                             application[
//                                     'fullName']
//                                 ?.toString(),
//                           ),
//                           _detail(
//                             'Phone',
//                             application[
//                                     'phone']
//                                 ?.toString(),
//                           ),
//                           _detail(
//                             'Email',
//                             application[
//                                     'email']
//                                 ?.toString(),
//                           ),
//                           _detail(
//                             'Age',
//                             application[
//                                     'age']
//                                 ?.toString(),
//                           ),
//                           _detail(
//                             'Occupation',
//                             application[
//                                     'occupation']
//                                 ?.toString(),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 14),

//                       _buildDetailSection(
//                         title:
//                             'Household Information',
//                         items: [
//                           _detail(
//                             'Household',
//                             application[
//                                     'householdType']
//                                 ?.toString(),
//                           ),
//                           _detail(
//                             'Address',
//                             application[
//                                     'address']
//                                 ?.toString(),
//                           ),
//                           _detail(
//                             'Members',
//                             application[
//                                     'householdMembers']
//                                 ?.toString(),
//                           ),
//                           _detail(
//                             'Children',
//                             application[
//                                     'children']
//                                 ?.toString(),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 14),

//                       _buildDetailSection(
//                         title:
//                             'Pet Experience',
//                         items: [
//                           _detail(
//                             'Experience',
//                             application[
//                                     'experienceLevel']
//                                 ?.toString(),
//                           ),
//                           _detail(
//                             'Previous Pets',
//                             application[
//                                     'previousPets']
//                                 ?.toString(),
//                           ),
//                           _detail(
//                             'Current Pets',
//                             application[
//                                     'currentPets']
//                                 ?.toString(),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 14),

//                       _buildDetailSection(
//                         title:
//                             'Lifestyle',
//                         items: [
//                           _detail(
//                             'Home Environment',
//                             application[
//                                     'homeEnvironment']
//                                 ?.toString(),
//                           ),
//                           _detail(
//                             'Activity Level',
//                             application[
//                                     'activityLevel']
//                                 ?.toString(),
//                           ),
//                           _detail(
//                             'Time Available',
//                             application[
//                                     'timeAvailable']
//                                 ?.toString(),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 14),

//                       _buildDetailSection(
//                         title:
//                             'Adoption Reason',
//                         items: [
//                           _detail(
//                             'Reason',
//                             application[
//                                     'adoptionReason']
//                                 ?.toString(),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // PET DETAIL CARD
//   // ============================================================

//   Widget _buildDetailPetCard(
//     Map<String, dynamic> pet,
//   ) {
//     final String image =
//         pet['image']?.toString() ?? '';

//     final String name =
//         pet['name']?.toString() ?? 'Pet';

//     final String breed =
//         pet['breed']?.toString() ?? '';

//     return Container(
//       padding: const EdgeInsets.all(14),

//       decoration: BoxDecoration(
//         color: lightPrimary,
//         borderRadius: BorderRadius.circular(16),
//       ),

//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius:
//                 BorderRadius.circular(12),

//             child: Image.network(
//               image,
//               width: 70,
//               height: 70,
//               fit: BoxFit.cover,

//               errorBuilder:
//                   (_, __, ___) {
//                 return Container(
//                   width: 70,
//                   height: 70,
//                   color: lightBlue,

//                   child: const Icon(
//                     Icons.pets,
//                     color: primaryColor,
//                   ),
//                 );
//               },
//             ),
//           ),

//           const SizedBox(width: 13),

//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: [
//                 const Text(
//                   'Applying to adopt',
//                   style: TextStyle(
//                     color: secondaryText,
//                     fontSize: 11,
//                   ),
//                 ),

//                 const SizedBox(height: 3),

//                 Text(
//                   name,
//                   style: const TextStyle(
//                     color: darkText,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),

//                 const SizedBox(height: 3),

//                 Text(
//                   breed,
//                   style: const TextStyle(
//                     color: secondaryText,
//                     fontSize: 12,
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
//   // DETAIL SECTION
//   // ============================================================

//   Widget _buildDetailSection({
//     required String title,
//     required List<Map<String, String>> items,
//   }) {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.all(15),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius: BorderRadius.circular(16),

//         border: Border.all(
//           color: borderColor,
//         ),
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               color: darkText,
//               fontSize: 15,
//               fontWeight: FontWeight.w800,
//             ),
//           ),

//           const SizedBox(height: 12),

//           ...items.map(
//             (item) {
//               return Padding(
//                 padding:
//                     const EdgeInsets.only(
//                   bottom: 9,
//                 ),

//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,

//                   children: [
//                     Text(
//                       item['label'] ?? '',
//                       style: const TextStyle(
//                         color: secondaryText,
//                         fontSize: 11,
//                       ),
//                     ),

//                     const SizedBox(height: 2),

//                     Text(
//                       item['value']?.isEmpty ??
//                               true
//                           ? 'Not provided'
//                           : item['value']!,
//                       style: const TextStyle(
//                         color: darkText,
//                         fontSize: 13,
//                         height: 1.4,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // DETAIL HELPER
//   // ============================================================

//   Map<String, String> _detail(
//     String label,
//     String? value,
//   ) {
//     return {
//       'label': label,
//       'value': value ?? '',
//     };
//   }

//   // ============================================================
//   // DATE
//   // ============================================================

//   String _formatDate(DateTime date) {
//     final month = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];

//     return '${month[date.month - 1]} '
//         '${date.day}, ${date.year}';
//   }
// }