import 'config/supabase_config.dart';

/// Returns a loadable GLB URL for the model assigned to this pet.
/// Supabase may store either a public URL or a path within pet-models.
String? resolvePetModelUrl(Object? value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return null;

  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.path.toLowerCase().endsWith('.glb')) return null;
  if (uri.hasScheme) {
    return uri.scheme == 'https' && uri.host.isNotEmpty ? raw : null;
  }
  if (raw.startsWith('//') ||
      raw.startsWith('/') ||
      uri.hasQuery ||
      uri.hasFragment) {
    return null;
  }

  final path = raw.startsWith('pet-models/')
      ? raw.substring('pet-models/'.length)
      : raw;
  if (path.isEmpty ||
      path.split('/').any((part) => part == '..' || part == '.')) {
    return null;
  }
  final encoded = path.split('/').map(Uri.encodeComponent).join('/');
  return '${SupabaseConfig.url}/storage/v1/object/public/pet-models/$encoded';
}
