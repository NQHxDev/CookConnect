import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_pool/video_pool.dart';
import 'package:cookconnect/features/recipe/data/services/home_video_feed_controller.dart';

class FakePlayerAdapter implements PlayerAdapter {
  double volume = 1.0;
  bool isPlaying = false;
  bool isPaused = false;
  int playCalls = 0;
  int pauseCalls = 0;
  int setVolumeCalls = 0;

  @override
  final ValueNotifier<PlayerState> stateNotifier =
      ValueNotifier<PlayerState>(const PlayerState());

  @override
  Future<void> play() async {
    isPlaying = true;
    isPaused = false;
    playCalls++;
  }

  @override
  Future<void> pause() async {
    isPlaying = false;
    isPaused = true;
    pauseCalls++;
  }

  @override
  Future<void> setVolume(double vol) async {
    volume = vol;
    setVolumeCalls++;
  }

  @override
  Future<void> swapSource(VideoSource source) async {}

  @override
  Future<void> prepare() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> seekTo(Duration position) async {}

  @override
  Future<void> setLooping(bool loop) async {}

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Duration get duration => const Duration(seconds: 30);

  @override
  Duration get position => Duration.zero;

  @override
  int get estimatedMemoryBytes => 1024;

  @override
  bool get isReusable => true;

  @override
  Widget get videoWidget => const SizedBox();
}

void main() {
  late HomeVideoFeedController controller;
  late VideoPool pool;
  late FakePlayerAdapter adapter0;

  setUp(() async {
    controller = HomeVideoFeedController.instance;
    adapter0 = FakePlayerAdapter();

    pool = VideoPool(
      config: const VideoPoolConfig(maxConcurrent: 2, preloadCount: 1),
      adapterFactory: (id) => adapter0,
      sourceResolver: (index) => VideoSource(
        url: 'https://example.com/$index.mp4',
        type: VideoSourceType.network,
      ),
    );

    // Initial assignment and wait for async reconciliation
    pool.onVisibilityChanged(primaryIndex: 0, visibilityRatios: {0: 1.0});
    await pumpEventQueue();
    controller.attachPool(pool, activeIndex: 0);
  });

  tearDown(() async {
    controller.detachPool();
    await pumpEventQueue();
    pool.dispose();
  });

  group('HomeVideoFeedController', () {
    test('pauseFeed immediately stops sound, pauses playback and updates lifecycle', () async {
      final entry = pool.getEntryForIndex(0);
      expect(entry, isNotNull);
      entry!.lifecycleNotifier.value = LifecycleState.playing;

      controller.pauseFeed();

      expect(entry.lifecycleNotifier.value, LifecycleState.paused);
      expect(adapter0.setVolumeCalls, greaterThanOrEqualTo(1));
      expect(adapter0.volume, 0.0);
      expect(adapter0.pauseCalls, greaterThanOrEqualTo(1));
    });

    test('prePlayFeed sends immediate play signal, restores volume and updates lifecycle', () async {
      final entry = pool.getEntryForIndex(0);
      expect(entry, isNotNull);

      // First pause it
      controller.setHomeMainTabActive(false);
      expect(controller.isHomeMainTabActive, isFalse);

      // Now trigger pre-play signal
      controller.prePlayFeed();

      expect(controller.isHomeMainTabActive, isTrue);
      expect(entry!.lifecycleNotifier.value, LifecycleState.playing);
      expect(adapter0.volume, 1.0);
      expect(adapter0.playCalls, greaterThanOrEqualTo(1));
    });

    test('setHomeMainTabActive controls pause and play when switching main tabs', () async {
      final entry = pool.getEntryForIndex(0);
      expect(entry, isNotNull);
      entry!.lifecycleNotifier.value = LifecycleState.playing;

      // User switches away from Home main tab to Library/Profile
      controller.setHomeMainTabActive(false);
      expect(controller.isHomeMainTabActive, isFalse);
      expect(entry.lifecycleNotifier.value, LifecycleState.paused);
      expect(adapter0.volume, 0.0);

      // User switches back to Home main tab
      controller.setHomeMainTabActive(true);
      expect(controller.isHomeMainTabActive, isTrue);
      expect(entry.lifecycleNotifier.value, LifecycleState.playing);
      expect(adapter0.volume, 1.0);
    });

    test('updateSubTabActive pauses when leaving For You and resumes when returning', () async {
      final entry = pool.getEntryForIndex(0);
      expect(entry, isNotNull);
      entry!.lifecycleNotifier.value = LifecycleState.playing;

      // User switches to "Bạn bè" sub-tab (isForYou = false)
      controller.updateSubTabActive(false);
      expect(controller.isForYouSubTabActive, isFalse);
      expect(entry.lifecycleNotifier.value, LifecycleState.paused);
      expect(adapter0.volume, 0.0);

      // User returns to "Dành cho bạn" sub-tab (isForYou = true)
      controller.updateSubTabActive(true);
      expect(controller.isForYouSubTabActive, isTrue);
      expect(entry.lifecycleNotifier.value, LifecycleState.playing);
      expect(adapter0.volume, 1.0);
    });

    test('updateActiveIndex changes tracked video index', () {
      controller.updateActiveIndex(3);
      expect(controller.activePageIndex, 3);
    });
  });
}
