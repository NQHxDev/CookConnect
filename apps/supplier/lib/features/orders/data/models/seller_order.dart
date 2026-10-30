class OrderItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String? productId;
  final String? note;

  OrderItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.productId,
    this.note,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      title: json['productName']?.toString() ??
          json['title']?.toString() ??
          json['name']?.toString() ??
          '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['unitPrice'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0.0,
      imageUrl: json['imageUrl']?.toString(),
      productId: json['productId']?.toString(),
      note: json['note']?.toString(),
    );
  }
}

class SellerOrder {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final double totalAmount;
  final double shippingFee;
  final String status; // mapped user-friendly status in Vietnamese
  final String rawStatus; // raw enum: PENDING, CONFIRMED, PROCESSING, SHIPPING, etc.
  final String paymentMethod;
  final String paymentStatus;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;

  SellerOrder({
    required this.id,
    this.orderNumber = '',
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.totalAmount,
    this.shippingFee = 0.0,
    required this.status,
    this.rawStatus = '',
    this.paymentMethod = 'COD',
    this.paymentStatus = 'UNPAID',
    this.note,
    required this.createdAt,
    this.updatedAt,
    required this.items,
  });

  static String mapBackendStatus(String raw) {
    switch (raw.toUpperCase()) {
      case 'PENDING':
        return 'Cần vận chuyển trong vòng 24h';
      case 'CONFIRMED':
      case 'PROCESSING':
        return 'Đang chờ vận chuyển';
      case 'SHIPPING':
        return 'Đang trung chuyển';
      case 'DELIVERED':
        return 'Đã giao hàng';
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return raw;
    }
  }

  factory SellerOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawStatus =
        json['orderStatus']?.toString() ?? json['status']?.toString() ?? 'pending';

    return SellerOrder(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ??
          json['id']?.toString() ??
          '',
      customerName: json['receiverName']?.toString() ??
          json['customerName']?.toString() ??
          json['customer']?['name']?.toString() ??
          'Khách hàng',
      customerPhone: json['receiverPhone']?.toString() ??
          json['customerPhone']?.toString() ??
          json['customer']?['phone']?.toString() ??
          '',
      deliveryAddress: json['shippingAddress']?.toString() ??
          json['deliveryAddress']?.toString() ??
          '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      rawStatus: rawStatus,
      status: mapBackendStatus(rawStatus),
      paymentMethod: json['paymentMethod']?.toString() ?? 'COD',
      paymentStatus: json['paymentStatus']?.toString() ?? 'UNPAID',
      note: json['note']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      items: rawItems
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  SellerOrder copyWith({
    String? id,
    String? orderNumber,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    double? totalAmount,
    double? shippingFee,
    String? status,
    String? rawStatus,
    String? paymentMethod,
    String? paymentStatus,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
  }) {
    return SellerOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      status: status ?? this.status,
      rawStatus: rawStatus ?? this.rawStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
