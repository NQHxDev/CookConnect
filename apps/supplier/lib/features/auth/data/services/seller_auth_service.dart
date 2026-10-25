import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/core/network/api_exception.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/auth/data/models/otp_result.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';
import 'package:cook_connect_seller/features/auth/data/services/auth_api_service.dart';

/// Global singleton session and authentication state manager for CookConnect Supplier.
class SellerAuthService extends ChangeNotifier {
  static final SellerAuthService instance = SellerAuthService._internal();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  SellerAuthService._internal() {
    _setupApiClientHandlers();
  }

  TokenStorageService _storage = SecureTokenStorageService();
  AuthApiService _apiService = AuthApiService();

  SellerUser? _currentUser;
  AuthTokens? _tokens;
  bool _hasSupplier = false;
  SupplierProfile? _supplierProfile;
  bool _isInitialized = false;
  Completer<String?>? _refreshCompleter;

  SellerUser? get currentUser => _currentUser;
  AuthTokens? get tokens => _tokens;
  bool get hasSupplier => _hasSupplier;
  SupplierProfile? get supplierProfile => _supplierProfile;
  bool get isLoggedIn => _currentUser != null && _tokens != null && !_tokens!.isExpired;
  bool get isInitialized => _isInitialized;

  void _setupApiClientHandlers() {
    ApiClient.tokenRefreshHandler = () => refreshAccessToken();
    ApiClient.sessionExpiredHandler = () => handleSessionExpired();
  }

  /// Dependency injection for testing and customization
  void configure({TokenStorageService? storage, AuthApiService? apiService}) {
    if (storage != null) _storage = storage;
    if (apiService != null) _apiService = apiService;
    _setupApiClientHandlers();
  }

