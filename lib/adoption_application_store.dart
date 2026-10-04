class AdoptionApplicationStore {
  // ============================================================
  // ALL ADOPTION APPLICATIONS
  // ============================================================

  static final List<Map<String, dynamic>> applications = [];

  // ============================================================
  // CHECK IF USER HAS ANY APPLICATION
  // ============================================================

  static bool get hasApplication {
    return applications.isNotEmpty;
  }

  // ============================================================
  // KEEP COMPATIBILITY WITH OLD CODE
  // ============================================================
  //
  // This returns the latest application.
  // Your existing profile_screen.dart can still use:
  //
  // AdoptionApplicationStore.hasApplication
  //
  // Other old code can still use:
  //
  // AdoptionApplicationStore.application
  //
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
  //
  // IMPORTANT:
  // This NO LONGER replaces the previous application.
  //
  // Every submitted application is added to the list.
  //
  // Example:
  //
  // Bella application
  // Luna application
  // Max application
  //
  // All three will remain stored.
  //
  // ============================================================

  static void saveApplication({
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
  }) {
    final Map<String, dynamic> newApplication = {
      // ========================================================
      // PET
      // ========================================================

      'pet': Map<String, dynamic>.from(pet),

      // ========================================================
      // APPLICATION STATUS
      // ========================================================

      'status': 'Under Review',

      // ========================================================
      // PERSONAL INFORMATION
      // ========================================================

      'fullName': fullName,
      'phone': phone,
      'email': email,
      'age': age,
      'occupation': occupation,

      // ========================================================
      // HOUSEHOLD INFORMATION
      // ========================================================

      'householdType': householdType,
      'address': address,
      'householdMembers': householdMembers,
      'children': children,

      // ========================================================
      // PET EXPERIENCE
      // ========================================================

      'experienceLevel': experienceLevel,
      'previousPets': previousPets,
      'currentPets': currentPets,

      // ========================================================
      // LIFESTYLE
      // ========================================================

      'homeEnvironment': homeEnvironment,
      'activityLevel': activityLevel,
      'timeAvailable': timeAvailable,

      // ========================================================
      // ADOPTION
      // ========================================================

      'adoptionReason': adoptionReason,

      // ========================================================
      // DATE/TIME
      // ========================================================

      'submittedAt': DateTime.now().toIso8601String(),
    };

    // ==========================================================
    // ADD NEW APPLICATION
    // ==========================================================
    //
    // DO NOT use:
    //
    // applications.clear();
    //
    // DO NOT use:
    //
    // applications = [newApplication];
    //
    // because that would erase previous applications.
    //
    // ==========================================================

    applications.add(newApplication);
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
  // REMOVE ONE APPLICATION
  // ============================================================
  //
  // This is optional and can be used later if you want the user
  // to cancel an application.
  //
  // ============================================================

  static void removeApplication(int index) {
    if (index >= 0 && index < applications.length) {
      applications.removeAt(index);
    }
  }

  // ============================================================
  // CLEAR ALL APPLICATIONS
  // ============================================================
  //
  // Optional.
  // Useful for testing only.
  //
  // ============================================================

  static void clearApplications() {
    applications.clear();
  }
}
























// class AdoptionApplicationStore {
//   // ============================================================
//   // ALL ADOPTION APPLICATIONS
//   // ============================================================

//   static final List<Map<String, dynamic>> applications = [];

//   // ============================================================
//   // CHECK IF THERE IS AT LEAST ONE APPLICATION
//   // ============================================================

//   static bool get hasApplication {
//     return applications.isNotEmpty;
//   }

//   // ============================================================
//   // NUMBER OF APPLICATIONS
//   // ============================================================

//   static int get applicationCount {
//     return applications.length;
//   }

//   // ============================================================
//   // ADD APPLICATION
//   // ============================================================

//   static void addApplication(
//     Map<String, dynamic> application,
//   ) {
//     applications.add(
//       Map<String, dynamic>.from(application),
//     );
//   }

//   // ============================================================
//   // GET APPLICATION
//   // ============================================================

//   static Map<String, dynamic>? getApplication(
//     int index,
//   ) {
//     if (index < 0 ||
//         index >= applications.length) {
//       return null;
//     }

//     return applications[index];
//   }

//   // ============================================================
//   // REMOVE APPLICATION
//   // ============================================================

//   static void removeApplication(
//     int index,
//   ) {
//     if (index >= 0 &&
//         index < applications.length) {
//       applications.removeAt(index);
//     }
//   }

//   // ============================================================
//   // CLEAR ALL APPLICATIONS
//   // ============================================================

//   static void clearApplications() {
//     applications.clear();
//   }
// }

























// class AdoptionApplicationStore {
//   // ============================================================
//   // STORED APPLICATION
//   // ============================================================

//   static Map<String, dynamic>? application;

//   // ============================================================
//   // CHECK IF USER HAS AN APPLICATION
//   // ============================================================

//   static bool get hasApplication {
//     return application != null;
//   }

//   // ============================================================
//   // SAVE APPLICATION
//   // ============================================================

//   static void saveApplication({
//     required Map<String, dynamic> pet,

//     required String fullName,
//     required String phone,
//     required String email,
//     required String age,
//     required String occupation,

//     required String householdType,
//     required String address,
//     required String householdMembers,
//     required String children,

//     required String experienceLevel,
//     required String previousPets,
//     required String currentPets,

//     required String homeEnvironment,
//     required String activityLevel,
//     required String timeAvailable,

//     required String adoptionReason,
//   }) {
//     application = {
//       // PET
//       'pet': pet,

//       // STATUS
//       'status': 'Under Review',

//       // PERSONAL INFORMATION
//       'fullName': fullName,
//       'phone': phone,
//       'email': email,
//       'age': age,
//       'occupation': occupation,

//       // HOUSEHOLD
//       'householdType': householdType,
//       'address': address,
//       'householdMembers': householdMembers,
//       'children': children,

//       // PET EXPERIENCE
//       'experienceLevel': experienceLevel,
//       'previousPets': previousPets,
//       'currentPets': currentPets,

//       // LIFESTYLE
//       'homeEnvironment': homeEnvironment,
//       'activityLevel': activityLevel,
//       'timeAvailable': timeAvailable,

//       // ADOPTION
//       'adoptionReason': adoptionReason,

//       // DATE
//       'submittedAt': DateTime.now(),
//     };
//   }

//   // ============================================================
//   // CLEAR APPLICATION
//   // ============================================================

//   static void clearApplication() {
//     application = null;
//   }
// }










// class AdoptionApplicationStore {
//   static final List<Map<String, dynamic>> applications = [];

//   static void addApplication({
//     required Map<String, dynamic> pet,
//     required String fullName,
//     required String phone,
//     required String email,
//     required String age,
//     required String occupation,
//     required String householdType,
//     required String address,
//     required String householdMembers,
//     required String children,
//     required String experienceLevel,
//     required String previousPets,
//     required String currentPets,
//     required String homeEnvironment,
//     required String activityLevel,
//     required String timeAvailable,
//     required String adoptionReason,
//   }) {
//     applications.insert(0, {
//       'id': DateTime.now().millisecondsSinceEpoch.toString(),

//       // PET
//       'pet': Map<String, dynamic>.from(pet),

//       // STATUS
//       'status': 'Under Review',
//       'submittedAt': DateTime.now(),

//       // PERSONAL INFORMATION
//       'fullName': fullName,
//       'phone': phone,
//       'email': email,
//       'age': age,
//       'occupation': occupation,

//       // HOUSEHOLD
//       'householdType': householdType,
//       'address': address,
//       'householdMembers': householdMembers,
//       'children': children,

//       // PET EXPERIENCE
//       'experienceLevel': experienceLevel,
//       'previousPets': previousPets,
//       'currentPets': currentPets,

//       // LIFESTYLE
//       'homeEnvironment': homeEnvironment,
//       'activityLevel': activityLevel,
//       'timeAvailable': timeAvailable,

//       // ADOPTION
//       'adoptionReason': adoptionReason,
//     });
//   }

//   static List<Map<String, dynamic>> getApplications() {
//     return List<Map<String, dynamic>>.from(applications);
//   }

//   static Map<String, dynamic>? getApplicationById(String id) {
//     try {
//       return applications.firstWhere(
//         (application) => application['id'] == id,
//       );
//     } catch (_) {
//       return null;
//     }
//   }
// }