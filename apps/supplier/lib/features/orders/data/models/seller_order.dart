class OrderItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SellerOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final double totalAmount;
  final String status; // pending, confirmed, preparing, ready, completed, cancelled
  final DateTime createdAt;
  final List<OrderItem> items;

  SellerOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory SellerOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return SellerOrder(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? json['customer']?['name']?.toString() ?? 'Khách hàng',
      customerPhone: json['customerPhone']?.toString() ?? json['customer']?['phone']?.toString() ?? '',
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      items: rawItems.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
