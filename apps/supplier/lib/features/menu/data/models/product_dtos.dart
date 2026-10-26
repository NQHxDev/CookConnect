import 'product_category.dart';
import 'product_category_type.dart';
import 'seller_product_item.dart';

/// Request DTO for single product packaging variant matching Swagger schema `CreateProductVariantDto`.
class CreateProductVariantDto {
  final String sku;
  final String variantName;
  final String unit;
  final String? packSize;
  final double price;
  final double? originalPrice;
  final String currency;
  final int stockQuantity;
  final int lowStockThreshold;
  final bool isDefault;

  const CreateProductVariantDto({
    required this.sku,
    required this.variantName,
    required this.unit,
    this.packSize,
    required this.price,
    this.originalPrice,
    this.currency = 'VND',
    required this.stockQuantity,
    this.lowStockThreshold = 10,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'sku': sku,
      'variantName': variantName,
      'unit': unit,
      'price': price,
      'currency': currency,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'isDefault': isDefault,
    };
    if (packSize != null && packSize!.trim().isNotEmpty) {
      map['packSize'] = packSize!.trim();
    }
    if (originalPrice != null && originalPrice! > 0) {
      map['originalPrice'] = originalPrice;
    }
    return map;
  }

  ProductSkuItem toProductSkuItem() {
    return ProductSkuItem(
      id: 'sku_${DateTime.now().millisecondsSinceEpoch}_${sku.hashCode.abs()}',
      name: variantName,
      sku: sku,
      price: price,
      originalPrice: originalPrice,
      stock: stockQuantity,
      unit: unit,
      packSize: packSize,
      lowStockThreshold: lowStockThreshold,
      isDefault: isDefault,
    );
  }

