import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/features/orders/data/models/seller_order.dart';

class OrdersApiService {
  final ApiClient _client;

  OrdersApiService({ApiClient? apiClient}) : _client = apiClient ?? ApiClient();

  Future<List<SellerOrder>> getOrders({
    required String token,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    final response = await _client.get(
      ApiConfig.ordersPath,
      token: token,
      queryParams: query,
    );

    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => SellerOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SellerOrder> getOrderDetail({
    required String token,
    required String orderId,
  }) async {
    final response = await _client.get(
      ApiConfig.orderDetailPath(orderId),
      token: token,
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return SellerOrder.fromJson(data);
  }

  Future<bool> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
  }) async {
    final response = await _client.patch(
      ApiConfig.orderStatusPath(orderId),
      token: token,
      body: {'status': status},
    );
    return response['statusCode'] != null && (response['statusCode'] as int) < 400;
  }
}
