import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/core/storage/language_storage_service.dart';

void main() {
  group('LanguageStorageService Tests', () {
    test('InMemoryLanguageStorageService saves, retrieves, and clears language', () async {
      final storage = InMemoryLanguageStorageService();

      expect(await storage.getLanguage(), isNull);

      await storage.saveLanguage('en');
      expect(await storage.getLanguage(), 'en');

      await storage.saveLanguage('vi');
      expect(await storage.getLanguage(), 'vi');

      await storage.clearLanguage();
      expect(await storage.getLanguage(), isNull);
    });

    test('SecureLanguageStorageService gracefully handles reads/writes without throwing', () async {
      final storage = SecureLanguageStorageService();
      // On non-platform headless test environments, should not crash
      expect(await storage.getLanguage(), isNull);
    });
  });

  group('ApiI18n Storage Integration & App Restart Simulation Tests', () {
    late InMemoryLanguageStorageService storage;

    setUp(() {
      storage = InMemoryLanguageStorageService();
      ApiI18n.configure(storage: storage);
      ApiI18n.resetForTesting(defaultLang: ApiI18n.vi);
    });

    tearDown(() {
      ApiI18n.configure(storage: SecureLanguageStorageService());
      ApiI18n.resetForTesting(defaultLang: ApiI18n.vi);
    });

    test('ApiI18n.init falls back to default "vi" when storage is empty', () async {
      await ApiI18n.init(storage: storage);

      expect(ApiI18n.currentLanguage, ApiI18n.vi);
      expect(ApiI18n.languageNotifier.value, ApiI18n.vi);
    });

    test('ApiI18n.init restores previously saved "en" language on app launch', () async {
      await storage.saveLanguage('en');

      await ApiI18n.init(storage: storage);

      expect(ApiI18n.currentLanguage, ApiI18n.en);
      expect(ApiI18n.languageNotifier.value, ApiI18n.en);
    });

    test('ApiI18n.init ignores unsupported saved language code and keeps valid default', () async {
      await storage.saveLanguage('unsupported_lang');

      await ApiI18n.init(storage: storage);

      expect(ApiI18n.currentLanguage, ApiI18n.vi);
      expect(ApiI18n.languageNotifier.value, ApiI18n.vi);
    });

    test('Setting ApiI18n.currentLanguage automatically persists to storage', () async {
      ApiI18n.currentLanguage = ApiI18n.en;

      expect(await storage.getLanguage(), 'en');
    });

    test('ApiI18n.setLanguage persists and awaits completion', () async {
      await ApiI18n.setLanguage(ApiI18n.en);

      expect(ApiI18n.currentLanguage, ApiI18n.en);
      expect(await storage.getLanguage(), 'en');
    });

    test('Simulating app cold restart preserves selected language across lifecycle', () async {
      // 1. User sets language to English in settings
      await ApiI18n.setLanguage(ApiI18n.en);
      expect(ApiI18n.currentLanguage, 'en');
      expect(await storage.getLanguage(), 'en');

      // 2. App process dies (reset in-memory static state to initial default 'vi')
      ApiI18n.resetForTesting(defaultLang: ApiI18n.vi);
      expect(ApiI18n.currentLanguage, 'vi');

      // 3. User relaunches app -> main() calls ApiI18n.init()
      await ApiI18n.init(storage: storage);

      // 4. Stored language 'en' is successfully restored
      expect(ApiI18n.currentLanguage, 'en');
      expect(ApiI18n.languageNotifier.value, 'en');
    });
  });
}
