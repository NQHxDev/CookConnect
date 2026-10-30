import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/features/orders/data/models/seller_order.dart';

void main() {
  group('SellerOrder & OrderItem Tests', () {
    test('parses real backend API response correctly', () {
      final backendOrderJson = {
        'id': 'c6204c8c-1e82-411a-8e26-f7253d7159bb',
        'orderNumber': 'ORD-MVUTHTBT-4498',
        'userId': '283b8796-03c0-4820-99c5-8463c63be113',
        'supplierId': '5097672a-87b6-4871-8a48-df6159b97a60',
        'subtotal': 120000,
        'discountAmount': 0,
        'shippingFee': 20000,
        'totalAmount': 140000,
        'orderStatus': 'PENDING',
        'paymentMethod': 'COD',
        'paymentStatus': 'UNPAID',
        'shippingAddress': '123 Cách Mạng Tháng 8, P.10, Q.3, TP.HCM',
        'receiverName': 'Test Customer',
        'receiverPhone': '0901234567',
        'note': 'Giao giờ hành chính',
        'createdAt': '2026-10-30T09:40:48.374Z',
        'updatedAt': '2026-10-30T09:40:48.374Z',
        'items': [
          {
            'id': '18cf325c-8dfc-423c-a968-3bb8c312781b',
            'orderId': 'c6204c8c-1e82-411a-8e26-f7253d7159bb',
            'productId': '79b38dc7-6ef7-4ba3-ab2f-d89e08398ff6',
            'productVariantId': null,
            'productName': 'Thịt ba chỉ heo tươi',
            'quantity': 2,
            'unitPrice': 60000,
            'totalPrice': 120000,
            'note': null,
          }
        ],
      };

      final order = SellerOrder.fromJson(backendOrderJson);

      expect(order.id, 'c6204c8c-1e82-411a-8e26-f7253d7159bb');
      expect(order.orderNumber, 'ORD-MVUTHTBT-4498');
      expect(order.customerName, 'Test Customer');
      expect(order.customerPhone, '0901234567');
      expect(order.deliveryAddress, '123 Cách Mạng Tháng 8, P.10, Q.3, TP.HCM');
      expect(order.totalAmount, 140000.0);
      expect(order.shippingFee, 20000.0);
      expect(order.rawStatus, 'PENDING');
      expect(order.status, 'Cần vận chuyển trong vòng 24h');
      expect(order.paymentMethod, 'COD');
      expect(order.paymentStatus, 'UNPAID');
      expect(order.note, 'Giao giờ hành chính');
      expect(order.items.length, 1);
      expect(order.items.first.title, 'Thịt ba chỉ heo tươi');
      expect(order.items.first.quantity, 2);
      expect(order.items.first.price, 60000.0);
    });

    test('mapBackendStatus correctly maps all lifecycle statuses', () {
      expect(SellerOrder.mapBackendStatus('PENDING'), 'Cần vận chuyển trong vòng 24h');
      expect(SellerOrder.mapBackendStatus('CONFIRMED'), 'Đang chờ vận chuyển');
      expect(SellerOrder.mapBackendStatus('PROCESSING'), 'Đang chờ vận chuyển');
      expect(SellerOrder.mapBackendStatus('SHIPPING'), 'Đang trung chuyển');
      expect(SellerOrder.mapBackendStatus('DELIVERED'), 'Đã giao hàng');
      expect(SellerOrder.mapBackendStatus('COMPLETED'), 'Đã hoàn thành');
      expect(SellerOrder.mapBackendStatus('CANCELLED'), 'Đã hủy');
      expect(SellerOrder.mapBackendStatus('Đang chờ lấy hàng'), 'Đang chờ lấy hàng');
    });

    test('copyWith works properly', () {
      final order = SellerOrder(
        id: 'ord_1',
        customerName: 'A',
        customerPhone: '123',
        deliveryAddress: 'Addr',
        totalAmount: 1000,
        status: 'pending',
        createdAt: DateTime.now(),
        items: [],
      );

      final updated = order.copyWith(status: 'Đang chờ vận chuyển', totalAmount: 2000);
      expect(updated.status, 'Đang chờ vận chuyển');
      expect(updated.totalAmount, 2000.0);
      expect(updated.id, 'ord_1');
    });
  });
}
