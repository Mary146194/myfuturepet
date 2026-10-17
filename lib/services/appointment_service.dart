import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../appointment_schedule.dart';

class AppointmentService {
  final SupabaseClient _client;
  final DateTime Function() _now;

  AppointmentService({SupabaseClient? client, DateTime Function()? now})
    : _client = client ?? Supabase.instance.client,
      _now = now ?? DateTime.now;

  static const _details =
      '*, shelters(id, name, address, contact_number), pets(id, name, type, breed, image_url)';

  /// Send a pending visit request. Staff approval is separate from submission.
  Future<Map<String, dynamic>> bookAppointment({
    required String shelterId,
    String? petId,
    required DateTime scheduledAt,
    String appointmentType = 'shelter_visit',
    String? notes,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to book an appointment.');
    }
    if (shelterId.trim().isEmpty) {
      throw ArgumentError(
        'Shelter details are missing. Reopen the pet details.',
      );
    }
    if (!const ['shelter_visit', 'meet_and_greet'].contains(appointmentType)) {
      throw ArgumentError('Select a valid appointment type.');
    }
    AppointmentSchedule.validateInstant(scheduledAt, _now());
    final response = await _client
        .from('appointments')
        .insert({
          'user_id': user.id,
          'shelter_id': shelterId.trim(),
          'pet_id': petId == null || petId.trim().isEmpty ? null : petId.trim(),
          'appointment_type': appointmentType,
          'scheduled_at': scheduledAt.toUtc().toIso8601String(),
          'status': 'pending',
          'notes': notes == null || notes.trim().isEmpty ? null : notes.trim(),
        })
        .select(_details)
        .single();
    return response;
  }

  /// Fetch only the authenticated adopter's bookings, ordered by visit time.
  Future<List<Map<String, dynamic>>> fetchMyAppointments({
    bool throwOnError = false,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    try {
      final rows = await _client
          .from('appointments')
          .select(_details)
          .eq('user_id', user.id)
          .order('scheduled_at', ascending: true);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('Error fetching user appointments: $e');
      if (throwOnError) rethrow;
      return [];
    }
  }

  /// Cancel an upcoming appointment.
  Future<bool> cancelAppointment(String appointmentId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    try {
      await _client
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', appointmentId)
          .eq('user_id', user.id);
      return true;
    } catch (e) {
      debugPrint('Error cancelling appointment: $e');
      return false;
    }
  }
}
