import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/features/menu/data/models/product_category.dart';

/// Storage abstraction for caching categories
abstract class CategoryCacheStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Secure storage implementation using iOS Keychain / Android KeyStore
class SecureCategoryCacheStorage implements CategoryCacheStorage {
  final FlutterSecureStorage _storage;

  SecureCategoryCacheStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }
}

/// In-memory storage implementation for unit tests and local isolation
class InMemoryCategoryCacheStorage implements CategoryCacheStorage {
  final Map<String, String> _memory = {};

  @override
  Future<String?> read(String key) async => _memory[key];

  @override
  Future<void> write(String key, String value) async {
    _memory[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _memory.remove(key);
  }

  void clear() => _memory.clear();
}

/// Cached wrapper with sliding expiration metadata
class CategoryCacheItem {
  final List<ProductCategory> data;
  final DateTime expiresAt;

  CategoryCacheItem({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'expires_at': expiresAt.toIso8601String(),
  };

  factory CategoryCacheItem.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    return CategoryCacheItem(
      data: rawList
          .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      expiresAt:
          DateTime.tryParse(json['expires_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Service that handles fetching food categories from Server with Sliding Expiration cache
class ProductCategoryService {
  static const String defaultCacheKey = 'cc_product_categories_cache';
  static const Duration defaultTtl = Duration(days: 1);

  final ApiClient _client;
  final CategoryCacheStorage _storage;
  final String _cacheKey;

  ProductCategoryService({
    ApiClient? apiClient,
    CategoryCacheStorage? storage,
    this._cacheKey = defaultCacheKey,
  }) : _client = apiClient ?? ApiClient(),
       _storage = storage ?? SecureCategoryCacheStorage();

  /// Retrieves categories using Sliding Expiration:
  /// - If cached and within valid period (1 day): "tái tạo" (renews) expiry date for another day and returns cached data.
  /// - If expired or not found: fetches fresh list from `/api/v1/products/categories`, saves to cache with 1 day TTL.
  /// - If server is unavailable (503/offline): falls back gracefully to stale cache or WHO standard defaults.
  Future<List<ProductCategory>> getCategories({
    bool forceRefresh = false,
    Duration ttl = defaultTtl,
  }) async {
    // 1. Check local cache first if not forced
    if (!forceRefresh) {
      final cachedItem = await _getCachedItem();
      if (cachedItem != null &&
          !cachedItem.isExpired &&
          cachedItem.data.isNotEmpty) {
        // Sliding Expiration: renew expiry date by adding TTL from now
        await _saveToCache(cachedItem.data, ttl);
        return cachedItem.data;
      }
    }

    // 2. Cache expired or not found -> Fetch from server
    try {
      final freshCategories = await _fetchFromApi();
      if (freshCategories.isNotEmpty) {
        await _saveToCache(freshCategories, ttl);
        return freshCategories;
      }
    } catch (_) {
      // Server down / maintenance tolerance (e.g. 503 Service Unavailable)
      // Attempt stale cache fallback
      final staleItem = await _getCachedItem();
      if (staleItem != null && staleItem.data.isNotEmpty) {
        return staleItem.data;
      }
    }

    // 3. Fallback to default WHO standard categories if both network & cache are unavailable
    return ProductCategory.defaultCategories;
  }

  /// Forces refreshing categories from backend and updates sliding expiration cache
  Future<List<ProductCategory>> refreshCategories({Duration ttl = defaultTtl}) {
    return getCategories(forceRefresh: true, ttl: ttl);
  }

  /// Fetches raw categories list from API endpoint
  Future<List<ProductCategory>> _fetchFromApi() async {
    final response = await _client.get(ApiConfig.productCategoriesPath);
    final rawData = response['data'];

    List<dynamic> list;
    if (rawData is List) {
      list = rawData;
    } else if (response['items'] is List) {
      list = response['items'] as List<dynamic>;
    } else {
      list = [];
    }

    final categories = list
        .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
        .toList();

    // Sort by order priority if specified
    categories.sort((a, b) => a.order.compareTo(b.order));
    return categories;
  }

  /// Saves categories to persistent storage with calculated expiration timestamp
  Future<void> _saveToCache(
    List<ProductCategory> categories,
    Duration ttl,
  ) async {
    final item = CategoryCacheItem(
      data: categories,
      expiresAt: DateTime.now().add(ttl),
    );
    await _storage.write(_cacheKey, jsonEncode(item.toJson()));
  }

  /// Reads current cached item if available
  Future<CategoryCacheItem?> _getCachedItem() async {
    try {
      final raw = await _storage.read(_cacheKey);
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CategoryCacheItem.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Read snapshot of current cache for diagnostics or testing
  Future<CategoryCacheItem?> getCachedSnapshot() => _getCachedItem();

  /// Clears stored category cache
  Future<void> clearCache() => _storage.delete(_cacheKey);
}
