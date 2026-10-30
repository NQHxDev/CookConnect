import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/recipe/data/models/product_search_model.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/services/product_search_service.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/add_ingredient_bottom_sheet.dart';

class FakeProductSearchService extends ProductSearchService {
  final List<ProductSearchItemDto> mockItems;

  FakeProductSearchService({required this.mockItems});

  @override
  Future<SearchProductsResponseDto> searchProducts({
    String? query,
    String? whoCategoryCode,
    String? supplierId,
    String? status,
    int limit = 20,
    int offset = 0,
    String? token,
  }) async {
    final filtered = query == null || query.isEmpty
        ? mockItems
        : mockItems
            .where((item) =>
                item.productName.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return SearchProductsResponseDto(
      items: filtered,
      total: filtered.length,
      limit: limit,
      offset: offset,
    );
  }
}

void main() {
  final sampleProduct = ProductSearchItemDto(
    productId: 'prod-wagu-01',
    supplierId: 'supp-01',
    productName: 'Thịt bò Wagu thượng hạng',
    whoCategoryCode: 'MEAT_FISH_POULTRY',
    minPrice: 500000,
    maxPrice: 500000,
    currency: 'VND',
    variants: [
      ProductVariantDto(
        variantId: 'var-01',
        productId: 'prod-wagu-01',
        variantName: 'Khay 500g',
        unit: 'khay',
        packSize: '500g',
        price: 500000,
      ),
    ],
  );

  testWidgets('AddIngredientBottomSheet displays search and supplier products',
      (WidgetTester tester) async {
    final fakeService = FakeProductSearchService(mockItems: [sampleProduct]);

    Ingredient? savedIngredient;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                savedIngredient = await AddIngredientBottomSheet.show(
                  context,
                  searchService: fakeService,
                );
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    );

    // Open sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Thêm nguyên liệu'), findsOneWidget);
    expect(find.text('Sản phẩm từ Nhà cung cấp'), findsOneWidget);
    expect(find.text('Thịt bò Wagu thượng hạng'), findsOneWidget);

    // Tap on product to select
    await tester.tap(find.text('Chọn'));
    await tester.pumpAndSettle();

    expect(find.text('Sản phẩm từ Nhà cung cấp'), findsWidgets);
    expect(find.text('Đổi / Hủy'), findsOneWidget);

    // Save
    await tester.tap(find.text('Thêm vào công thức'));
    await tester.pumpAndSettle();

    expect(savedIngredient, isNotNull);
    expect(savedIngredient!.name, 'Thịt bò Wagu thượng hạng');
    expect(savedIngredient!.productId, 'prod-wagu-01');
    expect(savedIngredient!.productVariantId, 'var-01');
    expect(savedIngredient!.price, 500000);
  });

  testWidgets('AddIngredientBottomSheet supports manual entry fallback',
      (WidgetTester tester) async {
    final fakeService = FakeProductSearchService(mockItems: []);

    Ingredient? savedIngredient;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                savedIngredient = await AddIngredientBottomSheet.show(
                  context,
                  searchService: fakeService,
                );
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Type a custom ingredient name
    final nameField = find.byType(TextField).first;
    await tester.enterText(nameField, 'Muối tiêu chanh');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Select a quick amount chip '100g'
    await tester.tap(find.text('100g'));
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('Thêm vào công thức'));
    await tester.pumpAndSettle();

    expect(savedIngredient, isNotNull);
    expect(savedIngredient!.name, 'Muối tiêu chanh');
    expect(savedIngredient!.amount, '100g');
    expect(savedIngredient!.productId, isNull);
  });
}
