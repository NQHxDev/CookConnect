import 'product_category_type.dart';
import 'product_sku_item.dart';

export 'product_sku_item.dart';

class SellerProductItem {
  final String id;
  final String name;
  final String sku;
  final double price;
  final double? originalPrice;
  final int stock;
  final int soldCount;
  final String? imageUrl;
  final List<String> images;
  final ProductCategoryType categoryType;
  final String foodCategory;
  final String? rejectReason;
  final String? freezeReason;
  final DateTime updatedAt;
  final bool isAvailable;
  final List<ProductSkuItem> skus;

  SellerProductItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    this.originalPrice,
    required this.stock,
    this.soldCount = 0,
    String? imageUrl,
    List<String>? images,
    required this.categoryType,
    this.foodCategory = 'Thịt bò',
    this.rejectReason,
    this.freezeReason,
    DateTime? updatedAt,
    this.isAvailable = true,
    List<ProductSkuItem>? skus,
  })  : imageUrl = imageUrl ?? (images != null && images.isNotEmpty ? images.first : null),
        images = images ?? (imageUrl != null ? [imageUrl] : const []),
        updatedAt = updatedAt ?? DateTime.now(),
        skus = skus ?? const [];

  bool get hasMultipleSkus => skus.length > 1;

  double get minPrice {
    if (skus.isEmpty) return price;
    return skus.map((s) => s.price).reduce((a, b) => a < b ? a : b);
  }

  double get maxPrice {
    if (skus.isEmpty) return price;
    return skus.map((s) => s.price).reduce((a, b) => a > b ? a : b);
  }

  int get totalStock {
    if (skus.isEmpty) return stock;
    return skus.fold(0, (sum, s) => sum + s.stock);
  }

  SellerProductItem copyWith({
    String? id,
    String? name,
    String? sku,
    double? price,
    double? originalPrice,
    int? stock,
    int? soldCount,
    String? imageUrl,
    List<String>? images,
    ProductCategoryType? categoryType,
    String? foodCategory,
    String? rejectReason,
    String? freezeReason,
    DateTime? updatedAt,
    bool? isAvailable,
    List<ProductSkuItem>? skus,
  }) {
    return SellerProductItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stock: stock ?? this.stock,
      soldCount: soldCount ?? this.soldCount,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      categoryType: categoryType ?? this.categoryType,
      foodCategory: foodCategory ?? this.foodCategory,
      rejectReason: rejectReason ?? this.rejectReason,
      freezeReason: freezeReason ?? this.freezeReason,
      updatedAt: updatedAt ?? this.updatedAt,
      isAvailable: isAvailable ?? this.isAvailable,
      skus: skus ?? this.skus,
    );
  }
}
