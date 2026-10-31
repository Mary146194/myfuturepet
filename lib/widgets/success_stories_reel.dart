import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'story_video_source.dart';

/// Builds the player for a story video; null shows the poster only.
typedef StoryVideoBuilder = VideoPlayerController? Function(Uri url);

/// Full-screen, vertically swiped "Success Stories" feed of alumni pets.
///
/// Stateless about likes/comments: the Community Feed owns those counts so
/// the reel and the classic list never disagree.
class SuccessStoriesReel extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  final bool Function(String postId) isLiked;
  final bool Function(String postId) isLikePending;
  final int Function(String postId) likeCount;
  final int Function(String postId) commentCount;
  final void Function(String postId) onLike;
  final void Function(String postId, String author) onComment;
  final void Function(String author, String content) onShare;
  final String Function(int count) formatCount;
  final String Function(dynamic timestamp) timeAgo;

  /// Shown on the empty state: adopters can post the first story.
  final VoidCallback? onShareStory;

  /// Override in tests (no video platform there). Defaults to streaming.
  final StoryVideoBuilder? videoBuilder;

  const SuccessStoriesReel({
    super.key,
    required this.posts,
    required this.isLiked,
    required this.isLikePending,
    required this.likeCount,
    required this.commentCount,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.formatCount,
    required this.timeAgo,
    this.onShareStory,
    this.videoBuilder,
  });

  @override
  State<SuccessStoriesReel> createState() => _SuccessStoriesReelState();
}

class _SuccessStoriesReelState extends State<SuccessStoriesReel> {
  final PageController _pages = PageController();
  int _index = 0;

  /// Reels start muted; the choice carries from story to story.
  bool _muted = true;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) return _buildEmpty(context);
    final count = widget.posts.length;
    if (_index >= count) _index = count - 1;

    return Stack(
      children: [
        PageView.builder(
          controller: _pages,
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(
            parent: PageScrollPhysics(),
          ),
          itemCount: count,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: _StoryPage(
              key: ValueKey('story-${widget.posts[i]['id']}'),
              post: widget.posts[i],
              parent: widget,
              active: i == _index,
              muted: _muted,
              onToggleMute: () => setState(() => _muted = !_muted),
            ),
          ),
        ),
        // Story counter, like a reel position hint.
        if (count > 1)
          Positioned(
            right: 24,
            top: 18,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_index + 1}/$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.14),
        Icon(
          Icons.auto_stories_outlined,
          size: 56,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 12),
        Text(
          'No success stories yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'When JALRG pets go home, their new families share updates here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        if (widget.onShareStory != null) ...[
          const SizedBox(height: 18),
          Center(
            child: FilledButton.icon(
              onPressed: widget.onShareStory,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFA94327),
              ),
              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: const Text('Share the first story'),
            ),
          ),
        ],
      ],
    );
  }
}

