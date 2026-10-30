class ProductVariantDto {
  final String variantId;
  final String productId;
  final String? sku;
  final String? variantName;
  final String? unit;
  final String? packSize;
  final num? price;
  final num? originalPrice;
  final String? currency;
  final int? stockQuantity;
  final int? availableStock;
  final bool? isDefault;
  final String? status;

  ProductVariantDto({
    required this.variantId,
    required this.productId,
    this.sku,
    this.variantName,
    this.unit,
    this.packSize,
    this.price,
    this.originalPrice,
    this.currency,
    this.stockQuantity,
    this.availableStock,
    this.isDefault,
    this.status,
  });

  factory ProductVariantDto.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic value) {
      if (value is num) return value;
      if (value is String) return num.tryParse(value);
      return null;
    }

    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return ProductVariantDto(
      variantId: json['variantId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      sku: json['sku']?.toString(),
      variantName: json['variantName']?.toString(),
      unit: json['unit']?.toString(),
      packSize: json['packSize']?.toString(),
      price: parseNum(json['price']),
      originalPrice: parseNum(json['originalPrice']),
      currency: json['currency']?.toString() ?? 'VND',
      stockQuantity: parseInt(json['stockQuantity']),
      availableStock: parseInt(json['availableStock']),
      isDefault: json['isDefault'] as bool?,
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variantId': variantId,
      'productId': productId,
      if (sku != null) 'sku': sku,
      if (variantName != null) 'variantName': variantName,
      if (unit != null) 'unit': unit,
      if (packSize != null) 'packSize': packSize,
      if (price != null) 'price': price,
      if (originalPrice != null) 'originalPrice': originalPrice,
      if (currency != null) 'currency': currency,
      if (stockQuantity != null) 'stockQuantity': stockQuantity,
      if (availableStock != null) 'availableStock': availableStock,
      if (isDefault != null) 'isDefault': isDefault,
      if (status != null) 'status': status,
    };
  }
}

class ProductSearchItemDto {
  final String productId;
  final String supplierId;
  final String? whoCategoryCode;
  final String productName;
  final String? productSlug;
  final String? description;
  final String? origin;
  final List<String> images;
  final String? status;
  final String? moderationStatus;
  final List<ProductVariantDto> variants;
  final num? minPrice;
  final num? maxPrice;
  final String? currency;
  final String? createdAt;
  final String? updatedAt;

  ProductSearchItemDto({
    required this.productId,
    required this.supplierId,
    this.whoCategoryCode,
    required this.productName,
    this.productSlug,
    this.description,
    this.origin,
    this.images = const [],
    this.status,
    this.moderationStatus,
    this.variants = const [],
    this.minPrice,
    this.maxPrice,
    this.currency,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductSearchItemDto.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic value) {
      if (value is num) return value;
      if (value is String) return num.tryParse(value);
      return null;
    }

    final rawImages = json['images'];
    List<String> imagesList = [];
    if (rawImages is List) {
      imagesList = rawImages.map((e) => e.toString()).toList();
    }

    final rawVariants = json['variants'];
    List<ProductVariantDto> variantsList = [];
    if (rawVariants is List) {
      variantsList = rawVariants
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductVariantDto.fromJson(e))
          .toList();
    }

    return ProductSearchItemDto(
      productId: json['productId']?.toString() ?? '',
      supplierId: json['supplierId']?.toString() ?? '',
      whoCategoryCode: json['whoCategoryCode']?.toString(),
      productName: json['productName']?.toString() ?? '',
      productSlug: json['productSlug']?.toString(),
      description: json['description']?.toString(),
      origin: json['origin']?.toString(),
      images: imagesList,
      status: json['status']?.toString(),
      moderationStatus: json['moderationStatus']?.toString(),
      variants: variantsList,
      minPrice: parseNum(json['minPrice']),
      maxPrice: parseNum(json['maxPrice']),
      currency: json['currency']?.toString() ?? 'VND',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'supplierId': supplierId,
      if (whoCategoryCode != null) 'whoCategoryCode': whoCategoryCode,
      'productName': productName,
      if (productSlug != null) 'productSlug': productSlug,
      if (description != null) 'description': description,
      if (origin != null) 'origin': origin,
      'images': images,
      if (status != null) 'status': status,
      if (moderationStatus != null) 'moderationStatus': moderationStatus,
      'variants': variants.map((v) => v.toJson()).toList(),
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (currency != null) 'currency': currency,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  /// Helper to get the primary display image
  String? get primaryImage => images.isNotEmpty ? images.first : null;

  /// Formatted price range
  String get formattedPrice {
    final cur = currency ?? 'VND';
    final curSymbol = cur == 'VND' ? 'đ' : cur;

    String formatNumber(num n) {
      return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    }

    if (minPrice != null && maxPrice != null) {
      if (minPrice == maxPrice) {
        return '${formatNumber(minPrice!)} $curSymbol';
      }
      return '${formatNumber(minPrice!)} - ${formatNumber(maxPrice!)} $curSymbol';
    } else if (minPrice != null) {
      return 'từ ${formatNumber(minPrice!)} $curSymbol';
    } else if (variants.isNotEmpty && variants.first.price != null) {
      return '${formatNumber(variants.first.price!)} $curSymbol';
    }
    return 'Liên hệ';
  }

  /// Helper for primary unit or packaging
  String get displayUnit {
    if (variants.isNotEmpty) {
      final v = variants.first;
      if (v.packSize != null && v.packSize!.isNotEmpty) return v.packSize!;
      if (v.unit != null && v.unit!.isNotEmpty) return v.unit!;
    }
    return '';
  }
}

class SearchProductsResponseDto {
  final List<ProductSearchItemDto> items;
  final int total;
  final int limit;
  final int offset;

