import 'package:flutter/material.dart';

class CreateOrderItemDto {
  final String productId;
  final String productName;
  final String? productVariantId;
  final int quantity;
  final num unitPrice;
  final String? note;

  CreateOrderItemDto({
    required this.productId,
    required this.productName,
    this.productVariantId,
    required this.quantity,
    required this.unitPrice,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      if (productVariantId != null && productVariantId!.isNotEmpty)
        'productVariantId': productVariantId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}

class CreateOrderDto {
  final String paymentMethod; // COD, MOMO, VNPAY, CREDIT_CARD
  final String shippingAddress;
  final String receiverName;
  final String receiverPhone;
  final String? note;
  final num shippingFee;
  final String? supplierId;
  final List<CreateOrderItemDto> items;

  CreateOrderDto({
    required this.paymentMethod,
    required this.shippingAddress,
    required this.receiverName,
    required this.receiverPhone,
    this.note,
    this.shippingFee = 0,
    this.supplierId,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      if (note != null && note!.isNotEmpty) 'note': note,
      'shippingFee': shippingFee,
      if (supplierId != null && supplierId!.isNotEmpty) 'supplierId': supplierId,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class OrderItemDto {
  final String id;
  final String? orderId;
  final String productId;
  final String? productVariantId;
  final String productName;
  final int quantity;
  final num unitPrice;
  final num totalPrice;
  final String? note;
  final String? imageUrl;

  OrderItemDto({
    required this.id,
    this.orderId,
    required this.productId,
    this.productVariantId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.note,
    this.imageUrl,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toInt() ?? 1;
    final unitP = (json['unitPrice'] as num?) ?? (json['price'] as num?) ?? 0;
    final totalP = (json['totalPrice'] as num?) ?? (qty * unitP);

    return OrderItemDto(
      id: json['orderItemId']?.toString() ?? json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString(),
      productId: json['productId']?.toString() ?? '',
      productVariantId: json['productVariantId']?.toString(),
      productName: json['productName']?.toString() ??
          json['title']?.toString() ??
          json['name']?.toString() ??
          '',
      quantity: qty,
      unitPrice: unitP,
      totalPrice: totalP,
      note: json['note']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  String get formattedUnitPrice {
    final formatted = unitPrice.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formatted đ';
  }

  String get formattedTotalPrice {
    final formatted = totalPrice.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formatted đ';
  }
}

class OrderDto {
  final String id;
  final String orderNumber;
  final String? userId;
  final String? supplierId;
  final num subtotal;
  final num discountAmount;
  final num shippingFee;
  final num totalAmount;
  final String orderStatus;
  final String paymentMethod;
  final String paymentStatus;
  final String shippingAddress;
  final String receiverName;
  final String receiverPhone;
  final String? note;
  final String? shippingMethod;
  final String? shipperTrackingCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItemDto> items;

  OrderDto({
    required this.id,
    required this.orderNumber,
    this.userId,
    this.supplierId,
    required this.subtotal,
    this.discountAmount = 0,
    this.shippingFee = 0,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.shippingAddress,
    required this.receiverName,
    required this.receiverPhone,
    this.note,
    this.shippingMethod,
    this.shipperTrackingCode,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>?;
    final parsedItems = rawItems != null
        ? rawItems
            .map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
            .toList()
        : <OrderItemDto>[];

    final calculatedSubtotal = parsedItems.fold<num>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    final rawSubtotal = (json['subtotal'] as num?) ?? (json['subTotal'] as num?);
    final finalSubtotal = (rawSubtotal != null && rawSubtotal > 0)
        ? rawSubtotal
        : calculatedSubtotal;

    final fee = (json['shippingFee'] as num?) ?? 0;
    final discount = (json['discountAmount'] as num?) ?? 0;
    final rawTotal = (json['totalAmount'] as num?);
    final finalTotal = rawTotal ?? (finalSubtotal + fee - discount);

    final id = json['orderId']?.toString() ??
        json['id']?.toString() ??
        json['_id']?.toString() ??
        '';

    final orderNumber = json['orderNumber']?.toString() ??
        (id.isNotEmpty ? 'ORD-${id.substring(0, id.length > 8 ? 8 : id.length).toUpperCase()}' : '');

    return OrderDto(
      id: id,
      orderNumber: orderNumber,
      userId: json['userId']?.toString(),
      supplierId: json['supplierId']?.toString(),
      subtotal: finalSubtotal,
      discountAmount: discount,
      shippingFee: fee,
      totalAmount: finalTotal,
      orderStatus: json['orderStatus']?.toString() ??
          json['status']?.toString() ??
          'PENDING',
      paymentMethod: json['paymentMethod']?.toString() ?? 'COD',
      paymentStatus: json['paymentStatus']?.toString() ?? 'PENDING',
      shippingAddress: json['shippingAddress']?.toString() ??
          json['deliveryAddress']?.toString() ??
          '',
      receiverName: json['receiverName']?.toString() ??
          json['customerName']?.toString() ??
          '',
      receiverPhone: json['receiverPhone']?.toString() ??
          json['customerPhone']?.toString() ??
          '',
      note: json['note']?.toString(),
      shippingMethod: json['shippingMethod']?.toString(),
      shipperTrackingCode: json['shipperTrackingCode']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      items: parsedItems,
    );
  }

  OrderDto copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    String? supplierId,
    num? subtotal,
    num? discountAmount,
    num? shippingFee,
    num? totalAmount,
    String? orderStatus,
    String? paymentMethod,
    String? paymentStatus,
    String? shippingAddress,
    String? receiverName,
    String? receiverPhone,
    String? note,
    String? shippingMethod,
    String? shipperTrackingCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItemDto>? items,
  }) {
    return OrderDto(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      supplierId: supplierId ?? this.supplierId,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      totalAmount: totalAmount ?? this.totalAmount,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      note: note ?? this.note,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      shipperTrackingCode: shipperTrackingCode ?? this.shipperTrackingCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  String get formattedTotalAmount {
    final formatted = totalAmount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formatted đ';
  }

  String get formattedSubtotal {
    final formatted = subtotal.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formatted đ';
  }

  String get formattedShippingFee {
    if (shippingFee == 0) return 'Miễn phí';
    final formatted = shippingFee.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formatted đ';
  }

  String get statusDisplay {
    switch (orderStatus.toUpperCase()) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'AWAITING_PAYMENT':
        return 'Chờ thanh toán';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'PROCESSING':
        return 'Đang chuẩn bị';
      case 'SHIPPING':
        return 'Đang giao hàng';
      case 'DELIVERED':
        return 'Đã giao hàng';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'REFUNDED':
        return 'Đã hoàn tiền';
      default:
        return orderStatus;
    }
  }

  String get statusDescription {
    switch (orderStatus.toUpperCase()) {
      case 'PENDING':
        return 'Đơn hàng đang chờ nhà cung cấp tiếp nhận và xác nhận.';
      case 'AWAITING_PAYMENT':
        return 'Vui lòng hoàn tất thanh toán để người bán xử lý đơn.';
      case 'CONFIRMED':
        return 'Nhà cung cấp đã xác nhận đơn và đang chuẩn bị lấy hàng.';
      case 'PROCESSING':
        return 'Người bán đang lựa chọn những nguyên liệu tươi ngon nhất cho bạn.';
      case 'SHIPPING':
        return 'Đơn hàng đang trên đường vận chuyển tới địa chỉ của bạn.';
      case 'DELIVERED':
        return 'Đơn hàng đã được shipper giao thành công đến bạn.';
      case 'COMPLETED':
        return 'Đơn hàng đã hoàn tất trọn vẹn. Chúc bạn có món ăn thật ngon!';
      case 'CANCELLED':
        return 'Đơn hàng này đã được hủy.';
      case 'REFUNDED':
        return 'Đơn hàng đã được hoàn tiền.';
      default:
        return 'Đơn hàng đang được hệ thống xử lý.';
    }
  }

  bool get canCancel {
    final s = orderStatus.toUpperCase();
    return s == 'PENDING' || s == 'AWAITING_PAYMENT' || s == 'CONFIRMED';
  }

  bool get isTerminal {
    final s = orderStatus.toUpperCase();
    return s == 'COMPLETED' || s == 'DELIVERED' || s == 'CANCELLED' || s == 'REFUNDED';
  }

  bool get isCancelled {
    final s = orderStatus.toUpperCase();
    return s == 'CANCELLED' || s == 'REFUNDED';
  }

  bool get isShipping {
    return orderStatus.toUpperCase() == 'SHIPPING';
  }

  bool get isCompleted {
    final s = orderStatus.toUpperCase();
    return s == 'DELIVERED' || s == 'COMPLETED';
  }

  int get currentStepIndex {
    switch (orderStatus.toUpperCase()) {
      case 'PENDING':
      case 'AWAITING_PAYMENT':
        return 0; // Đặt hàng thành công
      case 'CONFIRMED':
      case 'PROCESSING':
        return 1; // Xác nhận & Chuẩn bị
      case 'SHIPPING':
        return 2; // Đang vận chuyển
      case 'DELIVERED':
      case 'COMPLETED':
        return 3; // Hoàn thành
      default:
        return 0;
    }
  }

  Color get statusColor {
    switch (orderStatus.toUpperCase()) {
      case 'PENDING':
      case 'AWAITING_PAYMENT':
        return const Color(0xFFF59E0B); // Amber / Orange
      case 'CONFIRMED':
        return const Color(0xFF3B82F6); // Blue
      case 'PROCESSING':
        return const Color(0xFF6366F1); // Indigo
      case 'SHIPPING':
        return const Color(0xFF0EA5E9); // Sky Cyan
      case 'DELIVERED':
      case 'COMPLETED':
        return const Color(0xFF10B981); // Emerald Green
      case 'CANCELLED':
      case 'REFUNDED':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color get statusBgColor {
    return statusColor.withValues(alpha: 0.12);
  }

  String get paymentMethodDisplay {
    switch (paymentMethod.toUpperCase()) {
      case 'COD':
        return 'Tiền mặt khi nhận hàng (COD)';
      case 'MOMO':
        return 'Ví MoMo';
      case 'VNPAY':
        return 'Cổng VNPAY-QR';
      case 'CREDIT_CARD':
        return 'Thẻ tín dụng / Ghi nợ';
      default:
        return paymentMethod;
    }
  }

  String get paymentStatusDisplay {
    switch (paymentStatus.toUpperCase()) {
      case 'SUCCESS':
        return 'Đã thanh toán';
      case 'PENDING':
        return 'Chờ thanh toán';
      case 'PROCESSING':
        return 'Đang xử lý';
      case 'FAILED':
        return 'Thất bại';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'REFUNDED':
        return 'Đã hoàn tiền';
      default:
        return paymentStatus;
    }
  }
}
