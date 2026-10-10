import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

abstract class TokenStorageService {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> getTokens();
  Future<void> saveUser(AuthUser user);
  Future<AuthUser?> getUser();
  Future<void> clearAuth();
}

/// Secure token & credentials storage using Android KeyStore (AES/GCM + RSA-OAEP) and iOS Keychain.
class SecureTokenStorageService implements TokenStorageService {
  final FlutterSecureStorage _storage;

  static const String _keyAccessToken = 'cc_access_token';
  static const String _keyRefreshToken = 'cc_refresh_token';
  static const String _keyTokenType = 'cc_token_type';
  static const String _keyExpiresIn = 'cc_expires_in';
  static const String _keyCreatedAt = 'cc_created_at';
  static const String _keyUserData = 'cc_user_data';

  SecureTokenStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    try {
      await _storage.write(key: _keyAccessToken, value: tokens.accessToken);
      await _storage.write(key: _keyRefreshToken, value: tokens.refreshToken);
      await _storage.write(key: _keyTokenType, value: tokens.tokenType);
      await _storage.write(
        key: _keyExpiresIn,
        value: tokens.expiresIn.toString(),
      );
      await _storage.write(
        key: _keyCreatedAt,
        value: tokens.createdAt.millisecondsSinceEpoch.toString(),
      );
    } catch (_) {
      // Graceful fallback
    }
  }

  @override
  Future<AuthTokens?> getTokens() async {
    try {
      final accessToken = await _storage.read(key: _keyAccessToken);
      final refreshToken = await _storage.read(key: _keyRefreshToken);

      if (accessToken == null ||
          accessToken.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        return null;
      }

      final tokenType = await _storage.read(key: _keyTokenType) ?? 'Bearer';
      final expiresInStr = await _storage.read(key: _keyExpiresIn);
      final expiresIn = int.tryParse(expiresInStr ?? '') ?? 900;

      final createdAtStr = await _storage.read(key: _keyCreatedAt);
      final createdAtMillis = int.tryParse(createdAtStr ?? '');
      final createdAt = createdAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(createdAtMillis)
          : null;

      return AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
        expiresIn: expiresIn,
        createdAt: createdAt,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUser(AuthUser user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: _keyUserData, value: userJson);
    } catch (_) {
      // Graceful fallback
    }
  }

  @override
  Future<AuthUser?> getUser() async {
    try {
      final userJsonStr = await _storage.read(key: _keyUserData);
      if (userJsonStr == null || userJsonStr.isEmpty) {
        return null;
      }
      final decoded = jsonDecode(userJsonStr) as Map<String, dynamic>;
      return AuthUser.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAuth() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyTokenType);
      await _storage.delete(key: _keyExpiresIn);
      await _storage.delete(key: _keyCreatedAt);
      await _storage.delete(key: _keyUserData);
    } catch (_) {
      // Graceful fallback
    }
  }
}

/// In-memory implementation of TokenStorageService for tests or mock usage.
class InMemoryTokenStorageService implements TokenStorageService {
  AuthTokens? _tokens;
  AuthUser? _user;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    _tokens = tokens;
  }

  @override
  Future<AuthTokens?> getTokens() async {
    return _tokens;
  }

  @override
  Future<void> saveUser(AuthUser user) async {
    _user = user;
  }

  @override
  Future<AuthUser?> getUser() async {
    return _user;
  }

  @override
  Future<void> clearAuth() async {
    _tokens = null;
    _user = null;
  }
}
