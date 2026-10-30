import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/features/recipe/data/models/create_post_dto.dart';
import 'package:cookconnect/features/recipe/data/models/multipart_upload_models.dart';
import 'package:cookconnect/features/recipe/data/services/post_api_service.dart';

void main() {
  group('Multipart Video Upload Workflow Tests', () {
    test('InitiateMultipartUploadDto serializes correctly', () {
      const dto = InitiateMultipartUploadDto(
        fileName: 'cooking_guide.mp4',
        mimeType: 'video/mp4',
        partsCount: 3,
        fileSize: 15728640,
        folder: 'omni/videos/raw',
      );

      final json = dto.toJson();
      expect(json['fileName'], 'cooking_guide.mp4');
      expect(json['mimeType'], 'video/mp4');
      expect(json['partsCount'], 3);
      expect(json['fileSize'], 15728640);
      expect(json['folder'], 'omni/videos/raw');
    });

    test('CompletedPartDto serializes with both etag and eTag for server compatibility', () {
      const part = CompletedPartDto(
        partNumber: 1,
        etag: '"etag-123456"',
      );

      final json = part.toJson();
      expect(json['partNumber'], 1);
      expect(json['etag'], '"etag-123456"');
      expect(json['eTag'], '"etag-123456"');
    });

    test('CompleteMultipartUploadDto serializes properly', () {
      const dto = CompleteMultipartUploadDto(
        mediaId: 'media-uuid-1',
        uploadId: 'upload-id-abc',
        parts: [
          CompletedPartDto(partNumber: 1, etag: '"etag-1"'),
          CompletedPartDto(partNumber: 2, etag: '"etag-2"'),
        ],
      );

      final json = dto.toJson();
      expect(json['mediaId'], 'media-uuid-1');
      expect(json['uploadId'], 'upload-id-abc');
      final parts = json['parts'] as List;
      expect(parts.length, 2);
      expect(parts[0]['partNumber'], 1);
      expect(parts[0]['etag'], '"etag-1"');
      expect(parts[1]['partNumber'], 2);
      expect(parts[1]['etag'], '"etag-2"');
    });

    test('InitiateMultipartUploadResponseDto parses JSON correctly', () {
      final json = {
        'mediaId': 'media-uuid-99',
        'uploadId': 'upload-r2-session-123',
        'key': 'omni/videos/raw/sample.mp4',
        'publicUrl': 'https://pub-r2.dev/omni/videos/raw/sample.mp4',
        'parts': [
          {'partNumber': 1, 'uploadUrl': 'https://r2.dev/part1?signature=abc'},
          {'partNumber': 2, 'uploadUrl': 'https://r2.dev/part2?signature=def'},
        ],
      };

      final response = InitiateMultipartUploadResponseDto.fromJson(json);
      expect(response.mediaId, 'media-uuid-99');
      expect(response.uploadId, 'upload-r2-session-123');
      expect(response.parts.length, 2);
      expect(response.parts[0].partNumber, 1);
      expect(response.parts[0].uploadUrl, 'https://r2.dev/part1?signature=abc');
    });

    test('CompleteMultipartUploadResponseDto parses JSON correctly', () {
      final json = {
        'id': 'media-uuid-99',
        'url': 'https://pub-r2.dev/omni/videos/raw/sample.mp4',
        'status': 'PROCESSING',
        'mimeType': 'video/mp4',
        'size': 12000000,
      };

      final response = CompleteMultipartUploadResponseDto.fromJson(json);
      expect(response.id, 'media-uuid-99');
      expect(response.url, 'https://pub-r2.dev/omni/videos/raw/sample.mp4');
      expect(response.status, 'PROCESSING');
    });

    test('Full 4-Step Multipart Flow executes seamlessly and publishes post with real mediaId', () async {
      final uploadedPartBodies = <int, List<int>>{};

      final mockClient = MockClient((request) async {
        // Step 1: Initiate
        if (request.url.path == '/api/v1/media/videos/multipart-initiate' &&
            request.method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['fileName'], 'test_video.mp4');
          expect(body['partsCount'], 2);

          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'mediaId': 'media-uuid-real-123',
                'uploadId': 'upload-id-r2-789',
                'key': 'omni/videos/raw/test_video.mp4',
                'publicUrl': 'https://pub-r2.dev/omni/videos/raw/test_video.mp4',
                'parts': [
                  {
                    'partNumber': 1,
                    'uploadUrl': 'https://storage.r2.cloudflarestorage.com/part-1',
                  },
                  {
                    'partNumber': 2,
                    'uploadUrl': 'https://storage.r2.cloudflarestorage.com/part-2',
                  },
                ],
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        // Step 2: Binary PUT to R2 Part 1
        if (request.url.toString() == 'https://storage.r2.cloudflarestorage.com/part-1' &&
            request.method == 'PUT') {
          uploadedPartBodies[1] = request.bodyBytes;
          return http.Response('', 200, headers: {'etag': '"etag-part-1-xyz"'});
        }

        // Step 2: Binary PUT to R2 Part 2
        if (request.url.toString() == 'https://storage.r2.cloudflarestorage.com/part-2' &&
            request.method == 'PUT') {
          uploadedPartBodies[2] = request.bodyBytes;
          return http.Response('', 200, headers: {'etag': '"etag-part-2-uvw"'});
        }

        // Step 3: Complete
        if (request.url.path == '/api/v1/media/videos/multipart-complete' &&
            request.method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['mediaId'], 'media-uuid-real-123');
          expect(body['uploadId'], 'upload-id-r2-789');
          final parts = body['parts'] as List;
          expect(parts.length, 2);
          expect(parts[0]['partNumber'], 1);
          expect(parts[0]['etag'], '"etag-part-1-xyz"');
          expect(parts[1]['partNumber'], 2);
          expect(parts[1]['etag'], '"etag-part-2-uvw"');

          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': 'media-uuid-real-123',
                'userId': 'user-1',
                'provider': 'CLOUDFLARE_R2',
                'type': 'VIDEO',
                'url': 'https://pub-r2.dev/omni/videos/raw/test_video.mp4',
                'key': 'omni/videos/raw/test_video.mp4',
                'mimeType': 'video/mp4',
                'size': 7000000,
                'status': 'PROCESSING',
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        // Step 4: Create Post
        if (request.url.path == '/api/v1/posts' && request.method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['mediaId'], 'media-uuid-real-123');
          expect(body['videoUrl'], 'https://pub-r2.dev/omni/videos/raw/test_video.mp4');
          expect(body['title'], 'Món Phở Bò');

          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'postId': 'post-created-uuid-456',
                'userId': 'user-1',
                'title': body['title'],
                'videoUrl': body['videoUrl'],
                'mediaId': body['mediaId'],
                'thumbnailUrl': body['thumbnailUrl'],
                'duration': body['duration'],
                'allowComments': true,
                'allowDuet': false,
                'createdAt': DateTime.now().toIso8601String(),
              },
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080');
      final postService = PostApiService(apiClient: apiClient);

      // Create a temporary file of ~7 MB to test 2 chunks (with partSize 4MB)
      final tempDir = Directory.systemTemp.createTempSync('multipart_test_');
      final tempFile = File('${tempDir.path}/test_video.mp4');
      final dummyBytes = List<int>.filled(7 * 1024 * 1024, 65); // 7MB of 'A'
      await tempFile.writeAsBytes(dummyBytes);

      // Execute Steps 1-3
      final completeRes = await postService.uploadVideoMultipart(
        videoFile: tempFile,
        partSize: 4 * 1024 * 1024, // 4MB chunks => 2 parts
        token: 'auth-jwt-token',
      );

      expect(completeRes.id, 'media-uuid-real-123');
      expect(completeRes.url, 'https://pub-r2.dev/omni/videos/raw/test_video.mp4');
      expect(completeRes.status, 'PROCESSING');

      // Verify binary chunks were sent correctly
      expect(uploadedPartBodies.length, 2);
      expect(uploadedPartBodies[1]!.length, 4 * 1024 * 1024);
      expect(uploadedPartBodies[2]!.length, 3 * 1024 * 1024);

      // Step 4: Create Post with mediaId and videoUrl from Step 3
      final post = await postService.createPost(
        dto: CreatePostDto(
          title: 'Món Phở Bò',
          videoUrl: completeRes.url,
          mediaId: completeRes.id,
          thumbnailUrl: 'https://pub-r2.dev/thumbs/pho.jpg',
          duration: 60,
        ),
        token: 'auth-jwt-token',
      );

      expect(post.postId, 'post-created-uuid-456');
      expect(post.mediaId, 'media-uuid-real-123');
      expect(post.videoUrl, 'https://pub-r2.dev/omni/videos/raw/test_video.mp4');

      // Cleanup
      tempDir.deleteSync(recursive: true);
    });
  });
}
