import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// Streams a Success Story video.
///
/// The default texture view fails on some MediaTek phones (e.g. OPPO
/// CPH1823): the hardware decoder cannot allocate buffers for full-HD
/// portrait clips. With [fallback], the video renders to a native Android
/// surface (platform view) instead, which those decoders handle.
VideoPlayerController streamStoryVideo(Uri url, {bool fallback = false}) =>
    VideoPlayerController.networkUrl(
      url,
      viewType: fallback
          ? VideoViewType.platformView
          : VideoViewType.textureView,
    );

/// Whether a failed load is worth retrying with [streamStoryVideo]'s
/// fallback. Platform views are only offered on Android.
bool get storyVideoHasFallback =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
