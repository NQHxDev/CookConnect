import 'package:flutter/material.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/auth/data/models/auth_user.dart';
import 'package:cookconnect/features/auth/data/models/auth_tokens.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/chat/data/models/user_suggestion.dart';
import 'package:cookconnect/features/chat/data/services/chat_api_service.dart';
import 'package:cookconnect/features/chat/presentation/pages/chat_screen.dart';
import 'package:cookconnect/features/chat/presentation/pages/chat_detail_screen.dart';
import 'package:cookconnect/features/activity/presentation/pages/activity_screen.dart';
import 'package:cookconnect/features/notification/presentation/pages/system_notification_screen.dart';

class _MockChatApiService extends ChatApiService {
  final Future<List<UserSuggestion>> Function(int limit) onGetSuggestions;

  _MockChatApiService({required this.onGetSuggestions});

  @override
  Future<List<UserSuggestion>> getSuggestedUsers({
    required String accessToken,
    int limit = 10,
  }) {
    return onGetSuggestions(limit);
  }
}

void main() {
  testWidgets('ChatScreen renders header, stories list with "Tạo tin" and friends', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Verify leading icon (2 people with plus: group_add_outlined)
    expect(find.byIcon(Icons.group_add_outlined), findsOneWidget);

    // Verify title text 'Hộp thư'
    expect(find.text('Hộp thư'), findsOneWidget);

    // Verify search action icon
    expect(find.byIcon(Iconsax.search_normal_1), findsOneWidget);

    // Verify "Tạo tin" story item
    expect(find.text('Tạo tin'), findsOneWidget);

    // Verify stories
    expect(find.text('Chef Nam'), findsWidgets);
  });

  testWidgets('ChatScreen renders 3 direct messages and suggested accounts section with question mark modal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Verify 3 chat conversations
    expect(find.text('Chef Linh'), findsOneWidget);
    expect(find.text('Chef Nam'), findsWidgets);
    expect(find.text('Bếp Mẹ Làm'), findsWidgets);

    // Verify suggested accounts header and question mark icon
    expect(find.text('Tài khoản được đề xuất'), findsOneWidget);
    expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);

    // Tap question mark icon to show explanation modal
    await tester.tap(find.byIcon(Icons.help_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Đã hiểu'), findsOneWidget);
    expect(find.textContaining('Các tài khoản này được đề xuất dựa trên sở thích'), findsOneWidget);

    // Tap "Đã hiểu" to close modal
    await tester.tap(find.text('Đã hiểu'));
    await tester.pumpAndSettle();

    // Verify suggested account follow button toggle
    final followButtons = find.widgetWithText(ElevatedButton, 'Theo dõi');
    expect(followButtons, findsWidgets);

    await tester.ensureVisible(followButtons.first);
    await tester.pumpAndSettle();

    await tester.tap(followButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('Đang theo dõi'), findsOneWidget);
  });

  testWidgets('ChatScreen supports pull-to-refresh pushing content down', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Trigger pull down
    await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('ChatScreen navigates to ChatDetailScreen and allows sending a message', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Tap on Chef Linh conversation
    await tester.tap(find.text('Chef Linh'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatDetailScreen), findsOneWidget);
    expect(find.text('Chào bạn! Mình thấy công thức Bò Sốt Vang của bạn trên CookConnect ngon quá!'), findsOneWidget);

    // Send a message
    final inputField = find.widgetWithText(TextField, 'Nhắn tin...');
    expect(inputField, findsOneWidget);

    await tester.enterText(inputField, 'Chào bạn nha, chúc bạn nấu thành công!');
    await tester.tap(find.byIcon(Iconsax.send_1));
    await tester.pumpAndSettle();

    expect(find.text('Chào bạn nha, chúc bạn nấu thành công!'), findsOneWidget);
  });

  testWidgets('ChatScreen navigates to ActivityScreen and SystemNotificationScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Tap on Hoạt động mới
    await tester.tap(find.text('Hoạt động mới'));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityScreen), findsOneWidget);

    // Go back
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Tap on Thông báo hệ thống
    await tester.tap(find.text('Thông báo hệ thống'));
    await tester.pumpAndSettle();

    expect(find.byType(SystemNotificationScreen), findsOneWidget);
  });

  testWidgets('ChatScreen fetches real suggested users from API and supports infinite scroll', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Set authenticated user with access token
    AuthService.instance.setSession(
      user: AuthUser(
        id: 'test-user-1',
        email: 'tester@cookconnect.app',
        fullName: 'Test Chef',
      ),
      tokens: AuthTokens(
        accessToken: 'valid-test-access-token',
        refreshToken: 'valid-test-refresh-token',
      ),
    );

    int callCount = 0;
    final mockChatApiService = _MockChatApiService(
      onGetSuggestions: (limit) async {
        callCount++;
        if (callCount == 1) {
          return List.generate(
            10,
            (i) => UserSuggestion(
              id: 'api-user-$i',
              displayName: 'Chef Đề Xuất $i',
              username: 'chef_$i',
              reason: 'popular',
              followersCount: 100 + i,
              isFollowing: false,
            ),
          );
        } else {
          return List.generate(
            5,
            (i) => UserSuggestion(
              id: 'api-user-page2-$i',
              displayName: 'Chef Trang Hai $i',
              username: 'page2_$i',
              reason: 'mutual_friends',
              mutualCount: 2,
              isFollowing: false,
            ),
          );
        }
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChatScreen(chatApiService: mockChatApiService),
      ),
    );
    await tester.pumpAndSettle();

    // Verify first 10 items loaded
    expect(callCount, 1);
    expect(find.text('Chef Đề Xuất 0'), findsOneWidget);

    // Scroll down to trigger infinite scroll
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1500));
    await tester.pumpAndSettle();

    // Verify infinite scroll triggered page 2
    expect(callCount, 2);
    expect(find.text('Chef Trang Hai 0'), findsOneWidget);
  });

  testWidgets('ChatScreen reactively updates UI labels when language changes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Default Vietnamese labels
    expect(find.text('Hộp thư'), findsOneWidget);
    expect(find.text('Tạo tin'), findsOneWidget);
    expect(find.text('Hoạt động mới'), findsOneWidget);
    expect(find.text('Thông báo hệ thống'), findsOneWidget);
    expect(find.text('Tin nhắn'), findsOneWidget);
    expect(find.text('Tài khoản được đề xuất'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Theo dõi'), findsWidgets);

    // Switch language to English
    ApiI18n.currentLanguage = ApiI18n.en;
    await tester.pumpAndSettle();

    // English labels
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Create story'), findsOneWidget);
    expect(find.text('New activity'), findsOneWidget);
    expect(find.text('System notifications'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Suggested accounts'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Follow'), findsWidgets);

    // Open explanation modal in English
    await tester.tap(find.byIcon(Icons.help_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Understood'), findsOneWidget);
    expect(find.textContaining('These accounts are suggested based on your culinary interests'), findsOneWidget);

    await tester.tap(find.text('Understood'));
    await tester.pumpAndSettle();

    // Reset back to Vietnamese
    ApiI18n.currentLanguage = ApiI18n.vi;
    await tester.pumpAndSettle();

    expect(find.text('Hộp thư'), findsOneWidget);
    expect(find.text('Tạo tin'), findsOneWidget);
  });
}
