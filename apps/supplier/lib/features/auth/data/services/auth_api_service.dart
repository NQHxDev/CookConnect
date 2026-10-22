import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/core/network/api_exception.dart';
import 'package:cook_connect_seller/features/auth/data/models/otp_result.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';

class AuthApiService {
  final ApiClient _client;

  AuthApiService({ApiClient? apiClient}) : _client = apiClient ?? ApiClient();

  /// Send 6-digit OTP to Email for supplier registration
  Future<OtpResult> sendOtp({required String contact}) async {
    final cleanContact = contact.trim().toLowerCase();
    try {
      final response = await _client.post(
        ApiConfig.sendOtpPath,
        body: {
          'email': cleanContact,
        },
      );
      return OtpResult.fromJson(response);
    } on ApiException catch (e) {
      return OtpResult.failure(
        error: e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return OtpResult.failure(
        error: 'Lỗi gửi mã OTP: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  /// Verify 6-digit OTP to receive verificationToken
  Future<OtpResult> verifyOtp({
    required String contact,
    required String otp,
  }) async {
    final cleanContact = contact.trim().toLowerCase();
    final cleanOtp = otp.trim();

    try {
      final response = await _client.post(
        ApiConfig.verifyOtpPath,
        body: {
          'email': cleanContact,
          'otp': cleanOtp,
        },
      );
      return OtpResult.fromJson(response);
    } on ApiException catch (e) {
      return OtpResult.failure(
        error: e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return OtpResult.failure(
        error: 'Lỗi xác thực mã OTP: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  /// User login with email & password
  Future<SellerAuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.loginPath,
        body: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'clientType': 'mobile',
        },
      );
      return SellerAuthResult.fromJson(response);
    } on ApiException catch (e) {
      return SellerAuthResult(
        success: false,
        message: e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return SellerAuthResult(
        success: false,
        message: e.toString().replaceFirst('ApiException: ', ''),
      );
    }
  }

  /// User login with phone & password
  Future<SellerAuthResult> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.loginPath,
        body: {
          'phone': phone.trim(),
          'password': password,
          'clientType': 'mobile',
        },
      );
      return SellerAuthResult.fromJson(response);
    } on ApiException catch (e) {
      return SellerAuthResult(
        success: false,
        message: e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return SellerAuthResult(
        success: false,
        message: e.toString().replaceFirst('ApiException: ', ''),
      );
    }
  }

  /// Register new Supplier Admin account (Step 3: Password creation)
  Future<SellerAuthResult> register({
    required String email,
    required String password,
    String? confirmPassword,
    String? verificationToken,
    String? storeName,
    String? fullName,
    String? phone,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.registerSupplierPath,
        body: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'confirmPassword': confirmPassword ?? password,
          'clientType': 'mobile',
          if (verificationToken != null && verificationToken.isNotEmpty)
            'verificationToken': verificationToken,
        },
      );
      return SellerAuthResult.fromJson(response);
    } on ApiException catch (e) {
      return SellerAuthResult(
        success: false,
        message: e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return SellerAuthResult(
        success: false,
        message: e.toString().replaceFirst('ApiException: ', ''),
      );
    }
  }

  /// Register a new supplier store or vendor (Step 4: Store Onboarding)
  Future<SupplierProfile> createSupplierStore({
    required String token,
    required String supplierName,
    String? supplierCode,
    String? contactEmail,
    String? contactPhone,
    String? address,
    String? city,
    String? supplierLogoUrl,
  }) async {
    final response = await _client.post(
      ApiConfig.suppliersPath,
      token: token,
      body: {
        'supplierName': supplierName.trim(),
        if (supplierCode != null && supplierCode.isNotEmpty) 'supplierCode': supplierCode.trim(),
        if (contactEmail != null && contactEmail.isNotEmpty) 'contactEmail': contactEmail.trim().toLowerCase(),
        if (contactPhone != null && contactPhone.isNotEmpty) 'contactPhone': contactPhone.trim(),
        if (address != null && address.isNotEmpty) 'address': address.trim(),
        if (city != null && city.isNotEmpty) 'city': city.trim(),
        if (supplierLogoUrl != null && supplierLogoUrl.isNotEmpty) 'supplierLogoUrl': supplierLogoUrl.trim(),
      },
    );

    final data = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;
    return SupplierProfile.fromJson(data);
  }

  /// Check supplier store onboarding state and fetch store profile
  Future<MySupplierResult> getMySupplier({required String token}) async {
    final response = await _client.get(
      ApiConfig.mySupplierPath,
      token: token,
    );
    return MySupplierResult.fromJson(response);
  }

  /// Update store profile
  Future<bool> updateStoreProfile({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.put(
        ApiConfig.storeProfilePath,
        token: token,
        body: data,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Proactive refresh token
  Future<SellerAuthResult> refreshToken(String refreshToken) async {
    try {
      final response = await _client.post(
        ApiConfig.refreshPath,
        body: {'refreshToken': refreshToken},
      );
      return SellerAuthResult.fromJson(response);
    } on ApiException catch (e) {
      return SellerAuthResult(
        success: false,
        message: e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return SellerAuthResult(
        success: false,
        message: e.toString().replaceFirst('ApiException: ', ''),
      );
    }
  }

  /// Logout
  Future<bool> logout(String token) async {
    try {
      await _client.post(ApiConfig.logoutPath, token: token);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get authenticated user profile from Auth service
  Future<SellerUser?> getMe(String token) async {
    try {
      final response = await _client.get(ApiConfig.mePath, token: token);
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        return SellerUser.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
