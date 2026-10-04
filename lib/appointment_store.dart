class AppointmentStore {
  // ============================================================
  // ALL APPOINTMENTS
  // ============================================================

  static final List<Map<String, dynamic>> appointments = [];

  // ============================================================
  // CHECK IF USER HAS ANY APPOINTMENT
  // ============================================================

  static bool get hasAppointment {
    return appointments.isNotEmpty;
  }

  // ============================================================
  // LATEST APPOINTMENT
  // ============================================================

  static Map<String, dynamic>? get appointment {
    if (appointments.isEmpty) {
      return null;
    }

    return appointments.last;
  }

  // ============================================================
  // SAVE APPOINTMENT
  // ============================================================

  static void saveAppointment({
    required Map<String, dynamic> pet,
    required String appointmentType,
    required DateTime date,
    required String time,
    required String shelter,
  }) {
    final Map<String, dynamic> newAppointment = {
      'pet': Map<String, dynamic>.from(pet),
      'appointmentType': appointmentType,
      'date': date.toIso8601String(),
      'time': time,
      'shelter': shelter,
      'status': 'Confirmed',
      'createdAt': DateTime.now().toIso8601String(),
    };

    appointments.add(newAppointment);
  }

  // ============================================================
  // GET ALL APPOINTMENTS
  // ============================================================

  static List<Map<String, dynamic>> getAllAppointments() {
    return List<Map<String, dynamic>>.from(appointments);
  }

  // ============================================================
  // COUNT
  // ============================================================

  static int get appointmentCount {
    return appointments.length;
  }

  // ============================================================
  // REMOVE APPOINTMENT
  // ============================================================

  static void removeAppointment(int index) {
    if (index >= 0 && index < appointments.length) {
      appointments.removeAt(index);
    }
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  static void clearAppointments() {
    appointments.clear();
  }
}