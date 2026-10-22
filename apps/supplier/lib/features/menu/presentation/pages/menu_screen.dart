import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:shared_widgets/shared_widgets.dart';
import '../../data/models/product_category_type.dart';
import '../../data/models/seller_product_item.dart';
import '../../data/models/mock_products.dart';
import '../widgets/category_tabs_bar.dart';
import '../widgets/all_categories_sheet.dart';
import '../widgets/product_card_item.dart';
import '../widgets/quick_edit_stock_dialog.dart';
import 'add_product_screen.dart';

typedef ProductsScreen = MenuScreen;

enum ProductSortOption {
  newest('Mới cập nhật'),
  bestSelling('Bán chạy nhất'),
  priceAsc('Giá tăng dần'),
  priceDesc('Giá giảm dần'),
  lowStock('Tồn kho thấp nhất');

  final String label;
  const ProductSortOption(this.label);
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  ProductCategoryType _selectedCategory = ProductCategoryType.onShelf;
  List<SellerProductItem> _products = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  ProductSortOption _currentSort = ProductSortOption.newest;
  bool _isSearchVisible = true;

  @override
  void initState() {
    super.initState();
    _products = List.from(initialMockProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Count items for each category
  Map<ProductCategoryType, int> get _categoryCounts {
    final counts = <ProductCategoryType, int>{
      for (var cat in ProductCategoryType.values) cat: 0,
    };
    for (final p in _products) {
      counts[p.categoryType] = (counts[p.categoryType] ?? 0) + 1;
    }
    return counts;
  }

  // Filtered and sorted products
  List<SellerProductItem> get _filteredProducts {
    List<SellerProductItem> list = _products
        .where((p) => p.categoryType == _selectedCategory)
        .toList();

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.foodCategory.toLowerCase().contains(q);
      }).toList();
    }

    switch (_currentSort) {
      case ProductSortOption.newest:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case ProductSortOption.bestSelling:
        list.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case ProductSortOption.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.lowStock:
        list.sort((a, b) => a.stock.compareTo(b.stock));
        break;
    }

