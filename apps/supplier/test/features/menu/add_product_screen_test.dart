import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/add_product_screen.dart';
import 'package:cook_connect_seller/features/menu/data/models/seller_product_item.dart';
import 'package:cook_connect_seller/features/menu/data/models/product_dtos.dart';

void main() {
  testWidgets('AddProductScreen renders all Swagger-compliant fields and builds CreateProductDto correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: AddProductScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Top Sections
    expect(find.text('Thêm sản phẩm mới'), findsOneWidget);
    expect(find.text('Thông tin thực phẩm'), findsOneWidget);
    expect(find.text('Tên thực phẩm *'), findsOneWidget);
    expect(find.text('Danh mục thực phẩm *'), findsOneWidget);
    expect(find.text('Mã sản phẩm / SKU chính (Tùy chọn)'), findsOneWidget);

    // 1. Tên thực phẩm
    await tester.enterText(
      find.byKey(const Key('product_name_input')),
      'Gạo ST25 Sóc Trăng Đạt Chuẩn GACP',
    );

    // 2. Select category
    await tester.tap(find.byKey(const Key('category_picker_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lương thực chính (Tinh bột)'));
    await tester.pumpAndSettle();

    // 3. Scroll to Pricing & Unit section
    await tester.scrollUntilVisible(
      find.byKey(const Key('product_price_input')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Phân loại & Giá bán'), findsOneWidget);
    expect(find.text('Giá bán (VNĐ) *'), findsOneWidget);
    expect(find.text('Đơn vị tính *'), findsOneWidget);
    expect(find.text('Quy cách đóng gói'), findsOneWidget);

    // 4. Đơn vị tính
    await tester.enterText(
      find.byKey(const Key('product_unit_input')),
      'túi',
    );

    // 5. Giá bán
    await tester.enterText(
      find.byKey(const Key('product_price_input')),
      '180000',
    );

    // 6. Scroll to Description & Attributes section
    await tester.scrollUntilVisible(
      find.byKey(const Key('product_description_input')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Mô tả & Thuộc tính thực phẩm'), findsOneWidget);
    expect(find.text('Mô tả chi tiết thực phẩm *'), findsOneWidget);
    expect(find.text('Nguồn gốc / Xuất xứ (Tùy chọn)'), findsOneWidget);
    expect(find.text('Điều kiện bảo quản (Tùy chọn)'), findsOneWidget);
    expect(find.text('Hạn sử dụng theo ngày (Tùy chọn)'), findsOneWidget);

    // 7. Mô tả chi tiết thực phẩm
    await tester.enterText(
      find.byKey(const Key('product_description_input')),
      'Gạo ST25 hảo hạng trồng tại vùng luân canh lúa tôm Sóc Trăng',
    );

    // 8. Nguồn gốc xuất xứ
    await tester.enterText(
      find.byKey(const Key('product_origin_input')),
      'Sóc Trăng, Việt Nam',
    );

    // 7. Quick chip tap for storage condition
    await tester.scrollUntilVisible(
      find.text('Nơi khô ráo, thoáng mát'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Nơi khô ráo, thoáng mát'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // 8. Quick chip tap for shelf life
    await tester.scrollUntilVisible(
      find.text('180 ngày'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('180 ngày'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Nơi khô ráo, thoáng mát'), findsWidgets);
    expect(find.text('180'), findsOneWidget);

    // Convert SellerProductItem mock to verify CreateProductDto mapping
    final mockItem = SellerProductItem(
      id: 'prod_test',
      supplierId: 'aef05366-86a7-4c9a-8646-2bd26cd3a674',
      name: 'Gạo ST25 Sóc Trăng Đạt Chuẩn GACP',
      sku: 'RICE-ST25-5KG',
      price: 180000,
      stock: 100,
      unit: 'túi',
      packSize: '5kg',
      categoryType: ProductCategoryType.underReview,
      foodCategory: 'Lương thực chính (Tinh bột)',
      whoCategoryCode: 'STAPLES',
      description: 'Gạo ST25 hảo hạng trồng tại vùng luân canh lúa tôm Sóc Trăng',
      origin: 'Sóc Trăng, Việt Nam',
      storageCondition: 'Nơi khô ráo, thoáng mát',
      shelfLifeDays: 180,
    );

    final dto = CreateProductDto.fromSellerProductItem(mockItem);
    expect(dto.supplierId, 'aef05366-86a7-4c9a-8646-2bd26cd3a674');
    expect(dto.productName, 'Gạo ST25 Sóc Trăng Đạt Chuẩn GACP');
    expect(dto.whoCategoryCode, 'STAPLES');
    expect(dto.description, 'Gạo ST25 hảo hạng trồng tại vùng luân canh lúa tôm Sóc Trăng');
    expect(dto.origin, 'Sóc Trăng, Việt Nam');
    expect(dto.storageCondition, 'Nơi khô ráo, thoáng mát');
    expect(dto.shelfLifeDays, 180);
    expect(dto.variants.length, 1);
    expect(dto.variants.first.unit, 'túi');
    expect(dto.variants.first.price, 180000);
    expect(dto.variants.first.packSize, '5kg');

    final json = dto.toJson();
    expect(json['supplierId'], 'aef05366-86a7-4c9a-8646-2bd26cd3a674');
    expect(json['whoCategoryCode'], 'STAPLES');
    expect(json['productName'], 'Gạo ST25 Sóc Trăng Đạt Chuẩn GACP');
    expect(json['description'], isNotEmpty);
    expect(json['origin'], 'Sóc Trăng, Việt Nam');
    expect(json['storageCondition'], 'Nơi khô ráo, thoáng mát');
    expect(json['shelfLifeDays'], 180);
    expect(json['variants'], isA<List>());
  });

  testWidgets('Submit button is inactive initially and becomes active only when all required fields are satisfied', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Inactive initially with blank form
    await tester.pumpWidget(const MaterialApp(home: AddProductScreen()));
    await tester.pumpAndSettle();

    final btnFinder = find.byKey(const Key('submit_for_review_button'));
    expect(btnFinder, findsOneWidget);
    var btn = tester.widget<ElevatedButton>(btnFinder);
    expect(btn.onPressed, isNull);

    // 2. Open screen with fully valid initial product (5 images, name, category, price, unit, stock, desc)
    final validProduct = SellerProductItem(
      id: 'prod_valid_test',
      name: 'Gạo ST25 Sóc Trăng Đạt Chuẩn GACP',
      sku: 'RICE-ST25-5KG',
      price: 180000,
      stock: 100,
      unit: 'túi',
      categoryType: ProductCategoryType.underReview,
      foodCategory: 'Lương thực chính (Tinh bột)',
      whoCategoryCode: 'STAPLES',
      images: const [
        'img1.jpg',
        'img2.jpg',
        'img3.jpg',
        'img4.jpg',
        'img5.jpg',
      ],
      description: 'Mô tả chi tiết sản phẩm gạo ST25 chuẩn chất lượng cao',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AddProductScreen(
          key: const Key('valid_screen'),
          initialProduct: validProduct,
        ),
      ),
    );
    await tester.pumpAndSettle();

    btn = tester.widget<ElevatedButton>(btnFinder);
    expect(btn.onPressed, isNotNull);

    // 3. Clear name -> button immediately becomes inactive
    await tester.enterText(find.byKey(const Key('product_name_input')), '');
    await tester.pumpAndSettle();

    btn = tester.widget<ElevatedButton>(btnFinder);
    expect(btn.onPressed, isNull);

    // 4. Restore valid name -> button becomes active again
    await tester.enterText(
      find.byKey(const Key('product_name_input')),
      'Gạo ST25 Sóc Trăng Đạt Chuẩn',
    );
    await tester.pumpAndSettle();

    btn = tester.widget<ElevatedButton>(btnFinder);
    expect(btn.onPressed, isNotNull);
  });
}
