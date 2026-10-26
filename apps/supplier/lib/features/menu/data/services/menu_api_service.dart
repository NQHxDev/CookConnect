import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/features/menu/data/models/menu_item.dart';
import 'package:cook_connect_seller/features/menu/data/models/product_category.dart';
import 'package:cook_connect_seller/features/menu/data/models/product_dtos.dart';
import 'package:cook_connect_seller/features/menu/data/services/product_api_service.dart';
import 'package:cook_connect_seller/features/menu/data/services/product_category_service.dart';

class MenuApiService {
  final ApiClient _client;
  final ProductCategoryService _categoryService;
  final ProductApiService _productApiService;

  MenuApiService({
    ApiClient? apiClient,
    ProductCategoryService? categoryService,
    ProductApiService? productApiService,
  })  : _client = apiClient ?? ApiClient(),
        _categoryService =
            categoryService ??
            ProductCategoryService(apiClient: apiClient ?? ApiClient()),
        _productApiService =
            productApiService ??
            ProductApiService(apiClient: apiClient ?? ApiClient());

  ProductApiService get productApiService => _productApiService;
  ProductCategoryService get categoryService => _categoryService;

  /// Retrieves standard WHO food categories with Sliding Expiration caching
  Future<List<ProductCategory>> getProductCategories({
    bool forceRefresh = false,
  }) {
    return _categoryService.getCategories(forceRefresh: forceRefresh);
  }

  /// Create food supply product with 1 of 8 WHO categories (POST /api/v1/products)
  Future<ProductItemDto> createProduct({
    required String token,
    required CreateProductDto dto,
  }) {
    return _productApiService.createProduct(token: token, dto: dto);
  }

  Future<List<MenuItem>> getMenuItems({required String token}) async {
    final response = await _client.get(ApiConfig.menuItemsPath, token: token);
    final list = response['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MenuItem> createMenuItem({
    required String token,
    required Map<String, dynamic> itemData,
  }) async {
    final response = await _client.post(
      ApiConfig.menuItemsPath,
      token: token,
      body: itemData,
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return MenuItem.fromJson(data);
  }

  Future<bool> updateMenuItem({
    required String token,
    required String itemId,
    required Map<String, dynamic> updates,
  }) async {
    final response = await _client.put(
      ApiConfig.menuItemDetailPath(itemId),
      token: token,
      body: updates,
    );
    return response['statusCode'] != null &&
        (response['statusCode'] as int) < 400;
  }

  Future<bool> deleteMenuItem({
    required String token,
    required String itemId,
  }) async {
    final response = await _client.delete(
      ApiConfig.menuItemDetailPath(itemId),
      token: token,
    );
    return response['statusCode'] != null &&
        (response['statusCode'] as int) < 400;
  }
}
