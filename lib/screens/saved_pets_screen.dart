import 'package:flutter/material.dart';

import '../saved_pet_store.dart';
import 'pet_details_screen.dart';

class SavedPetsScreen extends StatefulWidget {
  final VoidCallback? onBrowsePets;

  const SavedPetsScreen({
    super.key,
    this.onBrowsePets,
  });

  @override
  State<SavedPetsScreen> createState() =>
      _SavedPetsScreenState();
}

class _SavedPetsScreenState
    extends State<SavedPetsScreen> {
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: detailBrown,

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              width: double.infinity,

              color: detailBlue,

              padding:
                  const EdgeInsets.fromLTRB(
                14,
                10,
                14,
                10,
              ),

              child: Row(
                children: [
                  // BACK BUTTON
                  Material(
                    color: Colors.transparent,

                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),

                      child: Container(
                        width: 40,
                        height: 40,

                        decoration:
                            const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons
                              .arrow_back_ios_new_rounded,

                          size: 17,

                          color:
                              Color(0xFF526069),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // TITLE
                  const Expanded(
                    child: Text(
                      'Saved Pets',

                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 23,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  // SAVED COUNT
                  ValueListenableBuilder<int>(
                    valueListenable:
                        SavedPetStore
                            .changeNotifier,

                    builder: (
                      context,
                      value,
                      child,
                    ) {
                      final int count =
                          SavedPetStore.savedCount;

                      if (count == 0) {
                        return const SizedBox
                            .shrink();
                      }

                      return Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),

                        decoration:
                            BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),

                        child: Text(
                          '$count',

                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================

            Expanded(
              child:
                  ValueListenableBuilder<int>(
                valueListenable:
                    SavedPetStore
                        .changeNotifier,

                builder: (
                  context,
                  value,
                  child,
                ) {
                  final savedPets =
                      SavedPetStore
                          .getAllSavedPets();

                  // ==================================================
                  // EMPTY STATE
                  // ==================================================

                  if (savedPets.isEmpty) {
                    return _buildEmptyState(
                      context,
                    );
                  }

                  // ==================================================
                  // SAVED PET LIST
                  // ==================================================

                  return ListView.builder(
                    physics:
                        const BouncingScrollPhysics(),

                    padding:
                        const EdgeInsets.fromLTRB(
                      14,
                      18,
                      14,
                      30,
                    ),

                    itemCount:
                        savedPets.length,

                    itemBuilder:
                        (context, index) {
                      final pet =
                          savedPets[index];

                      return _buildSavedPetCard(
                        context,
                        pet,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 35,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            // HEART CIRCLE
            Container(
              width: 90,
              height: 90,

              decoration:
                  const BoxDecoration(
                color: Color(0xFFFBE9E4),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.favorite_border_rounded,

                size: 43,

                color: primaryColor,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'No Saved Pets Yet',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color: darkText,
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Pets you favorite will appear here so you can easily find them again.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            // BROWSE PETS
            SizedBox(
              height: 46,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);

                  widget.onBrowsePets?.call();
                },

                icon: const Icon(
                  Icons.pets_outlined,
                  size: 18,
                ),

                label: const Text(
                  'Browse Pets',
                ),

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
                    horizontal: 20,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
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
  // SAVED PET CARD
  // ============================================================

  Widget _buildSavedPetCard(
    BuildContext context,
    Map<String, dynamic> pet,
  ) {
    final String petName =
        pet['name'].toString();

    final String breed =
        pet['breed'].toString();

    final String age =
        pet['age'].toString();

    final String gender =
        pet['gender'].toString();

    final String status =
        pet['status'].toString();

    final String image =
        pet['image'].toString();

    final bool isAvailable =
        status == 'Available';

    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.05,
            ),

            blurRadius: 8,

            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PetDetailsScreen(
                  pet: pet,
                ),
              ),
            );

            setState(() {});
          },

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          child: Padding(
            padding:
                const EdgeInsets.all(
              10,
            ),

            child: Row(
              children: [
                // ==================================================
                // PET IMAGE
                // ==================================================

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),

                  child: Image.network(
                    image,

                    width: 105,
                    height: 105,

                    fit: BoxFit.cover,

                    errorBuilder:
                        (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Container(
                        width: 105,
                        height: 105,

                        color:
                            const Color(
                          0xFFE9EEF0,
                        ),

                        child: Icon(
                          pet['category'] ==
                                  'Dogs'
                              ? Icons.pets
                              : Icons
                                  .cruelty_free,

                          size: 42,

                          color:
                              primaryColor,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                // ==================================================
                // PET INFORMATION
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // NAME
                      Text(
                        petName,

                        maxLines: 1,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(
                          color: darkText,
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      // BREED
                      Text(
                        breed,

                        maxLines: 1,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(
                          color:
                              Color(0xFF5E6E73),
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      // AGE + GENDER
                      Text(
                        '$age • $gender',

                        style:
                            const TextStyle(
                          color:
                              Color(0xFF718085),
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      // STATUS
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),

                        decoration:
                            BoxDecoration(
                          color: isAvailable
                              ? const Color(
                                  0xFFD9F2F0,
                                )
                              : const Color(
                                  0xFFF0EEEE,
                                ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),
                        ),

                        child: Text(
                          status,

                          style:
                              TextStyle(
                            color: isAvailable
                                ? tealColor
                                : Colors
                                    .grey
                                    .shade600,

                            fontSize: 10,

                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 6,
                ),

                // ==================================================
                // REMOVE FAVORITE
                // ==================================================

                Material(
                  color:
                      Colors.transparent,

                  child: InkWell(
                    onTap: () {
                      SavedPetStore
                          .removePet(
                        petName,
                      );
                    },

                    borderRadius:
                        BorderRadius
                            .circular(
                      30,
                    ),

                    child: Container(
                      width: 40,
                      height: 40,

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFFBE9E4,
                        ),

                        shape:
                            BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons
                            .favorite_rounded,

                        size: 20,

                        color:
                            primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}