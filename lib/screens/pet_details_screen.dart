import 'package:flutter/material.dart';

import '../saved_pet_store.dart';
import 'adoption_process_screen.dart';
import 'visit_appointment_screen.dart';


class PetDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> pet;

  const PetDetailsScreen({
    super.key,
    required this.pet,
  });

  @override
  State<PetDetailsScreen> createState() =>
      _PetDetailsScreenState();
}

class _PetDetailsScreenState
    extends State<PetDetailsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor =
      Color(0xFFA94327);

  static const Color darkText =
      Color(0xFF062B35);

  static const Color tealColor =
      Color(0xFF008F82);

  static const Color detailBrown =
      Color(0xFF604A45);

  static const Color detailBlue =
      Color(0xFFEFF9FD);

  static const Color lightBlue =
      Color(0xFFE4F5FB);

  // ============================================================
  // CHECK IF PET IS SAVED
  // ============================================================

  bool get isSaved {
    return SavedPetStore.isSaved(
      widget.pet['name'].toString(),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isAvailable =
        widget.pet['status'] == 'Available';

    return Scaffold(
      backgroundColor: detailBrown,
      body: SafeArea(
        child: Stack(
          children: [
            // ==================================================
            // MAIN SCROLLABLE CONTENT
            // ==================================================

            SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),

              padding: const EdgeInsets.only(
                bottom: 155,
              ),

              child: Column(
                children: [
                  // ==================================================
                  // HERO IMAGE
                  // ==================================================

                  Container(
                    height: 400,

                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),

                    child: Stack(
                      children: [
                        // ==================================================
                        // IMAGE
                        // ==================================================

                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(
                              bottom:
                                  Radius.circular(28),
                            ),

                            child: Image.network(
                              widget.pet['image']
                                  .toString(),

                              fit: BoxFit.cover,

                              alignment:
                                  Alignment.center,

                              errorBuilder:
                                  (_, __, ___) {
                                return Container(
                                  color:
                                      const Color(
                                    0xFFE9EEF0,
                                  ),

                                  child: Icon(
                                    widget.pet[
                                                'category'] ==
                                            'Dogs'
                                        ? Icons.pets
                                        : Icons
                                            .cruelty_free,

                                    size: 80,

                                    color:
                                        primaryColor,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // ==================================================
                        // IMAGE GRADIENT
                        // ==================================================

                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(
                              bottom:
                                  Radius.circular(28),
                            ),

                            child: DecoratedBox(
                              decoration:
                                  BoxDecoration(
                                gradient:
                                    LinearGradient(
                                  begin:
                                      Alignment.topCenter,
                                  end: Alignment
                                      .bottomCenter,

                                  colors: [
                                    Colors.black
                                        .withOpacity(
                                      0.08,
                                    ),
                                    Colors
                                        .transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ==================================================
                        // BACK BUTTON
                        // ==================================================

                        Positioned(
                          top: 16,
                          left: 12,

                          child:
                              _buildCircleButton(
                            icon: Icons
                                .arrow_back_ios_new_rounded,

                            onTap: () {
                              Navigator.pop(
                                context,
                              );
                            },
                          ),
                        ),

                        // ==================================================
                        // FAVORITE BUTTON
                        // ==================================================

                        Positioned(
                          top: 16,
                          right: 12,

                          child:
                              _buildCircleButton(
                            icon: isSaved
                                ? Icons
                                    .favorite_rounded
                                : Icons
                                    .favorite_border_rounded,

                            iconColor:
                                primaryColor,

                            onTap: () {
                              setState(() {
                                SavedPetStore
                                    .togglePet(
                                  widget.pet,
                                );
                              });

                              if (isSaved) {
                                _showMessage(
                                  context,
                                  '${widget.pet['name']} added to Saved Pets.',
                                );
                              } else {
                                _showMessage(
                                  context,
                                  '${widget.pet['name']} removed from Saved Pets.',
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // INFORMATION CARD
                  // ==================================================

                  Transform.translate(
                    offset:
                        const Offset(0, -24),

                    child: Container(
                      width: double.infinity,

                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),

                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        24,
                        20,
                        24,
                      ),

                      decoration: BoxDecoration(
                        color: detailBlue,

                        borderRadius:
                            BorderRadius.circular(
                          28,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                              0.08,
                            ),

                            blurRadius: 10,

                            offset:
                                const Offset(
                              0,
                              2,
                            ),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          // ==================================================
                          // NAME
                          // ==================================================

                          Text(
                            widget.pet['name']
                                .toString(),

                            style:
                                const TextStyle(
                              color: darkText,

                              fontSize: 27,

                              fontWeight:
                                  FontWeight.bold,

                              height: 1.15,
                            ),
                          ),

                          const SizedBox(
                            height: 7,
                          ),

                          // ==================================================
                          // BREED / AGE / GENDER
                          // ==================================================

                          Text(
                            '${widget.pet['breed']} • ${widget.pet['age']} • ${widget.pet['gender']}',

                            style:
                                const TextStyle(
                              color:
                                  Color(0xFF45565B),

                              fontSize: 14,

                              fontWeight:
                                  FontWeight.w500,

                              height: 1.3,
                            ),
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          // ==================================================
                          // DIVIDER
                          // ==================================================

                          Container(
                            height: 1,

                            color:
                                const Color(
                              0xFFD9E8ED,
                            ),
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          // ==================================================
                          // WEIGHT + VACCINATION
                          // ==================================================

                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Expanded(
                                child:
                                    _buildInfoBox(
                                  title:
                                      'Weight',

                                  value: widget
                                      .pet['weight']
                                      .toString(),

                                  icon: Icons
                                      .monitor_weight_outlined,
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Expanded(
                                child:
                                    _buildInfoBox(
                                  title:
                                      'Vaccination',

                                  value: widget.pet[
                                          'vaccinationStatus']
                                      .toString(),

                                  icon: Icons
                                      .vaccines_outlined,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          // ==================================================
                          // PERSONALITY
                          // ==================================================

                          const Text(
                            'Personality',

                            style:
                                TextStyle(
                              color: darkText,

                              fontSize: 17,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Wrap(
                            spacing: 7,
                            runSpacing: 8,

                            children:
                                (widget.pet[
                                            'personality']
                                        as List<dynamic>)
                                    .map(
                              (
                                personality,
                              ) {
                                return _buildPersonalityChip(
                                  personality
                                      .toString(),
                                );
                              },
                            ).toList(),
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          // ==================================================
                          // ABOUT
                          // ==================================================

                          Text(
                            'About ${widget.pet['name']}',

                            style:
                                const TextStyle(
                              color: darkText,

                              fontSize: 17,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 9,
                          ),

                          Text(
                            widget.pet['about']
                                .toString(),

                            style:
                                const TextStyle(
                              color:
                                  Color(0xFF4B5E63),

                              fontSize: 14,

                              height: 1.6,

                              fontWeight:
                                  FontWeight.w400,
                            ),
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          // ==================================================
                          // SHELTER
                          // ==================================================

                          _buildShelterCard(
                            context,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ============================================================
            // FIXED BOTTOM BUTTONS
            // ============================================================

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,

              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(
                  14,
                  14,
                  14,
                  12,
                ),

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEAF8FC),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                        0.08,
                      ),

                      blurRadius: 10,

                      offset:
                          const Offset(0, -3),
                    ),
                  ],
                ),

                child: SafeArea(
                  top: false,

                  child: Column(
                    children: [
                      // ==================================================
                      // AR + VISIT
                      // ==================================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _buildSecondaryButton(
                              label:
                                  'AR Preview',

                              icon: Icons
                                  .view_in_ar_outlined,

                              filled: true,

                              onTap: () {
                                _showMessage(
                                  context,
                                  'AR Preview for ${widget.pet['name']} coming soon.',
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                _buildSecondaryButton(
                              label: 'Visit',

                              icon: Icons
                                  .calendar_month_outlined,

                              filled: false,

                              onTap: () {
                                _openVisitAppointment(
                                  context,
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // ==================================================
                      // APPLY FOR ADOPTION
                      // ==================================================

                      SizedBox(
                        width: double.infinity,

                        height: 52,

                        child:
                            ElevatedButton(
                          onPressed: isAvailable
                              ? () {
                                  _openAdoptionProcess(
                                    context,
                                  );
                                }
                              : null,

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                primaryColor,

                            disabledBackgroundColor:
                                const Color(
                              0xFFB9B9B9,
                            ),

                            foregroundColor:
                                Colors.white,

                            disabledForegroundColor:
                                Colors.white,

                            elevation: 0,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                28,
                              ),
                            ),
                          ),

                          child: Text(
                            isAvailable
                                ? 'Apply for Adoption'
                                : 'Adoption Pending',

                            style:
                                const TextStyle(
                              fontSize: 15,

                              fontWeight:
                                  FontWeight.bold,
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
  // OPEN ADOPTION PROCESS
  // ============================================================

  void _openAdoptionProcess(
    BuildContext context,
  ) {
    showGeneralDialog(
      context: context,

      barrierDismissible: false,

      barrierLabel:
          'Adoption Application',

      barrierColor:
          Colors.black.withOpacity(0.45),

      transitionDuration:
          const Duration(
        milliseconds: 250,
      ),

      pageBuilder: (
        dialogContext,
        animation,
        secondaryAnimation,
      ) {
        return AdoptionProcessScreen(
          pet: widget.pet,
        );
      },

      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curvedAnimation =
            CurvedAnimation(
          parent: animation,
          curve:
              Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,

          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.96,
              end: 1.0,
            ).animate(
              curvedAnimation,
            ),

            child: child,
          ),
        );
      },
    );
  }

  // ============================================================
  // CIRCLE BUTTON
  // ============================================================

  Widget _buildCircleButton({
    required IconData icon,

    required VoidCallback onTap,

    Color iconColor =
        const Color(0xFF526069),
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(30),

        child: Container(
          width: 44,
          height: 44,

          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(
              0.90,
            ),

            shape: BoxShape.circle,

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(
                  0.08,
                ),

                blurRadius: 6,

                offset:
                    const Offset(0, 2),
              ),
            ],
          ),

          child: Icon(
            icon,

            size: 19,

            color: iconColor,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO BOX
  // ============================================================

  Widget _buildInfoBox({
    required String title,

    required String value,

    required IconData icon,
  }) {
    return Container(
      height: 76,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),

      decoration: BoxDecoration(
        color: lightBlue,

        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,

                  style:
                      const TextStyle(
                    color:
                        Color(0xFF617176),

                    fontSize: 12,

                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),

              Icon(
                icon,

                size: 16,

                color:
                    const Color(
                  0xFF7A989F,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            value,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style:
                const TextStyle(
              color: darkText,

              fontSize: 14,

              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERSONALITY CHIP
  // ============================================================

  Widget _buildPersonalityChip(
    String text,
  ) {
    IconData icon;

    switch (text.toLowerCase()) {
      case 'friendly':
        icon =
            Icons.favorite_border_rounded;
        break;

      case 'active':
      case 'playful':
      case 'high energy':
        icon = Icons.bolt_rounded;
        break;

      case 'good with kids':
        icon =
            Icons.child_friendly_rounded;
        break;

      case 'calm':
      case 'quiet':
      case 'gentle':
        icon =
            Icons.spa_outlined;
        break;

      case 'independent':
        icon =
            Icons.self_improvement_outlined;
        break;

      case 'affectionate':
        icon =
            Icons.favorite_border_rounded;
        break;

      case 'loyal':
        icon =
            Icons.shield_outlined;
        break;

      default:
        icon =
            Icons.pets_outlined;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color:
            const Color(0xFFDDF2F1),

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            icon,

            size: 14,

            color: tealColor,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            text,

            style:
                const TextStyle(
              color:
                  Color(0xFF34706C),

              fontSize: 11,

              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SHELTER CARD
  // ============================================================

  Widget _buildShelterCard(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color:
              const Color(0xFFDDE9EC),
        ),
      ),

      child: Row(
        children: [
          // ==================================================
          // SHELTER ICON
          // ==================================================

          Container(
            width: 46,
            height: 46,

            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFE9F7F6),

              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.home_work_outlined,

              size: 21,

              color: tealColor,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          // ==================================================
          // SHELTER NAME
          // ==================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: const [
                Text(
                  'JAGNA ANIMAL LOVER AND',

                  style:
                      TextStyle(
                    color:
                        Color(0xFF425257),

                    fontSize: 11,

                    fontWeight:
                        FontWeight.bold,

                    height: 1.3,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  'RESCUE GROUP',

                  style:
                      TextStyle(
                    color:
                        Color(0xFF425257),

                    fontSize: 11,

                    fontWeight:
                        FontWeight.bold,

                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // PHONE BUTTON
          // ==================================================

          Material(
            color: Colors.transparent,

            child: InkWell(
              borderRadius:
                  BorderRadius.circular(
                30,
              ),

              onTap: () {
                _showMessage(
                  context,
                  'Contacting shelter...',
                );
              },

              child: Container(
                width: 42,
                height: 42,

                decoration:
                    BoxDecoration(
                  border: Border.all(
                    color:
                        const Color(
                      0xFFDCE7EA,
                    ),
                  ),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.phone_outlined,

                  size: 18,

                  color:
                      Color(0xFF6D7B7F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECONDARY BUTTON
  // ============================================================

  Widget _buildSecondaryButton({
    required String label,

    required IconData icon,

    required bool filled,

    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,

      child: ElevatedButton(
        onPressed: onTap,

        style:
            ElevatedButton.styleFrom(
          backgroundColor: filled
              ? const Color(0xFFFFA45D)
              : Colors.transparent,

          foregroundColor: filled
              ? const Color(0xFF7B421E)
              : primaryColor,

          elevation: 0,

          side: BorderSide(
            color: primaryColor,

            width: filled ? 0 : 1.5,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(27),
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
          ),
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,

              size: 17,
            ),

            const SizedBox(
              width: 6,
            ),

            Text(
              label,

              style:
                  const TextStyle(
                fontSize: 13,

                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // OPEN VISIT APPOINTMENT
  // ============================================================

  void _openVisitAppointment(
    BuildContext context,
  ) {
    showGeneralDialog(
      context: context,

      barrierDismissible: false,

      barrierLabel:
          'Visit Appointment',

      barrierColor:
          Colors.black.withOpacity(0.45),

      transitionDuration:
          const Duration(
        milliseconds: 250,
      ),

      pageBuilder: (
        dialogContext,
        animation,
        secondaryAnimation,
      ) {
        return VisitAppointmentScreen(
          pet: widget.pet,
        );
      },

      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curvedAnimation =
            CurvedAnimation(
          parent: animation,
          curve:
              Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,

          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.96,
              end: 1.0,
            ).animate(
              curvedAnimation,
            ),

            child: child,
          ),
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    BuildContext context,
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
            fontSize: 14,
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

// import 'adoption_process_screen.dart';
// import 'visit_appointment_screen.dart';

// class PetDetailsScreen extends StatelessWidget {
//   final Map<String, dynamic> pet;

//   const PetDetailsScreen({
//     super.key,
//     required this.pet,
//   });

//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor = Color(0xFFA94327);
//   static const Color darkText = Color(0xFF062B35);

//   static const Color tealColor = Color(0xFF008F82);

//   static const Color detailBrown = Color(0xFF604A45);
//   static const Color detailBlue = Color(0xFFEFF9FD);
//   static const Color lightBlue = Color(0xFFE4F5FB);

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final bool isAvailable = pet['status'] == 'Available';

//     return Scaffold(
//       backgroundColor: detailBrown,

//       body: SafeArea(
//         child: Stack(
//           children: [
//             // ==================================================
//             // MAIN SCROLLABLE CONTENT
//             // ==================================================

//             SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),

//               padding: const EdgeInsets.only(
//                 bottom: 155,
//               ),

//               child: Column(
//                 children: [
//                   // ==================================================
//                   // HERO IMAGE
//                   // ==================================================

//                   Container(
//                     height: 400,

//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                     ),

//                     child: Stack(
//                       children: [
//                         // ==================================================
//                         // IMAGE
//                         // ==================================================

//                         Positioned.fill(
//                           child: ClipRRect(
//                             borderRadius:
//                                 const BorderRadius.vertical(
//                               bottom: Radius.circular(28),
//                             ),

//                             child: Image.network(
//                               pet['image'].toString(),

//                               fit: BoxFit.cover,

//                               alignment: Alignment.center,

//                               errorBuilder: (_, __, ___) {
//                                 return Container(
//                                   color:
//                                       const Color(0xFFE9EEF0),

//                                   child: Icon(
//                                     pet['category'] == 'Dogs'
//                                         ? Icons.pets
//                                         : Icons.cruelty_free,

//                                     size: 80,

//                                     color: primaryColor,
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),

//                         // ==================================================
//                         // IMAGE GRADIENT
//                         // ==================================================

//                         Positioned.fill(
//                           child: ClipRRect(
//                             borderRadius:
//                                 const BorderRadius.vertical(
//                               bottom: Radius.circular(28),
//                             ),

//                             child: DecoratedBox(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,

//                                   colors: [
//                                     Colors.black.withOpacity(0.08),
//                                     Colors.transparent,
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         // ==================================================
//                         // BACK BUTTON
//                         // ==================================================

//                         Positioned(
//                           top: 16,
//                           left: 12,

//                           child: _buildCircleButton(
//                             icon:
//                                 Icons.arrow_back_ios_new_rounded,

//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ),

//                         // ==================================================
//                         // FAVORITE BUTTON
//                         // ==================================================

//                         Positioned(
//                           top: 16,
//                           right: 12,

//                           child: _buildCircleButton(
//                             icon:
//                                 Icons.favorite_border_rounded,

//                             iconColor: primaryColor,

//                             onTap: () {
//                               _showMessage(
//                                 context,
//                                 '${pet['name']} added to favorites.',
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // ==================================================
//                   // INFORMATION CARD
//                   // ==================================================

//                   Transform.translate(
//                     offset: const Offset(0, -24),

//                     child: Container(
//                       width: double.infinity,

//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                       ),

//                       padding: const EdgeInsets.fromLTRB(
//                         20,
//                         24,
//                         20,
//                         24,
//                       ),

//                       decoration: BoxDecoration(
//                         color: detailBlue,

//                         borderRadius:
//                             BorderRadius.circular(28),

//                         boxShadow: [
//                           BoxShadow(
//                             color:
//                                 Colors.black.withOpacity(0.08),

//                             blurRadius: 10,

//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),

//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,

//                         children: [
//                           // ==================================================
//                           // NAME
//                           // ==================================================

//                           Text(
//                             pet['name'].toString(),

//                             style: const TextStyle(
//                               color: darkText,

//                               fontSize: 27,

//                               fontWeight: FontWeight.bold,

//                               height: 1.15,
//                             ),
//                           ),

//                           const SizedBox(height: 7),

//                           // ==================================================
//                           // BREED / AGE / GENDER
//                           // ==================================================

//                           Text(
//                             '${pet['breed']} • ${pet['age']} • ${pet['gender']}',

//                             style: const TextStyle(
//                               color: Color(0xFF45565B),

//                               fontSize: 14,

//                               fontWeight:
//                                   FontWeight.w500,

//                               height: 1.3,
//                             ),
//                           ),

//                           const SizedBox(height: 18),

//                           // ==================================================
//                           // DIVIDER
//                           // ==================================================

//                           Container(
//                             height: 1,

//                             color: const Color(
//                               0xFFD9E8ED,
//                             ),
//                           ),

//                           const SizedBox(height: 18),

//                           // ==================================================
//                           // WEIGHT + VACCINATION
//                           // ==================================================

//                           Row(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.start,

//                             children: [
//                               Expanded(
//                                 child: _buildInfoBox(
//                                   title: 'Weight',

//                                   value:
//                                       pet['weight'].toString(),

//                                   icon: Icons
//                                       .monitor_weight_outlined,
//                                 ),
//                               ),

//                               const SizedBox(width: 12),

//                               Expanded(
//                                 child: _buildInfoBox(
//                                   title: 'Vaccination',

//                                   value: pet[
//                                           'vaccinationStatus']
//                                       .toString(),

//                                   icon:
//                                       Icons.vaccines_outlined,
//                                 ),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 22),

//                           // ==================================================
//                           // PERSONALITY
//                           // ==================================================

//                           const Text(
//                             'Personality',

//                             style: TextStyle(
//                               color: darkText,

//                               fontSize: 17,

//                               fontWeight:
//                                   FontWeight.bold,
//                             ),
//                           ),

//                           const SizedBox(height: 10),

//                           Wrap(
//                             spacing: 7,
//                             runSpacing: 8,

//                             children:
//                                 (pet['personality']
//                                         as List<dynamic>)
//                                     .map(
//                               (personality) {
//                                 return _buildPersonalityChip(
//                                   personality.toString(),
//                                 );
//                               },
//                             ).toList(),
//                           ),

//                           const SizedBox(height: 24),

//                           // ==================================================
//                           // ABOUT
//                           // ==================================================

//                           Text(
//                             'About ${pet['name']}',

//                             style: const TextStyle(
//                               color: darkText,

//                               fontSize: 17,

//                               fontWeight:
//                                   FontWeight.bold,
//                             ),
//                           ),

//                           const SizedBox(height: 9),

//                           Text(
//                             pet['about'].toString(),

//                             style: const TextStyle(
//                               color: Color(0xFF4B5E63),

//                               fontSize: 14,

//                               height: 1.6,

//                               fontWeight:
//                                   FontWeight.w400,
//                             ),
//                           ),

//                           const SizedBox(height: 22),

//                           // ==================================================
//                           // SHELTER
//                           // ==================================================

//                           _buildShelterCard(context),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ============================================================
//             // FIXED BOTTOM BUTTONS
//             // ============================================================

//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,

//               child: Container(
//                 padding: const EdgeInsets.fromLTRB(
//                   14,
//                   14,
//                   14,
//                   12,
//                 ),

//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEAF8FC),

//                   boxShadow: [
//                     BoxShadow(
//                       color:
//                           Colors.black.withOpacity(0.08),

//                       blurRadius: 10,

//                       offset: const Offset(0, -3),
//                     ),
//                   ],
//                 ),

//                 child: SafeArea(
//                   top: false,

//                   child: Column(
//                     children: [
//                       // ==================================================
//                       // AR + VISIT
//                       // ==================================================

//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildSecondaryButton(
//                               label: 'AR Preview',

//                               icon:
//                                   Icons.view_in_ar_outlined,

//                               filled: true,

//                               onTap: () {
//                                 _showMessage(
//                                   context,
//                                   'AR Preview for ${pet['name']} coming soon.',
//                                 );
//                               },
//                             ),
//                           ),

//                           const SizedBox(width: 10),

//                           Expanded(
//                             child: _buildSecondaryButton(
//                               label: 'Visit',

//                               icon:
//                                   Icons.calendar_month_outlined,

//                               filled: false,

//                               onTap: () {
//                                 _openVisitAppointment(
//                                   context,
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 10),

//                       // ==================================================
//                       // APPLY FOR ADOPTION
//                       // ==================================================

//                       SizedBox(
//                         width: double.infinity,

//                         height: 52,

//                         child: ElevatedButton(
//                           onPressed: isAvailable
//                               ? () {
//                                   _openAdoptionProcess(
//                                     context,
//                                   );
//                                 }
//                               : null,

//                           style:
//                               ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 primaryColor,

//                             disabledBackgroundColor:
//                                 const Color(0xFFB9B9B9),

//                             foregroundColor:
//                                 Colors.white,

//                             disabledForegroundColor:
//                                 Colors.white,

//                             elevation: 0,

//                             shape:
//                                 RoundedRectangleBorder(
//                               borderRadius:
//                                   BorderRadius.circular(28),
//                             ),
//                           ),

//                           child: Text(
//                             isAvailable
//                                 ? 'Apply for Adoption'
//                                 : 'Adoption Pending',

//                             style: const TextStyle(
//                               fontSize: 15,

//                               fontWeight:
//                                   FontWeight.bold,
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
//   // OPEN ADOPTION PROCESS
//   // ============================================================

//   void _openAdoptionProcess(
//     BuildContext context,
//   ) {
//     showGeneralDialog(
//       context: context,

//       barrierDismissible: false,

//       barrierLabel: 'Adoption Application',

//       barrierColor:
//           Colors.black.withOpacity(0.45),

//       transitionDuration:
//           const Duration(milliseconds: 250),

//       pageBuilder: (
//         dialogContext,
//         animation,
//         secondaryAnimation,
//       ) {
//         return AdoptionProcessScreen(
//           pet: pet,
//         );
//       },

//       transitionBuilder: (
//         context,
//         animation,
//         secondaryAnimation,
//         child,
//       ) {
//         final curvedAnimation =
//             CurvedAnimation(
//           parent: animation,

//           curve: Curves.easeOutCubic,
//         );

//         return FadeTransition(
//           opacity: curvedAnimation,

//           child: ScaleTransition(
//             scale: Tween<double>(
//               begin: 0.96,
//               end: 1.0,
//             ).animate(curvedAnimation),

//             child: child,
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // CIRCLE BUTTON
//   // ============================================================

//   Widget _buildCircleButton({
//     required IconData icon,

//     required VoidCallback onTap,

//     Color iconColor =
//         const Color(0xFF526069),
//   }) {
//     return Material(
//       color: Colors.transparent,

//       child: InkWell(
//         onTap: onTap,

//         borderRadius:
//             BorderRadius.circular(30),

//         child: Container(
//           width: 44,
//           height: 44,

//           decoration: BoxDecoration(
//             color:
//                 Colors.white.withOpacity(0.90),

//             shape: BoxShape.circle,

//             boxShadow: [
//               BoxShadow(
//                 color:
//                     Colors.black.withOpacity(0.08),

//                 blurRadius: 6,

//                 offset:
//                     const Offset(0, 2),
//               ),
//             ],
//           ),

//           child: Icon(
//             icon,

//             size: 19,

//             color: iconColor,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // INFO BOX
//   // ============================================================

//   Widget _buildInfoBox({
//     required String title,

//     required String value,

//     required IconData icon,
//   }) {
//     return Container(
//       height: 76,

//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 11,
//       ),

//       decoration: BoxDecoration(
//         color: lightBlue,

//         borderRadius:
//             BorderRadius.circular(12),
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         mainAxisAlignment:
//             MainAxisAlignment.center,

//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   title,

//                   style: const TextStyle(
//                     color:
//                         Color(0xFF617176),

//                     fontSize: 12,

//                     fontWeight:
//                         FontWeight.w500,
//                   ),
//                 ),
//               ),

//               Icon(
//                 icon,

//                 size: 16,

//                 color:
//                     const Color(0xFF7A989F),
//               ),
//             ],
//           ),

//           const SizedBox(height: 7),

//           Text(
//             value,

//             maxLines: 1,

//             overflow:
//                 TextOverflow.ellipsis,

//             style: const TextStyle(
//               color: darkText,

//               fontSize: 14,

//               fontWeight:
//                   FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PERSONALITY CHIP
//   // ============================================================

//   Widget _buildPersonalityChip(
//     String text,
//   ) {
//     IconData icon;

//     switch (text.toLowerCase()) {
//       case 'friendly':
//         icon =
//             Icons.favorite_border_rounded;
//         break;

//       case 'active':
//       case 'playful':
//       case 'high energy':
//         icon =
//             Icons.bolt_rounded;
//         break;

//       case 'good with kids':
//         icon =
//             Icons.child_friendly_rounded;
//         break;

//       case 'calm':
//       case 'quiet':
//       case 'gentle':
//         icon =
//             Icons.spa_outlined;
//         break;

//       case 'independent':
//         icon =
//             Icons.self_improvement_outlined;
//         break;

//       case 'affectionate':
//         icon =
//             Icons.favorite_border_rounded;
//         break;

//       case 'loyal':
//         icon =
//             Icons.shield_outlined;
//         break;

//       default:
//         icon =
//             Icons.pets_outlined;
//     }

//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 12,
//         vertical: 8,
//       ),

//       decoration: BoxDecoration(
//         color:
//             const Color(0xFFDDF2F1),

//         borderRadius:
//             BorderRadius.circular(18),
//       ),

//       child: Row(
//         mainAxisSize:
//             MainAxisSize.min,

//         children: [
//           Icon(
//             icon,

//             size: 14,

//             color: tealColor,
//           ),

//           const SizedBox(width: 5),

//           Text(
//             text,

//             style: const TextStyle(
//               color:
//                   Color(0xFF34706C),

//               fontSize: 11,

//               fontWeight:
//                   FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SHELTER CARD
//   // ============================================================

//   Widget _buildShelterCard(
//     BuildContext context,
//   ) {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 12,
//         vertical: 12,
//       ),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(14),

//         border: Border.all(
//           color:
//               const Color(0xFFDDE9EC),
//         ),
//       ),

//       child: Row(
//         children: [
//           // ==================================================
//           // SHELTER ICON
//           // ==================================================

//           Container(
//             width: 46,
//             height: 46,

//             decoration: const BoxDecoration(
//               color:
//                   Color(0xFFE9F7F6),

//               shape: BoxShape.circle,
//             ),

//             child: const Icon(
//               Icons.home_work_outlined,

//               size: 21,

//               color: tealColor,
//             ),
//           ),

//           const SizedBox(width: 12),

//           // ==================================================
//           // SHELTER NAME
//           // ==================================================

//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: const [
//                 Text(
//                   'JAGNA ANIMAL LOVER AND',

//                   style: TextStyle(
//                     color:
//                         Color(0xFF425257),

//                     fontSize: 11,

//                     fontWeight:
//                         FontWeight.bold,

//                     height: 1.3,
//                   ),
//                 ),

//                 SizedBox(height: 2),

//                 Text(
//                   'RESCUE GROUP',

//                   style: TextStyle(
//                     color:
//                         Color(0xFF425257),

//                     fontSize: 11,

//                     fontWeight:
//                         FontWeight.bold,

//                     height: 1.3,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ==================================================
//           // PHONE BUTTON
//           // ==================================================

//           Material(
//             color: Colors.transparent,

//             child: InkWell(
//               borderRadius:
//                   BorderRadius.circular(30),

//               onTap: () {
//                 _showMessage(
//                   context,
//                   'Contacting shelter...',
//                 );
//               },

//               child: Container(
//                 width: 42,
//                 height: 42,

//                 decoration:
//                     BoxDecoration(
//                   border: Border.all(
//                     color:
//                         const Color(
//                       0xFFDCE7EA,
//                     ),
//                   ),

//                   shape: BoxShape.circle,
//                 ),

//                 child: const Icon(
//                   Icons.phone_outlined,

//                   size: 18,

//                   color:
//                       Color(0xFF6D7B7F),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SECONDARY BUTTON
//   // ============================================================

//   Widget _buildSecondaryButton({
//     required String label,

//     required IconData icon,

//     required bool filled,

//     required VoidCallback onTap,
//   }) {
//     return SizedBox(
//       height: 52,

//       child: ElevatedButton(
//         onPressed: onTap,

//         style:
//             ElevatedButton.styleFrom(
//           backgroundColor: filled
//               ? const Color(0xFFFFA45D)
//               : Colors.transparent,

//           foregroundColor: filled
//               ? const Color(0xFF7B421E)
//               : primaryColor,

//           elevation: 0,

//           side: BorderSide(
//             color: primaryColor,

//             width: filled ? 0 : 1.5,
//           ),

//           shape:
//               RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(27),
//           ),

//           padding:
//               const EdgeInsets.symmetric(
//             horizontal: 8,
//           ),
//         ),

//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             Icon(
//               icon,

//               size: 17,
//             ),

//             const SizedBox(width: 6),

//             Text(
//               label,

//               style: const TextStyle(
//                 fontSize: 13,

//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // OPEN VISIT APPOINTMENT
//   // ============================================================

//   void _openVisitAppointment(
//     BuildContext context,
//   ) {
//     showGeneralDialog(
//       context: context,

//       barrierDismissible: false,

//       barrierLabel: 'Visit Appointment',

//       barrierColor:
//           Colors.black.withOpacity(0.45),

//       transitionDuration:
//           const Duration(milliseconds: 250),

//       pageBuilder: (
//         dialogContext,
//         animation,
//         secondaryAnimation,
//       ) {
//         return VisitAppointmentScreen(
//           pet: pet,
//         );
//       },

//       transitionBuilder: (
//         context,
//         animation,
//         secondaryAnimation,
//         child,
//       ) {
//         final curvedAnimation =
//             CurvedAnimation(
//           parent: animation,

//           curve: Curves.easeOutCubic,
//         );

//         return FadeTransition(
//           opacity: curvedAnimation,

//           child: ScaleTransition(
//             scale: Tween<double>(
//               begin: 0.96,
//               end: 1.0,
//             ).animate(curvedAnimation),

//             child: child,
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     BuildContext context,

//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(
//           message,

//           style: const TextStyle(
//             fontSize: 14,
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

// import 'adoption_process_screen.dart';
// import 'visit_appointment_screen.dart';

// class PetDetailsScreen extends StatelessWidget {
//   final Map<String, dynamic> pet;

//   const PetDetailsScreen({
//     super.key,
//     required this.pet,
//   });

//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor = Color(0xFFA94327);
//   static const Color darkText = Color(0xFF062B35);

//   static const Color tealColor = Color(0xFF008F82);

//   static const Color detailBrown = Color(0xFF604A45);
//   static const Color detailBlue = Color(0xFFEFF9FD);
//   static const Color lightBlue = Color(0xFFE4F5FB);

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final bool isAvailable = pet['status'] == 'Available';

//     return Scaffold(
//       backgroundColor: detailBrown,

//       body: SafeArea(
//         child: Stack(
//           children: [
//             // ==================================================
//             // MAIN CONTENT
//             // ==================================================

//             SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),

//               padding: const EdgeInsets.only(
//                 bottom: 145,
//               ),

//               child: Column(
//                 children: [
//                   // ==================================================
//                   // HERO IMAGE
//                   // ==================================================

//                   Container(
//                     height: 320,

//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                     ),

//                     child: Stack(
//                       children: [
//                         // ==================================================
//                         // IMAGE
//                         // ==================================================

//                         Positioned.fill(
//                           child: ClipRRect(
//                             borderRadius:
//                                 const BorderRadius.vertical(
//                               bottom: Radius.circular(24),
//                             ),

//                             child: Image.network(
//                               pet['image'].toString(),

//                               fit: BoxFit.cover,

//                               alignment: Alignment.center,

//                               errorBuilder: (_, __, ___) {
//                                 return Container(
//                                   color: const Color(0xFFE9EEF0),

//                                   child: Icon(
//                                     pet['category'] == 'Dogs'
//                                         ? Icons.pets
//                                         : Icons.cruelty_free,

//                                     size: 70,

//                                     color: primaryColor,
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),

//                         // ==================================================
//                         // IMAGE GRADIENT
//                         // ==================================================

//                         Positioned.fill(
//                           child: ClipRRect(
//                             borderRadius:
//                                 const BorderRadius.vertical(
//                               bottom: Radius.circular(24),
//                             ),

//                             child: DecoratedBox(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,

//                                   colors: [
//                                     Colors.black.withOpacity(0.08),
//                                     Colors.transparent,
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         // ==================================================
//                         // BACK BUTTON
//                         // ==================================================

//                         Positioned(
//                           top: 12,
//                           left: 10,

//                           child: _buildCircleButton(
//                             icon:
//                                 Icons.arrow_back_ios_new_rounded,

//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ),

//                         // ==================================================
//                         // FAVORITE BUTTON
//                         // ==================================================

//                         Positioned(
//                           top: 12,
//                           right: 10,

//                           child: _buildCircleButton(
//                             icon:
//                                 Icons.favorite_border_rounded,

//                             iconColor: primaryColor,

//                             onTap: () {
//                               _showMessage(
//                                 context,
//                                 '${pet['name']} added to favorites.',
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // ==================================================
//                   // INFORMATION CARD
//                   // ==================================================

//                   Transform.translate(
//                     offset: const Offset(0, -20),

//                     child: Container(
//                       width: double.infinity,

//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                       ),

//                       padding: const EdgeInsets.fromLTRB(
//                         12,
//                         14,
//                         12,
//                         16,
//                       ),

//                       decoration: BoxDecoration(
//                         color: detailBlue,

//                         borderRadius:
//                             BorderRadius.circular(22),

//                         boxShadow: [
//                           BoxShadow(
//                             color:
//                                 Colors.black.withOpacity(0.08),

//                             blurRadius: 8,

//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),

//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,

//                         children: [
//                           // ==================================================
//                           // NAME
//                           // ==================================================

//                           Text(
//                             pet['name'].toString(),

//                             style: const TextStyle(
//                               color: darkText,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           const SizedBox(height: 3),

//                           Text(
//                             '${pet['breed']} • ${pet['age']} • ${pet['gender']}',

//                             style: const TextStyle(
//                               color: Color(0xFF45565B),
//                               fontSize: 9,
//                             ),
//                           ),

//                           const SizedBox(height: 12),

//                           // DIVIDER

//                           Container(
//                             height: 1,

//                             color: const Color(
//                               0xFFD9E8ED,
//                             ),
//                           ),

//                           const SizedBox(height: 11),

//                           // ==================================================
//                           // WEIGHT + VACCINATION
//                           // ==================================================

//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _buildInfoBox(
//                                   title: 'Weight',

//                                   value:
//                                       pet['weight'].toString(),

//                                   icon: Icons
//                                       .monitor_weight_outlined,
//                                 ),
//                               ),

//                               const SizedBox(width: 7),

//                               Expanded(
//                                 child: _buildInfoBox(
//                                   title: 'Vaccination',

//                                   value: pet[
//                                           'vaccinationStatus']
//                                       .toString(),

//                                   icon:
//                                       Icons.vaccines_outlined,
//                                 ),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 12),

//                           // ==================================================
//                           // PERSONALITY
//                           // ==================================================

//                           const Text(
//                             'Personality',

//                             style: TextStyle(
//                               color: darkText,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           const SizedBox(height: 6),

//                           Wrap(
//                             spacing: 5,
//                             runSpacing: 5,

//                             children:
//                                 (pet['personality']
//                                         as List<dynamic>)
//                                     .map(
//                               (personality) {
//                                 return _buildPersonalityChip(
//                                   personality.toString(),
//                                 );
//                               },
//                             ).toList(),
//                           ),

//                           const SizedBox(height: 14),

//                           // ==================================================
//                           // ABOUT
//                           // ==================================================

//                           Text(
//                             'About ${pet['name']}',

//                             style: const TextStyle(
//                               color: darkText,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           const SizedBox(height: 5),

//                           Text(
//                             pet['about'].toString(),

//                             style: const TextStyle(
//                               color: Color(0xFF4B5E63),
//                               fontSize: 8,
//                               height: 1.45,
//                             ),
//                           ),

//                           const SizedBox(height: 15),

//                           // ==================================================
//                           // SHELTER
//                           // ==================================================

//                           _buildShelterCard(context),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==================================================
//             // FIXED BOTTOM BUTTONS
//             // ==================================================

//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,

//               child: Container(
//                 padding: const EdgeInsets.fromLTRB(
//                   14,
//                   10,
//                   14,
//                   10,
//                 ),

//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEAF8FC),

//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),

//                       blurRadius: 8,

//                       offset: const Offset(0, -2),
//                     ),
//                   ],
//                 ),

//                 child: SafeArea(
//                   top: false,

//                   child: Column(
//                     children: [
//                       // ==================================================
//                       // AR + VISIT
//                       // ==================================================

//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildSecondaryButton(
//                               label: 'AR Preview',

//                               icon:
//                                   Icons.view_in_ar_outlined,

//                               filled: true,

//                               onTap: () {
//                                 _showMessage(
//                                   context,
//                                   'AR Preview for ${pet['name']} coming soon.',
//                                 );
//                               },
//                             ),
//                           ),

//                           const SizedBox(width: 7),

//                           Expanded(
//                             child: _buildSecondaryButton(
//                               label: 'Visit',

//                               icon: Icons.calendar_month_outlined,

//                               filled: false,

//                               onTap: () {
//                                 _openVisitAppointment(context);
//                               },
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 7),

//                       // ==================================================
//                       // APPLY FOR ADOPTION
//                       // ==================================================

//                       SizedBox(
//                         width: double.infinity,
//                         height: 38,

//                         child: ElevatedButton(
//                           onPressed: isAvailable
//                               ? () {
//                                   _openAdoptionProcess(
//                                     context,
//                                   );
//                                 }
//                               : null,

//                           style:
//                               ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 primaryColor,

//                             disabledBackgroundColor:
//                                 const Color(0xFFB9B9B9),

//                             foregroundColor:
//                                 Colors.white,

//                             disabledForegroundColor:
//                                 Colors.white,

//                             elevation: 0,

//                             shape:
//                                 RoundedRectangleBorder(
//                               borderRadius:
//                                   BorderRadius.circular(22),
//                             ),
//                           ),

//                           child: Text(
//                             isAvailable
//                                 ? 'Apply for Adoption'
//                                 : 'Adoption Pending',

//                             style: const TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
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
//   // OPEN ADOPTION PROCESS
//   // ============================================================

//   void _openAdoptionProcess(
//     BuildContext context,
//   ) {
//     showGeneralDialog(
//       context: context,

//       barrierDismissible: false,

//       barrierLabel: 'Adoption Application',

//       barrierColor: Colors.black.withOpacity(0.45),

//       transitionDuration:
//           const Duration(milliseconds: 250),

//       pageBuilder: (
//         dialogContext,
//         animation,
//         secondaryAnimation,
//       ) {
//         return AdoptionProcessScreen(
//           pet: pet,
//         );
//       },

//       transitionBuilder: (
//         context,
//         animation,
//         secondaryAnimation,
//         child,
//       ) {
//         final curvedAnimation = CurvedAnimation(
//           parent: animation,

//           curve: Curves.easeOutCubic,
//         );

//         return FadeTransition(
//           opacity: curvedAnimation,

//           child: ScaleTransition(
//             scale: Tween<double>(
//               begin: 0.96,
//               end: 1.0,
//             ).animate(curvedAnimation),

//             child: child,
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // CIRCLE BUTTON
//   // ============================================================

//   Widget _buildCircleButton({
//     required IconData icon,

//     required VoidCallback onTap,

//     Color iconColor =
//         const Color(0xFF526069),
//   }) {
//     return Material(
//       color: Colors.transparent,

//       child: InkWell(
//         onTap: onTap,

//         borderRadius:
//             BorderRadius.circular(30),

//         child: Container(
//           width: 36,
//           height: 36,

//           decoration: BoxDecoration(
//             color:
//                 Colors.white.withOpacity(0.88),

//             shape: BoxShape.circle,

//             boxShadow: [
//               BoxShadow(
//                 color:
//                     Colors.black.withOpacity(0.08),

//                 blurRadius: 5,

//                 offset:
//                     const Offset(0, 2),
//               ),
//             ],
//           ),

//           child: Icon(
//             icon,

//             size: 15,

//             color: iconColor,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // INFO BOX
//   // ============================================================

//   Widget _buildInfoBox({
//     required String title,

//     required String value,

//     required IconData icon,
//   }) {
//     return Container(
//       height: 48,

//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 8,
//         vertical: 6,
//       ),

//       decoration: BoxDecoration(
//         color: lightBlue,

//         borderRadius:
//             BorderRadius.circular(7),
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         mainAxisAlignment:
//             MainAxisAlignment.center,

//         children: [
//           Row(
//             children: [
//               Text(
//                 title,

//                 style: const TextStyle(
//                   color: Color(0xFF617176),

//                   fontSize: 7,

//                   fontWeight:
//                       FontWeight.w500,
//                 ),
//               ),

//               const Spacer(),

//               Icon(
//                 icon,

//                 size: 10,

//                 color:
//                     const Color(0xFF7A989F),
//               ),
//             ],
//           ),

//           const SizedBox(height: 3),

//           Text(
//             value,

//             maxLines: 1,

//             overflow:
//                 TextOverflow.ellipsis,

//             style: const TextStyle(
//               color: darkText,

//               fontSize: 8,

//               fontWeight:
//                   FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PERSONALITY CHIP
//   // ============================================================

//   Widget _buildPersonalityChip(
//     String text,
//   ) {
//     IconData icon;

//     switch (text.toLowerCase()) {
//       case 'friendly':
//         icon =
//             Icons.favorite_border_rounded;
//         break;

//       case 'active':
//       case 'playful':
//       case 'high energy':
//         icon =
//             Icons.bolt_rounded;
//         break;

//       case 'good with kids':
//         icon =
//             Icons.child_friendly_rounded;
//         break;

//       case 'calm':
//       case 'quiet':
//       case 'gentle':
//         icon =
//             Icons.spa_outlined;
//         break;

//       case 'independent':
//         icon =
//             Icons.self_improvement_outlined;
//         break;

//       case 'affectionate':
//         icon =
//             Icons.favorite_border_rounded;
//         break;

//       case 'loyal':
//         icon =
//             Icons.shield_outlined;
//         break;

//       default:
//         icon =
//             Icons.pets_outlined;
//     }

//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 7,
//         vertical: 4,
//       ),

//       decoration: BoxDecoration(
//         color:
//             const Color(0xFFDDF2F1),

//         borderRadius:
//             BorderRadius.circular(10),
//       ),

//       child: Row(
//         mainAxisSize:
//             MainAxisSize.min,

//         children: [
//           Icon(
//             icon,

//             size: 8,

//             color: tealColor,
//           ),

//           const SizedBox(width: 3),

//           Text(
//             text,

//             style: const TextStyle(
//               color:
//                   Color(0xFF34706C),

//               fontSize: 6.5,

//               fontWeight:
//                   FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SHELTER CARD
//   // ============================================================

//   Widget _buildShelterCard(
//     BuildContext context,
//   ) {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.all(7),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(9),

//         border: Border.all(
//           color:
//               const Color(0xFFDDE9EC),
//         ),
//       ),

//       child: Row(
//         children: [
//           // ==================================================
//           // SHELTER ICON
//           // ==================================================

//           Container(
//             width: 30,
//             height: 30,

//             decoration: const BoxDecoration(
//               color:
//                   Color(0xFFE9F7F6),

//               shape: BoxShape.circle,
//             ),

//             child: const Icon(
//               Icons.home_work_outlined,

//               size: 14,

//               color: tealColor,
//             ),
//           ),

//           const SizedBox(width: 7),

//           // ==================================================
//           // SHELTER NAME
//           // ==================================================

//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: const [
//                 Text(
//                   'JAGNA ANIMAL LOVER AND',

//                   style: TextStyle(
//                     color:
//                         Color(0xFF425257),

//                     fontSize: 6.5,

//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),

//                 SizedBox(height: 1),

//                 Text(
//                   'RESCUE GROUP',

//                   style: TextStyle(
//                     color:
//                         Color(0xFF425257),

//                     fontSize: 6.5,

//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ==================================================
//           // PHONE BUTTON
//           // ==================================================

//           Material(
//             color: Colors.transparent,

//             child: InkWell(
//               borderRadius:
//                   BorderRadius.circular(30),

//               onTap: () {
//                 _showMessage(
//                   context,
//                   'Contacting shelter...',
//                 );
//               },

//               child: Container(
//                 width: 27,
//                 height: 27,

//                 decoration:
//                     BoxDecoration(
//                   border: Border.all(
//                     color:
//                         const Color(
//                       0xFFDCE7EA,
//                     ),
//                   ),

//                   shape: BoxShape.circle,
//                 ),

//                 child: const Icon(
//                   Icons.phone_outlined,

//                   size: 12,

//                   color:
//                       Color(0xFF6D7B7F),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SECONDARY BUTTON
//   // ============================================================

//   Widget _buildSecondaryButton({
//     required String label,

//     required IconData icon,

//     required bool filled,

//     required VoidCallback onTap,
//   }) {
//     return SizedBox(
//       height: 38,

//       child: ElevatedButton(
//         onPressed: onTap,

//         style:
//             ElevatedButton.styleFrom(
//           backgroundColor: filled
//               ? const Color(0xFFFFA45D)
//               : Colors.transparent,

//           foregroundColor: filled
//               ? const Color(0xFF7B421E)
//               : primaryColor,

//           elevation: 0,

//           side: BorderSide(
//             color: primaryColor,

//             width: filled ? 0 : 1,
//           ),

//           shape:
//               RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(20),
//           ),

//           padding:
//               const EdgeInsets.symmetric(
//             horizontal: 8,
//           ),
//         ),

//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [
//             Icon(
//               icon,

//               size: 11,
//             ),

//             const SizedBox(width: 4),

//             Text(
//               label,

//               style: const TextStyle(
//                 fontSize: 8.5,

//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
// // OPEN VISIT APPOINTMENT
// // ============================================================

//   void _openVisitAppointment(BuildContext context) {
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierLabel: 'Visit Appointment',
//       barrierColor: Colors.black.withOpacity(0.45),

//       transitionDuration:
//           const Duration(milliseconds: 250),

//       pageBuilder: (
//         dialogContext,
//         animation,
//         secondaryAnimation,
//       ) {
//         return VisitAppointmentScreen(
//           pet: pet,
//         );
//       },

//       transitionBuilder: (
//         context,
//         animation,
//         secondaryAnimation,
//         child,
//       ) {
//         final curvedAnimation =
//             CurvedAnimation(
//           parent: animation,
//           curve: Curves.easeOutCubic,
//         );

//         return FadeTransition(
//           opacity: curvedAnimation,

//           child: ScaleTransition(
//             scale: Tween<double>(
//               begin: 0.96,
//               end: 1.0,
//             ).animate(curvedAnimation),

//             child: child,
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     BuildContext context,

//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),

//         behavior:
//             SnackBarBehavior.floating,

//         duration:
//             const Duration(seconds: 2),
//       ),
//     );
//   }
// }











// import 'package:flutter/material.dart';

// class PetDetailsScreen extends StatelessWidget {
//   final Map<String, dynamic> pet;

//   const PetDetailsScreen({
//     super.key,
//     required this.pet,
//   });

//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor = Color(0xFFA94327);
//   static const Color darkText = Color(0xFF062B35);

//   static const Color tealColor = Color(0xFF008F82);

//   static const Color detailBrown = Color(0xFF604A45);
//   static const Color detailBlue = Color(0xFFEFF9FD);
//   static const Color lightBlue = Color(0xFFE4F5FB);

//   @override
//   Widget build(BuildContext context) {
//     final bool isAvailable =
//         pet['status'] == 'Available';

//     return Scaffold(
//       backgroundColor: detailBrown,

//       body: SafeArea(
//         child: Stack(
//           children: [

//             // ==================================================
//             // MAIN CONTENT
//             // ==================================================

//             SingleChildScrollView(
//               physics:
//                   const BouncingScrollPhysics(),

//               padding: const EdgeInsets.only(
//                 bottom: 145,
//               ),

//               child: Column(
//                 children: [

//                   // ==================================================
//                   // HERO IMAGE
//                   // ==================================================

//                   Container(
//                     height: 320,
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                     ),

//                     child: Stack(
//                       children: [

//                         Positioned.fill(
//                           child: ClipRRect(
//                             borderRadius:
//                                 const BorderRadius.vertical(
//                               bottom:
//                                   Radius.circular(24),
//                             ),

//                             child: Image.network(
//                               pet['image'].toString(),

//                               fit: BoxFit.cover,

//                               alignment:
//                                   Alignment.center,

//                               errorBuilder:
//                                   (_, __, ___) {
//                                 return Container(
//                                   color:
//                                       const Color(
//                                     0xFFE9EEF0,
//                                   ),

//                                   child: Icon(
//                                     pet['category'] ==
//                                             'Dogs'
//                                         ? Icons.pets
//                                         : Icons
//                                             .cruelty_free,

//                                     size: 70,

//                                     color:
//                                         primaryColor,
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),

//                         // ==================================================
//                         // IMAGE GRADIENT
//                         // ==================================================

//                         Positioned.fill(
//                           child: ClipRRect(
//                             borderRadius:
//                                 const BorderRadius.vertical(
//                               bottom:
//                                   Radius.circular(24),
//                             ),

//                             child: DecoratedBox(
//                               decoration:
//                                   BoxDecoration(
//                                 gradient:
//                                     LinearGradient(
//                                   begin:
//                                       Alignment.topCenter,
//                                   end:
//                                       Alignment.bottomCenter,

//                                   colors: [
//                                     Colors.black
//                                         .withOpacity(
//                                       0.08,
//                                     ),

//                                     Colors.transparent,
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         // ==================================================
//                         // BACK BUTTON
//                         // ==================================================

//                         Positioned(
//                           top: 12,
//                           left: 10,

//                           child:
//                               _buildCircleButton(
//                             icon: Icons
//                                 .arrow_back_ios_new_rounded,

//                             onTap: () {
//                               Navigator.pop(
//                                 context,
//                               );
//                             },
//                           ),
//                         ),

//                         // ==================================================
//                         // FAVORITE BUTTON
//                         // ==================================================

//                         Positioned(
//                           top: 12,
//                           right: 10,

//                           child:
//                               _buildCircleButton(
//                             icon: Icons
//                                 .favorite_border_rounded,

//                             iconColor:
//                                 primaryColor,

//                             onTap: () {
//                               _showMessage(
//                                 context,
//                                 '${pet['name']} added to favorites.',
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // ==================================================
//                   // INFORMATION CARD
//                   // ==================================================

//                   Transform.translate(
//                     offset: const Offset(0, -20),

//                     child: Container(
//                       width: double.infinity,

//                       margin:
//                           const EdgeInsets.symmetric(
//                         horizontal: 14,
//                       ),

//                       padding:
//                           const EdgeInsets.fromLTRB(
//                         12,
//                         14,
//                         12,
//                         16,
//                       ),

//                       decoration: BoxDecoration(
//                         color: detailBlue,

//                         borderRadius:
//                             BorderRadius.circular(22),

//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black
//                                 .withOpacity(0.08),

//                             blurRadius: 8,

//                             offset:
//                                 const Offset(0, 2),
//                           ),
//                         ],
//                       ),

//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,

//                         children: [

//                           // ==================================================
//                           // NAME
//                           // ==================================================

//                           Text(
//                             pet['name'].toString(),

//                             style: const TextStyle(
//                               color: darkText,
//                               fontSize: 20,
//                               fontWeight:
//                                   FontWeight.bold,
//                             ),
//                           ),

//                           const SizedBox(height: 3),

//                           Text(
//                             '${pet['breed']} • ${pet['age']} • ${pet['gender']}',

//                             style:
//                                 const TextStyle(
//                               color:
//                                   Color(0xFF45565B),

//                               fontSize: 9,
//                             ),
//                           ),

//                           const SizedBox(height: 12),

//                           Container(
//                             height: 1,
//                             color:
//                                 const Color(
//                               0xFFD9E8ED,
//                             ),
//                           ),

//                           const SizedBox(height: 11),

//                           // ==================================================
//                           // WEIGHT + VACCINATION
//                           // ==================================================

//                           Row(
//                             children: [

//                               Expanded(
//                                 child:
//                                     _buildInfoBox(
//                                   title: 'Weight',

//                                   value:
//                                       pet['weight']
//                                           .toString(),

//                                   icon: Icons
//                                       .monitor_weight_outlined,
//                                 ),
//                               ),

//                               const SizedBox(width: 7),

//                               Expanded(
//                                 child:
//                                     _buildInfoBox(
//                                   title:
//                                       'Vaccination',

//                                   value: pet[
//                                           'vaccinationStatus']
//                                       .toString(),

//                                   icon: Icons
//                                       .vaccines_outlined,
//                                 ),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 12),

//                           // ==================================================
//                           // PERSONALITY
//                           // ==================================================

//                           const Text(
//                             'Personality',

//                             style: TextStyle(
//                               color: darkText,
//                               fontSize: 10,
//                               fontWeight:
//                                   FontWeight.bold,
//                             ),
//                           ),

//                           const SizedBox(height: 6),

//                           Wrap(
//                             spacing: 5,
//                             runSpacing: 5,

//                             children:
//                                 (pet['personality']
//                                         as List<dynamic>)
//                                     .map(
//                               (personality) {
//                                 return _buildPersonalityChip(
//                                   personality
//                                       .toString(),
//                                 );
//                               },
//                             ).toList(),
//                           ),

//                           const SizedBox(height: 14),

//                           // ==================================================
//                           // ABOUT
//                           // ==================================================

//                           Text(
//                             'About ${pet['name']}',

//                             style:
//                                 const TextStyle(
//                               color: darkText,
//                               fontSize: 10,
//                               fontWeight:
//                                   FontWeight.bold,
//                             ),
//                           ),

//                           const SizedBox(height: 5),

//                           Text(
//                             pet['about'].toString(),

//                             style:
//                                 const TextStyle(
//                               color:
//                                   Color(0xFF4B5E63),

//                               fontSize: 8,

//                               height: 1.45,
//                             ),
//                           ),

//                           const SizedBox(height: 15),

//                           // ==================================================
//                           // SHELTER
//                           // ==================================================

//                           _buildShelterCard(
//                             context,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==================================================
//             // FIXED BOTTOM BUTTONS
//             // ==================================================

//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,

//               child: Container(
//                 padding:
//                     const EdgeInsets.fromLTRB(
//                   14,
//                   10,
//                   14,
//                   10,
//                 ),

//                 decoration: BoxDecoration(
//                   color:
//                       const Color(0xFFEAF8FC),

//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black
//                           .withOpacity(0.08),

//                       blurRadius: 8,

//                       offset:
//                           const Offset(0, -2),
//                     ),
//                   ],
//                 ),

//                 child: SafeArea(
//                   top: false,

//                   child: Column(
//                     children: [

//                       // ==================================================
//                       // AR + VISIT
//                       // ==================================================

//                       Row(
//                         children: [

//                           Expanded(
//                             child:
//                                 _buildSecondaryButton(
//                               label:
//                                   'AR Preview',

//                               icon: Icons
//                                   .view_in_ar_outlined,

//                               filled: true,

//                               onTap: () {
//                                 _showMessage(
//                                   context,
//                                   'AR Preview for ${pet['name']} coming soon.',
//                                 );
//                               },
//                             ),
//                           ),

//                           const SizedBox(width: 7),

//                           Expanded(
//                             child:
//                                 _buildSecondaryButton(
//                               label: 'Visit',

//                               icon: Icons
//                                   .calendar_month_outlined,

//                               filled: false,

//                               onTap: () {
//                                 _showMessage(
//                                   context,
//                                   'Visit request for ${pet['name']} coming soon.',
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 7),

//                       // ==================================================
//                       // APPLY FOR ADOPTION
//                       // ==================================================

//                       SizedBox(
//                         width: double.infinity,
//                         height: 38,

//                         child: ElevatedButton(
//                           onPressed: isAvailable
//                               ? () {
//                                   _showMessage(
//                                     context,
//                                     'Adoption request for ${pet['name']} coming soon.',
//                                   );
//                                 }
//                               : null,

//                           style:
//                               ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 primaryColor,

//                             disabledBackgroundColor:
//                                 const Color(
//                               0xFFB9B9B9,
//                             ),

//                             foregroundColor:
//                                 Colors.white,

//                             disabledForegroundColor:
//                                 Colors.white,

//                             elevation: 0,

//                             shape:
//                                 RoundedRectangleBorder(
//                               borderRadius:
//                                   BorderRadius.circular(
//                                 22,
//                               ),
//                             ),
//                           ),

//                           child: Text(
//                             isAvailable
//                                 ? 'Apply for Adoption'
//                                 : 'Adoption Pending',

//                             style:
//                                 const TextStyle(
//                               fontSize: 10,
//                               fontWeight:
//                                   FontWeight.bold,
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
//   // CIRCLE BUTTON
//   // ============================================================

//   Widget _buildCircleButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     Color iconColor =
//         const Color(0xFF526069),
//   }) {
//     return Material(
//       color: Colors.transparent,

//       child: InkWell(
//         onTap: onTap,

//         borderRadius:
//             BorderRadius.circular(30),

//         child: Container(
//           width: 36,
//           height: 36,

//           decoration: BoxDecoration(
//             color:
//                 Colors.white.withOpacity(0.88),

//             shape: BoxShape.circle,

//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black
//                     .withOpacity(0.08),

//                 blurRadius: 5,

//                 offset:
//                     const Offset(0, 2),
//               ),
//             ],
//           ),

//           child: Icon(
//             icon,
//             size: 15,
//             color: iconColor,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // INFO BOX
//   // ============================================================

//   Widget _buildInfoBox({
//     required String title,
//     required String value,
//     required IconData icon,
//   }) {
//     return Container(
//       height: 48,

//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 8,
//         vertical: 6,
//       ),

//       decoration: BoxDecoration(
//         color: lightBlue,

//         borderRadius:
//             BorderRadius.circular(7),
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         mainAxisAlignment:
//             MainAxisAlignment.center,

//         children: [

//           Row(
//             children: [

//               Text(
//                 title,

//                 style: const TextStyle(
//                   color:
//                       Color(0xFF617176),

//                   fontSize: 7,

//                   fontWeight:
//                       FontWeight.w500,
//                 ),
//               ),

//               const Spacer(),

//               Icon(
//                 icon,

//                 size: 10,

//                 color:
//                     Color(0xFF7A989F),
//               ),
//             ],
//           ),

//           const SizedBox(height: 3),

//           Text(
//             value,

//             maxLines: 1,

//             overflow:
//                 TextOverflow.ellipsis,

//             style: const TextStyle(
//               color: darkText,

//               fontSize: 8,

//               fontWeight:
//                   FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PERSONALITY CHIP
//   // ============================================================

//   Widget _buildPersonalityChip(
//     String text,
//   ) {
//     IconData icon;

//     switch (text.toLowerCase()) {
//       case 'friendly':
//         icon =
//             Icons.favorite_border_rounded;
//         break;

//       case 'active':
//       case 'playful':
//       case 'high energy':
//         icon = Icons.bolt_rounded;
//         break;

//       case 'good with kids':
//         icon =
//             Icons.child_friendly_rounded;
//         break;

//       case 'calm':
//       case 'quiet':
//       case 'gentle':
//         icon = Icons.spa_outlined;
//         break;

//       case 'independent':
//         icon =
//             Icons.self_improvement_outlined;
//         break;

//       case 'affectionate':
//         icon =
//             Icons.favorite_border_rounded;
//         break;

//       case 'loyal':
//         icon = Icons.shield_outlined;
//         break;

//       default:
//         icon = Icons.pets_outlined;
//     }

//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 7,
//         vertical: 4,
//       ),

//       decoration: BoxDecoration(
//         color:
//             const Color(0xFFDDF2F1),

//         borderRadius:
//             BorderRadius.circular(10),
//       ),

//       child: Row(
//         mainAxisSize:
//             MainAxisSize.min,

//         children: [

//           Icon(
//             icon,
//             size: 8,
//             color: tealColor,
//           ),

//           const SizedBox(width: 3),

//           Text(
//             text,

//             style: const TextStyle(
//               color:
//                   Color(0xFF34706C),

//               fontSize: 6.5,

//               fontWeight:
//                   FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SHELTER CARD
//   // ============================================================

//   Widget _buildShelterCard(
//     BuildContext context,
//   ) {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.all(7),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(9),

//         border: Border.all(
//           color:
//               const Color(0xFFDDE9EC),
//         ),
//       ),

//       child: Row(
//         children: [

//           Container(
//             width: 30,
//             height: 30,

//             decoration: const BoxDecoration(
//               color:
//                   Color(0xFFE9F7F6),

//               shape: BoxShape.circle,
//             ),

//             child: const Icon(
//               Icons.home_work_outlined,

//               size: 14,

//               color: tealColor,
//             ),
//           ),

//           const SizedBox(width: 7),

//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: const [

//                 Text(
//                   'JAGNA ANIMAL LOVER AND',

//                   style: TextStyle(
//                     color:
//                         Color(0xFF425257),

//                     fontSize: 6.5,

//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),

//                 SizedBox(height: 1),

//                 Text(
//                   'RESCUE GROUP',

//                   style: TextStyle(
//                     color:
//                         Color(0xFF425257),

//                     fontSize: 6.5,

//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Material(
//             color: Colors.transparent,

//             child: InkWell(
//               borderRadius:
//                   BorderRadius.circular(30),

//               onTap: () {
//                 _showMessage(
//                   context,
//                   'Contacting shelter...',
//                 );
//               },

//               child: Container(
//                 width: 27,
//                 height: 27,

//                 decoration:
//                     BoxDecoration(
//                   border: Border.all(
//                     color:
//                         const Color(
//                       0xFFDCE7EA,
//                     ),
//                   ),

//                   shape: BoxShape.circle,
//                 ),

//                 child: const Icon(
//                   Icons.phone_outlined,

//                   size: 12,

//                   color:
//                       Color(0xFF6D7B7F),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SECONDARY BUTTON
//   // ============================================================

//   Widget _buildSecondaryButton({
//     required String label,
//     required IconData icon,
//     required bool filled,
//     required VoidCallback onTap,
//   }) {
//     return SizedBox(
//       height: 38,

//       child: ElevatedButton(
//         onPressed: onTap,

//         style:
//             ElevatedButton.styleFrom(
//           backgroundColor: filled
//               ? const Color(0xFFFFA45D)
//               : Colors.transparent,

//           foregroundColor: filled
//               ? const Color(0xFF7B421E)
//               : primaryColor,

//           elevation: 0,

//           side: BorderSide(
//             color: primaryColor,

//             width: filled ? 0 : 1,
//           ),

//           shape:
//               RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(20),
//           ),

//           padding:
//               const EdgeInsets.symmetric(
//             horizontal: 8,
//           ),
//         ),

//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,

//           children: [

//             Icon(
//               icon,
//               size: 11,
//             ),

//             const SizedBox(width: 4),

//             Text(
//               label,

//               style: const TextStyle(
//                 fontSize: 8.5,

//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     BuildContext context,
//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),

//         behavior:
//             SnackBarBehavior.floating,

//         duration:
//             const Duration(seconds: 2),
//       ),
//     );
//   }
// }