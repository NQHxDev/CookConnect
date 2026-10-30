import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:cookconnect/core/config/api_config.dart';
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/core/network/api_exception.dart';
import 'package:cookconnect/features/recipe/data/models/create_post_dto.dart';
import 'package:cookconnect/features/recipe/data/models/multipart_upload_models.dart';
import 'package:cookconnect/features/recipe/data/models/post_item.dart';

class PostApiService {
  /// Bumped whenever the current user's posts change (e.g. after publishing).
  static final ValueNotifier<int> postsChanged = ValueNotifier<int>(0);

  final ApiClient _client;

  PostApiService({ApiClient? apiClient}) : _client = apiClient ?? ApiClient();

  /// Retrieves infinite scroll feed of video posts
  Future<PostFeedResponse> getFeed({
    String? cursor,
    int limit = 3,
    String? userId,
    String? tag,
    String? category,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
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

  /// Publishes a new video recipe post
  Future<PostItem> createPost({
    required CreatePostDto dto,
    String? token,
  }) async {
    final response = await _client.post(
      ApiConfig.postsPath,
      body: dto.toJson(),
      token: token,
    );

    postsChanged.value++;
    final data = response['data'] ?? response;
    return PostItem.fromJson(data as Map<String, dynamic>);
  }

  /// Step 1: Initiates a multipart video upload session on Cloudflare R2
  Future<InitiateMultipartUploadResponseDto> initiateVideoMultipartUpload({
    required String fileName,
    required String mimeType,
    required int partsCount,
    int? fileSize,
    String? folder,
    String? token,
  }) async {
    final dto = InitiateMultipartUploadDto(
      fileName: fileName,
      mimeType: mimeType,
      partsCount: partsCount,
      fileSize: fileSize,
      folder: folder,
    );

    final response = await _client.post(
      ApiConfig.mediaVideoMultipartInitiatePath,
      body: dto.toJson(),
      token: token,
    );

    final data = response['data'] ?? response;
    return InitiateMultipartUploadResponseDto.fromJson(
      data as Map<String, dynamic>,
    );
  }

  /// Step 3: Completes multipart video upload on Cloudflare R2 and triggers async HLS transcoding
  Future<CompleteMultipartUploadResponseDto> completeVideoMultipartUpload({
    required String mediaId,
    required String uploadId,
    required List<CompletedPartDto> parts,
    String? token,
  }) async {
    final dto = CompleteMultipartUploadDto(
      mediaId: mediaId,
      uploadId: uploadId,
      parts: parts,
    );

    final response = await _client.post(
      ApiConfig.mediaVideoMultipartCompletePath,
      body: dto.toJson(),
      token: token,
    );

    final data = response['data'] ?? response;
    return CompleteMultipartUploadResponseDto.fromJson(
      data as Map<String, dynamic>,
    );
  }

  /// Full 3-step R2 multipart upload flow (recommended for video uploads):
  /// - Step 1: POST /api/v1/media/videos/multipart-initiate
  /// - Step 2: Binary PUT chunks directly to Cloudflare R2 presigned URLs
  /// - Step 3: POST /api/v1/media/videos/multipart-complete
  /// Returns the completed media object with `id` (mediaId) and `url`.
  Future<CompleteMultipartUploadResponseDto> uploadVideoMultipart({
    required File videoFile,
    String? token,
    int partSize = 5 * 1024 * 1024, // 5MB standard chunk size
    void Function(double progress, String status)? onProgress,
  }) async {
    if (!videoFile.existsSync()) {
      throw ApiException(
        statusCode: 400,
        message: 'File video không tồn tại trên thiết bị',
      );
    }

    final fileSize = await videoFile.length();
    if (fileSize <= 0) {
      throw ApiException(
        statusCode: 400,
        message: 'File video trống hoặc bị lỗi',
      );
    }

    final fileName = videoFile.uri.pathSegments.isNotEmpty
        ? videoFile.uri.pathSegments.last
        : 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final lowerName = fileName.toLowerCase();
    final mimeType = lowerName.endsWith('.mov')
        ? 'video/quicktime'
        : (lowerName.endsWith('.webm') ? 'video/webm' : 'video/mp4');

    final partsCount = (fileSize / partSize).ceil().clamp(1, 10000);

    onProgress?.call(0.05, 'Khởi tạo phiên tải video lên R2...');

    // Step 1: Initiate multipart upload
    final initiateRes = await initiateVideoMultipartUpload(
      fileName: fileName,
      mimeType: mimeType,
      partsCount: partsCount,
      fileSize: fileSize,
      token: token,
    );

    if (initiateRes.parts.isEmpty) {
      throw ApiException(
        statusCode: 500,
        message: 'Server không trả về URL tải part cho video',
      );
    }

    // Step 2: Upload binary chunks sequentially to R2 presigned URLs
    final sortedPartUrls = List<MultipartPartUrlDto>.from(initiateRes.parts)
      ..sort((a, b) => a.partNumber.compareTo(b.partNumber));

    final completedParts = <CompletedPartDto>[];
    final raf = await videoFile.open(mode: FileMode.read);

    try {
      for (int i = 0; i < sortedPartUrls.length; i++) {
        final part = sortedPartUrls[i];
        final partNumber = part.partNumber;
        final start = (partNumber - 1) * partSize;
        final end = (start + partSize) > fileSize
            ? fileSize
            : (start + partSize);
        final length = end - start;

        await raf.setPosition(start);
        final chunkBytes = await raf.read(length);

        final partStatus =
            'Đang tải video: phần ${i + 1}/${sortedPartUrls.length}...';
        final progress = 0.1 + (0.75 * (i / sortedPartUrls.length));
        onProgress?.call(progress, partStatus);

        final putResponse = await _client.putBinary(
          part.uploadUrl,
          bytes: chunkBytes,
        );

        if (putResponse.statusCode < 200 || putResponse.statusCode >= 300) {
          throw ApiException(
            message:
                'Tải chunk $partNumber lên R2 thất bại (HTTP ${putResponse.statusCode})',
            statusCode: putResponse.statusCode,
          );
        }

        final rawEtag =
            putResponse.headers['etag'] ?? putResponse.headers['ETag'];
        if (rawEtag == null || rawEtag.isEmpty) {
          throw ApiException(
            statusCode: putResponse.statusCode,
            message: 'Không nhận được ETag từ R2 cho chunk $partNumber',
          );
        }

        completedParts.add(
          CompletedPartDto(partNumber: partNumber, etag: rawEtag),
        );
      }
    } finally {
      await raf.close();
    }

    onProgress?.call(0.9, 'Hoàn tất ghép part và kích hoạt xử lý...');

    // Step 3: Complete multipart upload
    final completeRes = await completeVideoMultipartUpload(
      mediaId: initiateRes.mediaId,
      uploadId: initiateRes.uploadId,
      parts: completedParts,
      token: token,
    );

    onProgress?.call(1.0, 'Tải video thành công!');
    return completeRes;
  }

  /// Uploads media file to backend proxy storage and returns public URL
  Future<String?> uploadMedia({
    required List<int> fileBytes,
    required String fileName,
    String type = 'IMAGE',
    String? mimeType,
    String? token,
  }) async {
    final base64String = base64Encode(fileBytes);
    final determinedMime =
        mimeType ??
        (type == 'VIDEO'
            ? 'video/mp4'
            : (fileName.toLowerCase().endsWith('.png')
                  ? 'image/png'
                  : 'image/jpeg'));

    final payload = {
      'fileBase64': 'data:$determinedMime;base64,$base64String',
      'fileName': fileName,
      'mimeType': determinedMime,
      'type': type,
    };

    final response = await _client.post(
      ApiConfig.mediaUploadPath,
      body: payload,
      token: token,
    );

    final data = response['data'] ?? response;
    return data['url']?.toString();
  }
}
