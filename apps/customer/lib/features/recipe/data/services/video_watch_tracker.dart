import 'dart:math';
import 'package:cookconnect/features/recipe/data/models/video_watch_event.dart';

/// Tracks the viewing session of a video item.
/// Accurately records:
/// - Real elapsed watch time (excluding buffering, pauses, seeking)
/// - Maximum playback position reached
/// - Looping count when short video loops back to start
/// - Completion percentage
/// - Handles re-watching gracefully by resetting session state on replay
class VideoWatchTracker {
  final String postId;
  final String videoUrl;
  final Duration minWatchThreshold;
  final List<String> categoryIds;
  final List<String> tagIds;

  late String _sessionId;
  final Stopwatch _stopwatch = Stopwatch();
  int _maxPositionMs = 0;
  int _lastPositionMs = 0;
  int _loopCount = 0;
  int _totalDurationMs = 0;
  bool _hasEnded = false;

  VideoWatchTracker({
    required this.postId,
    required this.videoUrl,
    Duration? initialDuration,
    this.minWatchThreshold = const Duration(milliseconds: 600),
    this.categoryIds = const [],
    this.tagIds = const [],
  }) {
    _totalDurationMs = initialDuration?.inMilliseconds ?? 0;
    _sessionId = _generateSessionId();
  }

  String get sessionId => _sessionId;
  bool get isTracking => _stopwatch.isRunning;
  bool get hasEnded => _hasEnded;
  int get elapsedWatchMs => _stopwatch.elapsedMilliseconds;
  int get totalDurationMs => _totalDurationMs;
  int get loopCount => _loopCount;
  int get maxPositionMs => _maxPositionMs;

  /// Generate a unique compliant RFC-4122 UUID v4 session ID
  static String _generateSessionId() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // RFC-4122 version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC-4122 variant
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Start or resume watch time tracking.
  /// If the previous session had ended (e.g. user scrolled away then came back),
  /// automatically resets for a clean re-watch session with a new sessionId.
  void start() {
    if (_hasEnded) {
      reset();
    }
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    }
  }

  /// Pause tracking (e.g. video paused by user, buffering, or app minimized)
  void pause() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    }
  }

  /// Update video playback progress to measure max position and detect looping
  void onPositionUpdated(Duration position, [Duration? totalDuration]) {
    if (totalDuration != null && totalDuration.inMilliseconds > 0) {
      _totalDurationMs = totalDuration.inMilliseconds;
    }

    final curMs = position.inMilliseconds;
    if (curMs > _maxPositionMs) {
      _maxPositionMs = curMs;
    }

    // Detect looping: previously near the end (>85% duration) and now back near start (<1.5s)
    if (_totalDurationMs > 2000 &&
        _lastPositionMs >= (_totalDurationMs * 0.85) &&
        curMs < 1500) {
      _loopCount++;
    }

    _lastPositionMs = curMs;
  }

  /// Finalize the watch session and build the analytic event.
  /// Returns null if the watch time is below [minWatchThreshold] (e.g. quick flick).
  VideoWatchEvent? finish({String reason = 'SCROLLED'}) {
    if (_hasEnded) return null;

    pause();
    final watchedMs = _stopwatch.elapsedMilliseconds;

    // Filter out fast flicks (less than min threshold)
    if (watchedMs < minWatchThreshold.inMilliseconds) {
      _hasEnded = true;
      return null;
    }

    _hasEnded = true;

    final event = VideoWatchEvent.create(
      postId: postId,
      videoUrl: videoUrl,
      sessionId: _sessionId,
      watchDurationMs: watchedMs,
      videoDurationMs: _totalDurationMs > 0 ? _totalDurationMs : _maxPositionMs,
      maxPositionMs: _maxPositionMs,
      loopCount: _loopCount,
      exitReason: reason,
      categoryIds: categoryIds,
      tagIds: tagIds,
      timestamp: DateTime.now(),
    );

    return event;
  }

  /// Reset tracker for a new session of the same video (used when re-watching)
  void reset() {
    _stopwatch.reset();
    _stopwatch.stop();
    _maxPositionMs = 0;
    _lastPositionMs = 0;
    _loopCount = 0;
    _hasEnded = false;
    _sessionId = _generateSessionId();
  }
}
