import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/recipe/presentation/pages/library_screen.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/recipe_detail_sheet.dart';

void main() {
  testWidgets('LibraryScreen renders tabs, search and handles interaction', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: LibraryScreen()));

    // Verify title
    expect(find.text('Thư viện ẩm thực'), findsOneWidget);

    // Verify tabs
    expect(find.textContaining('Yêu thích'), findsOneWidget);
    expect(find.textContaining('Bộ sưu tập'), findsOneWidget);
    expect(find.textContaining('Đã nấu & Xem'), findsOneWidget);
    expect(find.textContaining('Đi chợ'), findsOneWidget);

    // Switch to Collections tab
    await tester.tap(find.textContaining('Bộ sưu tập'));
    await tester.pumpAndSettle();
    expect(find.text('Bộ sưu tập của tôi'), findsOneWidget);

    // Switch to Cooked tab
    await tester.tap(find.textContaining('Đã nấu & Xem'));
    await tester.pumpAndSettle();
    expect(find.text('Thành tích bếp trưởng'), findsOneWidget);

    // Switch to Shopping List tab
    await tester.tap(find.textContaining('Đi chợ'));
    await tester.pumpAndSettle();
    expect(find.text('Tiến độ mua sắm thực phẩm'), findsOneWidget);
  });

  testWidgets('RecipeDetailSheet renders header, steps, and nutrition', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final sampleRecipe = Recipe(
      id: 'test_rec',
      title: 'Phở Bò Test',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=800',
      chefName: 'Chef Test',
      chefAvatar: '',
      rating: 4.8,
      reviewsCount: 10,
      cookTimeMinutes: 30,
      difficulty: 'Dễ',
      calories: 450,
      servings: 2,
      tags: ['#Pho', '#Test'],
      ingredients: [
        Ingredient(id: 'i1', name: 'Bánh phở tươi', amount: '200g'),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Chuẩn bị nước dùng',
          description: 'Hầm xương lấy nước',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                RecipeDetailSheet.show(context, recipe: sampleRecipe);
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Phở Bò Test'), findsOneWidget);
    expect(find.text('Bánh phở tươi'), findsOneWidget);
    expect(find.text('Bắt đầu nấu ngay'), findsOneWidget);

    // Switch to Cách làm tab
    await tester.tap(find.text('Cách làm'));
    await tester.pumpAndSettle();
    expect(find.text('Chuẩn bị nước dùng'), findsOneWidget);

    // Switch to Dinh dưỡng tab
    await tester.tap(find.text('Dinh dưỡng'));
    await tester.pumpAndSettle();
    expect(find.text('Tổng năng lượng ước tính'), findsOneWidget);
  });
}
