/// Standard WHO culinary food category DTO returned by /api/v1/products/categories.
class ProductCategory {
  final String code;
  final String name;
  final String description;
  final String examples;
  final int order;

  const ProductCategory({
    required this.code,
    required this.name,
    required this.description,
    required this.examples,
    required this.order,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    final rawCode = json['code'];
    String codeStr = '';
    if (rawCode is Map) {
      codeStr = rawCode['code']?.toString() ?? '';
    } else {
      codeStr = rawCode?.toString() ?? '';
    }

    return ProductCategory(
      code: codeStr,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      examples: json['examples']?.toString() ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'description': description,
    'examples': examples,
    'order': order,
  };

  ProductCategory copyWith({
    String? code,
    String? name,
    String? description,
    String? examples,
    int? order,
  }) {
    return ProductCategory(
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      examples: examples ?? this.examples,
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductCategory &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name &&
          order == other.order;

  @override
  int get hashCode => Object.hash(code, name, order);

  @override
  String toString() =>
      'ProductCategory(code: $code, name: $name, order: $order)';

  /// Finds category by WHO enum code
  static ProductCategory? findByCode(String? code) {
    if (code == null || code.isEmpty) return null;
    return defaultCategories.where((c) => c.code.toUpperCase() == code.toUpperCase()).firstOrNull;
  }

  /// Maps a custom name or foodCategory string to a valid WHO category
  static ProductCategory mapToWhoCategory(String? categoryName) {
    if (categoryName == null || categoryName.trim().isEmpty) {
      return defaultCategories.first;
    }
    final lower = categoryName.trim().toLowerCase();

    for (final c in defaultCategories) {
      if (c.code.toLowerCase() == lower || c.name.toLowerCase() == lower) {
        return c;
      }
    }

    if (lower.contains('gạo') ||
        lower.contains('ngô') ||
        lower.contains('khoai') ||
        lower.contains('bột') ||
        lower.contains('sắn') ||
        lower.contains('tinh bột')) {
      return findByCode('STAPLES')!;
    }
    if (lower.contains('đậu') ||
        lower.contains('hạt') ||
        lower.contains('lạc') ||
        lower.contains('vừng') ||
        lower.contains('đậu hũ')) {
      return findByCode('LEGUMES_NUTS_SEEDS')!;
    }
    if (lower.contains('sữa') ||
        lower.contains('phô mai') ||
        lower.contains('kem')) {
      return findByCode('DAIRY')!;
    }
    if (lower.contains('thịt') ||
        lower.contains('cá') ||
        lower.contains('tôm') ||
        lower.contains('mực') ||
        lower.contains('hải sản') ||
        lower.contains('gà') ||
        lower.contains('vịt') ||
        lower.contains('heo') ||
        lower.contains('bò') ||
        lower.contains('cừu')) {
      return findByCode('MEAT_FISH_POULTRY')!;
    }
    if (lower.contains('trứng')) {
      return findByCode('EGGS')!;
    }
    if (lower.contains('cà rốt') ||
        lower.contains('bí') ||
        lower.contains('vitamin a') ||
        lower.contains('đu đủ') ||
        lower.contains('xoài') ||
        lower.contains('rau ngót') ||
        lower.contains('rau muống')) {
      return findByCode('VITAMIN_A_FRUITS_VEG')!;
    }
    if (lower.contains('dầu') ||
        lower.contains('mỡ') ||
        lower.contains('bơ') ||
        lower.contains('chất béo')) {
      return findByCode('FATS_OILS')!;
    }

    return findByCode('OTHER_FRUITS_VEG')!;
  }

  /// Fallback exact 8 WHO categories matching backend server /api/v1/products/categories
  static const List<ProductCategory> defaultCategories = [
    ProductCategory(
      code: 'STAPLES',
      name: 'Lương thực chính (Tinh bột)',
      description:
          'Gạo, ngô, lúa mì, khoai lang, khoai tây, sắn và các loại củ giàu tinh bột khác.',
      examples:
          'Gạo tẻ, gạo lứt, ngô ngọt, khoai lang mật, khoai tây, bột mì, bột sắn dây',
      order: 1,
    ),
    ProductCategory(
      code: 'LEGUMES_NUTS_SEEDS',
      name: 'Các loại đậu và hạt',
      description:
          'Đậu nành, đậu phộng, đậu xanh, đậu đen, hạt điều, hạt hạnh nhân...',
      examples:
          'Đậu đen xanh lòng, đậu xanh tách vỏ, hạt điều rang muối, đậu phộng sẻ, hạt sen khô',
      order: 2,
    ),
    ProductCategory(
      code: 'DAIRY',
      name: 'Sữa và các sản phẩm từ sữa',
      description: 'Sữa tươi, sữa chua, phô mai (ngoại trừ bơ).',
      examples:
          'Sữa tươi thanh trùng, sữa tiệt trùng, sữa chua không đường, phô mai cheddar, mozzarella',
      order: 3,
    ),
    ProductCategory(
      code: 'MEAT_FISH_POULTRY',
      name: 'Thịt, cá và gia cầm',
      description:
          'Thịt bò, thịt heo, thịt gà, vịt, các loại cá, tôm, cua và hải sản.',
      examples:
          'Thịt bò phi lê, thịt ba rọi heo, ức gà ta, cá hồi phi lê, tôm sú sống, cua biển',
      order: 4,
    ),
    ProductCategory(
      code: 'EGGS',
      name: 'Trứng',
      description: 'Trứng gà, trứng vịt, trứng cút...',
      examples: 'Trứng gà ta thảo mộc, trứng vịt thả đồng, trứng cút tươi',
      order: 5,
    ),
    ProductCategory(
      code: 'VITAMIN_A_FRUITS_VEG',
      name: 'Rau củ và quả giàu Vitamin A',
      description:
          'Cà rốt, bí ngô, khoai lang ruột vàng, đu đủ, xoài chín, rau ngót, rau muống.',
      examples:
          'Cà rốt hữu cơ Đà Lạt, bí đỏ hồ lô, đu đủ chín cây, rau ngót ta, rau muống non',
      order: 6,
    ),
    ProductCategory(
      code: 'OTHER_FRUITS_VEG',
      name: 'Rau củ và quả khác',
      description: 'Bắp cải, dưa leo, cà chua, chuối, táo...',
      examples:
          'Bắp cải trắng, dưa leo baby, cà chua bi cherry, chuối già Nam Mỹ, nấm hương tươi',
      order: 7,
    ),
    ProductCategory(
      code: 'FATS_OILS',
      name: 'Chất béo và dầu mỡ',
      description: 'Dầu thực vật, mỡ động vật, bơ.',
      examples:
          'Dầu mè nguyên chất, dầu đậu nành ép lạnh, mỡ heo sạch, bơ động vật lạt',
      order: 8,
    ),
  ];
}
