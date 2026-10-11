import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/core/storage/token_storage_service.dart';

/// Global singleton session and authentication state manager with secure persistence.
class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();

  /// Global keys for navigation and user notifications upon session expiry
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  AuthService._internal() {
    _setupApiServiceHandlers();
  }

  TokenStorageService _storage = SecureTokenStorageService();
  ApiService _apiService = ApiService();

  AuthUser? _currentUser;
  AuthTokens? _tokens;
  bool _isInitialized = false;
  Completer<String?>? _refreshCompleter;

  AuthUser? get currentUser => _currentUser;
  AuthTokens? get tokens => _tokens;
  bool get isLoggedIn => _currentUser != null && _tokens != null;
  bool get isInitialized => _isInitialized;

  void _setupApiServiceHandlers() {
    ApiService.tokenRefreshHandler = () => refreshAccessToken();
    ApiService.sessionExpiredHandler = () => handleSessionExpired();
  }

  /// Dependency injection for testing and customization
  void configure({TokenStorageService? storage, ApiService? apiService}) {
    if (storage != null) _storage = storage;
    if (apiService != null) {
      _apiService = apiService;
    }
    _setupApiServiceHandlers();
  }

  /// Initialize session from secure storage (Android KeyStore / iOS Keychain)
  /// and automatically restore or refresh credentials with backend.
  Future<void> init() async {
    try {
      final cachedTokens = await _storage.getTokens();
      final cachedUser = await _storage.getUser();

      if (cachedTokens != null) {
        // If both access and refresh tokens have expired, kick out immediately
        if (cachedTokens.isAccessTokenExpired() &&
            cachedTokens.isRefreshTokenExpired()) {
          await _storage.clearAuth();
          _tokens = null;
          _currentUser = null;
          notifyListeners();
          return;
        }

        _tokens = cachedTokens;
        _currentUser = cachedUser;
        notifyListeners();

        // Restore & refresh profile in the background or during startup
        await restoreSession();
      }
    } catch (e) {
      debugPrint('AuthService init error: $e');
      await _storage.clearAuth();
      _tokens = null;
      _currentUser = null;
      notifyListeners();
    } finally {
      _isInitialized = true;
    }
  }

  /// Explicitly fetch/sync fresh user profile from the server
  Future<void> fetchUserProfile() async {
    await restoreSession();
  }

  /// Restore user session: validates current access token with `/api/v1/auth/me`
  /// and queries `/api/v1/users/{id}` to fetch fresh displayName, username, bio, stats, etc.
  /// or refreshes tokens via `/api/v1/auth/refresh` if access token expired.
  Future<void> restoreSession() async {
    final currentTokens = _tokens;
    if (currentTokens == null) return;

    // Skip backend refresh if it's a demo session
    if (currentTokens.accessToken.startsWith('demo-')) {
      return;
    }

    // If access token is already known to be expired, refresh it proactively
    if (currentTokens.isAccessTokenExpired()) {
      final newToken = await refreshAccessToken();
      if (newToken == null) {
        // Refresh token also failed or expired -> user was logged out
        return;
      }
    }

    try {
      final activeTokens = _tokens;
      if (activeTokens == null) return;

      // 1. Check if current access token is valid and retrieve user profile
      final profileResult = await _apiService.getProfile(
        activeTokens.accessToken,
        userId: _currentUser?.userId ?? _currentUser?.id,
      );

      if (profileResult.isSuccess && profileResult.user != null) {
        var user = profileResult.user!;
        if ((user.accountId == null || user.accountId!.isEmpty) &&
            activeTokens.sub != null) {
          user = user.copyWith(accountId: activeTokens.sub);
        }
        _currentUser = _mergeUser(_currentUser, user);
        await _storage.saveUser(_currentUser!);
        notifyListeners();
        return;
      }

      // 2. If access token is rejected (e.g. 401 Unauthorized or failed), attempt refresh
      if (profileResult.statusCode == 401 ||
          profileResult.statusCode == 403 ||
          !profileResult.isSuccess) {
        // If it's a network offline error (status 0), retain cached session
        if (profileResult.statusCode == 0) {
          return;
        }

        final refreshResult = await _apiService.refreshToken(
          activeTokens.refreshToken,
        );

        if (refreshResult.isSuccess && refreshResult.tokens != null) {
          final newTokens = refreshResult.tokens!;
          _tokens = newTokens;
          await _storage.saveTokens(newTokens);

          // Fetch fresh user profile with new access token
          final newProfileResult = await _apiService.getProfile(
            newTokens.accessToken,
            userId: _currentUser?.userId ?? _currentUser?.id,
          );
          if (newProfileResult.isSuccess && newProfileResult.user != null) {
            var user = newProfileResult.user!;
            if ((user.accountId == null || user.accountId!.isEmpty) &&
                newTokens.sub != null) {
              user = user.copyWith(accountId: newTokens.sub);
            }
            _currentUser = _mergeUser(_currentUser, user);
            await _storage.saveUser(_currentUser!);
          }
          notifyListeners();
        } else {
          // Both access and refresh token expired/invalid/rejected -> kick user out
          logout(callServer: false, sessionExpired: true);
        }
      }
    } catch (e) {
      debugPrint('AuthService restoreSession error: $e');
    }
  }

  /// Proactively or reactively refresh the access token using the stored refresh token.
  /// Prevents multiple concurrent refresh calls using a Completer lock.
  Future<String?> refreshAccessToken() async {
    final currentTokens = _tokens;
    if (currentTokens == null || currentTokens.refreshToken.isEmpty) {
      logout(callServer: false, sessionExpired: true);
      return null;
    }

    if (currentTokens.accessToken.startsWith('demo-')) {
      return currentTokens.accessToken;
    }

    // If a refresh is already in flight, wait for its result
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final result = await _apiService.refreshToken(currentTokens.refreshToken);

      if (result.isSuccess && result.tokens != null) {
        final newTokens = result.tokens!;
        _tokens = newTokens;
        await _storage.saveTokens(newTokens);
        notifyListeners();
        completer.complete(newTokens.accessToken);
        return newTokens.accessToken;
      } else {
        // Refresh token failed (expired, invalid, revoked, or server error)
        if (result.statusCode != 0) {
          logout(callServer: false, sessionExpired: true);
        }
        completer.complete(null);
        return null;
      }
    } catch (e) {
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Handle expired session callback from ApiService
  void handleSessionExpired() {
    if (isLoggedIn) {
      logout(callServer: false, sessionExpired: true);
    }
  }

  /// Merge existing user with updated server user, preserving any non-null existing data
  AuthUser _mergeUser(AuthUser? current, AuthUser updated) {
    if (current == null) return updated;

    final mergedAccountId = (updated.accountId != null && updated.accountId!.isNotEmpty)
        ? updated.accountId
        : current.accountId;

    final mergedUserId = (updated.userId != null && updated.userId!.isNotEmpty)
        ? updated.userId
        : current.userId;

    final mergedUserProfileId = (updated.userProfileId != null && updated.userProfileId!.isNotEmpty)
        ? updated.userProfileId
        : current.userProfileId;

    final mergedId = (updated.id.isNotEmpty && !updated.id.startsWith('demo-'))
        ? updated.id
        : (mergedUserId?.isNotEmpty == true
            ? mergedUserId!
            : (mergedAccountId?.isNotEmpty == true ? mergedAccountId! : current.id));

    final mergedName = updated.fullName.isNotEmpty &&
            updated.fullName != updated.email &&
            updated.fullName != updated.email.split('@').first
        ? updated.fullName
        : (current.fullName.isNotEmpty ? current.fullName : updated.fullName);

    final mergedUsername =
        (updated.username != null && updated.username!.isNotEmpty)
            ? updated.username
            : current.username;

    final mergedGender = (updated.gender != null && updated.gender!.isNotEmpty)
        ? updated.gender
        : current.gender;

    final mergedDob =
        (updated.dateOfBirth != null && updated.dateOfBirth!.isNotEmpty)
            ? updated.dateOfBirth
            : current.dateOfBirth;

    final mergedBio = (updated.bio != null && updated.bio!.isNotEmpty)
        ? updated.bio
        : current.bio;

    final mergedAvatar =
        (updated.avatar != null && updated.avatar!.isNotEmpty)
            ? updated.avatar
            : current.avatar;

    return current.copyWith(
      id: mergedId,
      accountId: mergedAccountId,
      userId: mergedUserId,
      userProfileId: mergedUserProfileId,
      email: updated.email.isNotEmpty ? updated.email : current.email,
      fullName: mergedName,
      username: mergedUsername,
      gender: mergedGender,
      dateOfBirth: mergedDob,
      bio: mergedBio,
      avatar: mergedAvatar,
      roles: updated.roles.isNotEmpty ? updated.roles : current.roles,
      status: updated.status ?? current.status,
      isEmailVerified: updated.isEmailVerified || current.isEmailVerified,
      videoCount:
          updated.videoCount != 0 ? updated.videoCount : current.videoCount,
      followerCount: updated.followerCount != 0
          ? updated.followerCount
          : current.followerCount,
      followingCount: updated.followingCount != 0
          ? updated.followingCount
          : current.followingCount,
      likeCount: updated.likeCount != 0 ? updated.likeCount : current.likeCount,
    );
  }

  /// Update active session with authenticated user data & tokens
  void setSession({required AuthUser user, required AuthTokens tokens}) {
    var sessionUser = user;
    if ((sessionUser.accountId == null || sessionUser.accountId!.isEmpty) &&
        tokens.sub != null) {
      sessionUser = sessionUser.copyWith(accountId: tokens.sub);
    }
    _currentUser = sessionUser;
    _tokens = tokens;
    notifyListeners();

    // Persist to secure storage
    _storage.saveTokens(tokens);
    _storage.saveUser(sessionUser);
  }

  /// Demo chef user session with real data
  void setGuestDemo({
    String name = 'Chef Linh Đan',
    String email = 'linhdan@cookconnect.app',
  }) {
    final demoUser = AuthUser(
      id: 'demo-chef-01',
      accountId: 'demo-acc-01',
      userId: 'demo-user-01',
      userProfileId: 'demo-profile-01',
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
  void logout({bool callServer = true, bool sessionExpired = false}) {
    final currentToken = _tokens?.accessToken;
    final wasLoggedIn = isLoggedIn;

    _currentUser = null;
    _tokens = null;
    notifyListeners();

    _storage.clearAuth();

    if (callServer &&
        currentToken != null &&
        !currentToken.startsWith('demo-')) {
      _apiService.logout(currentToken).catchError((_) => false);
    }

    if (sessionExpired && wasLoggedIn) {
      _onSessionExpired();
    }
  }

  /// Notify the UI and pop back to root when session expires
  void _onSessionExpired() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.popUntil((route) => route.isFirst);
        }
        if (scaffoldMessengerKey.currentState != null) {
          scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
          scaffoldMessengerKey.currentState!.showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Iconsax.lock, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFD32F2F),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (_) {}
    });
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
