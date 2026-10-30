import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/menu/data/models/seller_product_item.dart';
import 'package:cook_connect_seller/features/menu/data/services/product_api_service.dart';
import 'package:cook_connect_seller/features/menu/data/services/product_background_queue_service.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/menu_screen.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';
import 'package:cook_connect_seller/features/auth/data/services/auth_api_service.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockProduct = SellerProductItem(
    id: 'prod_test_bg_1',
    name: 'Cá hồi Na Uy phi lê',
    sku: 'SALMON-01',
    price: 350000,
    stock: 20,
    unit: 'kg',
    categoryType: ProductCategoryType.underReview,
    foodCategory: 'Thực phẩm tươi sống',
    whoCategoryCode: 'MEAT_FISH',
    images: const [
      'https://cdn.cookconnect.vn/salmon1.jpg',
      'https://cdn.cookconnect.vn/salmon2.jpg',
      'https://cdn.cookconnect.vn/salmon3.jpg',
      'https://cdn.cookconnect.vn/salmon4.jpg',
      'https://cdn.cookconnect.vn/salmon5.jpg',
    ],
    description: 'Cá hồi tươi ngon nhập khẩu Na Uy đạt chuẩn',
  );

  tearDown(() {
    ProductBackgroundQueueService.instance.clearCompletedTasks();
    for (final task in List.of(ProductBackgroundQueueService.instance.failedTasks)) {
      ProductBackgroundQueueService.instance.dismissFailedTask(task.id);
    }
  });

  test('ProductBackgroundQueueService successfully creates product in background and emits onTaskCompleted', () async {
    final mockClient = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/api/v1/products') {
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 201,
            'data': {
              'id': 'prod_created_123',
              'name': 'Cá hồi Na Uy phi lê',
              'status': 'DRAFT',
              'moderationStatus': 'PENDING_APPROVAL',
              'variants': [],
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('Not Found', 404);
    });

    final mockTokenStorage = InMemoryTokenStorageService();
    await mockTokenStorage.saveTokens(
      AuthTokens(accessToken: 'valid-test-token', refreshToken: 'refresh'),
    );

    final apiService = ProductApiService(apiClient: ApiClient(client: mockClient));
    ProductUploadTask? completedTask;
    final sub = ProductBackgroundQueueService.instance.onTaskCompleted.listen((task) {
      completedTask = task;
    });

    final task = ProductBackgroundQueueService.instance.enqueue(
      product: mockProduct,
      images: mockProduct.images,
      isUpdate: false,
      supplierId: 'supplier-uuid-1',
      apiService: apiService,
      tokenStorage: mockTokenStorage,
    );

    expect(task.isProcessing, isTrue);

    // Wait for async background execution to complete
    await Future.delayed(const Duration(milliseconds: 100));

    expect(task.isCompleted, isTrue);
    expect(task.errorMessage, isNull);
    expect(completedTask, isNotNull);
    expect(completedTask!.product.name, 'Cá hồi Na Uy phi lê');

    await sub.cancel();
  });

  test('ProductBackgroundQueueService handles failure gracefully, stores exact error and emits onTaskFailed', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'success': false,
          'statusCode': 400,
          'errorCode': 'PRODUCT.SKU_ALREADY_EXISTS',
          'message': 'SKU already exists in your store',
        }),
        400,
        headers: {'content-type': 'application/json'},
      );
    });

    final mockTokenStorage = InMemoryTokenStorageService();
    await mockTokenStorage.saveTokens(
      AuthTokens(accessToken: 'valid-test-token', refreshToken: 'refresh'),
    );

    final apiService = ProductApiService(apiClient: ApiClient(client: mockClient));
    ProductUploadTask? failedTask;
    final sub = ProductBackgroundQueueService.instance.onTaskFailed.listen((task) {
      failedTask = task;
    });

    final task = ProductBackgroundQueueService.instance.enqueue(
      product: mockProduct,
      images: mockProduct.images,
      isUpdate: false,
      supplierId: 'supplier-uuid-1',
      apiService: apiService,
      tokenStorage: mockTokenStorage,
    );

    // Wait for async background execution to fail
    await Future.delayed(const Duration(milliseconds: 100));

    expect(task.isFailed, isTrue);
    expect(task.errorMessage, 'Mã sản phẩm / SKU đã tồn tại trong gian hàng của bạn.');
    expect(failedTask, isNotNull);
    expect(failedTask!.errorMessage, contains('Mã sản phẩm / SKU đã tồn tại'));

    await sub.cancel();
  });

  test('ProductBackgroundQueueService refreshes expired access token via /api/v1/auth/refresh and completes creation', () async {
    String? capturedAuthHeader;
    String? capturedRefreshHeader;
    Map<String, dynamic>? capturedRefreshBody;

    final mockClient = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/api/v1/auth/refresh') {
        capturedRefreshHeader = request.headers['x-refresh-token'] ?? request.headers['X-Refresh-Token'];
        if (request.body.isNotEmpty) {
          try {
            capturedRefreshBody = jsonDecode(request.body) as Map<String, dynamic>;
          } catch (_) {}
        }
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'data': {
              'tokens': {
                'accessToken': 'rotated_access_token_999',
                'refreshToken': 'new_refresh_token_999',
                'tokenType': 'Bearer',
                'expiresIn': 3600,
              },
              'user': {
                'userId': 'usr_test_seller',
                'email': 'seller@cookconnect.app',
                'roles': ['SUPPLIER_ADMIN'],
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.method == 'POST' && request.url.path == '/api/v1/products') {
        capturedAuthHeader = request.headers['authorization'];
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 201,
            'data': {
              'id': 'prod_created_after_refresh',
              'name': 'Cá hồi Na Uy phi lê',
              'status': 'DRAFT',
              'moderationStatus': 'PENDING_APPROVAL',
              'variants': [],
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response('Not Found', 404);
    });

    final mockTokenStorage = InMemoryTokenStorageService();
    final expiredTokens = AuthTokens(
      accessToken: 'expired-access-token',
      refreshToken: 'valid-refresh-token-123',
      expiresIn: -100, // Access token is expired!
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    );
    await mockTokenStorage.saveTokens(expiredTokens);

    final authApiClient = ApiClient(client: mockClient);
    SellerAuthService.instance.configure(
      storage: mockTokenStorage,
      apiService: AuthApiService(apiClient: authApiClient),
    );
    SellerAuthService.instance.setSession(
      user: SellerUser(id: 'usr_test_seller', email: 'seller@cookconnect.app'),
      tokens: expiredTokens,
    );

    final apiService = ProductApiService(apiClient: authApiClient);
    ProductUploadTask? completedTask;
    final sub = ProductBackgroundQueueService.instance.onTaskCompleted.listen((task) {
      completedTask = task;
    });

    final task = ProductBackgroundQueueService.instance.enqueue(
      product: mockProduct,
      images: mockProduct.images,
      isUpdate: false,
      supplierId: 'supplier-uuid-1',
      apiService: apiService,
      tokenStorage: mockTokenStorage,
    );

    // Wait for async background refresh and execution to finish
    await Future.delayed(const Duration(milliseconds: 150));

    expect(task.isCompleted, isTrue);
    expect(task.errorMessage, isNull);
    expect(capturedRefreshHeader, equals('valid-refresh-token-123'));
    expect(capturedRefreshBody?['refreshToken'], equals('valid-refresh-token-123'));
    expect(capturedAuthHeader, equals('Bearer rotated_access_token_999'));
    expect(completedTask, isNotNull);

    await sub.cancel();
  });

  test('ProductBackgroundQueueService fails with session expired when both access and refresh token are unusable', () async {
    final mockClient = MockClient((request) async {
      return http.Response('Unauthorized', 401);
    });

    final mockTokenStorage = InMemoryTokenStorageService();
    final unrefreshableTokens = AuthTokens(
      accessToken: 'expired-access-token',
      refreshToken: '', // No refresh token!
      expiresIn: -100,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    );
    await mockTokenStorage.saveTokens(unrefreshableTokens);

    SellerAuthService.instance.configure(
      storage: mockTokenStorage,
      apiService: AuthApiService(apiClient: ApiClient(client: mockClient)),
    );
    await SellerAuthService.instance.logout(callServer: false);

    final apiService = ProductApiService(apiClient: ApiClient(client: mockClient));
    ProductUploadTask? failedTask;
    final sub = ProductBackgroundQueueService.instance.onTaskFailed.listen((task) {
      failedTask = task;
    });

    final task = ProductBackgroundQueueService.instance.enqueue(
      product: mockProduct,
      images: mockProduct.images,
      isUpdate: false,
      supplierId: 'supplier-uuid-1',
      apiService: apiService,
      tokenStorage: mockTokenStorage,
    );

    await Future.delayed(const Duration(milliseconds: 100));

    expect(task.isFailed, isTrue);
    expect(task.errorMessage, contains('Phiên đăng nhập đã hết hạn'));
    expect(failedTask, isNotNull);

    await sub.cancel();
  });

  testWidgets('MenuScreen displays failed task banner and allows user to dismiss or re-edit', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Enqueue a failed task directly into the queue
    final queue = ProductBackgroundQueueService.instance;
    final failedTask = ProductUploadTask(
      id: 'task_failed_sample_1',
      product: mockProduct,
      originalImages: mockProduct.images,
      isUpdate: false,
      supplierId: 'supplier-uuid-1',
      status: ProductTaskStatus.failed,
      errorMessage: 'Mã sản phẩm / SKU đã tồn tại trong gian hàng của bạn.',
    );
    queue.tasks; // ensure init
    // Add manually to tasks
    queue.enqueue(
      product: mockProduct,
      images: mockProduct.images,
      isUpdate: false,
      supplierId: 'sup-1',
      apiService: ProductApiService(apiClient: ApiClient(client: MockClient((_) async => http.Response('{"statusCode":400,"errorCode":"PRODUCT.SKU_ALREADY_EXISTS"}', 400)))),
      tokenStorage: InMemoryTokenStorageService()..saveTokens(AuthTokens(accessToken: 'tok', refreshToken: 'ref')),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: MenuScreen(
          initialProducts: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify failed task banner rendered with product name & reason
    expect(find.textContaining('Đăng sản phẩm "Cá hồi Na Uy phi lê" thất bại'), findsOneWidget);
    expect(find.text('Mã sản phẩm / SKU đã tồn tại trong gian hàng của bạn.'), findsOneWidget);
    expect(find.text('Sửa & Thử lại'), findsOneWidget);
    expect(find.text('Bỏ qua'), findsOneWidget);

    // Tap "Bỏ qua" to dismiss
    await tester.tap(find.text('Bỏ qua'));
    await tester.pumpAndSettle();

    // Banner is dismissed
    expect(find.textContaining('Đăng sản phẩm "Cá hồi Na Uy phi lê" thất bại'), findsNothing);
  });
}

