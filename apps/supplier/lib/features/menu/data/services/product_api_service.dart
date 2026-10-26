import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/features/menu/data/models/product_dtos.dart';

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

  /// Lists supplier products matching filter criteria.
  /// Endpoint: `GET /api/v1/products`
  Future<List<ProductItemDto>> listProducts({
    required String token,
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final uri = Uri.parse(ApiConfig.productsPath).replace(queryParameters: queryParams);
    final response = await _client.get(uri.toString(), token: token);

    final rawItems = response['data']?['items'] ?? response['items'] ?? response['data'];
    if (rawItems is List) {
      return rawItems
          .map((e) => ProductItemDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Uploads a single local image to Media Service via `POST /api/v1/media/upload`.
  /// If path is already a remote URL (http/https), returns it as-is.
  /// If server is in maintenance or offline, gracefully returns the path or fallback.
  Future<String> uploadMediaImage({
    required String token,
    required String imagePath,
    String folder = 'cookconnect/products',
  }) async {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    try {
      final file = File(imagePath);
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
    } catch (e) {
      debugPrint('Media upload warning: $e');
    }

    return imagePath;
  }

  /// Uploads multiple product images and returns list of image URLs.
  Future<List<String>> uploadMultipleImages({
    required String token,
    required List<String> imagePaths,
  }) async {
    final List<String> resultUrls = [];
    for (final path in imagePaths) {
      final url = await uploadMediaImage(token: token, imagePath: path);
      resultUrls.add(url);
    }
    return resultUrls;
  }
}
