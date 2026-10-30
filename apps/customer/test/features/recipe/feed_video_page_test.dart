import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_pool/video_pool.dart';
import 'package:cookconnect/features/auth/data/models/auth_tokens.dart';
import 'package:cookconnect/features/auth/data/models/auth_user.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/recipe/data/models/post_item.dart';
import 'package:cookconnect/features/recipe/data/services/author_profile_service.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/feed_video_page.dart';

class _MockPlayerAdapter implements PlayerAdapter {
  final ValueNotifier<PlayerState> _notifier = ValueNotifier<PlayerState>(
    const PlayerState(phase: PlaybackPhase.idle),
  );

  @override
  ValueNotifier<PlayerState> get stateNotifier => _notifier;

  @override
  Widget get videoWidget => const SizedBox.shrink();

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

Widget _wrapTestWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: VideoPoolScope(
        config: const VideoPoolConfig(
          maxConcurrent: 2,
          preloadCount: 1,
        ),
        adapterFactory: (_) => _MockPlayerAdapter(),
        sourceResolver: (_) => const VideoSource(
          url: 'https://example.com/video.mp4',
          type: VideoSourceType.network,
        ),
        child: child,
      ),
    ),
  );
}

void main() {
  setUp(() {
    AuthorProfileService.instance.clear();
  });

  tearDown(() {
    AuthService.instance.logout(callServer: false);
  });

  final testPost = PostItem(
    postId: 'post-1',
    userId: 'user-author-999',
    title: 'Món Bò Xào Cực Ngon',
    caption: 'Bí quyết xào bò mềm ngọt không dai',
    videoUrl: 'https://example.com/video.mp4',
    thumbnailUrl: 'https://example.com/thumb.jpg',
  );

  testWidgets('displays explicit authorUsername when provided', (tester) async {
    await tester.pumpWidget(
      _wrapTestWidget(
        child: FeedVideoPage(
          index: 0,
          post: testPost,
          source: const VideoSource(
            url: 'https://example.com/video.mp4',
            type: VideoSourceType.network,
          ),
          authorUsername: 'chef_quanghung',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('@chef_quanghung'), findsOneWidget);
    expect(find.text('@chef_cookconnect'), findsNothing);
  });

  testWidgets('displays current user handle when post.userId matches currentUser accountId', (tester) async {
    final currentUser = AuthUser(
      id: 'internal-id',
      userId: 'user-db-id',
      accountId: 'user-author-999',
      email: 'hung@cookconnect.app',
      fullName: 'Nguyễn Quang Hưng',
      username: 'anhjkrr7',
    );

    AuthService.instance.setSession(
      user: currentUser,
      tokens: AuthTokens(accessToken: 'acc-token', refreshToken: 'ref-token'),
    );

    await tester.pumpWidget(
      _wrapTestWidget(
        child: FeedVideoPage(
          index: 0,
          post: testPost,
          source: const VideoSource(
            url: 'https://example.com/video.mp4',
            type: VideoSourceType.network,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('@anhjkrr7'), findsOneWidget);
    expect(find.text('@chef_cookconnect'), findsNothing);
  });

  testWidgets('avatar without picture uses dark gray background, not orange gradient', (tester) async {
    await tester.pumpWidget(
      _wrapTestWidget(
        child: FeedVideoPage(
          index: 0,
          post: testPost,
          source: const VideoSource(
            url: 'https://example.com/video.mp4',
            type: VideoSourceType.network,
          ),
          authorAvatar: null,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify avatar fallback container does NOT have orange gradient
    final containers = tester.widgetList<Container>(find.byType(Container));
    final avatarContainer = containers.firstWhere(
      (c) => c.constraints?.maxWidth == 48 && c.constraints?.maxHeight == 48,
    );

    final decoration = avatarContainer.decoration as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);

    // Verify gradient contains slate-gray colors and no orange
    if (decoration.gradient is LinearGradient) {
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors.contains(Colors.orange), isFalse);
      expect(gradient.colors.contains(Colors.deepOrangeAccent), isFalse);
      expect(gradient.colors.first, const Color(0xFF3E3E42));
      expect(gradient.colors.last, const Color(0xFF262628));
    }
  });

  testWidgets('ModernPauseOverlay renders minimalist play triangle icon with opacity and no background', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ModernPauseOverlay(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify play triangle is shown
    final iconFinder = find.byIcon(Icons.play_arrow_rounded);
    expect(iconFinder, findsOneWidget);

    final Icon playIcon = tester.widget<Icon>(iconFinder);
    expect(playIcon.color, Colors.white.withValues(alpha: 0.65));
    expect(playIcon.size, 72);

    // Verify there is no ClipOval or Container background used for pause overlay
    expect(find.byType(ClipOval), findsNothing);
    expect(find.byType(Container), findsNothing);
  });
}