class _StoryPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final SuccessStoriesReel parent;

  /// Only the story on screen plays its video.
  final bool active;
  final bool muted;
  final VoidCallback onToggleMute;

  const _StoryPage({
    super.key,
    required this.post,
    required this.parent,
    required this.active,
    required this.muted,
    required this.onToggleMute,
  });

  @override
  State<_StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<_StoryPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _heart = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  bool _expanded = false;

  VideoPlayerController? _video;
  bool _videoReady = false;
  bool _videoFailed = false;

  /// The viewer tapped to pause; stays paused until tapped again.
  bool _userPaused = false;

  /// False when the Community tab is hidden or the app is in background.
  bool _visible = true;
  bool _foreground = true;

  String get _videoUrl => widget.post['video_url']?.toString().trim() ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadVideo();
  }

  /// Retrying on a native surface after the default renderer failed.
  bool _useFallback = false;

  void _loadVideo() {
    final uri = Uri.tryParse(_videoUrl);
    if (_videoUrl.isEmpty || uri == null) return;
    final builder = widget.parent.videoBuilder;
    final controller = builder != null
        ? builder(uri)
        : streamStoryVideo(uri, fallback: _useFallback);
    if (controller == null) return;
    _video = controller;
    _initVideo(controller);
  }

  /// Network hiccups are common on mobile data; let the viewer try again.
  void _retryVideo() {
    final old = _video;
    setState(() {
      _video = null;
      _videoReady = false;
      _videoFailed = false;
    });
    old?.dispose();
    _loadVideo();
  }

  Future<void> _initVideo(VideoPlayerController controller) async {
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(widget.muted ? 0 : 1);
      if (!mounted) return;
      setState(() => _videoReady = true);
      _syncPlayback();
    } catch (e) {
      debugPrint('Story video failed to load ($_videoUrl): $e');
      if (!mounted || !identical(controller, _video)) return;
      if (widget.parent.videoBuilder == null &&
          !_useFallback &&
          storyVideoHasFallback) {
        debugPrint('Retrying story video on a native surface.');
        _useFallback = true;
        _video = null;
        controller.dispose();
        _loadVideo();
        return;
      }
      setState(() => _videoFailed = true);
    }
  }

  // Hidden tabs (IndexedStack) turn tickers off; treat that as off-screen.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible != _visible) {
      _visible = visible;
      _syncPlayback();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncPlayback();
  }

  @override
  void didUpdateWidget(_StoryPage old) {
    super.didUpdateWidget(old);
    if (old.muted != widget.muted && _videoReady) {
      _video?.setVolume(widget.muted ? 0 : 1);
    }
    if (old.active != widget.active) {
      // Swiping back to a story starts it over, like other reel apps.
      if (widget.active && _videoReady) _video?.seekTo(Duration.zero);
      _userPaused = false;
      _syncPlayback();
    }
  }

  void _syncPlayback() {
    final video = _video;
    if (video == null || !_videoReady) return;
    final shouldPlay = widget.active && _visible && _foreground && !_userPaused;
    if (shouldPlay && !video.value.isPlaying) {
      video.play();
    } else if (!shouldPlay && video.value.isPlaying) {
      video.pause();
    }
  }

  void _togglePause() {
    if (_video == null || !_videoReady) return;
    setState(() => _userPaused = !_userPaused);
    _syncPlayback();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _video?.dispose();
    _heart.dispose();
    super.dispose();
  }

  String get _id => widget.post['id']?.toString() ?? '';

  void _doubleTapLike() {
    _heart.forward(from: 0);
    final reel = widget.parent;
    // Double-tap only ever likes, like other reel apps; never unlikes.
    if (!reel.isLiked(_id) && !reel.isLikePending(_id)) reel.onLike(_id);
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.parent;
    final post = widget.post;
    final pet = post['pet'] as Map<String, dynamic>?;
    final author = post['author'] as Map<String, dynamic>?;
    final shelter = post['shelter'] as Map<String, dynamic>?;
    final content = post['content']?.toString() ?? '';

    final authorName =
        (author?['full_name']?.toString().trim() ?? '').isNotEmpty
        ? author!['full_name'].toString().trim()
        : shelter?['name']?.toString() ?? 'JALRG family';
    final authorAvatar =
        author?['avatar_url']?.toString() ?? shelter?['logo_url']?.toString();
    final petName = pet?['name']?.toString();
    final isAlumni =
        pet != null && pet['status']?.toString().toLowerCase() == 'adopted';
    final postImage = post['image_url']?.toString().trim() ?? '';
    final image = postImage.isNotEmpty
        ? postImage
        : pet?['image_url']?.toString().trim() ?? '';

    final liked = reel.isLiked(_id);
    final pending = reel.isLikePending(_id);
    final video = _video;
    final hasVideo = _videoUrl.isNotEmpty && !_videoFailed;

    return Semantics(
      container: true,
      label:
          'Success story by $authorName'
          '${petName == null ? '' : ' about $petName'}. $content',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background photo (also the video's poster while it loads)
            if (image.isNotEmpty)
              Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              )
            else
              _fallback(),

            // Native-surface fallback ignores Flutter's scaling, so show the
            // whole frame at its true shape instead of stretching it.
            if (video != null && _videoReady && _useFallback)
              ColoredBox(
                color: Colors.black,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: video.value.aspectRatio,
                    child: VideoPlayer(video),
                  ),
                ),
              )
            // Video, cover-cropped to the card like a reel
            else if (video != null && _videoReady)
              FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: video.value.size.width,
                  height: video.value.size.height,
                  child: VideoPlayer(video),
                ),
              ),
            if (hasVideo && !_videoReady && video != null)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        color: Colors.white70,
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Loading video...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(blurRadius: 6)],
                      ),
                    ),
                  ],
                ),
              ),
            if (hasVideo && _userPaused)
              const Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white70,
                  size: 84,
                  semanticLabel: 'Paused. Tap to play',
                ),
              ),

            // Legibility gradient
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.18, 0.55, 1],
                  colors: [
                    Color(0x66000000),
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),

            // Tap / double-tap layer under the badges, caption and rail, so
            // those buttons respond instantly instead of waiting out the
            // double-tap window.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: hasVideo ? _togglePause : null,
                onDoubleTap: _doubleTapLike,
              ),
            ),

            if (_videoFailed)
              Center(
                child: FilledButton.icon(
                  key: ValueKey('reel-retry-$_id'),
                  onPressed: _retryVideo,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("Video couldn't load · Retry"),
                ),
              ),

            // Alumni badge
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isAlumni
                      ? const Color(0xFF008F82)
                      : const Color(0xFFA94327),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAlumni ? Icons.school_rounded : Icons.favorite_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isAlumni
                          ? 'JALRG Alumni${petName == null ? '' : ' · $petName'}'
                          : 'Success Story',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (hasVideo)
              Positioned(
                left: 14,
                top: 50,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.videocam_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
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

            if (video != null && _videoReady)
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

            // Double-tap heart burst
            Center(
              child: AnimatedBuilder(
                animation: _heart,
                builder: (context, _) {
                  if (!_heart.isAnimating) return const SizedBox.shrink();
                  final t = _heart.value;
                  final scale = t < 0.3
                      ? Curves.easeOutBack.transform(t / 0.3) * 1.15
                      : 1.15 - 0.15 * ((t - 0.3) / 0.7);
                  return Opacity(
                    opacity: t < 0.7 ? 1 : (1 - (t - 0.7) / 0.3),
                    child: Transform.scale(
                      scale: scale,
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 110,
                        shadows: [
                          Shadow(blurRadius: 24, color: Colors.black38),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Caption + author
            Positioned(
              left: 16,
              right: 78,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 34,
                          height: 34,
                          child: authorAvatar != null && authorAvatar.isNotEmpty
                              ? Image.network(
                                  authorAvatar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _initial(authorName),
                                )
                              : _initial(authorName),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '  ·  ${reel.timeAgo(post['created_at'])}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  if (petName != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      isAlumni
                          ? '🐾 Adopted $petName from JALRG'
                          : '🐾 with $petName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.topLeft,
                      child: Text(
                        content,
                        maxLines: _expanded ? 12 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          height: 1.4,
                          shadows: [
                            Shadow(blurRadius: 6, color: Colors.black45),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action rail
            Positioned(
              right: 10,
              bottom: 22,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasVideo) ...[
                    _railButton(
                      key: ValueKey('reel-mute-$_id'),
                      icon: widget.muted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                      label: widget.muted ? 'Muted' : 'Sound',
                      semantics: widget.muted ? 'Unmute' : 'Mute',
                      onTap: widget.onToggleMute,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _railButton(
                    key: ValueKey('reel-like-$_id'),
                    icon: liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: liked ? const Color(0xFFFF4D67) : Colors.white,
                    label: reel.formatCount(reel.likeCount(_id)),
                    semantics: liked ? 'Unlike' : 'Like',
                    onTap: pending ? null : () => reel.onLike(_id),
                  ),
                  const SizedBox(height: 16),
                  _railButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    label: reel.formatCount(reel.commentCount(_id)),
                    semantics: 'Comments',
                    onTap: () => reel.onComment(_id, authorName),
                  ),
                  const SizedBox(height: 16),
                  _railButton(
                    icon: Icons.share_outlined,
                    color: Colors.white,
                    label: 'Share',
                    semantics: 'Share',
                    onTap: () => reel.onShare(authorName, content),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _railButton({
    Key? key,
    required IconData icon,
    required Color color,
    required String label,
    required String semantics,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      label: semantics,
      child: GestureDetector(
        key: key,
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF008F82), Color(0xFFA94327)],
      ),
    ),
    child: Center(
      child: Icon(Icons.pets_rounded, size: 96, color: Colors.white24),
    ),
  );

  Widget _initial(String name) => ColoredBox(
    color: const Color(0xFFFFECD9),
    child: Center(
      child: Text(
        name.isEmpty ? 'J' : name[0].toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFFA94327),
        ),
      ),
    ),
  );
}
