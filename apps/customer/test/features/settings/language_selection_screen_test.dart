import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/settings/presentation/pages/language/language_selection_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/settings_screen.dart';

void main() {
  setUp(() {
    ApiI18n.currentLanguage = 'vi';
  });

  tearDown(() {
    ApiI18n.currentLanguage = 'vi';
  });

  testWidgets('LanguageSelectionScreen renders AppBar, category headers, active and disabled languages', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LanguageSelectionScreen(),
      ),
    );

    // Verify AppBar header
    expect(find.text('Ngôn ngữ'), findsOneWidget);

    // Verify category headers
    expect(find.text('Ngôn ngữ khả dụng'), findsOneWidget);
    expect(find.text('Sắp ra mắt'), findsOneWidget);

    // Verify selectable languages
    expect(find.text('Tiếng Việt'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    // Verify disabled languages
    expect(find.text('中文 (Chinese)'), findsOneWidget);
    expect(find.text('日本語 (Japanese)'), findsOneWidget);
    expect(find.text('한국어 (Korean)'), findsOneWidget);

    // Verify "Sắp có" badges for disabled languages
    expect(find.text('Sắp có'), findsNWidgets(3));

    // Initially Tiếng Việt is selected
    expect(ApiI18n.currentLanguage, 'vi');

    // Tap on English
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // Verify language changed to English and UI text updated
    expect(ApiI18n.currentLanguage, 'en');
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Available languages'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.text('Soon'), findsNWidgets(3));

    // Tap on a disabled language (e.g. Chinese) should not change language
    await tester.tap(find.text('中文 (Chinese)'));
    await tester.pumpAndSettle();

    expect(ApiI18n.currentLanguage, 'en');

    // Switch back to Vietnamese
    await tester.tap(find.text('Tiếng Việt'));
    await tester.pumpAndSettle();

    expect(ApiI18n.currentLanguage, 'vi');
    expect(find.text('Ngôn ngữ'), findsOneWidget);
  });

  testWidgets('Navigating from SettingsScreen to LanguageSelectionScreen works properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    // Scroll down to Tùy chọn section
    await tester.drag(find.byType(ListView), const Offset(0, -650));
    await tester.pumpAndSettle();

    final languageItemFinder = find.widgetWithText(InkWell, 'Ngôn ngữ');
    expect(languageItemFinder, findsOneWidget);

    await tester.tap(languageItemFinder);
    await tester.pumpAndSettle();

    // Verify LanguageSelectionScreen is displayed
    expect(find.byType(LanguageSelectionScreen), findsOneWidget);

    // Back to SettingsScreen
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
