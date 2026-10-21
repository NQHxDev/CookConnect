import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/features/store/data/models/store_profile.dart';

class StoreApiService {
  final ApiClient _client;

  StoreApiService({ApiClient? apiClient}) : _client = apiClient ?? ApiClient();

  Future<StoreProfile> getStoreProfile({required String token}) async {
    final response = await _client.get(
      ApiConfig.storeProfilePath,
      token: token,
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return StoreProfile.fromJson(data);
  }

  Future<StoreProfile> updateStoreProfile({
    required String token,
    required Map<String, dynamic> updates,
  }) async {
    final response = await _client.put(
      ApiConfig.storeProfilePath,
      token: token,
      body: updates,
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return StoreProfile.fromJson(data);
  }

  Future<bool> toggleStoreStatus({
    required String token,
    required bool isOpen,
  }) async {
    final response = await _client.patch(
      ApiConfig.storeStatusPath,
      token: token,
      body: {'isOpen': isOpen},
    );
    return response['statusCode'] != null && (response['statusCode'] as int) < 400;
  }
}
