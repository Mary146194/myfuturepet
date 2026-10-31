import 'package:flutter/material.dart';

import '../adoption_application_store.dart';
import '../adoption_journey.dart';
import '../services/adoption_journey_service.dart';
import '../widgets/adoption_journey_tracker.dart';
import 'pets_screen.dart';
import 'visit_appointment_screen.dart';

/// Badge colours for a journey status, shared by the list and details.
({Color bg, Color fg}) journeyBadgeColors(AdoptionJourney? journey) {
  if (journey?.halted ?? false) {
    return (bg: const Color(0xFFFEE2E2), fg: const Color(0xFFDC2626));
  }
  if (journey == null || journey.stage.index <= JourneyStage.reviewing.index) {
    return (bg: const Color(0xFFFEF3C7), fg: const Color(0xFFD97706));
  }
  if (journey.isComplete) {
    return (bg: const Color(0xFFE8F5E9), fg: const Color(0xFF2E7D32));
  }
  return (bg: const Color(0xFFEAF8F6), fg: const Color(0xFF008F82));
}

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

  static const Color borderColor =
      Color(0xFFD7E3E7);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  // The journey service refreshes the application store from the same rows,
  // so the list, badges and roads always agree.
  Future<void> _refresh() async {
    await Future.wait([
      AdoptionApplicationStore.syncWithSupabase(),
      AdoptionJourneyService().refresh(),
    ]);
    if (mounted) setState(() {});
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // Rebuild whenever realtime moves a journey (store is updated with it)
    // or a celebration finishes (the adoption then moves to history).
    final service = AdoptionJourneyService();
    return ListenableBuilder(
      listenable: Listenable.merge([service.journeys, service.celebrations]),
      builder: (context, _) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
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
                        BorderRadius.circular(16),
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
                  for (final stage in JourneyStage.values) ...[
                    if (stage.index > 0) const SizedBox(height: 8),
                    _buildAdoptionStepRow(
                      '${stage.index + 1}',
                      _stageExplainer[stage]!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The same five stages as the Profile "Progress Road".
  static const Map<JourneyStage, String> _stageExplainer = {
    JourneyStage.submitted:
        'Application Submitted: find a pet you love and apply.',
    JourneyStage.reviewing:
        'Reviewing Details: shelter volunteers check your application.',
    JourneyStage.interview:
        'Scheduling Interview: once approved, book a meet & greet.',
    JourneyStage.meetAndGreet:
        'Meet & Greet: visit the shelter to meet your future pet.',
    JourneyStage.welcomeHome:
        'Welcome Home!: the shelter marks your pet adopted.',
  };

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
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: _refresh,
      child: ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),

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

        Builder(
          builder: (context) {
            final done = applications.where(_isDone).length;
            final active = applications.length - done;
            return Text(
              '$active in progress • $done done',
              style: const TextStyle(
                color: secondaryText,
                fontSize: 13,
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // ======================================================
        // APPLICATION CARDS: in progress, then adoption history
        // ======================================================

        ..._buildSections(applications),
      ],
      ),
    );
  }

  /// Done = pet went home, rejected or withdrawn (same rule as the journey).
  bool _isDone(Map<String, dynamic> application) {
    final journey = AdoptionJourneyService().journeyFor(
      application['id']?.toString(),
    );
    return journey != null
        ? !journey.isActive
        : AdoptionApplicationStore.isDone(application);
  }

  /// Finished applications leave the active list for "Application History".
  List<Widget> _buildSections(List<Map<String, dynamic>> applications) {
    final service = AdoptionJourneyService();
    final inProgress = applications.where((a) => !_isDone(a)).toList();
    DateTime endOf(Map<String, dynamic> a) {
      final j = service.journeyFor(a['id']?.toString());
      return j?.finishedAt ??
          j?.submittedAt ??
          DateTime.tryParse(a['submittedAt']?.toString() ?? '') ??
          DateTime(0);
    }

    final history = applications.where(_isDone).toList()
      ..sort((a, b) => endOf(b).compareTo(endOf(a)));

    Widget card(Map<String, dynamic> application, {bool inHistory = false}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildApplicationCard(
            application,
            0,
            inHistory: inHistory,
          ),
        );

    return [
      if (inProgress.isEmpty)
        _buildNothingInProgress()
      else
        ...inProgress.map(card),
      if (history.isNotEmpty) ...[
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(Icons.history_rounded, size: 18, color: primaryColor),
            SizedBox(width: 6),
            Text(
              'Application History',
              style: TextStyle(
                color: darkText,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...history.map((a) => card(a, inHistory: true)),
      ],
    ];
  }

  Widget _buildNothingInProgress() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF2E7D32),
            size: 22,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'No applications in progress. Your finished applications are in the history below.',
              style: TextStyle(
                color: secondaryText,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          TextButton(
            onPressed: _browsePets,
            child: const Text(
              'Browse Pets',
              style: TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APPLICATION CARD
  // ============================================================

  Widget _buildApplicationCard(
    Map<String, dynamic> application,
    int index, {
    bool inHistory = false,
  }) {
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

    final journey = AdoptionJourneyService().journeyFor(
      application['id']?.toString(),
    );
    final String status =
        journey?.statusLabel ??
        application['status']?.toString() ??
            'Pending';

    final String submittedAt =
        application['submittedAt']?.toString() ??
            '';

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: borderColor,
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
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
                    BorderRadius.circular(12),

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
                          final colors = journeyBadgeColors(journey);
                          final badgeBg = colors.bg;
                          final badgeText = colors.fg;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(16),
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

          // ADOPTION JOURNEY (same road as the Profile dashboard).
          // History cards just keep their outcome badge.
          if (journey != null && !inHistory) ...[
            ValueListenableBuilder<Set<String>>(
              valueListenable: AdoptionJourneyService().celebrations,
              builder: (context, celebrations, _) => AdoptionJourneyTracker(
                key: ValueKey('road-${journey.applicationId}'),
                journey: journey,
                isDark: false,
                compact: true,
                celebrate: celebrations.contains(journey.applicationId),
                onCelebrated: () => AdoptionJourneyService().markCelebrated(
                  journey.applicationId,
                ),
                onBookMeetAndGreet: () async {
                  await VisitAppointmentScreen.openMeetAndGreet(
                    context,
                    journey,
                  );
                  if (mounted) setState(() {});
                },
              ),
            ),
            const SizedBox(height: 12),
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

    // Follow realtime so the details never contradict the Profile road.
    return ValueListenableBuilder<List<AdoptionJourney>>(
      valueListenable: AdoptionJourneyService().journeys,
      builder: (context, _, _) {
        final journey = AdoptionJourneyService().journeyFor(
          application['id']?.toString(),
        );
        return _buildScaffold(context, name, breed, age, image, journey);
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    String name,
    String breed,
    String age,
    String image,
    AdoptionJourney? journey,
  ) {
    final String status =
        journey?.statusLabel ??
        application['status']?.toString() ??
            'Pending';

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
                    BorderRadius.circular(16),

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

            _buildStatusCard(context, status, journey),

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
                      'The shelter may contact you using the information you provided.',
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
    BuildContext context,
    String status,
    AdoptionJourney? journey,
  ) {
    final colors = journeyBadgeColors(journey);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.route_rounded,
                  color: colors.fg,
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
                      'Adoption Journey',
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
                      style: TextStyle(
                        color: colors.fg,
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
          if (journey != null) ...[
            const SizedBox(height: 16),
            AdoptionJourneyTracker(
              key: ValueKey('details-road-${journey.applicationId}'),
              journey: journey,
              isDark: false,
              compact: true,
              onBookMeetAndGreet: () =>
                  VisitAppointmentScreen.openMeetAndGreet(context, journey),
            ),
          ],
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
