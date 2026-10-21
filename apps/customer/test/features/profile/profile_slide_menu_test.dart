import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/main/presentation/pages/main_screen.dart';
import 'package:cookconnect/features/profile/presentation/pages/profile_screen.dart';

void main() {
  setUp(() {
    AuthService.instance.logout();
  });

  tearDown(() {
    AuthService.instance.logout();
  });

  testWidgets('Guest (unauthenticated) ProfileScreen does not display hamburger menu or person icon in header', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );

    // Guest header: title 'Cá nhân' is displayed
    expect(find.text('Cá nhân'), findsOneWidget);

    // Icons must NOT be present in header when not logged in
    expect(find.byTooltip('Menu'), findsNothing);
    expect(find.byIcon(Icons.menu_rounded), findsNothing);
    expect(find.byTooltip('Tìm bạn bè'), findsNothing);
    expect(find.byIcon(Iconsax.user_add), findsNothing);
    expect(find.byTooltip('Sửa thông tin'), findsNothing);
    expect(find.byIcon(Iconsax.edit_2), findsNothing);
  });

  testWidgets('ProfileScreen 8/2 slide menu renders section titles and handles slide actions when logged in', (tester) async {
    AuthService.instance.setGuestDemo(name: 'Test User', email: 'test@example.com');

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );

    // Initial state: menu is closed
    expect(find.text('Công cụ cá nhân'), findsNothing);
    expect(find.text('Cài đặt'), findsNothing);

    // Tap the menu icon (3-bar menu)
    final menuButtonFinder = find.byTooltip('Menu');
    expect(menuButtonFinder, findsOneWidget);
    await tester.tap(menuButtonFinder);
    await tester.pumpAndSettle();

    // Now options panel is open with section headers and items
    expect(find.text('Công cụ cá nhân'), findsOneWidget);
    expect(find.text('Trung tâm hoạt động'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);
    expect(find.text('Cài đặt và quyền riêng tư'), findsOneWidget);

    // Tap on the 20% left overlay area (e.g. at x = 20, y = 300) to close
    await tester.tapAt(const Offset(20, 300));
    await tester.pumpAndSettle();

    // Menu is closed
    expect(find.text('Công cụ cá nhân'), findsNothing);
  });

  testWidgets('MainScreen automatically closes profile options menu when switching to another tab', (tester) async {
    AuthService.instance.setGuestDemo(name: 'Test User', email: 'test@example.com');

    await tester.pumpWidget(
      const MaterialApp(
        home: MainScreen(),
      ),
    );

    // Switch to Profile Tab (index 4)
    final profileTabFinder = find.text('Cá nhân');
    expect(profileTabFinder, findsOneWidget);
    await tester.tap(profileTabFinder);
    await tester.pumpAndSettle();

    // Open options menu
    final menuButtonFinder = find.byTooltip('Menu');
    expect(menuButtonFinder, findsOneWidget);
    await tester.tap(menuButtonFinder);
    await tester.pumpAndSettle();

    // Menu is opened
    expect(find.text('Công cụ cá nhân'), findsOneWidget);

    // Tap Home Tab (Trang chủ)
    final homeTabFinder = find.text('Trang chủ');
    expect(homeTabFinder, findsOneWidget);
    await tester.tap(homeTabFinder);
    await tester.pumpAndSettle();

    // Now tap back to Profile Tab (Cá nhân)
    await tester.tap(profileTabFinder);
    await tester.pumpAndSettle();

    // Options menu must be closed when returning to Profile tab
    expect(find.text('Công cụ cá nhân'), findsNothing);
  });

  testWidgets('Logging out from ProfileScreen via SettingsScreen does not display SnackBar notification', (tester) async {
    AuthService.instance.setGuestDemo(name: 'Test User', email: 'test@example.com');

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );

    // Open options menu
    final menuButtonFinder = find.byTooltip('Menu');
    expect(menuButtonFinder, findsOneWidget);
    await tester.tap(menuButtonFinder);
    await tester.pumpAndSettle();

    // Tap Cài đặt và quyền riêng tư
    final settingsOption = find.text('Cài đặt và quyền riêng tư');
    expect(settingsOption, findsOneWidget);
    await tester.tap(settingsOption);
    await tester.pumpAndSettle();

    // In SettingsScreen, scroll to Đăng nhập section
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    // Tap Đăng xuất
    expect(find.text('Đăng xuất'), findsOneWidget);
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();

    // Returned to ProfileScreen: verify no SnackBar or message is shown
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Đã đăng xuất khỏi tài khoản.'), findsNothing);

    // Also verify header icons are removed upon logout
    expect(find.byTooltip('Menu'), findsNothing);
    expect(find.byIcon(Icons.menu_rounded), findsNothing);
    expect(find.byTooltip('Tìm bạn bè'), findsNothing);
    expect(find.byIcon(Iconsax.user_add), findsNothing);
  });
}
