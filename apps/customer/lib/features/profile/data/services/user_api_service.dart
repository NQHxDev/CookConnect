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

  /// Helper for executing PATCH on current user endpoints (/api/v1/users/me/*)
  Future<AuthResult> _patchUserMe({
    required String path,
    required String accessToken,
    required Map<String, dynamic> body,
    String defaultSuccessMessage = 'Cập nhật thành công',
  }) async {
    try {
      final decoded = await _client.patch(
        path,
        token: accessToken,
        body: body,
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
        message: decoded['message']?.toString() ?? defaultSuccessMessage,
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

  /// 1. Cập nhật ngày sinh và giới tính via `PATCH /api/v1/users/me/personal-info`
  Future<AuthResult> updatePersonalInfo({
    required String accessToken,
    String? dateOfBirth,
    String? gender,
  }) async {
    final bodyMap = <String, dynamic>{
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) 'dateOfBirth': dateOfBirth,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
    };

    return _patchUserMe(
      path: ApiConfig.userPersonalInfoPath,
      accessToken: accessToken,
      body: bodyMap,
      defaultSuccessMessage: 'Cập nhật thông tin cá nhân thành công',
    );
  }

  /// 2. Cập nhật tên hiển thị via `PATCH /api/v1/users/me/display-name`
  Future<AuthResult> updateDisplayName({
    required String accessToken,
    required String displayName,
  }) async {
    final bodyMap = <String, dynamic>{
      'displayName': displayName.trim(),
    };

    return _patchUserMe(
      path: ApiConfig.userDisplayNamePath,
      accessToken: accessToken,
      body: bodyMap,
      defaultSuccessMessage: 'Cập nhật tên hiển thị thành công',
    );
  }

  /// 3. Cập nhật tiểu sử via `PATCH /api/v1/users/me/bio`
  Future<AuthResult> updateBio({
    required String accessToken,
    required String bio,
  }) async {
    final bodyMap = <String, dynamic>{
      'bio': bio.trim(),
    };

    return _patchUserMe(
      path: ApiConfig.userBioPath,
      accessToken: accessToken,
      body: bodyMap,
      defaultSuccessMessage: 'Cập nhật tiểu sử thành công',
    );
  }

  /// 4. Cập nhật vị trí / địa chỉ via `PATCH /api/v1/users/me/location`
  Future<AuthResult> updateLocation({
    required String accessToken,
    required String location,
  }) async {
    final bodyMap = <String, dynamic>{
      'location': location.trim(),
    };

    return _patchUserMe(
      path: ApiConfig.userLocationPath,
      accessToken: accessToken,
      body: bodyMap,
      defaultSuccessMessage: 'Cập nhật vị trí thành công',
    );
  }

  /// 5. Cập nhật website via `PATCH /api/v1/users/me/website`
  Future<AuthResult> updateWebsite({
    required String accessToken,
    required String website,
  }) async {
    final bodyMap = <String, dynamic>{
      'website': website.trim(),
    };

    return _patchUserMe(
      path: ApiConfig.userWebsitePath,
      accessToken: accessToken,
      body: bodyMap,
      defaultSuccessMessage: 'Cập nhật website thành công',
    );
  }

  /// 6. Cập nhật ảnh bìa via `PATCH /api/v1/users/me/cover-image`
  Future<AuthResult> updateCoverImage({
    required String accessToken,
    required String coverImage,
  }) async {
    final bodyMap = <String, dynamic>{
      'coverImage': coverImage.trim(),
    };

    return _patchUserMe(
      path: ApiConfig.userCoverImagePath,
      accessToken: accessToken,
      body: bodyMap,
      defaultSuccessMessage: 'Cập nhật ảnh bìa thành công',
    );
  }

  /// 7. Cập nhật địa chỉ cư trú via `PATCH /api/v1/users/me/address`
  Future<AuthResult> updateAddress({
    required String accessToken,
    required String address,
  }) async {
    final bodyMap = <String, dynamic>{
      'address': address.trim(),
    };

    return _patchUserMe(
      path: ApiConfig.userAddressPath,
      accessToken: accessToken,
      body: bodyMap,
      defaultSuccessMessage: 'Cập nhật địa chỉ thành công',
    );
  }

  /// 8. Đổi Username (Handle) via `PATCH /api/v1/users/me/username`
  Future<AuthResult> updateUsername({
    required String accessToken,
    required String username,
  }) async {
    final bodyMap = <String, dynamic>{
      'username': username.trim().toLowerCase(),
    };

    return _patchUserMe(
      path: ApiConfig.userUsernamePath,
      accessToken: accessToken,
      body: bodyMap,
      defaultSuccessMessage: 'Cập nhật tên người dùng thành công',
    );
  }

  /// Tạo hồ sơ người dùng ban đầu via `POST /api/v1/users/profile`
  Future<AuthResult> createUserProfile({
    required String accessToken,
    required String displayName,
    String? username,
    String? gender,
    String? dateOfBirth,
    String? bio,
    String? avatar,
    String? coverImage,
    String? website,
    String? location,
    String? address,
  }) async {
    final bodyMap = <String, dynamic>{
      'displayName': displayName.trim(),
      if (address != null && address.isNotEmpty) 'address': address.trim(),
      if (username != null && username.isNotEmpty)
        'username': username.trim().toLowerCase(),
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      if (dateOfBirth != null && dateOfBirth.isNotEmpty)
        'dateOfBirth': dateOfBirth,
      if (bio != null && bio.isNotEmpty) 'bio': bio.trim(),
      if (avatar != null && avatar.isNotEmpty) 'avatar': avatar,
      if (coverImage != null && coverImage.isNotEmpty)
        'coverImage': coverImage,
      if (website != null && website.isNotEmpty) 'website': website,
      if (location != null && location.isNotEmpty) 'location': location,
    };

    try {
      final decoded = await _client.post(
        ApiConfig.userProfilePath,
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
        statusCode: decoded['statusCode'] as int? ?? 201,
        message: decoded['message']?.toString() ?? 'Tạo hồ sơ người dùng thành công',
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

  /// Cập nhật thông tin người dùng bằng cách tuần tự gọi các endpoint riêng lẻ tương ứng
  Future<AuthResult> updateUserProfile({
    required String accessToken,
    String? userId,
    String? displayName,
    String? username,
    String? gender,
    String? dateOfBirth,
    String? bio,
    String? avatar,
    String? location,
    String? address,
    String? website,
    String? coverImage,
  }) async {
    AuthResult? lastResult;

    if (displayName != null && displayName.isNotEmpty) {
      lastResult = await updateDisplayName(
        accessToken: accessToken,
        displayName: displayName,
      );
      if (!lastResult.isSuccess) return lastResult;
    }

    if (username != null && username.isNotEmpty) {
      lastResult = await updateUsername(
        accessToken: accessToken,
        username: username,
      );
      if (!lastResult.isSuccess) return lastResult;
    }

    if ((gender != null && gender.isNotEmpty) ||
        (dateOfBirth != null && dateOfBirth.isNotEmpty)) {
      lastResult = await updatePersonalInfo(
        accessToken: accessToken,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
      if (!lastResult.isSuccess) return lastResult;
    }

    if (bio != null) {
      lastResult = await updateBio(
        accessToken: accessToken,
        bio: bio,
      );
      if (!lastResult.isSuccess) return lastResult;
    }

    if (location != null && location.isNotEmpty) {
      lastResult = await updateLocation(
        accessToken: accessToken,
        location: location,
      );
      if (!lastResult.isSuccess) return lastResult;
    }

    if (address != null && address.isNotEmpty) {
      lastResult = await updateAddress(
        accessToken: accessToken,
        address: address,
      );
      if (!lastResult.isSuccess) return lastResult;
    }

    if (website != null && website.isNotEmpty) {
      lastResult = await updateWebsite(
        accessToken: accessToken,
        website: website,
      );
      if (!lastResult.isSuccess) return lastResult;
    }

    if (coverImage != null && coverImage.isNotEmpty) {
      lastResult = await updateCoverImage(
        accessToken: accessToken,
        coverImage: coverImage,
      );
      if (!lastResult.isSuccess) return lastResult;
    }

    return lastResult ??
        AuthResult(
          isSuccess: true,
          statusCode: 200,
          message: 'Cập nhật hồ sơ thành công',
        );
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
