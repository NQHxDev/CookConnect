import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

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

class OtpResult {
  final bool isSuccess;
  final int statusCode;
  final String? message;
  final String? verificationToken;
  final int? cooldownSeconds;
  final int? expiresInMinutes;
  final String? error;

  OtpResult({
    required this.isSuccess,
    required this.statusCode,
    this.message,
    this.verificationToken,
    this.cooldownSeconds,
    this.expiresInMinutes,
    this.error,
  });
}

class AuthUser {
  final String id;
  final String email;
  final String fullName;
  final String? username;
  final String? gender;
  final String? dateOfBirth;
  final String? bio;
  final String? avatar;
  final List<String> roles;
  final String? status;
  final bool isEmailVerified;
  final int videoCount;
  final int followerCount;
  final int followingCount;
  final int likeCount;

  AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.username,
    this.gender,
    this.dateOfBirth,
    this.bio,
    this.avatar,
    this.roles = const ['USER'],
    this.status,
    this.isEmailVerified = false,
    this.videoCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.likeCount = 0,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    // 1. Support nested profile object (from User microservice)
    final profile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : null;

    // 2. Support nested stats object (from User microservice)
    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : null;

    // 3. User Identifier (supports id, userId, sub)
    final id = json['id']?.toString() ??
        json['userId']?.toString() ??
        json['sub']?.toString() ??
        '';

    // 4. Email address
    final email = json['email']?.toString() ??
        profile?['email']?.toString() ??
        '';

    // 5. Display Name / Full Name
    final rawName = json['fullName'] ??
        json['displayName'] ??
        json['name'] ??
        profile?['displayName'] ??
        profile?['fullName'] ??
        profile?['name'];

    final name = rawName != null && rawName.toString().trim().isNotEmpty
        ? rawName.toString().trim()
        : (json['username'] != null && json['username'].toString().trim().isNotEmpty
            ? json['username'].toString().trim()
            : (email.isNotEmpty
                ? email.split('@').first
                : ''));

    // 6. Username
    final username = json['username']?.toString() ??
        profile?['username']?.toString();

    // 7. Profile details
    final gender = json['gender']?.toString() ?? profile?['gender']?.toString();
    final dateOfBirth = json['dateOfBirth']?.toString() ??
        profile?['dateOfBirth']?.toString();
    final bio = json['bio']?.toString() ?? profile?['bio']?.toString();
    final avatar = json['avatar']?.toString() ?? profile?['avatar']?.toString();

