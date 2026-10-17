import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdoptionService {
  final SupabaseClient _client;

  AdoptionService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Submit a new adoption application for a specific pet
  Future<Map<String, dynamic>> submitApplication({
    required String petId,
    required String fullName,
    required String contactNumber,
    required String address,
    String? occupation,
    required String housingType,
    bool hasOtherPets = false,
    String? otherPetsDetails,
    String? reasonForAdoption,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception(
        'You must be logged in to submit an adoption application.',
      );
    }

    // Normalize housing_type to match database check constraint: ('house', 'apartment', 'compound', 'other')
    String normalizedHousing = housingType.trim().toLowerCase();
    if (normalizedHousing.contains('house') ||
        normalizedHousing.contains('townhouse')) {
      normalizedHousing = 'house';
    } else if (normalizedHousing.contains('apartment') ||
        normalizedHousing.contains('condo') ||
        normalizedHousing.contains('condominium')) {
      normalizedHousing = 'apartment';
    } else if (normalizedHousing.contains('compound')) {
      normalizedHousing = 'compound';
    } else {
      normalizedHousing = 'other';
    }

    try {
      final insertData = {
        'pet_id': petId,
        'applicant_id': user.id,
        'full_name': fullName.trim(),
        'contact_number': contactNumber.trim(),
        'address': address.trim(),
        'occupation': occupation?.trim().isEmpty == true
            ? null
            : occupation?.trim(),
        'housing_type': normalizedHousing,
        'has_other_pets': hasOtherPets,
        'other_pets_details': otherPetsDetails?.trim().isEmpty == true
            ? null
            : otherPetsDetails?.trim(),
        'reason_for_adoption': reasonForAdoption?.trim().isEmpty == true
            ? null
            : reasonForAdoption?.trim(),
        'status': 'pending',
      };

      final response = await _client
          .from('adoption_applications')
          .insert(insertData)
          .select()
          .single();

      return response;
    } catch (e) {
      debugPrint('Error submitting adoption application: $e');
      rethrow;
    }
  }

  /// Fetch all applications submitted by the current user
  Future<List<Map<String, dynamic>>> fetchMyApplications() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('adoption_applications')
          .select(
            '*, pets(id, name, type, breed, image_url, status, shelters(id, name, address, contact_number))',
          )
          .eq('applicant_id', user.id)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error fetching user applications: $e');
      return [];
    }
  }

  /// Withdraw an existing pending application
  Future<bool> withdrawApplication(String applicationId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      await _client
          .from('adoption_applications')
          .update({'status': 'withdrawn'})
          .eq('id', applicationId)
          .eq('applicant_id', user.id);
      return true;
    } catch (e) {
      debugPrint('Error withdrawing application: $e');
      return false;
    }
  }
}
