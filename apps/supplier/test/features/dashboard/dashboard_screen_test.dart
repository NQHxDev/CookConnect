import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';

void main() {
  setUp(() {
    SellerAuthService.instance.setDemoSession();
  });

  testWidgets('DashboardScreen renders operational UI elements and excludes sensitive revenue data',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Store Header & Status
    expect(find.text('Đại Siêu Thị Nguyên Liệu Tươi CookConnect'), findsOneWidget);
    expect(find.text('SUPP-DEMO-01'), findsOneWidget);
    expect(find.textContaining('Đang mở cửa'), findsOneWidget);

    // 2. Sensitive Money / Revenue check: Home screen MUST NEVER contain revenue figures
    expect(find.text('Doanh thu hôm nay'), findsNothing);
    expect(find.text('1.250.000 đ'), findsNothing);
    expect(find.textContaining('VNĐ'), findsNothing);
    expect(find.textContaining('Doanh thu'), findsNothing);

    // 3. Verify Action Center (To-Do list)
    expect(find.text('Việc cần xử lý'), findsOneWidget);
    expect(find.text('Chờ xác nhận'), findsOneWidget);
    expect(find.text('Chờ đóng gói'), findsOneWidget);
    expect(find.text('Đang giao'), findsOneWidget);
    expect(find.text('Khiếu nại/Trả'), findsOneWidget);

    // 4. Verify Performance Metrics
    expect(find.text('Hiệu suất hôm nay'), findsOneWidget);
    expect(find.text('Đơn hoàn thành'), findsOneWidget);
    expect(find.text('Thời gian chuẩn bị'), findsOneWidget);
    expect(find.text('Đánh giá gian hàng'), findsOneWidget);
    expect(find.text('Tỉ lệ phản hồi chat'), findsOneWidget);

    // 5. Verify Inventory Warning
    expect(find.text('Cảnh báo tồn kho trong ngày'), findsOneWidget);

    // 6. Verify Quick Tools Grid
    expect(find.text('Tiện ích quản lý'), findsOneWidget);
    expect(find.text('Thêm món'), findsOneWidget);
    expect(find.text('Thực đơn'), findsOneWidget);
    expect(find.text('Đơn hàng'), findsOneWidget);
    expect(find.text('Quảng cáo'), findsOneWidget);
    expect(find.text('Trò chuyện'), findsOneWidget);
    expect(find.text('Hồ sơ quán'), findsOneWidget);
    expect(find.text('Giao hàng'), findsOneWidget);
    expect(find.text('Kho hàng'), findsOneWidget);

    // 7. Verify Seller Guides
    expect(find.text('Cẩm nang nhà bán hàng'), findsOneWidget);

    // 8. Test Open/Close store toggle
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    expect(find.textContaining('Tạm ngưng nhận đơn'), findsOneWidget);
  });
}
