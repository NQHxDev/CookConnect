import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/core/network/api_exception.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:shared_widgets/shared_widgets.dart';
import '../../data/models/seller_product_item.dart';
import '../../data/services/product_api_service.dart';
import '../../data/services/product_background_queue_service.dart';
import '../widgets/category_tabs_bar.dart';
import '../widgets/all_categories_sheet.dart';
import '../widgets/product_card_item.dart';
import '../widgets/quick_edit_stock_dialog.dart';
import '../widgets/confirm_delete_product_dialog.dart';
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
  final ProductApiService? productApiService;
  final TokenStorageService? tokenStorage;
  final List<SellerProductItem>? initialProducts;

  const MenuScreen({
    super.key,
    this.productApiService,
    this.tokenStorage,
    this.initialProducts,
  });

  @override
  State<MenuScreen> createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {
  ProductCategoryType _selectedCategory = ProductCategoryType.onShelf;
  List<SellerProductItem> _products = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  ProductSortOption _currentSort = ProductSortOption.newest;
  bool _isSearchVisible = true;
  late final ProductApiService _productApiService;
  late final TokenStorageService _tokenStorage;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<ProductUploadTask>? _completedSub;
  StreamSubscription<ProductUploadTask>? _failedSub;

  @override
  void initState() {
    super.initState();
    _productApiService = widget.productApiService ?? ProductApiService();
    _tokenStorage = widget.tokenStorage ?? SecureTokenStorageService();

    ProductBackgroundQueueService.instance.addListener(_onQueueChanged);
    _completedSub =
        ProductBackgroundQueueService.instance.onTaskCompleted.listen((task) {
      if (mounted) {
        _loadProducts(showLoadingIndicator: false);
      }
    });
    _failedSub =
        ProductBackgroundQueueService.instance.onTaskFailed.listen((task) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đăng sản phẩm "${task.product.name}" thất bại: ${task.errorMessage}',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Sửa lại',
              textColor: Colors.white,
              onPressed: () => _openFixFailedProduct(task),
            ),
          ),
        );
      }
    });

    final pendingOnMount = ProductBackgroundQueueService.instance.pendingTasks
        .map((t) => t.product)
        .toList();

    if (widget.initialProducts != null) {
      _products = [...pendingOnMount, ...widget.initialProducts!];
      _isLoading = false;
    } else {
      _products = [...pendingOnMount];
      _isLoading = pendingOnMount.isEmpty;
      _loadProducts(showLoadingIndicator: pendingOnMount.isEmpty);
    }
  }

  void _onQueueChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  DateTime? _lastFetchTime;
  bool _isFetching = false;

  Future<void> _loadProducts({
    bool showLoadingIndicator = true,
    ProductCategoryType? categoryToRefresh,
  }) async {
    // 1. Throttling guard: Prevent spamming refreshes while one is active or within 1s
    if (_isFetching) return;
    final now = DateTime.now();
    if (_lastFetchTime != null && now.difference(_lastFetchTime!).inMilliseconds < 1000) {
      debugPrint('Throttling refresh: too frequent');
      return;
    }
    _lastFetchTime = now;
    _isFetching = true;

    // 2. Only show full-screen spinner if we have NO data yet
    if (showLoadingIndicator && _products.isEmpty && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      AuthTokens? activeTokens = SellerAuthService.instance.tokens;
      activeTokens ??= await _tokenStorage.getTokens();

      String? token;
      if (activeTokens != null) {
        if (!activeTokens.isAccessTokenExpired()) {
          token = activeTokens.accessToken;
        } else if (activeTokens.refreshToken.isNotEmpty &&
            !activeTokens.isRefreshTokenExpired()) {
          token = await SellerAuthService.instance.refreshAccessToken();
        } else {
          token = activeTokens.accessToken;
        }
      }
      final String? supplierId = SellerAuthService.instance.supplierProfile?.supplierId;

      List<ProductItemDto> dtoList;
      if (categoryToRefresh != null) {
        // Targeted query: only 1-2 status pairs for active tab, avoiding server rate limits!
        dtoList = await _productApiService.fetchProductsForCategory(
          category: categoryToRefresh,
          token: token,
          supplierId: (supplierId != null && supplierId.isNotEmpty) ? supplierId : null,
        );
      } else {
        // Full catalog query across all pairs
        dtoList = await _productApiService.fetchAllSupplierProducts(
          token: token,
          supplierId: (supplierId != null && supplierId.isNotEmpty) ? supplierId : null,
        );
      }

      if (mounted) {
        setState(() {
          final freshItems = dtoList.map((dto) => dto.toSellerProductItem()).toList();

          // Retain products that are currently pending background submission and not yet in server list
          final pendingProducts = ProductBackgroundQueueService.instance.pendingTasks
              .map((t) => t.product)
              .where((pendingProd) => !freshItems.any((serverItem) =>
                  serverItem.id == pendingProd.id ||
                  (pendingProd.sku.isNotEmpty && serverItem.sku == pendingProd.sku)))
              .toList();

          final merged = [...pendingProducts, ...freshItems];

          if (categoryToRefresh != null) {
            // Stale-while-revalidate merge: preserve other categories, update target category
            final unaffected = _products.where((p) => p.categoryType != categoryToRefresh).toList();
            _products = [...unaffected, ...merged.where((p) => p.categoryType == categoryToRefresh)];
          } else {
            _products = merged;
          }
          _errorMessage = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load products from backend error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // IMPORTANT: Only show error view if user has NO products at all!
          // If user already has products, KEEP the products on screen without wiping!
          if (_products.isEmpty) {
            _errorMessage = e is ApiException
                ? e.message
                : 'Không thể kết nối với máy chủ. Vui lòng kiểm tra mạng và thử lại.';
          }
        });

        final isRateLimit = e is ApiException &&
            (e.statusCode == 429 ||
                e.errorCode == 'COMMON.TOO_MANY_REQUESTS' ||
                e.message.contains('429'));
        final message = isRateLimit
            ? 'Bạn thao tác quá nhanh, máy chủ đang tạm giới hạn (429). Dữ liệu hiện tại được giữ nguyên.'
            : 'Không thể làm mới danh sách (${e is ApiException ? e.message : e.toString()}). Đang hiển thị dữ liệu đã lưu.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isRateLimit ? AppColors.warning : null,
            action: _products.isEmpty
                ? SnackBarAction(
                    label: 'Thử lại',
                    textColor: Colors.white,
                    onPressed: () => _loadProducts(showLoadingIndicator: true),
                  )
                : null,
          ),
        );
      }
    } finally {
      _isFetching = false;
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  @visibleForTesting
  Future<void> debugReloadProducts() async {
    _lastFetchTime = null;
    _isFetching = false;
    await _loadProducts(
      showLoadingIndicator: false,
      categoryToRefresh: _selectedCategory,
    );
  }

  @override
  void dispose() {
    ProductBackgroundQueueService.instance.removeListener(_onQueueChanged);
    _completedSub?.cancel();
    _failedSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFixFailedProduct(ProductUploadTask task) async {
    final String? currentSupplierId = task.supplierId.isNotEmpty
        ? task.supplierId
        : (SellerAuthService.instance.supplierProfile?.supplierId ??
            SellerAuthService.instance.currentUser?.storeId);

    await Navigator.of(context).push<SellerProductItem>(
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          initialProduct: task.product,
          initialImages: task.originalImages,
          failedTaskId: task.id,
          productApiService: _productApiService,
          tokenStorage: _tokenStorage,
          supplierId: (currentSupplierId != null && currentSupplierId.isNotEmpty)
              ? currentSupplierId
              : null,
        ),
      ),
    );
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
    final String? currentSupplierId = SellerAuthService.instance.supplierProfile?.supplierId ??
        SellerAuthService.instance.currentUser?.storeId;

    final newProduct = await Navigator.of(context).push<SellerProductItem>(
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          productApiService: _productApiService,
          tokenStorage: _tokenStorage,
          supplierId: (currentSupplierId != null && currentSupplierId.isNotEmpty)
              ? currentSupplierId
              : null,
        ),
      ),
    );

    if (newProduct != null && mounted) {
      setState(() {
        // Đẩy ngay card sản phẩm mới ra ngoài danh sách (vị trí đầu tiên)
        _products.removeWhere((p) => p.id == newProduct.id);
        _products.insert(0, newProduct);
        // Chuyển tab sang trạng thái của sản phẩm mới (thường là Đang xét duyệt) để card hiện ra ngay
        _selectedCategory = newProduct.categoryType;
        _isLoading = false;
        _errorMessage = null;
      });
      // Mặc định xem như thành công, im luôn không hiển thị thanh quay quay và không thông báo thừa
    }
  }

  Future<void> _openEditProduct(SellerProductItem product) async {
    final String? currentSupplierId = product.supplierId ??
        SellerAuthService.instance.supplierProfile?.supplierId ??
        SellerAuthService.instance.currentUser?.storeId;

    final updatedProduct = await Navigator.of(context).push<SellerProductItem>(
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          initialProduct: product,
          productApiService: _productApiService,
          tokenStorage: _tokenStorage,
          supplierId: (currentSupplierId != null && currentSupplierId.isNotEmpty)
              ? currentSupplierId
              : null,
        ),
      ),
    );

    if (updatedProduct != null && mounted) {
      setState(() {
        final idx = _products.indexWhere((p) => p.id == updatedProduct.id);
        if (idx != -1) {
          _products[idx] = updatedProduct;
        } else {
          _products.insert(0, updatedProduct);
        }
        _selectedCategory = updatedProduct.categoryType;
        _isLoading = false;
      });
      // Im luôn theo Optimistic UI, không thanh quay quay và không thông báo thừa
    }
  }

  void _openQuickEditStock(SellerProductItem product) {
    QuickEditStockDialog.show(
      context: context,
      product: product,
      onSave: (newStock, newPrice) async {
        final delta = newStock - product.stock;
        final previousProducts = List<SellerProductItem>.from(_products);

        setState(() {
          final idx = _products.indexWhere((p) => p.id == product.id);
          if (idx != -1) {
            ProductCategoryType newCategory = product.categoryType;
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

        try {
          final token = await SellerAuthService.instance.getValidAccessToken() ??
              (await _tokenStorage.getTokens())?.accessToken;
          if (token != null && token.isNotEmpty) {
            final variantId = product.skus.isNotEmpty ? product.skus.first.id : null;
            if (variantId != null && delta != 0) {
              await _productApiService.adjustStock(
                token: token,
                variantId: variantId,
                quantityDelta: delta,
                movementType: 'ADJUSTMENT',
                reason: 'Cập nhật nhanh từ ứng dụng',
              );
            }
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật tồn kho & giá thành công!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error updating stock: $e');
          if (mounted) {
            setState(() {
              _products = previousProducts;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi cập nhật tồn kho: ${e is ApiException ? e.message : e.toString()}'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _toggleProductStatus(SellerProductItem product) async {
    final willActivate = product.categoryType == ProductCategoryType.disabled;
    final targetStatus = willActivate ? 'ACTIVE' : 'INACTIVE';
    final previousProducts = List<SellerProductItem>.from(_products);

    setState(() {
      final idx = _products.indexWhere((p) => p.id == product.id);
      if (idx != -1) {
        final newCat = willActivate
            ? (product.stock <= 5 ? ProductCategoryType.lowStock : ProductCategoryType.onShelf)
            : ProductCategoryType.disabled;
        _products[idx] = product.copyWith(
          categoryType: newCat,
          isAvailable: willActivate,
          status: targetStatus,
        );
      }
    });

    try {
      final token = await SellerAuthService.instance.getValidAccessToken() ??
          (await _tokenStorage.getTokens())?.accessToken;
      if (token != null && token.isNotEmpty) {
        await _productApiService.updateProductStatus(
          token: token,
          productId: product.id,
          status: targetStatus,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(willActivate
                ? 'Đã mở bán lại "${product.name}"'
                : 'Đã tạm ngưng kinh doanh "${product.name}"'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating product status: $e');
      if (mounted) {
        setState(() {
          _products = previousProducts;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật trạng thái: ${e is ApiException ? e.message : e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _deleteProduct(SellerProductItem product) {
    ConfirmDeleteProductDialog.show(
      context: context,
      product: product,
      onConfirm: () async {
        final previousProducts = List<SellerProductItem>.from(_products);
        setState(() {
          _products.removeWhere((p) => p.id == product.id);
        });
        try {
          final token = await SellerAuthService.instance.getValidAccessToken() ??
              (await _tokenStorage.getTokens())?.accessToken;
          if (token != null && token.isNotEmpty) {
            await _productApiService.updateProductStatus(
              token: token,
              productId: product.id,
              status: 'INACTIVE',
            );
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã ngừng bán sản phẩm thành công'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error deactivating product: $e');
          if (mounted) {
            setState(() {
              _products = previousProducts;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi ngừng bán sản phẩm: ${e is ApiException ? e.message : e.toString()}'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _duplicateProduct(SellerProductItem product) async {
    final String? currentSupplierId = product.supplierId ??
        SellerAuthService.instance.supplierProfile?.supplierId ??
        SellerAuthService.instance.currentUser?.storeId;

    final duplicatedProduct = product.copyWith(
      id: '',
      sku: '${product.sku}-COPY',
      name: '${product.name} (Bản sao)',
    );

    final result = await Navigator.of(context).push<SellerProductItem>(
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          initialProduct: duplicatedProduct,
          productApiService: _productApiService,
          tokenStorage: _tokenStorage,
          supplierId: (currentSupplierId != null && currentSupplierId.isNotEmpty)
              ? currentSupplierId
              : null,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _products.insert(0, result);
        _selectedCategory = result.categoryType;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo bản sao sản phẩm "${result.name}" thành công!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _shareProduct(SellerProductItem product) {
    final displayPrice = product.hasMultipleSkus
        ? '${product.minPrice.round()} - ${product.maxPrice.round()} đ'
        : '${product.price.round()} đ';
    final shareContent = '🍴 ${product.name}\n💰 Giá: $displayPrice\n🏷️ Mã SKU: ${product.sku}\n📦 Danh mục: ${product.foodCategory}';
    Clipboard.setData(ClipboardData(text: shareContent));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.tick_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Đã sao chép thông tin "${product.name}" vào bộ nhớ tạm'),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
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

          // 3.5 Background upload queue status (Active & Failed tasks)
          _buildQueueStatusBanners(),

          // 4. Products List or Empty State with Shared Custom Pull to Refresh
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                CustomSliverRefreshControl(
                  onRefresh: () async {
                    await _loadProducts(
                      showLoadingIndicator: false,
                      categoryToRefresh: _selectedCategory,
                    );
                  },
                  primaryColor: AppColors.primary,
                ),
                if (_isLoading && _products.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Đang tải danh sách sản phẩm từ máy chủ...',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_errorMessage != null && _products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(),
                  )
                else if (filtered.isEmpty)
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
                            onDuplicate: () => _duplicateProduct(product),
                            onShare: () => _shareProduct(product),
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

  Widget _buildErrorState() {
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
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.warning_2,
                size: 38,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải sản phẩm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi khi kết nối với máy chủ.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadProducts(showLoadingIndicator: true),
              icon: const Icon(Iconsax.refresh, size: 16),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 40),
              ),
            ),
          ],
        ),
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

  Widget _buildQueueStatusBanners() {
    final queue = ProductBackgroundQueueService.instance;
    final failedTasks = queue.failedTasks;

    if (failedTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Failed tasks reporting banners
        for (final task in failedTasks)
          Container(
            key: Key('bg_task_failed_${task.id}'),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Iconsax.warning_2, color: AppColors.error, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đăng sản phẩm "${task.product.name}" thất bại',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        task.errorMessage ?? 'Đã xảy ra lỗi khi đăng sản phẩm',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB91C1C),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            key: Key('fix_failed_product_btn_${task.id}'),
                            onPressed: () => _openFixFailedProduct(task),
                            icon: const Icon(Iconsax.edit_2, size: 13, color: Colors.white),
                            label: const Text(
                              'Sửa & Thử lại',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: const Size(0, 28),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            key: Key('dismiss_failed_product_btn_${task.id}'),
                            onPressed: () {
                              ProductBackgroundQueueService.instance.dismissFailedTask(task.id);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              minimumSize: const Size(0, 28),
                              foregroundColor: Colors.grey.shade600,
                            ),
                            child: const Text(
                              'Bỏ qua',
                              style: TextStyle(fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Color(0xFF991B1B)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 16,
                  onPressed: () {
                    ProductBackgroundQueueService.instance.dismissFailedTask(task.id);
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
