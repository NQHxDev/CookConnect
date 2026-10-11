import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/profile/presentation/pages/profile_screen.dart';

void main() {
  setUp(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
    AuthService.instance.logout(callServer: false);
  });

  tearDown(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
    AuthService.instance.logout(callServer: false);
  });

  testWidgets('Unauthenticated ProfileScreen dynamically updates labels when language changes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Default Vietnamese labels
    expect(find.text('Cá nhân'), findsOneWidget);
    expect(find.text('Tham gia CookConnect'), findsOneWidget);
    expect(find.text('Đặc quyền khi có tài khoản'), findsOneWidget);
    expect(find.text('Đăng nhập / Đăng ký ngay'), findsOneWidget);
    expect(find.text('Tài khoản & Hoạt động'), findsOneWidget);
    expect(find.text('Món ăn đã lưu'), findsOneWidget);

    // Switch language to English
    ApiI18n.currentLanguage = ApiI18n.en;
    await tester.pumpAndSettle();

    // English labels
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Join CookConnect'), findsOneWidget);
    expect(find.text('Member benefits'), findsOneWidget);
    expect(find.text('Log in / Register now'), findsOneWidget);
    expect(find.text('Account & Activity'), findsOneWidget);
    expect(find.text('Saved recipes'), findsOneWidget);

    // Switch back to Vietnamese
    ApiI18n.currentLanguage = ApiI18n.vi;
    await tester.pumpAndSettle();

    expect(find.text('Cá nhân'), findsOneWidget);
    expect(find.text('Tham gia CookConnect'), findsOneWidget);
  });

  testWidgets('Authenticated ProfileScreen dynamically updates stats and side menu on language change', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AuthService.instance.setGuestDemo(name: 'Chef Linh Đan', email: 'linhdan@cookconnect.app');

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Default Vietnamese labels
    expect(find.text('Công thức'), findsOneWidget);
    expect(find.text('Follower'), findsOneWidget);
    expect(find.text('Thích'), findsOneWidget);

    // Open side drawer menu
    final menuButton = find.byTooltip('Menu');
    expect(menuButton, findsOneWidget);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    expect(find.text('Công cụ cá nhân'), findsOneWidget);
    expect(find.text('Trung tâm hoạt động'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);
    expect(find.text('Cài đặt và quyền riêng tư'), findsOneWidget);

    // Switch language to English while menu is open
    ApiI18n.currentLanguage = ApiI18n.en;
    await tester.pumpAndSettle();

    // English labels in menu
    expect(find.text('Personal tools'), findsOneWidget);
    expect(find.text('Activity Center'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Settings and privacy'), findsOneWidget);

    // Close menu
    await tester.tapAt(const Offset(20, 300));
    await tester.pumpAndSettle();

    // Verify stats in English
    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Followers'), findsOneWidget);
    expect(find.text('Likes'), findsOneWidget);
  });
}
