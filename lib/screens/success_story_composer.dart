import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../adoption_journey.dart';
import '../services/adoption_journey_service.dart';
import '../services/community_service.dart';
import '../services/theme_service.dart';
import '../services/video_compression_service.dart';

/// The alumni portal: adopters whose journey reached "Welcome Home!" post
/// updates about the pet they took home. Everyone else sees why it's locked.
class SuccessStoryComposer extends StatefulWidget {
  final List<AdoptionJourney> alumni;
  final AdoptionJourney? initialPet;
  final CommunityService? communityService;

  const SuccessStoryComposer({
    super.key,
    required this.alumni,
    this.initialPet,
    this.communityService,
  });

  /// Pets this adopter has successfully taken home.
  static List<AdoptionJourney> myAlumni() => AdoptionJourneyService()
      .journeys
      .value
      .where((j) => j.isComplete && j.petId.isNotEmpty)
      .toList();

  /// Opens the portal; resolves to true once a story was published.
  static Future<bool> open(
    BuildContext context, {
    AdoptionJourney? initialPet,
    CommunityService? communityService,
  }) async {
    final posted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SuccessStoryComposer(
          alumni: myAlumni(),
          initialPet: initialPet,
          communityService: communityService,
        ),
      ),
    );
    return posted ?? false;
  }

  @override
  State<SuccessStoryComposer> createState() => _SuccessStoryComposerState();
}

class _SuccessStoryComposerState extends State<SuccessStoryComposer> {
  static const Color primaryColor = Color(0xFFA94327);
  static const Color tealColor = Color(0xFF008F82);

  final TextEditingController _caption = TextEditingController();
  late final CommunityService _service =
      widget.communityService ?? CommunityService();
  AdoptionJourney? _pet;
  Uint8List? _photo;

  /// A picked video replaces the photo; the pet's portrait becomes its poster.
  XFile? _video;
  Uint8List? _videoBytes;
  VideoPlayerController? _preview;
  PreparedVideo? _videoInfo;
  bool _submitting = false;

  final VideoCompressionService _compressor = VideoCompressionService();

  /// Progress (0-1) while a picked video is being shrunk; null when idle.
  double? _compressing;
  bool _usedCompressor = false;

  bool get _busy => _submitting || _compressing != null;

