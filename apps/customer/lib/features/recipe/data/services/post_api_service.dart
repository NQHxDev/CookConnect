import 'package:cookconnect/core/config/api_config.dart';
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/features/recipe/data/models/post_item.dart';

class PostApiService {
  final ApiClient _client;

  PostApiService({ApiClient? apiClient})
      : _client = apiClient ?? ApiClient();

  /// Retrieves infinite scroll feed of video posts
  Future<PostFeedResponse> getFeed({
    String? cursor,
    int limit = 3,
    String? userId,
    String? tag,
    String? category,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }
    if (userId != null && userId.isNotEmpty) {
      queryParams['userId'] = userId;
    }
    if (tag != null && tag.isNotEmpty) {
      queryParams['tag'] = tag;
    }
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }

    final response = await _client.get(
      ApiConfig.postFeedPath,
      queryParams: queryParams,
      token: token,
    );

    final data = response['data'] ?? response;
    return PostFeedResponse.fromJson(data as Map<String, dynamic>);
  }

  /// Retrieves single post details by UUID
  Future<PostItem> getPostById(String postId, {String? token}) async {
    final response = await _client.get(
      '${ApiConfig.postsPath}/$postId',
      token: token,
    );
    final data = response['data'] ?? response;
    return PostItem.fromJson(data as Map<String, dynamic>);
  }

  /// Retrieves dish ingredients for a video post
  Future<List<PostIngredientItem>> getPostIngredients(
    String postId, {
    String? token,
  }) async {
    final response = await _client.get(
      '${ApiConfig.postsPath}/$postId/ingredients',
      token: token,
    );
    final data = response['data'] ?? response;
    if (data is List) {
      return data
          .map((e) => PostIngredientItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
