import 'package:http/http.dart' as http;
import 'package:cookconnect/core/config/api_config.dart';
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/core/network/api_exception.dart';
import 'package:cookconnect/features/auth/data/models/auth_result.dart';
import 'package:cookconnect/features/auth/data/models/auth_tokens.dart';
import 'package:cookconnect/features/auth/data/models/auth_user.dart';
import 'package:cookconnect/features/auth/data/models/otp_result.dart';

/// API Service dedicated to authentication endpoints (OTP, Register, Login, Refresh, Logout)
class AuthApiService {
  final ApiClient _client;

  AuthApiService({ApiClient? apiClient, http.Client? httpClient})
      : _client = apiClient ?? ApiClient(client: httpClient);

  /// Request OTP for registration via `/api/v1/auth/register/send-otp`
  Future<OtpResult> sendOtp({
    required String email,
    String clientType = 'mobile',
    String appVersion = '1.0.0',
  }) async {
    try {
      final decoded = await _client.post(
        ApiConfig.sendOtpPath,
        headers: {
          'X-Client-Type': clientType,
          'X-App-Version': appVersion,
        },
        body: {
          'email': email.trim().toLowerCase(),
        },
      );

      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      return OtpResult(
        isSuccess: true,
        statusCode: decoded['statusCode'] as int? ?? 200,
        message: data['message']?.toString() ??
            decoded['message']?.toString() ??
            'Mã OTP đã được gửi đến email của bạn',
        cooldownSeconds: (data['cooldownSeconds'] as num?)?.toInt() ?? 60,
        expiresInMinutes: (data['expiresInMinutes'] as num?)?.toInt() ?? 5,
      );
    } on ApiException catch (e) {
      return OtpResult(
        isSuccess: false,
        statusCode: e.statusCode,
        error: e.message,
      );
    } catch (e) {
      return OtpResult(
        isSuccess: false,
        statusCode: 0,
        error: e.toString(),
      );
    }
  }

  /// Verify OTP code via `/api/v1/auth/register/verify-otp`
  Future<OtpResult> verifyOtp({
    required String email,
    required String otp,
    String clientType = 'mobile',
    String appVersion = '1.0.0',
  }) async {
    try {
      final decoded = await _client.post(
        ApiConfig.verifyOtpPath,
        headers: {
          'X-Client-Type': clientType,
          'X-App-Version': appVersion,
        },
        body: {
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
        },
      );

      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      final verificationToken = data['verificationToken']?.toString() ??
          data['verifyToken']?.toString() ??
          data['token']?.toString() ??
          decoded['verificationToken']?.toString() ??
          decoded['verifyToken']?.toString() ??
          decoded['token']?.toString();

      return OtpResult(
        isSuccess: true,
        statusCode: decoded['statusCode'] as int? ?? 200,
        message: decoded['message']?.toString() ?? 'Xác thực OTP thành công',
        verificationToken: verificationToken,
      );
    } on ApiException catch (e) {
      return OtpResult(
        isSuccess: false,
        statusCode: e.statusCode,
        error: e.message,
      );
    } catch (e) {
      return OtpResult(
        isSuccess: false,
        statusCode: 0,
        error: e.toString(),
      );
    }
  }

  /// Register a new account via `/api/v1/auth/register`
  Future<AuthResult> register({
    required String email,
    required String password,
    String? fullName,
    String? confirmPassword,
    String? verificationToken,
    String? deviceId,
    String clientType = 'mobile',
    String appVersion = '1.0.0',
  }) async {
    final bodyMap = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': password,
      'confirmPassword': confirmPassword ?? password,
      'clientType': clientType,
      'appVersion': appVersion,
      if (verificationToken != null && verificationToken.isNotEmpty)
        'verificationToken': verificationToken,
      if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
    };

    try {
      final decoded = await _client.post(
        ApiConfig.registerPath,
        headers: {
          'X-Client-Type': clientType,
          if (deviceId != null && deviceId.isNotEmpty) 'X-Device-Id': deviceId,
        },
        body: bodyMap,
      );

      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      var user = data['user'] is Map<String, dynamic>
          ? AuthUser.fromJson(data['user'] as Map<String, dynamic>)
          : null;

      final tokens = data['tokens'] is Map<String, dynamic>
          ? AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>)
          : null;

      if (user != null && tokens != null) {
        if ((user.accountId == null || user.accountId!.isEmpty) &&
            tokens.sub != null) {
          user = user.copyWith(accountId: tokens.sub);
        }
      }

      if (user != null && (user.fullName.isEmpty || user.fullName == user.email)) {
        if (fullName != null && fullName.isNotEmpty) {
          user = user.copyWith(fullName: fullName);
        }
      }

      // Enrich with full user profile from /api/v1/users/me if available
      if (tokens != null && tokens.accessToken.isNotEmpty) {
        try {
          final userDetail = await _client.get(
            ApiConfig.userMePath,
            token: tokens.accessToken,
          );
          final uData = userDetail['data'] is Map<String, dynamic>
              ? userDetail['data'] as Map<String, dynamic>
              : userDetail;
          final d = AuthUser.fromJson(uData);
          user = (user ?? d).copyWith(
            id: d.id.isNotEmpty ? d.id : user?.id,
            accountId: d.accountId?.isNotEmpty == true
                ? d.accountId
                : (user?.accountId ?? tokens.sub),
            userId: d.userId?.isNotEmpty == true ? d.userId : user?.userId,
            userProfileId: d.userProfileId?.isNotEmpty == true
                ? d.userProfileId
                : user?.userProfileId,
            fullName: d.fullName.isNotEmpty ? d.fullName : user?.fullName,
            username: d.username ?? user?.username,
            gender: d.gender ?? user?.gender,
            dateOfBirth: d.dateOfBirth ?? user?.dateOfBirth,
            bio: d.bio ?? user?.bio,
            avatar: d.avatar ?? user?.avatar,
            videoCount: d.videoCount,
            followerCount: d.followerCount,
            followingCount: d.followingCount,
            likeCount: d.likeCount,
          );
        } catch (_) {}
      }

