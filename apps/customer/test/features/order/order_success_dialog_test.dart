import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/order/data/models/order_model.dart';
import 'package:cookconnect/features/order/presentation/widgets/order_success_dialog.dart';

void main() {
  testWidgets('OrderSuccessDialog renders complete order info and interacts properly',
      (WidgetTester tester) async {
    final testOrder = OrderDto(
      id: 'ord-8888',
      orderNumber: 'CC-ORD-20261030',
      subtotal: 250000,
      shippingFee: 20000,
      totalAmount: 270000,
      orderStatus: 'PENDING',
      paymentMethod: 'COD',
      paymentStatus: 'UNPAID',
      shippingAddress: '456 Lê Lợi, P. Bến Nghé, Quận 1, TP.HCM',
      receiverName: 'Trần Thị Mai',
      receiverPhone: '0987654321',
      items: [
        OrderItemDto(
          id: 'item-1',
          productId: 'prod-1',
          productName: 'Cà rốt Đà Lạt',
          quantity: 2,
          unitPrice: 25000,
          totalPrice: 50000,
        ),
        OrderItemDto(
          id: 'item-2',
          productId: 'prod-2',
          productName: 'Sườn non heo sạch',
          quantity: 1,
          unitPrice: 200000,
          totalPrice: 200000,
        ),
      ],
      createdAt: DateTime(2026, 10, 30, 14, 30),
    );

    bool primaryActionCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    OrderSuccessDialog.show(
                      context,
                      testOrder,
                      onPrimaryAction: () {
                        primaryActionCalled = true;
                      },
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text('Đặt hàng thành công!'), findsOneWidget);
    expect(
      find.text('Đơn hàng đã được chuyển tới người bán để chuẩn bị nguyên liệu tươi ngon nhất.'),
      findsOneWidget,
    );

    // Verify Order Number
    expect(find.text('MÃ ĐƠN HÀNG'), findsOneWidget);
    expect(find.text('CC-ORD-20261030'), findsOneWidget);
    expect(find.text('Sao chép'), findsOneWidget);

    // Verify Status & Time
    expect(find.text('Chờ xác nhận'), findsOneWidget);
    expect(find.text('14:30, 30/10/2026'), findsOneWidget);

    // Verify Payment Method
    expect(find.text('Tiền mặt khi nhận hàng (COD)'), findsOneWidget);

    // Verify Recipient & Address
    expect(find.text('Trần Thị Mai • 0987654321'), findsOneWidget);
    expect(find.text('456 Lê Lợi, P. Bến Nghé, Quận 1, TP.HCM'), findsOneWidget);

    // Verify Items count
    expect(find.text('2 nguyên liệu'), findsOneWidget);

    // Verify Total Amount
    expect(find.text('Tổng thanh toán:'), findsOneWidget);
    expect(find.text('270.000 đ'), findsOneWidget);

    // Verify Trust Banner
    expect(
      find.text('CookConnect cam kết nguyên liệu tươi sạch và hỗ trợ cập nhật hành trình nhanh chóng.'),
      findsOneWidget,
    );

    // Tap copy order number
    await tester.tap(find.text('Sao chép'));
    await tester.pump();
    expect(find.text('Đã chép'), findsOneWidget);

    // Scroll to primary button if needed and tap "Về danh sách đi chợ"
    await tester.ensureVisible(find.text('Về danh sách đi chợ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Về danh sách đi chợ'));
    await tester.pumpAndSettle();

    expect(primaryActionCalled, isTrue);
    expect(find.text('Đặt hàng thành công!'), findsNothing);
  });
}
