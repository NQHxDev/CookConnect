import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/menu_screen.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/add_product_screen.dart';
import 'package:cook_connect_seller/features/menu/data/models/product_category_type.dart';
import 'package:shared_widgets/shared_widgets.dart';

void main() {
  testWidgets('MenuScreen renders product management page with all 7 category tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: MenuScreen(),
      ),
    );
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
    final lowStockOption = find.text('Sản phẩm có tồn kho thấp, cần nhập thêm hàng');
    expect(lowStockOption, findsOneWidget);
    await tester.tap(lowStockOption);
    await tester.pumpAndSettle();

    // Verify modal is closed and "Còn ít" is now active
    expect(find.text('Tất cả danh mục sản phẩm'), findsNothing);
    expect(find.text('Khô bò sợi cay đặc biệt Tây Bắc (Hũ 250g)'), findsOneWidget);
  });

  testWidgets('MenuScreen allows switching tabs by direct horizontal tab tapping', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: MenuScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "Đã vô hiệu hóa"
    final disabledTab = find.text('Đã vô hiệu hóa').first;
    await tester.tap(disabledTab);
    await tester.pumpAndSettle();

    // Verify items in "Đã vô hiệu hóa" are visible
    expect(find.text('Trà sen Tây Hồ ướp bông tự nhiên'), findsOneWidget);
  });

  testWidgets('MenuScreen search filter works as expected', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: MenuScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Initially contains Bánh mì bơ tỏi
    expect(find.text('Bánh mì bơ tỏi phô mai Hàn Quốc (Set 2 bánh)'), findsOneWidget);

    // Enter search text
    final searchInput = find.byType(TextField).first;
    await tester.enterText(searchInput, 'Bánh mì');
    await tester.pumpAndSettle();

    // Only Bánh mì matches
    expect(find.text('Bánh mì bơ tỏi phô mai Hàn Quốc (Set 2 bánh)'), findsOneWidget);
    expect(find.text('Khô gà lá chanh thượng hạng hộp 300g'), findsNothing);
  });

  testWidgets('MenuScreen quick edit stock and price dialog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: MenuScreen(),
      ),
    );
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

  testWidgets('MenuScreen integrates shared CustomSliverRefreshControl and pull-to-refresh triggers smoothly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: MenuScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify CustomSliverRefreshControl is embedded in CustomScrollView
    expect(find.byType(CustomSliverRefreshControl), findsOneWidget);

    // Find the vertical scrollable (CustomScrollView)
    final verticalScrollable = find.byType(Scrollable).at(1);

    // Pull down to trigger refresh
    await tester.drag(verticalScrollable, const Offset(0, 150));
    await tester.pump(const Duration(milliseconds: 50));

    // CustomRefreshBadge should be present and refreshing
    expect(
      find.byWidgetPredicate((w) => w is CustomRefreshBadge && w.isRefreshing),
      findsOneWidget,
    );

    // Let the refresh complete
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Products are still intact after refresh
    expect(find.text('Bánh mì bơ tỏi phô mai Hàn Quốc (Set 2 bánh)'), findsOneWidget);
  });

  testWidgets('Tapping add button navigates to AddProductScreen with food categories, multiple SKUs and real image requirements', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: MenuScreen(),
      ),
    );
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
    expect(find.text('Phân loại & Giá bán (SKU)'), findsOneWidget);
    expect(find.text('Duy nhất 1 loại'), findsOneWidget);
    expect(find.text('Nhiều phân loại (SKU)'), findsOneWidget);

    // Tap Food Category to verify modal bottom sheet opens with food ingredient categories
    final categoryField = find.text('Thịt bò');
    expect(categoryField, findsOneWidget);
    await tester.tap(categoryField);
    await tester.pumpAndSettle();

    // Verify category modal bottom sheet has food categories
    expect(find.text('Chọn danh mục thực phẩm'), findsOneWidget);
    expect(find.text('Thịt cừu & dê'), findsOneWidget);
    expect(find.text('Trứng các loại'), findsOneWidget);
    expect(find.text('Rau củ tươi'), findsOneWidget);
    expect(find.text('Thực phẩm chế biến'), findsOneWidget);

    // Select 'Trứng các loại'
    await tester.tap(find.text('Trứng các loại'));
    await tester.pumpAndSettle();

    // Category modal closes and selection updates
    expect(find.text('Chọn danh mục thực phẩm'), findsNothing);
    expect(find.text('Trứng các loại'), findsOneWidget);

    // Switch to 'Nhiều phân loại (SKU)'
    await tester.tap(find.text('Nhiều phân loại (SKU)'));
    await tester.pumpAndSettle();

    // Verify Multiple SKUs UI elements are displayed
    expect(find.text('Phân loại #1'), findsOneWidget);
    expect(find.text('Phân loại #2'), findsOneWidget);
    expect(find.text('+ Thêm phân loại SKU mới'), findsOneWidget);

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
  });
}
