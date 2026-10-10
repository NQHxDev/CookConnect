import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/recipe/presentation/pages/search_screen.dart';

void main() {
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
}
