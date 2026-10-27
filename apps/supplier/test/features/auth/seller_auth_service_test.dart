import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';
import 'package:cook_connect_seller/features/auth/data/services/auth_api_service.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';

void main() {
  late InMemoryTokenStorageService storage;
  late SellerAuthService authService;
  String? lastRequestedPath;
  Map<String, dynamic>? lastRequestBody;
  Map<String, String>? lastRequestHeaders;

  setUp(() {
    storage = InMemoryTokenStorageService();
    lastRequestedPath = null;
    lastRequestBody = null;
    lastRequestHeaders = null;

    ApiClient.defaultClient = MockClient((request) async {
      lastRequestedPath = request.url.path;
      lastRequestHeaders = request.headers;
      if (request.body.isNotEmpty) {
        try {
          lastRequestBody = jsonDecode(request.body) as Map<String, dynamic>;
        } catch (_) {}
      }

      if (request.url.path == '/api/v1/auth/register/send-otp') {
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'message': 'OTP sent successfully',
            'data': {
              'cooldownSeconds': 60,
              'expiresInMinutes': 5,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.url.path == '/api/v1/auth/register/verify-otp') {
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'message': 'OTP verified successfully',
            'data': {
              'verificationToken': 'vtok_test12345678',
              'expiresInSeconds': 900,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.url.path == '/api/v1/auth/register') {
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 201,
            'message': 'Account registered successfully',
            'data': {
              'user': {
                'userId': 'usr_test_123',
                'email': 'quancuatoi@cookconnect.app',
                'roles': ['SUPPLIER_ADMIN'],
                'status': 'active',
              },
              'tokens': {
                'accessToken': 'test_access_token',
                'refreshToken': 'test_refresh_token',
                'tokenType': 'Bearer',
                'expiresIn': 900,
              },
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.url.path == '/api/v1/suppliers/me') {
        final authHeader = request.headers['authorization'];
        if (authHeader == 'Bearer rejected_token') {
          return http.Response(
            jsonEncode({
              'success': false,
              'statusCode': 401,
              'errorCode': 'COMMON.UNAUTHORIZED',
              'message': 'COMMON.UNAUTHORIZED',
            }),
            401,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'data': {
              'hasSupplier': true,
              'supplier': {
                'supplierId': 'supp_123',
                'supplierName': 'Quán Ăn Ngon',
                'supplierSlug': 'quan-an-ngon',
                'supplierCode': 'SUPP-123',
                'rating': 4.9,
                'isVerified': true,
                'supplierStatus': 'ACTIVE',
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.url.path == '/api/v1/auth/me') {
        final authHeader = request.headers['authorization'];
        if (authHeader == 'Bearer rejected_token') {
          return http.Response(
            jsonEncode({
              'success': false,
              'statusCode': 401,
              'errorCode': 'COMMON.UNAUTHORIZED',
              'message': 'COMMON.UNAUTHORIZED',
            }),
            401,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'data': {
              'sub': 'usr_test_123',
              'email': 'quanan@cookconnect.app',
              'roles': ['SUPPLIER_ADMIN'],
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.url.path == '/api/v1/auth/refresh') {
        final refreshHeader = request.headers['x-refresh-token'] ?? request.headers['X-Refresh-Token'];
        if (refreshHeader == 'expired_refresh_token' || lastRequestBody?['refreshToken'] == 'expired_refresh_token') {
          return http.Response(
            jsonEncode({
              'success': false,
              'statusCode': 401,
              'errorCode': 'AUTH.REFRESH_TOKEN_EXPIRED',
              'message': 'AUTH.REFRESH_TOKEN_EXPIRED',
            }),
            401,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'data': {
              'tokens': {
                'accessToken': 'new_rotated_access_token',
                'refreshToken': 'new_rotated_refresh_token',
                'tokenType': 'Bearer',
                'expiresIn': 3600,
              },
              'user': {
                'userId': 'usr_test_123',
                'email': 'quanan@cookconnect.app',
                'roles': ['SUPPLIER_ADMIN'],
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response('Not Found', 404);
    });

    authService = SellerAuthService.instance;
    authService.configure(storage: storage, apiService: AuthApiService());
  });

  tearDown(() async {
    ApiClient.defaultClient = null;
    await authService.logout(callServer: false);
  });

  test('ApiConfig register paths point to unified /api/v1/auth/register', () {
    expect(ApiConfig.registerPath, equals('/api/v1/auth/register'));
    expect(ApiConfig.registerSupplierPath, equals('/api/v1/auth/register'));
    expect(ApiConfig.registerUrl, equals('http://192.168.1.162:8080/api/v1/auth/register'));
    expect(ApiConfig.registerSupplierUrl, equals('http://192.168.1.162:8080/api/v1/auth/register'));
  });

  test('Initial state is not logged in', () {
    expect(authService.isLoggedIn, isFalse);
    expect(authService.currentUser, isNull);
    expect(authService.tokens, isNull);
  });

  test('sendOtp and verifyOtp work successfully', () async {
    final sendResult = await authService.sendOtp(contact: 'seller.new@cookconnect.app');
    expect(sendResult.isSuccess, isTrue);
    expect(lastRequestedPath, equals('/api/v1/auth/register/send-otp'));

    final verifyResult = await authService.verifyOtp(
      contact: 'seller.new@cookconnect.app',
      otp: '123456',
    );
    expect(verifyResult.isSuccess, isTrue);
    expect(verifyResult.verificationToken, equals('vtok_test12345678'));
    expect(lastRequestedPath, equals('/api/v1/auth/register/verify-otp'));
  });

  test('register calls unified /api/v1/auth/register and updates store profile flow', () async {
    final regResult = await authService.register(
      email: 'quancuatoi@cookconnect.app',
      password: 'StrongPassword123!',
      verificationToken: 'vtok_test12345678',
    );

    expect(lastRequestedPath, equals('/api/v1/auth/register'));
    expect(lastRequestBody?['email'], equals('quancuatoi@cookconnect.app'));
    expect(lastRequestBody?['password'], equals('StrongPassword123!'));
    expect(lastRequestBody?['confirmPassword'], equals('StrongPassword123!'));
    expect(lastRequestBody?['verificationToken'], equals('vtok_test12345678'));

    expect(regResult.success, isTrue);
    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser?.email, equals('quancuatoi@cookconnect.app'));

    await authService.updateStoreProfile(
      storeName: 'Bếp Nhà Tôi',
      fullName: 'Trần Văn An',
      phone: '0901234567',
      category: 'Cơm văn phòng & Món gia đình',
      address: '100 Hai Bà Trưng, Q1, TP. HCM',
      description: 'Cơm ngon chuẩn vị mẹ nấu',
    );

    expect(authService.currentUser?.storeName, equals('Bếp Nhà Tôi'));
    expect(authService.currentUser?.fullName, equals('Trần Văn An'));
    expect(authService.currentUser?.phone, equals('0901234567'));
    expect(authService.currentUser?.category, equals('Cơm văn phòng & Món gia đình'));
    expect(authService.currentUser?.address, equals('100 Hai Bà Trưng, Q1, TP. HCM'));
    expect(authService.currentUser?.description, equals('Cơm ngon chuẩn vị mẹ nấu'));
  });

  test('setDemoSession sets valid session and notifies listeners', () {
    bool notified = false;
    authService.addListener(() => notified = true);

    authService.setDemoSession();

    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser?.storeName, contains('Đại Siêu Thị Nguyên Liệu Tươi'));
    expect(authService.currentUser?.role, equals('SUPPLIER_ADMIN'));
    expect(authService.tokens?.accessToken, startsWith('demo-seller-token'));
    expect(notified, isTrue);
  });

  test('loginWithSocial sets valid session for Google and Apple', () async {
    final googleResult = await authService.loginWithSocial(provider: 'google');
    expect(googleResult.success, isTrue);
    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser?.fullName, equals('Google Seller Partner'));
    expect(authService.tokens?.accessToken, startsWith('social-google-'));

    final appleResult = await authService.loginWithSocial(provider: 'apple');
    expect(appleResult.success, isTrue);
    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser?.fullName, equals('Apple Seller Partner'));
    expect(authService.tokens?.accessToken, startsWith('social-apple-'));
  });

  test('logout clears session and storage', () async {
    authService.setDemoSession();
    expect(authService.isLoggedIn, isTrue);

    await authService.logout(callServer: false);

    expect(authService.isLoggedIn, isFalse);
    expect(authService.currentUser, isNull);
    expect(authService.tokens, isNull);
    final storedTokens = await storage.getTokens();
    expect(storedTokens, isNull);
  });

  test('Expired tokens on init are rejected and cleared', () async {
    final expiredTokens = AuthTokens(
      accessToken: 'expired-token',
      refreshToken: '',
      expiresIn: -100, // already expired
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    );
    await storage.saveTokens(expiredTokens);

    await authService.init();

    expect(authService.isLoggedIn, isFalse);
    expect(authService.tokens, isNull);
  });

  test('Valid cached tokens on init restore session', () async {
    final validTokens = AuthTokens(
      accessToken: 'valid-token',
      refreshToken: 'valid-refresh',
      expiresIn: 3600,
      createdAt: DateTime.now(),
    );
    final user = SellerUser(
      id: 'seller-123',
      email: 'quanan@cookconnect.app',
      storeName: 'Quán Ăn Ngon',
      role: 'seller',
    );
    await storage.saveTokens(validTokens);
    await storage.saveSellerProfile(user.toJson());

    await authService.init();

    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser?.storeName, equals('Quán Ăn Ngon'));
  });

  test('refreshToken passes x-refresh-token header as required by Swagger docs', () async {
    final result = await authService.refreshAccessToken();
    expect(result, isNull); // no active tokens

    final tokens = AuthTokens(
      accessToken: 'old_access_token',
      refreshToken: 'my_refresh_token_123',
      expiresIn: 3600,
      createdAt: DateTime.now(),
    );
    final user = SellerUser(id: 'usr_1', email: 'quanan@cookconnect.app');
    authService.setSession(user: user, tokens: tokens);

    final refreshed = await authService.refreshAccessToken();
    expect(refreshed, equals('new_rotated_access_token'));
    expect(lastRequestedPath, equals('/api/v1/auth/refresh'));
    expect(lastRequestHeaders?['x-refresh-token'], equals('my_refresh_token_123'));
    expect(lastRequestHeaders?['X-Refresh-Token'], equals('my_refresh_token_123'));
    expect(lastRequestBody?['refreshToken'], equals('my_refresh_token_123'));
    expect(authService.tokens?.accessToken, equals('new_rotated_access_token'));
  });

  test('If refresh token fails with 401 when re-entering app, user is immediately logged out', () async {
    final expiredAccessToken = AuthTokens(
      accessToken: 'expired_access_token',
      refreshToken: 'expired_refresh_token',
      expiresIn: -50,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
    final user = SellerUser(id: 'usr_1', email: 'quanan@cookconnect.app');
    authService.setSession(user: user, tokens: expiredAccessToken);
    expect(authService.isLoggedIn, isTrue);

    // Call restoreSession (triggered on app resumed / entering app)
    await authService.restoreSession();

    // Must be logged out immediately
    expect(authService.isLoggedIn, isFalse);
    expect(authService.tokens, isNull);
    expect(authService.currentUser, isNull);
    final storedTokens = await storage.getTokens();
    expect(storedTokens, isNull);
  });

  test('If access token is rejected with 401 and refresh fails, user is logged out immediately', () async {
    final tokens = AuthTokens(
      accessToken: 'rejected_token',
      refreshToken: 'expired_refresh_token',
      expiresIn: 3600,
      createdAt: DateTime.now(),
    );
    final user = SellerUser(id: 'usr_1', email: 'quanan@cookconnect.app');
    authService.setSession(user: user, tokens: tokens);
    expect(authService.isLoggedIn, isTrue);

    // Calling checkSupplierStatus with rejected token will fail and attempt refresh, which fails -> logout
    await authService.checkSupplierStatus();

    expect(authService.isLoggedIn, isFalse);
    expect(authService.tokens, isNull);
    expect(authService.currentUser, isNull);
  });
}
