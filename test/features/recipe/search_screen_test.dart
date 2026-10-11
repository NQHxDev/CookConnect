import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/recipe/presentation/pages/search_screen.dart';

void main() {
  setUp(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  tearDown(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
  });

  testWidgets('SearchScreen renders correctly with discover sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchScreen(),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.text('Xem thêm'), findsOneWidget);
    expect(find.text('Tìm kiếm phổ biến'), findsOneWidget);
    expect(find.text('Phở bò Hà Nội'), findsOneWidget);

    // Tap "Xem thêm" to expand recent searches
    await tester.tap(find.text('Xem thêm'));
    await tester.pumpAndSettle();

    expect(find.text('Xóa tất cả'), findsOneWidget);

    // Tap "Xóa tất cả" to clear recent searches
    await tester.tap(find.text('Xóa tất cả'));
    await tester.pumpAndSettle();

    expect(find.text('Phở bò'), findsNothing);
  });

  testWidgets('SearchScreen filters recipes when query is entered',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchScreen(),
      ),
    );

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Phở');
    await tester.pumpAndSettle();

    expect(find.textContaining('Tìm thấy'), findsOneWidget);
    expect(find.textContaining('Phở'), findsWidgets);
  });

  testWidgets('SearchScreen shows empty state for unmatched query',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchScreen(),
      ),
    );

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'xyz non existing recipe 12345');
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy món ăn nào'), findsOneWidget);
  });

  testWidgets('SearchScreen dynamically updates all UI strings on language change',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchScreen(),
      ),
    );

    // Vietnamese default
    expect(find.text('Tìm kiếm phổ biến'), findsOneWidget);
    expect(find.text('Gợi ý món hôm nay'), findsOneWidget);
    expect(find.text('Xem thêm'), findsOneWidget);
    expect(find.text('Tìm món ăn, nguyên liệu, đầu bếp...'), findsOneWidget);

    // Switch to English
    ApiI18n.currentLanguage = ApiI18n.en;
    await tester.pumpAndSettle();

    expect(find.text('Trending searches'), findsOneWidget);
    expect(find.text('Today\'s suggestions'), findsOneWidget);
    expect(find.text('See more'), findsOneWidget);
    expect(find.text('Search dishes, ingredients, chefs...'), findsOneWidget);

    // Expand recent searches in English
    await tester.tap(find.text('See more'));
    await tester.pumpAndSettle();

    expect(find.text('Clear all'), findsOneWidget);

    // Test search results counter in English
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Phở');
    await tester.pumpAndSettle();

    expect(find.textContaining('Found'), findsOneWidget);

    // Test empty state in English
    await tester.enterText(textField, 'non_existing_query_xyz');
    await tester.pumpAndSettle();

    expect(find.text('No dishes found'), findsOneWidget);
    expect(find.text('Try searching with another keyword or explore suggestions'), findsOneWidget);

    // Switch back to Vietnamese
    ApiI18n.currentLanguage = ApiI18n.vi;
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy món ăn nào'), findsOneWidget);
  });
}
