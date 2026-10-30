import 'package:cookconnect/core/config/api_config.dart';
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/features/market/data/product_detail_model.dart';
import 'package:cookconnect/features/recipe/data/models/product_search_model.dart';

class ProductSearchService {
  final ApiClient _client;
  static List<WhoCategoryDto>? _cachedCategories;

  ProductSearchService({ApiClient? apiClient})
    : _client = apiClient ?? ApiClient();

  /// Searches products from Elasticsearch via /api/v1/products/search
  Future<SearchProductsResponseDto> searchProducts({
    String? query,
    String? whoCategoryCode,
    String? supplierId,
    String? status,
    int limit = 20,
    int offset = 0,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit, 'offset': offset};

    if (query != null && query.trim().isNotEmpty) {
      queryParams['query'] = query.trim();
    }
    if (whoCategoryCode != null && whoCategoryCode.isNotEmpty) {
      queryParams['whoCategoryCode'] = whoCategoryCode;
    }
    if (supplierId != null && supplierId.isNotEmpty) {
      queryParams['supplierId'] = supplierId;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _client.get(
      ApiConfig.productSearchPath,
      queryParams: queryParams,
      token: token,
    );

    final data = response['data'] ?? response;
    return SearchProductsResponseDto.fromJson(data as Map<String, dynamic>);
  }

  /// Fetches WHO food categories from /api/v1/products/categories
  Future<List<WhoCategoryDto>> getCategories({
    bool forceRefresh = false,
    String? token,
  }) async {
    if (!forceRefresh &&
        _cachedCategories != null &&
        _cachedCategories!.isNotEmpty) {
      return _cachedCategories!;
    }

    final response = await _client.get(
      ApiConfig.productCategoriesPath,
      token: token,
    );

    final data = response['data'] ?? response;
    if (data is List) {
      final categories =
          data
              .whereType<Map<String, dynamic>>()
              .map((e) => WhoCategoryDto.fromJson(e))
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      _cachedCategories = categories;
      return categories;
    }
    return [];
  }

  /// Autocomplete / typeahead suggestion items from /api/v1/products/suggest
  Future<List<ProductSuggestionItemDto>> suggestProducts({
    required String query,
    int limit = 10,
    String? token,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final response = await _client.get(
      ApiConfig.productSuggestPath,
      queryParams: {'query': trimmed, 'limit': limit},
      token: token,
    );

    final data = response['data'] ?? response;
    if (data is Map<String, dynamic>) {
      final suggestResp = SuggestProductsResponseDto.fromJson(data);
      return suggestResp.items;
    }
    return [];
  }

  /// Fetches product detail (incl. supplier info) from /api/v1/products/{id}
  Future<ProductDetailDto> getProductDetail(
    String productId, {
    String? token,
  }) async {
    final response = await _client.get(
      ApiConfig.productDetailPath(productId),
      token: token,
    );
    final data = response['data'] ?? response;
    return ProductDetailDto.fromJson(data as Map<String, dynamic>);
  }
}
