import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'token_storage_service.dart';

/// Global singleton session and authentication state manager with secure persistence.
class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();

  AuthService._internal();

  TokenStorageService _storage = SecureTokenStorageService();
  ApiService _apiService = ApiService();

  AuthUser? _currentUser;
  AuthTokens? _tokens;
  bool _isInitialized = false;

  AuthUser? get currentUser => _currentUser;
  AuthTokens? get tokens => _tokens;
  bool get isLoggedIn => _currentUser != null && _tokens != null;
  bool get isInitialized => _isInitialized;

  /// Dependency injection for testing and customization
  void configure({TokenStorageService? storage, ApiService? apiService}) {
    if (storage != null) _storage = storage;
    if (apiService != null) _apiService = apiService;
  }

  /// Initialize session from secure storage (Android KeyStore / iOS Keychain)
  /// and automatically restore or refresh credentials with backend.
  Future<void> init() async {
    try {
      final cachedTokens = await _storage.getTokens();
      final cachedUser = await _storage.getUser();

      if (cachedTokens != null) {
        _tokens = cachedTokens;
        _currentUser = cachedUser;
        notifyListeners();

        // Restore & refresh profile in the background or during startup
        await restoreSession();
      }
    } catch (e) {
      debugPrint('AuthService init error: $e');
    } finally {
      _isInitialized = true;
    }
  }

  /// Restore user session: validates current access token with `/api/v1/auth/me`
  /// or refreshes tokens via `/api/v1/auth/refresh` if access token expired.
  Future<void> restoreSession() async {
    final currentTokens = _tokens;
    if (currentTokens == null) return;

    // Skip backend refresh if it's a demo session
    if (currentTokens.accessToken.startsWith('demo-')) {
      return;
    }

    try {
      // 1. Check if current access token is valid by requesting user profile
      final profileResult = await _apiService.getProfile(
        currentTokens.accessToken,
      );

      if (profileResult.isSuccess && profileResult.user != null) {
        _currentUser = profileResult.user;
        await _storage.saveUser(profileResult.user!);
        notifyListeners();
        return;
      }

      // 2. If access token is rejected (e.g. 401 Unauthorized), attempt refresh
      if (profileResult.statusCode == 401 || !profileResult.isSuccess) {
        // If it's a network offline error (status 0), retain cached session
        if (profileResult.statusCode == 0) {
          return;
        }

        final refreshResult = await _apiService.refreshToken(
          currentTokens.refreshToken,
        );

        if (refreshResult.isSuccess && refreshResult.tokens != null) {
          final newTokens = refreshResult.tokens!;
          _tokens = newTokens;
          await _storage.saveTokens(newTokens);

          // Fetch fresh user profile with new access token
          final newProfileResult = await _apiService.getProfile(
            newTokens.accessToken,
          );
          if (newProfileResult.isSuccess && newProfileResult.user != null) {
            _currentUser = newProfileResult.user;
            await _storage.saveUser(newProfileResult.user!);
          }
          notifyListeners();
        } else if (refreshResult.statusCode == 401 ||
            refreshResult.statusCode == 403) {
          // Both access and refresh token expired/invalid -> log out
          logout(callServer: false);
        }
      }
    } catch (e) {
      debugPrint('AuthService restoreSession error: $e');
    }
  }

  /// Update active session with authenticated user data & tokens
  void setSession({required AuthUser user, required AuthTokens tokens}) {
    _currentUser = user;
    _tokens = tokens;
    notifyListeners();

    // Persist to secure storage
    _storage.saveTokens(tokens);
    _storage.saveUser(user);
  }

  /// Demo chef user session with real data
  void setGuestDemo({
    String name = 'Chef Linh Đan',
    String email = 'linhdan@cookconnect.app',
  }) {
    final demoUser = AuthUser(
      id: 'demo-chef-01',
      email: email,
      fullName: name,
      username: 'linhdan_cook',
      gender: 'FEMALE',
      dateOfBirth: '1998-08-15',
      bio: 'Đam mê nấu ăn và làm bánh 🍰 | Chia sẻ công thức mỗi ngày 🍳',
      roles: ['USER'],
      status: 'ACTIVE',
      videoCount: 18,
      followerCount: 2450,
      followingCount: 182,
      likeCount: 15800,
    );
    final demoTokens = AuthTokens(
      accessToken: 'demo-access-token',
      refreshToken: 'demo-refresh-token',
    );

    _currentUser = demoUser;
    _tokens = demoTokens;
    notifyListeners();

    // Persist demo credentials so demo session survives app restart
    _storage.saveTokens(demoTokens);
    _storage.saveUser(demoUser);
  }

  /// Logout and clear user credentials from memory and secure storage
  void logout({bool callServer = true}) {
    final currentToken = _tokens?.accessToken;
    _currentUser = null;
    _tokens = null;
    notifyListeners();

    _storage.clearAuth();

    if (callServer &&
        currentToken != null &&
        !currentToken.startsWith('demo-')) {
      _apiService.logout(currentToken).catchError((_) => false);
    }
  }

  /// Update local user fields (e.g. after profile edit)
  void updateUser({
    String? fullName,
    String? username,
    String? gender,
    String? dateOfBirth,
    String? bio,
    String? avatar,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      fullName: fullName,
      username: username,
      gender: gender,
      dateOfBirth: dateOfBirth,
      bio: bio,
      avatar: avatar,
    );
    notifyListeners();

    _storage.saveUser(_currentUser!);
  }
}
