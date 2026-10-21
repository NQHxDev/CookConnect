/// Configuration class for CookConnect Seller API endpoints and environment settings.
///
/// Base URL defaults to http://192.168.1.162:8080 and can be configured via
/// `--dart-define=API_BASE_URL=...` or `--dart-define-from-file=.env`.
class ApiConfig {
  ApiConfig._();

  /// Base URL to your backend server.
  /// Defaults to LAN server at 192.168.1.162:8080.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.162:8080',
  );

  /// API version string (e.g. 'v1').
  static const String apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  /// Network request timeout in seconds.
  static const int timeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 10,
  );

  // Common Endpoints
  static String get healthPath => '/api/$apiVersion/health';

  // Seller Auth Endpoints
  static String get loginPath => '/api/$apiVersion/seller/auth/login';
  static String get registerPath => '/api/$apiVersion/seller/auth/register';
  static String get refreshPath => '/api/$apiVersion/seller/auth/refresh';
  static String get logoutPath => '/api/$apiVersion/seller/auth/logout';
  static String get mePath => '/api/$apiVersion/seller/auth/me';

  // Seller Dashboard & Stats
  static String get dashboardStatsPath => '/api/$apiVersion/seller/dashboard/stats';

  // Seller Orders
  static String get ordersPath => '/api/$apiVersion/seller/orders';
  static String orderDetailPath(String orderId) => '/api/$apiVersion/seller/orders/$orderId';
  static String orderStatusPath(String orderId) => '/api/$apiVersion/seller/orders/$orderId/status';

  // Seller Menu / Products
  static String get menuItemsPath => '/api/$apiVersion/seller/menu/items';
  static String menuItemDetailPath(String itemId) => '/api/$apiVersion/seller/menu/items/$itemId';
  static String get menuCategoriesPath => '/api/$apiVersion/seller/menu/categories';

  // Seller Store Profile
  static String get storeProfilePath => '/api/$apiVersion/seller/store';
  static String get storeStatusPath => '/api/$apiVersion/seller/store/status';

  // Helper getters for full endpoint URLs
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
  static String get healthUrl => '$baseUrl$healthPath';
  static String get loginUrl => '$baseUrl$loginPath';
  static String get registerUrl => '$baseUrl$registerPath';
  static String get refreshUrl => '$baseUrl$refreshPath';
  static String get logoutUrl => '$baseUrl$logoutPath';
  static String get meUrl => '$baseUrl$mePath';
  static String get dashboardStatsUrl => '$baseUrl$dashboardStatsPath';
  static String get ordersUrl => '$baseUrl$ordersPath';
  static String get menuItemsUrl => '$baseUrl$menuItemsPath';
  static String get menuCategoriesUrl => '$baseUrl$menuCategoriesPath';
  static String get storeProfileUrl => '$baseUrl$storeProfilePath';
  static String get storeStatusUrl => '$baseUrl$storeStatusPath';
}
