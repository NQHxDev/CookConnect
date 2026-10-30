import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_pool/video_pool.dart';
import 'package:cookconnect/features/recipe/data/models/post_item.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/feed_video_page.dart';

class _FakeAdapter implements PlayerAdapter {
  final ValueNotifier<PlayerState> _notifier = ValueNotifier<PlayerState>(
    const PlayerState(phase: PlaybackPhase.playing),
  );

  @override
  ValueNotifier<PlayerState> get stateNotifier => _notifier;

  @override
  Widget get videoWidget => const SizedBox();

  @override
  Duration get position => Duration.zero;

  @override
  Duration get duration => Duration.zero;

  @override
  int get estimatedMemoryBytes => 0;

  @override
  bool get isReusable => true;

  @override
  Future<void> prepare() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> swapSource(VideoSource source) async {}

  @override
  Future<void> seekTo(Duration position) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> setLooping(bool loop) async {}

  @override
  Future<void> dispose() async {
    _notifier.dispose();
  }
}

void main() {
  late VideoPool pool;

  setUp(() async {
    pool = VideoPool(
      config: const VideoPoolConfig(maxConcurrent: 2, preloadCount: 1),
      adapterFactory: (_) => _FakeAdapter(),
      sourceResolver: (_) => const VideoSource(
        url: 'https://example.com/video.mp4',
        type: VideoSourceType.network,
      ),
    );
    pool.onVisibilityChanged(primaryIndex: 0, visibilityRatios: {0: 1.0});
    await pumpEventQueue();
  });

  tearDown(() async {
    await pumpEventQueue();
    pool.dispose();
  });

  final testPost = PostItem(
    postId: 'post-1',
    userId: 'user-author-999',
    title: 'Món Bò Xào Cực Ngon',
    caption: 'Bí quyết xào bò mềm ngọt không dai',
    videoUrl: 'https://example.com/video.mp4',
    thumbnailUrl: 'https://example.com/thumb.jpg',
  );

  testWidgets(
    'ModernPauseOverlay is NOT displayed when paused by tab switch / system without user manual tap',
    (tester) async {
      final entry = pool.getEntryForIndex(0);
      expect(entry, isNotNull);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoPoolProvider(
              pool: pool,
              child: FeedVideoPage(
                index: 0,
                post: testPost,
                source: const VideoSource(
                  url: 'https://example.com/video.mp4',
                  type: VideoSourceType.network,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Video initially in playing state
      entry!.lifecycleNotifier.value = LifecycleState.playing;
      await tester.pump();
      expect(find.byType(ModernPauseOverlay), findsNothing);

      // System / Tab switch pauses the entry
      entry.lifecycleNotifier.value = LifecycleState.paused;
      await tester.pump(const Duration(milliseconds: 250));

      // ModernPauseOverlay MUST NOT be visible!
      expect(find.byType(ModernPauseOverlay), findsNothing);
    },
  );

  testWidgets(
    'ModernPauseOverlay shows when user manually taps video to pause and hides when user taps again',
    (tester) async {
      final entry = pool.getEntryForIndex(0);
      expect(entry, isNotNull);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoPoolProvider(
              pool: pool,
              child: FeedVideoPage(
                index: 0,
                post: testPost,
                source: const VideoSource(
                  url: 'https://example.com/video.mp4',
                  type: VideoSourceType.network,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Start in playing state
      entry!.lifecycleNotifier.value = LifecycleState.playing;
      await tester.pump();
      expect(find.byType(ModernPauseOverlay), findsNothing);

      // User explicitly taps the video card
      await tester.tap(find.byType(VideoCard), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 250));

      // ModernPauseOverlay MUST be visible
      expect(find.byType(ModernPauseOverlay), findsOneWidget);

      // User taps again to resume
      await tester.tap(find.byType(VideoCard), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 250));

      // ModernPauseOverlay MUST disappear
      expect(find.byType(ModernPauseOverlay), findsNothing);
    },
  );
}
