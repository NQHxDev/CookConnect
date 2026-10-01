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
    final rawName = json['fullName'] ?? json['displayName'] ?? json['name'];
    final name =
        rawName?.toString() ??
        (json['email'] != null
            ? json['email'].toString().split('@').first
            : '');

    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: name,
      username: json['username']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      bio: json['bio']?.toString(),
      avatar: json['avatar']?.toString(),
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['USER'],
      status: json['status']?.toString(),
      isEmailVerified: json['isEmailVerified'] == true,
      videoCount: (json['videoCount'] as num?)?.toInt() ?? 0,
      followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
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

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 900,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 900,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'expiresIn': expiresIn,
  };
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

  /// Request OTP for registration via `/api/v1/auth/send-otp`
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

  /// Verify OTP code via `/api/v1/auth/verify-otp`
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
            data['token']?.toString();

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

        final user = data['user'] is Map<String, dynamic>
            ? AuthUser.fromJson(data['user'] as Map<String, dynamic>)
            : null;

        final tokens = data['tokens'] is Map<String, dynamic>
            ? AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>)
            : null;

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

  /// Update user profile via `/api/v1/users/{id}` or `/api/v1/users/me`
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
        : '${ApiConfig.baseUrl}/api/${ApiConfig.apiVersion}/users/me';

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
      final response = await _client
          .patch(uri, headers: headers, body: jsonEncode(bodyMap))
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : decoded;

        final userMap = data['user'] is Map<String, dynamic>
            ? data['user'] as Map<String, dynamic>
            : (data['email'] != null ? data : null);

        final user = userMap != null ? AuthUser.fromJson(userMap) : null;

        return AuthResult(
          isSuccess: true,
          statusCode: response.statusCode,
          message: 'Cập nhật hồ sơ thành công',
          user: user,
        );
      } else {
        return AuthResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error:
              decoded['message']?.toString() ??
              'Cập nhật hồ sơ không thành công',
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

  /// Get current user profile via `/api/v1/auth/me`
  Future<AuthResult> getProfile(String accessToken) async {
    final uri = Uri.parse(ApiConfig.meUrl);
    final headers = {
      'Authorization': 'Bearer $accessToken',
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

        final userMap = data['user'] is Map<String, dynamic>
            ? data['user'] as Map<String, dynamic>
            : (data['email'] != null ? data : null);

        final user = userMap != null ? AuthUser.fromJson(userMap) : null;

        return AuthResult(
          isSuccess: true,
          statusCode: response.statusCode,
          user: user,
        );
      } else {
        return AuthResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error:
              decoded['message']?.toString() ??
              'Không thể tải thông tin cá nhân',
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
        return AuthResult(
          isSuccess: false,
          statusCode: response.statusCode,
          error: decoded['message']?.toString() ?? 'Phiên đăng nhập đã hết hạn',
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
    required bool isRegister,
  }) {
    final message = json['message']?.toString() ?? '';
    final errorCode = json['errorCode']?.toString() ?? '';
    final error = json['error']?.toString() ?? '';

    // Check specific auth and otp error codes
    if (message.contains('OTP_COOLDOWN_ACTIVE') ||
        errorCode.contains('OTP_COOLDOWN_ACTIVE')) {
      return 'Vui lòng chờ ít phút trước khi yêu cầu mã OTP mới.';
    }
    if (message.contains('OTP_MAX_ATTEMPTS_EXCEEDED') ||
        errorCode.contains('OTP_MAX_ATTEMPTS_EXCEEDED')) {
      return 'Bạn đã nhập sai mã OTP quá nhiều lần. Vui lòng gửi lại mã mới.';
    }
    if (message.contains('INVALID_OTP') ||
        errorCode.contains('INVALID_OTP') ||
        message.contains('OTP_INVALID')) {
      return 'Mã xác thực OTP không chính xác. Vui lòng kiểm tra lại.';
    }
    if (message.contains('OTP_EXPIRED') ||
        errorCode.contains('OTP_EXPIRED') ||
        message.contains('EXPIRED_OTP')) {
      return 'Mã OTP đã hết hạn. Vui lòng nhấn gửi lại mã mới.';
    }
    if (message.contains('USER_ALREADY_EXISTS') ||
        errorCode.contains('USER_ALREADY_EXISTS') ||
        message.contains('EMAIL_ALREADY_EXISTS')) {
      return 'Email này đã được đăng ký tài khoản trong hệ thống.';
    }
    if (message.contains('INVALID_EMAIL_FORMAT') ||
        errorCode.contains('INVALID_EMAIL_FORMAT')) {
      return 'Định dạng email không hợp lệ.';
    }
    if (message.contains('VALIDATION_FAILED') ||
        errorCode.contains('VALIDATION_FAILED')) {
      return 'Thông tin không hợp lệ hoặc không đúng định dạng.';
    }
    if (message.contains('INVALID_CREDENTIALS') ||
        errorCode.contains('INVALID_CREDENTIALS')) {
      return 'Email hoặc mật khẩu không chính xác.';
    }
    if (message.contains('INTERNAL_SERVER_ERROR') ||
        errorCode.contains('INTERNAL_SERVER_ERROR')) {
      return isRegister
          ? 'Đăng ký thất bại. Email có thể đã tồn tại hoặc hệ thống đang bảo trì.'
          : 'Đăng nhập không thành công. Vui lòng kiểm tra lại thông tin đăng nhập.';
    }

    if (message.isNotEmpty && !message.contains('COMMON.')) {
      return message;
    }
    if (error.isNotEmpty && !error.contains('COMMON.')) {
      return error;
    }

    return isRegister
        ? 'Gửi yêu cầu thất bại. Vui lòng thử lại.'
        : 'Đăng nhập thất bại. Vui lòng thử lại.';
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
