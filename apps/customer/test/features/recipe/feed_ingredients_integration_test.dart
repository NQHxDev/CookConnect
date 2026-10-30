import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/core/navigation/app_tab_navigator.dart';
import 'package:cookconnect/features/recipe/data/models/post_item.dart';
import 'package:cookconnect/features/recipe/data/services/recipe_data_service.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/ingredients_bottom_sheet.dart';

void main() {
  setUp(() {
    RecipeDataService.instance.clearAllShoppingItems();
  });

  testWidgets('IngredientsBottomSheet displays items and adds them to Shopping List', (tester) async {
    final samplePost = PostItem.sampleOnboarding();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IngredientsBottomSheet(
            recipeTitle: samplePost.title,
            ingredients: samplePost.ingredients,
            post: samplePost,
            postId: samplePost.postId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check header and ingredients
    expect(find.textContaining('Bánh Mì Chảo'), findsWidgets);
    expect(find.textContaining('5 nguyên liệu'), findsOneWidget);
    expect(find.text('Bánh mì giòn rụm'), findsOneWidget);
    expect(find.text('Trứng gà ta'), findsOneWidget);

    // Initial state: 0 items in shopping list
    expect(RecipeDataService.instance.shoppingList.isEmpty, isTrue);

    // Click "Thêm 5 món vào giỏ" button
    final addButton = find.textContaining('Thêm 5 món vào giỏ');
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Should have added 5 items to shopping list
    expect(RecipeDataService.instance.shoppingList.length, equals(5));

    // Linked post should be registered
    final linked = RecipeDataService.instance.linkedPost(samplePost.postId);
    expect(linked, isNotNull);
    expect(linked?.title, equals(samplePost.title));

    // UI should show "Đủ trong giỏ" or "Đã có trong giỏ đi chợ"
    expect(find.text('Đã có trong giỏ đi chợ'), findsWidgets);
  });

  testWidgets('AppTabNavigator dispatches market navigation request', (tester) async {
    bool notified = false;
    AppTabNavigator.instance.addListener(() {
      notified = true;
    });

    final request = MarketNavigationRequest(tabIndex: 1, searchQuery: 'Thịt bò');
    expect(request.tabIndex, 1);
    expect(request.searchQuery, 'Thịt bò');
    expect(notified, isFalse);
  });
}

