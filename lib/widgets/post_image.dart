import 'package:flutter/material.dart';

/// Shape rules for photos and videos in feed cards: show the media at its
/// own aspect ratio, but keep very tall or very wide ones within a sensible
/// range (4:5 portrait to 1.91:1 landscape, as on other social feeds).
class PostMediaAspect {
  const PostMediaAspect._();

  static const double tallest = 4 / 5;
  static const double widest = 1.91;

  /// Before the size is known, reserve a neutral 4:3 box.
  static const double fallback = 4 / 3;

  static double clamp(double? aspect) {
    if (aspect == null || !aspect.isFinite || aspect <= 0) return fallback;
    return aspect.clamp(tallest, widest).toDouble();
  }
}

/// A post photo shown at its natural shape: never stretched, and only
/// cropped a little if it is extremely tall or wide. Tap to open it full
/// screen and pinch to zoom.
class PostImage extends StatefulWidget {
  final String url;
  final Color background;

  const PostImage({
    super.key,
    required this.url,
    this.background = const Color(0xFFF1F5F9),
  });

  @override
  State<PostImage> createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  late NetworkImage _image = NetworkImage(widget.url);
  ImageStream? _stream;
  late final ImageStreamListener _listener = ImageStreamListener(
    _onImage,
    onError: (_, _) {},
  );
  double? _aspect;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(PostImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _image = NetworkImage(widget.url);
      _aspect = null;
      _resolve();
    }
  }

  /// Reads the photo's real width and height to size the card.
  void _resolve() {
    final stream = _image.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  void _onImage(ImageInfo info, bool _) {
    final aspect = info.image.width / info.image.height;
    if (mounted && aspect != _aspect) setState(() => _aspect = aspect);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  void _openFullScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, _, _) =>
            _FullScreenImage(image: _image, url: widget.url),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      button: true,
      label: 'Post photo. Tap to view full screen.',
      child: GestureDetector(
        onTap: _aspect == null ? null : _openFullScreen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: widget.background,
          child: AspectRatio(
            aspectRatio: PostMediaAspect.clamp(_aspect),
            child: Hero(
              tag: 'post-image-${widget.url}',
              child: Image(
                image: _image,
                fit: BoxFit.cover,
                width: double.infinity,
                filterQuality: FilterQuality.medium,
                frameBuilder: (context, child, frame, wasSync) =>
                    wasSync || frame != null
                    ? child
                    : const Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        ),
                      ),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Black full-screen viewer: the whole photo, pinch to zoom.
class _FullScreenImage extends StatelessWidget {
  final ImageProvider image;
  final String url;

  const _FullScreenImage({required this.image, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Hero(
                    tag: 'post-image-$url',
                    child: Image(
                      image: image,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                key: const ValueKey('post-image-close'),
                tooltip: 'Close',
                color: Colors.white,
                icon: const Icon(Icons.close_rounded, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
