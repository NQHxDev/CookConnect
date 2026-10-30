import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/menu/data/models/seller_product_item.dart';
import 'package:cook_connect_seller/features/menu/data/models/product_category_type.dart';
import 'package:cook_connect_seller/features/menu/presentation/widgets/product_card_item.dart';
import 'package:cook_connect_seller/features/menu/presentation/widgets/product_action_bottom_sheet.dart';
import 'package:cook_connect_seller/features/menu/presentation/widgets/confirm_delete_product_dialog.dart';

void main() {
  final sampleProduct = SellerProductItem(
    id: 'prod-001',
    name: 'Thịt bò Úc Fuji thượng hạng',
    sku: 'SP-BO-01',
    price: 350000,
    originalPrice: 400000,
    stock: 25,
    soldCount: 8,
    categoryType: ProductCategoryType.onShelf,
    foodCategory: 'Thịt tươi sống',
  );

  testWidgets(
    'Tapping 3-dots button on ProductCardItem opens custom ProductActionBottomSheet',
    (WidgetTester tester) async {
      bool editCalled = false;
      bool toggleStatusCalled = false;
      bool quickStockCalled = false;
      bool deleteCalled = false;
      bool copyCalled = false;
      bool shareCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCardItem(
              product: sampleProduct,
              onEdit: () => editCalled = true,
              onToggleStatus: () => toggleStatusCalled = true,
              onQuickUpdateStock: () => quickStockCalled = true,
              onDelete: () => deleteCalled = true,
              onDuplicate: () => copyCalled = true,
              onShare: () => shareCalled = true,
            ),
          ),
        ),
      );

      // Verify 3 dots button is present
      final moreButton = find.byIcon(Iconsax.more);
      expect(moreButton, findsOneWidget);

      // Tap 3 dots button
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Verify custom ProductActionBottomSheet is opened
      expect(find.text('Tùy chọn sản phẩm'), findsOneWidget);
      expect(find.text('Quản lý trạng thái và thao tác nhanh'), findsOneWidget);

      // Verify product preview card inside bottom sheet
      expect(find.text('Thịt bò Úc Fuji thượng hạng'), findsNWidgets(2)); // Card and BottomSheet
      expect(find.text('SKU: SP-BO-01'), findsOneWidget);
      expect(find.text('• Kho: 25'), findsOneWidget);

      // Verify action options
      expect(find.text('Chỉnh sửa sản phẩm'), findsOneWidget);
      expect(find.text('Kho hàng & Giá bán'), findsOneWidget);
      expect(find.text('Tạm ngưng kinh doanh'), findsOneWidget);
      expect(find.text('Sao chép sản phẩm'), findsOneWidget);
      expect(find.text('Chia sẻ sản phẩm'), findsOneWidget);
      expect(find.text('Ngừng bán & Xóa sản phẩm'), findsOneWidget);

      // Tap 'Sao chép sản phẩm' and verify callback
      await tester.tap(find.text('Sao chép sản phẩm'));
      await tester.pumpAndSettle();
      expect(copyCalled, isTrue);
      // Bottom sheet should be closed
      expect(find.text('Tùy chọn sản phẩm'), findsNothing);
    },
  );

  testWidgets(
    'ProductActionBottomSheet triggers toggleStatus and delete correctly',
    (WidgetTester tester) async {
      bool toggleStatusCalled = false;
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  ProductActionBottomSheet.show(
                    context: ctx,
                    product: sampleProduct,
                    onEdit: () {},
                    onToggleStatus: () => toggleStatusCalled = true,
                    onDelete: () => deleteCalled = true,
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

      expect(find.text('Tùy chọn sản phẩm'), findsOneWidget);

      // Tap 'Tạm ngưng kinh doanh'
      await tester.tap(find.text('Tạm ngưng kinh doanh'));
      await tester.pumpAndSettle();
      expect(toggleStatusCalled, isTrue);

      // Re-open and tap 'Ngừng bán & Xóa sản phẩm'
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ngừng bán & Xóa sản phẩm'));
      await tester.pumpAndSettle();
      expect(deleteCalled, isTrue);
    },
  );

  testWidgets(
    'ConfirmDeleteProductDialog renders custom UI and fires onConfirm callback',
    (WidgetTester tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  ConfirmDeleteProductDialog.show(
                    context: ctx,
                    product: sampleProduct,
                    onConfirm: () => confirmed = true,
                  );
                },
                child: const Text('Delete'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify custom modal dialog content
      expect(find.text('Xác nhận ngừng bán sản phẩm'), findsOneWidget);
      expect(
        find.textContaining('Bạn có chắc chắn muốn ngừng kinh doanh sản phẩm "Thịt bò Úc Fuji thượng hạng"?'),
        findsOneWidget,
      );
      expect(find.text('Hủy bỏ'), findsOneWidget);
      expect(find.text('Đồng ý ngừng bán'), findsOneWidget);

      // Tap 'Đồng ý ngừng bán'
      await tester.tap(find.text('Đồng ý ngừng bán'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
      expect(find.text('Xác nhận ngừng bán sản phẩm'), findsNothing);
    },
  );
}
