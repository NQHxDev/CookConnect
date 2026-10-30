import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cookconnect/core/config/api_config.dart';
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/core/network/api_exception.dart';
import 'package:cookconnect/core/storage/token_storage_service.dart';
import 'package:cookconnect/features/recipe/data/models/video_watch_event.dart';

/// Service responsible for batching and reporting video watch engagement metrics to the server.
/// Features:
/// - In-memory event queue (Batching) to prevent network spamming.
/// - Periodic flush every 10 seconds.
/// - Immediate flush when the queue exceeds threshold or app enters background/disposed.
/// - Matches Swagger Backend Schema: POST /api/v1/analyze/watch-session
class VideoAnalyticsService {
  static final VideoAnalyticsService instance = VideoAnalyticsService();

  final ApiClient _client;
  final TokenStorageService _tokenStorage;

  /// Internal event buffer queue
  final List<VideoWatchEvent> _queue = [];

  /// Timer for periodic syncing every 10 seconds
  Timer? _flushTimer;

  /// Sync interval duration (10 seconds)
  static const Duration flushInterval = Duration(seconds: 10);

  /// Maximum events kept in queue before an eager flush is triggered
  static const int maxQueueCapacity = 10;

  bool _isFlushing = false;

  VideoAnalyticsService({ApiClient? client, TokenStorageService? tokenStorage})
    : _client = client ?? ApiClient(),
      _tokenStorage = tokenStorage ?? SecureTokenStorageService();

  /// Total number of pending watch events in the queue
  int get pendingCount => _queue.length;

  /// Enqueue a video watch session event.
  /// Automatically starts the 10-second timer if not already running.
  void enqueue(VideoWatchEvent event) {
    _queue.add(event);

    final watchedSec = (event.watchDurationMs / 1000.0).toStringAsFixed(1);
    final totalSec = (event.videoDurationMs / 1000.0).toStringAsFixed(1);
    debugPrint(
      '📥 [VideoAnalytics] Enqueued video: ${event.postId} | Watched: ${watchedSec}s/${totalSec}s '
      '(${event.watchPercentage.toStringAsFixed(1)}%) | Loops: ${event.loopCount} | Reason: ${event.exitReason} '
      '| Pending in queue: ${_queue.length}',
    );

    // Eager flush if queue capacity exceeded
    if (_queue.length >= maxQueueCapacity) {
      flush();
    } else {
      _startPeriodicTimerIfNeeded();
    }
  }

  /// Backward-compatible alias for enqueue
  void recordWatchEvent(VideoWatchEvent event) => enqueue(event);

  void _startPeriodicTimerIfNeeded() {
    if (_flushTimer != null && _flushTimer!.isActive) return;
    _flushTimer = Timer.periodic(flushInterval, (_) {
      flush();
    });
  }

  /// Sends all queued analytics events to the server.
  /// Safe against concurrency and network disruptions.
  Future<int> flush() async {
    if (_isFlushing || _queue.isEmpty) return 0;

    _isFlushing = true;
    final eventsToSend = List<VideoWatchEvent>.from(_queue);
    _queue.clear();

    int successCount = 0;
    final List<VideoWatchEvent> failedRetries = [];

    try {
      final tokens = await _tokenStorage.getTokens();
      final token = tokens?.accessToken;

      for (final event in eventsToSend) {
        final payload = event.toServerPayload();

        try {
          final response = await _client.post(
            ApiConfig.videoWatchAnalyticsPath,
            body: payload,
            token: token,
          );

          successCount++;
          final scoreDelta = response['calculatedScoreDelta'] ?? 0;
          debugPrint(
            '✅ [VideoAnalytics] Synced video ${event.postId} (Session: ${event.sessionId}) | '
            'Score Delta: $scoreDelta | Msg: ${response['message'] ?? 'OK'}',
          );
        } on ApiException catch (e) {
          if (e.statusCode == 404) {
            debugPrint(
              'ℹ️ [VideoAnalytics] Endpoint ${ApiConfig.videoWatchAnalyticsPath} (404). Drop event.',
            );
          } else if (e.statusCode == 401) {
            debugPrint(
              '⚠️ [VideoAnalytics] Unauthorized (401). Guest session, skipped server sync.',
            );
          } else if (e.statusCode >= 400 && e.statusCode < 500) {
            debugPrint(
              '⚠️ [VideoAnalytics] Client error (${e.statusCode}): ${e.message}',
            );
          } else {
            // Server error 5xx, keep for next retry cycle
            failedRetries.add(event);
          }
        } catch (e) {
          debugPrint('⚠️ [VideoAnalytics] Network connection drop: $e');
          failedRetries.add(event);
        }
      }

      // Re-queue events that failed due to temporary connection drops
      if (failedRetries.isNotEmpty) {
        _queue.insertAll(0, failedRetries);
        debugPrint(
          '🔁 [VideoAnalytics] Re-queued ${failedRetries.length} event(s) for next 10s sync cycle.',
        );
      }
    } finally {
      _isFlushing = false;
      // Stop timer if queue is empty to conserve battery & resources
      if (_queue.isEmpty && _flushTimer != null) {
        _flushTimer?.cancel();
        _flushTimer = null;
      }
    }

    return successCount;
  }

  /// Cancels timer and flushes any remaining events before shutdown
  Future<void> dispose() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    await flush();
  }
}
