import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_pool/video_pool.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/main/presentation/pages/main_screen.dart';
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
  late VideoPool pool;
  late FakePlayerAdapter adapter;

  setUp(() async {
    ApiI18n.currentLanguage = ApiI18n.vi;
    adapter = FakePlayerAdapter();

    pool = VideoPool(
      config: const VideoPoolConfig(maxConcurrent: 2, preloadCount: 1),
      adapterFactory: (id) => adapter,
      sourceResolver: (index) => VideoSource(
        url: 'https://example.com/$index.mp4',
        type: VideoSourceType.network,
      ),
    );

    pool.onVisibilityChanged(primaryIndex: 0, visibilityRatios: {0: 1.0});
    await pumpEventQueue();
    HomeVideoFeedController.instance.attachPool(pool, activeIndex: 0);
  });

  tearDown(() async {
    HomeVideoFeedController.instance.detachPool();
    await pumpEventQueue();
    pool.dispose();
  });

  testWidgets(
    'Switching to another tab pauses video & mutes sound immediately; touching Home tab sends pre-play signal',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final entry = pool.getEntryForIndex(0);
      expect(entry, isNotNull);
      entry!.lifecycleNotifier.value = LifecycleState.playing;

      await tester.pumpWidget(
        const MaterialApp(
          home: MainScreen(),
        ),
      );
      await tester.pump();

      // Home tab is initially active
      expect(HomeVideoFeedController.instance.isHomeMainTabActive, isTrue);

      // Tap on Library tab (Thư viện)
      final libraryTab = find.text('Thư viện');
      expect(libraryTab, findsOneWidget);
      await tester.tap(libraryTab);
      await tester.pump();

      // Video must be immediately paused and sound muted
      expect(HomeVideoFeedController.instance.isHomeMainTabActive, isFalse);
      expect(entry.lifecycleNotifier.value, LifecycleState.paused);
      expect(adapter.volume, 0.0);
      expect(adapter.pauseCalls, greaterThanOrEqualTo(1));

      // Now user prepares to return to Home tab:
      // Send a pointer down event (finger touching the screen) to Home tab icon
      final homeTab = find.text('Trang chủ');
      expect(homeTab, findsOneWidget);

      final homeCenter = tester.getCenter(homeTab);
      final gesture = await tester.startGesture(homeCenter, kind: PointerDeviceKind.touch);

      // Pre-play signal is fired BEFORE user lifts finger or completes tap!
      expect(HomeVideoFeedController.instance.isHomeMainTabActive, isTrue);
      expect(entry.lifecycleNotifier.value, LifecycleState.playing);
      expect(adapter.volume, 1.0);
      expect(adapter.playCalls, greaterThanOrEqualTo(1));

      // Complete the tap gesture
      await gesture.up();
      await tester.pump();

      // Video remains playing on Home tab
      expect(HomeVideoFeedController.instance.isHomeMainTabActive, isTrue);
      expect(entry.lifecycleNotifier.value, LifecycleState.playing);
    },
  );
}
