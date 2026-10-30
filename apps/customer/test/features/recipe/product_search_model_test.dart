import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/recipe/data/models/product_search_model.dart';

void main() {
  group('ProductSearchModel Tests', () {
    test('ProductVariantDto deserializes correctly from Swagger JSON', () {
      final json = {
        'variantId': 'var-01',
        'productId': 'prod-01',
        'sku': 'TP-1234',
        'variantName': 'Túi 5kg',
        'unit': 'túi',
        'packSize': '5kg',
        'price': 180000,
        'originalPrice': 200000,
        'currency': 'VND',
        'stockQuantity': 50,
        'availableStock': 45,
        'isDefault': true,
        'status': 'ACTIVE',
      };

      final dto = ProductVariantDto.fromJson(json);
      expect(dto.variantId, 'var-01');
      expect(dto.productId, 'prod-01');
      expect(dto.sku, 'TP-1234');
      expect(dto.variantName, 'Túi 5kg');
      expect(dto.unit, 'túi');
      expect(dto.packSize, '5kg');
      expect(dto.price, 180000);
      expect(dto.originalPrice, 200000);
      expect(dto.isDefault, true);

      final map = dto.toJson();
      expect(map['variantId'], 'var-01');
      expect(map['price'], 180000);
    });

    test('ProductSearchItemDto parses fields and formats price correctly', () {
      final json = {
        'productId': 'prod-01',
        'supplierId': 'supp-01',
        'whoCategoryCode': 'STAPLES',
        'productName': 'Gạo ST25 Sóc Trăng',
        'productSlug': 'gao-st25-soc-trang',
        'description': 'Gạo ngon nhất thế giới',
        'images': ['https://example.com/gao.jpg'],
        'status': 'ACTIVE',
        'moderationStatus': 'APPROVED',
        'variants': [
          {
            'variantId': 'var-01',
            'productId': 'prod-01',
            'variantName': 'Túi 5kg',
            'unit': 'túi',
            'packSize': '5kg',
            'price': 180000,
          }
        ],
        'minPrice': 180000,
        'maxPrice': 250000,
        'currency': 'VND',
      };

      final item = ProductSearchItemDto.fromJson(json);
      expect(item.productId, 'prod-01');
      expect(item.supplierId, 'supp-01');
      expect(item.productName, 'Gạo ST25 Sóc Trăng');
      expect(item.primaryImage, 'https://example.com/gao.jpg');
      expect(item.displayUnit, '5kg');
      expect(item.formattedPrice, contains('180.000'));
      expect(item.formattedPrice, contains('250.000'));
    });

    test('SearchProductsResponseDto parses wrapper items and pagination', () {
      final json = {
        'items': [
          {
            'productId': 'prod-01',
            'supplierId': 'supp-01',
            'productName': 'Thịt bò Wagyu',
            'variants': [],
          }
        ],
        'total': 1,
        'limit': 20,
        'offset': 0,
      };

      final res = SearchProductsResponseDto.fromJson(json);
      expect(res.total, 1);
      expect(res.limit, 20);
      expect(res.offset, 0);
      expect(res.items.length, 1);
      expect(res.items.first.productName, 'Thịt bò Wagyu');
    });

    test('WhoCategoryDto parses correctly from Swagger and maps icons/labels', () {
      final json = {
        'code': 'MEAT_FISH_POULTRY',
        'name': 'Thịt, cá và gia cầm',
        'description': 'Các loại thịt tươi và hải sản',
        'examples': 'Thịt bò, cá hồi, tôm sú',
        'order': 4,
      };

      final cat = WhoCategoryDto.fromJson(json);
      expect(cat.code, 'MEAT_FISH_POULTRY');
      expect(cat.name, 'Thịt, cá và gia cầm');
      expect(cat.icon, '🥩');
      expect(cat.shortName, 'Thịt & Cá');
      expect(cat.order, 4);

      final map = cat.toJson();
      expect(map['code'], 'MEAT_FISH_POULTRY');
      expect(map['order'], 4);
    });

    test('ProductSuggestionItemDto and SuggestProductsResponseDto deserialize correctly', () {
      final json = {
        'items': [
          {
            'productId': 'sug-01',
            'productName': 'Cá Hồi Na Uy',
            'productSlug': 'ca-hoi-na-uy',
            'whoCategoryCode': 'MEAT_FISH_POULTRY',
            'images': ['https://example.com/salmon.jpg'],
            'defaultUnit': 'kg',
            'minPrice': 300000,
            'maxPrice': 350000,
            'currency': 'VND',
          }
        ]
      };

      final res = SuggestProductsResponseDto.fromJson(json);
      expect(res.items.length, 1);
      final item = res.items.first;
      expect(item.productId, 'sug-01');
      expect(item.productName, 'Cá Hồi Na Uy');
      expect(item.formattedPrice, contains('300.000'));
      expect(item.formattedPrice, contains('350.000'));
    });
  });
}
