/// Configuration class for CookConnect Supplier API endpoints and environment settings.
///
/// Base URL defaults to http://192.168.1.162:8080 and can be configured via
/// `--dart-define=API_BASE_URL=...` or `--dart-define-from-file=.env`.
class ApiConfig {
  ApiConfig._();

  /// Base URL to your backend server.
  /// Defaults to LAN server at 192.168.1.162:8080.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.96:8080',
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

  // Supplier Admin Auth Endpoints (Phase 1: Account registration)
  // Note: Backend server unified account registration into /api/v1/auth/register
  static String get sendOtpPath => '/api/$apiVersion/auth/register/send-otp';
  static String get verifyOtpPath =>
      '/api/$apiVersion/auth/register/verify-otp';
  static String get loginPath => '/api/$apiVersion/auth/login';
  static String get registerPath => '/api/$apiVersion/auth/register';
  static String get registerSupplierPath => registerPath;
  static String get refreshPath => '/api/$apiVersion/auth/refresh';
  static String get logoutPath => '/api/$apiVersion/auth/logout';
  static String get mePath => '/api/$apiVersion/auth/me';
  static String get userMePath => '/api/$apiVersion/users/me';
  static String get userAddressPath => '/api/$apiVersion/users/me/address';

  // Supplier Store Onboarding Endpoints (Phase 2: Store setup & details)
  static String get suppliersPath => '/api/$apiVersion/suppliers';
  static String get submitKybPath => '/api/$apiVersion/suppliers/me/kyb';
  static String supplierDetailPath(String supplierId) =>
      '/api/$apiVersion/suppliers/$supplierId';
  static String supplierStatusPath(String supplierId) =>
      '/api/$apiVersion/suppliers/$supplierId/status';
  static String get mySupplierPath => '/api/$apiVersion/suppliers/me';
  static String get storeProfilePath => mySupplierPath;
  static String get storeStatusPath => '/api/$apiVersion/suppliers/me/status';

  // Supplier Dashboard & Stats
  static String get dashboardStatsPath =>
      '/api/$apiVersion/supplier/dashboard/stats';

  // Supplier Orders
  static String get ordersPath => '/api/$apiVersion/supplier/orders';
  static String orderDetailPath(String orderId) =>
      '/api/$apiVersion/supplier/orders/$orderId';
  static String orderStatusPath(String orderId) =>
      '/api/$apiVersion/supplier/orders/$orderId/status';

  // Supplier Menu / Products
  static String get menuItemsPath => '/api/$apiVersion/commerce/products';
  static String menuItemDetailPath(String itemId) =>
      '/api/$apiVersion/commerce/products/$itemId';
  static String get menuCategoriesPath =>
      '/api/$apiVersion/commerce/ingredients/categories';
  static String get productCategoriesPath =>
      '/api/$apiVersion/products/categories';

  // Product Management (POST /api/v1/products - WHO categories & Raw ingredients)
  static String get productsPath => '/api/$apiVersion/products';
  static String get productSearchPath => '/api/$apiVersion/products/search';
  static String get productSuggestPath => '/api/$apiVersion/products/suggest';
  static String productDetailPath(String productId) =>
      '/api/$apiVersion/products/$productId';
  static String productStatusPath(String productId) =>
      '/api/$apiVersion/products/$productId/status';
  static String productVariantStockPath(String variantId) =>
      '/api/$apiVersion/products/variants/$variantId/stock';
  static String productSubmitReviewPath(String productId) =>
      '/api/$apiVersion/products/$productId/submit-review';
  // Media Endpoints
  static String get mediaUploadPath => '/api/$apiVersion/media/upload';
  static String get mediaVideoMultipartInitiatePath =>
      '/api/$apiVersion/media/videos/multipart-initiate';
  static String get mediaVideoMultipartCompletePath =>
      '/api/$apiVersion/media/videos/multipart-complete';

  // Helper getters for full endpoint URLs
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
  static String get healthUrl => '$baseUrl$healthPath';
  static String get sendOtpUrl => '$baseUrl$sendOtpPath';
  static String get verifyOtpUrl => '$baseUrl$verifyOtpPath';
  static String get loginUrl => '$baseUrl$loginPath';
  static String get registerUrl => '$baseUrl$registerPath';
  static String get registerSupplierUrl => registerUrl;
  static String get refreshUrl => '$baseUrl$refreshPath';
  static String get logoutUrl => '$baseUrl$logoutPath';
  static String get meUrl => '$baseUrl$mePath';
  static String get userMeUrl => '$baseUrl$userMePath';
  static String get userAddressUrl => '$baseUrl$userAddressPath';
  static String get suppliersUrl => '$baseUrl$suppliersPath';
  static String get submitKybUrl => '$baseUrl$submitKybPath';
  static String get mySupplierUrl => '$baseUrl$mySupplierPath';
  static String get dashboardStatsUrl => '$baseUrl$dashboardStatsPath';
  static String get ordersUrl => '$baseUrl$ordersPath';
  static String get menuItemsUrl => '$baseUrl$menuItemsPath';
  static String get menuCategoriesUrl => '$baseUrl$menuCategoriesPath';
  static String get productCategoriesUrl => '$baseUrl$productCategoriesPath';
  static String get storeProfileUrl => '$baseUrl$storeProfilePath';
  static String get storeStatusUrl => '$baseUrl$storeStatusPath';
  static String get productsUrl => '$baseUrl$productsPath';
  static String get productSearchUrl => '$baseUrl$productSearchPath';
  static String get productSuggestUrl => '$baseUrl$productSuggestPath';
  static String productSubmitReviewUrl(String productId) =>
      '$baseUrl${productSubmitReviewPath(productId)}';
  static String get mediaUploadUrl => '$baseUrl$mediaUploadPath';
  static String get mediaVideoMultipartInitiateUrl =>
      '$baseUrl$mediaVideoMultipartInitiatePath';
  static String get mediaVideoMultipartCompleteUrl =>
      '$baseUrl$mediaVideoMultipartCompletePath';
}
