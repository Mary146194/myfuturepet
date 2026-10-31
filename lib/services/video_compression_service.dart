import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

/// Result of preparing a story video for upload.
class PreparedVideo {
  final XFile file;
  final int originalBytes;
  final int bytes;

  const PreparedVideo({
    required this.file,
    required this.originalBytes,
    required this.bytes,
  });

  bool get wasCompressed => bytes < originalBytes;
}

/// Shrinks story videos on the phone before upload (540p, 30 fps), so a
/// 60-second clip is a few MB instead of tens. Android/iOS only; elsewhere,
/// or if compression fails, the original file is used unchanged.
class VideoCompressionService {
  static final VideoCompressionService _instance =
      VideoCompressionService._internal();
  factory VideoCompressionService() => _instance;
  VideoCompressionService._internal();

  /// Phone screens show reels at roughly this size; higher wastes data.
  static const quality = VideoQuality.Res960x540Quality;

  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Compresses [picked], reporting progress from 0 to 1. Keeps whichever of
  /// the original and compressed files is smaller.
  Future<PreparedVideo> prepare(
    XFile picked, {
    void Function(double progress)? onProgress,
  }) async {
    final originalBytes = await picked.length();
    final original = PreparedVideo(
      file: picked,
      originalBytes: originalBytes,
      bytes: originalBytes,
    );
    if (!supported) return original;

    Subscription? progress;
    try {
      if (onProgress != null) {
        // The plugin reports percent (0-100).
        progress = VideoCompress.compressProgress$.subscribe(
          (percent) => onProgress((percent / 100).clamp(0.0, 1.0)),
        );
      }
      final info = await VideoCompress.compressVideo(
        picked.path,
        quality: quality,
        includeAudio: true,
        frameRate: 30,
      );
      final path = info?.path;
      if (path == null || path.isEmpty) return original;
      final compressed = XFile(path, mimeType: 'video/mp4');
      final bytes = info?.filesize ?? await compressed.length();
      return choose(
        original,
        PreparedVideo(
          file: compressed,
          originalBytes: originalBytes,
          bytes: bytes,
        ),
      );
    } catch (e) {
      debugPrint('Video compression failed, using original: $e');
      return original;
    } finally {
      progress?.unsubscribe();
    }
  }

  /// A re-encode can come out larger (already-small clips); keep the smaller.
  @visibleForTesting
  static PreparedVideo choose(
    PreparedVideo original,
    PreparedVideo compressed,
  ) {
    if (compressed.bytes <= 0 || compressed.bytes >= original.bytes) {
      return original;
    }
    return compressed;
  }

  /// Stops an in-progress compression (e.g. the composer was closed).
  Future<void> cancel() async {
    if (!supported) return;
    try {
      await VideoCompress.cancelCompression();
    } catch (_) {}
  }

  /// Removes compressed copies once they are uploaded or discarded.
  Future<void> clearCache() async {
    if (!supported) return;
    try {
      await VideoCompress.deleteAllCache();
    } catch (_) {}
  }
}
