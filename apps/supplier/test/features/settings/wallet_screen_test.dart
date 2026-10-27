import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/wallet/wallet_screen.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';

void main() {
  setUp(() {
    SellerAuthService.instance.setDemoSession();
  });

  testWidgets('WalletScreen renders wallet details, revenue reporting, and withdraw workflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: WalletScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify AppBar and Title
    expect(find.text('Ví & Doanh thu'), findsOneWidget);

    // 2. Verify Wallet Balance Card
    expect(find.text('Ví CookConnect Seller'), findsOneWidget);
    expect(find.text('Số dư khả dụng để rút'), findsOneWidget);
    expect(find.text('24.850.000 đ'), findsOneWidget);
    expect(find.text('Đang chờ quyết toán:'), findsOneWidget);
    expect(find.text('3.450.000 đ'), findsOneWidget);

    // 3. Test Privacy Eye Toggle (Hide/Show balance)
    final eyeButton = find.byTooltip('Ẩn/hiện số tiền');
    expect(eyeButton, findsOneWidget);
    await tester.tap(eyeButton);
    await tester.pumpAndSettle();

    // Should now be masked
    expect(find.text('•••••••• đ'), findsWidgets);
    expect(find.text('24.850.000 đ'), findsNothing);

    // Toggle back
    await tester.tap(eyeButton);
    await tester.pumpAndSettle();
    expect(find.text('24.850.000 đ'), findsOneWidget);

    // 4. Verify Revenue Report Section
    expect(find.text('Báo cáo Doanh thu'), findsOneWidget);
    expect(find.text('Hôm nay'), findsOneWidget);
    expect(find.text('7 ngày qua'), findsOneWidget);
    expect(find.text('Tháng này'), findsOneWidget);
    expect(find.text('Đơn hoàn thành'), findsOneWidget);
    expect(find.text('Giá trị TB/đơn'), findsOneWidget);
    expect(find.text('Phí sàn'), findsOneWidget);

    // Switch revenue period tab to '7 ngày qua'
    await tester.tap(find.text('7 ngày qua'));
    await tester.pumpAndSettle();
    expect(find.text('14.820.000 đ'), findsOneWidget);

    // 5. Verify Linked Bank Account Card
    expect(find.text('Tài khoản nhận tiền'), findsOneWidget);
    expect(find.text('Vietcombank'), findsOneWidget);

    // 6. Verify Transaction History
    expect(find.text('Lịch sử dòng tiền'), findsOneWidget);
    expect(find.textContaining('Quyết toán đơn hàng #CC-90214'), findsOneWidget);

    // 7. Test Withdraw Button & BottomSheet
    final withdrawButton = find.text('Rút tiền về ngân hàng');
    expect(withdrawButton, findsOneWidget);
    await tester.tap(withdrawButton);
    await tester.pumpAndSettle();

    expect(find.text('Rút tiền về tài khoản ngân hàng'), findsOneWidget);
    expect(find.text('Xác nhận rút tiền'), findsOneWidget);

    // Confirm withdraw
    await tester.tap(find.text('Xác nhận rút tiền'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
