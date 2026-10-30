import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/menu/data/models/seller_product_item.dart';
import 'package:cook_connect_seller/features/menu/data/services/product_api_service.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/add_product_screen.dart';
import 'package:cook_connect_seller/features/menu/data/services/product_background_queue_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleProductItemJson = {
    'productId': 'prod-uuid-123',
    'supplierId': 'supp-uuid-456',
    'whoCategoryCode': 'STAPLES',
    'productName': 'Gạo ST25 Sóc Trăng',
    'productSlug': 'gao-st25-soc-trang',
    'description': 'Gạo hữu cơ đạt chuẩn',
    'origin': 'Sóc Trăng',
    'storageCondition': 'Khô ráo',
    'shelfLifeDays': 180,
    'images': ['https://cdn.cookconnect.vn/products/rice1.jpg'],
    'status': 'DRAFT',
    'moderationStatus': 'PENDING_APPROVAL',
    'rejectionReason': null,
    'variants': [
      {
        'variantId': 'var-1',
        'productId': 'prod-uuid-123',
        'sku': 'ST25-5KG',
        'variantName': 'Túi 5kg',
        'unit': 'túi',
        'packSize': '5kg',
        'price': 180000.0,
        'originalPrice': 200000.0,
        'currency': 'VND',
        'stockQuantity': 50,
        'reservedQuantity': 0,
        'lowStockThreshold': 10,
        'isDefault': true,
        'status': 'AVAILABLE',
      }
    ],
    'version': 1,
    'createdAt': '2026-10-28T00:00:00.000Z',
    'updatedAt': '2026-10-28T00:00:00.000Z',
  };

  group('ProductApiService Unit Tests', () {
    test('1. submitProductForReview sends POST to submit-review endpoint', () async {
      String? recordedPath;
      String? recordedAuth;

      final mockClient = MockClient((request) async {
        recordedPath = request.url.path;
        recordedAuth = request.headers['Authorization'];
        return http.Response(
          jsonEncode({
            'success': true,
            'data': sampleProductItemJson,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ProductApiService(apiClient: ApiClient(client: mockClient));
      final result = await service.submitProductForReview(
        token: 'test-token-xyz',
        productId: 'prod-uuid-123',
      );

      expect(recordedPath, '/api/v1/products/prod-uuid-123/submit-review');
      expect(recordedAuth, 'Bearer test-token-xyz');
      expect(result.productId, 'prod-uuid-123');
      expect(result.moderationStatus, 'PENDING_APPROVAL');
    });

    test('2. uploadMediaImage returns remote URL immediately if already http', () async {
      final service = ProductApiService();
      final url = await service.uploadMediaImage(
        token: 'token',
        imagePath: 'https://cdn.cookconnect.vn/avatar.jpg',
      );
      expect(url, 'https://cdn.cookconnect.vn/avatar.jpg');
    });

    test('3. uploadMultipleImages calls progress callback correctly', () async {
      final progressList = <int>[];
      final service = ProductApiService();
      final urls = await service.uploadMultipleImages(
        token: 'token',
        imagePaths: [
          'https://cdn.cookconnect.vn/1.jpg',
          'https://cdn.cookconnect.vn/2.jpg',
          'https://cdn.cookconnect.vn/3.jpg',
        ],
        onProgress: (cur, tot) {
          progressList.add(cur);
        },
      );

      expect(urls.length, 3);
      expect(progressList, [1, 2, 3]);
    });

    test('4. updateProduct sends PATCH with UpdateProductDto body', () async {
      String? recordedMethod;
      String? recordedPath;
      Map<String, dynamic>? recordedBody;

      final mockClient = MockClient((request) async {
        recordedMethod = request.method;
        recordedPath = request.url.path;
        recordedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'success': true,
            'data': sampleProductItemJson,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ProductApiService(apiClient: ApiClient(client: mockClient));
      final result = await service.updateProduct(
        token: 'test-token',
        productId: 'prod-uuid-123',
        dto: const UpdateProductDto(
          productName: 'Tên mới cập nhật',
          whoCategoryCode: 'STAPLES',
        ),
      );

      expect(recordedMethod, 'PATCH');
      expect(recordedPath, '/api/v1/products/prod-uuid-123');
      expect(recordedBody?['productName'], 'Tên mới cập nhật');
      expect(recordedBody?['whoCategoryCode'], 'STAPLES');
      expect(result.productName, 'Gạo ST25 Sóc Trăng');
    });

    test('5. listProducts sends query parameters and deserializes items', () async {
      Map<String, String>? recordedParams;

      final mockClient = MockClient((request) async {
        recordedParams = request.url.queryParameters;
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'items': [sampleProductItemJson],
              'total': 1,
              'limit': 50,
              'offset': 0,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ProductApiService(apiClient: ApiClient(client: mockClient));
      final items = await service.listProducts(
        token: 'test-token',
        limit: 50,
        status: 'ACTIVE',
        search: 'gạo',
      );

      expect(recordedParams?['limit'], '50');
      expect(recordedParams?['status'], 'ACTIVE');
      expect(recordedParams?['moderationStatus'], 'APPROVED');
      expect(recordedParams?['search'], 'gạo');
      expect(items.length, 1);
      expect(items.first.productId, 'prod-uuid-123');
    });

    test('6. listProducts defaults to status=ACTIVE & moderationStatus=APPROVED when omitted', () async {
      Map<String, String>? recordedParams;

      final mockClient = MockClient((request) async {
        recordedParams = request.url.queryParameters;
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'items': [], 'total': 0},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ProductApiService(apiClient: ApiClient(client: mockClient));
      await service.listProducts(token: 'test-token');

      expect(recordedParams?['status'], 'ACTIVE');
      expect(recordedParams?['moderationStatus'], 'APPROVED');
    });

    test('7. listProducts sends custom Swagger statuses accurately', () async {
      Map<String, String>? recordedParams;

      final mockClient = MockClient((request) async {
        recordedParams = request.url.queryParameters;
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'items': [], 'total': 0},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ProductApiService(apiClient: ApiClient(client: mockClient));
      await service.listProducts(
        token: 'test-token',
        status: ProductStatus.draft.value,
        moderationStatus: ProductModerationStatus.pendingApproval.value,
      );

      expect(recordedParams?['status'], 'DRAFT');
      expect(recordedParams?['moderationStatus'], 'PENDING_APPROVAL');
    });

    test('8. fetchAllSupplierProducts queries all Swagger status pairs', () async {
      final requestedPairs = <String>[];

      final mockClient = MockClient((request) async {
        final s = request.url.queryParameters['status'];
        final m = request.url.queryParameters['moderationStatus'];
        requestedPairs.add('$s+$m');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'items': [
                {
                  ...sampleProductItemJson,
                  'productId': 'prod-$s-$m',
                  'status': s,
                  'moderationStatus': m,
                }
              ],
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ProductApiService(apiClient: ApiClient(client: mockClient));
      final allItems = await service.fetchAllSupplierProducts(token: 'test-token');

      expect(requestedPairs, contains('ACTIVE+APPROVED'));
      expect(requestedPairs, contains('INACTIVE+APPROVED'));
      expect(requestedPairs, contains('DRAFT+PENDING_APPROVAL'));
      expect(requestedPairs, contains('ACTIVE+EDIT_PENDING_APPROVAL'));
      expect(requestedPairs, contains('DRAFT+REJECTED'));
      expect(requestedPairs, contains('ACTIVE+SUSPENDED'));
      expect(requestedPairs, contains('DRAFT+DRAFT'));
      expect(allItems.isNotEmpty, true);
    });
  });

  group('AddProductScreen API Integration Tests', () {
    testWidgets('Submitting new product calls createProduct directly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final requestedPaths = <String>[];
      final mockClient = MockClient((request) async {
        requestedPaths.add('${request.method} ${request.url.path}');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': sampleProductItemJson,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final mockTokenStorage = InMemoryTokenStorageService();
      await mockTokenStorage.saveTokens(
        AuthTokens(accessToken: 'mock-access-token', refreshToken: 'mock-refresh'),
      );

      final validProduct = SellerProductItem(
        id: 'prod-valid',
        name: 'Gạo ST25 Sóc Trăng Đạt Chuẩn GACP',
        sku: 'ST25-5KG',
        price: 180000,
        stock: 50,
        unit: 'túi',
        categoryType: ProductCategoryType.underReview,
        foodCategory: 'Lương thực chính (Tinh bột)',
        whoCategoryCode: 'STAPLES',
        images: const [
          'https://cdn.cookconnect.vn/1.jpg',
          'https://cdn.cookconnect.vn/2.jpg',
          'https://cdn.cookconnect.vn/3.jpg',
          'https://cdn.cookconnect.vn/4.jpg',
          'https://cdn.cookconnect.vn/5.jpg',
        ],
        description: 'Mô tả chi tiết sản phẩm gạo ST25',
      );

      SellerProductItem? returnedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: AddProductScreen(
            tokenStorage: mockTokenStorage,
            productApiService: ProductApiService(apiClient: ApiClient(client: mockClient)),
            initialImages: validProduct.images,
            onAdd: (item) {
              returnedItem = item;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('product_name_input')), validProduct.name);

      await tester.scrollUntilVisible(
        find.byKey(const Key('category_picker_field')),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('category_picker_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lương thực chính (Tinh bột)'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('product_price_input')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byKey(const Key('product_price_input')), '180000');
      await tester.enterText(find.byKey(const Key('product_unit_input')), 'túi');

      await tester.scrollUntilVisible(
        find.byKey(const Key('product_description_input')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byKey(const Key('product_description_input')), validProduct.description!);
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const Key('submit_for_review_button'));
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(requestedPaths, contains('POST /api/v1/products'));
      expect(returnedItem, isNotNull);
    });

    testWidgets('API error 400 enqueues background task and records failure with exact reason', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'statusCode': 400,
            'errorCode': 'PRODUCT.PRODUCT_NOT_OWNED',
            'message': 'PRODUCT.PRODUCT_NOT_OWNED',
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final mockTokenStorage = InMemoryTokenStorageService();
      await mockTokenStorage.saveTokens(
        AuthTokens(accessToken: 'mock-access-token', refreshToken: 'mock-refresh'),
      );

      final initialProduct = SellerProductItem(
        id: 'prod-uuid-123',
        name: 'Gạo ST25 Sóc Trăng Đạt Chuẩn GACP',
        sku: 'ST25-5KG',
        price: 180000,
        stock: 50,
        unit: 'túi',
        categoryType: ProductCategoryType.draft,
        foodCategory: 'Lương thực chính (Tinh bột)',
        whoCategoryCode: 'STAPLES',
        images: const [
          'https://cdn.cookconnect.vn/1.jpg',
          'https://cdn.cookconnect.vn/2.jpg',
          'https://cdn.cookconnect.vn/3.jpg',
          'https://cdn.cookconnect.vn/4.jpg',
          'https://cdn.cookconnect.vn/5.jpg',
        ],
        description: 'Mô tả chi tiết sản phẩm gạo ST25',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AddProductScreen(
            initialProduct: initialProduct,
            tokenStorage: mockTokenStorage,
            productApiService: ProductApiService(apiClient: ApiClient(client: mockClient)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const Key('submit_for_review_button'));
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Screen is popped optimistically to not block user
      expect(find.byType(AddProductScreen), findsNothing);

      // Background task caught the 400 error with descriptive message
      final failedTask = ProductBackgroundQueueService.instance.failedTasks.firstWhere(
        (t) => t.product.id == 'prod-uuid-123',
      );
      expect(failedTask.errorMessage, 'Bạn không có quyền sở hữu sản phẩm này.');
    });

    testWidgets('Save draft calls createProduct and DOES NOT call submit-review', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final requestedPaths = <String>[];
      final mockClient = MockClient((request) async {
        requestedPaths.add('${request.method} ${request.url.path}');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': sampleProductItemJson,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final mockTokenStorage = InMemoryTokenStorageService();
      await mockTokenStorage.saveTokens(
        AuthTokens(accessToken: 'mock-access-token', refreshToken: 'mock-refresh'),
      );

      SellerProductItem? returnedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: AddProductScreen(
            tokenStorage: mockTokenStorage,
            productApiService: ProductApiService(apiClient: ApiClient(client: mockClient)),
            onAdd: (item) {
              returnedItem = item;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('product_name_input')), 'Bản nháp xoài cát Hòa Lộc');
      await tester.pumpAndSettle();

      final saveDraftBtn = find.byKey(const Key('save_draft_button'));
      expect(saveDraftBtn, findsOneWidget);
      await tester.tap(saveDraftBtn);
      await tester.pumpAndSettle();

      expect(requestedPaths, contains('POST /api/v1/products'));
      expect(
        requestedPaths.any((p) => p.endsWith('/submit-review')),
        isFalse,
      );
      expect(returnedItem?.categoryType, ProductCategoryType.draft);
    });
  });
}
