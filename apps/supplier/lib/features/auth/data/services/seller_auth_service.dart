import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/core/network/api_exception.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/auth/data/models/otp_result.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';
import 'package:cook_connect_seller/features/auth/data/services/auth_api_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/auth_gate.dart';

/// Global singleton session and authentication state manager for CookConnect Supplier.
class SellerAuthService extends ChangeNotifier with WidgetsBindingObserver {
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

  bool _isValidatingSession = false;
  DateTime? _lastValidationTime;
  bool _isObserverRegistered = false;

  SellerUser? get currentUser => _currentUser;
  AuthTokens? get tokens => _tokens;
  bool get hasSupplier => _hasSupplier;
  SupplierProfile? get supplierProfile => _supplierProfile;
  bool get isLoggedIn => _currentUser != null && _tokens != null;
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      handleAppResumed();
    }
  }

  @override
  void dispose() {
    if (_isObserverRegistered) {
      try {
        WidgetsBinding.instance.removeObserver(this);
      } catch (_) {}
      _isObserverRegistered = false;
    }
    super.dispose();
  }

  /// Initialize session from secure storage (KeyStore / Keychain)
  Future<void> init() async {
    try {
      try {
        if (!_isObserverRegistered) {
          WidgetsBinding.instance.addObserver(this);
          _isObserverRegistered = true;
        }
      } catch (_) {
        // WidgetsBinding might not be initialized in headless test environments
      }

      final cachedTokens = await _storage.getTokens();
      final cachedProfile = await _storage.getSellerProfile();

      if (cachedTokens != null) {
        // If both tokens are expired or refresh token is expired, reject immediately
        if (cachedTokens.isRefreshTokenExpired() ||
            (cachedTokens.isAccessTokenExpired() && cachedTokens.refreshToken.isEmpty)) {
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
        notifyListeners();

        // Restore & refresh profile/token with backend
        await restoreSession();
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

  /// Triggered when returning to the app from background (resumed).
  /// Re-validates the session, proactively refreshes expired tokens,
  /// and fetches fresh supplier store and user data.
  /// If unsuccessful due to expired/invalid token or revoked session, logs out immediately.
  Future<void> handleAppResumed() async {
    if (_tokens == null || _currentUser == null) {
      return;
    }

    if (_tokens!.accessToken.startsWith('demo-') ||
        _tokens!.accessToken.startsWith('social-')) {
      return;
    }

    final now = DateTime.now();
    if (_lastValidationTime != null &&
        now.difference(_lastValidationTime!) < const Duration(seconds: 2)) {
      return;
    }

    if (_isValidatingSession) {
      return;
    }

    _isValidatingSession = true;
    _lastValidationTime = now;

    try {
      await restoreSession();
    } finally {
      _isValidatingSession = false;
    }
  }

  /// Restore and sync supplier session with backend.
  /// Validates token and queries /api/v1/suppliers/me and /api/v1/auth/me.
  /// If token has expired or credentials are rejected, logs out immediately.
  Future<void> restoreSession() async {
    final currentTokens = _tokens;
    if (currentTokens == null) return;

    if (currentTokens.accessToken.startsWith('demo-') ||
        currentTokens.accessToken.startsWith('social-')) {
      return;
    }

    // 1. Proactive token check: If refresh token is expired, session is irrecoverable -> logout
    if (currentTokens.isRefreshTokenExpired() ||
        (currentTokens.isAccessTokenExpired() && currentTokens.refreshToken.isEmpty)) {
      await logout(callServer: false, sessionExpired: true);
      return;
    }

    // 2. If access token is expired, proactively rotate via /api/v1/auth/refresh
    if (currentTokens.isAccessTokenExpired()) {
      final newToken = await refreshAccessToken();
      if (newToken == null) {
        // Refresh failed (invalid/expired/revoked) -> ensure user is logged out immediately
        await logout(callServer: false, sessionExpired: true);
        return;
      }
    }

    try {
      final activeTokens = _tokens;
      if (activeTokens == null) return;

      // 3. Fetch & validate supplier store profile (GET /api/v1/suppliers/me)
      await checkSupplierStatus();

      // 4. Fetch & validate user account data (GET /api/v1/auth/me)
      if (_tokens != null) {
        try {
          final meUser = await _apiService.getMe(_tokens!.accessToken);
          if (meUser != null && _currentUser != null) {
            _currentUser = _currentUser!.copyWith(
              id: meUser.id.isNotEmpty ? meUser.id : _currentUser!.id,
              email: meUser.email.isNotEmpty ? meUser.email : _currentUser!.email,
              roles: meUser.roles.isNotEmpty ? meUser.roles : _currentUser!.roles,
            );
            await _storage.saveSellerProfile(_currentUser!.toJson());
            notifyListeners();
          }
        } on ApiException catch (e) {
          if (e.statusCode == 401 || e.statusCode == 403 || e.statusCode == 404) {
            await logout(callServer: false, sessionExpired: true);
            return;
          }
        } catch (_) {}
      }
    } on ApiException catch (e) {
      debugPrint('SellerAuthService restoreSession ApiException: ${e.statusCode} ${e.message}');
      if (e.statusCode == 401 || e.statusCode == 403 || e.statusCode == 404) {
        await logout(callServer: false, sessionExpired: true);
      }
    } catch (e) {
      debugPrint('SellerAuthService restoreSession error: $e');
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
      if (e is ApiException && (e.statusCode == 401 || e.statusCode == 403 || e.statusCode == 404)) {
        await logout(callServer: false, sessionExpired: true);
      }
      return null;
    }
  }

  /// Send OTP for registration to email
  Future<OtpResult> sendOtp({required String contact, String? deviceId}) async {
    return _apiService.sendOtp(contact: contact, deviceId: deviceId);
  }

  /// Verify OTP code to obtain verificationToken
  Future<OtpResult> verifyOtp({
    required String contact,
    required String otp,
    String? deviceId,
  }) async {
    return _apiService.verifyOtp(contact: contact, otp: otp, deviceId: deviceId);
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

  /// Register a new supplier admin account (Step 3: Password creation via merged API)
  Future<SellerAuthResult> register({
    required String email,
    required String password,
    String? confirmPassword,
    String? storeName,
    String? fullName,
    String? phone,
    String? verificationToken,
    String? deviceId,
  }) async {
    final result = await _apiService.register(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      verificationToken: verificationToken,
      storeName: storeName,
      fullName: fullName,
      phone: phone,
      deviceId: deviceId,
    );
    if (result.success && result.tokens != null) {
      final defaultName = fullName ?? (email.contains('@') ? email.split('@').first : email);
      final defaultStore = storeName ?? 'Gian hàng $defaultName';
      var user = result.user ??
          SellerUser(
            id: 'supplier_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            storeName: defaultStore,
            fullName: defaultName,
            phone: phone,
          );
      if (user.fullName == null || user.fullName!.isEmpty) {
        user = user.copyWith(fullName: defaultName);
      }
      if (user.storeName == null || user.storeName!.isEmpty) {
        user = user.copyWith(storeName: defaultStore);
      }
      if (user.phone == null && phone != null) {
        user = user.copyWith(phone: phone);
      }
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

  /// Update detailed supplier store information
  Future<bool> updateSupplierStoreDetails({
    required String storeName,
    String? contactPhone,
    String? contactEmail,
    String? address,
    String? city,
    String? category,
    String? description,
    String? logoUrl,
    String? supplierStatus,
    String? ownerName,
  }) async {
    final suppId = _supplierProfile?.supplierId ?? _currentUser?.storeId;

    if (_supplierProfile != null) {
      _supplierProfile = _supplierProfile!.copyWith(
        supplierName: storeName,
        contactPhone: contactPhone ?? _supplierProfile!.contactPhone,
        contactEmail: contactEmail ?? _supplierProfile!.contactEmail,
        address: address ?? _supplierProfile!.address,
        city: city ?? _supplierProfile!.city,
        supplierLogoUrl: logoUrl ?? _supplierProfile!.supplierLogoUrl,
        supplierStatus: supplierStatus ?? _supplierProfile!.supplierStatus,
      );
    }

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        storeName: storeName,
        fullName: ownerName ?? _currentUser!.fullName,
        phone: contactPhone ?? _currentUser!.phone,
        category: category ?? _currentUser!.category,
        address: address ?? _currentUser!.address,
        description: description ?? _currentUser!.description,
        supplierProfile: _supplierProfile,
      );
      await _storage.saveSellerProfile(_currentUser!.toJson());
    }

    _hasSupplier = true;
    notifyListeners();

    final token = _tokens?.accessToken;
    if (token != null &&
        !token.startsWith('demo-') &&
        !token.startsWith('social-') &&
        suppId != null &&
        suppId.isNotEmpty) {
      try {
        final updateData = <String, dynamic>{
          'supplierName': storeName,
          if (contactPhone != null && contactPhone.isNotEmpty) 'contactPhone': contactPhone,
          if (contactEmail != null && contactEmail.isNotEmpty) 'contactEmail': contactEmail,
          if (address != null && address.isNotEmpty) 'address': address,
          if (city != null && city.isNotEmpty) 'city': city,
          if (logoUrl != null && logoUrl.isNotEmpty) 'supplierLogoUrl': logoUrl,
        };
        final updatedSupplier = await _apiService.updateSupplier(
          token: token,
          supplierId: suppId,
          body: updateData,
        );
        if (updatedSupplier != null) {
          _supplierProfile = updatedSupplier;
          if (_currentUser != null) {
            _currentUser = _currentUser!.copyWith(supplierProfile: _supplierProfile);
            await _storage.saveSellerProfile(_currentUser!.toJson());
          }
          notifyListeners();
        }

        if (supplierStatus != null) {
          await _apiService.updateSupplierStatus(
            token: token,
            supplierId: suppId,
            status: supplierStatus,
          );
        }
        return true;
      } catch (e) {
        debugPrint('updateSupplierStoreDetails error: ');
        return false;
      }
    }
    return true;
  }

  /// Upload media image to server and get back remote URL
  Future<String> uploadImage(String imagePath, {String folder = 'cookconnect/kyb'}) async {
    final token = _tokens?.accessToken;
    if (token == null || token.isEmpty) {
      throw ApiException(statusCode: 401, message: 'Phiên đăng nhập đã hết hạn');
    }
    return _apiService.uploadMediaImage(token: token, imagePath: imagePath, folder: folder);
  }

  /// Submit KYB verification documents (Step 2/3)
  Future<bool> submitKyb({
    required String merchantType,
    String? citizenId,
    String? citizenIdIssuedDate,
    String? idCardFrontUrl,
    String? idCardBackUrl,
    String? businessName,
    String? taxCode,
    String? businessLicenseUrl,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountHolder,
  }) async {
    final token = _tokens?.accessToken;
    if (token == null || token.isEmpty) return false;

    if (token.startsWith('demo-') || token.startsWith('social-')) {
      if (_supplierProfile != null) {
        _supplierProfile = _supplierProfile!.copyWith(
          supplierStatus: 'UNDER_REVIEW',
          merchantType: merchantType,
          citizenId: citizenId,
          businessName: businessName,
          taxCode: taxCode,
          bankName: bankName,
          bankAccountNumber: bankAccountNumber,
          bankAccountHolder: bankAccountHolder,
        );
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(supplierProfile: _supplierProfile);
          await _storage.saveSellerProfile(_currentUser!.toJson());
        }
        notifyListeners();
      }
      return true;
    }

    // Auto-upload local images if local file paths are passed
    String? resolvedFrontUrl = idCardFrontUrl;
    if (resolvedFrontUrl != null &&
        resolvedFrontUrl.isNotEmpty &&
        !resolvedFrontUrl.startsWith('http://') &&
        !resolvedFrontUrl.startsWith('https://')) {
      resolvedFrontUrl = await uploadImage(resolvedFrontUrl, folder: 'cookconnect/kyb');
    }

    String? resolvedBackUrl = idCardBackUrl;
    if (resolvedBackUrl != null &&
        resolvedBackUrl.isNotEmpty &&
        !resolvedBackUrl.startsWith('http://') &&
        !resolvedBackUrl.startsWith('https://')) {
      resolvedBackUrl = await uploadImage(resolvedBackUrl, folder: 'cookconnect/kyb');
    }

    String? resolvedLicenseUrl = businessLicenseUrl;
    if (resolvedLicenseUrl != null &&
        resolvedLicenseUrl.isNotEmpty &&
        !resolvedLicenseUrl.startsWith('http://') &&
        !resolvedLicenseUrl.startsWith('https://')) {
      resolvedLicenseUrl = await uploadImage(resolvedLicenseUrl, folder: 'cookconnect/kyb');
    }

    final kybPayload = <String, dynamic>{
      'merchantType': merchantType,
      if (citizenId != null && citizenId.isNotEmpty) 'citizenId': citizenId,
      if (citizenIdIssuedDate != null && citizenIdIssuedDate.isNotEmpty)
        'citizenIdIssuedDate': citizenIdIssuedDate,
      if (resolvedFrontUrl != null && resolvedFrontUrl.isNotEmpty)
        'idCardFrontUrl': resolvedFrontUrl,
      if (resolvedBackUrl != null && resolvedBackUrl.isNotEmpty)
        'idCardBackUrl': resolvedBackUrl,
      if (businessName != null && businessName.isNotEmpty)
        'businessName': businessName,
      if (taxCode != null && taxCode.isNotEmpty) 'taxCode': taxCode,
      if (resolvedLicenseUrl != null && resolvedLicenseUrl.isNotEmpty)
        'businessLicenseUrl': resolvedLicenseUrl,
      if (bankName != null && bankName.isNotEmpty) 'bankName': bankName,
      if (bankAccountNumber != null && bankAccountNumber.isNotEmpty)
        'bankAccountNumber': bankAccountNumber,
      if (bankAccountHolder != null && bankAccountHolder.isNotEmpty)
        'bankAccountHolder': bankAccountHolder,
    };

    final profile = await _apiService.submitKyb(token: token, kybData: kybPayload);
    if (profile != null) {
      _supplierProfile = profile;
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(supplierProfile: _supplierProfile);
        await _storage.saveSellerProfile(_currentUser!.toJson());
      }
      notifyListeners();
      return true;
    }
    return false;
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
        (provider == 'google' ? 'Google Seller Partner' : 'Apple Seller Partner');

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

  /// Returns a valid access token.
  /// If the current access token is expired or expiring soon, but the refresh token is valid,
  /// it proactively calls [refreshAccessToken] to rotate and refresh token via /api/v1/auth/refresh.
  /// Returns null only if no tokens exist, or if the refresh token is expired/revoked.
  Future<String?> getValidAccessToken({bool forceRefresh = false}) async {
    if (_tokens == null) {
      final cachedTokens = await _storage.getTokens();
      if (cachedTokens != null) {
        _tokens = cachedTokens;
      }
    }

    final currentTokens = _tokens;
    if (currentTokens == null || currentTokens.accessToken.isEmpty) {
      return null;
    }

    if (currentTokens.accessToken.startsWith('demo-') ||
        currentTokens.accessToken.startsWith('social-')) {
      return currentTokens.accessToken;
    }

    // 1. If access token is still valid and forceRefresh is not requested, return it
    if (!forceRefresh && !currentTokens.isAccessTokenExpired()) {
      return currentTokens.accessToken;
    }

    // 2. Access token is expired (or forceRefresh). Attempt refresh if refresh token is valid.
    if (currentTokens.refreshToken.isNotEmpty && !currentTokens.isRefreshTokenExpired()) {
      debugPrint('🔄 Access token expired. Proactively refreshing token via /api/v1/auth/refresh...');
      final newToken = await refreshAccessToken();
      return newToken;
    }

    // 3. Refresh token is also expired or missing -> force logout
    await logout(callServer: false, sessionExpired: true);
    return null;
  }

  /// Proactively refresh the access token using stored refresh token via /api/v1/auth/refresh
  Future<String?> refreshAccessToken() async {
    if (_tokens == null) {
      final cachedTokens = await _storage.getTokens();
      if (cachedTokens != null) {
        _tokens = cachedTokens;
      }
    }

    final currentTokens = _tokens;
    if (currentTokens == null || currentTokens.refreshToken.isEmpty) {
      await logout(callServer: false, sessionExpired: true);
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
        if (result.user != null) {
          _currentUser = _mergeUser(_currentUser, result.user!);
          await _storage.saveSellerProfile(_currentUser!.toJson());
        }
        notifyListeners();
        completer.complete(newTokens.accessToken);
        return newTokens.accessToken;
      } else {
        // Refresh token failed (expired, invalid, revoked, or server error) -> force logout immediately
        await logout(callServer: false, sessionExpired: true);
        completer.complete(null);
        return null;
      }
    } catch (_) {
      await logout(callServer: false, sessionExpired: true);
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Handle session expiration callback from ApiClient
  void handleSessionExpired() {
    if (_tokens != null || _currentUser != null) {
      logout(callServer: false, sessionExpired: true);
    }
  }

  /// Logout and clear storage
  Future<void> logout({bool callServer = true, bool sessionExpired = false}) async {
    final token = _tokens?.accessToken;
    final hadSession = _tokens != null || _currentUser != null;

    // 1. Immediately wipe all local secure tokens and cached profile
    await _storage.clearAuth();

    // 2. Clear in-memory session and notify listeners to reset state
    _currentUser = null;
    _tokens = null;
    _hasSupplier = false;
    _supplierProfile = null;
    notifyListeners();

    // 3. Notify backend server to invalidate session/token
    if (callServer && token != null && !token.startsWith('demo-') && !token.startsWith('social-')) {
      _apiService.logout(token).catchError((_) => false);
    }

    // 4. Force reset navigation back to AuthGate / WelcomeAuthScreen
    if (sessionExpired || hadSession) {
      _onSessionExpired(showNotification: sessionExpired);
    }
  }

  void _onSessionExpired({bool showNotification = false}) {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthGate()),
              (route) => false,
            );
          }
        } catch (_) {}

        if (showNotification) {
          try {
            final messenger = scaffoldMessengerKey.currentState;
            if (messenger != null) {
              messenger.removeCurrentSnackBar();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (_) {}
        }
      });
    } catch (_) {
      // Binding not initialized (e.g. during headless unit tests)
    }
  }

  /// Merge existing user with updated server user, preserving non-null existing data
  SellerUser _mergeUser(SellerUser? current, SellerUser updated) {
    if (current == null) return updated;
    return current.copyWith(
      id: updated.id.isNotEmpty ? updated.id : current.id,
      email: updated.email.isNotEmpty ? updated.email : current.email,
      roles: updated.roles.isNotEmpty ? updated.roles : current.roles,
      fullName: (updated.fullName != null && updated.fullName!.isNotEmpty)
          ? updated.fullName
          : current.fullName,
      storeName: (updated.storeName != null && updated.storeName!.isNotEmpty)
          ? updated.storeName
          : current.storeName,
      storeId: (updated.storeId != null && updated.storeId!.isNotEmpty)
          ? updated.storeId
          : current.storeId,
      phone: (updated.phone != null && updated.phone!.isNotEmpty)
          ? updated.phone
          : current.phone,
      role: updated.role ?? current.role,
      category: updated.category ?? current.category,
      address: updated.address ?? current.address,
      description: updated.description ?? current.description,
      supplierProfile: updated.supplierProfile ?? current.supplierProfile,
    );
  }
}
