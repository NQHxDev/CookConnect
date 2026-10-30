import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/order/data/models/order_model.dart';
import 'package:cookconnect/features/order/presentation/widgets/order_live_tracking_map.dart';

void main() {
  Widget buildTestWidget(OrderDto order) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: OrderLiveTrackingMap(
            order: order,
            height: 240,
          ),
        ),
      ),
    );
  }

  testWidgets('OrderLiveTrackingMap renders properly with shipping status',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final shippingOrder = OrderDto(
      id: 'ord-test-live-map',
      orderNumber: 'ORD-LIVE-001',
      subtotal: 100000,
      totalAmount: 120000,
      orderStatus: 'SHIPPING',
      paymentMethod: 'COD',
      paymentStatus: 'PENDING',
      shippingAddress: '123 Lê Lợi, Quận 1, TP.HCM',
      receiverName: 'Trần Văn A',
      receiverPhone: '0901234567',
    );

    await tester.pumpWidget(buildTestWidget(shippingOrder));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify map and core UI components
    expect(find.byType(FlutterMap), findsOneWidget);

    // Verify ETA banner texts for shipping order
    expect(find.text('Tài xế đang giao hàng đến bạn'), findsOneWidget);
    expect(find.textContaining('Dự kiến: 10 - 15 phút'), findsOneWidget);

    // Verify action buttons
    expect(find.byTooltip('Căn giữa lộ trình'), findsOneWidget);
    expect(find.byTooltip('Xem toàn màn hình'), findsOneWidget);
  });

  testWidgets('OrderLiveTrackingMap renders properly when order is preparing',
      (WidgetTester tester) async {
    final pendingOrder = OrderDto(
      id: 'ord-test-pending',
      orderNumber: 'ORD-PEND-002',
      subtotal: 50000,
      totalAmount: 50000,
      orderStatus: 'PROCESSING',
      paymentMethod: 'MOMO',
      paymentStatus: 'SUCCESS',
      shippingAddress: '456 Pasteur, Quận 3, TP.HCM',
      receiverName: 'Nguyễn Thị B',
      receiverPhone: '0909888999',
    );

    await tester.pumpWidget(buildTestWidget(pendingOrder));
    await tester.pump();

    // Verify ETA banner texts for preparing order
    expect(find.text('Quán đang hoàn tất đóng gói món'), findsOneWidget);
    expect(
      find.text('Shipper sẽ nhận hàng ngay khi quán chuẩn bị xong'),
      findsOneWidget,
    );
  });
}
