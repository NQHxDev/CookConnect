import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/recipe/data/models/video_watch_event.dart';
import 'package:cookconnect/features/recipe/data/services/video_watch_tracker.dart';
import 'package:cookconnect/features/recipe/data/services/video_analytics_service.dart';

void main() {
  group('VideoWatchEvent tests', () {
    test('Calculates watch percentage and matches Server OpenAPI specification', () {
      final event = VideoWatchEvent.create(
        postId: 'post-test-1',
        videoUrl: 'https://cdn.cookconnect.app/v1.mp4',
        sessionId: '0192e21b-0002-7000-8000-000000000001',
        watchDurationMs: 30000, // 30 seconds
        videoDurationMs: 100000, // 100 seconds
        maxPositionMs: 32000,
        loopCount: 0,
        exitReason: 'SCROLLED',
        categoryIds: ['vietnamese-cuisine'],
        tagIds: ['phobo'],
      );

      expect(event.postId, equals('post-test-1'));
      expect(event.completionRate, closeTo(0.3, 0.001));
      expect(event.watchPercentage, closeTo(30.0, 0.01));
      expect(event.isCompleted, isFalse);

      final serverPayload = event.toServerPayload();
      expect(serverPayload['videoId'], equals('post-test-1'));
      expect(serverPayload['sessionId'], equals('0192e21b-0002-7000-8000-000000000001'));
      expect(serverPayload['watchDurationMs'], equals(30000));
      expect(serverPayload['videoDurationMs'], equals(100000));
      expect(serverPayload['isCompleted'], isFalse);
      expect(serverPayload['loopCount'], equals(0));
      expect(serverPayload['categoryIds'], equals(['vietnamese-cuisine']));
      expect(serverPayload['tagIds'], equals(['phobo']));
    });

    test('Video watched to end marks isCompleted as true', () {
      final event = VideoWatchEvent.create(
        postId: 'post-test-2',
        videoUrl: 'https://cdn.cookconnect.app/v2.mp4',
        sessionId: '0192e21b-0002-7000-8000-000000000002',
        watchDurationMs: 60000,
        videoDurationMs: 60000,
        maxPositionMs: 59500,
        loopCount: 0,
        exitReason: 'COMPLETED',
      );

      expect(event.completionRate, closeTo(1.0, 0.001));
      expect(event.watchPercentage, closeTo(100.0, 0.01));
      expect(event.isCompleted, isTrue);
    });
  });

  group('VideoWatchTracker tests', () {
    test('Filters out rapid flick scrolls under minWatchThreshold', () {
      final tracker = VideoWatchTracker(
        postId: 'quick-flick',
        videoUrl: 'https://example.com/flick.mp4',
        initialDuration: const Duration(seconds: 30),
        minWatchThreshold: const Duration(milliseconds: 500),
      );

      tracker.start();
      final event = tracker.finish(reason: 'SCROLLED');
      expect(event, isNull);
    });

    test('Automatically resets and creates new session on re-watch after finish', () async {
      final tracker = VideoWatchTracker(
        postId: 'rewatch-post',
        videoUrl: 'https://example.com/video.mp4',
        initialDuration: const Duration(seconds: 10),
        minWatchThreshold: Duration.zero,
      );

      // Session 1: User watches video for first time
      tracker.start();
      final session1Id = tracker.sessionId;
      await Future.delayed(const Duration(milliseconds: 20));
      final event1 = tracker.finish(reason: 'SCROLLED');

      expect(event1, isNotNull);
      expect(event1!.sessionId, equals(session1Id));
      expect(tracker.hasEnded, isTrue);

      // Session 2: User scrolls back to the same video!
      tracker.start(); // Auto-resets session
      expect(tracker.hasEnded, isFalse);
      final session2Id = tracker.sessionId;
      expect(session2Id, isNot(equals(session1Id)));

      await Future.delayed(const Duration(milliseconds: 20));
      final event2 = tracker.finish(reason: 'SCROLLED');

      expect(event2, isNotNull);
      expect(event2!.sessionId, equals(session2Id));
    });
  });

  group('VideoAnalyticsService batching tests', () {
    test('Enqueues events into in-memory queue without instant spam', () {
      final service = VideoAnalyticsService.instance;
      final initialCount = service.pendingCount;

      final event = VideoWatchEvent.create(
        postId: 'batch-test-post',
        videoUrl: 'https://example.com/batch.mp4',
        sessionId: '0192e21b-0002-7000-8000-batch0000001',
        watchDurationMs: 15000,
        videoDurationMs: 30000,
        maxPositionMs: 16000,
        loopCount: 0,
        exitReason: 'SCROLLED',
      );

      service.enqueue(event);
      expect(service.pendingCount, equals(initialCount + 1));
    });
  });
}
