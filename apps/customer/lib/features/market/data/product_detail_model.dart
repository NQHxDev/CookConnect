class ProductSupplierSummary {
  final String supplierId;
  final String supplierName;
  final String? supplierLogoUrl;
  final String? address;
  final String? city;
  final num? rating;
  final bool isVerified;

  const ProductSupplierSummary({
    required this.supplierId,
    required this.supplierName,
    this.supplierLogoUrl,
    this.address,
    this.city,
    this.rating,
    this.isVerified = false,
  });

  factory ProductSupplierSummary.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'];
    return ProductSupplierSummary(
      supplierId: json['supplierId']?.toString() ?? '',
      supplierName: json['supplierName']?.toString() ?? '',
      supplierLogoUrl: json['supplierLogoUrl']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      rating: rating is num ? rating : num.tryParse('$rating'),
      isVerified: json['isVerified'] == true,
    );
  }
}

/// Detail of a single product from GET /api/v1/products/{productId}.
class ProductDetailDto {
  final String productId;
  final String productName;
  final String? description;
  final String? origin;
  final String? storageCondition;
  final int? shelfLifeDays;
  final List<String> images;
  final int? orderCount;
  final int? soldCount;
  final ProductSupplierSummary? supplier;

  const ProductDetailDto({
    required this.productId,
    required this.productName,
    this.description,
    this.origin,
    this.storageCondition,
    this.shelfLifeDays,
    this.images = const [],
    this.orderCount,
    this.soldCount,
    this.supplier,
  });

  factory ProductDetailDto.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) =>
        v is num ? v.toInt() : (v is String ? int.tryParse(v) : null);
    final rawImages = json['images'];
    final rawSupplier = json['supplier'];
    return ProductDetailDto(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      description: json['description']?.toString(),
      origin: json['origin']?.toString(),
      storageCondition: json['storageCondition']?.toString(),
      shelfLifeDays: toInt(json['shelfLifeDays']),
      images: rawImages is List
          ? rawImages.map((e) => e.toString()).toList()
          : const [],
      orderCount: toInt(json['orderCount']),
      soldCount: toInt(json['soldCount']),
      supplier: rawSupplier is Map<String, dynamic>
          ? ProductSupplierSummary.fromJson(rawSupplier)
          : null,
    );
  }
}
