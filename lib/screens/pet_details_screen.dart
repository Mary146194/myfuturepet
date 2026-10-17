import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../saved_pet_store.dart';
import '../services/pet_service.dart';
import '../services/theme_service.dart';
import 'adoption_process_screen.dart';
import 'ar_view_screen.dart';
import 'visit_appointment_screen.dart';

class PetDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> pet;
  final PetService? petService;
  final Future<bool> Function(Uri uri, LaunchMode mode)? linkLauncher;

  const PetDetailsScreen({
    super.key,
    required this.pet,
    this.petService,
    this.linkLauncher,
  });

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  late Map<String, dynamic> _pet;
  bool _loadingPet = true;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    _pet = Map<String, dynamic>.from(widget.pet);
    _loadPet();
  }

  Future<void> _loadPet() async {
    setState(() {
      _loadingPet = true;
      _detailError = null;
    });
    try {
      final id = _pet['id']?.toString() ?? '';
      if (id.isEmpty) throw StateError('Missing pet ID');
      final pet = await (widget.petService ?? PetService()).fetchPetById(
        id,
        throwOnError: true,
      );
      if (!mounted) return;
      if (pet == null) {
        _detailError = 'This pet is no longer available.';
      } else {
        _pet = pet;
      }
    } catch (_) {
      if (!mounted) return;
      _detailError = 'Unable to refresh pet details. Please try again.';
    } finally {
      if (mounted) setState(() => _loadingPet = false);
    }
  }

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFA94327);
  static const Color darkText = Color(0xFF062B35);
  static const Color tealColor = Color(0xFF008F82);
  static const Color backgroundColor = Color(0xFFF5FAFD);

  // ============================================================
  // CHECK IF PET IS SAVED
  // ============================================================

  bool get isSaved {
    return SavedPetStore.isSaved(_pet['name'].toString());
  }

  void _sharePet() {
    final petName = _pet['name'] ?? 'This pet';
    final breed = _pet['breed'] ?? 'Adoptable pet';
    SharePlus.instance.share(
      ShareParams(
        text:
            'Meet $petName, a loving $breed looking for a forever home at My Future Pet! Check them out in the app.',
        subject: 'Meet $petName on My Future Pet',
      ),
    );
  }

  void _toggleSave() {
    setState(() {
      SavedPetStore.togglePet(_pet);
    });

    if (isSaved) {
      _showMessage(context, '${_pet['name']} added to Saved Pets.');
    } else {
      _showMessage(context, '${_pet['name']} removed from Saved Pets.');
    }
  }

  Future<bool> _launchContact(Uri uri) {
    final launcher = widget.linkLauncher;
    if (launcher != null) return launcher(uri, LaunchMode.externalApplication);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _chatOnMessenger() async {
    try {
      final opened = await _launchContact(
        Uri.parse('https://m.me/jagnaanimallover'),
      );
      if (!opened && mounted) {
        _showMessage(context, 'Could not open Messenger. Please try again.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage(context, 'Could not open Messenger. Please try again.');
      }
    }
  }

  Future<void> _callShelter() async {
    final rawPhone = _pet['shelterPhone']?.toString().trim() ?? '';
    if (rawPhone.isEmpty) {
      _showMessage(context, 'Shelter contact number not provided.');
      return;
    }
    final phone = rawPhone.replaceAll(RegExp(r'[\s().-]'), '');
    if (!RegExp(r'^\+?\d{7,15}$').hasMatch(phone)) {
      _showMessage(context, 'Shelter contact number is invalid.');
      return;
    }
    try {
      final opened = await _launchContact(Uri.parse('tel:$phone'));
      if (!opened && mounted) {
        _showMessage(
          context,
          'Could not open the phone app. Shelter contact: $rawPhone',
        );
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          context,
          'Could not open the phone app. Shelter contact: $rawPhone',
        );
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeService.isDarkMode(context);

    final rawStatus = (_pet['status'] ?? 'Available').toString();
    final bool isAvailable =
        !_loadingPet &&
        _detailError == null &&
        rawStatus.toLowerCase() == 'available';

    final String name = (_pet['name'] ?? 'Pet').toString();
    final String breed = (_pet['breed'] ?? 'Unknown Breed').toString();
    final String category =
        (_pet['category'] ?? (_pet['type'] == 'dog' ? 'Dogs' : 'Cats'))
            .toString();
    final String gender = (_pet['gender'] ?? 'Unknown').toString();
    final bool isFemale = gender.toLowerCase().contains('female');

    final String location =
        (_pet['shelterAddress'] ??
                _pet['location'] ??
                'Jagna, Bohol, Philippines')
            .toString();

    final String age = (_pet['age'] ?? 'Young').toString();
    final String weight =
        (_pet['weight'] ??
                (_pet['weight_kg'] != null
                    ? '${_pet['weight_kg']} kg'
                    : 'Normal'))
            .toString();
    final String size = (_pet['size'] ?? 'Medium').toString();
    final String coatColor = (_pet['color'] ?? _pet['coatColor'] ?? 'Mixed')
        .toString();

    final String rawVaccinationStatus =
        (_pet['vaccination_status'] ??
                _pet['vaccinationStatus'] ??
                'Not recorded')
            .toString();
    final String vaccinationStatus = _formatTitleCase(rawVaccinationStatus);
    final String healthCondition =
        (_pet['health_condition'] ?? _pet['healthCondition'] ?? 'Not recorded')
            .toString();
    final String deworming = (_pet['deworming'] ?? 'Not recorded').toString();
    final String rabies = (_pet['rabies'] ?? 'Not recorded').toString();
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : backgroundColor,
      body: Stack(
        children: [
          // ==================================================
          // MAIN SCROLLABLE CONTENT
          // ==================================================
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 145),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_loadingPet) const LinearProgressIndicator(),
                if (_detailError != null)
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(_detailError!),
                          TextButton(
                            onPressed: _loadPet,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                // ==================================================
                // HERO IMAGE
                // ==================================================
                SizedBox(
                  height: 390,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Pet Image
                      Image.network(
                        _pet['image']?.toString() ??
                            _pet['image_url']?.toString() ??
                            '',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE9EEF0),
                            child: Icon(
                              _pet['category'] == 'Dogs'
                                  ? Icons.pets
                                  : Icons.cruelty_free,
                              size: 80,
                              color: primaryColor,
                            ),
                          );
                        },
                      ),

                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.20),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),

                      // Top App Bar Icons
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 14,
                        right: 14,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            _buildCircleButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.pop(context),
                            ),

                            // Share + Favorite Buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildCircleButton(
                                  icon: Icons.share_outlined,
                                  onTap: _sharePet,
                                ),
                                const SizedBox(width: 8),
                                _buildCircleButton(
                                  icon: isSaved
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  iconColor: isSaved
                                      ? primaryColor
                                      : (isDark
                                            ? const Color(0xFFF8FAFC)
                                            : darkText),
                                  onTap: _toggleSave,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bottom Left Adoption Status Pill
                      Positioned(
                        bottom: 24,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: tealColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                isAvailable
                                    ? 'Available for Free Adoption'
                                    : (rawStatus.isNotEmpty
                                          ? rawStatus
                                          : 'Adoption Pending'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // MAIN DETAILS CARD
                // ==================================================
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 22),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.25 : 0.04,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Gender Badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFF8FAFC)
                                      : darkText,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  height: 1.15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isFemale
                                    ? (isDark
                                          ? const Color(
                                              0xFF831843,
                                            ).withValues(alpha: 0.35)
                                          : const Color(0xFFFFF0F5))
                                    : (isDark
                                          ? const Color(
                                              0xFF0C4A6E,
                                            ).withValues(alpha: 0.35)
                                          : const Color(0xFFE8F6FC)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isFemale
                                      ? (isDark
                                            ? const Color(
                                                0xFFDB2777,
                                              ).withValues(alpha: 0.45)
                                            : const Color(0xFFF7B5CD))
                                      : (isDark
                                            ? const Color(
                                                0xFF0284C7,
                                              ).withValues(alpha: 0.45)
                                            : const Color(0xFFBCE3F7)),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isFemale ? Icons.female : Icons.male,
                                    size: 15,
                                    color: isFemale
                                        ? (isDark
                                              ? const Color(0xFFF472B6)
                                              : const Color(0xFFD63384))
                                        : (isDark
                                              ? const Color(0xFF38BDF8)
                                              : const Color(0xFF0284C7)),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isFemale ? 'Female' : 'Male',
                                    style: TextStyle(
                                      color: isFemale
                                          ? (isDark
                                                ? const Color(0xFFF472B6)
                                                : const Color(0xFFD63384))
                                          : (isDark
                                                ? const Color(0xFF38BDF8)
                                                : const Color(0xFF0284C7)),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Breed • Category
                        Text(
                          '$breed • $category',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF45565B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Color(0xFFB85D3B),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF75858A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Divider
                        Divider(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFEEF3F5),
                          height: 1,
                          thickness: 1,
                        ),

                        const SizedBox(height: 16),

                        // 4 Quick Stats Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickStatCard(
                                icon: Icons.cake_outlined,
                                iconColor: tealColor,
                                iconBg: const Color(0xFFE5F8F6),
                                value: age,
                                label: 'Age',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildQuickStatCard(
                                icon: Icons.inventory_2_outlined,
                                iconColor: const Color(0xFFEA580C),
                                iconBg: const Color(0xFFFFF2E8),
                                value: weight,
                                label: 'Weight',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildQuickStatCard(
                                icon: Icons.straighten_outlined,
                                iconColor: const Color(0xFF0284C7),
                                iconBg: const Color(0xFFEBF7FD),
                                value: size,
                                label: 'Size',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildQuickStatCard(
                                icon: Icons.pets,
                                iconColor: const Color(0xFF8B5CF6),
                                iconBg: const Color(0xFFF5EBFD),
                                value: coatColor,
                                label: 'Coat Color',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // HEALTH & MEDICAL STATUS
                // ==================================================
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.20 : 0.03,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? tealColor.withValues(alpha: 0.18)
                                  : const Color(0xFFE5F8F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.security_outlined,
                              size: 20,
                              color: isDark
                                  ? const Color(0xFF2DD4BF)
                                  : tealColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Health & Medical Status',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFF8FAFC)
                                    : darkText,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(
                                      0xFF14532D,
                                    ).withValues(alpha: 0.45)
                                  : const Color(0xFFD4F7DF),
                              borderRadius: BorderRadius.circular(20),
                              border: isDark
                                  ? Border.all(
                                      color: const Color(
                                        0xFF22C55E,
                                      ).withValues(alpha: 0.4),
                                    )
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 13,
                                  color: isDark
                                      ? const Color(0xFF4ADE80)
                                      : const Color(0xFF16A34A),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Health Records',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF4ADE80)
                                        : const Color(0xFF16A34A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 2x2 Grid of Medical Status Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildMedicalCard(
                              icon: Icons.vaccines_outlined,
                              title: 'Vaccination',
                              value: vaccinationStatus,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMedicalCard(
                              icon: Icons.favorite_border_rounded,
                              title: 'Health Condition',
                              value: healthCondition,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildMedicalCard(
                              icon: Icons.verified_outlined,
                              title: 'Deworming',
                              value: deworming,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMedicalCard(
                              icon: Icons.shield_outlined,
                              title: 'Rabies Protection',
                              value: rabies,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Note
                      Text(
                        'Rescue pets undergo rigorous medical checkup and quarantine before rehoming.',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF88989D),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // PERSONALITY, ABOUT, & SHELTER CONTAINER
                // ==================================================
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.20 : 0.03,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personality Header
                      Text(
                        'Personality',
                        style: TextStyle(
                          color: isDark ? const Color(0xFFF8FAFC) : darkText,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Personality Chips
                      Builder(
                        builder: (context) {
                          List<dynamic> personalityList = [];
                          final rawPersonality = _pet['personality'];
                          if (rawPersonality is List) {
                            personalityList = rawPersonality;
                          } else if (rawPersonality is String &&
                              rawPersonality.trim().isNotEmpty) {
                            personalityList = rawPersonality
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();
                          } else {
                            final temperament = _pet['temperament']?.toString();
                            if (temperament != null &&
                                temperament.trim().isNotEmpty) {
                              personalityList = temperament
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();
                            }
                          }
                          if (personalityList.isEmpty) {
                            personalityList = ['Gentle', 'smart'];
                          }

                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: personalityList.map((personality) {
                              return _buildPersonalityChip(
                                personality.toString(),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 22),

                      // About Section
                      Text(
                        'About $name',
                        style: TextStyle(
                          color: isDark ? const Color(0xFFF8FAFC) : darkText,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 9),

                      Text(
                        (_pet['about'] ??
                                _pet['description'] ??
                                'Rescue background not provided.')
                            .toString(),
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF4B5E63),
                          fontSize: 14,
                          height: 1.55,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Shelter Card
                      _buildShelterCard(context),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // FIXED BOTTOM ACTION BAR
          // ============================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE6EDF0),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // AR Preview & Schedule Visit Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildSecondaryButton(
                            label: 'View in AR',
                            icon: Icons.view_in_ar_outlined,
                            isAR: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ARViewScreen(pet: _pet),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSecondaryButton(
                            label: 'Schedule Visit',
                            icon: Icons.calendar_month_outlined,
                            isAR: false,
                            onTap: () {
                              _openVisitAppointment(context);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Apply for Adoption Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isAvailable
                            ? () {
                                _openAdoptionProcess(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          disabledBackgroundColor: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFB9B9B9),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: isDark
                              ? const Color(0xFF64748B)
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isAvailable
                                  ? 'Adopt Me'
                                  : (_loadingPet
                                        ? 'Loading...'
                                        : _detailError != null
                                        ? 'Details unavailable'
                                        : rawStatus.toLowerCase() == 'adopted'
                                        ? 'Already Adopted'
                                        : 'Adoption Pending'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
    );
  }

  // ============================================================
  // QUICK STAT CARD
  // ============================================================

  Widget _buildQuickStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    final bool isDark = ThemeService.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE6EDF0),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.18) : iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFFF8FAFC) : darkText,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF88989D),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTitleCase(String val) {
    if (val.isEmpty) return val;
    return val
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  // ============================================================
  // MEDICAL CARD
  // ============================================================

  Widget _buildMedicalCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final bool isDark = ThemeService.isDarkMode(context);
    final formattedValue = _formatTitleCase(value);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FCFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE8EFF2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? const Color(0xFF2DD4BF) : tealColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF88989D),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedValue,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF8FAFC) : darkText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
  // CIRCLE BUTTON
  // ============================================================

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = darkText,
  }) {
    final bool isDark = ThemeService.isDarkMode(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: isDark
                ? Border.all(color: const Color(0xFF334155), width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: (iconColor == darkText && isDark)
                ? const Color(0xFFF8FAFC)
                : iconColor,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PERSONALITY CHIP
  // ============================================================

  Widget _buildPersonalityChip(String text) {
    final bool isDark = ThemeService.isDarkMode(context);

    IconData icon;

    switch (text.toLowerCase()) {
      case 'friendly':
        icon = Icons.favorite_border_rounded;
        break;
      case 'active':
      case 'playful':
      case 'high energy':
        icon = Icons.bolt_rounded;
        break;
      case 'good with kids':
        icon = Icons.child_friendly_rounded;
        break;
      case 'calm':
      case 'quiet':
      case 'gentle':
        icon = Icons.spa_outlined;
        break;
      case 'smart':
      case 'knows basic commands':
        icon = Icons.psychology_outlined;
        break;
      case 'independent':
        icon = Icons.self_improvement_outlined;
        break;
      case 'affectionate':
        icon = Icons.favorite_border_rounded;
        break;
      case 'loyal':
        icon = Icons.shield_outlined;
        break;
      default:
        icon = Icons.pets_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? tealColor.withValues(alpha: 0.18)
            : const Color(0xFFE5F8F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? tealColor.withValues(alpha: 0.35)
              : const Color(0xFFC7EDE6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? const Color(0xFF2DD4BF) : tealColor,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF134E48),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SHELTER CARD
  // ============================================================

  Widget _buildShelterCard(BuildContext context) {
    final bool isDark = ThemeService.isDarkMode(context);

    final shelterName = (_pet['shelter'] ?? 'Shelter not provided').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
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
                      ? tealColor.withValues(alpha: 0.18)
                      : const Color(0xFFE9F7F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_work_outlined,
                  size: 22,
                  color: isDark ? const Color(0xFF2DD4BF) : tealColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  [shelterName, _pet['shelterAddress'], _pet['shelterPhone']]
                      .where(
                        (value) =>
                            value != null && value.toString().trim().isNotEmpty,
                      )
                      .join('\n'),
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFF425257),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _chatOnMessenger,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Chat on Messenger'),
                style: FilledButton.styleFrom(
                  backgroundColor: tealColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _callShelter,
                icon: const Icon(Icons.phone_outlined, size: 18),
                label: const Text('Call Shelter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? const Color(0xFF2DD4BF) : tealColor,
                  side: BorderSide(
                    color: isDark ? const Color(0xFF2DD4BF) : tealColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
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
  // SECONDARY BUTTON (AR Preview & Schedule Visit)
  // ============================================================

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required bool isAR,
    required VoidCallback onTap,
  }) {
    final bool isDark = ThemeService.isDarkMode(context);

    final Color bg = isDark
        ? (isAR
              ? const Color(0xFFEA580C).withValues(alpha: 0.16)
              : const Color(0xFF008F82).withValues(alpha: 0.16))
        : (isAR ? const Color(0xFFFFF7ED) : const Color(0xFFE6F9F5));

    final Color borderColor = isDark
        ? (isAR
              ? const Color(0xFFF97316).withValues(alpha: 0.50)
              : const Color(0xFF008F82).withValues(alpha: 0.50))
        : (isAR
              ? const Color(0xFFF97316).withValues(alpha: 0.55)
              : const Color(0xFF008F82).withValues(alpha: 0.35));

    final Color contentColor = isDark
        ? (isAR ? const Color(0xFFFB923C) : const Color(0xFF2DD4BF))
        : (isAR ? const Color(0xFFEA580C) : const Color(0xFF008F82));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: contentColor),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: contentColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
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
  // OPEN ADOPTION PROCESS
  // ============================================================

  Future<void> _openAdoptionProcess(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Adoption Application',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AdoptionProcessScreen(pet: _pet);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.96,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
    if (mounted) await _loadPet();
  }

  // ============================================================
  // OPEN VISIT APPOINTMENT
  // ============================================================

  void _openVisitAppointment(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Visit Appointment',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return VisitAppointmentScreen(pet: _pet);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.96,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 14)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
