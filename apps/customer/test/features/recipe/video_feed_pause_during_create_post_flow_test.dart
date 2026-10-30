import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_pool/video_pool.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/core/storage/token_storage_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/recipe/data/services/home_video_feed_controller.dart';
import 'package:cookconnect/features/recipe/presentation/pages/cooking_camera_screen.dart';
import 'package:cookconnect/features/recipe/presentation/pages/upload_screen.dart';

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
    AuthService.instance.configure(storage: InMemoryTokenStorageService());
    AuthService.instance.setGuestDemo();
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
    'Video remains paused when transitioning from camera to upload recipe screen and only resumes when back to main screen',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final entry = pool.getEntryForIndex(0);
      expect(entry, isNotNull);
      entry!.lifecycleNotifier.value = LifecycleState.playing;
      adapter.isPlaying = true;
      adapter.volume = 1.0;

      // Simulate MainScreen opening CookingCameraScreen
      late BuildContext rootContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                rootContext = ctx;
                return Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      HomeVideoFeedController.instance.pauseFeed();
                      await Navigator.of(ctx).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => const CookingCameraScreen(),
                        ),
                      );
                      if (ctx.mounted && (ModalRoute.of(ctx)?.isCurrent ?? true)) {
                        HomeVideoFeedController.instance.resumeFeed();
                      }
                    },
                    child: const Text('Open Camera'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap to open Camera
      await tester.tap(find.text('Open Camera'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Video must be paused and muted upon opening camera
      expect(adapter.isPaused, isTrue);
      expect(adapter.volume, 0.0);
      final playCallsBeforeEditor = adapter.playCalls;

      // Find CookingCameraScreen
      expect(find.byType(CookingCameraScreen), findsOneWidget);

      // Now navigate to UploadScreen (Editor) from CookingCameraScreen
      final cameraState = tester.state(find.byType(CookingCameraScreen));
      expect(cameraState, isNotNull);

      // Trigger navigation to editor with a mock video path
      // ignore: avoid_dynamic_calls
      (cameraState as dynamic).navigateToEditorForTesting(
        videoPath: 'test_video.mp4',
        videoFileName: 'test_clip.mp4',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that UploadScreen is now visible
      expect(find.byType(UploadScreen), findsOneWidget);
      expect(find.text('Nguyên liệu & Cách làm'), findsOneWidget);

      // CRITICAL ASSERTION:
      // Video on Home feed MUST NOT resume while user is on UploadScreen!
      // In the buggy version, pushReplacement caused the camera future to complete immediately,
      // which resumed the feed and unmuted sound while on UploadScreen.
      expect(adapter.isPaused, isTrue);
      expect(adapter.volume, 0.0);
      expect(adapter.playCalls, equals(playCallsBeforeEditor));

      // Pop UploadScreen (simulating user cancel / back)
      final closeButton = find.descendant(
        of: find.byType(UploadScreen),
        matching: find.byIcon(Icons.close),
      );
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // We should be back on CookingCameraScreen, video still paused
      expect(find.byType(CookingCameraScreen), findsOneWidget);
      expect(adapter.isPaused, isTrue);
      expect(adapter.volume, 0.0);

      // Now close CookingCameraScreen to return to root screen
      Navigator.of(rootContext).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Now that we are back to root screen, Home feed resumes
      expect(adapter.isPlaying, isTrue);
      expect(adapter.volume, 1.0);
    },
  );

  testWidgets(
    'Publishing from recipe editor closes all flow screens and resumes home feed',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final entry = pool.getEntryForIndex(0);
      expect(entry, isNotNull);
      entry!.lifecycleNotifier.value = LifecycleState.playing;
      adapter.isPlaying = true;
      adapter.volume = 1.0;

      late BuildContext rootContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                rootContext = ctx;
                return Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      HomeVideoFeedController.instance.pauseFeed();
                      await Navigator.of(ctx).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => const CookingCameraScreen(),
                        ),
                      );
                      if (ctx.mounted && (ModalRoute.of(ctx)?.isCurrent ?? true)) {
                        HomeVideoFeedController.instance.resumeFeed();
                      }
                    },
                    child: const Text('Open Camera'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open Camera'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final cameraState = tester.state(find.byType(CookingCameraScreen));
      // ignore: avoid_dynamic_calls
      (cameraState as dynamic).navigateToEditorForTesting(
        videoPath: 'test_video.mp4',
        videoFileName: 'test_clip.mp4',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(UploadScreen), findsOneWidget);
      expect(adapter.isPaused, isTrue);

      // Simulate publishing: find UploadScreen and invoke onPublished callback
      final uploadScreen = tester.widget<UploadScreen>(find.byType(UploadScreen));
      expect(uploadScreen.onPublished, isNotNull);
      uploadScreen.onPublished!();

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      // Both UploadScreen and CookingCameraScreen should now be popped
      expect(find.byType(UploadScreen), findsNothing);
      expect(find.byType(CookingCameraScreen), findsNothing);

      // Feed must resume on main screen
      expect(adapter.isPlaying, isTrue);
      expect(adapter.volume, 1.0);
    },
  );
}
