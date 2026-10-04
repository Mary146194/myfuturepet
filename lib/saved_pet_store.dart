import 'package:flutter/foundation.dart';

class SavedPetStore {
  // ============================================================
  // SAVED PETS
  // ============================================================

  static final List<Map<String, dynamic>> savedPets = [];

  // ============================================================
  // CHECK IF PET IS SAVED
  // ============================================================

  static bool isSaved(String petName) {
    return savedPets.any(
      (pet) => pet['name'].toString() == petName,
    );
  }

  // ============================================================
  // ADD PET
  // ============================================================

  static void addPet(
    Map<String, dynamic> pet,
  ) {
    final String petName =
        pet['name'].toString();

    if (!isSaved(petName)) {
      savedPets.add(
        Map<String, dynamic>.from(pet),
      );

      _notify();
    }
  }

  // ============================================================
  // REMOVE PET
  // ============================================================

  static void removePet(
    String petName,
  ) {
    savedPets.removeWhere(
      (pet) =>
          pet['name'].toString() == petName,
    );

    _notify();
  }

  // ============================================================
  // TOGGLE SAVE
  // ============================================================

  static void togglePet(
    Map<String, dynamic> pet,
  ) {
    final String petName =
        pet['name'].toString();

    if (isSaved(petName)) {
      removePet(petName);
    } else {
      addPet(pet);
    }
  }

  // ============================================================
  // GET ALL SAVED PETS
  // ============================================================

  static List<Map<String, dynamic>>
      getAllSavedPets() {
    return List<Map<String, dynamic>>.from(
      savedPets,
    );
  }

  // ============================================================
  // SAVED PET COUNT
  // ============================================================

  static int get savedCount {
    return savedPets.length;
  }

  // ============================================================
  // CLEAR ALL SAVED PETS
  // ============================================================

  static void clearAll() {
    savedPets.clear();

    _notify();
  }

  // ============================================================
  // CHANGE NOTIFIER
  // ============================================================

  static final ValueNotifier<int>
      changeNotifier =
      ValueNotifier<int>(0);

  static void _notify() {
    changeNotifier.value++;
  }
}
























// import 'package:flutter/foundation.dart';

// class SavedPetStore {
//   // ============================================================
//   // SAVED PETS
//   // ============================================================

//   static final List<Map<String, dynamic>> savedPets = [];

//   // ============================================================
//   // CHECK IF PET IS SAVED
//   // ============================================================

//   static bool isSaved(String petName) {
//     return savedPets.any(
//       (pet) => pet['name'].toString() == petName,
//     );
//   }

//   // ============================================================
//   // ADD PET
//   // ============================================================

//   static void addPet(Map<String, dynamic> pet) {
//     final String petName = pet['name'].toString();

//     if (!isSaved(petName)) {
//       savedPets.add(
//         Map<String, dynamic>.from(pet),
//       );

//       _notify();
//     }
//   }

//   // ============================================================
//   // REMOVE PET
//   // ============================================================

//   static void removePet(String petName) {
//     savedPets.removeWhere(
//       (pet) => pet['name'].toString() == petName,
//     );

//     _notify();
//   }

//   // ============================================================
//   // TOGGLE SAVE
//   // ============================================================

//   static void togglePet(
//     Map<String, dynamic> pet,
//   ) {
//     final String petName = pet['name'].toString();

//     if (isSaved(petName)) {
//       removePet(petName);
//     } else {
//       addPet(pet);
//     }
//   }

//   // ============================================================
//   // GET ALL SAVED PETS
//   // ============================================================

//   static List<Map<String, dynamic>> getAllSavedPets() {
//     return List<Map<String, dynamic>>.from(
//       savedPets,
//     );
//   }

//   // ============================================================
//   // SAVED PET COUNT
//   // ============================================================

//   static int get savedCount {
//     return savedPets.length;
//   }

//   // ============================================================
//   // CLEAR ALL SAVED PETS
//   // ============================================================

//   static void clearAll() {
//     savedPets.clear();
//     _notify();
//   }

//   // ============================================================
//   // CHANGE NOTIFIER
//   // ============================================================

//   static final ValueNotifier<int> changeNotifier =
//       ValueNotifier<int>(0);

//   static void _notify() {
//     changeNotifier.value++;
//   }
// }