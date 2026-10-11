import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cookconnect/core/config/api_config.dart';
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/core/network/api_exception.dart';
import 'package:cookconnect/features/auth/data/models/auth_result.dart';
import 'package:cookconnect/features/auth/data/models/auth_user.dart';
import 'package:cookconnect/features/auth/data/models/auth_tokens.dart';

class HealthCheckResult {
  final bool isHealthy;
  final int statusCode;
  final String? message;
  final Map<String, dynamic>? data;
  final String? error;

  HealthCheckResult({
    required this.isHealthy,
    required this.statusCode,
    this.message,
    this.data,
    this.error,
  });
}

/// API Service dedicated to user profile endpoints
class UserApiService {
  final ApiClient _client;

  UserApiService({ApiClient? apiClient, http.Client? httpClient})
      : _client = apiClient ?? ApiClient(client: httpClient);

  /// Check server health at `/api/v1/health`
  Future<HealthCheckResult> checkHealth() async {
    try {
      final decoded = await _client.get(ApiConfig.healthPath);
      return HealthCheckResult(
        isHealthy: true,
        statusCode: decoded['statusCode'] as int? ?? 200,
        message: decoded['message']?.toString() ?? 'OK',
        data: decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : null,
      );
    } on ApiException catch (e) {
      return HealthCheckResult(
        isHealthy: false,
        statusCode: e.statusCode,
        error: e.statusCode == 0 ? (e.error ?? e.message) : e.message,
      );
    } catch (e) {
      return HealthCheckResult(
        isHealthy: false,
        statusCode: 0,
        error: e.toString(),
      );
    }
  }

  /// Check if username is available using `GET /api/v1/users/check-username?username=...`
  Future<bool> checkUsername(String username) async {
    final clean = username.trim().toLowerCase();
    if (clean.isEmpty) return false;

    try {
      final decoded = await _client.get(
        ApiConfig.checkUsernamePath,
        queryParams: {'username': clean},
      );
      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;
      return data['available'] == true;
    } catch (_) {
      return true;
    }
  }