    // 8. Roles
    final roles = (json['roles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const ['USER'];

    // 9. Stats
    final videoCount = (json['videoCount'] as num?)?.toInt() ??
        (stats?['postsCount'] as num?)?.toInt() ??
        (json['postsCount'] as num?)?.toInt() ??
        0;

    final followerCount = (json['followerCount'] as num?)?.toInt() ??
        (stats?['followersCount'] as num?)?.toInt() ??
        (json['followersCount'] as num?)?.toInt() ??
        0;

    final followingCount = (json['followingCount'] as num?)?.toInt() ??
        (stats?['followingCount'] as num?)?.toInt() ??
        (json['followingCount'] as num?)?.toInt() ??
        0;

    final likeCount = (json['likeCount'] as num?)?.toInt() ??
        (stats?['likeCount'] as num?)?.toInt() ??
        0;

    return AuthUser(
      id: id,
      email: email,
      fullName: name,
      username: username,
      gender: gender,
      dateOfBirth: dateOfBirth,
      bio: bio,
      avatar: avatar,
      roles: roles,
      status: json['status']?.toString(),
      isEmailVerified: json['isEmailVerified'] == true,
      videoCount: videoCount,
      followerCount: followerCount,
      followingCount: followingCount,
      likeCount: likeCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'displayName': fullName,
    if (username != null) 'username': username,
    if (gender != null) 'gender': gender,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    if (bio != null) 'bio': bio,
    if (avatar != null) 'avatar': avatar,
    'roles': roles,
    'status': status,
    'isEmailVerified': isEmailVerified,
    'videoCount': videoCount,
    'followerCount': followerCount,
    'followingCount': followingCount,
    'likeCount': likeCount,
  };

  AuthUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? gender,
    String? dateOfBirth,
    String? bio,
    String? avatar,
    List<String>? roles,
    String? status,
    bool? isEmailVerified,
    int? videoCount,
    int? followerCount,
    int? followingCount,
    int? likeCount,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      videoCount: videoCount ?? this.videoCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime createdAt;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 900,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final createdAtMillis = (json['createdAt'] as num?)?.toInt();
    return AuthTokens(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 900,
      createdAt: createdAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(createdAtMillis)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'expiresIn': expiresIn,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  /// Checks whether the access token is expired based on JWT payload or issuance duration.
  bool isAccessTokenExpired({Duration buffer = const Duration(seconds: 10)}) {
    if (accessToken.isEmpty) return true;
    if (accessToken.startsWith('demo-')) return false;

    // 1. Check JWT 'exp' timestamp
    final jwtExp = getJwtExpiryDate(accessToken);
    if (jwtExp != null) {
      return DateTime.now().add(buffer).isAfter(jwtExp);
    }

    // 2. Check local duration
    if (expiresIn > 0) {
      final expiryTime = createdAt.add(Duration(seconds: expiresIn));
      return DateTime.now().add(buffer).isAfter(expiryTime);
    }

    return false;
  }

  /// Checks whether the refresh token is expired (if JWT formatted).
  bool isRefreshTokenExpired({Duration buffer = const Duration(seconds: 5)}) {
    if (refreshToken.isEmpty) return true;
    if (refreshToken.startsWith('demo-')) return false;

    final jwtExp = getJwtExpiryDate(refreshToken);
    if (jwtExp != null) {
      return DateTime.now().add(buffer).isAfter(jwtExp);
    }
    return false;
  }

  /// Extracts expiry DateTime from JWT payload if available.
  static DateTime? getJwtExpiryDate(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded);
      if (map is Map<String, dynamic> && map.containsKey('exp')) {
        final expNum = map['exp'];
        if (expNum is num) {
          return DateTime.fromMillisecondsSinceEpoch(expNum.toInt() * 1000);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final int statusCode;
  final String? message;
  final AuthUser? user;
  final AuthTokens? tokens;
  final String? error;

  AuthResult({
    required this.isSuccess,
    required this.statusCode,
    this.message,
    this.user,
    this.tokens,
    this.error,
  });
}

class ApiService {
  /// Global default client override (useful for mocking during integration and widget tests).
  static http.Client? defaultClient;

  /// Global handlers for automatic token refresh & session expiration handling
  static Future<String?> Function()? tokenRefreshHandler;
  static void Function()? sessionExpiredHandler;

  final http.Client _client;

  ApiService({http.Client? client})
    : _client = client ?? defaultClient ?? http.Client();

  /// Check server health at `/api/v1/health`
  Future<HealthCheckResult> checkHealth() async {
    final uri = Uri.parse(ApiConfig.healthUrl);
    try {
      final response = await _client
          .get(uri)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return HealthCheckResult(
          isHealthy: true,
          statusCode: response.statusCode,
          message: decoded['message']?.toString() ?? 'OK',
          data: decoded['data'] is Map<String, dynamic>
              ? decoded['data'] as Map<String, dynamic>
              : null,
        );
      } else {
        return HealthCheckResult(
          isHealthy: false,
          statusCode: response.statusCode,
          error:
              'Server returned HTTP ${response.statusCode}: ${response.body}',
        );
      }
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

    final uri = Uri.parse(
      '${ApiConfig.checkUsernameUrl}?username=${Uri.encodeComponent(clean)}',
    );
    final headers = {
      'Accept': 'application/json',
    };

    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : decoded;
        return data['available'] == true;
      }
      return false;
    } catch (_) {
      return true;
    }
  }

  /// Request OTP for registration via `/api/v1/auth/register/send-otp`
  /// Body: strictly SendRegisterOtpDto `{ "email": string }`
  Future<OtpResult> sendOtp({
    required String email,
    String clientType = 'mobile',
    String appVersion = '1.0.0',
  }) async {
    final uri = Uri.parse(ApiConfig.sendOtpUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Type': clientType,
      'X-App-Version': appVersion,
    };

    // Send strictly { email } without extraneous fields to satisfy NestJS ValidationPipe
    final body = jsonEncode({
      'email': email.trim().toLowerCase(),
    });

    try {
      final response = await _client
          .post(uri, headers: headers, body: body)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : decoded;

        return OtpResult(
          isSuccess: true,
          statusCode: response.statusCode,
          message:
              data['message']?.toString() ??
              decoded['message']?.toString() ??
              'Mã OTP đã được gửi đến email của bạn',
          cooldownSeconds: (data['cooldownSeconds'] as num?)?.toInt() ?? 60,
          expiresInMinutes: (data['expiresInMinutes'] as num?)?.toInt() ?? 5,
        );
      } else {
        final msg = _extractErrorMessage(decoded, isRegister: true);
        return OtpResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error: msg,
        );
      }
    } catch (e) {
      return OtpResult(
        isSuccess: false,
        statusCode: 0,
        error: _formatNetworkError(e),
      );
    }
  }

  /// Verify OTP code via `/api/v1/auth/register/verify-otp`
  /// Body: strictly VerifyRegisterOtpDto `{ "email": string, "otp": string }`
  Future<OtpResult> verifyOtp({
    required String email,
    required String otp,
    String clientType = 'mobile',
    String appVersion = '1.0.0',
  }) async {
    final uri = Uri.parse(ApiConfig.verifyOtpUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Type': clientType,
      'X-App-Version': appVersion,
    };

    // Send strictly { email, otp } without extraneous fields to satisfy NestJS ValidationPipe
    final body = jsonEncode({
      'email': email.trim().toLowerCase(),
      'otp': otp.trim(),
    });

    try {
      final response = await _client
          .post(uri, headers: headers, body: body)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : decoded;
        final verificationToken =
            data['verificationToken']?.toString() ??
            data['verifyToken']?.toString() ??
            data['token']?.toString() ??
            decoded['verificationToken']?.toString() ??
            decoded['verifyToken']?.toString() ??
            decoded['token']?.toString();

        return OtpResult(
          isSuccess: true,
          statusCode: response.statusCode,
          message:
              decoded['message']?.toString() ?? 'Xác thực OTP thành công',
          verificationToken: verificationToken,
        );
      } else {
        final msg = _extractErrorMessage(decoded, isRegister: true);
        return OtpResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error: msg,
        );
      }
    } catch (e) {
      return OtpResult(
        isSuccess: false,
        statusCode: 0,
        error: _formatNetworkError(e),
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
    final uri = Uri.parse(ApiConfig.registerUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Type': clientType,
      if (deviceId != null && deviceId.isNotEmpty) 'X-Device-Id': deviceId,
    };

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
      final response = await _client
          .post(uri, headers: headers, body: jsonEncode(bodyMap))
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : decoded;

        var user = data['user'] is Map<String, dynamic>
            ? AuthUser.fromJson(data['user'] as Map<String, dynamic>)
            : null;

        if (user != null &&
            (user.fullName.isEmpty || user.fullName == user.email)) {
          if (fullName != null && fullName.isNotEmpty) {
            user = user.copyWith(fullName: fullName);
          }
        }

        final tokens = data['tokens'] is Map<String, dynamic>
            ? AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>)
            : null;

        return AuthResult(
          isSuccess: true,
          statusCode: response.statusCode,
          message: decoded['message']?.toString() ?? 'Đăng ký thành công',
          user: user,
          tokens: tokens,
        );
      } else {
        final msg = _extractErrorMessage(decoded, isRegister: true);
        return AuthResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error: msg,
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: _formatNetworkError(e),
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
    final uri = Uri.parse(ApiConfig.loginUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Type': clientType,
      if (deviceId != null && deviceId.isNotEmpty) 'X-Device-Id': deviceId,
    };

    final body = jsonEncode({
      'email': email.trim(),
      'password': password,
      'clientType': clientType,
      'appVersion': appVersion,
      if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
    });

    try {
      final response = await _client
          .post(uri, headers: headers, body: body)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : decoded;

        var user = data['user'] is Map<String, dynamic>
            ? AuthUser.fromJson(data['user'] as Map<String, dynamic>)
            : null;

        final tokens = data['tokens'] is Map<String, dynamic>
            ? AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>)
            : null;

        // Enrich with full user profile from /api/v1/users/me
        if (tokens != null) {
          try {
            final detailResult = await getMyUserProfile(tokens.accessToken);
            if (detailResult.isSuccess && detailResult.user != null) {
              final d = detailResult.user!;
              user = (user ?? d).copyWith(
                id: d.id.isNotEmpty ? d.id : user?.id,
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
            } else if (user != null && user.id.isNotEmpty) {
              final fallbackResult = await getUserDetails(
                accessToken: tokens.accessToken,
                userId: user.id,
              );
              if (fallbackResult.isSuccess && fallbackResult.user != null) {
                final d = fallbackResult.user!;
                user = user.copyWith(
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
              }
            }
          } catch (_) {}
        }

        return AuthResult(
          isSuccess: true,
          statusCode: response.statusCode,
          message: decoded['message']?.toString() ?? 'Đăng nhập thành công',
          user: user,
          tokens: tokens,
        );
      } else {
        final msg = _extractErrorMessage(decoded, isRegister: false);
        return AuthResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error: msg,
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: _formatNetworkError(e),
      );
    }
  }

