import 'package:flutter/foundation.dart';
import 'services/adoption_service.dart';
import 'services/pet_service.dart';

class AdoptionApplicationStore {
  // ============================================================
  // ALL ADOPTION APPLICATIONS
  // ============================================================

  static final List<Map<String, dynamic>> applications = [];

  // ============================================================
  // SYNC WITH SUPABASE
  // ============================================================

  static Future<List<Map<String, dynamic>>> syncWithSupabase() async {
    try {
      // Throw on failure so an offline refresh cannot wipe the list.
      applyRows(await AdoptionService().fetchMyApplications(throwOnError: true));
    } catch (e) {
      debugPrint('Error syncing adoption applications: $e');
    }
    return applications;
  }

  /// Replace the list from `adoption_applications` rows (with nested `pets`).
  /// AdoptionJourneyService calls this too, so every screen shows one truth.
  static void applyRows(List<Map<String, dynamic>> rows) {
    final fetched = <Map<String, dynamic>>[];
    for (var raw in rows) {
          final petRaw = raw['pets'] as Map<String, dynamic>?;
          final shelterRaw = petRaw?['shelters'] as Map<String, dynamic>?;
          fetched.add({
            'id': raw['id']?.toString() ?? '',
            'pet': {
              'id': petRaw?['id']?.toString() ?? '',
              'shelter_id': shelterRaw?['id']?.toString() ?? '',
              'shelter': shelterRaw?['name']?.toString() ?? '',
              'name': petRaw?['name']?.toString() ?? 'Pet',
              'breed': petRaw?['breed']?.toString() ?? '',
              'age':
                  PetService.ageFromBirthdate(petRaw?['birthdate']) ??
                  'Age unknown',
              'gender': petRaw?['gender']?.toString() ?? '',
              'image': petRaw?['image_url']?.toString() ?? '',
              'status': petRaw?['status']?.toString() ?? 'Available',
            },
            'status': statusLabel(raw['status']),
            'fullName': raw['full_name']?.toString() ?? '',
            'phone': raw['contact_number']?.toString() ?? '',
            'email': '',
            'householdType': raw['housing_type']?.toString() ?? '',
            'address': raw['address']?.toString() ?? '',
            'submittedAt': raw['created_at']?.toString() ?? '',
            'reviewNotes': raw['review_notes']?.toString() ?? '',
            'decidedAt': raw['decided_at']?.toString() ?? '',
          });
    }
    applications
      ..clear()
      ..addAll(fetched);
  }

  // ============================================================
  // CHECK IF USER HAS ANY APPLICATION
  // ============================================================

  static bool get hasApplication {
    return applications.isNotEmpty;
  }

  /// Finished: pet went home (approved + adopted), rejected or withdrawn.
  /// Mirrors AdoptionJourney so the list and the road agree.
  static bool isDone(Map<String, dynamic> application) {
    final status = application['status']?.toString();
    if (status == 'Rejected' || status == 'Withdrawn') return true;
    final pet = application['pet'] as Map?;
    return status == 'Approved' &&
        pet?['status']?.toString().toLowerCase() == 'adopted';
  }

  /// Only applications still being processed count on Profile.
  static int get activeCount => applications.where((a) => !isDone(a)).length;

  /// The same words the admin uses for each database status.
  static String statusLabel(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'under_review':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return 'Pending';
    }
  }

  /// Status of the most recent application, for the Profile summary.
  static String? get latestStatus {
    if (applications.isEmpty) return null;
    final sorted = [...applications]
      ..sort(
        (a, b) => (b['submittedAt'] ?? '').toString().compareTo(
          (a['submittedAt'] ?? '').toString(),
        ),
      );
    return sorted.first['status']?.toString();
  }

  // ============================================================
  // LATEST APPLICATION
  // ============================================================

  static Map<String, dynamic>? get application {
    if (applications.isEmpty) {
      return null;
    }
    return applications.last;
  }

  // ============================================================
  // SAVE APPLICATION
  // ============================================================

  static Future<void> saveApplication({
    required Map<String, dynamic> pet,

    // PERSONAL INFORMATION
    required String fullName,
    required String phone,
    required String email,
    required String age,
    required String occupation,

    // HOUSEHOLD INFORMATION
    required String householdType,
    required String address,
    required String householdMembers,
    required String children,

    // PET EXPERIENCE
    required String experienceLevel,
    required String previousPets,
    required String currentPets,

    // LIFESTYLE
    required String homeEnvironment,
    required String activityLevel,
    required String timeAvailable,

    // ADOPTION
    required String adoptionReason,
    String yardAvailability = 'Not provided',
    AdoptionService? service,
  }) async {
    final Map<String, dynamic> newApplication = {
      'pet': Map<String, dynamic>.from(pet),
      'status': 'Pending',
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'age': age,
      'occupation': occupation,
      'householdType': householdType,
      'address': address,
      'householdMembers': householdMembers,
      'children': children,
      'experienceLevel': experienceLevel,
      'previousPets': previousPets,
      'currentPets': currentPets,
      'homeEnvironment': homeEnvironment,
      'yardAvailability': yardAvailability,
      'activityLevel': activityLevel,
      'timeAvailable': timeAvailable,
      'adoptionReason': adoptionReason,
      'submittedAt': DateTime.now().toIso8601String(),
    };

    // Persist to Supabase Database first so the applicant is only told the
    // application was sent when it actually reached the shelter's queue.
    final petId = pet['id']?.toString() ?? '';
    if (petId.isEmpty) {
      throw Exception('This pet cannot accept applications right now.');
    }

    final currentPetsText = currentPets.trim();
    final hasOtherPets =
        currentPetsText.isNotEmpty &&
        !RegExp(
          r'^(none|no|n/a|na|nil|wala)\b',
          caseSensitive: false,
        ).hasMatch(currentPetsText);

    // The table has no columns for these answers, so keep them readable in
    // reason_for_adoption where the admin screening modal already shows them.
    final reasonWithDetails = [
      adoptionReason,
      '— Applicant details —',
      'Age: $age',
      'Household members: $householdMembers, children: $children',
      'Pet experience: $experienceLevel',
      'Previous pets: $previousPets',
      'Home environment: $homeEnvironment',
      'Yard availability: $yardAvailability',
      'Activity level: $activityLevel',
      'Time available: $timeAvailable',
      'Email: $email',
    ].join('\n');

    try {
      final res = await (service ?? AdoptionService()).submitApplication(
        petId: petId,
        fullName: fullName,
        contactNumber: phone,
        address: address,
        occupation: occupation,
        housingType: householdType,
        hasOtherPets: hasOtherPets,
        otherPetsDetails: hasOtherPets ? currentPetsText : null,
        reasonForAdoption: reasonWithDetails,
      );
      if (res['id'] == null || res['id'].toString().isEmpty) {
        throw StateError('Application confirmation was missing.');
      }
      if (res['id'] != null) {
        newApplication['id'] = res['id'].toString();
      }
      applications.add(newApplication);
    } catch (e) {
      debugPrint('Adoption submission to Supabase error: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET ALL APPLICATIONS
  // ============================================================

  static List<Map<String, dynamic>> getAllApplications() {
    return List<Map<String, dynamic>>.from(applications);
  }

  // ============================================================
  // GET APPLICATION COUNT
  // ============================================================

  static int get applicationCount {
    return applications.length;
  }

  // ============================================================
  // CLEAR ALL APPLICATIONS
  // ============================================================

  static void clear() {
    applications.clear();
  }

  static void clearApplications() {
    applications.clear();
  }
}
