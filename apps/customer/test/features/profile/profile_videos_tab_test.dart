import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/features/auth/data/models/auth_user.dart';
import 'package:cookconnect/features/auth/data/models/auth_tokens.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/profile/presentation/pages/profile_screen.dart';
import 'package:cookconnect/features/recipe/data/services/post_api_service.dart';
import 'package:cookconnect/features/recipe/presentation/pages/user_video_feed_screen.dart';

void main() {
  setUp(() {
    AuthService.instance.setSession(
      user: AuthUser(
        id: 'user-test-1',
        email: 'test@cookconnect.app',
        fullName: 'Chef Test',
        username: 'cheftest',
      ),
      tokens: AuthTokens(
        accessToken: 'fake-token',
        refreshToken: 'fake-refresh',
      ),
    );
  });

  tearDown(() {
    AuthService.instance.logout(callServer: false);
  });

  testWidgets(
    'ProfileVideosTab displays empty state when user has no posted videos',
    (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/posts/feed')) {
          return http.Response(
            '{"statusCode": 200, "data": {"items": [], "nextCursor": null, "hasMore": false}}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final postApiService = PostApiService(
        apiClient: ApiClient(client: mockClient),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: ProfileVideosTab(
                    userId: 'user-test-1',
                    postApiService: postApiService,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Chưa có video nào'), findsOneWidget);
      expect(
        find.text('Các video công thức bạn đã đăng tải sẽ hiển thị ở đây.'),
        findsOneWidget,
      );
      expect(find.text('Đăng video mới'), findsNothing);

      // Verify empty state styling matches Liked and Saved tabs
      final iconFinder = find.byIcon(Iconsax.video_play);
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.size, equals(48));
      expect(iconWidget.color, equals(Colors.grey.shade400));

      final titleText = tester.widget<Text>(find.text('Chưa có video nào'));
      expect(titleText.style?.fontSize, equals(15));
      expect(titleText.style?.fontWeight, equals(FontWeight.w600));
      expect(titleText.style?.color, equals(Colors.grey.shade700));

      final subtitleText = tester.widget<Text>(
        find.text('Các video công thức bạn đã đăng tải sẽ hiển thị ở đây.'),
      );
      expect(subtitleText.style?.fontSize, equals(12));
      expect(subtitleText.style?.color, equals(Colors.grey.shade500));
    },
  );

  testWidgets(
    'ProfileVideosTab renders real video items with views and thumbnail instead of placeholder',
    (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/posts/feed')) {
          return http.Response(
            '''{
              "statusCode": 200,
              "data": {
                "items": [
                  {
                    "postId": "post-pho-bo",
                    "userId": "user-test-1",
                    "title": "Phở Bò Gia Truyền",
                    "caption": "Nước dùng thơm lừng",
                    "videoUrl": "https://pub-50b1ab619efd4084959e011fe2e5a273.r2.dev/videos/video_1.mp4",
                    "thumbnailUrl": "https://example.com/thumb_pho.jpg",
                    "duration": 45,
                    "viewCount": 15400,
                    "likeCount": 1200,
                    "commentCount": 35,
                    "shareCount": 10,
                    "saveCount": 85,
                    "allowComments": true,
                    "allowDuet": false,
                    "createdAt": "2026-10-17T02:00:00.000Z",
                    "updatedAt": "2026-10-17T02:00:00.000Z",
                    "ingredients": []
                  },
                  {
                    "postId": "post-bun-cha",
                    "userId": "user-test-1",
                    "title": "Bún Chả Hà Nội",
                    "caption": "Chả nướng than hoa",
                    "videoUrl": "https://pub-50b1ab619efd4084959e011fe2e5a273.r2.dev/videos/video_2.mp4",
                    "thumbnailUrl": "https://example.com/thumb_buncha.jpg",
                    "duration": 60,
                    "viewCount": 850,
                    "likeCount": 210,
                    "commentCount": 12,
                    "shareCount": 5,
                    "saveCount": 40,
                    "allowComments": true,
                    "allowDuet": false,
                    "createdAt": "2026-10-18T02:00:00.000Z",
                    "updatedAt": "2026-10-18T02:00:00.000Z",
                    "ingredients": []
                  }
                ],
                "nextCursor": null,
                "hasMore": false
              }
            }''',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final postApiService = PostApiService(
        apiClient: ApiClient(client: mockClient),
      );

      int reportedCount = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileVideosTab(
              userId: 'user-test-1',
              postApiService: postApiService,
              onVideosCountChanged: (count) {
                reportedCount = count;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check reported videos count callback
      expect(reportedCount, equals(2));

      // View counts from real API data
      expect(find.text('15.4K'), findsOneWidget);
      expect(find.text('850'), findsOneWidget);

      // Verify grid items exist and are not placeholder childCount 36
      expect(find.byType(SliverGrid), findsOneWidget);

      // Tapping on first video opens UserVideoFeedScreen
      await tester.tap(find.text('15.4K'));
      await tester.pumpAndSettle();

      expect(find.byType(UserVideoFeedScreen), findsOneWidget);
    },
  );

  testWidgets(
    'ProfileScreen does not render NestedScrollView when user has 0 videos',
    (WidgetTester tester) async {
      AuthService.instance.setSession(
        user: AuthUser(
          id: 'user-empty',
          email: 'empty@cookconnect.app',
          fullName: 'Empty User',
          username: 'empty_user',
          videoCount: 0,
        ),
        tokens: AuthTokens(
          accessToken: 'fake-token',
          refreshToken: 'fake-refresh',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // NestedScrollView is NOT used when content height is not enough to overflow
      expect(find.byType(NestedScrollView), findsNothing);
    },
  );
}
