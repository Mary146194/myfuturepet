import 'package:flutter/material.dart';
import '../adoption_journey.dart';
import '../appointment_store.dart';
import '../appointment_schedule.dart';
import '../services/adoption_journey_service.dart';
import '../services/appointment_service.dart';

// ============================================================
// VISIT APPOINTMENT SCREEN
// ============================================================

class VisitAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> pet;
  final AppointmentService? appointmentService;
  final DateTime Function()? now;
  final String initialAppointmentType;

  const VisitAppointmentScreen({
    super.key,
    required this.pet,
    this.appointmentService,
    this.now,
    this.initialAppointmentType = 'Shelter Visit',
  });

  /// Book the meet & greet for an approved adoption (journey stage 3).
  /// Shared by Profile, My Applications and Application Details.
  static Future<void> openMeetAndGreet(
    BuildContext context,
    AdoptionJourney journey,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VisitAppointmentScreen(
          pet: {
            'id': journey.petId,
            'name': journey.petName,
            'image': journey.petImage,
            'shelter_id': journey.shelterId,
          },
          initialAppointmentType: 'Meet and Greet',
        ),
      ),
    );
    await AdoptionJourneyService().refresh();
  }

  @override
  State<VisitAppointmentScreen> createState() =>
      _VisitAppointmentScreenState();
}

