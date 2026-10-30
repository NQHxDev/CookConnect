import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/recipe/data/models/product_search_model.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/services/product_search_service.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/add_shopping_item_bottom_sheet.dart';

class FakeShoppingProductSearchService extends ProductSearchService {
  final List<ProductSearchItemDto> mockItems;

  FakeShoppingProductSearchService({required this.mockItems});

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
    var filtered = mockItems;
    if (query != null && query.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item.productName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    if (whoCategoryCode != null && whoCategoryCode.isNotEmpty) {
      filtered = filtered
          .where((item) => item.whoCategoryCode == whoCategoryCode)
          .toList();
    }

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
    productId: 'prod-rau-01',
    supplierId: 'supp-01',
    productName: 'Rau Muống Sạch Thủy Canh',
    whoCategoryCode: 'VITAMIN_A_FRUITS_VEG',
    minPrice: 35000,
    maxPrice: 35000,
    currency: 'VND',
    variants: [
      ProductVariantDto(
        variantId: 'var-01',
        productId: 'prod-rau-01',
        variantName: 'Bó 500g',
        unit: 'bó',
        packSize: '500g',
        price: 35000,
      ),
    ],
  );

  testWidgets('AddShoppingItemBottomSheet displays products, handles search and selection',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeService =
        FakeShoppingProductSearchService(mockItems: [sampleProduct]);

    ShoppingItem? selectedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selectedResult = await AddShoppingItemBottomSheet.show(
                  context,
                  searchService: fakeService,
                );
              },
              child: const Text('Open Shopping Sheet'),
            ),
          ),
        ),
      ),
    );

    // Open sheet
    await tester.tap(find.text('Open Shopping Sheet'));
    await tester.pumpAndSettle();

    // Verify header and UI
    expect(find.text('Thêm thực phẩm đi chợ'), findsOneWidget);
    expect(find.text('Rau Muống Sạch Thủy Canh'), findsOneWidget);

    // Select the product
    await tester.tap(find.text('Rau Muống Sạch Thủy Canh'));
    await tester.pumpAndSettle();

    // Verify amount is auto-populated from variant packSize
    expect(find.text('500g'), findsWidgets);

    // Tap submit button
    await tester.tap(find.text('Thêm vào giỏ đi chợ'));
    await tester.pumpAndSettle();

    expect(selectedResult, isNotNull);
    expect(selectedResult!.name, 'Rau Muống Sạch Thủy Canh');
    expect(selectedResult!.amount, '500g');
    expect(selectedResult!.price, 35000);
    expect(selectedResult!.productId, 'prod-rau-01');
  });

  testWidgets('AddShoppingItemBottomSheet allows manual custom item addition',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeService =
        FakeShoppingProductSearchService(mockItems: [sampleProduct]);

    ShoppingItem? customResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                customResult = await AddShoppingItemBottomSheet.show(
                  context,
                  searchService: fakeService,
                );
              },
              child: const Text('Open Custom Shopping Sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Custom Shopping Sheet'));
    await tester.pumpAndSettle();

    // Enter custom name
    final nameFinder =
        find.widgetWithText(TextField, 'Ví dụ: Thịt bò tươi, Cà chua bi, Sữa chua...');
    await tester.enterText(nameFinder, 'Trứng gà ta thảo mộc');

    // Tap quick amount chip '1 vỉ'
    await tester.tap(find.text('1 vỉ'));
    await tester.pumpAndSettle();

    // Submit
    await tester.tap(find.text('Thêm vào giỏ đi chợ'));
    await tester.pumpAndSettle();

    expect(customResult, isNotNull);
    expect(customResult!.name, 'Trứng gà ta thảo mộc');
    expect(customResult!.amount, '1 vỉ');
    expect(customResult!.recipeSource, 'Tự thêm');
  });
}