  factory CreateProductVariantDto.fromJson(Map<String, dynamic> json) {
    return CreateProductVariantDto(
      sku: json['sku']?.toString() ?? '',
      variantName: json['variantName']?.toString() ?? '',
      unit: json['unit']?.toString() ?? 'kg',
      packSize: json['packSize']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      currency: json['currency']?.toString() ?? 'VND',
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 10,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

/// Request DTO for registering a raw ingredient / supply product matching Swagger `POST /api/v1/products`.
class CreateProductDto {
  /// Standard WHO nutrition group code (1 of 8 groups enum)
  final String whoCategoryCode;
  final String productName;
  final String description;
  final String? origin;
  final String? storageCondition;
  final int? shelfLifeDays;
  final List<String> images;
  final List<CreateProductVariantDto> variants;

  const CreateProductDto({
    required this.whoCategoryCode,
    required this.productName,
    required this.description,
    this.origin,
    this.storageCondition,
    this.shelfLifeDays,
    this.images = const [],
    required this.variants,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'whoCategoryCode': whoCategoryCode,
      'productName': productName,
      'description': description,
      'variants': variants.map((v) => v.toJson()).toList(),
    };

    if (origin != null && origin!.trim().isNotEmpty) {
      map['origin'] = origin!.trim();
    }
    if (storageCondition != null && storageCondition!.trim().isNotEmpty) {
      map['storageCondition'] = storageCondition!.trim();
    }
    if (shelfLifeDays != null && shelfLifeDays! > 0) {
      map['shelfLifeDays'] = shelfLifeDays;
    }
    if (images.isNotEmpty) {
      map['images'] = images;
    }

    return map;
  }

  CreateProductDto copyWith({
    String? whoCategoryCode,
    String? productName,
    String? description,
    String? origin,
    String? storageCondition,
    int? shelfLifeDays,
    List<String>? images,
    List<CreateProductVariantDto>? variants,
  }) {
    return CreateProductDto(
      whoCategoryCode: whoCategoryCode ?? this.whoCategoryCode,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      origin: origin ?? this.origin,
      storageCondition: storageCondition ?? this.storageCondition,
      shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
      images: images ?? this.images,
      variants: variants ?? this.variants,
    );
  }

  factory CreateProductDto.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variants'] as List<dynamic>? ?? [];
    final rawImages = json['images'] as List<dynamic>? ?? [];

    return CreateProductDto(
      whoCategoryCode: json['whoCategoryCode'] is Map
          ? (json['whoCategoryCode']['code']?.toString() ?? 'STAPLES')
          : (json['whoCategoryCode']?.toString() ?? 'STAPLES'),
      productName: json['productName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      origin: json['origin']?.toString(),
      storageCondition: json['storageCondition']?.toString(),
      shelfLifeDays: (json['shelfLifeDays'] as num?)?.toInt(),
      images: rawImages.map((e) => e.toString()).toList(),
      variants: rawVariants
          .map((v) => CreateProductVariantDto.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Response DTO for a variant returned by backend `ProductVariantDto`.
class ProductVariantDto {
  final String variantId;
  final String productId;
  final String sku;
  final String variantName;
  final String unit;
  final String? packSize;
  final double price;
  final double? originalPrice;
  final String currency;
  final int stockQuantity;
  final int reservedQuantity;
  final int lowStockThreshold;
  final bool isDefault;
  final String status;

  const ProductVariantDto({
    required this.variantId,
    required this.productId,
    required this.sku,
    required this.variantName,
    required this.unit,
    this.packSize,
    required this.price,
    this.originalPrice,
    this.currency = 'VND',
    required this.stockQuantity,
    this.reservedQuantity = 0,
    this.lowStockThreshold = 10,
    this.isDefault = false,
    this.status = 'AVAILABLE',
  });

  factory ProductVariantDto.fromJson(Map<String, dynamic> json) {
    return ProductVariantDto(
      variantId: json['variantId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      variantName: json['variantName']?.toString() ?? '',
      unit: json['unit']?.toString() ?? 'kg',
      packSize: json['packSize']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      currency: json['currency'] is Map
          ? (json['currency']['code']?.toString() ?? 'VND')
          : (json['currency']?.toString() ?? 'VND'),
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      reservedQuantity: (json['reservedQuantity'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 10,
      isDefault: json['isDefault'] as bool? ?? false,
      status: json['status']?.toString() ?? 'AVAILABLE',
    );
  }

  ProductSkuItem toProductSkuItem() {
    return ProductSkuItem(
      id: variantId,
      name: variantName,
      sku: sku,
      price: price,
      originalPrice: originalPrice,
      stock: stockQuantity,
      unit: unit,
      packSize: packSize,
      lowStockThreshold: lowStockThreshold,
      isDefault: isDefault,
      status: status,
    );
  }
}

/// Response DTO for registered product returned by backend `POST /api/v1/products` (`ProductItemDto`).
class ProductItemDto {
  final String productId;
  final String supplierId;
  final String whoCategoryCode;
  final String productName;
  final String? productSlug;
  final String description;
  final String? origin;
  final String? storageCondition;
  final int? shelfLifeDays;
  final List<String> images;
  final String status; // DRAFT, ACTIVE, INACTIVE
  final String moderationStatus; // PENDING_APPROVAL, APPROVED, REJECTED
  final String? rejectionReason;
  final List<ProductVariantDto> variants;
  final int version;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductItemDto({
    required this.productId,
    required this.supplierId,
    required this.whoCategoryCode,
    required this.productName,
    this.productSlug,
    required this.description,
    this.origin,
    this.storageCondition,
    this.shelfLifeDays,
    this.images = const [],
    this.status = 'DRAFT',
    this.moderationStatus = 'PENDING_APPROVAL',
    this.rejectionReason,
    this.variants = const [],
    this.version = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductItemDto.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variants'] as List<dynamic>? ?? [];
    final rawImages = json['images'] as List<dynamic>? ?? [];

    String parseCategory(dynamic val) {
      if (val is Map) return val['code']?.toString() ?? 'STAPLES';
      return val?.toString() ?? 'STAPLES';
    }

    String parseStatus(dynamic val) {
      if (val is Map) return val['name']?.toString() ?? val['code']?.toString() ?? 'DRAFT';
      return val?.toString() ?? 'DRAFT';
    }

    String parseModeration(dynamic val) {
      if (val is Map) return val['name']?.toString() ?? val['code']?.toString() ?? 'PENDING_APPROVAL';
      return val?.toString() ?? 'PENDING_APPROVAL';
    }

    return ProductItemDto(
      productId: json['productId']?.toString() ?? '',
      supplierId: json['supplierId']?.toString() ?? '',
      whoCategoryCode: parseCategory(json['whoCategoryCode']),
      productName: json['productName']?.toString() ?? '',
      productSlug: json['productSlug']?.toString(),
      description: json['description']?.toString() ?? '',
      origin: json['origin']?.toString(),
      storageCondition: json['storageCondition']?.toString(),
      shelfLifeDays: (json['shelfLifeDays'] as num?)?.toInt(),
      images: rawImages.map((e) => e.toString()).toList(),
      status: parseStatus(json['status']),
      moderationStatus: parseModeration(json['moderationStatus']),
      rejectionReason: json['rejectionReason']?.toString(),
      variants: rawVariants
          .map((v) => ProductVariantDto.fromJson(v as Map<String, dynamic>))
          .toList(),
      version: (json['version'] as num?)?.toInt() ?? 1,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  /// Converts backend ProductItemDto to UI SellerProductItem
  SellerProductItem toSellerProductItem() {
    final categoryObj = ProductCategory.findByCode(whoCategoryCode) ??
        ProductCategory.defaultCategories.first;

    final skus = variants.map((v) => v.toProductSkuItem()).toList();
    final primarySku = variants.isNotEmpty ? variants.first : null;

    final primaryPrice = primarySku?.price ?? 0.0;
    final primaryOriginalPrice = primarySku?.originalPrice;
    final totalStock = variants.fold<int>(0, (sum, v) => sum + v.stockQuantity);
    final primaryUnit = primarySku?.unit ?? 'kg';

    ProductCategoryType catType;
    if (moderationStatus.toUpperCase() == 'PENDING_APPROVAL') {
      catType = ProductCategoryType.underReview;
    } else if (moderationStatus.toUpperCase() == 'REJECTED') {
      catType = ProductCategoryType.failed;
    } else if (status.toUpperCase() == 'DRAFT') {
      catType = ProductCategoryType.draft;
    } else if (status.toUpperCase() == 'INACTIVE') {
      catType = ProductCategoryType.disabled;
    } else {
      catType = ProductCategoryType.onShelf;
    }

    return SellerProductItem(
      id: productId,
      name: productName,
      sku: primarySku?.sku ?? 'SKU-$productId',
      price: primaryPrice,
      originalPrice: primaryOriginalPrice,
      stock: totalStock,
      imageUrl: images.isNotEmpty ? images.first : null,
      images: images,
      categoryType: catType,
      foodCategory: categoryObj.name,
      whoCategoryCode: whoCategoryCode,
      description: description,
      origin: origin,
      storageCondition: storageCondition,
      shelfLifeDays: shelfLifeDays,
      unit: primaryUnit,
      packSize: primarySku?.packSize,
      moderationStatus: moderationStatus,
      status: status,
      rejectReason: rejectionReason,
      updatedAt: updatedAt ?? createdAt ?? DateTime.now(),
      isAvailable: status.toUpperCase() == 'ACTIVE',
      skus: skus,
    );
  }
}
