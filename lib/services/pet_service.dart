import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetService {
  final SupabaseClient _client;

  PetService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Fetch adoptable pets with optional filters (category, search, breed, gender)
  Future<List<Map<String, dynamic>>> fetchPets({
    String? category,
    String? searchQuery,
    String? breed,
    String? gender,
    String? status,
    bool throwOnError = false,
  }) async {
    try {
      var query = _client
          .from('pets')
          .select('*, shelters(id, name, address, contact_number)');

      // Category filter (Dogs / Cats)
      if (category != null && category != 'All') {
        if (category.toLowerCase() == 'dogs' ||
            category.toLowerCase() == 'dog') {
          query = query.eq('type', 'dog');
        } else if (category.toLowerCase() == 'cats' ||
            category.toLowerCase() == 'cat') {
          query = query.eq('type', 'cat');
        }
      }

      // Status filter (default to showing available first, or specific status)
      if (status != null && status != 'All') {
        query = query.eq('status', status.toLowerCase());
      }

      // Search query (pet name or breed)
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = searchQuery.trim();
        query = query.or('name.ilike.%$term%,breed.ilike.%$term%');
      }

      // Breed filter
      if (breed != null && breed != 'All Breeds' && breed.isNotEmpty) {
        query = query.eq('breed', breed);
      }

      // Gender filter
      if (gender != null && gender != 'Any Gender' && gender.isNotEmpty) {
        query = query.eq('gender', gender.toLowerCase());
      }

      final response = await query.order('created_at', ascending: false);
      final List<dynamic> data = response as List<dynamic>;

      return data
          .map((item) => _normalizePetData(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching pets: $e');
      if (throwOnError) rethrow;
      return [];
    }
  }

  /// Fetch featured pets for the Home screen carousel
  Future<List<Map<String, dynamic>>> fetchFeaturedPets({int limit = 5}) async {
    try {
      final response = await _client
          .from('pets')
          .select('*, shelters(id, name, address, contact_number)')
          .eq('status', 'available')
          .order('created_at', ascending: false)
          .limit(limit);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((item) => _normalizePetData(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching featured pets: $e');
      return [];
    }
  }

  /// Fetch recommended pets for the Home grid
  Future<List<Map<String, dynamic>>> fetchRecommendedPets({
    int limit = 6,
  }) async {
    try {
      final response = await _client
          .from('pets')
          .select('*, shelters(id, name, address, contact_number)')
          .eq('status', 'available')
          .order('created_at', ascending: false)
          .limit(limit);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((item) => _normalizePetData(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching recommended pets: $e');
      return [];
    }
  }

  /// Single pet details by ID
  Future<Map<String, dynamic>?> fetchPetById(
    String id, {
    bool throwOnError = false,
  }) async {
    try {
      final response = await _client
          .from('pets')
          .select('*, shelters(id, name, address, contact_number)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return _normalizePetData(response);
    } catch (e) {
      debugPrint('Error fetching pet by ID: $e');
      if (throwOnError) rethrow;
      return null;
    }
  }

  /// Helper to normalize pet attributes for consistent UI consumption
  Map<String, dynamic> _normalizePetData(Map<String, dynamic> raw) {
    final shelter = raw['shelters'] as Map<String, dynamic>?;
    final type = (raw['type'] ?? 'dog').toString().toLowerCase();

    // Prefer the gallery when present; older schemas use image_url only.
    final photos = raw['photo_urls'];
    final imageUrls = (photos is List ? photos : const [])
        .whereType<String>()
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
    final legacyImage = raw['image_url']?.toString().trim() ?? '';
    if (imageUrls.isEmpty && legacyImage.isNotEmpty) {
      imageUrls.add(legacyImage);
    }
    final imageUrl = imageUrls.isEmpty ? '' : imageUrls.first;
    // Calculate age string from birthdate
    String ageStr = raw['age']?.toString() ?? 'Age unknown';
    if (raw['birthdate'] != null) {
      try {
        final bday = DateTime.parse(raw['birthdate'].toString());
        final now = DateTime.now();
        final diffDays = now.difference(bday).inDays;
        final years = (diffDays / 365.25).floor();
        final months = ((diffDays % 365.25) / 30.4).floor();

        if (years >= 1) {
          ageStr = '$years ${years == 1 ? 'yr' : 'yrs'}';
        } else if (months >= 1) {
          ageStr = '$months ${months == 1 ? 'mo' : 'mos'}';
        } else {
          ageStr = '$diffDays days';
        }
      } catch (_) {}
    }

    // Only what the shelter wrote; the details screen says when it is missing.
    final temperamentStr = raw['temperament']?.toString() ?? '';
    final personalityList = temperamentStr
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final vacStatus = raw['vaccination_status']?.toString() ?? 'Not recorded';
    final isVaccinated = const {
      'fully_vaccinated',
      'fully vaccinated',
      'vaccinated',
      'up to date',
      'up_to_date',
    }.contains(vacStatus.trim().toLowerCase());
    return {
      'id': raw['id']?.toString() ?? '',
      'name': raw['name']?.toString() ?? 'Unnamed Pet',
      'type': type,
      'category': type == 'dog' ? 'Dogs' : 'Cats',
      'breed': raw['breed']?.toString() ?? (type == 'dog' ? 'Aspin' : 'Puspin'),
      'gender': (raw['gender'] != null)
          ? raw['gender'].toString().substring(0, 1).toUpperCase() +
                raw['gender'].toString().substring(1)
          : 'Unknown',
      'age': ageStr,
      'birthdate': raw['birthdate']?.toString(),
      'status': (raw['status'] != null)
          ? raw['status'].toString().substring(0, 1).toUpperCase() +
                raw['status'].toString().substring(1)
          : 'Available',
      'raw_status': raw['status']?.toString() ?? 'available',
      'size': raw['size']?.toString() ?? 'Medium',
      'weight': raw['weight_kg'] != null ? '${raw['weight_kg']} kg' : 'Not recorded',
      'color': raw['color']?.toString() ?? 'Not recorded',
      'health_condition': raw['health_condition']?.toString() ?? 'Not recorded',
      'vaccination_status': vacStatus,
      'vaccinationStatus': vacStatus,
      'temperament': temperamentStr,
      'personality': personalityList,
      'personalityShort': personalityList.join(', '),
      'behavior': personalityList.isNotEmpty ? personalityList.first : 'Active',
      'energy': personalityList.isNotEmpty ? personalityList.first : 'Active',
      'vaccinated': isVaccinated,
      'kidFriendly':
          temperamentStr.toLowerCase().contains('kid') ||
          temperamentStr.toLowerCase().contains('gentle') ||
          temperamentStr.toLowerCase().contains('friendly'),
      'description':
          raw['description']?.toString() ?? 'Rescue background not provided.',
      'about':
          raw['description']?.toString() ?? 'Rescue background not provided.',
      'adoption_requirements':
          raw['adoption_requirements']?.toString() ??
          'Valid ID, screening questionnaire, home inspection agreement.',
      'image': imageUrl,
      'image_url': imageUrl,
      'images': imageUrls,
      'model_url': raw['model_url']?.toString(),
      'shelter_id': raw['shelter_id']?.toString(),
      'shelter': shelter?['name']?.toString() ?? 'Shelter not provided',
      'shelterPhone': shelter?['contact_number']?.toString() ?? '',
      'shelterAddress':
          shelter?['address']?.toString() ?? 'Address not provided',
      'location': shelter?['address']?.toString() ?? 'Address not provided',
      'deworming': raw['deworming']?.toString() ?? 'Not recorded',
      'rabies': raw['rabies']?.toString() ?? 'Not recorded',
      'likes': raw['likes'] ?? 0,
    };
  }
}