class _VisitAppointmentScreenState
    extends State<VisitAppointmentScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  final Color primaryColor = const Color(0xFFA94327);
  final Color darkText = const Color(0xFF062B35);
  final Color tealColor = const Color(0xFF008F82);
  final Color detailBrown = const Color(0xFF604A45);
  final Color detailBlue = const Color(0xFFEFF9FD);
  final Color lightBlue = const Color(0xFFE4F5FB);

  // ============================================================
  // APPOINTMENT DATA
  // ============================================================

  late String selectedAppointmentType = widget.initialAppointmentType;

  late DateTime selectedDate;

  String? selectedTime;
  bool _booking = false;
  DateTime _now() => widget.now?.call() ?? DateTime.now();

  // ============================================================
  // CALENDAR
  // ============================================================

  late DateTime displayedMonth;

  @override
  void initState() {
    super.initState();

    selectedDate = AppointmentSchedule.firstBookableDate(_now());
    final now = selectedDate;

    displayedMonth = DateTime(
      now.year,
      now.month,
      1,
    );
  }

  // ============================================================
  // APPOINTMENT TYPES
  // ============================================================

  final List<String> appointmentTypes = [
    'Shelter Visit',
    'Meet and Greet',
  ];

  // ============================================================
  // AVAILABLE TIMES
  // ============================================================

  final List<String> availableTimes = AppointmentSchedule.timeSlots;

  // ============================================================
  // CHANGE MONTH
  // ============================================================

  void _changeMonth(int amount) {
    final now = AppointmentSchedule.inManila(_now());

    final currentMonth = DateTime(
      now.year,
      now.month,
      1,
    );

    final newMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + amount,
      1,
    );

    // Do not allow going before the current month.
    if (newMonth.isBefore(currentMonth)) {
      return;
    }

    setState(() {
      displayedMonth = newMonth;
    });
  }

  // ============================================================
  // GET MONTH NAME
  // ============================================================

  String _monthName(int month) {
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

    return months[month - 1];
  }

  // ============================================================
  // FORMAT DATE
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
  // GET NUMBER OF DAYS
  // ============================================================

  int _daysInMonth(DateTime month) {
    return DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;
  }

  // ============================================================
  // GET FIRST DAY OFFSET
  // ============================================================

  int _firstDayOffset(DateTime month) {
    final firstDay = DateTime(
      month.year,
      month.month,
      1,
    );

    return firstDay.weekday % 7;
  }

  // ============================================================
  // CHECK IF SAME DATE
  // ============================================================

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  // ============================================================
  // CHECK IF DATE IS PAST
  // ============================================================

  bool _isPastDate(DateTime date) {
    final today = AppointmentSchedule.inManila(_now());

    final todayOnly = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final dateOnly = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return dateOnly.isBefore(todayOnly);
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  void _selectDate(DateTime date) {
    if (_booking || !AppointmentSchedule.isDateSelectable(date, _now())) {
      return;
    }

    setState(() {
      selectedDate = date;
      selectedTime = null;
    });
  }

  // ============================================================
  // SELECT TIME
  // ============================================================

  void _selectTime(String time) {
    if (_booking || !AppointmentSchedule.isSlotSelectable(selectedDate, time, _now())) return;
    setState(() {
      selectedTime = time;
    });
  }

  // ============================================================
// CONFIRM APPOINTMENT
// ============================================================

Future<void> _confirmAppointment() async {
  if (_booking) return;
  if (selectedTime == null || !AppointmentSchedule.isSlotSelectable(selectedDate, selectedTime!, _now())) {
    _showMessage(
      'Please select an available time.',
    );
    return;
  }

  // ==========================================================
  // SAVE APPOINTMENT
  // ==========================================================

  setState(() => _booking = true);
  try {
  await AppointmentStore.saveAppointment(
    service: widget.appointmentService,
    pet: widget.pet,
    appointmentType: selectedAppointmentType,
    date: selectedDate,
    time: selectedTime!,
    shelter: widget.pet['shelter']?.toString() ??
        'JAGNA ANIMAL LOVER AND RESCUE GROUP',
  );
  } catch (error) {
    if (!mounted) return;
    setState(() => _booking = false);
    final message = error.toString();
    _showMessage(message.contains('logged in')
        ? 'Please log in to request an appointment.'
        : error is ArgumentError ? error.message.toString()
        : 'Could not request your visit. Please check your connection and try again.');
    return;
  }
  // A meet & greet request moves the adoption journey; resync it.
  AdoptionJourneyService().refresh();
  if (!mounted) return;
  setState(() => _booking = false);

  // ==========================================================
  // SHOW CONFIRMATION
  // ==========================================================

  showDialog(
    context: context,
    barrierDismissible: false,

    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: tealColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.check_rounded,
                color: tealColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            const Expanded(
              child: Text(
                'Visit Request Sent',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF062B35),
                ),
              ),
            ),
          ],
        ),

        content: Text(
          'Your visit with ${widget.pet['name']} on ${_formatDate(selectedDate)} at $selectedTime (Philippine time) is pending shelter approval. View it under My Appointments.',
          style: TextStyle(
            color: darkText,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },

            child: Text(
              'Done',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_booking,
      child: AbsorbPointer(
        absorbing: _booking,
        child: Scaffold(
      backgroundColor: detailBrown,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: detailBrown,
        elevation: 0,
        automaticallyImplyLeading: false,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Schedule Appointment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Container(
        decoration: BoxDecoration(
          color: detailBlue,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),

        child: SafeArea(
          top: false,

          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              40,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ==================================================
                // APP HEADER
                // ==================================================

                // Row(
                //   children: [
                //     Container(
                //       width: 42,
                //       height: 42,

                //       decoration: const BoxDecoration(
                //         shape: BoxShape.circle,
                //         color: Colors.white,
                //       ),

                //       padding: const EdgeInsets.all(2),

                //       child: ClipOval(
                //         child: Image.network(
                //           widget.pet['image'] ?? '',
                //           fit: BoxFit.cover,

                //           errorBuilder:
                //               (context, error, stackTrace) {
                //             return Container(
                //               color: lightBlue,

                //               child: Icon(
                //                 Icons.pets,
                //                 color: primaryColor,
                //                 size: 22,
                //               ),
                //             );
                //           },
                //         ),
                //       ),
                //     ),

                //     const SizedBox(width: 12),

                //     Expanded(
                //       child: Text(
                //         'My Future Pet',
                //         style: TextStyle(
                //           fontSize: 20,
                //           fontWeight: FontWeight.bold,
                //           color: primaryColor,
                //         ),
                //       ),
                //     ),

                //     Icon(
                //       Icons.notifications_none_rounded,
                //       color: Colors.grey.shade600,
                //       size: 21,
                //     ),
                //   ],
                // ),

                // const SizedBox(height: 20),

                // ==================================================
                // PET MINI PROFILE
                // ==================================================

                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),

                      child: Image.network(
                        widget.pet['image'] ?? '',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,

                        errorBuilder:
                            (context, error, stackTrace) {
                          return Container(
                            width: 64,
                            height: 64,
                            color: lightBlue,
                            child: Icon(
                              Icons.pets,
                              color: primaryColor,
                              size: 30,
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
                          Text(
                            'Schedule a Visit with',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                              height: 1.15,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            widget.pet['name'] ?? 'Pet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: Colors.grey.shade600,
                              ),

                              const SizedBox(width: 4),

                              Expanded(
                                child: Text(
                                  'Jagna Animal Lover and Rescue Group Shelter',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ==================================================
                // APPOINTMENT TYPE CARD
                // ==================================================

                _buildSectionTitle(
                  'Appointment Type',
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(16),

                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: 0.04),

                        blurRadius: 8,

                        offset:
                            const Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Column(
                    children: appointmentTypes.map(
                      (type) {
                        final isSelected =
                            selectedAppointmentType ==
                                type;

                        final isLast =
                            type ==
                                appointmentTypes.last;

                        return Padding(
                          padding:
                              EdgeInsets.only(
                            bottom: isLast ? 0 : 10,
                          ),

                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAppointmentType =
                                    type;
                              });
                            },

                            child: AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds: 180,
                              ),

                              height: 58,

                              decoration:
                                  BoxDecoration(
                                color: isSelected
                                    ? primaryColor
                                        .withValues(alpha: 0.06)
                                    : Colors.white,

                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : const Color(
                                          0xFFE3C9C1,
                                        ),

                                  width: isSelected
                                      ? 1.5
                                      : 1,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),

                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,

                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,

                                    decoration:
                                        BoxDecoration(
                                      color: isSelected
                                          ? primaryColor
                                              .withValues(
                                              alpha: 0.10,
                                            )
                                          : lightBlue,

                                      shape:
                                          BoxShape.circle,
                                    ),

                                    child: Icon(
                                      _appointmentIcon(
                                        type,
                                      ),

                                      size: 16,

                                      color: isSelected
                                          ? primaryColor
                                          : Colors
                                              .grey
                                              .shade600,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                  Text(
                                    type,

                                    style: TextStyle(
                                      fontSize: 14,

                                      fontWeight:
                                          isSelected
                                              ? FontWeight
                                                  .w600
                                              : FontWeight
                                                  .w500,

                                      color: isSelected
                                          ? primaryColor
                                          : darkText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // SELECT DATE
                // ==================================================

                _buildSectionTitle(
                  'Select a Date',
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.fromLTRB(
                    14,
                    16,
                    14,
                    18,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(16),

                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: 0.04),

                        blurRadius: 8,

                        offset:
                            const Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      // ==========================================
                      // MONTH HEADER
                      // ==========================================

                      Row(
                        children: [
                          _buildCalendarArrow(
                            icon:
                                Icons.chevron_left_rounded,

                            onTap: () {
                              _changeMonth(-1);
                            },
                          ),

                          Expanded(
                            child: Center(
                              child: Text(
                                '${_monthName(displayedMonth.month)} ${displayedMonth.year}',

                                style:
                                    TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: darkText,
                                ),
                              ),
                            ),
                          ),

                          _buildCalendarArrow(
                            icon:
                                Icons.chevron_right_rounded,

                            onTap: () {
                              _changeMonth(1);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ==========================================
                      // WEEK DAYS
                      // ==========================================

                      Row(
                        children: [
                          'Su',
                          'Mo',
                          'Tu',
                          'We',
                          'Th',
                          'Fr',
                          'Sa',
                        ].map(
                          (day) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  day,

                                  style:
                                      TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.w600,
                                    color: Colors
                                        .grey
                                        .shade600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),

                      const SizedBox(height: 10),

                      // ==========================================
                      // CALENDAR
                      // ==========================================

                      _buildCalendar(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // AVAILABLE TIMES
                // ==================================================

                _buildSectionTitle(
                  'Available Times',
                ),

                const SizedBox(height: 6),

                Text(
                  _formatDate(selectedDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(16),

                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: 0.04),

                        blurRadius: 8,

                        offset:
                            const Offset(0, 2),
                      ),
                    ],
                  ),

                  child: GridView.builder(
                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount:
                        availableTimes.length,

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,

                      crossAxisSpacing: 10,

                      mainAxisSpacing: 10,

                      childAspectRatio: 2.8,
                    ),

                    itemBuilder:
                        (context, index) {
                      final time =
                          availableTimes[index];

                      final isSelected =
                          selectedTime == time;

                      final isUnavailable = !AppointmentSchedule.isSlotSelectable(selectedDate, time, _now());

                      return GestureDetector(
                        key: ValueKey('slot-$time'),
                        onTap: isUnavailable
                            ? null
                            : () {
                                _selectTime(time);
                              },

                        child: AnimatedContainer(
                          duration:
                              const Duration(
                            milliseconds: 150,
                          ),

                          alignment:
                              Alignment.center,

                          decoration:
                              BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                    .withValues(alpha: 0.08)
                                : Colors.white,

                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : isUnavailable
                                      ? Colors
                                          .grey
                                          .shade300
                                      : const Color(
                                          0xFFD5E3E7,
                                        ),

                              width: isSelected
                                  ? 1.5
                                  : 1,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              11,
                            ),
                          ),

                          child: Text(
                            time,

                            style: TextStyle(
                              fontSize: 14,

                              fontWeight:
                                  FontWeight.w600,

                              color: isUnavailable
                                  ? Colors
                                      .grey
                                      .shade400
                                  : isSelected
                                      ? primaryColor
                                      : darkText,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // APPOINTMENT SUMMARY
                // ==================================================

                _buildSectionTitle(
                  'Appointment Summary',
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(16),

                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: 0.04),

                        blurRadius: 8,

                        offset:
                            const Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // ==========================================
                      // DATE
                      // ==========================================

                      _buildSummaryRow(
                        icon:
                            Icons.calendar_today_outlined,

                        title: 'Date',

                        value:
                            _formatDate(selectedDate),
                      ),

                      const SizedBox(height: 14),

                      // ==========================================
                      // TIME
                      // ==========================================

                      _buildSummaryRow(
                        icon:
                            Icons.access_time_rounded,

                        title: 'Time',

                        value: selectedTime ??
                            'No time selected',
                      ),

                      const SizedBox(height: 14),

                      // ==========================================
                      // TYPE
                      // ==========================================

                      _buildSummaryRow(
                        icon:
                            Icons.event_outlined,

                        title: 'Appointment',

                        value:
                            selectedAppointmentType,
                      ),

                      const SizedBox(height: 14),

                      // ==========================================
                      // PET
                      // ==========================================

                      _buildSummaryRow(
                        icon:
                            Icons.pets_outlined,

                        title: 'Pet',

                        value:
                            widget.pet['name'] ??
                                'Pet',
                      ),

                      const SizedBox(height: 14),

                      // ==========================================
                      // SHELTER
                      // ==========================================

                      _buildSummaryRow(
                        icon:
                            Icons.location_on_outlined,

                        title: 'Shelter',

                        value:
                            widget.pet['shelter'] ??
                                'JAGNA ANIMAL LOVER AND RESCUE GROUP',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // CONFIRM BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,

                  height: 56,

                  child: ElevatedButton(
                    onPressed: _booking || selectedTime == null ? null : _confirmAppointment,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedTime == null
                              ? Colors.grey.shade300
                              : primaryColor,

                      foregroundColor:
                          Colors.white,

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          28,
                        ),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        Text(
                          _booking ? 'Sending...' : 'Request Appointment',

                          style: TextStyle(
                            fontSize: 14,

                            fontWeight:
                                FontWeight.w600,

                            color:
                                selectedTime == null
                                    ? Colors
                                        .grey
                                        .shade600
                                    : Colors.white,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Icon(
                          Icons
                              .check_circle_outline_rounded,

                          size: 19,

                          color:
                              selectedTime == null
                                  ? Colors
                                      .grey
                                      .shade600
                                  : Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Small helper text
                Center(
                  child: Text(
                    'Philippine time (UTC+8). Mon–Sat, 9 AM–4 PM. Shelter approval required.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
    );
  }

  // ============================================================
  // CALENDAR ARROW
  // ============================================================

  Widget _buildCalendarArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(16),

        child: Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: lightBlue,

            shape: BoxShape.circle,
          ),

          child: Icon(
            icon,

            size: 22,

            color: darkText,
          ),
        ),
      ),
    );
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

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _buildSummaryRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Container(
          width: 36,
          height: 36,

          decoration: BoxDecoration(
            color:
                primaryColor.withValues(alpha: 0.08),

            shape: BoxShape.circle,
          ),

          child: Icon(
            icon,

            size: 17,

            color: primaryColor,
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

                style: TextStyle(
                  fontSize: 12,

                  color:
                      Colors.grey.shade600,

                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,

                style: TextStyle(
                  fontSize: 14,

                  color: darkText,

                  fontWeight:
                      FontWeight.w600,

                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CALENDAR WIDGET
  // ============================================================

  Widget _buildCalendar() {
    final daysInMonth =
        _daysInMonth(displayedMonth);

    final firstOffset =
        _firstDayOffset(displayedMonth);

    final totalCells =
        ((firstOffset + daysInMonth) / 7)
            .ceil() *
        7;

    return Column(
      children: List.generate(
        totalCells ~/ 7,
        (weekIndex) {
          return Row(
            children: List.generate(
              7,
              (dayIndex) {
                final cellIndex =
                    weekIndex * 7 + dayIndex;

                final dayNumber =
                    cellIndex - firstOffset + 1;

                if (dayNumber < 1 ||
                    dayNumber > daysInMonth) {
                  return const Expanded(
                    child: SizedBox(
                      height: 44,
                    ),
                  );
                }

                final date = DateTime(
                  displayedMonth.year,
                  displayedMonth.month,
                  dayNumber,
                );

                final selected =
                    _isSameDate(
                  date,
                  selectedDate,
                );

                final past = _isPastDate(date) || date.weekday == DateTime.sunday;

                return Expanded(
                  child: GestureDetector(
                    key: ValueKey('date-${date.year}-${date.month}-${date.day}'),
                    onTap: past
                        ? null
                        : () {
                            _selectDate(date);
                          },

                    child: Container(
                      height: 44,

                      margin:
                          const EdgeInsets.all(2),

                      alignment:
                          Alignment.center,

                      child: Container(
                        width: 38,
                        height: 38,

                        alignment:
                            Alignment.center,

                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,

                          color: selected
                              ? primaryColor
                              : Colors
                                  .transparent,
                        ),

                        child: Text(
                          '$dayNumber',

                          style:
                              TextStyle(
                            fontSize: 13,

                            fontWeight:
                                selected
                                    ? FontWeight.bold
                                    : FontWeight
                                        .normal,

                            color: past
                                ? Colors
                                    .grey
                                    .shade300
                                : selected
                                    ? Colors.white
                                    : darkText,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
