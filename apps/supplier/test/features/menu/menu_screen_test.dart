import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/menu/data/models/mock_products.dart';
import 'package:cook_connect_seller/features/menu/data/models/seller_product_item.dart';
import 'package:cook_connect_seller/features/menu/data/services/product_api_service.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/add_product_screen.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/menu_screen.dart';
import 'package:shared_widgets/shared_widgets.dart';

void main() {
  testWidgets(
    'MenuScreen renders product management page with all 7 category tabs',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(MaterialApp(home: MenuScreen(initialProducts: initialMockProducts)));
      await tester.pumpAndSettle();

      // 1. Verify AppBar title
      expect(find.text('Quản lý sản phẩm'), findsOneWidget);

      // 2. Verify all 7 categories exist in the tab bar
      for (final cat in ProductCategoryType.values) {
        expect(find.text(cat.label), findsWidgets);
      }

      // 3. Verify horizontal scrolling to reach later tabs
      final horizontalScrollable = find.byType(SingleChildScrollView).first;
      await tester.drag(horizontalScrollable, const Offset(-300, 0));
      await tester.pumpAndSettle();

      final draftTab = find.text('Bản nháp');
      expect(draftTab, findsOneWidget);

      // 4. Verify three-lines menu icon button at the end
      final menuButton = find.byKey(const ValueKey('all_categories_button'));
      expect(menuButton, findsOneWidget);

      // 5. Tap the three-lines menu button to open All Categories modal
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      expect(find.text('Tất cả danh mục sản phẩm'), findsOneWidget);

      // 6. Select "Còn ít" from the bottom sheet
      final lowStockOption = find.text(
        'Sản phẩm có tồn kho thấp, cần nhập thêm hàng',
      );
      expect(lowStockOption, findsOneWidget);
      await tester.tap(lowStockOption);
      await tester.pumpAndSettle();

      // Verify modal is closed and "Còn ít" is now active
      expect(find.text('Tất cả danh mục sản phẩm'), findsNothing);
      expect(
        find.text('Khô bò sợi cay đặc biệt Tây Bắc (Hũ 250g)'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'MenuScreen allows switching tabs by direct horizontal tab tapping',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(MaterialApp(home: MenuScreen(initialProducts: initialMockProducts)));
      await tester.pumpAndSettle();

      // Tap "Đã vô hiệu hóa"
      final disabledTab = find.text('Đã vô hiệu hóa').first;
      await tester.tap(disabledTab);
      await tester.pumpAndSettle();

      // Verify items in "Đã vô hiệu hóa" are visible
      expect(find.text('Trà sen Tây Hồ ướp bông tự nhiên'), findsOneWidget);
    },
  );

  testWidgets('MenuScreen search filter works as expected', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MaterialApp(home: MenuScreen(initialProducts: initialMockProducts)));
    await tester.pumpAndSettle();

    // Initially contains Bánh mì bơ tỏi
    expect(
      find.text('Bánh mì bơ tỏi phô mai Hàn Quốc (Set 2 bánh)'),
      findsOneWidget,
    );

    // Enter search text
    final searchInput = find.byType(TextField).first;
    await tester.enterText(searchInput, 'Bánh mì');
    await tester.pumpAndSettle();

    // Only Bánh mì matches
    expect(
      find.text('Bánh mì bơ tỏi phô mai Hàn Quốc (Set 2 bánh)'),
      findsOneWidget,
    );
    expect(find.text('Khô gà lá chanh thượng hạng hộp 300g'), findsNothing);
  });

  testWidgets('MenuScreen quick edit stock and price dialog', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MaterialApp(home: MenuScreen(initialProducts: initialMockProducts)));
    await tester.pumpAndSettle();

    // Tap "Kho & Giá" on the first card
    final editStockBtn = find.text('Kho & Giá').first;
    await tester.tap(editStockBtn);
    await tester.pumpAndSettle();

    // Dialog appears
    expect(find.text('Cập nhật nhanh kho & giá'), findsOneWidget);

    // Click "Lưu thay đổi"
    await tester.tap(find.text('Lưu thay đổi'));
    await tester.pumpAndSettle();

    expect(find.text('Cập nhật nhanh kho & giá'), findsNothing);
  });

  testWidgets(
    'MenuScreen integrates shared CustomSliverRefreshControl and pull-to-refresh triggers smoothly',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockClient = MockClient((_) async => http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'items': [
              {
                'productId': 'prod-1',
                'supplierId': 'supp-1',
                'whoCategoryCode': 'STAPLES',
                'productName': 'Bánh mì bơ tỏi phô mai Hàn Quốc (Set 2 bánh)',
                'description': 'Mô tả',
                'images': [],
                'status': 'ACTIVE',
                'moderationStatus': 'APPROVED',
                'variants': [
                  {
                    'variantId': 'var-1',
                    'productId': 'prod-1',
                    'sku': 'BM-01',
                    'variantName': 'Set 2 bánh',
                    'unit': 'set',
                    'price': 45000.0,
                    'stockQuantity': 50,
                    'reservedQuantity': 0,
                    'lowStockThreshold': 5,
                    'isDefault': true,
                    'status': 'AVAILABLE',
                  }
                ],
                'version': 1,
              }
            ],
            'total': 1,
          }
        }),
        200,
        headers: {'content-type': 'application/json'},
      ));
      final mockService = ProductApiService(apiClient: ApiClient(client: mockClient));

      final mockTokenStorage = InMemoryTokenStorageService();
      await mockTokenStorage.saveTokens(
        AuthTokens(accessToken: 'mock-token', refreshToken: 'mock-refresh'),
      );

      await tester.pumpWidget(MaterialApp(
        home: MenuScreen(
          initialProducts: initialMockProducts,
          productApiService: mockService,
          tokenStorage: mockTokenStorage,
        ),
      ));
      await tester.pumpAndSettle();

      // Verify CustomSliverRefreshControl is embedded in CustomScrollView
      expect(
        find.byType(CustomSliverRefreshControl, skipOffstage: false),
        findsOneWidget,
      );

      // Find the vertical scrollable (CustomScrollView)
      final verticalScrollable = find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      );

      // Pull down to trigger refresh
      await tester.drag(verticalScrollable, const Offset(0, 150));
      await tester.pump(const Duration(milliseconds: 50));

      // CustomRefreshBadge should be present and refreshing
      expect(
        find.byWidgetPredicate(
          (w) => w is CustomRefreshBadge && w.isRefreshing,
        ),
        findsOneWidget,
      );

      // Let the refresh complete
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Products are still intact after refresh
      expect(
        find.text('Bánh mì bơ tỏi phô mai Hàn Quốc (Set 2 bánh)'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Tapping add button navigates to AddProductScreen with food categories, multiple SKUs and real image requirements',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(MaterialApp(home: MenuScreen(initialProducts: initialMockProducts)));
      await tester.pumpAndSettle();

      // Find '+' button in AppBar
      final addBtn = find.byTooltip('Thêm sản phẩm');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Verify AddProductScreen full page is opened
      expect(find.byType(AddProductScreen), findsOneWidget);
      expect(find.text('Thêm sản phẩm mới'), findsOneWidget);
      expect(find.text('Xét duyệt'), findsOneWidget);
      expect(find.text('Hình ảnh sản phẩm *'), findsOneWidget);
      expect(find.text('0/5 ảnh tối thiểu'), findsOneWidget);

      // Food basic info
      expect(find.text('Thông tin thực phẩm'), findsOneWidget);
      expect(find.text('Tên thực phẩm *'), findsOneWidget);
      expect(find.text('Danh mục thực phẩm *'), findsOneWidget);

      // SKU & Pricing Section
      expect(find.text('Phân loại & Giá bán'), findsOneWidget);
      expect(find.text('Duy nhất 1 loại'), findsOneWidget);
      expect(find.text('Nhiều phân loại'), findsOneWidget);

      // Tap Food Category to verify modal bottom sheet opens with food ingredient categories
      final categoryField = find.byKey(const Key('category_picker_field'));
      expect(categoryField, findsOneWidget);
      expect(find.text('Chọn danh mục thực phẩm'), findsOneWidget);
      await tester.tap(categoryField);
      await tester.pumpAndSettle();

      // Verify category modal bottom sheet has food categories
      expect(find.text('Chọn danh mục thực phẩm'), findsNWidgets(2));
      expect(find.text('Lương thực chính (Tinh bột)'), findsOneWidget);
      expect(find.text('Thịt, cá và gia cầm'), findsOneWidget);
      expect(find.text('Trứng'), findsOneWidget);
      expect(find.text('Các loại đậu và hạt'), findsOneWidget);

      // Select 'Trứng'
      await tester.tap(find.text('Trứng'));
      await tester.pumpAndSettle();

      // Category modal closes and selection updates
      expect(find.text('Chọn danh mục thực phẩm'), findsNothing);
      expect(find.text('Trứng'), findsOneWidget);

      // Switch to 'Nhiều phân loại (SKU)'
      await tester.tap(find.text('Nhiều phân loại'));
      await tester.pumpAndSettle();

      // Verify Multiple SKUs UI elements are displayed
      expect(find.text('Phân loại #1'), findsOneWidget);
      expect(find.text('Phân loại #2'), findsOneWidget);
      expect(find.text('+ Thêm phân loại mới'), findsOneWidget);

      // Verify dirty check when navigating back with edits
      final backBtn = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backBtn, findsOneWidget);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      // Dialog asks to save draft
      expect(find.text('Lưu bản nháp?'), findsOneWidget);

      // Choose discard/leave
      await tester.tap(find.text('Không lưu'));
      await tester.pumpAndSettle();

      expect(find.text('Quản lý sản phẩm'), findsOneWidget);
    },
  );

  testWidgets(
    'AddProductScreen requires selecting a category before submission',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(home: AddProductScreen()));
      await tester.pumpAndSettle();

      // Verify initial state has no category selected
      expect(find.text('Chọn danh mục thực phẩm'), findsOneWidget);

      // Verify 'Xét duyệt' button is inactive initially
      final initialSubmitBtn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Xét duyệt'),
      );
      expect(initialSubmitBtn.onPressed, isNull);

      // Fill valid name and price
      await tester.enterText(
        find.byType(TextFormField).first,
        'Thịt thăn bò Úc nhập khẩu',
      );
      await tester.enterText(find.byType(TextFormField).at(2), '250000');
      await tester.pumpAndSettle();

      // 'Xét duyệt' button remains inactive because category, images and description are incomplete
      final stillDisabledBtn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Xét duyệt'),
      );
      expect(stillDisabledBtn.onPressed, isNull);

      // Tap category picker and choose 'Thịt, cá và gia cầm'
      final picker = find.byKey(const Key('category_picker_field'));
      await tester.tap(picker);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Thịt, cá và gia cầm'));
      await tester.pumpAndSettle();

      // Category is selected
      expect(find.text('Thịt, cá và gia cầm'), findsOneWidget);
    },
  );

  group('Real API call integration tests for MenuScreen', () {
    testWidgets(
      'MenuScreen calls ProductApiService.listProducts and renders real products from backend',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final mockClient = MockClient((request) async {
          expect(request.url.path, '/api/v1/products');
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'items': [
                  {
                    'productId': 'prod-real-123',
                    'supplierId': 'supp-real-456',
                    'whoCategoryCode': 'STAPLES',
                    'productName': 'Gạo ST25 Sóc Trăng Đạt Chuẩn GACP Thật',
                    'productSlug': 'gao-st25-soc-trang',
                    'description': 'Gạo ST25 chính hãng từ API server',
                    'images': ['https://cdn.cookconnect.vn/rice.jpg'],
                    'status': 'ACTIVE',
                    'moderationStatus': 'APPROVED',
                    'variants': [
                      {
                        'variantId': 'var-real-1',
                        'productId': 'prod-real-123',
                        'sku': 'ST25-REAL-5KG',
                        'variantName': 'Bao 5kg thật',
                        'unit': 'bao',
                        'price': 195000.0,
                        'currency': 'VND',
                        'stockQuantity': 100,
                        'reservedQuantity': 0,
                        'lowStockThreshold': 10,
                        'isDefault': true,
                        'status': 'AVAILABLE',
                      }
                    ],
                    'version': 1,
                    'createdAt': '2026-10-28T00:00:00.000Z',
                    'updatedAt': '2026-10-28T00:00:00.000Z',
                  }
                ],
                'total': 1,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final mockTokenStorage = InMemoryTokenStorageService();
        await mockTokenStorage.saveTokens(
          AuthTokens(accessToken: 'mock-token', refreshToken: 'mock-refresh'),
        );

        final service = ProductApiService(apiClient: ApiClient(client: mockClient));

        await tester.pumpWidget(
          MaterialApp(
            home: MenuScreen(
              productApiService: service,
              tokenStorage: mockTokenStorage,
            ),
          ),
        );

        // Allow future to finish and setState to rebuild
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Real product name is rendered!
        expect(find.text('Gạo ST25 Sóc Trăng Đạt Chuẩn GACP Thật'), findsOneWidget);
        expect(find.text('1 sản phẩm'), findsOneWidget);
      },
    );

    testWidgets(
      'MenuScreen shows empty state when backend returns 0 products without any mock data',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final mockClient = MockClient((request) async {
          expect(request.url.path, '/api/v1/products');
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'items': [],
                'total': 0,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final mockTokenStorage = InMemoryTokenStorageService();
        await mockTokenStorage.saveTokens(
          AuthTokens(accessToken: 'mock-token', refreshToken: 'mock-refresh'),
        );

        final service = ProductApiService(apiClient: ApiClient(client: mockClient));

        await tester.pumpWidget(
          MaterialApp(
            home: MenuScreen(
              productApiService: service,
              tokenStorage: mockTokenStorage,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Empty state is rendered!
        expect(find.text('Không có sản phẩm "Trên kệ"'), findsOneWidget);
        expect(find.text('Thêm sản phẩm ngay'), findsOneWidget);
        // None of the mock items exist
        expect(find.text('Bánh mì bơ tỏi phô mai Hàn Quốc (Set 2 bánh)'), findsNothing);
      },
    );

    testWidgets(
      'When refresh fails with 429 Too Many Requests, existing products are retained on screen without blanking out',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final mockClient = MockClient((request) async {
          // Server rate-limits refresh calls with 429 Too Many Requests!
          return http.Response(
            jsonEncode({
              'success': false,
              'statusCode': 429,
              'errorCode': 'COMMON.TOO_MANY_REQUESTS',
              'message': 'Too Many Requests',
            }),
            429,
            headers: {'content-type': 'application/json'},
          );
        });

        final mockTokenStorage = InMemoryTokenStorageService();
        final service = ProductApiService(apiClient: ApiClient(client: mockClient));

        final existingProduct = SellerProductItem(
          id: 'prod-on-shelf-1',
          name: 'Gạo Lứt Huyết Rồng Trên Kệ',
          sku: 'SKU-RICE-01',
          price: 150000,
          stock: 50,
          categoryType: ProductCategoryType.onShelf,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MenuScreen(
              productApiService: service,
              tokenStorage: mockTokenStorage,
              initialProducts: [existingProduct],
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Product is visible on active "Trên kệ" tab!
        expect(find.text('Gạo Lứt Huyết Rồng Trên Kệ'), findsOneWidget);

        // Now simulate pull to refresh or reload that gets blocked with 429
        final menuState = tester.state<MenuScreenState>(find.byType(MenuScreen));
        // Force refresh call which will hit 429
        await menuState.debugReloadProducts();

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // CRITICAL CHECK: Existing product is STILL on screen! UI is NOT blank!
        expect(find.text('Gạo Lứt Huyết Rồng Trên Kệ'), findsOneWidget);
        // SnackBar informs the user about rate limit while preserving data
        expect(find.textContaining('429'), findsOneWidget);
      },
    );
  });
}
