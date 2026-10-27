import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/account/account_information_screen.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';

void main() {
  setUp(() {
    SellerAuthService.instance.setDemoSession();
  });

  testWidgets('AccountInformationScreen renders unified UI elements and details correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: AccountInformationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AppBar
    expect(find.text('Thông tin tài khoản'), findsWidgets);

    // Verify Section Headers
    expect(find.text('Thông tin tài khoản'), findsWidgets);
    expect(find.text('Định danh & Quyền hạn'), findsOneWidget);

    // Verify Account Information Items
    expect(find.text('Họ và tên'), findsOneWidget);
    expect(find.text('Số điện thoại'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Ngày sinh'), findsNothing);
    expect(find.text('Giới tính'), findsNothing);

    // Verify Identity & Roles
    expect(find.text('Mã tài khoản'), findsOneWidget);
    expect(find.text('Gian hàng liên kết'), findsOneWidget);
    expect(find.text('Vai trò tài khoản'), findsOneWidget);
    expect(find.text('Trạng thái tài khoản'), findsOneWidget);
    expect(find.text('Đang hoạt động'), findsOneWidget);

    // Test editing full name dialog
    await tester.tap(find.text('Họ và tên'));
    await tester.pumpAndSettle();
    expect(find.text('Đổi tên chủ tài khoản'), findsOneWidget);

    // Cancel edit dialog
    await tester.tap(find.text('Huỷ'));
    await tester.pumpAndSettle();
    expect(find.text('Đổi tên chủ tài khoản'), findsNothing);

    // Test copying account ID
    await tester.tap(find.text('Mã tài khoản'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
