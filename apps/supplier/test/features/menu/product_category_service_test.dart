import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/features/menu/data/models/product_category.dart';
import 'package:cook_connect_seller/features/menu/data/services/product_category_service.dart';

void main() {
  late InMemoryCategoryCacheStorage storage;
  late int apiCallCount;

  final sampleApiResponse = [
    {
      'code': 'STAPLES',
      'name': 'Lương thực chính (Tinh bột)',
      'description': 'Gạo, ngô, lúa mì, khoai lang...',
      'examples': 'Gạo tẻ, gạo lứt, ngô ngọt',
      'order': 1,
    },
    {
      'code': 'FLESH_FOODS',
      'name': 'Thịt tươi sống & Thủy hải sản',
      'description': 'Thịt gia súc gia cầm, cá tôm...',
      'examples': 'Thịt bò, ức gà, tôm sú',
      'order': 2,
    },
  ];

  setUp(() {
    storage = InMemoryCategoryCacheStorage();
    apiCallCount = 0;
  });

  ApiClient createMockClient({int statusCode = 200, dynamic body}) {
    return ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/api/v1/products/categories') {
          apiCallCount++;
          return http.Response(
            jsonEncode(body ?? sampleApiResponse),
            statusCode,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      }),
    );
  }

  test(
    '1. First call fetches from API and caches with 1-day expiration',
    () async {
      final client = createMockClient();
      final service = ProductCategoryService(
        apiClient: client,
        storage: storage,
      );

      final categories = await service.getCategories();

      expect(apiCallCount, equals(1));
      expect(categories.length, equals(2));
      expect(categories.first.code, equals('STAPLES'));

      // Verify cache has been written with sliding expiry (~ 1 day in future)
      final snapshot = await service.getCachedSnapshot();
      expect(snapshot, isNotNull);
      expect(snapshot!.data.length, equals(2));
      expect(snapshot.isExpired, isFalse);
      expect(
        snapshot.expiresAt.difference(DateTime.now()).inHours,
        inInclusiveRange(23, 24),
      );
    },
  );

  test(
    '2. Subsequent call within 1 day retrieves from cache and slides (renews) expiry',
    () async {
      final client = createMockClient();
      final service = ProductCategoryService(
        apiClient: client,
        storage: storage,
      );

      // Initial fetch
      await service.getCategories();
      expect(apiCallCount, equals(1));

      // Manually set cache expiration to 3 hours in the future (still valid)
      final initialExpiry = DateTime.now().add(const Duration(hours: 3));
      final intermediateItem = CategoryCacheItem(
        data: [
          const ProductCategory(
            code: 'STAPLES',
            name: 'Lương thực chính (Tinh bột)',
            description: 'Desc',
            examples: 'Examples',
            order: 1,
          ),
        ],
        expiresAt: initialExpiry,
      );
      await storage.write(
        ProductCategoryService.defaultCacheKey,
        jsonEncode(intermediateItem.toJson()),
      );

      // Call getCategories() again while still valid
      final categories = await service.getCategories();

      // No new API call made!
      expect(apiCallCount, equals(1));
      expect(categories.length, equals(1));

      // Expiry was renewed/slid forward to 24 hours from now!
      final updatedSnapshot = await service.getCachedSnapshot();
      expect(updatedSnapshot, isNotNull);
      expect(updatedSnapshot!.expiresAt.isAfter(initialExpiry), isTrue);
      expect(
        updatedSnapshot.expiresAt.difference(DateTime.now()).inHours,
        inInclusiveRange(23, 24),
      );
    },
  );

  test('3. Expired cache triggers fresh API call and updates cache', () async {
    final client = createMockClient();
    final service = ProductCategoryService(apiClient: client, storage: storage);

    // Seed expired cache (> 1 day ago)
    final expiredItem = CategoryCacheItem(
      data: [
        const ProductCategory(
          code: 'OLD',
          name: 'Danh mục cũ',
          description: 'Desc',
          examples: 'Examples',
          order: 99,
        ),
      ],
      expiresAt: DateTime.now().subtract(const Duration(hours: 25)),
    );
    await storage.write(
      ProductCategoryService.defaultCacheKey,
      jsonEncode(expiredItem.toJson()),
    );

    // Call getCategories()
    final categories = await service.getCategories();

    // Fresh API call was triggered!
    expect(apiCallCount, equals(1));
    expect(categories.length, equals(2));
    expect(categories.first.code, equals('STAPLES'));

    // Cache updated with new expiration
    final updatedSnapshot = await service.getCachedSnapshot();
    expect(updatedSnapshot!.isExpired, isFalse);
    expect(updatedSnapshot.data.first.code, equals('STAPLES'));
  });

  test(
    '4. Graceful fallback to default WHO categories when server returns 503 maintenance',
    () async {
      final client = createMockClient(
        statusCode: 503,
        body: {'message': 'Service Unavailable'},
      );
      final service = ProductCategoryService(
        apiClient: client,
        storage: storage,
      );

      // Call with server down and no cache
      final categories = await service.getCategories();

      // Returns standard WHO categories without throwing
      expect(categories.isNotEmpty, isTrue);
      expect(
        categories.length,
        equals(ProductCategory.defaultCategories.length),
      );
      expect(categories.any((c) => c.code == 'STAPLES'), isTrue);
    },
  );

  test(
    '6. Stale cache fallback when server is unavailable after expiration',
    () async {
      final client = createMockClient(
        statusCode: 503,
        body: {'message': 'Service Unavailable'},
      );
      final service = ProductCategoryService(
        apiClient: client,
        storage: storage,
      );

      // Save expired cache
      final staleItem = CategoryCacheItem(
        data: [
          const ProductCategory(
            code: 'STALE',
            name: 'Danh mục cũ còn lưu',
            description: 'Desc',
            examples: 'Examples',
            order: 1,
          ),
        ],
        expiresAt: DateTime.now().subtract(const Duration(hours: 30)),
      );
      await storage.write(
        ProductCategoryService.defaultCacheKey,
        jsonEncode(staleItem.toJson()),
      );

      // Server is down, but we have stale cache -> should return stale data safely
      final categories = await service.getCategories();
      expect(categories.length, equals(1));
      expect(categories.first.code, equals('STALE'));
    },
  );

  test('7. Clear cache removes cached item from storage', () async {
    final client = createMockClient();
    final service = ProductCategoryService(apiClient: client, storage: storage);

    await service.getCategories();
    expect(await service.getCachedSnapshot(), isNotNull);

    await service.clearCache();
    expect(await service.getCachedSnapshot(), isNull);
  });

  test('5. Force refresh bypasses cache and updates stored data', () async {
    final client = createMockClient();
    final service = ProductCategoryService(apiClient: client, storage: storage);

    // Fetch initially
    await service.getCategories();
    expect(apiCallCount, equals(1));

    // Force refresh
    await service.refreshCategories();
    expect(apiCallCount, equals(2));
  });
}
