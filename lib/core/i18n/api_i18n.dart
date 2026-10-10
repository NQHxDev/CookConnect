import 'locales/vi/vi.dart';
import 'locales/en/en.dart';

/// Internationalization and localization service for Server API response messages.
/// Extensible architecture for multi-language and modular per-domain dictionaries.
class ApiI18n {
  ApiI18n._();

  /// Current active language code (default: 'vi')
  static String currentLanguage = 'vi';

  /// Supported language keys
  static const String vi = 'vi';
  static const String en = 'en';

  /// Multi-language registry loaded from modular domain dictionaries
  static final Map<String, Map<String, String>> _translations = {
    vi: viTranslations,
    en: enTranslations,
  };

  /// Register or extend a language translation dictionary dynamically
  static void registerTranslations(String language, Map<String, String> messages) {
    if (_translations.containsKey(language)) {
      _translations[language]!.addAll(messages);
    } else {
      _translations[language] = Map<String, String>.from(messages);
    }
  }

  /// Translate an API code key to localized message.
  /// Falls back to defaultLanguage (vi) if translation not found in requested language.
  static String? translate(String key, {String? language}) {
    final lang = language ?? currentLanguage;
    final cleanKey = key.trim();
    if (cleanKey.isEmpty) return null;

    final langMap = _translations[lang] ?? _translations[vi]!;
    if (langMap.containsKey(cleanKey)) {
      return langMap[cleanKey];
    }

    // Fallback to Vietnamese dictionary if requested language didn't have the key
    if (lang != vi && _translations[vi]!.containsKey(cleanKey)) {
      return _translations[vi]![cleanKey];
    }

    return null;
  }

  /// Resolve an API response JSON into a localized friendly error message.
  static String resolveErrorMessage(
    Map<String, dynamic> json, {
    String? language,
    bool isRegister = false,
    String? defaultMessage,
  }) {
    final message = json['message']?.toString().trim() ?? '';
    final errorCode = json['errorCode']?.toString().trim() ?? '';
    final error = json['error']?.toString().trim() ?? '';

    // 1. Extract validation field errors first if any specific details are provided
    if (json['errors'] is List && (json['errors'] as List).isNotEmpty) {
      final firstError = (json['errors'] as List).first;
      if (firstError is Map<String, dynamic>) {
        final fieldMsg = firstError['message']?.toString();
        if (fieldMsg != null && !_isErrorCodeKey(fieldMsg)) {
          return fieldMsg;
        }
        final fieldCode = firstError['code']?.toString();
        if (fieldCode != null) {
          final translated = translate(fieldCode, language: language);
          if (translated != null) return translated;
        }
      }
    }

    // 2. Direct dictionary match against errorCode, message, or error
    if (errorCode.isNotEmpty) {
      final translated = translate(errorCode, language: language);
      if (translated != null) return translated;
    }

    if (message.isNotEmpty) {
      final translated = translate(message, language: language);
      if (translated != null) return translated;
    }

    if (error.isNotEmpty) {
      final translated = translate(error, language: language);
      if (translated != null) return translated;
    }

    // 3. Check if message/error is already a human-readable text (not a raw API key)
    if (message.isNotEmpty && !_isErrorCodeKey(message)) {
      return message;
    }
    if (error.isNotEmpty && !_isErrorCodeKey(error)) {
      return error;
    }

    // 4. Fallback message if provided
    if (defaultMessage != null && defaultMessage.isNotEmpty) {
      return defaultMessage;
    }

    // 5. Default generic error message per language
    final lang = language ?? currentLanguage;
    if (lang == en) {
      return isRegister
          ? 'Registration failed. Please try again.'
          : 'Request failed. Please try again later.';
    }
    return isRegister
        ? 'Gửi yêu cầu thất bại. Vui lòng thử lại.'
        : 'Yêu cầu không thành công. Vui lòng thử lại sau.';
  }

  /// Resolve an API response JSON into a localized friendly success message.
  static String resolveSuccessMessage(
    Map<String, dynamic> json, {
    String? language,
    String defaultMessage = 'Thành công',
  }) {
    final message = json['message']?.toString().trim() ?? '';
    if (message.isNotEmpty) {
      final translated = translate(message, language: language);
      if (translated != null) return translated;
      if (!_isErrorCodeKey(message)) return message;
    }
    return defaultMessage;
  }

  /// Checks whether a string represents a raw system error key (e.g., USER.FILE_REQUIRED, BAD_REQUEST)
  static bool isErrorCodeKey(String text) => _isErrorCodeKey(text);

  static bool _isErrorCodeKey(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains(' ')) return false;
    return RegExp(r'^[A-Z0-9_]+(\.[A-Z0-9_]+)+$').hasMatch(trimmed) ||
        RegExp(r'^[A-Z0-9_]{3,}$').hasMatch(trimmed);
  }
}
