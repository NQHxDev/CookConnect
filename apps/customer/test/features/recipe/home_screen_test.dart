import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/recipe/presentation/pages/home_screen.dart';

void main() {
  setUp(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  tearDown(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  testWidgets('HomeScreen renders default Vietnamese feed tabs and icon tooltips', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Initial Vietnamese tabs
    expect(find.text('Bạn bè'), findsOneWidget);
    expect(find.text('Đã follow'), findsOneWidget);
    expect(find.text('Đề xuất'), findsOneWidget);

    // Tooltips
    expect(find.byTooltip('Phát trực tiếp'), findsOneWidget);
    expect(find.byTooltip('Tìm kiếm'), findsOneWidget);
  });

  testWidgets('HomeScreen reactively updates tabs and tooltips to English on language change', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('Bạn bè'), findsOneWidget);
    expect(find.text('Đã follow'), findsOneWidget);
    expect(find.text('Đề xuất'), findsOneWidget);

    // Change language to English
    ApiI18n.currentLanguage = ApiI18n.en;
    await tester.pump();

    // Verify English tabs
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Following'), findsOneWidget);
    expect(find.text('For You'), findsOneWidget);

    // English tooltips
    expect(find.byTooltip('Live'), findsOneWidget);
    expect(find.byTooltip('Search'), findsOneWidget);

    // Change back to Vietnamese
    ApiI18n.currentLanguage = ApiI18n.vi;
    await tester.pump();

    expect(find.text('Bạn bè'), findsOneWidget);
    expect(find.text('Đã follow'), findsOneWidget);
    expect(find.text('Đề xuất'), findsOneWidget);
  });

  testWidgets('HomeScreen handles tab switching smoothly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Initially 'Đề xuất' (index 2) is active
    expect(find.text('Đề xuất'), findsOneWidget);

    // Tap on 'Bạn bè' tab
    await tester.tap(find.text('Bạn bè'));
    await tester.pump(const Duration(milliseconds: 300));

    // Tap on 'Đã follow' tab
    await tester.tap(find.text('Đã follow'));
    await tester.pump(const Duration(milliseconds: 300));
  });
}
