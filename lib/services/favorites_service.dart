import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final ValueNotifier<Set<String>> favoritesNotifier = ValueNotifier<Set<String>>({});
  bool _isInitialized = false;

  String get _storageKey {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? 'guest';
    return 'user_favorites_$userId';
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(_storageKey) ?? [];
      favoritesNotifier.value = savedList.toSet();
      _isInitialized = true;
    } catch (_) {
      favoritesNotifier.value = {};
    }
    await _mergeFromSupabase();
  }

  /// Saved pets follow the account across devices: add the ones saved
  /// elsewhere, and upload any saved here before the table existed.
  Future<void> _mergeFromSupabase() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;
      final rows = await client
          .from('user_favorites')
          .select('pet_id')
          .eq('user_id', user.id);
      final remote = {for (final r in rows) r['pet_id'].toString()};
      final local = favoritesNotifier.value;
      // shortcut: a pet unsaved on another phone comes back if this phone
      // still had it saved; track removals if that starts to matter.
      for (final petId in local.difference(remote)) {
        _syncToSupabase(petId, true);
      }
      final merged = {...local, ...remote};
      favoritesNotifier.value = merged;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, merged.toList());
    } catch (e) {
      debugPrint('Saved pets kept on this device only: $e');
    }
  }

  bool isFavorite(String petId) {
    return favoritesNotifier.value.contains(petId);
  }

  Future<void> addFavorite(String petId) async {
    await init();
    if (favoritesNotifier.value.contains(petId)) return;

    final current = Set<String>.from(favoritesNotifier.value);
    current.add(petId);
    favoritesNotifier.value = current;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, current.toList());
    } catch (e) {
      debugPrint('Failed to save favorite locally: $e');
    }

    _syncToSupabase(petId, true);
  }

  Future<void> removeFavorite(String petId) async {
    await init();
    if (!favoritesNotifier.value.contains(petId)) return;

    final current = Set<String>.from(favoritesNotifier.value);
    current.remove(petId);
    favoritesNotifier.value = current;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, current.toList());
    } catch (e) {
      debugPrint('Failed to remove favorite locally: $e');
    }

    _syncToSupabase(petId, false);
  }

  Future<bool> toggleFavorite(String petId) async {
    await init();
    if (isFavorite(petId)) {
      await removeFavorite(petId);
      return false;
    } else {
      await addFavorite(petId);
      return true;
    }
  }

  void _syncToSupabase(String petId, bool isFavorite) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      if (isFavorite) {
        await Supabase.instance.client.from('user_favorites').upsert({
          'user_id': user.id,
          'pet_id': petId,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        await Supabase.instance.client
            .from('user_favorites')
            .delete()
            .match({'user_id': user.id, 'pet_id': petId});
      }
    } catch (_) {
      // Gracefully ignore if user_favorites table does not exist or network is offline
    }
  }

  List<String> getFavoriteIds() {
    return favoritesNotifier.value.toList();
  }

  List<Map<String, dynamic>> filterFavoritePets(List<Map<String, dynamic>> allPets) {
    final favIds = favoritesNotifier.value;
    return allPets.where((pet) => favIds.contains(pet['id']?.toString())).toList();
  }
}
