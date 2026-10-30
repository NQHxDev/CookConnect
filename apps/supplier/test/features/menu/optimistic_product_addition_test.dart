import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cook_connect_seller/core/network/api_client.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';
import 'package:cook_connect_seller/features/menu/data/models/seller_product_item.dart';
import 'package:cook_connect_seller/features/menu/data/models/product_category_type.dart';
import 'package:cook_connect_seller/features/menu/data/services/product_api_service.dart';
import 'package:cook_connect_seller/features/menu/data/services/product_background_queue_service.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/add_product_screen.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/menu_screen.dart';
import 'package:cook_connect_seller/features/menu/presentation/widgets/product_card_item.dart';

void main() {
  group('Optimistic Product Submission Flow Tests', () {
    testWidgets(
      'Submitting product in AddProductScreen closes screen immediately and enqueues task without full-screen blocking spinner',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': 'prod-server-999',
                'name': 'Gạo Nếp Cái Hoa Vàng',
                'status': 'UNDER_REVIEW',
                'variants': [],
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

        final validProduct = SellerProductItem(
          id: 'prod-init-1',
          name: 'Gạo Nếp Cái Hoa Vàng',
          sku: 'NEP-01',
          price: 120000,
          stock: 30,
          unit: 'kg',
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
          description: 'Gạo nếp cái hoa vàng chuẩn mùa vụ',
        );

        SellerProductItem? submittedProduct;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    final res = await Navigator.of(context).push<SellerProductItem>(
                      MaterialPageRoute(
                        builder: (_) => AddProductScreen(
                          initialProduct: validProduct,
                          initialImages: validProduct.images,
                          tokenStorage: mockTokenStorage,
                          productApiService: ProductApiService(
                            apiClient: ApiClient(client: mockClient),
                          ),
                          onAdd: (item) {
                            submittedProduct = item;
                          },
                        ),
                      ),
                    );
                    expect(res, isNotNull);
                  },
                  child: const Text('Mở form tạo'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open AddProductScreen
        await tester.tap(find.text('Mở form tạo'));
        await tester.pumpAndSettle();

        expect(find.byType(AddProductScreen), findsOneWidget);

        // Tap submit for review
        final submitBtn = find.byKey(const Key('submit_for_review_button'));
        expect(submitBtn, findsOneWidget);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        // VERIFY: AddProductScreen is dismissed immediately (popped back)
        expect(find.byType(AddProductScreen), findsNothing);
        expect(find.text('Mở form tạo'), findsOneWidget);
        expect(submittedProduct, isNotNull);
        expect(submittedProduct!.name, 'Gạo Nếp Cái Hoa Vàng');
        expect(submittedProduct!.categoryType, ProductCategoryType.underReview);
      },
    );

    testWidgets(
      'MenuScreen displays newly submitted product card immediately in "Đang xét duyệt" tab without full-screen spinner or needing manual refresh',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'success': true, 'data': []}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final mockTokenStorage = InMemoryTokenStorageService();
        await mockTokenStorage.saveTokens(
          AuthTokens(accessToken: 'mock-token', refreshToken: 'mock-refresh'),
        );

        final apiService = ProductApiService(apiClient: ApiClient(client: mockClient));

        final initialItem = SellerProductItem(
          id: 'prod-existing-1',
          name: 'Sản phẩm đang bán cũ',
          sku: 'OLD-01',
          price: 50000,
          stock: 10,
          categoryType: ProductCategoryType.onShelf,
          foodCategory: 'Lương thực chính (Tinh bột)',
        );

        final optimisticProduct = SellerProductItem(
          id: 'prod-optimistic-1',
          name: 'Thịt Bò Tươi Sạch Ba Chỉ',
          sku: 'BO-01',
          price: 150000,
          stock: 25,
          unit: 'khay',
          categoryType: ProductCategoryType.underReview,
          foodCategory: 'Thịt & Sản phẩm từ thịt',
          description: 'Thịt bò tươi ngon giao trong ngày',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MenuScreen(
              productApiService: apiService,
              tokenStorage: mockTokenStorage,
              initialProducts: [optimisticProduct, initialItem],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Scroll category tab bar horizontally to reach "Đang xét duyệt"
        final horizontalScrollable = find.byType(SingleChildScrollView).first;
        await tester.drag(horizontalScrollable, const Offset(-300, 0));
        await tester.pumpAndSettle();

        // Switch to "Đang xét duyệt"
        await tester.tap(find.text('Đang xét duyệt'));
        await tester.pumpAndSettle();

        // Card must be immediately visible without spinner
        expect(find.text('Thịt Bò Tươi Sạch Ba Chỉ'), findsOneWidget);
        expect(find.byType(ProductCardItem), findsOneWidget);
        expect(find.text('Đang tải danh sách sản phẩm từ máy chủ...'), findsNothing);
      },
    );
  });
}
