import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/features/orders/data/models/seller_order.dart';

class SupplierOrdersResult {
  final List<SellerOrder> orders;
  final int totalItems;
  final int shippingCount;
  final int needsActionCount;

  SupplierOrdersResult({
    required this.orders,
    this.totalItems = 0,
    this.shippingCount = 0,
    this.needsActionCount = 0,
  });
}

class OrdersApiService {
  final ApiClient _client;

  OrdersApiService({ApiClient? apiClient}) : _client = apiClient ?? ApiClient();

  /// Retrieve supplier orders with pagination, group filter, dateRange, and badge metrics
  Future<SupplierOrdersResult> getSupplierOrders({
    required String token,
    String? status,
    String? group,
    String? search,
    String? dateRange,
    int page = 1,
    int limit = 50,
  }) async {
    final query = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    if (group != null && group.isNotEmpty) {
      query['group'] = group;
    }
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    if (dateRange != null && dateRange.isNotEmpty) {
      query['dateRange'] = dateRange;
    }

    final response = await _client.get(
      ApiConfig.ordersPath,
      token: token,
      queryParams: query,
    );

    final data = response['data'] as Map<String, dynamic>? ?? response;
    final itemsList = (data['items'] as List<dynamic>?) ??
        (response['items'] as List<dynamic>?) ??
        (response['data'] is List ? response['data'] as List<dynamic> : <dynamic>[]);

    final orders = itemsList
        .map((e) => SellerOrder.fromJson(e as Map<String, dynamic>))
        .toList();

    final summary = data['summary'] as Map<String, dynamic>?;
    final pagination = data['pagination'] as Map<String, dynamic>?;

    return SupplierOrdersResult(
      orders: orders,
      totalItems: (pagination?['totalItems'] as num?)?.toInt() ?? orders.length,
      shippingCount: (summary?['shippingCount'] as num?)?.toInt() ?? 0,
      needsActionCount: (summary?['needsActionCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Backwards-compatible getOrders method returning plain `List<SellerOrder>`
  Future<List<SellerOrder>> getOrders({
    required String token,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await getSupplierOrders(
      token: token,
      status: status,
      page: page,
      limit: limit,
    );
    return result.orders;
  }

  Future<SellerOrder> getOrderDetail({
    required String token,
    required String orderId,
  }) async {
    final response = await _client.get(
      ApiConfig.orderDetailPath(orderId),
      token: token,
    );
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return SellerOrder.fromJson(data);
  }

  Future<bool> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
    String? trackingNumber,
    String? shipperName,
    String? note,
  }) async {
    final body = <String, dynamic>{
      'status': status,
      if (trackingNumber != null && trackingNumber.isNotEmpty)
        'trackingNumber': trackingNumber,
      if (shipperName != null && shipperName.isNotEmpty)
        'shipperName': shipperName,
      if (note != null && note.isNotEmpty)
        'note': note,
    };

    final response = await _client.patch(
      ApiConfig.orderStatusPath(orderId),
      token: token,
      body: body,
    );
    return response['statusCode'] != null && (response['statusCode'] as int) < 400;
  }
}