    return list;
  }

  void _onCategorySelected(ProductCategoryType cat) {
    setState(() {
      _selectedCategory = cat;
    });
  }

  void _openAllCategoriesSheet() {
    AllCategoriesSheet.show(
      context: context,
      selectedCategory: _selectedCategory,
      counts: _categoryCounts,
      onSelectCategory: _onCategorySelected,
    );
  }

  Future<void> _openAddProduct() async {
    final newProduct = await Navigator.of(context).push<SellerProductItem>(
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );

    if (newProduct != null && mounted) {
      setState(() {
        _products.insert(0, newProduct);
        _selectedCategory = newProduct.categoryType;
      });
      final msg = newProduct.categoryType == ProductCategoryType.underReview
          ? 'Đã gửi sản phẩm "${newProduct.name}" để xét duyệt'
          : newProduct.categoryType == ProductCategoryType.draft
              ? 'Đã lưu sản phẩm "${newProduct.name}" vào bản nháp'
              : 'Đã thêm sản phẩm "${newProduct.name}"';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openEditProduct(SellerProductItem product) async {
    final updatedProduct = await Navigator.of(context).push<SellerProductItem>(
      MaterialPageRoute(
        builder: (context) => AddProductScreen(initialProduct: product),
      ),
    );

    if (updatedProduct != null && mounted) {
      setState(() {
        final idx = _products.indexWhere((p) => p.id == product.id);
        if (idx != -1) {
          _products[idx] = updatedProduct;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật sản phẩm "${updatedProduct.name}"'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openQuickEditStock(SellerProductItem product) {
    QuickEditStockDialog.show(
      context: context,
      product: product,
      onSave: (newStock, newPrice) {
        setState(() {
          final idx = _products.indexWhere((p) => p.id == product.id);
          if (idx != -1) {
            ProductCategoryType newCategory = product.categoryType;
            // Auto transition to lowStock or onShelf if stock changes
            if (product.categoryType == ProductCategoryType.onShelf && newStock <= 5) {
              newCategory = ProductCategoryType.lowStock;
            } else if (product.categoryType == ProductCategoryType.lowStock && newStock > 5) {
              newCategory = ProductCategoryType.onShelf;
            }

            _products[idx] = product.copyWith(
              stock: newStock,
              price: newPrice,
              categoryType: newCategory,
              updatedAt: DateTime.now(),
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật tồn kho & giá thành công!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _toggleProductStatus(SellerProductItem product) {
    setState(() {
      final idx = _products.indexWhere((p) => p.id == product.id);
      if (idx != -1) {
        if (product.categoryType == ProductCategoryType.disabled) {
          final newCat = product.stock <= 5 ? ProductCategoryType.lowStock : ProductCategoryType.onShelf;
          _products[idx] = product.copyWith(categoryType: newCat, isAvailable: true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã mở bán lại "${product.name}"'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          _products[idx] = product.copyWith(categoryType: ProductCategoryType.disabled, isAvailable: false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã tắt tạm ngưng "${product.name}"'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  void _deleteProduct(SellerProductItem product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _products.removeWhere((p) => p.id == product.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa sản phẩm thành công'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Sắp xếp danh sách',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...ProductSortOption.values.map((opt) {
              final isSel = opt == _currentSort;
              return ListTile(
                title: Text(
                  opt.label,
                  style: TextStyle(
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    color: isSel ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                trailing: isSel ? const Icon(Iconsax.tick_circle, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _currentSort = opt);
                  Navigator.of(ctx).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Iconsax.search_status : Iconsax.search_normal_1,
              color: AppColors.textPrimary,
              size: 20,
            ),
            tooltip: 'Tìm kiếm',
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.add_circle, color: AppColors.primary, size: 20),
            tooltip: 'Thêm sản phẩm',
            onPressed: _openAddProduct,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Horizontal Scrollable Category Selector Bar with 3-lines menu icon at the end
          CategoryTabsBar(
            selectedCategory: _selectedCategory,
            counts: _categoryCounts,
            onCategoryChanged: _onCategorySelected,
            onOpenAllCategories: _openAllCategoriesSheet,
          ),

          // 2. Search & Filter Bar
          if (_isSearchVisible)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm theo tên sản phẩm, SKU...',
                          hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textHint),
                          prefixIcon: const Icon(Iconsax.search_normal, size: 16, color: AppColors.textHint),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16, color: AppColors.textHint),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _showSortSheet,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.sort, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            _currentSort.label,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 3. Category Description & Count Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(_selectedCategory.icon, size: 14, color: _selectedCategory.color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _selectedCategory.description,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${filtered.length} sản phẩm',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 4. Products List or Empty State with Shared Custom Pull to Refresh
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                CustomSliverRefreshControl(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 600));
                    if (mounted) setState(() {});
                  },
                  primaryColor: AppColors.primary,
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = filtered[index];
                          return ProductCardItem(
                            product: product,
                            onEdit: () => _openEditProduct(product),
                            onToggleStatus: () => _toggleProductStatus(product),
                            onQuickUpdateStock: () => _openQuickEditStock(product),
                            onDelete: () => _deleteProduct(product),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _selectedCategory.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedCategory.icon,
                size: 38,
                color: _selectedCategory.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Không có sản phẩm "${_selectedCategory.label}"',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Không tìm thấy kết quả phù hợp với từ khóa "$_searchQuery"'
                  : _getEmptyStateHint(_selectedCategory),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_searchQuery.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Xóa tìm kiếm'),
              )
            else if (_selectedCategory == ProductCategoryType.onShelf ||
                _selectedCategory == ProductCategoryType.draft)
              ElevatedButton.icon(
                onPressed: _openAddProduct,
                icon: const Icon(Iconsax.add, size: 16),
                label: const Text('Thêm sản phẩm ngay'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 40),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getEmptyStateHint(ProductCategoryType cat) {
    switch (cat) {
      case ProductCategoryType.onShelf:
        return 'Bạn chưa có sản phẩm nào đang mở bán. Hãy thêm món ăn ngay để khách hàng có thể đặt hàng!';
      case ProductCategoryType.lowStock:
        return 'Tất cả sản phẩm hiện tại đều có lượng tồn kho an toàn.';
      case ProductCategoryType.disabled:
        return 'Không có món ăn nào đang bị vô hiệu hóa hoặc tạm ngừng bán.';
      case ProductCategoryType.underReview:
        return 'Không có sản phẩm nào đang chờ hệ thống kiểm duyệt.';
      case ProductCategoryType.failed:
        return 'Rất tốt! Không có sản phẩm nào bị từ chối phê duyệt.';
      case ProductCategoryType.frozen:
        return 'Cửa hàng không có sản phẩm nào bị đóng băng do vi phạm chính sách.';
      case ProductCategoryType.draft:
        return 'Chưa có bản nháp lưu tạm nào.';
    }
  }
}
