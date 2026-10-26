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

  setUp(() {
    storage = InMemoryTokenStorageService();
    lastRequestedPath = null;
    lastRequestBody = null;

    ApiClient.defaultClient = MockClient((request) async {
      lastRequestedPath = request.url.path;
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
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'data': {
              'hasSupplier': false,
              'supplier': null,
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

    // Verify it hits unified endpoint /api/v1/auth/register, not deprecated /register-supplier
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
      refreshToken: 'expired-refresh',
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
}
