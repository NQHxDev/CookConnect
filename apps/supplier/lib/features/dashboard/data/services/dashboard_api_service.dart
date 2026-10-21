import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/features/dashboard/data/models/dashboard_stats.dart';

class DashboardApiService {
  final ApiClient _client;

  DashboardApiService({ApiClient? apiClient}) : _client = apiClient ?? ApiClient();

  Future<DashboardStats> getStats({required String token}) async {
    final response = await _client.get(
      ApiConfig.dashboardStatsPath,
      token: token,
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return DashboardStats.fromJson(data);
  }
}
