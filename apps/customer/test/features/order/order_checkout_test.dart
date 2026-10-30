import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/order/data/models/order_model.dart';
import 'package:cookconnect/features/order/presentation/pages/order_checkout_screen.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';

void main() {
  test('CreateOrderDto and OrderDto json serialization tests', () {
    final item = CreateOrderItemDto(
      productId: 'prod_123',
      productName: 'Thịt bò phi lê',
      quantity: 2,
      unitPrice: 150000,
    );

    final dto = CreateOrderDto(
      paymentMethod: 'COD',
      shippingAddress: '123 Cách Mạng Tháng 8, Q.3, TP.HCM',
      receiverName: 'Nguyễn Văn A',
      receiverPhone: '0901234567',
      shippingFee: 20000,
      items: [item],
    );

    final json = dto.toJson();
    expect(json['paymentMethod'], 'COD');
    expect(json['receiverName'], 'Nguyễn Văn A');
    expect(json['receiverPhone'], '0901234567');
    expect(json['items'], isA<List>());
    expect((json['items'] as List).first['productName'], 'Thịt bò phi lê');

    final orderJson = {
      'id': 'ord-1234',
      'orderNumber': 'ORD-TEST-001',
      'subtotal': 300000,
      'shippingFee': 20000,
      'totalAmount': 320000,
      'orderStatus': 'PENDING',
      'paymentMethod': 'COD',
      'paymentStatus': 'UNPAID',
      'shippingAddress': '123 CMT8',
      'receiverName': 'Nguyễn Văn A',
      'receiverPhone': '0901234567',
      'items': [
        {
          'id': 'item-1',
          'productId': 'prod_123',
          'productName': 'Thịt bò phi lê',
          'quantity': 2,
          'unitPrice': 150000,
          'totalPrice': 300000,
        }
      ],
    };

    final order = OrderDto.fromJson(orderJson);
    expect(order.orderNumber, 'ORD-TEST-001');
    expect(order.statusDisplay, 'Chờ xác nhận');
    expect(order.items.length, 1);
    expect(order.items.first.productName, 'Thịt bò phi lê');
  });

  testWidgets('OrderCheckoutScreen renders items, addresses and payment methods',
      (WidgetTester tester) async {
    final testItems = [
      ShoppingItem(
        id: 'test_1',
        name: 'Trứng gà ta',
        amount: '10 quả',
        recipeSource: 'Trứng chiên',
        price: 35000,
      ),
      ShoppingItem(
        id: 'test_2',
        name: 'Hành lá tươi',
        amount: '1 bó',
        recipeSource: 'Tự thêm',
        price: 10000,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: OrderCheckoutScreen(items: testItems),
      ),
    );

    await tester.pump();

    // Verify Title
    expect(find.text('Xác nhận đặt hàng'), findsOneWidget);

    // Verify Address fields
    expect(find.text('Địa chỉ nhận hàng'), findsOneWidget);
    expect(find.text('Họ và tên người nhận *'), findsOneWidget);
    expect(find.text('Số điện thoại *'), findsOneWidget);

    // Verify Products
    expect(find.text('Trứng gà ta'), findsOneWidget);
    expect(find.text('Hành lá tươi'), findsOneWidget);

    // Scroll to see payment methods and summary
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pump();

    // Verify Payment methods
    expect(find.text('Thanh toán tiền mặt khi nhận hàng (COD)'), findsOneWidget);
    expect(find.text('Ví điện tử MoMo'), findsOneWidget);

    // Verify summary
    expect(find.text('Chi tiết thanh toán'), findsOneWidget);
    expect(find.text('Đặt hàng ngay'), findsOneWidget);
  });
}
