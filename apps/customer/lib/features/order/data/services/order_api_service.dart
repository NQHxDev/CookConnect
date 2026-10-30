import 'package:cookconnect/core/config/api_config.dart';
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/core/network/api_exception.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/order/data/models/order_model.dart';
import 'package:flutter/foundation.dart';

class OrderResult<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final int statusCode;
  final int? total;

  OrderResult.success(
    this.data, {
    this.statusCode = 200,
    this.message,
    this.total,
  }) : isSuccess = true;

  OrderResult.failure(
    this.message, {
    this.statusCode = 400,
    this.data,
    this.total,
  }) : isSuccess = false;
}

class OrderApiService {
  static final OrderApiService instance = OrderApiService();

  final ApiClient _client;

  OrderApiService({ApiClient? apiClient}) : _client = apiClient ?? ApiClient();

  Future<String?> _getToken(String? token) async {
    return token ?? await AuthService.instance.getValidAccessToken();
  }

  /// Create a new order (POST /api/v1/orders)
  Future<OrderResult<OrderDto>> createOrder(
    CreateOrderDto dto, {
    String? accessToken,
  }) async {
    try {
      final token = await _getToken(accessToken);
      final response = await _client.post(
        ApiConfig.ordersPath,
        body: dto.toJson(),
        token: token,
      );

      final data = response['data'] as Map<String, dynamic>? ?? response;
      final order = OrderDto.fromJson(data);
      return OrderResult.success(
        order,
        statusCode: (response['statusCode'] as num?)?.toInt() ?? 201,
        message: response['message']?.toString(),
      );
    } on ApiException catch (e) {
      debugPrint('OrderApiService.createOrder ApiException: ${e.message}');
      return OrderResult.failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      debugPrint('OrderApiService.createOrder error: $e');
      return OrderResult.failure('Không thể tạo đơn hàng: $e');
    }
  }

  /// Get customer's orders (GET /api/v1/orders/my-orders)
  Future<OrderResult<List<OrderDto>>> getMyOrders({
    int page = 1,
    int limit = 20,
    String? accessToken,
  }) async {
    try {
      final token = await _getToken(accessToken);
      final response = await _client.get(
        ApiConfig.myOrdersPath,
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
        token: token,
      );

      final dynamic rawData = response['data'] ?? response;
      List<dynamic> itemsList = [];
      int? totalCount;

      if (rawData is List) {
        itemsList = rawData;
      } else if (rawData is Map) {
        totalCount = (rawData['total'] as num?)?.toInt();
        if (rawData['orders'] is List) {
          itemsList = rawData['orders'] as List<dynamic>;
        } else if (rawData['items'] is List) {
          itemsList = rawData['items'] as List<dynamic>;
        }
      }

      final orders = itemsList
          .map((item) => OrderDto.fromJson(item as Map<String, dynamic>))
          .toList();

      return OrderResult.success(orders, total: totalCount);
    } on ApiException catch (e) {
      debugPrint('OrderApiService.getMyOrders ApiException: ${e.message}');
      return OrderResult.failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      debugPrint('OrderApiService.getMyOrders error: $e');
      return OrderResult.failure('Không thể tải danh sách đơn hàng: $e');
    }
  }

  /// Get order detail (GET /api/v1/orders/:id)
  Future<OrderResult<OrderDto>> getOrderDetail(
    String orderId, {
    String? accessToken,
  }) async {
    try {
      final token = await _getToken(accessToken);
      final response = await _client.get(
        ApiConfig.orderDetailPath(orderId),
        token: token,
      );

      final data = response['data'] as Map<String, dynamic>? ?? response;
      final order = OrderDto.fromJson(data);
      return OrderResult.success(order);
    } on ApiException catch (e) {
      debugPrint('OrderApiService.getOrderDetail ApiException: ${e.message}');
      return OrderResult.failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      debugPrint('OrderApiService.getOrderDetail error: $e');
      return OrderResult.failure('Không thể tải chi tiết đơn hàng: $e');
    }
  }

  /// Cancel order (POST /api/v1/orders/:id/cancel)
  Future<OrderResult<OrderDto>> cancelOrder(
    String orderId, {
    String? reason,
    String? accessToken,
  }) async {
    try {
      final token = await _getToken(accessToken);
      final response = await _client.post(
        ApiConfig.orderCancelPath(orderId),
        body: {
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
        token: token,
      );

      final data = response['data'] as Map<String, dynamic>? ?? response;
      final order = OrderDto.fromJson(data);
      return OrderResult.success(order);
    } on ApiException catch (e) {
      debugPrint('OrderApiService.cancelOrder ApiException: ${e.message}');
      return OrderResult.failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      debugPrint('OrderApiService.cancelOrder error: $e');
      return OrderResult.failure('Không thể hủy đơn hàng: $e');
    }
  }

  /// Get payment details by Order ID (GET /api/v1/payments/order/:orderId)
  Future<OrderResult<Map<String, dynamic>>> getOrderPayment(
    String orderId, {
    String? accessToken,
  }) async {
    try {
      final token = await _getToken(accessToken);
      final response = await _client.get(
        ApiConfig.orderPaymentPath(orderId),
        token: token,
      );

      final data = response['data'] as Map<String, dynamic>? ?? response;
      return OrderResult.success(data);
    } on ApiException catch (e) {
      return OrderResult.failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return OrderResult.failure('Không thể tải thông tin thanh toán: $e');
    }
  }
}
