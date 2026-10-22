class ProductSkuItem {
  final String id;
  final String name; // Ví dụ: "Gói nhỏ 250g", "Gói lớn 500g", "Khay 300g"
  final String sku;  // Ví dụ: "XX-250G", "BO-300G"
  final double price;
  final double? originalPrice;
  final int stock;

  const ProductSkuItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    this.originalPrice,
    required this.stock,
  });

  ProductSkuItem copyWith({
    String? id,
    String? name,
    String? sku,
    double? price,
    double? originalPrice,
    int? stock,
  }) {
    return ProductSkuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stock: stock ?? this.stock,
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
    };
  }

  factory ProductSkuItem.fromJson(Map<String, dynamic> json) {
    return ProductSkuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null ? (json['originalPrice'] as num).toDouble() : null,
      stock: json['stock'] as int,
    );
  }
}
