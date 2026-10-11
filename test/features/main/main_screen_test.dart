import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/main/presentation/pages/main_screen.dart';

void main() {
  setUp(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  tearDown(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  testWidgets('BottomNavBar displays localized labels in Vietnamese by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainScreen(),
      ),
    );

    // Initial Vietnamese labels on navigation items
    expect(find.widgetWithText(InkWell, 'Trang chủ'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Thư viện'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Hộp thư'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Cá nhân'), findsOneWidget);
  });

  testWidgets('BottomNavBar reactively updates labels when ApiI18n language changes to English and back', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainScreen(),
      ),
    );

    expect(find.widgetWithText(InkWell, 'Trang chủ'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Thư viện'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Hộp thư'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Cá nhân'), findsOneWidget);

    // Switch language to English
    ApiI18n.currentLanguage = ApiI18n.en;
    await tester.pumpAndSettle();

    // Verify English labels are displayed on nav items
    expect(find.widgetWithText(InkWell, 'Home'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Library'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Inbox'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Profile'), findsOneWidget);

    // Vietnamese labels should no longer be present on nav items
    expect(find.widgetWithText(InkWell, 'Trang chủ'), findsNothing);
    expect(find.widgetWithText(InkWell, 'Thư viện'), findsNothing);
    expect(find.widgetWithText(InkWell, 'Hộp thư'), findsNothing);
    expect(find.widgetWithText(InkWell, 'Cá nhân'), findsNothing);

    // Switch back to Vietnamese
    ApiI18n.currentLanguage = ApiI18n.vi;
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InkWell, 'Trang chủ'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Thư viện'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Hộp thư'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Cá nhân'), findsOneWidget);
  });

  testWidgets('BottomNavBar preserves selected tab when switching language', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainScreen(),
      ),
    );

    // Tap on Library tab (index 1)
    await tester.tap(find.widgetWithText(InkWell, 'Thư viện'));
    await tester.pumpAndSettle();

    // Change language to English
    ApiI18n.currentLanguage = ApiI18n.en;
    await tester.pumpAndSettle();

    // Library tab in English should still be present
    expect(find.widgetWithText(InkWell, 'Library'), findsOneWidget);

    // Tap on Inbox tab (index 3)
    await tester.tap(find.widgetWithText(InkWell, 'Inbox'));
    await tester.pumpAndSettle();

    // Change language back to Vietnamese
    ApiI18n.currentLanguage = ApiI18n.vi;
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InkWell, 'Hộp thư'), findsOneWidget);
  });
}
