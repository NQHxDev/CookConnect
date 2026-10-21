import 'package:cookconnect/features/settings/presentation/pages/help/help_center_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/terms/terms_and_policies_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/settings/presentation/pages/language/language_selection_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/settings_screen.dart';

void main() {
  setUp(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  tearDown(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  testWidgets(
    'SettingsScreen renders header, all 8 sections, and handles logout option when logged in',
    (WidgetTester tester) async {
      bool loggedOut = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            isLoggedIn: true,
            onLogoutRequested: () {
              loggedOut = true;
            },
          ),
        ),
      );

      // Verify AppBar header title exists
      expect(find.text('Cài đặt & Quyền riêng tư'), findsOneWidget);

      // Verify back button exists
      expect(find.byType(IconButton), findsOneWidget);

      // Verify 'Hoạt động' header and options exist
      expect(find.text('Hoạt động'), findsOneWidget);
      expect(find.text('Quản lý bài đăng'), findsOneWidget);
      expect(find.text('Tùy chọn nội dung'), findsOneWidget);
      expect(find.text('Thông báo'), findsOneWidget);
      expect(find.text('Thời gian sử dụng'), findsOneWidget);
      expect(find.text('Gia đình'), findsOneWidget);

      // Verify 'Tài khoản' header and options exist
      expect(find.text('Tài khoản'), findsNWidgets(2)); // Header + Option item
      expect(find.text('Bảo mật & Quyền'), findsOneWidget);
      expect(find.text('Chia sẻ hồ sơ'), findsOneWidget);

      // Scroll down to Cài đặt hiển thị
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify 'Cài đặt hiển thị' header and options exist
      expect(find.text('Cài đặt hiển thị'), findsOneWidget);
      expect(find.text('Tài khoản riêng tư'), findsOneWidget);
      expect(find.text('Tài khoản hạn chế'), findsOneWidget);
      expect(find.text('Tài khoản bị chặn'), findsOneWidget);

      // Scroll down to Tương tác
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify 'Tương tác' header and options exist
      expect(find.text('Tương tác'), findsOneWidget);
      expect(find.text('Bình luận'), findsOneWidget);
      expect(find.text('Nhắc đến'), findsOneWidget);
      expect(find.text('Tin nhắn trực tiếp'), findsOneWidget);
      expect(find.text('Tải về'), findsOneWidget);
      expect(find.text('Người xem'), findsOneWidget);

      // Scroll down to Tùy chọn
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();

      // Verify 'Tùy chọn' header and options exist
      expect(find.text('Tùy chọn'), findsOneWidget);
      expect(find.text('Kiểm soát khán giả'), findsOneWidget);
      expect(find.text('Quảng cáo'), findsOneWidget);
      expect(find.text('Phát video'), findsOneWidget);
      expect(find.text('Ngôn ngữ'), findsOneWidget);
      expect(find.text('Hiển thị'), findsOneWidget);
      expect(find.text('Trợ năng'), findsOneWidget);

      // Scroll down to Bộ nhớ đệm & Dữ liệu di động
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();

      // Verify 'Bộ nhớ đệm & Dữ liệu di động' header and options exist
      expect(find.text('Bộ nhớ đệm & Dữ liệu di động'), findsOneWidget);
      expect(find.text('Video ngoại tuyến'), findsOneWidget);
      expect(find.text('Giải phóng dung lượng'), findsOneWidget);
      expect(find.text('Trình tiết kiệm dữ liệu'), findsOneWidget);

      // Scroll down to Hỗ trợ & Chính sách
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();

      // Verify 'Hỗ trợ & Chính sách' header and options exist
      expect(find.text('Hỗ trợ & Chính sách'), findsOneWidget);
      expect(find.text('Trung tâm Trợ giúp'), findsOneWidget);
      expect(find.text('Trung tâm Quyền riêng tư'), findsOneWidget);
      expect(find.text('Điều khoản và Chính sách'), findsOneWidget);

      // Scroll down to Đăng nhập
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();

      // Verify 'Đăng nhập' header and options exist
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.text('Chuyển đổi tài khoản'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);

      // Tap 'Đăng xuất' option
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();

      expect(loggedOut, isTrue);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Đã đăng xuất khỏi tài khoản.'), findsNothing);
    },
  );

  testWidgets(
    'Tapping Tài khoản item navigates to AccountScreen when logged in',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SettingsScreen(isLoggedIn: true)),
      );

      // Find the Tài khoản item in the list
      final accountItemFinder = find.widgetWithText(InkWell, 'Tài khoản');
      expect(accountItemFinder, findsOneWidget);

      await tester.tap(accountItemFinder);
      await tester.pumpAndSettle();

      // Verify AccountScreen is displayed
      expect(find.text('Tài khoản'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Verify back to SettingsScreen
      expect(find.byType(SettingsScreen), findsOneWidget);
    },
  );

  testWidgets(
    'When not logged in, account-bound options are inactive and non-clickable',
    (WidgetTester tester) async {
      bool loggedOut = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            isLoggedIn: false,
            onLogoutRequested: () {
              loggedOut = true;
            },
          ),
        ),
      );

      // Tapping 'Tài khoản' item should be inactive and not navigate
      final accountItemFinder = find.widgetWithText(InkWell, 'Tài khoản');
      expect(accountItemFinder, findsOneWidget);
      await tester.tap(accountItemFinder);
      await tester.pumpAndSettle();

      // Verify we did NOT navigate to AccountScreen (SettingsScreen title still present)
      expect(find.text('Cài đặt & Quyền riêng tư'), findsOneWidget);
      expect(find.text('Hoạt động'), findsOneWidget);

      // Scroll down to Đăng xuất
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      // Tapping 'Đăng xuất' should be inactive and not trigger onLogoutRequested
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(loggedOut, isFalse);

      // Scroll to 'Ngôn ngữ' and ensure visible
      final languageItemFinder = find.widgetWithText(InkWell, 'Ngôn ngữ');
      await tester.drag(find.byType(ListView), const Offset(0, 600));
      await tester.pumpAndSettle();
      await tester.ensureVisible(languageItemFinder);
      await tester.pumpAndSettle();

      // Tapping 'Ngôn ngữ' (active for guests) should navigate to LanguageSelectionScreen
      expect(languageItemFinder, findsOneWidget);
      await tester.tap(languageItemFinder);
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectionScreen), findsOneWidget);
    },
  );

  testWidgets(
    'SettingsScreen dynamically updates all section titles and items on language change',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SettingsScreen(isLoggedIn: true)),
      );

      // Initial Vietnamese titles
      expect(find.text('Cài đặt & Quyền riêng tư'), findsOneWidget);
      expect(find.text('Hoạt động'), findsOneWidget);
      expect(find.text('Quản lý bài đăng'), findsOneWidget);

      // Switch to English
      ApiI18n.currentLanguage = ApiI18n.en;
      await tester.pumpAndSettle();

      // Verify English titles
      expect(find.text('Settings & Privacy'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Manage posts'), findsOneWidget);

      // Scroll to check other sections in English
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(find.text('Display settings'), findsOneWidget);
      expect(find.text('Private account'), findsOneWidget);

      // Switch back to Vietnamese
      ApiI18n.currentLanguage = ApiI18n.vi;
      await tester.pumpAndSettle();

      expect(find.text('Cài đặt & Quyền riêng tư'), findsOneWidget);

      // Scroll back up
      await tester.drag(find.byType(ListView), const Offset(0, 350));
      await tester.pumpAndSettle();

      expect(find.text('Hoạt động'), findsOneWidget);
      expect(find.text('Quản lý bài đăng'), findsOneWidget);
    },
  );

  testWidgets(
    'Tapping Điều khoản và Chính sách navigates to TermsAndPoliciesScreen',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: SettingsScreen(isLoggedIn: true)),
      );

      // Scroll to find 'Điều khoản và Chính sách'
      final termsItem = find.widgetWithText(
        InkWell,
        'Điều khoản và Chính sách',
      );
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.ensureVisible(termsItem);
      await tester.pumpAndSettle();

      expect(termsItem, findsOneWidget);
      await tester.tap(termsItem);
      await tester.pumpAndSettle();

      // Verify TermsAndPoliciesScreen is displayed
      expect(find.byType(TermsAndPoliciesScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    },
  );

  testWidgets('Tapping Trung tâm Trợ giúp navigates to HelpCenterScreen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: SettingsScreen(isLoggedIn: true)),
    );

    // Scroll to find 'Trung tâm Trợ giúp'
    final helpItem = find.widgetWithText(InkWell, 'Trung tâm Trợ giúp');
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.ensureVisible(helpItem);
    await tester.pumpAndSettle();

    expect(helpItem, findsOneWidget);
    await tester.tap(helpItem);
    await tester.pumpAndSettle();

    // Verify HelpCenterScreen is displayed
    expect(find.byType(HelpCenterScreen), findsOneWidget);

    // Tap back button
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