  /// Get current user profile details via `GET /api/v1/users/me`
  Future<AuthResult> getMyUserProfile(String accessToken) async {
    try {
      final decoded = await _client.get(
        ApiConfig.userMePath,
        token: accessToken,
      );

      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      final user = AuthUser.fromJson(data);
      return AuthResult(
        isSuccess: true,
        statusCode: decoded['statusCode'] as int? ?? 200,
        user: user,
      );
    } on ApiException catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: e.statusCode,
        error: e.message,
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: e.toString(),
      );
    }
  }

  /// Get user profile details by ID via `GET /api/v1/users/{id}`
  Future<AuthResult> getUserDetails({
    required String accessToken,
    required String userId,
  }) async {
    try {
      final decoded = await _client.get(
        '/api/${ApiConfig.apiVersion}/users/$userId',
        token: accessToken,
      );

      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      final user = AuthUser.fromJson(data);
      return AuthResult(
        isSuccess: true,
        statusCode: decoded['statusCode'] as int? ?? 200,
        user: user,
      );
    } on ApiException catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: e.statusCode,
        error: e.message,
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: e.toString(),
      );
    }
  }

  /// Resolve image Content-Type / MIME type for multipart upload
  MediaType _resolveImageContentType(
    String filename,
    List<int> bytes, [
    String? explicitMimeType,
  ]) {
    if (explicitMimeType != null && explicitMimeType.trim().isNotEmpty) {
      try {
        return MediaType.parse(explicitMimeType.trim());
      } catch (_) {}
    }

    final lower = filename.toLowerCase();
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.gif')) return MediaType('image', 'gif');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }

    if (bytes.length >= 12) {
      if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return MediaType('image', 'webp');
      }
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return MediaType('image', 'png');
      }
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return MediaType('image', 'jpeg');
      }
      if (bytes[0] == 0x47 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x38) {
        return MediaType('image', 'gif');
      }
    }

    return MediaType('image', 'jpeg');
  }

  /// Upload user avatar image via `POST /api/v1/users/me/avatar` (multipart/form-data)
  Future<AuthResult> uploadAvatar({
    required String accessToken,
    required List<int> fileBytes,
    required String filename,
    String? mimeType,
  }) async {
    final contentType = _resolveImageContentType(filename, fileBytes, mimeType);

    try {
      final decoded = await _client.uploadMultipart(
        ApiConfig.avatarPath,
        fileField: 'file',
        fileBytes: fileBytes,
        filename: filename,
        contentType: contentType,
        token: accessToken,
      );

      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      final avatarUrl = data['avatarUrl']?.toString() ??
          data['avatar']?.toString() ??
          (data['user'] is Map<String, dynamic>
              ? (data['user']['avatar']?.toString() ??
                  (data['user']['profile'] is Map<String, dynamic>
                      ? data['user']['profile']['avatar']?.toString()
                      : null))
              : null);

      var user = data['user'] is Map<String, dynamic>
          ? AuthUser.fromJson(data['user'] as Map<String, dynamic>)
          : null;

      if (user == null && avatarUrl != null) {
        user = AuthUser(
          id: '',
          email: '',
          fullName: '',
          avatar: avatarUrl,
        );
      } else if (user != null &&
          avatarUrl != null &&
          (user.avatar == null || user.avatar!.isEmpty)) {
        user = user.copyWith(avatar: avatarUrl);
      }

      return AuthResult(
        isSuccess: true,
        statusCode: decoded['statusCode'] as int? ?? 200,
        message: decoded['message']?.toString() ?? 'Tải ảnh đại diện thành công',
        user: user,
      );
    } on ApiException catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: e.statusCode,
        error: e.message,
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: e.toString(),
      );
    }
  }

  /// Update user profile via `PATCH /api/v1/users/me` or `PATCH /api/v1/users/{id}`
  Future<AuthResult> updateUserProfile({
    required String accessToken,
    String? userId,
    String? displayName,
    String? username,
    String? gender,
    String? dateOfBirth,
    String? bio,
    String? avatar,
  }) async {
    final endpoint = (userId != null && userId.isNotEmpty)
        ? '/api/${ApiConfig.apiVersion}/users/$userId'
        : ApiConfig.userMePath;

    final bodyMap = <String, dynamic>{
      if (displayName != null && displayName.isNotEmpty)
        'displayName': displayName.trim(),
      if (username != null && username.isNotEmpty)
        'username': username.trim().toLowerCase(),
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      if (dateOfBirth != null && dateOfBirth.isNotEmpty)
        'dateOfBirth': dateOfBirth,
      if (bio != null) 'bio': bio.trim(),
      if (avatar != null && avatar.isNotEmpty) 'avatar': avatar,
    };

    try {
      final decoded = await _client.patch(
        endpoint,
        token: accessToken,
        body: bodyMap,
      );

      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      final userMap = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : data;

      final user = AuthUser.fromJson(userMap);

      return AuthResult(
        isSuccess: true,
        statusCode: decoded['statusCode'] as int? ?? 200,
        message: 'Cập nhật hồ sơ thành công',
        user: user,
      );
    } on ApiException catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: e.statusCode,
        error: e.message,
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: e.toString(),
      );
    }
  }

  /// Get current user profile directly via User Service (`/api/v1/users/me`).
  /// Does not call Auth Service (`/api/v1/auth/me`) since email is not needed in the profile page.
  /// Falls back to Auth Service only if User Service is unavailable or in mock test environments.
  Future<AuthResult> getProfile(String accessToken, {String? userId}) async {
    try {
      // 1. Primary: Fetch directly from User Service (/api/v1/users/me)
      final userDetailResult = await getMyUserProfile(accessToken);
      if (userDetailResult.isSuccess && userDetailResult.user != null) {
        return userDetailResult;
      }

      if (userId != null &&
          userId.isNotEmpty &&
          !userId.startsWith('demo-')) {
        final detailResult = await getUserDetails(
          accessToken: accessToken,
          userId: userId,
        );
        if (detailResult.isSuccess && detailResult.user != null) {
          return detailResult;
        }
      }

      // 2. Fallback to /api/v1/auth/me if user service is unavailable or in mock test suites
      final decoded = await _client.get(
        ApiConfig.mePath,
        token: accessToken,
      );

      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      var authUser = data['user'] is Map<String, dynamic>
          ? AuthUser.fromJson(data['user'] as Map<String, dynamic>)
          : (data['email'] != null || data['sub'] != null || data['id'] != null
              ? AuthUser.fromJson(data)
              : null);

      if (authUser != null && (authUser.accountId == null || authUser.accountId!.isEmpty)) {
        final tokenPayload = AuthTokens.getJwtPayload(accessToken);
        final sub = tokenPayload?['sub']?.toString();
        if (sub != null && sub.isNotEmpty) {
          authUser = authUser.copyWith(accountId: sub);
        }
      }

      return AuthResult(
        isSuccess: true,
        statusCode: decoded['statusCode'] as int? ?? 200,
        user: authUser,
      );
    } on ApiException catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: e.statusCode,
        error: e.message,
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: e.toString(),
      );
    }
  }
}
