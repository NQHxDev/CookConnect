import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';

class AuthApiService {
  final ApiClient _client;

  AuthApiService({ApiClient? apiClient}) : _client = apiClient ?? ApiClient();

  Future<SellerAuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConfig.loginPath,
      body: {
        'email': email,
        'password': password,
      },
    );
    return SellerAuthResult.fromJson(response);
  }

  Future<SellerAuthResult> register({
    required String email,
    required String password,
    required String storeName,
    String? fullName,
    String? phone,
  }) async {
    final response = await _client.post(
      ApiConfig.registerPath,
      body: {
        'email': email,
        'password': password,
        'storeName': storeName,
        'fullName': fullName,
        'phone': phone,
      },
    );
    return SellerAuthResult.fromJson(response);
  }

  Future<SellerAuthResult> refreshToken(String refreshToken) async {
    final response = await _client.post(
      ApiConfig.refreshPath,
      body: {'refreshToken': refreshToken},
    );
    return SellerAuthResult.fromJson(response);
  }

  Future<bool> logout(String token) async {
    try {
      await _client.post(ApiConfig.logoutPath, token: token);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<SellerUser?> getMe(String token) async {
    final response = await _client.get(ApiConfig.mePath, token: token);
    final data = response['data'] as Map<String, dynamic>?;
    if (data != null) {
      return SellerUser.fromJson(data);
    }
    return null;
  }
}
