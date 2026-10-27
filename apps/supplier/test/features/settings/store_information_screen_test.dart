import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/store/store_information_screen.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';

void main() {
  setUp(() {
    SellerAuthService.instance.setDemoSession();
  });

  testWidgets('StoreInformationScreen renders all store UI elements and sections correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: StoreInformationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AppBar
    expect(find.text('Thông tin cửa hàng'), findsWidgets);

    // Verify Section Headers
    expect(find.text('Thông tin thương hiệu & Định danh'), findsOneWidget);
    expect(find.text('Liên hệ & Địa chỉ kinh doanh'), findsOneWidget);
    expect(find.text('Vận hành & Giờ hoạt động'), findsOneWidget);
    expect(find.text('Đại diện & Pháp lý gian hàng'), findsOneWidget);

    // Verify Store Information Items
    expect(find.text('Tên gian hàng'), findsOneWidget);
    expect(find.text('Mã nhà cung cấp'), findsOneWidget);
    expect(find.text('Đường dẫn gian hàng'), findsOneWidget);
    expect(find.text('Lĩnh vực cung cấp'), findsOneWidget);
    expect(find.text('Giới thiệu gian hàng'), findsOneWidget);

    // Verify Contact Items
    expect(find.text('Hotline / Số điện thoại'), findsOneWidget);
    expect(find.text('Email đối tác'), findsOneWidget);
    expect(find.text('Tỉnh / Thành phố'), findsOneWidget);
    expect(find.text('Địa chỉ kho / Trụ sở'), findsOneWidget);

    // Verify Operation Items
    expect(find.text('Trạng thái nhận đơn hàng'), findsOneWidget);
    expect(find.text('Giờ mở cửa hàng ngày'), findsOneWidget);
    expect(find.text('Chế độ nghỉ lễ'), findsOneWidget);

    // Verify Legal & Representative Items
    expect(find.text('Người đại diện pháp lý'), findsOneWidget);
    expect(find.text('Xác thực nhà cung cấp'), findsOneWidget);

    // Test editing Store Name dialog
    await tester.tap(find.text('Tên gian hàng'));
    await tester.pumpAndSettle();
    expect(find.text('Đổi tên gian hàng'), findsOneWidget);

    // Cancel edit dialog
    await tester.tap(find.text('Huỷ'));
    await tester.pumpAndSettle();
    expect(find.text('Đổi tên gian hàng'), findsNothing);

    // Test Preview Store Sheet
    await tester.tap(find.text('Xem trước'));
    await tester.pumpAndSettle();
    expect(find.text('Xem trước giao diện khách hàng'), findsOneWidget);

    // Close preview
    await tester.tap(find.text('Sao chép liên kết gian hàng'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
