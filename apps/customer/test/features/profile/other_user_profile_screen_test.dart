import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/profile/presentation/pages/other_user_profile_screen.dart';
import 'package:cookconnect/features/chat/presentation/pages/chat_detail_screen.dart';

void main() {
  setUp(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
    AuthService.instance.setSession(
      user: AuthUser(
        id: 'current-user-1',
        email: 'me@cookconnect.app',
        fullName: 'Me Chef',
      ),
      tokens: AuthTokens(
        accessToken: 'valid-test-access-token',
        refreshToken: 'valid-test-refresh-token',
      ),
    );
  });

  tearDown(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
    AuthService.instance.logout(callServer: false);
  });

  testWidgets('OtherUserProfileScreen shows loading box while fetching then displays complete profile & stats (recipesCount)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/v1/users/user-other-123') {
        return http.Response(
          '''{
            "statusCode": 200,
            "data": {
              "id": "user-other-123",
              "username": "minhtrang_chef",
              "displayName": "Chef Minh Trang",
              "profile": {
                "displayName": "Chef Minh Trang",
                "username": "minhtrang_chef",
                "bio": "Đam mê làm bánh ngọt Pháp 🍰🇫🇷",
                "avatar": "https://example.com/avatar.jpg"
              },
              "stats": {
                "recipesCount": 24,
                "postsCount": 30,
                "followersCount": 2500,
                "followingCount": 180,
                "likesCount": 15400
              }
            }
          }''',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      return http.Response('Not Found', 404);
    });

    final apiService = ApiService(client: mockClient);

    await tester.pumpWidget(
      MaterialApp(
        home: OtherUserProfileScreen(
          userId: 'user-other-123',
          apiService: apiService,
        ),
      ),
    );

    // Initial state: loading box must be shown
    expect(find.text('Đang tải thông tin đầu bếp...'), findsOneWidget);
    expect(find.text('Chef Minh Trang'), findsNothing);

    // Let the API response complete
    await tester.pumpAndSettle();

    // Verify loading box gone, full profile rendered without flicker
    expect(find.text('Đang tải thông tin đầu bếp...'), findsNothing);
    expect(find.text('Chef Minh Trang'), findsWidgets);
    expect(find.text('@minhtrang_chef'), findsOneWidget);

    // Verify stats from API: recipesCount = 24 (Công thức)
    expect(find.text('24'), findsOneWidget);
    expect(find.text('Công thức'), findsOneWidget);
    expect(find.text('2.5K'), findsOneWidget);
    expect(find.text('Follower'), findsOneWidget);
    expect(find.text('15.4K'), findsOneWidget);
    expect(find.text('Thích'), findsOneWidget);

    // Verify bio displayed without "+ Thêm tiểu sử" button
    expect(find.text('Đam mê làm bánh ngọt Pháp 🍰🇫🇷'), findsOneWidget);
    expect(find.text('Thêm tiểu sử'), findsNothing);

    // Verify 2 action buttons
    expect(find.text('Theo dõi'), findsOneWidget);
    expect(find.text('Nhắn tin'), findsOneWidget);

    // Toggle Follow button
    await tester.tap(find.text('Theo dõi'));
    await tester.pumpAndSettle();

    expect(find.text('Đang theo dõi'), findsOneWidget);
    expect(find.text('Đã theo dõi Chef Minh Trang'), findsOneWidget);

    // Tap Nhắn tin opens ChatDetailScreen
    await tester.tap(find.text('Nhắn tin'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatDetailScreen), findsOneWidget);
    expect(find.text('Chef Minh Trang'), findsWidgets);
  });

  testWidgets('OtherUserProfileScreen back button navigates back', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool popped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OtherUserProfileScreen(
                      userId: 'user-2',
                      name: 'Chef Tuấn',
                      username: 'tuan_cook',
                    ),
                  ),
                );
                popped = true;
              },
              child: const Text('Open Profile'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(OtherUserProfileScreen), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Iconsax.arrow_left));
    await tester.pumpAndSettle();

    expect(find.byType(OtherUserProfileScreen), findsNothing);
    expect(popped, isTrue);
  });

  testWidgets('OtherUserProfileScreen supports custom pull-to-refresh overscroll pushing content down', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool refreshTriggered = false;

    final mockClient = MockClient((request) async {
      return http.Response(
        '{"statusCode": 200, "data": {"id": "user-3", "username": "minhquan_cook", "displayName": "Chef Minh Quân", "stats": {"recipesCount": 15, "followersCount": 100, "likesCount": 500}}}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final apiService = ApiService(client: mockClient);

    await tester.pumpWidget(
      MaterialApp(
        home: OtherUserProfileScreen(
          userId: 'user-3',
          name: 'Chef Minh Quân',
          username: 'minhquan_cook',
          apiService: apiService,
          onRefresh: () async {
            refreshTriggered = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Pull down from top edge to trigger overscroll custom refresh
    await tester.fling(find.byType(NestedScrollView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(refreshTriggered, isTrue);
  });

  testWidgets('OtherUserProfileScreen reactively updates UI labels when language changes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: OtherUserProfileScreen(
          userId: 'user-i18n-1',
          name: 'Chef Lan Anh',
          username: 'lananh_cook',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Default Vietnamese labels
    expect(find.text('Công thức'), findsOneWidget);
    expect(find.text('Follower'), findsOneWidget);
    expect(find.text('Thích'), findsOneWidget);
    expect(find.text('Theo dõi'), findsOneWidget);
    expect(find.text('Nhắn tin'), findsOneWidget);

    // Switch language to English
    ApiI18n.currentLanguage = ApiI18n.en;
    await tester.pumpAndSettle();

    // English labels
    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Followers'), findsOneWidget);
    expect(find.text('Likes'), findsOneWidget);
    expect(find.text('Follow'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);

    // Toggle follow in English
    await tester.tap(find.text('Follow'));
    await tester.pumpAndSettle();

    expect(find.text('Following'), findsOneWidget);
    expect(find.text('Followed Chef Lan Anh'), findsOneWidget);

    // Switch back to Vietnamese
    ApiI18n.currentLanguage = ApiI18n.vi;
    await tester.pumpAndSettle();

    expect(find.text('Công thức'), findsOneWidget);
    expect(find.text('Đang theo dõi'), findsOneWidget);
  });

  testWidgets('OtherUserProfileScreen displays empty state when user has 0 recipes without extra scrolling', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockClient = MockClient((request) async {
      return http.Response(
        '''{
          "statusCode": 200,
          "data": {
            "id": "user-empty-recipes",
            "username": "chef_newbie",
            "displayName": "Chef Mới",
            "profile": {
              "displayName": "Chef Mới",
              "username": "chef_newbie"
            },
            "stats": {
              "recipesCount": 0,
              "postsCount": 0,
              "followersCount": 5,
              "followingCount": 10,
              "likesCount": 0
            }
          }
        }''',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final apiService = ApiService(client: mockClient);

    await tester.pumpWidget(
      MaterialApp(
        home: OtherUserProfileScreen(
          userId: 'user-empty-recipes',
          apiService: apiService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify empty state is displayed in Vietnamese
    expect(find.text('Người dùng chưa chia sẻ'), findsOneWidget);
    expect(find.text('Người dùng này chưa đăng tải bất kỳ công thức hay video nấu ăn nào.'), findsOneWidget);
    expect(find.byIcon(Iconsax.video_slash), findsOneWidget);

    // Switch language to English and verify empty state updates reactively
    ApiI18n.currentLanguage = ApiI18n.en;
    await tester.pumpAndSettle();

    expect(find.text('User has not shared yet'), findsOneWidget);
    expect(find.text('This user has not posted any recipes or cooking videos yet.'), findsOneWidget);

    // Reset back to Vietnamese
    ApiI18n.currentLanguage = ApiI18n.vi;
    await tester.pumpAndSettle();

    // Verify grid view is NOT present
    expect(find.byType(SliverGrid), findsNothing);
  });
}
