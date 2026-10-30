import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/core/network/api_exception.dart';
import 'package:cook_connect_seller/features/auth/data/models/otp_result.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';

class AuthApiService {
  final ApiClient _client;

  AuthApiService({ApiClient? apiClient}) : _client = apiClient ?? ApiClient();

  /// Send 6-digit OTP to Email for supplier registration
  Future<OtpResult> sendOtp({
    required String contact,
    String clientType = 'mobile',
    String? deviceId,
  }) async {
    final cleanContact = contact.trim().toLowerCase();
    try {
      final response = await _client.post(
        ApiConfig.sendOtpPath,
        headers: {
          'X-Client-Type': clientType,
          if (deviceId != null && deviceId.isNotEmpty) 'X-Device-Id': deviceId,
        },
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
    String clientType = 'mobile',
    String? deviceId,
  }) async {
    final cleanContact = contact.trim().toLowerCase();
    final cleanOtp = otp.trim();

    try {
      final response = await _client.post(
        ApiConfig.verifyOtpPath,
        headers: {
          'X-Client-Type': clientType,
          if (deviceId != null && deviceId.isNotEmpty) 'X-Device-Id': deviceId,
        },
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
    String clientType = 'mobile',
    String? deviceId,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.loginPath,
        headers: {
          'X-Client-Type': clientType,
          if (deviceId != null && deviceId.isNotEmpty) 'X-Device-Id': deviceId,
        },
        body: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'clientType': clientType,
          if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
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
    String clientType = 'mobile',
    String? deviceId,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.loginPath,
        headers: {
          'X-Client-Type': clientType,
          if (deviceId != null && deviceId.isNotEmpty) 'X-Device-Id': deviceId,
        },
        body: {
          'phone': phone.trim(),
          'password': password,
          'clientType': clientType,
          if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
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

  /// Register new Supplier Admin account (Step 3: Account creation via merged POST /api/v1/auth/register)
  Future<SellerAuthResult> register({
    required String email,
    required String password,
    String? confirmPassword,
    String? verificationToken,
    String? storeName,
    String? fullName,
    String? phone,
    String? deviceId,
    String clientType = 'mobile',
    String appVersion = '1.0.0',
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.registerPath,
        headers: {
          'X-Client-Type': clientType,
          if (deviceId != null && deviceId.isNotEmpty) 'X-Device-Id': deviceId,
        },
        body: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'confirmPassword': confirmPassword ?? password,
          'clientType': clientType,
          if (appVersion.isNotEmpty) 'appVersion': appVersion,
          if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
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

  /// Upload image to Media Service via `POST /api/v1/media/upload`
  Future<String> uploadMediaImage({
    required String token,
    required String imagePath,
    String folder = 'cookconnect/kyb',
  }) async {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    String cleanPath = imagePath;
    if (cleanPath.startsWith('file://')) {
      cleanPath = cleanPath.substring(7);
    }

    final file = File(cleanPath);
    if (!await file.exists()) {
      return imagePath;
    }

    final bytes = await file.readAsBytes();
    final ext = imagePath.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg';
    if (ext == 'png') {
      mimeType = 'image/png';
    } else if (ext == 'webp') {
      mimeType = 'image/webp';
    } else if (ext == 'gif') {
      mimeType = 'image/gif';
    }

    final base64String = 'data:$mimeType;base64,${base64Encode(bytes)}';
    final fileName = imagePath.split('/').last;

    final body = {
      'fileBase64': base64String,
      'fileName': fileName,
      'mimeType': mimeType,
      'type': 'IMAGE',
      'folder': folder,
    };

    final response = await _client.post(
      ApiConfig.mediaUploadPath,
      token: token,
      body: body,
    );

    final url = response['data']?['url']?.toString() ??
        response['data']?['secure_url']?.toString() ??
        response['url']?.toString();

    if (url != null && url.isNotEmpty) {
      return url;
    }

    throw ApiException(statusCode: 500, message: 'Tải ảnh xác minh lên hệ thống thất bại');
  }

  /// Submit KYB legal and banking documents (Step 2/3)
  Future<SupplierProfile?> submitKyb({
    required String token,
    required Map<String, dynamic> kybData,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.submitKybPath,
        token: token,
        body: kybData,
      );
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return SupplierProfile.fromJson(data);
    } on ApiException catch (e) {
      debugPrint('[AuthApiService] submitKyb ApiException: ${e.statusCode} ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AuthApiService] submitKyb error: $e');
      rethrow;
    }
  }

  /// Update supplier store details via PATCH /api/v1/suppliers/{supplierId}
  Future<SupplierProfile?> updateSupplier({
    required String token,
    required String supplierId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _client.patch(
        ApiConfig.supplierDetailPath(supplierId),
        token: token,
        body: body,
      );
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return SupplierProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Update supplier status via PATCH /api/v1/suppliers/{supplierId}/status
  Future<bool> updateSupplierStatus({
    required String token,
    required String supplierId,
    required String status,
  }) async {
    try {
      await _client.patch(
        ApiConfig.supplierStatusPath(supplierId),
        token: token,
        body: {'status': status},
      );
      return true;
    } catch (_) {
      return false;
    }
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

  /// Proactive refresh token via /api/v1/auth/refresh
  Future<SellerAuthResult> refreshToken(String refreshToken) async {
    try {
      final response = await _client.post(
        ApiConfig.refreshPath,
        headers: {
          'x-refresh-token': refreshToken,
          'X-Refresh-Token': refreshToken,
          'X-Client-Type': 'mobile',
        },
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

  /// Get authenticated user profile from Auth service (/api/v1/auth/me)
  Future<SellerUser?> getMe(String token) async {
    try {
      final response = await _client.get(ApiConfig.mePath, token: token);
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        return SellerUser.fromJson(data);
      }
      return null;
    } on ApiException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// Get user profile details from User service (/api/v1/users/me)
  Future<Map<String, dynamic>?> getUserProfile(String token) async {
    try {
      final response = await _client.get(ApiConfig.userMePath, token: token);
      return response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
    } on ApiException {
      rethrow;
    } catch (_) {
      return null;
    }
  }
}
