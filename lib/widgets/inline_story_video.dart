import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'post_image.dart' show PostMediaAspect;
import 'story_video_source.dart';
import 'success_stories_reel.dart' show StoryVideoBuilder;

/// A story video inside a regular feed card. Plays muted and looping while
/// most of it is on screen (like other social feeds), pauses when scrolled
/// away, when the tab is hidden, or when the app is in the background.
/// Tap toggles sound. The poster shows while loading or if the video fails.
///
/// The card takes the video's own shape (within the feed's 4:5 to 1.91:1
/// range) and the whole frame is shown, so it is never stretched or cut.
class InlineStoryVideo extends StatefulWidget {
  final String url;
  final String? posterUrl;
  final Color background;

  /// Override in tests (no video platform there). Defaults to streaming.
  final StoryVideoBuilder? videoBuilder;

  const InlineStoryVideo({
    super.key,
    required this.url,
    this.posterUrl,
    this.background = const Color(0xFF0F172A),
    this.videoBuilder,
  });

  /// How much of the video must be visible before it starts playing.
  static const playThreshold = 0.6;

  @override
  State<InlineStoryVideo> createState() => _InlineStoryVideoState();
}

class _InlineStoryVideoState extends State<InlineStoryVideo>
    with WidgetsBindingObserver {
  VideoPlayerController? _video;
  bool _ready = false;
  bool _failed = false;
  bool _muted = true;

  bool _onScreen = false;
  bool _tabVisible = true;
  bool _foreground = true;
  ScrollPosition? _position;

  /// Retrying on a native surface after the default renderer failed.
  bool _useFallback = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_checkVisibility);
      _position = position?..addListener(_checkVisibility);
    }
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible != _tabVisible) {
      _tabVisible = visible;
      _sync();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
  }

  @override
  void didUpdateWidget(InlineStoryVideo old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _disposeVideo();
      _ready = false;
      _failed = false;
      _sync();
    }
  }

  void _checkVisibility() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final scrollable = Scrollable.maybeOf(context);
    final viewport = scrollable?.context.findRenderObject() as RenderBox?;
    double fraction;
    if (viewport == null || !viewport.attached || !viewport.hasSize) {
      fraction = 1;
    } else {
      final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
      final bottom = top + box.size.height;
      final visible =
          (bottom.clamp(0.0, viewport.size.height) -
                  top.clamp(0.0, viewport.size.height))
              .toDouble();
      fraction = box.size.height <= 0 ? 0 : visible / box.size.height;
    }
    final onScreen = fraction >= InlineStoryVideo.playThreshold;
    if (onScreen != _onScreen) {
      _onScreen = onScreen;
      _sync();
    }
  }

  bool get _shouldPlay => _onScreen && _tabVisible && _foreground;

  void _sync() {
    // Only start downloading once the viewer actually reaches the video.
    if (_shouldPlay && _video == null && !_failed) _load();
    final video = _video;
    if (video == null || !_ready) return;
    if (_shouldPlay && !video.value.isPlaying) {
      video.play();
    } else if (!_shouldPlay && video.value.isPlaying) {
      video.pause();
    }
  }

  void _load() {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) return;
    final builder = widget.videoBuilder;
    final controller = builder != null
        ? builder(uri)
        : streamStoryVideo(uri, fallback: _useFallback);
    if (controller == null) return;
    _video = controller;
    _init(controller);
  }

  Future<void> _init(VideoPlayerController controller) async {
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(_muted ? 0 : 1);
      if (!mounted || !identical(controller, _video)) return;
      setState(() => _ready = true);
      _sync();
    } catch (e) {
      debugPrint('Feed video failed to load (${widget.url}): $e');
      if (!mounted || !identical(controller, _video)) return;
      if (widget.videoBuilder == null &&
          !_useFallback &&
          storyVideoHasFallback) {
        debugPrint('Retrying feed video on a native surface.');
        _useFallback = true;
        _disposeVideo();
        _load();
        return;
      }
      setState(() => _failed = true);
    }
  }

  void _retry() {
    setState(() {
      _disposeVideo();
      _ready = false;
      _failed = false;
    });
    _sync();
  }

  void _toggleMute() {
    final video = _video;
    if (video == null || !_ready) return;
    setState(() => _muted = !_muted);
    video.setVolume(_muted ? 0 : 1);
  }

  void _disposeVideo() {
    _video?.dispose();
    _video = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _position?.removeListener(_checkVisibility);
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = _video;
    final poster = widget.posterUrl?.trim() ?? '';
    final ready = video != null && _ready;
    // Story clips are usually portrait, so reserve that until the real
    // shape is known.
    final aspect = ready
        ? PostMediaAspect.clamp(video.value.aspectRatio)
        : PostMediaAspect.tallest;
    return AspectRatio(
      aspectRatio: aspect,
      child: ColoredBox(
        color: ready ? Colors.black : widget.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (poster.isNotEmpty && !ready)
              Image.network(
                poster,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            // The whole frame at its true shape. (Scaling the player with a
            // FittedBox stretched it on phones that use the native-surface
            // fallback, which ignores Flutter's scaling.)
            if (ready)
              Center(
                child: AspectRatio(
                  aspectRatio: video.value.aspectRatio,
                  child: VideoPlayer(video),
                ),
              ),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleMute,
              ),
            ),
            if (video != null && !_ready && !_failed)
              const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.white70,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            if (_failed)
              Center(
                child: FilledButton.icon(
                  onPressed: _retry,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("Video couldn't load · Retry"),
                ),
              ),
            Positioned(
              left: 10,
              top: 10,
              child: _chip(
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_rounded, color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text(
                      'Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (video != null && _ready)
              Positioned(
                right: 10,
                bottom: 12,
                child: Semantics(
                  button: true,
                  label: _muted ? 'Unmute' : 'Mute',
                  child: GestureDetector(
                    key: const ValueKey('inline-video-mute'),
                    onTap: _toggleMute,
                    child: _chip(
                      Icon(
                        _muted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ),
              ),
            if (video != null && _ready)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VideoProgressIndicator(
                  video,
                  allowScrubbing: false,
                  padding: EdgeInsets.zero,
                  colors: const VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    Widget child, {
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}
