import 'package:flutter/material.dart';

import '../adoption_journey.dart';
import '../appointment_store.dart';
import '../services/adoption_journey_service.dart';
import '../services/appointment_service.dart';
import 'pets_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  final VoidCallback? onBrowsePets;
  final AppointmentService? appointmentService;

  const MyAppointmentsScreen({
    super.key,
    this.onBrowsePets,
    this.appointmentService,
  });

  @override
  State<MyAppointmentsScreen> createState() =>
      _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState
    extends State<MyAppointmentsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFA94327);
  static const Color darkText = Color(0xFF062B35);
  static const Color backgroundColor = Color(0xFFF5FAFD);
  static const Color secondaryText = Color(0xFF68777C);
  static const Color lightBlue = Color(0xFFE4F5FB);
  static const Color tealColor = Color(0xFF008F82);

  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  // ============================================================
  // REFRESH WHEN SCREEN OPENS
  // ============================================================

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      await AppointmentStore.syncWithSupabase(
        service: widget.appointmentService, throwOnError: true,
      );
      // Keep the adoption journey (and its stage chips) in step.
      await AdoptionJourneyService().refresh();
    } catch (_) {
      if (mounted) _loadFailed = true;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // Realtime journey refreshes also update AppointmentStore, so a visit the
    // shelter confirms shows here without reopening the screen.
    return ValueListenableBuilder<List<AdoptionJourney>>(
      valueListenable: AdoptionJourneyService().journeys,
      builder: (context, _, _) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final applications =
        AppointmentStore.getAllAppointments();

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
          'My Appointments',
          style: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,
        actions: [IconButton(
          tooltip: 'Refresh appointments',
          onPressed: _loading ? null : _refresh,
          icon: const Icon(Icons.refresh),
        )],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadFailed
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Unable to load appointments. Please try again.'),
                  TextButton(onPressed: _refresh, child: const Text('Retry')),
                ]))
          : applications.isEmpty
          ? _buildEmptyAppointments()
          : _buildAppointmentList(applications),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyAppointments() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,

              decoration: const BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.calendar_month_outlined,
                color: primaryColor,
                size: 50,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No Appointments Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'You have not scheduled an appointment yet. Visit our available pets and schedule a visit with your future companion.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryText,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

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

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // SHELTER VISITING GUIDELINES
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF008F82), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Visiting Jagna Rescue Shelter',
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Visiting hours: Monday to Saturday, 9:00 AM – 4:00 PM.',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 12,
                      height: 1.4,
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
  // APPOINTMENT LIST
  // ============================================================

  Widget _buildAppointmentList(
    List<Map<String, dynamic>> appointments,
  ) {
    return RefreshIndicator(
      color: primaryColor,

      onRefresh: _refresh,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          30,
        ),

        children: [
          const Text(
            'Your Appointments',
            style: TextStyle(
              color: darkText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '${AppointmentStore.activeCount} upcoming • '
            '${AppointmentStore.historyAppointments.length} done • '
            'Philippine time (UTC+8)',
            style: const TextStyle(
              color: secondaryText,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          // Completed or cancelled visits move to "Appointment History".
          if (AppointmentStore.activeAppointments.isEmpty)
            _buildNothingUpcoming()
          else
            for (final appointment in AppointmentStore.activeAppointments)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildAppointmentCard(appointment, 0),
              ),

          if (AppointmentStore.historyAppointments.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.history_rounded, size: 18, color: primaryColor),
                SizedBox(width: 6),
                Text(
                  'Appointment History',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final appointment in AppointmentStore.historyAppointments)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildAppointmentCard(
                  appointment,
                  0,
                  inHistory: true,
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // APPOINTMENT CARD
  // ============================================================

  Widget _buildNothingUpcoming() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7E3E7)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: Color(0xFF2E7D32),
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No upcoming appointments. Your finished visits are in the history below.',
              style: TextStyle(
                color: secondaryText,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
    Map<String, dynamic> appointment,
    int index, {
    bool inHistory = false,
  }) {
    final Map<String, dynamic> pet =
        Map<String, dynamic>.from(
      appointment['pet'] as Map,
    );

    final String petName =
        pet['name']?.toString() ?? 'Pet';

    final String breed =
        pet['breed']?.toString() ?? '';

    final String age =
        pet['age']?.toString() ?? '';

    final String image =
        pet['image']?.toString() ?? '';

    final String appointmentType =
        appointment['appointmentType']?.toString() ??
            'Appointment';

    final String time =
        appointment['time']?.toString() ??
            'No time selected';

    final String status = inHistory
        ? AppointmentStore.doneLabel(appointment)
        : appointment['status']?.toString() ?? 'Confirmed';

    DateTime date;

    try {
      date = DateTime.parse(
        appointment['date'].toString(),
      );
    } catch (_) {
      date = DateTime.now();
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFD7E3E7),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        children: [
          // ====================================================
          // PET INFORMATION
          // ====================================================

          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),

                child: Image.network(
                  image,
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,

                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      width: 82,
                      height: 82,
                      color: lightBlue,

                      child: const Icon(
                        Icons.pets,
                        color: primaryColor,
                        size: 35,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Appointment with',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      petName,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '$breed${age.isNotEmpty ? ' • $age' : ''}',
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // STATUS

              Builder(
                builder: (context) {
                  Color badgeBg = const Color(0xFFEAF8F6);
                  Color badgeText = tealColor;
                  final sLower = status.toLowerCase();
                  if (sLower.contains('pend')) {
                    badgeBg = const Color(0xFFFEF3C7);
                    badgeText = const Color(0xFFD97706);
                  } else if (sLower.contains('cancel') || sLower.contains('reject')) {
                    badgeBg = const Color(0xFFFEE2E2);
                    badgeText = const Color(0xFFDC2626);
                  } else if (sLower == 'expired') {
                    badgeBg = const Color(0xFFF1F5F9);
                    badgeText = const Color(0xFF64748B);
                  } else if (sLower.contains('complete') || sLower == 'done') {
                    badgeBg = const Color(0xFFE8F5E9);
                    badgeText = const Color(0xFF2E7D32);
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: badgeText,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(
            height: 1,
            color: Color(0xFFE7EEF0),
          ),

          const SizedBox(height: 14),

          // ====================================================
          // DATE
          // ====================================================

          Row(
            children: [
              _buildSmallIcon(
                Icons.calendar_today_outlined,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ====================================================
          // TIME + TYPE
          // ====================================================

          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildSmallIcon(
                      Icons.access_time_rounded,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Time',
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 11,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            time,
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Row(
                  children: [
                    _buildSmallIcon(
                      _appointmentIcon(
                        appointmentType,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Appointment',
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 11,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            appointmentType,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,

                            style: const TextStyle(
                              color: darkText,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ====================================================
          // ADOPTION JOURNEY LINK (meet & greet for an application)
          // ====================================================

          if (appointmentType == 'Meet and Greet' && !inHistory)
            _buildJourneyChip(pet['id']?.toString()),

          const SizedBox(height: 16),

          // ====================================================
          // VIEW DETAILS BUTTON
          // ====================================================

          SizedBox(
            width: double.infinity,
            height: 44,

            child: OutlinedButton.icon(
              onPressed: () {
                _showAppointmentDetails(
                  appointment,
                );
              },

              icon: const Icon(
                Icons.visibility_outlined,
                size: 18,
              ),

              label: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,

                side: const BorderSide(
                  color: primaryColor,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADOPTION JOURNEY CHIP
  // ============================================================

  Widget _buildJourneyChip(String? petId) {
    final journey = AdoptionJourneyService().journeyForPet(petId);
    if (journey == null) return const SizedBox.shrink();
    final step = journey.stage.index + 1;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF8F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.route_rounded,
              size: 16,
              color: Color(0xFF008F82),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Adoption journey · Step $step of '
                '${JourneyStage.values.length}: ${journey.statusLabel}',
                style: const TextStyle(
                  color: Color(0xFF00695F),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SMALL ICON
  // ============================================================

  Widget _buildSmallIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,

      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EF),
        shape: BoxShape.circle,
      ),

      child: Icon(
        icon,
        color: primaryColor,
        size: 16,
      ),
    );
  }

  // ============================================================
  // VIEW DETAILS
  // ============================================================

  void _showAppointmentDetails(
    Map<String, dynamic> appointment,
  ) {
    final Map<String, dynamic> pet =
        Map<String, dynamic>.from(
      appointment['pet'] as Map,
    );

    final String petName =
        pet['name']?.toString() ?? 'Pet';

    final String image =
        pet['image']?.toString() ?? '';

    final String appointmentType =
        appointment['appointmentType']?.toString() ??
            'Appointment';

    final String time =
        appointment['time']?.toString() ??
            'No time selected';

    final String status =
        appointment['status']?.toString() ??
            'Confirmed';

    final String shelter =
        appointment['shelter']?.toString() ??
            'JAGNA ANIMAL LOVER AND RESCUE GROUP';

    DateTime date;

    try {
      date = DateTime.parse(
        appointment['date'].toString(),
      );
    } catch (_) {
      date = DateTime.now();
    }

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            30,
          ),

          decoration: const BoxDecoration(
            color: backgroundColor,

            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),

          child: SafeArea(
            top: false,

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Appointment Details',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // PET

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(16),

                      border: Border.all(
                        color: const Color(0xFFD7E3E7),
                      ),
                    ),

                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(12),

                          child: Image.network(
                            image,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,

                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Container(
                                width: 70,
                                height: 70,
                                color: lightBlue,

                                child: const Icon(
                                  Icons.pets,
                                  color: primaryColor,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 13),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'Pet',
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                petName,
                                style: const TextStyle(
                                  color: darkText,
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildDetailRow(
                    icon:
                        Icons.calendar_today_outlined,
                    title: 'Date',
                    value: _formatDate(date),
                  ),

                  _buildDetailRow(
                    icon: Icons.access_time_rounded,
                    title: 'Time',
                    value: time,
                  ),

                  _buildDetailRow(
                    icon: _appointmentIcon(
                      appointmentType,
                    ),
                    title: 'Appointment',
                    value: appointmentType,
                  ),

                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    title: 'Shelter',
                    value: shelter,
                  ),

                  _buildDetailRow(
                    icon: Icons.check_circle_outline,
                    title: 'Status',
                    value: status,
                    valueColor: tealColor,
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),

                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
  // DETAIL ROW
  // ============================================================

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: const Color(0xFFD7E3E7),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 36,
            height: 36,

            decoration: BoxDecoration(
              color: const Color(0xFFFFF4EF),
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: primaryColor,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
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
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ============================================================
  // APPOINTMENT ICON
  // ============================================================

  IconData _appointmentIcon(String type) {
    switch (type) {
      case 'Shelter Visit':
        return Icons.home_outlined;

      case 'Meet and Greet':
        return Icons.people_outline;

      case 'Interview':
        return Icons.assignment_outlined;

      default:
        return Icons.event;
    }
  }
}