  /// Get current user profile details via `GET /api/v1/users/me`
  Future<AuthResult> getMyUserProfile(String accessToken) async {
    final uri = Uri.parse(ApiConfig.userMeUrl);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };

    try {
      var response = await _client
          .get(uri, headers: headers)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 401 &&
          tokenRefreshHandler != null &&
          !accessToken.startsWith('demo-')) {
        final newAccessToken = await tokenRefreshHandler!();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $newAccessToken';
          response = await _client
              .get(uri, headers: headers)
              .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
        }
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : decoded;

        final user = AuthUser.fromJson(data);
        return AuthResult(
          isSuccess: true,
          statusCode: response.statusCode,
          user: user,
        );
      } else {
        if (response.statusCode == 401) {
          sessionExpiredHandler?.call();
        }
        final msg = _extractErrorMessage(
          decoded,
          defaultMessage: 'Không thể tải thông tin cá nhân',
        );
        return AuthResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error: msg,
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: _formatNetworkError(e),
      );
    }
  }

  /// Get user profile details by ID via `GET /api/v1/users/{id}`
  Future<AuthResult> getUserDetails({
    required String accessToken,
    required String userId,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/${ApiConfig.apiVersion}/users/$userId',
    );
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };

    try {
      var response = await _client
          .get(uri, headers: headers)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 401 &&
          tokenRefreshHandler != null &&
          !accessToken.startsWith('demo-')) {
        final newAccessToken = await tokenRefreshHandler!();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $newAccessToken';
          response = await _client
              .get(uri, headers: headers)
              .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
        }
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : decoded;

        final user = AuthUser.fromJson(data);
        return AuthResult(
          isSuccess: true,
          statusCode: response.statusCode,
          user: user,
        );
      } else {
        if (response.statusCode == 401) {
          sessionExpiredHandler?.call();
        }
        final msg = _extractErrorMessage(
          decoded,
          defaultMessage: 'Không tìm thấy người dùng',
        );
        return AuthResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error: msg,
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: _formatNetworkError(e),
      );
    }
  }

  /// Upload user avatar image via `POST /api/v1/users/me/avatar` (multipart/form-data)
  Future<AuthResult> uploadAvatar({
    required String accessToken,
    required List<int> fileBytes,
    required String filename,
  }) async {
    final uri = Uri.parse(ApiConfig.avatarUrl);

    Future<http.Response> sendMultipart(String token) async {
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: filename,
          ),
        );

      final streamedResponse = await _client
          .send(request)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds * 2));
      return http.Response.fromStream(streamedResponse);
    }

    try {
      var response = await sendMultipart(accessToken);

      if (response.statusCode == 401 &&
          tokenRefreshHandler != null &&
          !accessToken.startsWith('demo-')) {
        final newAccessToken = await tokenRefreshHandler!();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          response = await sendMultipart(newAccessToken);
        }
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
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
          statusCode: response.statusCode,
          message: decoded['message']?.toString() ?? 'Tải ảnh đại diện thành công',
          user: user,
        );
      } else {
        if (response.statusCode == 401) {
          sessionExpiredHandler?.call();
        }
        final msg = _extractErrorMessage(
          decoded,
          defaultMessage: 'Không thể tải lên ảnh đại diện',
        );
        return AuthResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error: msg,
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: _formatNetworkError(e),
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
        ? '${ApiConfig.baseUrl}/api/${ApiConfig.apiVersion}/users/$userId'
        : ApiConfig.userMeUrl;

    final uri = Uri.parse(endpoint);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

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
      var response = await _client
          .patch(uri, headers: headers, body: jsonEncode(bodyMap))
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 401 &&
          tokenRefreshHandler != null &&
          !accessToken.startsWith('demo-')) {
        final newAccessToken = await tokenRefreshHandler!();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $newAccessToken';
          response = await _client
              .patch(uri, headers: headers, body: jsonEncode(bodyMap))
              .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
        }
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : decoded;

        final userMap = data['user'] is Map<String, dynamic>
            ? data['user'] as Map<String, dynamic>
            : data;

        final user = AuthUser.fromJson(userMap);

        return AuthResult(
          isSuccess: true,
          statusCode: response.statusCode,
          message: 'Cập nhật hồ sơ thành công',
          user: user,
        );
      } else {
        if (response.statusCode == 401) {
          sessionExpiredHandler?.call();
        }
        final msg = _extractErrorMessage(
          decoded,
          defaultMessage: 'Cập nhật hồ sơ không thành công',
        );
        return AuthResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error: msg,
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: _formatNetworkError(e),
      );
    }
  }

  /// Get current user profile:
  /// 1. Calls `/api/v1/auth/me` to authenticate and get account info (id/sub, email, roles).
  /// 2. Calls `/api/v1/users/me` (or `/api/v1/users/{id}`) to fetch the full profile
  ///    (displayName, username, bio, gender, dateOfBirth, avatar, video/follower stats).
  /// 3. Returns the combined AuthUser.
  Future<AuthResult> getProfile(String accessToken, {String? userId}) async {
    final authUri = Uri.parse(ApiConfig.meUrl);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };

    try {
      final response = await _client
          .get(authUri, headers: headers)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : decoded;

        var authUser = data['user'] is Map<String, dynamic>
            ? AuthUser.fromJson(data['user'] as Map<String, dynamic>)
            : (data['email'] != null || data['sub'] != null || data['id'] != null
                ? AuthUser.fromJson(data)
                : null);

        // Fetch detailed profile via /api/v1/users/me
        try {
          final userDetailResult = await getMyUserProfile(accessToken);
          if (userDetailResult.isSuccess && userDetailResult.user != null) {
            final detailUser = userDetailResult.user!;
            authUser = (authUser ?? detailUser).copyWith(
              id: detailUser.id.isNotEmpty ? detailUser.id : authUser?.id,
              fullName: detailUser.fullName.isNotEmpty
                  ? detailUser.fullName
                  : authUser?.fullName,
              username: detailUser.username ?? authUser?.username,
              gender: detailUser.gender ?? authUser?.gender,
              dateOfBirth: detailUser.dateOfBirth ?? authUser?.dateOfBirth,
              bio: detailUser.bio ?? authUser?.bio,
              avatar: detailUser.avatar ?? authUser?.avatar,
              videoCount: detailUser.videoCount,
              followerCount: detailUser.followerCount,
              followingCount: detailUser.followingCount,
              likeCount: detailUser.likeCount,
            );
          } else if (userId != null &&
              userId.isNotEmpty &&
              !userId.startsWith('demo-')) {
            final detailResult = await getUserDetails(
              accessToken: accessToken,
              userId: userId,
            );
            if (detailResult.isSuccess && detailResult.user != null) {
              final detailUser = detailResult.user!;
              authUser = (authUser ?? detailUser).copyWith(
                fullName: detailUser.fullName.isNotEmpty
                    ? detailUser.fullName
                    : authUser?.fullName,
                username: detailUser.username ?? authUser?.username,
                gender: detailUser.gender ?? authUser?.gender,
                dateOfBirth: detailUser.dateOfBirth ?? authUser?.dateOfBirth,
                bio: detailUser.bio ?? authUser?.bio,
                avatar: detailUser.avatar ?? authUser?.avatar,
                videoCount: detailUser.videoCount,
                followerCount: detailUser.followerCount,
                followingCount: detailUser.followingCount,
                likeCount: detailUser.likeCount,
              );
            }
          }
        } catch (_) {}

        return AuthResult(
          isSuccess: true,
          statusCode: response.statusCode,
          user: authUser,
        );
      } else {
        final msg = _extractErrorMessage(
          decoded,
          defaultMessage: 'Không thể tải thông tin cá nhân',
        );
        return AuthResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error: msg,
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: _formatNetworkError(e),
      );
    }
  }

  /// Log out via `/api/v1/auth/logout`
  Future<bool> logout(String accessToken) async {
    final uri = Uri.parse(ApiConfig.logoutUrl);
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };

    try {
      final response = await _client
          .post(uri, headers: headers)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Refresh token via `/api/v1/auth/refresh`
  Future<AuthResult> refreshToken(String refreshToken) async {
    final uri = Uri.parse(ApiConfig.refreshUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-refresh-token': refreshToken,
    };

    final body = jsonEncode({'refreshToken': refreshToken});

    try {
      final response = await _client
          .post(uri, headers: headers, body: body)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : decoded;

        final tokens = data['tokens'] is Map<String, dynamic>
            ? AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>)
            : null;

        return AuthResult(
          isSuccess: true,
          statusCode: response.statusCode,
          tokens: tokens,
        );
      } else {
        final msg = _extractErrorMessage(
          decoded,
          defaultMessage: 'Phiên đăng nhập đã hết hạn',
        );
        return AuthResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error: msg,
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        statusCode: 0,
        error: _formatNetworkError(e),
      );
    }
  }

  String _extractErrorMessage(
    Map<String, dynamic> json, {
    bool isRegister = false,
    String? defaultMessage,
  }) {
    final message = json['message']?.toString() ?? '';
    final errorCode = json['errorCode']?.toString() ?? '';
    final error = json['error']?.toString() ?? '';
    final code = '$message $errorCode $error'.toUpperCase();

    // Check avatar and file upload error codes (UsersController_uploadMyAvatar)
    if (code.contains('FILE_REQUIRED')) {
      return 'Vui lòng chọn tệp hình ảnh để tải lên!';
    }
    if (code.contains('INVALID_FILE_TYPE')) {
      return 'Định dạng ảnh không hợp lệ!';
    }
    if (code.contains('FILE_TOO_LARGE') ||
        code.contains('PAYLOAD_TOO_LARGE') ||
        code.contains('LIMIT_FILE_SIZE')) {
      return 'Kích thước tệp ảnh quá lớn! Vui lòng chọn ảnh nhỏ hơn 5MB!';
    }

    // Check user profile errors
    if (code.contains('USER.USER_NOT_FOUND') ||
        (code.contains('USER_NOT_FOUND') && !code.contains('AUTH.'))) {
      return 'Không tìm thấy thông tin người dùng.';
    }
    if (code.contains('USERNAME_ALREADY_TAKEN')) {
      return 'Tên người dùng đã được sử dụng. Vui lòng chọn tên khác.';
    }
    if (code.contains('INVALID_USERNAME_FORMAT')) {
      return 'Tên người dùng không hợp lệ (từ 3-30 ký tự, chỉ gồm chữ cái, số và dấu gạch dưới).';
    }


    // Check specific auth and otp error codes
    if (code.contains('OTP_COOLDOWN_ACTIVE')) {
      return 'Vui lòng chờ ít phút trước khi yêu cầu mã OTP mới.';
    }
    if (code.contains('OTP_MAX_ATTEMPTS_EXCEEDED')) {
      return 'Bạn đã nhập sai mã OTP quá nhiều lần. Vui lòng gửi lại mã mới.';
    }
    if (code.contains('INVALID_OTP') || code.contains('OTP_INVALID')) {
      return 'Mã xác thực OTP không chính xác. Vui lòng kiểm tra lại.';
    }
    if (code.contains('OTP_EXPIRED') || code.contains('EXPIRED_OTP')) {
      return 'Mã OTP đã hết hạn. Vui lòng nhấn gửi lại mã mới.';
    }
    if (code.contains('EMAIL_ALREADY_EXISTS') ||
        (code.contains('USER_ALREADY_EXISTS') && isRegister)) {
      return 'Email này đã được đăng ký tài khoản trong hệ thống.';
    }
    if (code.contains('INVALID_EMAIL_FORMAT')) {
      return 'Định dạng email không hợp lệ.';
    }
    if (code.contains('INVALID_CREDENTIALS')) {
      return 'Email hoặc mật khẩu không chính xác.';
    }
    if (code.contains('AUTH.USER_NOT_FOUND')) {
      return 'Tài khoản không tồn tại trong hệ thống.';
    }
    if (code.contains('ACCOUNT_BLOCKED')) {
      return 'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ hỗ trợ.';
    }
    if (code.contains('ACCOUNT_INACTIVE')) {
      return 'Tài khoản chưa được kích hoạt.';
    }
    if (code.contains('ACCOUNT_LOCKED_TEMPORARILY')) {
      return 'Tài khoản tạm thời bị khóa do đăng nhập sai nhiều lần. Vui lòng thử lại sau.';
    }
    if (code.contains('INVALID_OLD_PASSWORD')) {
      return 'Mật khẩu hiện tại không chính xác.';
    }
    if (code.contains('PASSWORD_UNCHANGED')) {
      return 'Mật khẩu mới không được trùng với mật khẩu cũ.';
    }
    if (code.contains('VERIFICATION_TOKEN_INVALID')) {
      return 'Mã xác thực không hợp lệ hoặc đã được sử dụng.';
    }
    if (code.contains('VERIFICATION_TOKEN_EXPIRED')) {
      return 'Phiên xác thực đã hết hạn. Vui lòng thử lại từ đầu.';
    }
    if (code.contains('REFRESH_TOKEN') ||
        code.contains('TOKEN_REVOKED') ||
        code.contains('TOKEN_INVALID_OR_EXPIRED')) {
      return 'Phiên đăng nhập đã hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.';
    }
    if (code.contains('COMMON.UNAUTHORIZED')) {
      return 'Phiên đăng nhập đã hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.';
    }
    if (code.contains('COMMON.FORBIDDEN') ||
        code.contains('COMMON.NOT_OWNER_OR_ADMIN') ||
        code.contains('NOT_OWNER_OR_ADMIN')) {
      return 'Bạn không có quyền thực hiện thao tác này.';
    }
    if (code.contains('VALIDATION_FAILED')) {
      if (json['errors'] is List && (json['errors'] as List).isNotEmpty) {
        final firstError = (json['errors'] as List).first;
        if (firstError is Map<String, dynamic> && firstError['message'] != null) {
          final errorFieldMsg = firstError['message'].toString();
          if (!_isErrorCodeKey(errorFieldMsg)) {
            return errorFieldMsg;
          }
        }
      }
      return 'Thông tin không hợp lệ hoặc không đúng định dạng.';
    }
    if (code.contains('INVALID_REQUEST')) {
      return 'Yêu cầu không hợp lệ. Vui lòng thử lại.';
    }
    if (code.contains('INTERNAL_SERVER_ERROR')) {
      return isRegister
          ? 'Đăng ký thất bại. Email có thể đã tồn tại hoặc hệ thống đang bảo trì.'
          : 'Hệ thống đang bảo trì hoặc gặp sự cố. Vui lòng thử lại sau.';
    }

    // Return message or error if it is human-readable (not a raw API key)
    if (message.isNotEmpty && !_isErrorCodeKey(message)) {
      return message;
    }
    if (error.isNotEmpty && !_isErrorCodeKey(error)) {
      return error;
    }

    if (defaultMessage != null && defaultMessage.isNotEmpty) {
      return defaultMessage;
    }

    return isRegister
        ? 'Gửi yêu cầu thất bại. Vui lòng thử lại.'
        : 'Yêu cầu không thành công. Vui lòng thử lại sau.';
  }

  bool _isErrorCodeKey(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains(' ')) return false;
    return RegExp(r'^[A-Z0-9_]+(\.[A-Z0-9_]+)+$').hasMatch(trimmed) ||
        RegExp(r'^[A-Z0-9_]{3,}$').hasMatch(trimmed);
  }

  String _formatNetworkError(dynamic error) {
    final errStr = error.toString();
    if (errStr.contains('Connection refused') ||
        errStr.contains('SocketException') ||
        errStr.contains('Failed host lookup')) {
      return 'Không thể kết nối đến máy chủ (${ApiConfig.baseUrl}). Vui lòng kiểm tra kết nối mạng hoặc đảm bảo Server đang chạy.';
    }
    if (errStr.contains('TimeoutException')) {
      return 'Kết nối máy chủ bị quá thời gian (${ApiConfig.timeoutSeconds}s). Vui lòng thử lại.';
    }
    return 'Lỗi kết nối: $errStr';
  }
}
