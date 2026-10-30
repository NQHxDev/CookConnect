import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/market/presentation/pages/market_screen.dart';
import 'package:cookconnect/features/recipe/data/models/product_search_model.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/services/product_search_service.dart';
import 'package:cookconnect/features/recipe/data/services/recipe_data_service.dart';

class FakeMarketProductSearchService extends ProductSearchService {
  final List<ProductSearchItemDto> mockItems;
  final List<WhoCategoryDto> mockCategories;

  FakeMarketProductSearchService({
    required this.mockItems,
    this.mockCategories = const [],
  });

  @override
  Future<List<WhoCategoryDto>> getCategories({
    bool forceRefresh = false,
    String? token,
  }) async {
    return mockCategories;
  }

  @override
  Future<List<ProductSuggestionItemDto>> suggestProducts({
    required String query,
    int limit = 10,
    String? token,
  }) async {
    return mockItems
        .where((i) => i.productName.toLowerCase().contains(query.toLowerCase()))
        .map(
          (i) => ProductSuggestionItemDto(
            productId: i.productId,
            productName: i.productName,
            whoCategoryCode: i.whoCategoryCode,
            minPrice: i.minPrice,
            currency: i.currency,
          ),
        )
        .toList();
  }

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
          .where(
            (item) =>
                item.productName.toLowerCase().contains(query.toLowerCase()),
          )
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
  final testProduct1 = ProductSearchItemDto(
    productId: 'test_prod_1',
    supplierId: 'test_supp_1',
    productName: 'Cá Hồi tươi phi lê',
    whoCategoryCode: 'MEAT_FISH_POULTRY',
    minPrice: 150000,
    maxPrice: 150000,
    currency: 'VND',
    variants: [
      ProductVariantDto(
        variantId: 'var_salmon_1',
        productId: 'test_prod_1',
        variantName: 'Khay 500g',
        packSize: '500g',
        unit: 'khay',
        price: 150000,
      ),
    ],
  );

  final testProduct2 = ProductSearchItemDto(
    productId: 'test_prod_2',
    supplierId: 'test_supp_2',
    productName: 'Rau Muống Sạch',
    whoCategoryCode: 'VITAMIN_A_FRUITS_VEG',
    minPrice: 25000,
    maxPrice: 25000,
    currency: 'VND',
    variants: [
      ProductVariantDto(
        variantId: 'var_rau_1',
        productId: 'test_prod_2',
        variantName: 'Bó 500g',
        packSize: '500g',
        unit: 'bó',
        price: 25000,
      ),
    ],
  );

  final testCategories = [
    WhoCategoryDto(
      code: 'MEAT_FISH_POULTRY',
      name: 'Thịt, cá và gia cầm',
      order: 1,
    ),
    WhoCategoryDto(
      code: 'VITAMIN_A_FRUITS_VEG',
      name: 'Rau củ giàu Vitamin A',
      order: 2,
    ),
  ];

  setUp(() {
    ApiI18n.currentLanguage = ApiI18n.vi;
    // Clear and seed clean test items
    RecipeDataService.instance.clearAllShoppingItems();
    RecipeDataService.instance.addShoppingItems([
      ShoppingItem(
        id: 'test_item_1',
        name: 'Thịt bò xay',
        amount: '300g',
        recipeSource: 'Mì Ý sốt bò băm',
        price: 65000,
        isCompleted: false,
      ),
      ShoppingItem(
        id: 'test_item_2',
        name: 'Sốt cà chua Barilla',
        amount: '1 lọ 400g',
        recipeSource: 'Mì Ý sốt bò băm',
        price: 45000,
        isCompleted: true,
      ),
    ]);
  });

  tearDown(() {
    RecipeDataService.instance.clearAllShoppingItems();
  });

