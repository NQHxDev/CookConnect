import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/settings/presentation/pages/privacy/privacy_center_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/privacy/download_data_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/privacy/privacy_policy_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/settings_screen.dart';

void main() {
  setUp(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  tearDown(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  group('PrivacyCenterScreen', () {
    testWidgets('renders AppBar with back button and centered title', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyCenterScreen(),
        ),
      );

      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);

      final appBar = tester.widget<AppBar>(appBarFinder);
      expect(appBar.centerTitle, isTrue);

      expect(find.text('Trung tâm Quyền riêng tư'), findsOneWidget);
      expect(find.byIcon(Iconsax.arrow_left), findsOneWidget);
    });

    testWidgets('renders hero banner and all main section headers', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyCenterScreen(),
        ),
      );

      // Hero banner
      expect(find.text('Quyền kiểm soát dữ liệu của bạn'), findsOneWidget);
      expect(find.text('Bảo mật & Minh bạch'), findsOneWidget);

      // Section titles
      expect(find.text('Dữ liệu cá nhân & Tải xuống'), findsOneWidget);
      expect(find.text('Công thức & Nội dung ẩm thực'), findsOneWidget);
      expect(find.text('Khả năng hiển thị & Kết nối'), findsOneWidget);
    });

    testWidgets('navigates to DownloadDataScreen when item is tapped', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyCenterScreen(),
        ),
      );

      final downloadItem = find.text('Tải xuống dữ liệu của bạn');
      expect(downloadItem, findsOneWidget);

      await tester.tap(downloadItem);
      await tester.pumpAndSettle();

      expect(find.byType(DownloadDataScreen), findsOneWidget);
      expect(find.text('Bản sao lưu trữ dữ liệu cá nhân'), findsOneWidget);

      // Back to Privacy Center
      await tester.tap(find.byIcon(Iconsax.arrow_left));
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyCenterScreen), findsOneWidget);
    });

    testWidgets('opens audience bottom sheet and changes recipe privacy', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyCenterScreen(),
        ),
      );

      // Tap default recipe privacy
      final audienceTile = find.text('Quyền riêng tư công thức mặc định');
      expect(audienceTile, findsOneWidget);

      await tester.tap(audienceTile);
      await tester.pumpAndSettle();

      // Bottom sheet items appear
      expect(find.text('Chỉ mình tôi (Bí quyết riêng)'), findsOneWidget);

      // Select 'Chỉ mình tôi'
      await tester.tap(find.text('Chỉ mình tôi (Bí quyết riêng)'));
      await tester.pumpAndSettle();

      // Verify selected value is reflected on the screen
      expect(find.text('Chỉ mình tôi (Bí quyết riêng)'), findsOneWidget);
    });

    testWidgets('toggles switches smoothly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyCenterScreen(),
        ),
      );

      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      final firstSwitch = switches.first;
      final initialVal = tester.widget<Switch>(firstSwitch).value;

      await tester.tap(firstSwitch);
      await tester.pumpAndSettle();

      final updatedVal = tester.widget<Switch>(firstSwitch).value;
      expect(updatedVal, !initialVal);
    });

    testWidgets('navigates to PrivacyPolicyScreen when policy item is tapped', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyCenterScreen(),
        ),
      );

      // Scroll to bottom
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      final policyTile = find.text('Chính sách Quyền riêng tư CookConnect');
      expect(policyTile, findsOneWidget);

      await tester.tap(policyTile);
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);

      // Back
      await tester.tap(find.byIcon(Iconsax.arrow_left));
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyCenterScreen), findsOneWidget);
    });

    testWidgets('shows device permissions modal bottom sheet', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyCenterScreen(),
        ),
      );

      final permissionsTile = find.text('Quyền truy cập thiết bị');
      expect(permissionsTile, findsOneWidget);

      await tester.tap(permissionsTile);
      await tester.pumpAndSettle();

      expect(find.text('Quyền truy cập trên thiết bị'), findsOneWidget);
      expect(find.text('Máy ảnh (Camera)'), findsOneWidget);
      expect(find.text('Thư viện hình ảnh'), findsOneWidget);
    });

    testWidgets('updates dynamically on language switch', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyCenterScreen(),
        ),
      );

      expect(find.text('Trung tâm Quyền riêng tư'), findsOneWidget);
      expect(find.text('Dữ liệu cá nhân & Tải xuống'), findsOneWidget);

      // Switch to English
      ApiI18n.currentLanguage = ApiI18n.en;
      await tester.pumpAndSettle();

      expect(find.text('Privacy Center'), findsOneWidget);
      expect(find.text('Personal Data & Downloads'), findsOneWidget);

      // Switch back to Vietnamese
      ApiI18n.currentLanguage = ApiI18n.vi;
      await tester.pumpAndSettle();

      expect(find.text('Trung tâm Quyền riêng tư'), findsOneWidget);
    });

    testWidgets('navigates from SettingsScreen to PrivacyCenterScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Scroll to Hỗ trợ & Chính sách
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      final privacyItem = find.widgetWithText(InkWell, 'Trung tâm Quyền riêng tư');
      expect(privacyItem, findsOneWidget);

      await tester.tap(privacyItem);
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyCenterScreen), findsOneWidget);

      // Tap back
      await tester.tap(find.byIcon(Iconsax.arrow_left));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
