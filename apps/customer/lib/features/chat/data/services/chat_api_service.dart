import 'package:cookconnect/core/config/api_config.dart';
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/core/network/api_exception.dart';
import 'package:cookconnect/features/chat/data/models/user_suggestion.dart';
import 'package:http/http.dart' as http;

class ChatApiService {
  final ApiClient _client;

  ChatApiService({ApiClient? apiClient, http.Client? httpClient})
      : _client = apiClient ?? ApiClient(client: httpClient);

  /// Fetch user suggestions from `GET /api/v1/users/suggestions?limit=...`
  Future<List<UserSuggestion>> getSuggestedUsers({
    required String accessToken,
    int limit = 10,
  }) async {
    try {
      final decoded = await _client.get(
        ApiConfig.userSuggestionsPath,
        token: accessToken,
        queryParams: {'limit': limit.toString()},
      );

      final List<dynamic> list;
      if (decoded['data'] is List) {
        list = decoded['data'] as List<dynamic>;
      } else if (decoded['items'] is List) {
        list = decoded['items'] as List<dynamic>;
      } else {
        list = const [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => UserSuggestion.fromJson(item))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Lỗi tải gợi ý: ${e.toString()}',
      );
    }
  }
}