      return AuthResult(
        isSuccess: true,
        statusCode: decoded['statusCode'] as int? ?? 200,
        message: decoded['message']?.toString() ?? 'Đăng ký thành công',
        user: user,
        tokens: tokens,
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

  /// Login via `/api/v1/auth/login`
  Future<AuthResult> login({
    required String email,
    required String password,
    String? deviceId,
    String clientType = 'mobile',
    String appVersion = '1.0.0',
  }) async {
    try {
      final decoded = await _client.post(
        ApiConfig.loginPath,
        headers: {
          'X-Client-Type': clientType,
          if (deviceId != null && deviceId.isNotEmpty) 'X-Device-Id': deviceId,
        },
        body: {
          'email': email.trim(),
          'password': password,
          'clientType': clientType,
          'appVersion': appVersion,
          if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
        },
      );

      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      var user = data['user'] is Map<String, dynamic>
          ? AuthUser.fromJson(data['user'] as Map<String, dynamic>)
          : (data['email'] != null || data['sub'] != null || data['id'] != null
              ? AuthUser.fromJson(data)
              : null);

      final tokens = data['tokens'] is Map<String, dynamic>
          ? AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>)
          : (decoded['tokens'] is Map<String, dynamic>
              ? AuthTokens.fromJson(decoded['tokens'] as Map<String, dynamic>)
              : (decoded['accessToken'] != null
                  ? AuthTokens.fromJson(decoded)
                  : null));

      if (user != null && tokens != null) {
        if ((user.accountId == null || user.accountId!.isEmpty) &&
            tokens.sub != null) {
          user = user.copyWith(accountId: tokens.sub);
        }
      }

      // Enrich with full user profile from /api/v1/users/me
      if (tokens != null && tokens.accessToken.isNotEmpty) {
        try {
          final userDetail = await _client.get(
            ApiConfig.userMePath,
            token: tokens.accessToken,
          );
          final uData = userDetail['data'] is Map<String, dynamic>
              ? userDetail['data'] as Map<String, dynamic>
              : userDetail;
          final d = AuthUser.fromJson(uData);
          user = (user ?? d).copyWith(
            id: d.id.isNotEmpty ? d.id : user?.id,
            accountId: d.accountId?.isNotEmpty == true
                ? d.accountId
                : (user?.accountId ?? tokens.sub),
            userId: d.userId?.isNotEmpty == true ? d.userId : user?.userId,
            userProfileId: d.userProfileId?.isNotEmpty == true
                ? d.userProfileId
                : user?.userProfileId,
            fullName: d.fullName.isNotEmpty ? d.fullName : user?.fullName,
            username: d.username ?? user?.username,
            gender: d.gender ?? user?.gender,
            dateOfBirth: d.dateOfBirth ?? user?.dateOfBirth,
            bio: d.bio ?? user?.bio,
            avatar: d.avatar ?? user?.avatar,
            videoCount: d.videoCount,
            followerCount: d.followerCount,
            followingCount: d.followingCount,
            likeCount: d.likeCount,
          );
        } catch (_) {
          final targetLookupId = user?.userId ?? user?.id;
          if (targetLookupId != null && targetLookupId.isNotEmpty) {
            try {
              final fallback = await _client.get(
                '/api/${ApiConfig.apiVersion}/users/$targetLookupId',
                token: tokens.accessToken,
              );
              final fData = fallback['data'] is Map<String, dynamic>
                  ? fallback['data'] as Map<String, dynamic>
                  : fallback;
              final d = AuthUser.fromJson(fData);
              user = user?.copyWith(
                id: d.id.isNotEmpty ? d.id : user.id,
                accountId: d.accountId?.isNotEmpty == true
                    ? d.accountId
                    : (user.accountId ?? tokens.sub),
                userId: d.userId?.isNotEmpty == true ? d.userId : user.userId,
                userProfileId: d.userProfileId?.isNotEmpty == true
                    ? d.userProfileId
                    : user.userProfileId,
                fullName: d.fullName.isNotEmpty ? d.fullName : user.fullName,
                username: d.username ?? user.username,
                gender: d.gender ?? user.gender,
                dateOfBirth: d.dateOfBirth ?? user.dateOfBirth,
                bio: d.bio ?? user.bio,
                avatar: d.avatar ?? user.avatar,
                videoCount: d.videoCount,
                followerCount: d.followerCount,
                followingCount: d.followingCount,
                likeCount: d.likeCount,
              );
            } catch (_) {}
          }
        }
      }

      return AuthResult(
        isSuccess: true,
        statusCode: decoded['statusCode'] as int? ?? 200,
        message: decoded['message']?.toString() ?? 'Đăng nhập thành công',
        user: user,
        tokens: tokens,
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

  /// Log out via `/api/v1/auth/logout`
  Future<bool> logout(String accessToken) async {
    try {
      await _client.post(
        ApiConfig.logoutPath,
        token: accessToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Refresh token via `/api/v1/auth/refresh`
  Future<AuthResult> refreshToken(String refreshToken) async {
    try {
      final decoded = await _client.post(
        ApiConfig.refreshPath,
        headers: {
          'x-refresh-token': refreshToken,
        },
        body: {'refreshToken': refreshToken},
      );

      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      final tokens = data['tokens'] is Map<String, dynamic>
          ? AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>)
          : null;

      return AuthResult(
        isSuccess: true,
        statusCode: decoded['statusCode'] as int? ?? 200,
        tokens: tokens,
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
