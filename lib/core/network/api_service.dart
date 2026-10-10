import 'package:http/http.dart' as http;
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/features/auth/data/models/auth_result.dart';
import 'package:cookconnect/features/auth/data/models/otp_result.dart';
import 'package:cookconnect/features/auth/data/services/auth_api_service.dart';
import 'package:cookconnect/features/profile/data/services/user_api_service.dart';

// Export all models and services for clean centralized access
export 'package:cookconnect/core/network/api_client.dart';
export 'package:cookconnect/core/network/api_exception.dart';
export 'package:cookconnect/features/auth/data/models/auth_result.dart';
export 'package:cookconnect/features/auth/data/models/auth_tokens.dart';
export 'package:cookconnect/features/auth/data/models/auth_user.dart';
export 'package:cookconnect/features/auth/data/models/otp_result.dart';
export 'package:cookconnect/features/auth/data/services/auth_api_service.dart';
export 'package:cookconnect/features/profile/data/services/user_api_service.dart';

/// Facade ApiService preserving backward compatibility and coordinating AuthApiService + UserApiService
class ApiService {
  /// Global default client override
  static http.Client? get defaultClient => ApiClient.defaultClient;
  static set defaultClient(http.Client? client) => ApiClient.defaultClient = client;

  /// Global handlers for token refresh and session expiration
  static Future<String?> Function()? get tokenRefreshHandler => ApiClient.tokenRefreshHandler;
  static set tokenRefreshHandler(Future<String?> Function()? handler) =>
      ApiClient.tokenRefreshHandler = handler;

  static void Function()? get sessionExpiredHandler => ApiClient.sessionExpiredHandler;
  static set sessionExpiredHandler(void Function()? handler) =>
      ApiClient.sessionExpiredHandler = handler;

  final ApiClient _client;
  final AuthApiService _authService;
  final UserApiService _userService;

  ApiService({http.Client? client, ApiClient? apiClient})
      : _client = apiClient ?? ApiClient(client: client),
        _authService = AuthApiService(apiClient: apiClient ?? ApiClient(client: client)),
        _userService = UserApiService(apiClient: apiClient ?? ApiClient(client: client));

  ApiClient get apiClient => _client;
  AuthApiService get auth => _authService;
  UserApiService get user => _userService;

  // Forwarding methods to AuthApiService & UserApiService
  Future<HealthCheckResult> checkHealth() => _userService.checkHealth();
  Future<bool> checkUsername(String username) => _userService.checkUsername(username);
  Future<OtpResult> sendOtp({
    required String email,
    String clientType = 'mobile',
    String appVersion = '1.0.0',
  }) =>
      _authService.sendOtp(
        email: email,
        clientType: clientType,
        appVersion: appVersion,
      );

  Future<OtpResult> verifyOtp({
    required String email,
    required String otp,
    String clientType = 'mobile',
    String appVersion = '1.0.0',
  }) =>
      _authService.verifyOtp(
        email: email,
        otp: otp,
        clientType: clientType,
        appVersion: appVersion,
      );

  Future<AuthResult> register({
    required String email,
    required String password,
    String? fullName,
    String? confirmPassword,
    String? verificationToken,
    String? deviceId,
    String clientType = 'mobile',
    String appVersion = '1.0.0',
  }) =>
      _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        confirmPassword: confirmPassword,
        verificationToken: verificationToken,
        deviceId: deviceId,
        clientType: clientType,
        appVersion: appVersion,
      );

  Future<AuthResult> login({
    required String email,
    required String password,
    String? deviceId,
    String clientType = 'mobile',
    String appVersion = '1.0.0',
  }) =>
      _authService.login(
        email: email,
        password: password,
        deviceId: deviceId,
        clientType: clientType,
        appVersion: appVersion,
      );

  Future<AuthResult> getMyUserProfile(String accessToken) =>
      _userService.getMyUserProfile(accessToken);

  Future<AuthResult> getUserDetails({
    required String accessToken,
    required String userId,
  }) =>
      _userService.getUserDetails(accessToken: accessToken, userId: userId);

  Future<AuthResult> uploadAvatar({
    required String accessToken,
    required List<int> fileBytes,
    required String filename,
    String? mimeType,
  }) =>
      _userService.uploadAvatar(
        accessToken: accessToken,
        fileBytes: fileBytes,
        filename: filename,
        mimeType: mimeType,
      );

  Future<AuthResult> updateUserProfile({
    required String accessToken,
    String? userId,
    String? displayName,
    String? username,
    String? gender,
    String? dateOfBirth,
    String? bio,
    String? avatar,
  }) =>
      _userService.updateUserProfile(
        accessToken: accessToken,
        userId: userId,
        displayName: displayName,
        username: username,
        gender: gender,
        dateOfBirth: dateOfBirth,
        bio: bio,
        avatar: avatar,
      );

  Future<AuthResult> getProfile(String accessToken, {String? userId}) =>
      _userService.getProfile(accessToken, userId: userId);

  Future<bool> logout(String accessToken) => _authService.logout(accessToken);

  Future<AuthResult> refreshToken(String refreshToken) =>
      _authService.refreshToken(refreshToken);
}
