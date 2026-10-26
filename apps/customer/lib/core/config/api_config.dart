class ApiConfig {
  /// Base URL to your backend server.
  /// Defaults to LAN server at 192.168.1.162:8080.
  /// Can be overridden via `--dart-define=API_BASE_URL=...` at run/build time.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.162:8080',
  );

  static const String apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  static const int timeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 10,
  );

  /// Relative Paths
  static String get healthPath => '/api/$apiVersion/health';
  static String get checkUsernamePath =>
      '/api/$apiVersion/users/check-username';
  static String get avatarPath => '/api/$apiVersion/users/me/avatar';
  static String get userProfilePath => '/api/$apiVersion/users/profile';
  static String get userPersonalInfoPath =>
      '/api/$apiVersion/users/me/personal-info';
  static String get userDisplayNamePath =>
      '/api/$apiVersion/users/me/display-name';
  static String get userBioPath => '/api/$apiVersion/users/me/bio';
  static String get userLocationPath => '/api/$apiVersion/users/me/location';
  static String get userWebsitePath => '/api/$apiVersion/users/me/website';
  static String get userCoverImagePath =>
      '/api/$apiVersion/users/me/cover-image';
  static String get userUsernamePath => '/api/$apiVersion/users/me/username';
  static String get sendOtpPath => '/api/$apiVersion/auth/register/send-otp';
  static String get verifyOtpPath =>
      '/api/$apiVersion/auth/register/verify-otp';
  static String get registerPath => '/api/$apiVersion/auth/register';
  static String get loginPath => '/api/$apiVersion/auth/login';
  static String get logoutPath => '/api/$apiVersion/auth/logout';
  static String get refreshPath => '/api/$apiVersion/auth/refresh';
  static String get mePath => '/api/$apiVersion/auth/me';
  static String get userMePath => '/api/$apiVersion/users/me';
  static String get userSuggestionsPath => '/api/$apiVersion/users/suggestions';
  static String get postsPath => '/api/$apiVersion/posts';
  static String get postFeedPath => '/api/$apiVersion/posts/feed';
  static String get productCategoriesPath =>
      '/api/$apiVersion/products/categories';

  /// Helper getters for full endpoint URLs
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
  static String get healthUrl => '$baseUrl$healthPath';
  static String get docsUrl => '$baseUrl/docs';
  static String get checkUsernameUrl => '$baseUrl$checkUsernamePath';
  static String get avatarUrl => '$baseUrl$avatarPath';
  static String get userProfileUrl => '$baseUrl$userProfilePath';
  static String get userPersonalInfoUrl => '$baseUrl$userPersonalInfoPath';
  static String get userDisplayNameUrl => '$baseUrl$userDisplayNamePath';
  static String get userBioUrl => '$baseUrl$userBioPath';
  static String get userLocationUrl => '$baseUrl$userLocationPath';
  static String get userWebsiteUrl => '$baseUrl$userWebsitePath';
  static String get userCoverImageUrl => '$baseUrl$userCoverImagePath';
  static String get userUsernameUrl => '$baseUrl$userUsernamePath';
  static String get sendOtpUrl => '$baseUrl$sendOtpPath';
  static String get verifyOtpUrl => '$baseUrl$verifyOtpPath';
  static String get registerUrl => '$baseUrl$registerPath';
  static String get loginUrl => '$baseUrl$loginPath';
  static String get logoutUrl => '$baseUrl$logoutPath';
  static String get refreshUrl => '$baseUrl$refreshPath';
  static String get meUrl => '$baseUrl$mePath';
  static String get userMeUrl => '$baseUrl$userMePath';
  static String get userSuggestionsUrl => '$baseUrl$userSuggestionsPath';
  static String get postsUrl => '$baseUrl$postsPath';
  static String get postFeedUrl => '$baseUrl$postFeedPath';
  static String get productCategoriesUrl => '$baseUrl$productCategoriesPath';
}
