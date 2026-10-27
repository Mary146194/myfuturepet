/// The model's animation clip for a behaviour button, matched by name in any
/// case: 'Sit' -> "sit", 'Wag Tail' -> "wag", anything else -> "idle".
/// Null when the model has no such clip (e.g. Scar has no idle, so he stands
/// still; the older dog models have no wag).
String? petClipFor(String action, List<String> clips) {
  final want = switch (action) {
    'Sit' => 'sit',
    'Wag Tail' => 'wag',
    _ => 'idle',
  };
  for (final clip in clips) {
    if (clip.toLowerCase() == want) return clip;
  }
  return null;
}
