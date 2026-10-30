import 'product_category.dart';
import 'product_category_type.dart';
import 'product_sku_item.dart';

export 'product_sku_item.dart';

class SellerProductItem {
  final String id;
  final String? supplierId;
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
  final String? whoCategoryCode;
  final String? description;
  final String? origin;
  final String? storageCondition;
  final int? shelfLifeDays;
  final String unit;
  final String? packSize;
  final String? moderationStatus; // PENDING_APPROVAL, APPROVED, REJECTED
  final String? status; // DRAFT, ACTIVE, INACTIVE
  final String? rejectReason;
  final String? freezeReason;
  final DateTime updatedAt;
  final bool isAvailable;
  final List<ProductSkuItem> skus;

  SellerProductItem({
    required this.id,
    this.supplierId,
    required this.name,
    required this.sku,
    required this.price,
    this.originalPrice,
    required this.stock,
    this.soldCount = 0,
    String? imageUrl,
    List<String>? images,
    required this.categoryType,
    this.foodCategory = 'Lương thực chính (Tinh bột)',
    this.whoCategoryCode,
    this.description,
    this.origin,
    this.storageCondition,
    this.shelfLifeDays,
    this.unit = 'kg',
    this.packSize,
    this.moderationStatus,
    this.status,
    this.rejectReason,
    this.freezeReason,
    DateTime? updatedAt,
    this.isAvailable = true,
    List<ProductSkuItem>? skus,
  })  : imageUrl = imageUrl ??
            (images != null && images.isNotEmpty ? images.first : null),
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

  /// Resolve valid WHO code
  String get effectiveWhoCategoryCode {
    if (whoCategoryCode != null && whoCategoryCode!.isNotEmpty) {
      return whoCategoryCode!;
    }
    return ProductCategory.mapToWhoCategory(foodCategory).code;
  }

  SellerProductItem copyWith({
    String? id,
    String? supplierId,
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
    String? whoCategoryCode,
    String? description,
    String? origin,
    String? storageCondition,
    int? shelfLifeDays,
    String? unit,
    String? packSize,
    String? moderationStatus,
    String? status,
    String? rejectReason,
    String? freezeReason,
    DateTime? updatedAt,
    bool? isAvailable,
    List<ProductSkuItem>? skus,
  }) {
    return SellerProductItem(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
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
      whoCategoryCode: whoCategoryCode ?? this.whoCategoryCode,
      description: description ?? this.description,
      origin: origin ?? this.origin,
      storageCondition: storageCondition ?? this.storageCondition,
      shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
      unit: unit ?? this.unit,
      packSize: packSize ?? this.packSize,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
      freezeReason: freezeReason ?? this.freezeReason,
      updatedAt: updatedAt ?? this.updatedAt,
      isAvailable: isAvailable ?? this.isAvailable,
      skus: skus ?? this.skus,
    );
  }
}
