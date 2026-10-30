import 'dart:math';

/// DTO representing a video watch behavior event.
/// Captures exact viewing time, total length, completion rate (percentage),
/// loop count, max position, and exit reason.
/// Fully matches the Backend Swagger Schema for RecordWatchSessionDto:
/// - sessionId
/// - videoId (mapped from postId)
/// - watchDurationMs
/// - videoDurationMs
/// - isCompleted
/// - loopCount
/// - categoryIds
/// - tagIds
class VideoWatchEvent {
  /// Unique identifier of the post/recipe (maps to videoId on server)
  final String postId;

  /// URL or Media ID of the video being watched
  final String videoUrl;

  /// Unique session identifier for this playback instance (UUID or unique string)
  final String sessionId;

  /// Exact time spent actually watching (in milliseconds)
  final int watchDurationMs;

  /// Total duration of the video (in milliseconds)
  final int videoDurationMs;

  /// Completion rate as a fraction between 0.0 and 1.0 (e.g. 0.35 for 35%)
  /// Can exceed 1.0 if the user watches multiple loops.
  final double completionRate;

  /// Completion rate expressed as percentage (0.0% to 100.0%)
  final double watchPercentage;

  /// Furthest playback position the user reached (in milliseconds)
  final int maxPositionMs;

  /// Number of times the video looped back to the beginning
  final int loopCount;

  /// Whether the video was watched to completion at least once
  final bool isCompleted;

  /// Reason why playback tracking ended ('SCROLLED', 'PAUSED', 'APP_BACKGROUND', 'DISPOSED', 'COMPLETED')
  final String exitReason;

  /// Category identifiers for recommendation affinity
  final List<String> categoryIds;

  /// Tag identifiers or keywords
  final List<String> tagIds;

  /// Timestamp when this event was recorded
  final DateTime timestamp;

  VideoWatchEvent({
    required this.postId,
    required this.videoUrl,
    required this.sessionId,
    required this.watchDurationMs,
    required this.videoDurationMs,
    required this.completionRate,
    required this.watchPercentage,
    required this.maxPositionMs,
    required this.loopCount,
    required this.isCompleted,
    required this.exitReason,
    this.categoryIds = const [],
    this.tagIds = const [],
    required this.timestamp,
  });

  /// Factory constructor computing metrics from raw values
  factory VideoWatchEvent.create({
    required String postId,
    required String videoUrl,
    required String sessionId,
    required int watchDurationMs,
    required int videoDurationMs,
    required int maxPositionMs,
    required int loopCount,
    required String exitReason,
    List<String> categoryIds = const [],
    List<String> tagIds = const [],
    DateTime? timestamp,
  }) {
    final validVideoDuration = max(1, videoDurationMs);
    final rawRate = watchDurationMs / validVideoDuration;
    final percentage = (rawRate * 100).clamp(0.0, 100.0);
    final completed =
        loopCount > 0 ||
        (videoDurationMs > 0 && maxPositionMs >= (videoDurationMs * 0.95));

    return VideoWatchEvent(
      postId: postId,
      videoUrl: videoUrl,
      sessionId: sessionId,
      watchDurationMs: watchDurationMs,
      videoDurationMs: videoDurationMs,
      completionRate: rawRate,
      watchPercentage: percentage,
      maxPositionMs: maxPositionMs,
      loopCount: loopCount,
      isCompleted: completed,
      exitReason: exitReason,
      categoryIds: categoryIds,
      tagIds: tagIds,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Converts to JSON payload compatible with Backend OpenAPI/Swagger specification:
  /// POST /api/v1/analyze/watch-session (RecordWatchSessionDto)
  Map<String, dynamic> toServerPayload() {
    return {
      'sessionId': sessionId,
      'videoId': postId,
      'watchDurationMs': watchDurationMs,
      'videoDurationMs': max(1, videoDurationMs),
      'isCompleted': isCompleted,
      'loopCount': loopCount,
      'categoryIds': categoryIds,
      'tagIds': tagIds,
    };
  }

  /// Converts to generic JSON payload for local caching or debugging
  Map<String, dynamic> toJson({bool snakeCase = false}) {
    final watchSec = (watchDurationMs / 1000.0);
    final videoSec = (videoDurationMs / 1000.0);
    final maxPosSec = (maxPositionMs / 1000.0);

    if (snakeCase) {
      return {
        'post_id': postId,
        'video_id': postId,
        'video_url': videoUrl,
        'session_id': sessionId,
        'watch_duration_ms': watchDurationMs,
        'video_duration_ms': videoDurationMs,
        'watch_duration_seconds': double.parse(watchSec.toStringAsFixed(2)),
        'video_duration_seconds': double.parse(videoSec.toStringAsFixed(2)),
        'completion_rate': double.parse(completionRate.toStringAsFixed(4)),
        'watch_percentage': double.parse(watchPercentage.toStringAsFixed(2)),
        'max_position_seconds': double.parse(maxPosSec.toStringAsFixed(2)),
        'loop_count': loopCount,
        'is_completed': isCompleted,
        'exit_reason': exitReason,
        'category_ids': categoryIds,
        'tag_ids': tagIds,
        'timestamp': timestamp.toIso8601String(),
      };
    }

    return {
      'postId': postId,
      'videoId': postId,
      'videoUrl': videoUrl,
      'sessionId': sessionId,
      'watchDurationMs': watchDurationMs,
      'videoDurationMs': videoDurationMs,
      'watchDurationSeconds': double.parse(watchSec.toStringAsFixed(2)),
      'videoDurationSeconds': double.parse(videoSec.toStringAsFixed(2)),
      'completionRate': double.parse(completionRate.toStringAsFixed(4)),
      'watchPercentage': double.parse(watchPercentage.toStringAsFixed(2)),
      'maxPositionSeconds': double.parse(maxPosSec.toStringAsFixed(2)),
      'loopCount': loopCount,
      'isCompleted': isCompleted,
      'exitReason': exitReason,
      'categoryIds': categoryIds,
      'tagIds': tagIds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    final watchSec = (watchDurationMs / 1000.0).toStringAsFixed(1);
    final videoSec = (videoDurationMs / 1000.0).toStringAsFixed(1);
    return 'VideoWatchEvent(videoId: $postId, watched: ${watchSec}s/${videoSec}s '
        '(${watchPercentage.toStringAsFixed(1)}%), loops: $loopCount, exit: $exitReason)';
  }
}
