import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/core/network/api_exception.dart';
import 'package:cook_connect_seller/features/menu/data/models/product_dtos.dart';
export 'package:cook_connect_seller/features/menu/data/models/product_dtos.dart';

/// Service for Supplier raw ingredient & culinary food product management
/// integrated with backend /api/v1/products and /api/v1/media.
class ProductApiService {
  final ApiClient _client;

  ProductApiService({ApiClient? apiClient})
      : _client = apiClient ?? ApiClient();

  /// Registers a new raw ingredient / food supply product according to WHO food categories.
  /// Endpoint: `POST /api/v1/products`
  /// Requires authenticated Bearer token.
  Future<ProductItemDto> createProduct({
    required String token,
    required CreateProductDto dto,
  }) async {
    final response = await _client.post(
      ApiConfig.productsPath,
      token: token,
      body: dto.toJson(),
    );

    final data = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;

    return ProductItemDto.fromJson(data);
  }

  /// Updates product attributes.
  /// Endpoint: `PATCH /api/v1/products/{productId}`
  Future<ProductItemDto> updateProduct({
    required String token,
    required String productId,
    required UpdateProductDto dto,
  }) async {
    final response = await _client.patch(
      ApiConfig.productDetailPath(productId),
      token: token,
      body: dto.toJson(),
    );

    final data = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;

    return ProductItemDto.fromJson(data);
  }

  /// Submits product for moderation review.
  /// Endpoint: `POST /api/v1/products/{productId}/submit-review`
  Future<ProductItemDto> submitProductForReview({
    required String token,
    required String productId,
  }) async {
    final response = await _client.post(
      ApiConfig.productSubmitReviewPath(productId),
      token: token,
    );

    final data = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;

    return ProductItemDto.fromJson(data);
  }

  /// Updates product operational status (ACTIVE / INACTIVE).
  /// Endpoint: `PATCH /api/v1/products/{productId}/status`
  Future<bool> updateProductStatus({
    required String token,
    required String productId,
    required String status,
  }) async {
    await _client.patch(
      ApiConfig.productStatusPath(productId),
      token: token,
      body: {'status': status},
    );
    return true;
  }

  /// Adjust warehouse stock level for a product variant.
  /// Endpoint: `POST /api/v1/products/variants/{variantId}/stock`
  Future<Map<String, dynamic>> adjustStock({
    required String token,
    required String variantId,
    required int quantityDelta,
    String movementType = 'ADJUSTMENT',
    String? reason,
  }) async {
    final body = <String, dynamic>{
      'quantityDelta': quantityDelta,
      'movementType': movementType,
    };
    if (reason != null && reason.trim().isNotEmpty) {
      body['reason'] = reason.trim();
    }
    return await _client.post(
      ApiConfig.productVariantStockPath(variantId),
      token: token,
      body: body,
    );
  }

  /// Retrieves detailed product by ID including packaging variants.
  /// Endpoint: `GET /api/v1/products/{productId}`
  Future<ProductItemDto> getProductById({
    String? token,
    required String productId,
  }) async {
    final response = await _client.get(
      ApiConfig.productDetailPath(productId),
      token: token,
    );
    final data = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;
    return ProductItemDto.fromJson(data);
  }

  /// Deletes or inactives a product.
  /// If DELETE endpoint is available it calls DELETE, otherwise updates status to INACTIVE.
  Future<bool> deleteProduct({
    required String token,
    required String productId,
  }) async {
    try {
      await updateProductStatus(
        token: token,
        productId: productId,
        status: 'INACTIVE',
      );
      return true;
    } catch (e) {
      debugPrint('deleteProduct error: $e');
      rethrow;
    }
  }

