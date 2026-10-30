import 'package:cookconnect/features/recipe/data/models/post_item.dart';
import 'package:cookconnect/features/recipe/data/models/create_post_dto.dart';
import 'package:cookconnect/features/recipe/data/services/post_api_service.dart';

export 'package:cookconnect/features/recipe/data/models/post_item.dart';
export 'package:cookconnect/features/recipe/data/models/create_post_dto.dart';
export 'package:cookconnect/features/recipe/data/models/multipart_upload_models.dart';
export 'package:cookconnect/features/recipe/data/services/post_api_service.dart';
export 'package:cookconnect/features/recipe/data/services/feed_cache_service.dart';
import 'package:http/http.dart' as http;
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/features/auth/data/models/auth_result.dart';
import 'package:cookconnect/features/auth/data/models/otp_result.dart';
import 'package:cookconnect/features/auth/data/services/auth_api_service.dart';
import 'package:cookconnect/features/profile/data/services/user_api_service.dart';
import 'package:cookconnect/features/recipe/data/models/video_watch_event.dart';
import 'package:cookconnect/features/recipe/data/services/video_analytics_service.dart';

// Export all models and services for clean centralized access
export 'package:cookconnect/core/network/api_client.dart';
export 'package:cookconnect/core/network/api_exception.dart';
export 'package:cookconnect/features/auth/data/models/auth_result.dart';
export 'package:cookconnect/features/auth/data/models/auth_tokens.dart';
export 'package:cookconnect/features/auth/data/models/auth_user.dart';
export 'package:cookconnect/features/auth/data/models/otp_result.dart';
export 'package:cookconnect/features/auth/data/services/auth_api_service.dart';
export 'package:cookconnect/features/profile/data/services/user_api_service.dart';
export 'package:cookconnect/features/recipe/data/models/video_watch_event.dart';
export 'package:cookconnect/features/recipe/data/services/video_analytics_service.dart';
export 'package:cookconnect/features/recipe/data/services/video_watch_tracker.dart';
export 'package:cookconnect/features/recipe/data/services/author_profile_service.dart';

/// Facade ApiService preserving backward compatibility and coordinating AuthApiService + UserApiService
class ApiService {
  static final ApiService instance = ApiService();
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
  final PostApiService _postService;
  final VideoAnalyticsService _videoAnalyticsService;

  ApiService({http.Client? client, ApiClient? apiClient})
      : _client = apiClient ?? ApiClient(client: client),
        _authService = AuthApiService(apiClient: apiClient ?? ApiClient(client: client)),
        _userService = UserApiService(apiClient: apiClient ?? ApiClient(client: client)),
        _postService = PostApiService(apiClient: apiClient ?? ApiClient(client: client)),
        _videoAnalyticsService = VideoAnalyticsService(client: apiClient ?? ApiClient(client: client));

  ApiClient get apiClient => _client;
  AuthApiService get auth => _authService;
  UserApiService get user => _userService;
  PostApiService get post => _postService;
  VideoAnalyticsService get videoAnalytics => _videoAnalyticsService;

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

  /// 1. Cập nhật ngày sinh và giới tính
  Future<AuthResult> updatePersonalInfo({
    required String accessToken,
    String? dateOfBirth,
    String? gender,
  }) =>
      _userService.updatePersonalInfo(
        accessToken: accessToken,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

  /// 2. Cập nhật tên hiển thị
  Future<AuthResult> updateDisplayName({
    required String accessToken,
    required String displayName,
  }) =>
      _userService.updateDisplayName(
        accessToken: accessToken,
        displayName: displayName,
      );

  /// 3. Cập nhật tiểu sử
  Future<AuthResult> updateBio({
    required String accessToken,
    required String bio,
  }) =>
      _userService.updateBio(
        accessToken: accessToken,
        bio: bio,
      );

  /// 4. Cập nhật vị trí
  Future<AuthResult> updateLocation({
    required String accessToken,
    required String location,
  }) =>
      _userService.updateLocation(
        accessToken: accessToken,
        location: location,
      );

  /// Cập nhật địa chỉ cư trú
  Future<AuthResult> updateAddress({
    required String accessToken,
    required String address,
  }) =>
      _userService.updateAddress(
        accessToken: accessToken,
        address: address,
      );

  /// 5. Cập nhật website
  Future<AuthResult> updateWebsite({
    required String accessToken,
    required String website,
  }) =>
      _userService.updateWebsite(
        accessToken: accessToken,
        website: website,
      );

  /// 6. Cập nhật ảnh bìa
  Future<AuthResult> updateCoverImage({
    required String accessToken,
    required String coverImage,
  }) =>
      _userService.updateCoverImage(
        accessToken: accessToken,
        coverImage: coverImage,
      );

  /// 8. Đổi Username (Handle)
  Future<AuthResult> updateUsername({
    required String accessToken,
    required String username,
  }) =>
      _userService.updateUsername(
        accessToken: accessToken,
        username: username,
      );

  /// Tạo hồ sơ ban đầu
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
  }) =>
      _userService.createUserProfile(
        accessToken: accessToken,
        displayName: displayName,
        username: username,
        gender: gender,
        dateOfBirth: dateOfBirth,
        bio: bio,
        avatar: avatar,
        coverImage: coverImage,
        website: website,
        location: location,
        address: address,
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
    String? location,
    String? address,
    String? website,
    String? coverImage,
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
        location: location,
        address: address,
        website: website,
        coverImage: coverImage,
      );

  Future<AuthResult> getProfile(String accessToken, {String? userId}) =>
      _userService.getProfile(accessToken, userId: userId);

  Future<bool> logout(String accessToken) => _authService.logout(accessToken);

  Future<AuthResult> refreshToken(String refreshToken) =>
      _authService.refreshToken(refreshToken);

  void recordVideoWatch(VideoWatchEvent event) =>
      _videoAnalyticsService.recordWatchEvent(event);

  Future<PostItem> createPost({
    required CreatePostDto dto,
    String? token,
  }) =>
      _postService.createPost(dto: dto, token: token);
}
