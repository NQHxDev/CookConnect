import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cook_connect_seller/core/constants/app_constants.dart';

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
    this.expiresIn = 3600,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpired {
    final expiryTime = createdAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expiryTime);
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'expiresIn': expiresIn,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: json['accessToken'] as String? ?? json['token'] as String? ?? '',
    refreshToken: json['refreshToken'] as String? ?? '',
    tokenType: json['tokenType'] as String? ?? 'Bearer',
    expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 3600,
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
  );
}

abstract class TokenStorageService {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> getTokens();
  Future<void> saveSellerProfile(Map<String, dynamic> profile);
  Future<Map<String, dynamic>?> getSellerProfile();
  Future<void> clearAuth();
}

/// Secure storage implementation using Android KeyStore & iOS Keychain
class SecureTokenStorageService implements TokenStorageService {
  final FlutterSecureStorage _storage;

  SecureTokenStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(resetOnError: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    try {
      await _storage.write(key: AppConstants.keyAccessToken, value: tokens.accessToken);
      await _storage.write(key: AppConstants.keyRefreshToken, value: tokens.refreshToken);
      await _storage.write(
        key: 'ccs_token_meta',
        value: jsonEncode(tokens.toJson()),
      );
    } catch (_) {}
  }

  @override
  Future<AuthTokens?> getTokens() async {
    try {
      final meta = await _storage.read(key: 'ccs_token_meta');
      if (meta != null && meta.isNotEmpty) {
        return AuthTokens.fromJson(jsonDecode(meta));
      }
      final access = await _storage.read(key: AppConstants.keyAccessToken);
      final refresh = await _storage.read(key: AppConstants.keyRefreshToken);
      if (access == null || access.isEmpty) return null;
      return AuthTokens(accessToken: access, refreshToken: refresh ?? '');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSellerProfile(Map<String, dynamic> profile) async {
    try {
      await _storage.write(
        key: AppConstants.keySellerProfile,
        value: jsonEncode(profile),
      );
    } catch (_) {}
  }

  @override
  Future<Map<String, dynamic>?> getSellerProfile() async {
    try {
      final str = await _storage.read(key: AppConstants.keySellerProfile);
      if (str == null || str.isEmpty) return null;
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAuth() async {
    try {
      await _storage.delete(key: AppConstants.keyAccessToken);
      await _storage.delete(key: AppConstants.keyRefreshToken);
      await _storage.delete(key: 'ccs_token_meta');
      await _storage.delete(key: AppConstants.keySellerProfile);
      await _storage.delete(key: AppConstants.keyStoreConfig);
    } catch (_) {}
  }
}

/// In-memory storage implementation for unit tests
class InMemoryTokenStorageService implements TokenStorageService {
  AuthTokens? _tokens;
  Map<String, dynamic>? _profile;

  @override
  Future<void> saveTokens(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<AuthTokens?> getTokens() async => _tokens;

  @override
  Future<void> saveSellerProfile(Map<String, dynamic> profile) async => _profile = profile;

  @override
  Future<Map<String, dynamic>?> getSellerProfile() async => _profile;

  @override
  Future<void> clearAuth() async {
    _tokens = null;
    _profile = null;
  }
}
