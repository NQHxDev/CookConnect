import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/features/recipe/data/models/create_post_dto.dart';
import 'package:cookconnect/features/recipe/data/services/post_api_service.dart';

void main() {
  group('CreatePostDto serialization tests', () {
    test('CreatePostDto serializes to JSON matching Swagger schema requirements', () {
      final dto = CreatePostDto(
        title: 'Bò bít tết sốt tiêu đen',
        caption: 'Công thức nấu bò bít tết mềm mọng thơm ngon #bobittet #steak',
        videoUrl: 'https://cdn.cookconnect.io/videos/steak.mp4',
        thumbnailUrl: 'https://cdn.cookconnect.io/thumbs/steak.jpg',
        duration: 90,
        visibility: 'PUBLIC',
        allowComments: true,
        tags: ['bobittet', 'steak'],
        ingredients: [
          const CreatePostIngredientDto(
            name: 'Thịt bò Tenderloin',
            amount: 300,
            unit: 'g',
            group: 'Nguyên liệu chính',
            sortOrder: 0,
            catalogIngredientId: 'prod-001',
          ),
          const CreatePostIngredientDto(
            name: 'Tiêu đen xay',
            amount: 10,
            unit: 'g',
            group: 'Gia vị',
            sortOrder: 1,
          ),
        ],
        recipe: const CreateRecipeDto(
          cookTimeMinutes: 20,
          servings: 2,
          difficulty: 'MEDIUM',
          calories: 550,
          steps: [
            CreateRecipeStepDto(
              stepNumber: 1,
              title: 'Ướp thịt',
              instruction: 'Ướp thịt với muối, tiêu và dầu olive trong 15 phút.',
              timestampSeconds: 10,
            ),
            CreateRecipeStepDto(
              stepNumber: 2,
              title: 'Áp chảo',
              instruction: 'Cho bơ tỏi vào chảo gang, áp chảo mỗi mặt 3 phút.',
              timestampSeconds: 30,
            ),
          ],
        ),
      );

      final json = dto.toJson();

      expect(json['title'], 'Bò bít tết sốt tiêu đen');
      expect(json['videoUrl'], 'https://cdn.cookconnect.io/videos/steak.mp4');
      expect(json['thumbnailUrl'], 'https://cdn.cookconnect.io/thumbs/steak.jpg');
      expect(json['duration'], 90);
      expect(json['visibility'], 'PUBLIC');
      expect(json['allowComments'], true);
      expect(json['tags'], ['bobittet', 'steak']);

      final ingredients = json['ingredients'] as List;
      expect(ingredients.length, 2);
      expect(ingredients[0]['name'], 'Thịt bò Tenderloin');
      expect(ingredients[0]['amount'], 300);
      expect(ingredients[0]['unit'], 'g');
      expect(ingredients[0]['catalogIngredientId'], 'prod-001');

      final recipe = json['recipe'] as Map<String, dynamic>;
      expect(recipe['cookTimeMinutes'], 20);
      expect(recipe['servings'], 2);
      expect(recipe['difficulty'], 'MEDIUM');
      expect(recipe['calories'], 550);

      final steps = recipe['steps'] as List;
      expect(steps.length, 2);
      expect(steps[0]['stepNumber'], 1);
      expect(steps[0]['instruction'], 'Ướp thịt với muối, tiêu và dầu olive trong 15 phút.');
    });

    test('PostApiService.createPost sends POST request with correct payload and headers', () async {
      late http.Request capturedRequest;

      final mockClient = MockClient((request) async {
        capturedRequest = request;
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/posts');
        expect(request.headers['Authorization'], 'Bearer fake_jwt_token');

        final responseBody = {
          'success': true,
          'statusCode': 201,
          'message': 'Post published successfully.',
          'data': {
            'postId': 'post-uuid-1234',
            'userId': 'user-uuid-5678',
            'title': 'Bò bít tết sốt tiêu đen',
            'videoUrl': 'https://cdn.cookconnect.io/videos/steak.mp4',
            'thumbnailUrl': 'https://cdn.cookconnect.io/thumbs/steak.jpg',
            'duration': 90,
            'viewCount': 0,
            'likeCount': 0,
            'commentCount': 0,
            'shareCount': 0,
            'saveCount': 0,
            'allowComments': true,
            'allowDuet': false,
            'createdAt': DateTime.now().toIso8601String(),
            'ingredients': [],
          }
        };

        return http.Response(
          jsonEncode(responseBody),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080');
      final service = PostApiService(apiClient: apiClient);

      final post = await service.createPost(
        dto: const CreatePostDto(
          title: 'Bò bít tết sốt tiêu đen',
          videoUrl: 'https://cdn.cookconnect.io/videos/steak.mp4',
          thumbnailUrl: 'https://cdn.cookconnect.io/thumbs/steak.jpg',
          duration: 90,
        ),
        token: 'fake_jwt_token',
      );

      expect(post.postId, 'post-uuid-1234');
      expect(post.title, 'Bò bít tết sốt tiêu đen');
      expect(capturedRequest.method, 'POST');
    });
  });
}