  testWidgets(
      'MarketScreen renders tabs, progress overview and items correctly',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeService = FakeMarketProductSearchService(
      mockItems: [testProduct1, testProduct2],
      mockCategories: testCategories,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MarketScreen(productSearchService: fakeService),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify AppBar title and tabs
    expect(find.text('Đi chợ CookConnect'), findsOneWidget);
    expect(find.text('Cần mua (1)'), findsOneWidget);
    expect(find.text('Chợ thực phẩm'), findsOneWidget);

    // Verify progress card
    expect(find.text('Tiến độ mua sắm'), findsOneWidget);
    expect(find.text('1/2 món (50%)'), findsOneWidget);

    // Verify items in the checklist
    expect(find.text('Thịt bò xay'), findsOneWidget);
    expect(find.text('Sốt cà chua Barilla'), findsOneWidget);
  });

  testWidgets('Toggling shopping item completion updates progress and state',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeService = FakeMarketProductSearchService(
      mockItems: [testProduct1, testProduct2],
      mockCategories: testCategories,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MarketScreen(productSearchService: fakeService),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Initially 1 uncompleted, 1 completed
    expect(find.text('1/2 món (50%)'), findsOneWidget);

    // Tap checkbox for 'Thịt bò xay'
    final uncompletedCheckbox = find.byType(Checkbox).first;
    await tester.tap(uncompletedCheckbox);
    await tester.pump(const Duration(milliseconds: 100));

    // Now all 2 items are completed (100%)
    expect(find.text('2/2 món (100%)'), findsOneWidget);
    expect(
      RecipeDataService.instance.shoppingList.every((i) => i.isCompleted),
      isTrue,
    );
  });

  testWidgets('Live staple chip from API adds real product to the shopping list',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeService = FakeMarketProductSearchService(
      mockItems: [testProduct1, testProduct2],
      mockCategories: testCategories,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MarketScreen(productSearchService: fakeService),
      ),
    );
    // Allow async _loadQuickStaples to complete
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final initialCount = RecipeDataService.instance.shoppingList.length;

    // Verify real product chip exists (from API)
    final salmonChip = find.text('+ Cá Hồi tươi phi lê');
    expect(salmonChip, findsOneWidget);
    await tester.tap(salmonChip);
    await tester.pump(const Duration(milliseconds: 100));

    // Shopping list length should increase by 1
    expect(RecipeDataService.instance.shoppingList.length, initialCount + 1);
    expect(find.text('Cá Hồi tươi phi lê'), findsOneWidget);
  });

  testWidgets(
      'Switching to Fresh Market tab displays product cards and enables adding to cart',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeService = FakeMarketProductSearchService(
      mockItems: [testProduct1, testProduct2],
      mockCategories: testCategories,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MarketScreen(productSearchService: fakeService),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Tap on 'Chợ thực phẩm' Tab
    final marketTab = find.text('Chợ thực phẩm');
    await tester.tap(marketTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify categories and search field
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Thịt & Cá'), findsOneWidget);
    expect(find.text('Rau & Củ'), findsOneWidget);

    // Verify product card is displayed from API
    expect(find.text('Cá Hồi tươi phi lê'), findsOneWidget);

    final countBefore = RecipeDataService.instance.shoppingList.length;

    // Tap '+' on the first product card
    final addIcon = find.byIcon(Iconsax.add).first;
    await tester.tap(addIcon);
    await tester.pump(const Duration(milliseconds: 100));

    // Shopping list count increases
    expect(RecipeDataService.instance.shoppingList.length, countBefore + 1);
  });

  testWidgets(
      'Searching on Fresh Market calls API and displays empty state when no matches (no placeholders)',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeService = FakeMarketProductSearchService(
      mockItems: [testProduct1, testProduct2],
      mockCategories: testCategories,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MarketScreen(productSearchService: fakeService),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Switch to Fresh Market tab
    await tester.tap(find.text('Chợ thực phẩm'));
    await tester.pumpAndSettle();

    // Verify initial product
    expect(find.text('Cá Hồi tươi phi lê'), findsOneWidget);

    // Enter non-matching query into search field
    final searchInput = find.byType(TextField).last;
    await tester.enterText(searchInput, 'MonAnKhongTonTai999');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify NO mock fallback items appear and clean empty state is shown
    expect(find.text('Không tìm thấy sản phẩm phù hợp'), findsOneWidget);
    expect(find.text('Cá Hồi tươi phi lê'), findsNothing);
  });
}
