import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class LanguageStorageService {
  Future<void> saveLanguage(String languageCode);
  Future<String?> getLanguage();
  Future<void> clearLanguage();
}

/// Persistent language preference storage using FlutterSecureStorage.
class SecureLanguageStorageService implements LanguageStorageService {
  final FlutterSecureStorage _storage;

  static const String _keyLanguage = 'cc_app_language';

  SecureLanguageStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(resetOnError: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  @override
  Future<void> saveLanguage(String languageCode) async {
    try {
      await _storage.write(key: _keyLanguage, value: languageCode);
    } catch (_) {
      // Graceful fallback
    }
  }

  @override
  Future<String?> getLanguage() async {
    try {
      final code = await _storage.read(key: _keyLanguage);
      if (code == null || code.trim().isEmpty) return null;
      return code.trim();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearLanguage() async {
    try {
      await _storage.delete(key: _keyLanguage);
    } catch (_) {
      // Graceful fallback
    }
  }
}

/// In-memory implementation of LanguageStorageService for unit tests or mocking.
class InMemoryLanguageStorageService implements LanguageStorageService {
  String? _language;

  InMemoryLanguageStorageService({String? initialLanguage})
      : _language = initialLanguage;

  @override
  Future<void> saveLanguage(String languageCode) async {
    _language = languageCode;
  }

  @override
  Future<String?> getLanguage() async {
    return _language;
  }

  @override
  Future<void> clearLanguage() async {
    _language = null;
  }
}