  /// Initialize session from secure storage (KeyStore / Keychain)
  Future<void> init() async {
    try {
      final cachedTokens = await _storage.getTokens();
      final cachedProfile = await _storage.getSellerProfile();

      if (cachedTokens != null) {
        if (cachedTokens.isExpired) {
          if (cachedTokens.refreshToken.isNotEmpty &&
              !cachedTokens.accessToken.startsWith('demo-')) {
            final refreshResult = await _apiService.refreshToken(cachedTokens.refreshToken);
            if (refreshResult.success && refreshResult.tokens != null) {
              _tokens = refreshResult.tokens;
              _currentUser = refreshResult.user ??
                  (cachedProfile != null ? SellerUser.fromJson(cachedProfile) : null);
              await _storage.saveTokens(_tokens!);
              if (_currentUser != null) {
                await _storage.saveSellerProfile(_currentUser!.toJson());
              }
              await checkSupplierStatus();
              notifyListeners();
              return;
            }
          }
          await _storage.clearAuth();
          _tokens = null;
          _currentUser = null;
          _hasSupplier = false;
          _supplierProfile = null;
          notifyListeners();
          return;
        }

        _tokens = cachedTokens;
        if (cachedProfile != null) {
          _currentUser = SellerUser.fromJson(cachedProfile);
          if (_currentUser?.storeId != null && _currentUser!.storeId!.isNotEmpty) {
            _hasSupplier = true;
          }
        }

        // Check live supplier onboarding status if valid access token
        if (_tokens != null &&
            !_tokens!.accessToken.startsWith('demo-') &&
            !_tokens!.accessToken.startsWith('social-')) {
          await checkSupplierStatus();
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('SellerAuthService init error: $e');
      await _storage.clearAuth();
      _tokens = null;
      _currentUser = null;
      _hasSupplier = false;
      _supplierProfile = null;
      notifyListeners();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Check onboarding state and store profile with GET /api/v1/suppliers/me
  Future<MySupplierResult?> checkSupplierStatus() async {
    final token = _tokens?.accessToken;
    if (token == null || token.isEmpty || token.startsWith('demo-') || token.startsWith('social-')) {
      return null;
    }

    try {
      final result = await _apiService.getMySupplier(token: token);
      _hasSupplier = result.hasSupplier;
      _supplierProfile = result.supplier;

      if (_supplierProfile != null && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          storeName: _supplierProfile!.supplierName,
          storeId: _supplierProfile!.supplierId,
          address: _supplierProfile!.address ?? _currentUser!.address,
          phone: _supplierProfile!.contactPhone ?? _currentUser!.phone,
          supplierProfile: _supplierProfile,
        );
        await _storage.saveSellerProfile(_currentUser!.toJson());
      }
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('checkSupplierStatus failed: $e');
      if (e is ApiException && (e.statusCode == 401 || e.statusCode == 403)) {
        await logout(callServer: false, sessionExpired: true);
      }
      return null;
    }
  }

  /// Send OTP for registration to email
  Future<OtpResult> sendOtp({required String contact}) async {
    return _apiService.sendOtp(contact: contact);
  }

  /// Verify OTP code to obtain verificationToken
  Future<OtpResult> verifyOtp({
    required String contact,
    required String otp,
  }) async {
    return _apiService.verifyOtp(contact: contact, otp: otp);
  }

  /// Login with email and password
  Future<SellerAuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _apiService.login(email: email, password: password);
    if (result.success && result.tokens != null) {
      final user = result.user ??
          SellerUser(
            id: 'supplier_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            storeName: 'Gian hàng $email',
            fullName: email.split('@').first,
          );
      setSession(user: user, tokens: result.tokens!);
      await checkSupplierStatus();
    }
    return result;
  }

  /// Login with phone number and password
  Future<SellerAuthResult> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    final result = await _apiService.loginWithPhone(phone: phone, password: password);
    if (result.success && result.tokens != null) {
      final user = result.user ??
          SellerUser(
            id: 'supplier_${DateTime.now().millisecondsSinceEpoch}',
            email: '$phone@supplier.cookconnect.app',
            phone: phone,
            storeName: 'Gian hàng $phone',
            fullName: 'Chủ quán $phone',
          );
      setSession(user: user, tokens: result.tokens!);
      await checkSupplierStatus();
    }
    return result;
  }

  /// Register a new supplier admin account (Step 3: Password creation)
  Future<SellerAuthResult> register({
    required String email,
    required String password,
    String? confirmPassword,
    String? storeName,
    String? fullName,
    String? phone,
    String? verificationToken,
  }) async {
    final result = await _apiService.register(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      verificationToken: verificationToken,
      storeName: storeName,
      fullName: fullName,
      phone: phone,
    );
    if (result.success && result.tokens != null) {
      final defaultName = fullName ?? (email.contains('@') ? email.split('@').first : email);
      final defaultStore = storeName ?? 'Gian hàng $defaultName';
      final user = result.user ??
          SellerUser(
            id: 'supplier_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            storeName: defaultStore,
            fullName: defaultName,
            phone: phone,
          );
      _hasSupplier = false;
      _supplierProfile = null;
      setSession(user: user, tokens: result.tokens!);
    }
    return result;
  }

  /// Register supplier store details (Step 4: Store Onboarding)
  Future<SupplierProfile> createSupplierStore({
    required String supplierName,
    String? supplierCode,
    String? contactEmail,
    String? contactPhone,
    String? address,
    String? city,
    String? supplierLogoUrl,
  }) async {
    final token = _tokens?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Chưa đăng nhập tài khoản');
    }

    if (token.startsWith('demo-') || token.startsWith('social-')) {
      final mock = SupplierProfile(
        supplierId: 'supp_demo_${DateTime.now().millisecondsSinceEpoch}',
        supplierName: supplierName,
        contactEmail: contactEmail ?? _currentUser?.email,
        contactPhone: contactPhone ?? _currentUser?.phone,
        address: address,
        city: city ?? 'Hồ Chí Minh',
        supplierLogoUrl: supplierLogoUrl,
      );
      _hasSupplier = true;
      _supplierProfile = mock;
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          storeName: supplierName,
          storeId: mock.supplierId,
          address: address,
          phone: contactPhone,
          supplierProfile: mock,
        );
        await _storage.saveSellerProfile(_currentUser!.toJson());
      }
      notifyListeners();
      return mock;
    }

    final profile = await _apiService.createSupplierStore(
      token: token,
      supplierName: supplierName,
      supplierCode: supplierCode,
      contactEmail: contactEmail ?? _currentUser?.email,
      contactPhone: contactPhone,
      address: address,
      city: city,
      supplierLogoUrl: supplierLogoUrl,
    );

    _hasSupplier = true;
    _supplierProfile = profile;

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        storeName: profile.supplierName,
        storeId: profile.supplierId,
        address: profile.address ?? _currentUser!.address,
        phone: profile.contactPhone ?? _currentUser!.phone,
        supplierProfile: profile,
      );
      await _storage.saveSellerProfile(_currentUser!.toJson());
    }

    notifyListeners();
    return profile;
  }

  /// Update store profile (Backward-compatibility & Profile edits)
  Future<void> updateStoreProfile({
    required String storeName,
    required String fullName,
    String? phone,
    String? category,
    String? address,
    String? description,
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        storeName: storeName,
        fullName: fullName,
        phone: phone ?? _currentUser!.phone,
        category: category ?? _currentUser!.category,
        address: address ?? _currentUser!.address,
        description: description ?? _currentUser!.description,
      );
      _hasSupplier = true;
      await _storage.saveSellerProfile(_currentUser!.toJson());
      notifyListeners();

      final token = _tokens?.accessToken;
      if (token != null && !token.startsWith('demo-') && !token.startsWith('social-')) {
        _apiService.updateStoreProfile(
          token: token,
          data: {
            'storeName': storeName,
            'fullName': fullName,
            'phone': ?phone,
            'category': ?category,
            'address': ?address,
            'description': ?description,
          },
        ).catchError((_) => false);
      }
    }
  }

  /// Social Login (Google / Apple)
  Future<SellerAuthResult> loginWithSocial({
    required String provider,
    String? token,
    String? email,
    String? displayName,
  }) async {
    final fallbackEmail = email ??
        (provider == 'google'
            ? 'partner.google@cookconnect.app'
            : 'partner.apple@cookconnect.app');
    final fallbackName = displayName ??
        (provider == 'google' ? 'Google Supplier Partner' : 'Apple Supplier Partner');

    final user = SellerUser(
      id: 'supplier_${provider}_${DateTime.now().millisecondsSinceEpoch}',
      email: fallbackEmail,
      fullName: fallbackName,
      storeName: 'Gian hàng $fallbackName',
      role: 'SUPPLIER_ADMIN',
    );

    final tokens = AuthTokens(
      accessToken: 'social-$provider-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'social-$provider-refresh-${DateTime.now().millisecondsSinceEpoch}',
      expiresIn: 86400,
    );

    _hasSupplier = true;
    setSession(user: user, tokens: tokens);

    return SellerAuthResult(
      success: true,
      message: 'Đăng nhập thành công qua $provider',
      tokens: tokens,
      user: user,
    );
  }

  /// Quick Demo Seller session for testing / previewing
  void setDemoSession({
    String storeName = 'Đại Siêu Thị Nguyên Liệu Tươi CookConnect',
    String email = 'supplier.demo@cookconnect.app',
    String phone = '0987654321',
    String ownerName = 'Nguyễn Quang Hải',
    String category = 'Nguyên liệu thực phẩm tươi sống',
    String address = '123 Đường Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh',
  }) {
    final demoProfile = SupplierProfile(
      supplierId: 'demo-supplier-01',
      supplierName: storeName,
      supplierSlug: 'dai-sieu-thi-nguyen-lieu-tuoi',
      supplierCode: 'SUPP-DEMO-01',
      contactEmail: email,
      contactPhone: phone,
      address: address,
      city: 'Hồ Chí Minh',
      rating: 4.9,
      isVerified: true,
      supplierStatus: 'ACTIVE',
      role: 'SUPPLIER_ADMIN',
    );

    final demoUser = SellerUser(
      id: 'demo-supplier-user-01',
      email: email,
      fullName: ownerName,
      storeName: storeName,
      storeId: 'demo-supplier-01',
      phone: phone,
      role: 'SUPPLIER_ADMIN',
      category: category,
      address: address,
      supplierProfile: demoProfile,
    );

    final demoTokens = AuthTokens(
      accessToken: 'demo-seller-token-01',
      refreshToken: 'demo-seller-refresh-01',
      expiresIn: 86400 * 30,
    );

    _hasSupplier = true;
    _supplierProfile = demoProfile;
    setSession(user: demoUser, tokens: demoTokens);
  }

  /// Save session state
  void setSession({required SellerUser user, required AuthTokens tokens}) {
    _currentUser = user;
    _tokens = tokens;
    notifyListeners();

    _storage.saveTokens(tokens);
    _storage.saveSellerProfile(user.toJson());
  }

  /// Proactively refresh the access token
  Future<String?> refreshAccessToken() async {
    final currentTokens = _tokens;
    if (currentTokens == null || currentTokens.refreshToken.isEmpty) {
      logout(callServer: false, sessionExpired: true);
      return null;
    }

    if (currentTokens.accessToken.startsWith('demo-') ||
        currentTokens.accessToken.startsWith('social-')) {
      return currentTokens.accessToken;
    }

    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final result = await _apiService.refreshToken(currentTokens.refreshToken);
      if (result.success && result.tokens != null) {
        final newTokens = result.tokens!;
        _tokens = newTokens;
        await _storage.saveTokens(newTokens);
        notifyListeners();
        completer.complete(newTokens.accessToken);
        return newTokens.accessToken;
      } else {
        logout(callServer: false, sessionExpired: true);
        completer.complete(null);
        return null;
      }
    } catch (_) {
      logout(callServer: false, sessionExpired: true);
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Handle session expiration
  void handleSessionExpired() {
    if (isLoggedIn) {
      logout(callServer: false, sessionExpired: true);
    }
  }

  /// Logout and clear storage
  Future<void> logout({bool callServer = true, bool sessionExpired = false}) async {
    final token = _tokens?.accessToken;
    final wasLoggedIn = isLoggedIn;

    _currentUser = null;
    _tokens = null;
    _hasSupplier = false;
    _supplierProfile = null;
    notifyListeners();

    await _storage.clearAuth();

    if (callServer && token != null && !token.startsWith('demo-')) {
      _apiService.logout(token).catchError((_) => false);
    }

    if (sessionExpired || wasLoggedIn) {
      _onSessionExpired();
    }
  }

  void _onSessionExpired() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.popUntil((route) => route.isFirst);
        }
      } catch (_) {}
    });
  }
}
