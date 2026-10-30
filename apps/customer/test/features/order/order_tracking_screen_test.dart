import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/order/data/models/order_model.dart';
import 'package:cookconnect/features/order/presentation/pages/order_tracking_screen.dart';

void main() {
  Widget buildTestWidget(OrderDto order) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: OrderTrackingScreen(
        orderId: order.id,
        initialOrder: order,
      ),
    );
  }

  testWidgets('OrderTrackingScreen renders shipping order details and timeline properly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final order = OrderDto(
      id: 'ord-12345',
      orderNumber: 'ORD-SHIP-999',
      subtotal: 100000,
      shippingFee: 20000,
      totalAmount: 120000,
      orderStatus: 'SHIPPING',
      paymentMethod: 'COD',
      paymentStatus: 'PENDING',
      shippingAddress: '789 Nguyễn Huệ, Quận 1, TP.HCM',
      receiverName: 'Lê Hoàng Nam',
      receiverPhone: '0912345678',
      note: 'Giao giờ hành chính',
      shipperTrackingCode: 'VNPOST-888999',
      items: [
        OrderItemDto(
          id: 'item-1',
          productId: 'p-1',
          productName: 'Ức gà phi lê tươi',
          quantity: 2,
          unitPrice: 50000,
          totalPrice: 100000,
        ),
      ],
      createdAt: DateTime(2026, 10, 30, 10, 0),
    );

    await tester.pumpWidget(buildTestWidget(order));
    await tester.pump();

    // Verify order title & number
    expect(find.text('Theo dõi đơn hàng'), findsOneWidget);
    expect(find.text('#ORD-SHIP-999'), findsOneWidget);

    // Verify status display
    expect(find.text('Đang giao hàng'), findsWidgets);
    expect(find.text(order.statusDescription), findsOneWidget);

    // Verify timeline steps
    expect(find.text('Hành trình đơn hàng'), findsOneWidget);
    expect(find.text('Đặt hàng'), findsOneWidget);
    expect(find.text('Xác nhận & Chuẩn bị'), findsOneWidget);
    expect(find.text('Hoàn thành'), findsOneWidget);

    // Verify shipping details & tracking code
    expect(find.text('Thông tin vận chuyển & Nhận hàng'), findsOneWidget);
    expect(find.text('Mã vận đơn: VNPOST-888999'), findsOneWidget);
    expect(find.text('Lê Hoàng Nam'), findsOneWidget);
    expect(find.text('789 Nguyễn Huệ, Quận 1, TP.HCM'), findsOneWidget);
    expect(find.text('Ghi chú: Giao giờ hành chính'), findsOneWidget);

    // Verify product item
    expect(find.text('Ức gà phi lê tươi'), findsOneWidget);
    expect(find.text('2 x 50.000 đ'), findsOneWidget);
    expect(find.text('100.000 đ'), findsWidgets);

    // Verify payment details
    expect(find.text('Chi tiết thanh toán'), findsOneWidget);
    expect(find.text('120.000 đ'), findsWidgets);
    expect(find.text('Tiền mặt khi nhận hàng (COD)'), findsOneWidget);

    // Verify bottom action buttons
    expect(find.text('Cần trợ giúp'), findsOneWidget);
    expect(find.text('Hủy đơn hàng'), findsNothing); // cannot cancel when shipping
  });

  testWidgets('OrderTrackingScreen shows cancel button when order is PENDING',
      (WidgetTester tester) async {
    final pendingOrder = OrderDto(
      id: 'ord-pending',
      orderNumber: 'ORD-PENDING-001',
      subtotal: 70000,
      shippingFee: 20000,
      totalAmount: 90000,
      orderStatus: 'PENDING',
      paymentMethod: 'COD',
      paymentStatus: 'PENDING',
      shippingAddress: '123 Đinh Tiên Hoàng, Q.1',
      receiverName: 'Nguyễn Văn B',
      receiverPhone: '0909000111',
      items: [
        OrderItemDto(
          id: 'item-2',
          productId: 'p-2',
          productName: 'Rau cải ngọt',
          quantity: 2,
          unitPrice: 35000,
          totalPrice: 70000,
        ),
      ],
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestWidget(pendingOrder));
    await tester.pump();

    // Verify cancellable order displays cancel button
    expect(find.text('Chờ xác nhận'), findsWidgets);
    expect(find.text('Hủy đơn hàng'), findsOneWidget);
  });

  testWidgets('OrderTrackingScreen shows reorder button when order is COMPLETED',
      (WidgetTester tester) async {
    final completedOrder = OrderDto(
      id: 'ord-done',
      orderNumber: 'ORD-DONE-001',
      subtotal: 50000,
      shippingFee: 0,
      totalAmount: 50000,
      orderStatus: 'COMPLETED',
      paymentMethod: 'MOMO',
      paymentStatus: 'SUCCESS',
      shippingAddress: '123 Đinh Tiên Hoàng, Q.1',
      receiverName: 'Nguyễn Văn B',
      receiverPhone: '0909000111',
      items: [
        OrderItemDto(
          id: 'item-3',
          productId: 'p-3',
          productName: 'Cà chua bi',
          quantity: 1,
          unitPrice: 50000,
          totalPrice: 50000,
        ),
      ],
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(buildTestWidget(completedOrder));
    await tester.pump();

    // Verify completed order displays reorder button
    expect(find.text('Hoàn thành'), findsWidgets);
    expect(find.text('Mua lại đơn này'), findsOneWidget);
  });
}
