import 'package:http/http.dart' as http;
import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/features/auth/data/services/auth_api_service.dart';
import 'package:cook_connect_seller/features/dashboard/data/services/dashboard_api_service.dart';
import 'package:cook_connect_seller/features/orders/data/services/orders_api_service.dart';
import 'package:cook_connect_seller/features/menu/data/services/menu_api_service.dart';
import 'package:cook_connect_seller/features/store/data/services/store_api_service.dart';

export 'package:cook_connect_seller/core/config/api_config.dart';
export 'package:cook_connect_seller/core/network/api_client.dart';
export 'package:cook_connect_seller/core/network/api_exception.dart';
export 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';
export 'package:cook_connect_seller/features/dashboard/data/models/dashboard_stats.dart';
export 'package:cook_connect_seller/features/orders/data/models/seller_order.dart';
export 'package:cook_connect_seller/features/menu/data/models/menu_item.dart';
export 'package:cook_connect_seller/features/store/data/models/store_profile.dart';

/// Central facade ApiService coordinating all domain API services for CookConnect Seller
class ApiService {
  static final ApiService instance = ApiService();

  static http.Client? get defaultClient => ApiClient.defaultClient;
  static set defaultClient(http.Client? client) => ApiClient.defaultClient = client;

  static Future<String?> Function()? get tokenRefreshHandler => ApiClient.tokenRefreshHandler;
  static set tokenRefreshHandler(Future<String?> Function()? handler) =>
      ApiClient.tokenRefreshHandler = handler;

  static void Function()? get sessionExpiredHandler => ApiClient.sessionExpiredHandler;
  static set sessionExpiredHandler(void Function()? handler) =>
      ApiClient.sessionExpiredHandler = handler;

  final ApiClient _client;
  final AuthApiService _authService;
  final DashboardApiService _dashboardService;
  final OrdersApiService _ordersService;
  final MenuApiService _menuService;
  final StoreApiService _storeService;

  ApiService({http.Client? client, ApiClient? apiClient})
      : _client = apiClient ?? ApiClient(client: client),
        _authService = AuthApiService(apiClient: apiClient ?? ApiClient(client: client)),
        _dashboardService = DashboardApiService(apiClient: apiClient ?? ApiClient(client: client)),
        _ordersService = OrdersApiService(apiClient: apiClient ?? ApiClient(client: client)),
        _menuService = MenuApiService(apiClient: apiClient ?? ApiClient(client: client)),
        _storeService = StoreApiService(apiClient: apiClient ?? ApiClient(client: client));

  ApiClient get apiClient => _client;
  AuthApiService get auth => _authService;
  DashboardApiService get dashboard => _dashboardService;
  OrdersApiService get orders => _ordersService;
  MenuApiService get menu => _menuService;
  StoreApiService get store => _storeService;

  /// Health check backend connectivity
  Future<bool> checkHealth() async {
    try {
      final res = await _client.get(ApiConfig.healthPath);
      return res['statusCode'] == 200 || res['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }
}