  SearchProductsResponseDto({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory SearchProductsResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    List<ProductSearchItemDto> itemsList = [];
    if (rawItems is List) {
      itemsList = rawItems
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductSearchItemDto.fromJson(e))
          .toList();
    }

    return SearchProductsResponseDto(
      items: itemsList,
      total: (json['total'] as num?)?.toInt() ?? itemsList.length,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'total': total,
      'limit': limit,
      'offset': offset,
    };
  }
}

class WhoCategoryDto {
  final String code;
  final String name;
  final String description;
  final String examples;
  final int order;

  WhoCategoryDto({
    required this.code,
    required this.name,
    this.description = '',
    this.examples = '',
    this.order = 0,
  });

  factory WhoCategoryDto.fromJson(Map<String, dynamic> json) {
    return WhoCategoryDto(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      examples: json['examples']?.toString() ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'examples': examples,
      'order': order,
    };
  }

  String get icon {
    switch (code) {
      case 'MEAT_FISH_POULTRY':
        return '🥩';
      case 'VITAMIN_A_FRUITS_VEG':
        return '🥦';
      case 'OTHER_FRUITS_VEG':
        return '🍎';
      case 'DAIRY':
        return '🥛';
      case 'EGGS':
        return '🥚';
      case 'STAPLES':
        return '🍚';
      case 'LEGUMES_NUTS_SEEDS':
        return '🥜';
      case 'FATS_OILS':
        return '🧈';
      default:
        return '🛒';
    }
  }

  String get shortName {
    switch (code) {
      case 'STAPLES':
        return 'Lương thực';
      case 'LEGUMES_NUTS_SEEDS':
        return 'Đậu & Hạt';
      case 'DAIRY':
        return 'Sữa & Phô mai';
      case 'MEAT_FISH_POULTRY':
        return 'Thịt & Cá';
      case 'EGGS':
        return 'Trứng tươi';
      case 'VITAMIN_A_FRUITS_VEG':
        return 'Rau & Củ';
      case 'OTHER_FRUITS_VEG':
        return 'Trái cây';
      case 'FATS_OILS':
        return 'Gia vị & Dầu';
      default:
        return name;
    }
  }
}

class ProductSuggestionItemDto {
  final String productId;
  final String productName;
  final String? productSlug;
  final String? whoCategoryCode;
  final String? origin;
  final List<String> images;
  final String? defaultUnit;
  final num? minPrice;
  final num? maxPrice;
  final String? currency;

  ProductSuggestionItemDto({
    required this.productId,
    required this.productName,
    this.productSlug,
    this.whoCategoryCode,
    this.origin,
    this.images = const [],
    this.defaultUnit,
    this.minPrice,
    this.maxPrice,
    this.currency,
  });

  factory ProductSuggestionItemDto.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic value) {
      if (value is num) return value;
      if (value is String) return num.tryParse(value);
      return null;
    }

    final rawImages = json['images'];
    List<String> imagesList = [];
    if (rawImages is List) {
      imagesList = rawImages.map((e) => e.toString()).toList();
    }

    return ProductSuggestionItemDto(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      productSlug: json['productSlug']?.toString(),
      whoCategoryCode: json['whoCategoryCode']?.toString(),
      origin: json['origin']?.toString(),
      images: imagesList,
      defaultUnit: json['defaultUnit']?.toString(),
      minPrice: parseNum(json['minPrice']),
      maxPrice: parseNum(json['maxPrice']),
      currency: json['currency']?.toString() ?? 'VND',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      if (productSlug != null) 'productSlug': productSlug,
      if (whoCategoryCode != null) 'whoCategoryCode': whoCategoryCode,
      if (origin != null) 'origin': origin,
      'images': images,
      if (defaultUnit != null) 'defaultUnit': defaultUnit,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (currency != null) 'currency': currency,
    };
  }

  String get formattedPrice {
    final cur = currency ?? 'VND';
    final curSymbol = cur == 'VND' ? 'đ' : cur;

    String formatNumber(num n) {
      return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    }

    if (minPrice != null && maxPrice != null) {
      if (minPrice == maxPrice) {
        return '${formatNumber(minPrice!)} $curSymbol';
      }
      return '${formatNumber(minPrice!)} - ${formatNumber(maxPrice!)} $curSymbol';
    } else if (minPrice != null) {
      return 'từ ${formatNumber(minPrice!)} $curSymbol';
    }
    return '';
  }
}

class SuggestProductsResponseDto {
  final List<ProductSuggestionItemDto> items;

  SuggestProductsResponseDto({required this.items});

  factory SuggestProductsResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    List<ProductSuggestionItemDto> itemsList = [];
    if (rawItems is List) {
      itemsList = rawItems
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductSuggestionItemDto.fromJson(e))
          .toList();
    }
    return SuggestProductsResponseDto(items: itemsList);
  }

  Map<String, dynamic> toJson() {
    return {'items': items.map((e) => e.toJson()).toList()};
  }
}
