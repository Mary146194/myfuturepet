import 'package:flutter/foundation.dart';
import 'appointment_schedule.dart';
import 'services/appointment_service.dart';

class AppointmentStore {
  // ============================================================
  // ALL APPOINTMENTS
  // ============================================================

  static final List<Map<String, dynamic>> appointments = [];

  static Map<String, dynamic> _fromRow(Map<String, dynamic> raw) {
    final pet = raw['pets'] as Map<String, dynamic>?;
    final shelter = raw['shelters'] as Map<String, dynamic>?;
    final scheduled = DateTime.parse(raw['scheduled_at'].toString());
    final wall = AppointmentSchedule.inManila(scheduled);
    final status = (raw['status'] ?? 'pending').toString().toLowerCase();
    return {
      'id': raw['id']?.toString() ?? '',
      'pet': {
        'id': pet?['id']?.toString() ?? '',
        'name': pet?['name']?.toString() ?? 'Shelter Visit',
        'breed': pet?['breed']?.toString() ?? '',
        'image':
            pet?['image_url']?.toString() ?? pet?['image']?.toString() ?? '',
      },
      'appointmentType': raw['appointment_type'] == 'meet_and_greet'
          ? 'Meet and Greet'
          : 'Shelter Visit',
      'scheduledAt': scheduled.toUtc().toIso8601String(),
      'date': wall.toIso8601String().substring(0, 10),
      'time': AppointmentSchedule.formatTime(wall),
      'shelter': shelter?['name']?.toString() ?? 'Shelter not provided',
      'shelterAddress': shelter?['address']?.toString() ?? '',
      'status': switch (status) {
        'confirmed' || 'approved' => 'Confirmed',
        'cancelled' || 'rejected' => 'Cancelled',
        'completed' => 'Completed',
        _ => 'Pending',
      },
      'createdAt': raw['created_at']?.toString() ?? '',
    };
  }

  // ============================================================
  // SYNC WITH SUPABASE
  // ============================================================

  static Future<List<Map<String, dynamic>>> syncWithSupabase({
    AppointmentService? service,
    bool throwOnError = false,
  }) async {
    try {
      final rows = await (service ?? AppointmentService()).fetchMyAppointments(
        throwOnError: true,
      );
      // Build before replacing so malformed/network responses cannot erase data.
      final fetched = rows.map(_fromRow).toList();
      appointments
        ..clear()
        ..addAll(fetched);
    } catch (e) {
      debugPrint('Error syncing appointments with Supabase: $e');
      if (throwOnError) rethrow;
    }
    return appointments;
  }

  // ============================================================
  // CHECK IF USER HAS ANY APPOINTMENT
  // ============================================================

  static bool get hasAppointment => appointments.isNotEmpty;
  // ============================================================
  // LATEST APPOINTMENT
  // ============================================================

  static Map<String, dynamic>? get appointment =>
      appointments.isEmpty ? null : appointments.last;

  // ============================================================
  // SAVE APPOINTMENT
  // ============================================================

  static Future<void> saveAppointment({
    required Map<String, dynamic> pet,
    required String appointmentType,
    required DateTime date,
    required String time,
    required String shelter,
    AppointmentService? service,
  }) async {
    final shelterId = pet['shelter_id']?.toString() ?? '';
    if (shelterId.isEmpty) {
      throw ArgumentError(
        'Shelter details are missing. Reopen the pet details.',
      );
    }
    final type = switch (appointmentType) {
      'Shelter Visit' => 'shelter_visit',
      'Meet and Greet' || 'Meet & Greet' => 'meet_and_greet',
      _ => throw ArgumentError('Select a valid appointment type.'),
    };
    final row = await (service ?? AppointmentService()).bookAppointment(
      shelterId: shelterId,
      petId: pet['id']?.toString(),
      scheduledAt: AppointmentSchedule.scheduledUtc(date, time),
      appointmentType: type,
      notes:
          'Booked via My Future Pet Mobile App. Visit time: Philippines (UTC+8).',
    );
    if (row['id'] == null || row['id'].toString().isEmpty) {
      throw StateError('Appointment confirmation was missing.');
    }
    final confirmed = _fromRow({
      ...row,
      'pets': row['pets'] ?? pet,
      'shelters': row['shelters'] ?? {'name': shelter},
    });
    appointments.removeWhere((entry) => entry['id'] == confirmed['id']);
    appointments.add(confirmed);
  }

  // ============================================================
  // GET ALL APPOINTMENTS
  // ============================================================

  static List<Map<String, dynamic>> getAllAppointments() =>
      List.from(appointments);
  // ============================================================
  // COUNT
  // ============================================================

  static int get appointmentCount => appointments.length;

  // ============================================================
  // REMOVE APPOINTMENT
  // ============================================================

  static void removeAppointment(int index) {
    if (index >= 0 && index < appointments.length) {
      final id = appointments[index]['id']?.toString();
      if (id != null && id.isNotEmpty) {
        AppointmentService().cancelAppointment(id).catchError((_) => false);
      }
      appointments.removeAt(index);
    }
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  static void clearAppointments() => appointments.clear();
}
