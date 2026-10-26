class ProductSkuItem {
  final String id;
  final String name; // Ví dụ: "Gói nhỏ 250g", "Gói lớn 500g", "Khay 300g"
  final String sku;  // Ví dụ: "XX-250G", "BO-300G"
  final double price;
  final double? originalPrice;
  final int stock;
  final String unit; // kg, g, túi, hộp, chai, khay, con, thùng
  final String? packSize; // 500g, 1kg, 5kg
  final int lowStockThreshold;
  final bool isDefault;
  final String status;

  const ProductSkuItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    this.originalPrice,
    required this.stock,
    this.unit = 'kg',
    this.packSize,
    this.lowStockThreshold = 10,
    this.isDefault = false,
    this.status = 'AVAILABLE',
  });

  ProductSkuItem copyWith({
    String? id,
    String? name,
    String? sku,
    double? price,
    double? originalPrice,
    int? stock,
    String? unit,
    String? packSize,
    int? lowStockThreshold,
    bool? isDefault,
    String? status,
  }) {
    return ProductSkuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      packSize: packSize ?? this.packSize,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      isDefault: isDefault ?? this.isDefault,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'price': price,
      'originalPrice': originalPrice,
      'stock': stock,
      'unit': unit,
      'packSize': packSize,
      'lowStockThreshold': lowStockThreshold,
      'isDefault': isDefault,
      'status': status,
    };
  }

  factory ProductSkuItem.fromJson(Map<String, dynamic> json) {
    return ProductSkuItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['variantName']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      stock: (json['stock'] as num?)?.toInt() ??
          (json['stockQuantity'] as num?)?.toInt() ??
          0,
      unit: json['unit']?.toString() ?? 'kg',
      packSize: json['packSize']?.toString(),
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 10,
      isDefault: json['isDefault'] as bool? ?? false,
      status: json['status']?.toString() ?? 'AVAILABLE',
    );
  }
}
