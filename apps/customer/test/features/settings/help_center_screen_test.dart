import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/settings/presentation/pages/help/help_center_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/settings_screen.dart';

void main() {
  setUp(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  tearDown(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  group('HelpCenterScreen', () {
    testWidgets('renders AppBar with back button and centered title', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: HelpCenterScreen()));

      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);

      final appBar = tester.widget<AppBar>(appBarFinder);
      expect(appBar.centerTitle, isTrue);

      expect(find.text('Trung tâm Trợ giúp'), findsOneWidget);
      expect(find.byIcon(Iconsax.arrow_left), findsOneWidget);
    });

    testWidgets('renders hero banner, search bar, and topics', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: HelpCenterScreen()));

      // Hero banner
      expect(find.text('Chúng tôi có thể giúp gì cho bạn?'), findsOneWidget);

      // Search bar
      expect(find.byType(TextField), findsOneWidget);

      // Topics section
      expect(find.text('Chủ đề trợ giúp'), findsOneWidget);
      expect(find.text('Công thức & Bài viết'), findsOneWidget);
      expect(find.text('Tài khoản & Đăng nhập'), findsOneWidget);
      expect(find.text('Quyền riêng tư & An toàn'), findsOneWidget);
      expect(find.text('Tương tác & Cộng đồng'), findsOneWidget);
      expect(find.text('Sự cố kỹ thuật & Bộ nhớ'), findsOneWidget);
      expect(find.byIcon(Iconsax.shield_tick), findsOneWidget);
    });

    testWidgets('expands FAQ item when tapped and allows helpful voting', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: HelpCenterScreen()));

      // Find first FAQ item
      final questionFinder = find.text(
        'Làm thế nào để đăng tải công thức nấu ăn mới?',
      );
      expect(questionFinder, findsOneWidget);

      // Initially answer is not visible
      expect(
        find.textContaining('chạm vào biểu tượng dấu cộng (+)'),
        findsNothing,
      );

      // Tap question to expand
      await tester.tap(questionFinder);
      await tester.pumpAndSettle();

      // Answer should now be visible
      expect(
        find.textContaining('chạm vào biểu tượng dấu cộng (+)'),
        findsOneWidget,
      );
      expect(find.text('Câu trả lời này có hữu ích không?'), findsOneWidget);

      // Tap "Có" (Yes)
      await tester.tap(find.text('Có'));
      await tester.pumpAndSettle();

      // Verify thanks message
      expect(find.text('Cảm ơn phản hồi của bạn!'), findsOneWidget);
    });

    testWidgets('search filters FAQs and shows empty state when no match', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: HelpCenterScreen()));

      final searchField = find.byType(TextField);

      // Enter search query with matching keyword
      await tester.enterText(searchField, 'mật khẩu');
      await tester.pumpAndSettle();

      expect(
        find.text('Tôi quên mật khẩu tài khoản thì phải làm sao?'),
        findsOneWidget,
      );
      expect(
        find.text('Làm thế nào để đăng tải công thức nấu ăn mới?'),
        findsNothing,
      );

      // Enter search query with no match
      await tester.enterText(searchField, 'xyzunknownquery');
      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy kết quả'), findsOneWidget);
      expect(find.text('Xóa tìm kiếm'), findsOneWidget);

      // Tap clear search button
      await tester.tap(find.text('Xóa tìm kiếm'));
      await tester.pumpAndSettle();

      // FAQs are restored
      expect(
        find.text('Làm thế nào để đăng tải công thức nấu ăn mới?'),
        findsOneWidget,
      );
    });

    testWidgets('support actions show bottom sheet for reporting problem', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: HelpCenterScreen()));

      // Scroll to bottom
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Tap 'Báo cáo sự cố'
      await tester.tap(find.text('Báo cáo sự cố'));
      await tester.pumpAndSettle();

      // Modal bottom sheet should appear
      expect(find.text('Gửi báo cáo'), findsNothing); // Button is 'Gửi'
      expect(find.text('Gửi'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.byType(HelpCenterScreen), findsOneWidget);
    });

    testWidgets('HelpCenterScreen updates dynamically on language switch', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: HelpCenterScreen()));

      expect(find.text('Trung tâm Trợ giúp'), findsOneWidget);
      expect(find.text('Chủ đề trợ giúp'), findsOneWidget);

      // Switch to English
      ApiI18n.currentLanguage = ApiI18n.en;
      await tester.pumpAndSettle();

      expect(find.text('Help Center'), findsOneWidget);
      expect(find.text('Help topics'), findsOneWidget);
      expect(find.text('Recipes & Posts'), findsOneWidget);
      expect(find.text('How can we help you?'), findsOneWidget);
      expect(find.text('Privacy & Safety'), findsOneWidget);

      // Switch back to Vietnamese
      ApiI18n.currentLanguage = ApiI18n.vi;
      await tester.pumpAndSettle();

      expect(find.text('Trung tâm Trợ giúp'), findsOneWidget);
    });

    testWidgets(
      'Tapping Trung tâm Trợ giúp in SettingsScreen navigates to HelpCenterScreen',
      (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

        // Scroll down to Hỗ trợ & Chính sách
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pumpAndSettle();

        // Find Trung tâm Trợ giúp item
        final helpCenterItemFinder = find.widgetWithText(
          InkWell,
          'Trung tâm Trợ giúp',
        );
        expect(helpCenterItemFinder, findsOneWidget);

        // Tap on it
        await tester.tap(helpCenterItemFinder);
        await tester.pumpAndSettle();

        // Should be on HelpCenterScreen
        expect(find.byType(HelpCenterScreen), findsOneWidget);

        // Tap back button
        await tester.tap(find.byIcon(Iconsax.arrow_left));
        await tester.pumpAndSettle();

        // Should be back on SettingsScreen
        expect(find.byType(SettingsScreen), findsOneWidget);
      },
    );
  });
}