  /// Lists supplier products matching filter criteria.
  /// Endpoint: `GET /api/v1/products`
  ///
  /// Note: Backend Swagger contract requires both `status` and `moderationStatus`.
  /// - `status`: 'DRAFT', 'ACTIVE', 'INACTIVE' (default: 'ACTIVE')
  /// - `moderationStatus`: 'DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'EDIT_PENDING_APPROVAL', 'SUSPENDED' (default: 'APPROVED')
  Future<List<ProductItemDto>> listProducts({
    String? token,
    int page = 1,
    int limit = 50,
    int offset = 0,
    String? status,
    String? moderationStatus,
    String? whoCategoryCode,
    String? search,
    String? supplierId,
  }) async {
    final effectiveStatus = (status != null && status.isNotEmpty)
        ? status.toUpperCase()
        : ProductStatus.active.value;
    final effectiveModeration = (moderationStatus != null && moderationStatus.isNotEmpty)
        ? moderationStatus.toUpperCase()
        : ProductModerationStatus.approved.value;

    final queryParams = <String, dynamic>{
      'status': effectiveStatus,
      'moderationStatus': effectiveModeration,
      'limit': limit,
      'offset': offset > 0 ? offset : (page - 1) * limit,
    };
    if (whoCategoryCode != null && whoCategoryCode.isNotEmpty) {
      queryParams['whoCategoryCode'] = whoCategoryCode;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (supplierId != null && supplierId.isNotEmpty) {
      queryParams['supplierId'] = supplierId;
    }

    final response = await _client.get(
      ApiConfig.productsPath,
      queryParams: queryParams,
      token: token,
    );

    final rawItems = response['data']?['items'] ?? response['items'] ?? response['data'];
    if (rawItems is List) {
      return rawItems
          .map((e) => ProductItemDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetches products specifically for a single ProductCategoryType tab.
  /// Minimizes requests to 1-2 status pairs instead of 8 to avoid rate limits (429 Too Many Requests)
  /// when the merchant is actively viewing or refreshing a specific category.
  Future<List<ProductItemDto>> fetchProductsForCategory({
    required ProductCategoryType category,
    String? token,
    String? supplierId,
    String? whoCategoryCode,
    String? search,
    int limit = 100,
  }) async {
    final pairs = ProductStatusQueryPair.pairsForCategory(category);
    final results = await Future.wait(
      pairs.map((pair) => listProducts(
        token: token,
        supplierId: supplierId,
        whoCategoryCode: whoCategoryCode,
        search: search,
        status: pair.status,
        moderationStatus: pair.moderationStatus,
        limit: limit,
      )),
    );

    final map = <String, ProductItemDto>{};
    for (final list in results) {
      for (final item in list) {
        map[item.productId] = item;
      }
    }
    return map.values.toList();
  }

  /// Fetches all products of a supplier across all Swagger operational & moderation status pairs
  /// (e.g. ACTIVE + APPROVED, INACTIVE + APPROVED, DRAFT + PENDING_APPROVAL, etc.)
  /// to provide a complete catalog for all tabs in MenuScreen.
  Future<List<ProductItemDto>> fetchAllSupplierProducts({
    String? token,
    String? supplierId,
    String? whoCategoryCode,
    String? search,
    int limitPerStatus = 100,
  }) async {
    final errors = <Object>[];
    final futures = ProductStatusQueryPair.allSupplierPairs.map((pair) async {
      try {
        return await listProducts(
          token: token,
          supplierId: supplierId,
          whoCategoryCode: whoCategoryCode,
          search: search,
          status: pair.status,
          moderationStatus: pair.moderationStatus,
          limit: limitPerStatus,
        );
      } catch (e) {
        errors.add(e);
        debugPrint('Query pair failed (${pair.status}, ${pair.moderationStatus}): $e');
        if (e is ApiException && e.statusCode == 429) {
          rethrow; // Do not swallow 429 Too Many Requests!
        }
        return <ProductItemDto>[];
      }
    });

    final results = await Future.wait(futures);
    if (errors.length == ProductStatusQueryPair.allSupplierPairs.length && errors.isNotEmpty) {
      throw errors.first;
    }

    final map = <String, ProductItemDto>{};
    for (final list in results) {
      for (final item in list) {
        map[item.productId] = item;
      }
    }
    return map.values.toList();
  }

  /// Uploads a single local image to Media Service via `POST /api/v1/media/upload`.
  /// If path is already a remote URL (http/https), returns it as-is.
  Future<String> uploadMediaImage({
    required String token,
    required String imagePath,
    String folder = 'cookconnect/products',
  }) async {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    String cleanPath = imagePath;
    if (cleanPath.startsWith('file://')) {
      cleanPath = cleanPath.substring(7);
    }

    final file = File(cleanPath);
    if (!await file.exists()) {
      return imagePath;
    }

    final bytes = await file.readAsBytes();
    final ext = imagePath.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg';
    if (ext == 'png') {
      mimeType = 'image/png';
    } else if (ext == 'webp') {
      mimeType = 'image/webp';
    } else if (ext == 'gif') {
      mimeType = 'image/gif';
    }

    final base64String = 'data:$mimeType;base64,${base64Encode(bytes)}';
    final fileName = imagePath.split('/').last;

    final body = {
      'fileBase64': base64String,
      'fileName': fileName,
      'mimeType': mimeType,
      'type': 'IMAGE',
      'folder': folder,
    };

    final response = await _client.post(
      ApiConfig.mediaUploadPath,
      token: token,
      body: body,
    );

    final url = response['data']?['url']?.toString() ??
        response['data']?['secure_url']?.toString() ??
        response['url']?.toString();

    if (url != null && url.isNotEmpty) {
      return url;
    }

    throw ApiException(
      statusCode: response['statusCode'] as int? ?? 500,
      message: response['message']?.toString() ?? 'Không nhận được đường dẫn ảnh từ máy chủ',
    );
  }

  /// Uploads multiple product images and returns list of image URLs.
  Future<List<String>> uploadMultipleImages({
    required String token,
    required List<String> imagePaths,
    void Function(int current, int total)? onProgress,
  }) async {
    final List<String> resultUrls = [];
    final total = imagePaths.length;
    for (int i = 0; i < total; i++) {
      onProgress?.call(i + 1, total);
      final path = imagePaths[i];
      final url = await uploadMediaImage(token: token, imagePath: path);
      resultUrls.add(url);
    }
    return resultUrls;
  }
}