  /// Keep story videos short, like reels.
  static const maxVideoLength = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
    _pet =
        widget.alumni
            .where((j) => j.applicationId == widget.initialPet?.applicationId)
            .firstOrNull ??
        widget.alumni.firstOrNull;
  }

  @override
  void dispose() {
    _caption.dispose();
    _preview?.dispose();
    if (_compressing != null) _compressor.cancel();
    // Compressed copies are already read into memory or uploaded.
    if (_usedCompressor) _compressor.clearCache();
    super.dispose();
  }

  void _clearVideo() {
    _preview?.dispose();
    _preview = null;
    _video = null;
    _videoBytes = null;
    _videoInfo = null;
  }

  void _removeMedia() {
    if (_compressing != null) _compressor.cancel();
    setState(() {
      _clearVideo();
      _compressing = null;
      _photo = null;
    });
  }

  static String _mb(int bytes) =>
      '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  Future<void> _pickVideo() async {
    try {
      final picked = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxVideoLength,
      );
      if (picked == null || !mounted) return;

      // Shrink it on the phone first, so uploads are quick on mobile data.
      final compressing = _compressor.supported;
      if (compressing) {
        _usedCompressor = true;
        setState(() {
          _clearVideo();
          _photo = null;
          _compressing = 0;
        });
      }
      final prepared = await _compressor.prepare(
        picked,
        onProgress: (p) {
          if (mounted && _compressing != null) {
            setState(() => _compressing = p);
          }
        },
      );
      // Closed, or the viewer tapped Remove while it was compressing.
      if (!mounted || (compressing && _compressing == null)) return;
      if (prepared.bytes > CommunityService.maxVideoBytes) {
        setState(() => _compressing = null);
        _snack(
          prepared.wasCompressed
              ? 'Even after compressing, that video is over 50 MB. '
                    'Please pick a shorter clip.'
              : 'That video is over 50 MB. Please pick a shorter clip.',
        );
        return;
      }
      final file = prepared.file;
      final bytes = await file.readAsBytes();
      final controller = kIsWeb
          ? VideoPlayerController.networkUrl(Uri.parse(file.path))
          : VideoPlayerController.file(File(file.path));
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _clearVideo();
        _photo = null;
        _compressing = null;
        _video = file;
        _videoBytes = bytes;
        _videoInfo = prepared;
        _preview = controller;
      });
      try {
        await controller.initialize();
        await controller.setLooping(true);
        await controller.setVolume(0);
        await controller.play();
      } catch (e) {
        debugPrint('Video preview unavailable: $e');
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() => _compressing = null);
      _snack('Could not open your videos. Please try again.');
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1440,
        maxHeight: 1440,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (mounted) {
        setState(() {
          _clearVideo();
          _photo = bytes;
        });
      }
    } catch (_) {
      _snack('Could not open your photos. Please try again.');
    }
  }

  Future<void> _publish() async {
    final pet = _pet;
    final text = _caption.text.trim();
    if (pet == null || _compressing != null) return;
    if (text.isEmpty) {
      _snack('Tell everyone how ${pet.petName} is doing.');
      return;
    }
    setState(() => _submitting = true);
    try {
      String? imageUrl;
      String? videoUrl;
      if (_videoBytes != null) {
        try {
          videoUrl = await _service.uploadStoryVideo(
            _videoBytes!,
            fileName: _video?.name ?? 'story.mp4',
          );
        } catch (e) {
          debugPrint('Story video upload failed: $e');
          final reason = e.toString();
          throw Exception(
            reason.contains('too-large')
                ? 'video-too-large'
                // The story-videos bucket hasn't been created yet.
                : reason.contains('Bucket not found')
                ? 'video-unsupported'
                : 'video',
          );
        }
      }
      if (_photo != null) {
        try {
          imageUrl = await _service.uploadStoryPhoto(_photo!);
        } catch (e) {
          debugPrint('Story photo upload failed: $e');
          final reason = e.toString();
          // Storage policy for stories/ hasn't been added yet.
          throw Exception(
            reason.contains('row-level security') || reason.contains('403')
                ? 'photo-blocked'
                : 'photo',
          );
        }
      }
      await _service.createPost(
        content: text,
        category: 'Success Stories',
        petId: pet.petId,
        videoUrl: videoUrl,
        // No photo: the pet's shelter portrait still gives the reel a face
        // (and is the poster while a video loads).
        imageUrl: imageUrl ?? (pet.petImage.isEmpty ? null : pet.petImage),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final message = e.toString();
      _snack(
        message.contains('video-unsupported')
            ? 'Video stories are not switched on yet. Share a photo for now.'
            : message.contains('video-too-large')
            ? 'That video is over 50 MB. Please pick a shorter clip.'
            : message.contains('video')
            ? 'Could not upload your video. Check your connection and try again.'
            : message.contains('photo-blocked')
            ? 'Photo uploads for stories are not switched on yet. '
                  'Post without a photo to use the shelter picture.'
            : message.contains('photo')
            ? 'Could not upload your photo. Check your connection and try again.'
            // 42501: the alumni-only RLS policy refused the post.
            : message.contains('42501') ||
                  message.contains('row-level security')
            ? 'Only the adopter of ${pet.petName} can share this story. '
                  'If you just adopted, pull to refresh and try again.'
            : 'Unable to publish your story. Check your connection and sign-in, then try again.',
      );
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode(context);
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF6F8F9);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final text = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF062B35);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: text),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          'Share a Success Story',
          style: TextStyle(
            color: text,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: widget.alumni.isEmpty
          ? _buildLocked(text, sub)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(
                  'Which alumni pet is this about?',
                  style: TextStyle(
                    color: sub,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.alumni.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) =>
                        _buildPetChoice(widget.alumni[i], text),
                  ),
                ),
                const SizedBox(height: 18),
                _buildMediaPicker(card, border, sub),
                const SizedBox(height: 16),
                TextField(
                  controller: _caption,
                  maxLines: 4,
                  maxLength: 3000,
                  style: TextStyle(color: text),
                  decoration: InputDecoration(
                    hintText: _pet == null
                        ? 'Share an update...'
                        : "e.g. ${_pet!.petName}'s first day at the beach!",
                    hintStyle: TextStyle(color: sub),
                    filled: true,
                    fillColor: card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _publish,
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(
                      _submitting
                          ? 'Sharing...'
                          : _compressing != null
                          ? 'Preparing video...'
                          : 'Share Story',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPetChoice(AdoptionJourney j, Color text) {
    final selected = _pet?.applicationId == j.applicationId;
    return Semantics(
      selected: selected,
      button: true,
      label: j.petName,
      child: GestureDetector(
        onTap: () => setState(() => _pet = j),
        child: SizedBox(
          width: 68,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? tealColor : Colors.transparent,
                    width: 2.5,
                  ),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: j.petImage.isEmpty
                        ? _petPlaceholder()
                        : Image.network(
                            j.petImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _petPlaceholder(),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                j.petName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: text,
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _petPlaceholder() => Container(
    color: tealColor.withValues(alpha: 0.15),
    child: const Icon(Icons.pets_rounded, color: tealColor),
  );

  Widget _buildMediaPicker(Color card, Color border, Color sub) {
    final preview = _preview;
    final hasMedia = _photo != null || _video != null || _compressing != null;
    final info = _videoInfo;
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: !hasMedia
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.perm_media_outlined, size: 44, color: sub),
                  const SizedBox(height: 8),
                  Text(
                    'Add a photo or a short video',
                    style: TextStyle(
                      color: sub,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _pet == null
                        ? 'Optional'
                        : "Optional — we'll use ${_pet!.petName}'s shelter photo",
                    style: TextStyle(color: sub, fontSize: 11.5),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _pickPhoto,
                        icon: const Icon(Icons.photo_outlined, size: 18),
                        label: const Text('Photo'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _pickVideo,
                        icon: const Icon(Icons.videocam_outlined, size: 18),
                        label: const Text('Video'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _compressor.supported
                        ? 'Videos up to 60 seconds, compressed before upload'
                        : 'Videos up to 60 seconds, 50 MB',
                    style: TextStyle(color: sub, fontSize: 11),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  if (_photo != null)
                    Image.memory(_photo!, fit: BoxFit.cover)
                  else if (preview != null && preview.value.isInitialized)
                    FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: preview.value.size.width,
                        height: preview.value.size.height,
                        child: VideoPlayer(preview),
                      ),
                    )
                  else
                    const ColoredBox(
                      color: Colors.black,
                      child: Center(
                        child: Icon(
                          Icons.videocam_rounded,
                          color: Colors.white54,
                          size: 48,
                        ),
                      ),
                    ),
                  if (_compressing != null)
                    ColoredBox(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                value: _compressing! > 0 ? _compressing : null,
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Optimizing video... '
                              '${(_compressing! * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Smaller files upload faster on mobile data',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (info != null)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        key: const ValueKey('story-video-size'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          info.wasCompressed
                              ? '${_mb(info.originalBytes)} → ${_mb(info.bytes)}'
                              : _mb(info.bytes),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (_video != null)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.videocam_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Video',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: _submitting ? null : _removeMedia,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLocked(Color text, Color sub) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: tealColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: tealColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'For JALRG adopters',
              style: TextStyle(
                color: text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Success Stories come from families who adopted through the app. '
              'Once your adoption journey reaches "Welcome Home!", you can '
              'post updates about your pet here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: sub, fontSize: 13, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
