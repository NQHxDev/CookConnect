import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/order/data/models/order_model.dart';
import 'package:cookconnect/features/order/presentation/pages/my_orders_screen.dart';
import 'package:cookconnect/features/order/presentation/widgets/customer_order_card.dart';

void main() {
  testWidgets('CustomerOrderCard renders order details properly',
      (WidgetTester tester) async {
    final order = OrderDto(
      id: 'ord-test-card',
      orderNumber: 'ORD-CARD-001',
      subtotal: 150000,
      shippingFee: 20000,
      totalAmount: 170000,
      orderStatus: 'PROCESSING',
      paymentMethod: 'COD',
      paymentStatus: 'PENDING',
      shippingAddress: '123 CMT8, Q.3',
      receiverName: 'Hoàng Nam',
      receiverPhone: '0901234567',
      items: [
        OrderItemDto(
          id: 'item-1',
          productId: 'p-1',
          productName: 'Cá hồi Na Uy phi lê',
          quantity: 1,
          unitPrice: 150000,
          totalPrice: 150000,
        ),
      ],
      createdAt: DateTime(2026, 10, 30, 12, 0),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: CustomerOrderCard(order: order),
        ),
      ),
    );

    expect(find.text('#ORD-CARD-001'), findsOneWidget);
    expect(find.text('Đang chuẩn bị'), findsOneWidget);
    expect(find.text('Cá hồi Na Uy phi lê'), findsOneWidget);
    expect(find.text('170.000 đ'), findsOneWidget);
    expect(find.text('Theo dõi đơn'), findsOneWidget);
  });

  testWidgets('MyOrdersScreen renders title and tabs or guest view',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        home: const MyOrdersScreen(),
      ),
    );
    await tester.pump();

    // Verify title
    expect(find.text('Đơn hàng của tôi'), findsOneWidget);

    // If unauthenticated, displays guest prompt
    final guestPrompt = find.text('Theo dõi đơn hàng dễ dàng');
    final tabAll = find.textContaining('Tất cả');

    // One of them must be present depending on auth state
    expect(guestPrompt.evaluate().isNotEmpty || tabAll.evaluate().isNotEmpty, isTrue);
  });
}
