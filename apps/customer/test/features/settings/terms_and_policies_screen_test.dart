import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/settings/presentation/pages/terms/policy_detail_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/terms/terms_and_policies_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/terms/terms_data.dart';

void main() {
  setUp(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  tearDown(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  testWidgets('TermsAndPoliciesScreen renders AppBar and all sections properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: TermsAndPoliciesScreen(),
      ),
    );

    // Verify AppBar header
    expect(find.text('Điều khoản và Chính sách'), findsOneWidget);

    // Verify Section headers
    expect(find.text('Điều khoản & Thỏa thuận pháp lý'), findsOneWidget);
    expect(find.text('An toàn & Tiêu chuẩn cộng đồng'), findsOneWidget);
    expect(find.text('Pháp lý bổ sung & Mã nguồn'), findsOneWidget);

    // Verify Legal items
    expect(find.text('Điều khoản Dịch vụ'), findsOneWidget);
    expect(find.text('Chính sách Quyền riêng tư'), findsOneWidget);
    expect(find.text('Chính sách Bản quyền & Sở hữu trí tuệ'), findsOneWidget);

    // Verify Community items
    expect(find.text('Tiêu chuẩn Cộng đồng Ẩm thực'), findsOneWidget);
    expect(find.text('Miễn trừ trách nhiệm về Ẩm thực & Sức khỏe'), findsOneWidget);
    expect(find.text('Chính sách Cookie & Công nghệ theo dõi'), findsOneWidget);

    // Verify Other items
    expect(find.text('Giấy phép Phần mềm Mã nguồn Mở'), findsOneWidget);
    expect(find.text('Liên hệ Pháp lý & Hỗ trợ'), findsOneWidget);

    // Verify footer note
    expect(find.textContaining('Bằng việc sử dụng CookConnect'), findsOneWidget);
  });

  testWidgets('Tapping on a policy item navigates to PolicyDetailScreen and back', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: TermsAndPoliciesScreen(),
      ),
    );

    // Tap on Điều khoản Dịch vụ
    final termsItem = find.text('Điều khoản Dịch vụ');
    expect(termsItem, findsOneWidget);
    await tester.tap(termsItem);
    await tester.pumpAndSettle();

    // Verify PolicyDetailScreen is opened
    expect(find.byType(PolicyDetailScreen), findsOneWidget);
    expect(find.text('Tóm tắt nhanh'), findsOneWidget);
    expect(find.text('1. Chấp thuận Điều khoản'), findsOneWidget);

    // Tap back button
    final backButton = find.byType(IconButton).first;
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Verify back to TermsAndPoliciesScreen
    expect(find.byType(TermsAndPoliciesScreen), findsOneWidget);
  });

  testWidgets('Tapping on Liên hệ Pháp lý opens modal bottom sheet with email copy option', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: TermsAndPoliciesScreen(),
      ),
    );

    final legalInquiryItem = find.text('Liên hệ Pháp lý & Hỗ trợ');
    expect(legalInquiryItem, findsOneWidget);
    await tester.tap(legalInquiryItem);
    await tester.pumpAndSettle();

    // Verify BottomSheet content
    expect(find.text(TermsData.legalEmail), findsOneWidget);
    expect(find.textContaining('CookConnect Legal Operations Team'), findsOneWidget);

    // Tap copy icon button
    final copyButton = find.widgetWithIcon(IconButton, Icons.copy);
    if (copyButton.evaluate().isNotEmpty) {
      await tester.tap(copyButton.first);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    }
  });

  testWidgets('TermsAndPoliciesScreen updates language when ApiI18n language changes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: TermsAndPoliciesScreen(),
      ),
    );

    expect(find.text('Điều khoản và Chính sách'), findsOneWidget);
    expect(find.text('Điều khoản Dịch vụ'), findsOneWidget);

    // Switch to English
    ApiI18n.currentLanguage = ApiI18n.en;
    await tester.pumpAndSettle();

    expect(find.text('Terms & Policies'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Legal Terms & Agreements'), findsOneWidget);

    // Switch back to Vietnamese
    ApiI18n.currentLanguage = ApiI18n.vi;
    await tester.pumpAndSettle();

    expect(find.text('Điều khoản và Chính sách'), findsOneWidget);
  });
}
