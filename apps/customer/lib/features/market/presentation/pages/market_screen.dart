import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/navigation/app_tab_navigator.dart';
import 'package:cookconnect/features/market/presentation/widgets/fly_to_cart_animation.dart';
import 'package:cookconnect/features/market/presentation/widgets/product_detail_bottom_sheet.dart';
import 'package:cookconnect/features/order/presentation/pages/my_orders_screen.dart';
import 'package:cookconnect/features/order/presentation/pages/order_checkout_screen.dart';
import 'package:cookconnect/features/recipe/data/models/product_search_model.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/services/product_search_service.dart';
import 'package:cookconnect/features/recipe/data/services/recipe_data_service.dart';
import 'package:cookconnect/features/recipe/presentation/pages/user_video_feed_screen.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/add_shopping_item_bottom_sheet.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/ingredients_bottom_sheet.dart';

class MarketScreen extends StatefulWidget {
  final int initialTabIndex;
  final ProductSearchService? productSearchService;

  const MarketScreen({
    super.key,
    this.initialTabIndex = 0,
    this.productSearchService,
  });

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ProductSearchService _productSearchService;
  final RecipeDataService _dataService = RecipeDataService.instance;

  // Tab 0 State (Shopping List)
  final TextEditingController _quickAddController = TextEditingController();
  final FocusNode _quickAddFocusNode = FocusNode();
  String _selectedListFilter = 'all'; // 'all', 'uncompleted', 'completed'
  bool _groupByRecipe = true;

  // Quick suggestions staples loaded dynamically from live API
  List<ProductSearchItemDto> _quickStaples = [];

  // Tab 1 State (Fresh Market Catalog)
  final TextEditingController _marketSearchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isLoadingMarket = false;
  String? _marketErrorMessage;
  String? _selectedCategoryCode;
  List<ProductSearchItemDto> _marketProducts = [];
  List<ProductSuggestionItemDto> _searchSuggestions = [];

  // Categories from WHO standard backend endpoint
  List<WhoCategoryDto> _categories = [];

  @override
  void initState() {
    super.initState();
    _productSearchService =
        widget.productSearchService ?? ProductSearchService();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _loadCategories();
    _loadQuickStaples();

    AppTabNavigator.instance.addListener(_handleNavigationRequest);
    final pending = AppTabNavigator.instance.consumeMarketRequest();
    if (pending?.searchQuery != null) {
      _applyNavigationRequest(pending!);
    } else {
      if (pending != null) _applyNavigationRequest(pending);
      _loadMarketProducts();
    }
  }

  // ==========================================
  // LIÊN KẾT TỪ FEED (AppTabNavigator)
  // ==========================================
  void _handleNavigationRequest() {
    final request = AppTabNavigator.instance.consumeMarketRequest();
    if (request == null || !mounted) return;
    _applyNavigationRequest(request);
  }

  void _applyNavigationRequest(MarketNavigationRequest request) {
    _tabController.animateTo(request.tabIndex.clamp(0, 1));
    final query = request.searchQuery?.trim();
    if (query != null && query.isNotEmpty) {
      _searchDebounce?.cancel();
      _marketSearchController.text = query;
      _marketSearchController.selection = TextSelection.collapsed(
        offset: query.length,
      );
      _selectedCategoryCode = null;
      _searchSuggestions = [];
      _loadMarketProducts(query: query);
    } else if (request.tabIndex == 0 && mounted) {
      setState(() {
        _selectedListFilter = 'all';
        _groupByRecipe = true;
      });
    }
  }

  void _openSourceIngredients(String postId, String title) {
    final post = _dataService.linkedPost(postId);
    showIngredientsBottomSheet(
      context,
      recipeTitle: post?.title ?? title,
      ingredients: post?.ingredients ?? const [],
      postId: postId,
      post: post,
    );
  }

  void _openSourceVideo(String postId) {
    final post = _dataService.linkedPost(postId);
    if (post == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UserVideoFeedScreen(posts: [post])),
    );
  }

  @override
  void dispose() {
    AppTabNavigator.instance.removeListener(_handleNavigationRequest);
    _tabController.dispose();
    _quickAddController.dispose();
    _quickAddFocusNode.dispose();
    _marketSearchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ==========================================
  // REAL API DATA LOADERS
  // ==========================================
  Future<void> _loadCategories({bool forceRefresh = false}) async {
    try {
      final cats = await _productSearchService.getCategories(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _categories = cats;
      });
    } catch (_) {}
  }

  Future<void> _loadQuickStaples() async {
    try {
      final response = await _productSearchService.searchProducts(
        limit: 8,
        status: 'ACTIVE',
      );
      if (!mounted) return;
      setState(() {
        _quickStaples = response.items;
      });
    } catch (_) {}
  }

  Future<void> _loadMarketProducts({String? query}) async {
    setState(() {
      _isLoadingMarket = true;
      _marketErrorMessage = null;
    });

    try {
      final response = await _productSearchService.searchProducts(
        query: query,
        whoCategoryCode: _selectedCategoryCode,
        limit: 30,
      );

      if (!mounted) return;

      setState(() {
        _marketProducts = response.items;
        _isLoadingMarket = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _marketProducts = [];
        _isLoadingMarket = false;
        _marketErrorMessage =
            'Không thể kết nối với máy chủ. Vui lòng kiểm tra lại mạng.';
      });
    }
  }

  void _onMarketSearchChanged(String val) {
    _searchDebounce?.cancel();
    final query = val.trim();

    if (query.isNotEmpty) {
      _fetchSearchSuggestions(query);
    } else {
      setState(() {
        _searchSuggestions = [];
      });
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadMarketProducts(query: query.isEmpty ? null : query);
    });
  }

  Future<void> _fetchSearchSuggestions(String query) async {
    try {
      final suggestions = await _productSearchService.suggestProducts(
        query: query,
        limit: 5,
      );
      if (!mounted) return;
      if (_marketSearchController.text.trim().isNotEmpty) {
        setState(() {
          _searchSuggestions = suggestions;
        });
      }
    } catch (_) {
      // Suggestion failure should not break search flow
    }
  }

  void _selectSuggestion(ProductSuggestionItemDto suggestion) {
    _marketSearchController.text = suggestion.productName;
    _marketSearchController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.productName.length),
    );
    setState(() {
      _searchSuggestions = [];
    });
    FocusScope.of(context).unfocus();
    _loadMarketProducts(query: suggestion.productName);
  }

  // ==========================================
  // SHOPPING LIST ACTIONS
  // ==========================================
  void _quickAddIngredient([String? text]) {
    final value = (text ?? _quickAddController.text).trim();
    if (value.isEmpty) return;

    final newItem = ShoppingItem(
      id: 'quick_${DateTime.now().millisecondsSinceEpoch}',
      name: value,
      amount: '1 phần',
      recipeSource: 'Tự thêm',
      price: 0,
      isCompleted: false,
    );

    _dataService.addShoppingItem(newItem);
    _quickAddController.clear();
    HapticFeedback.lightImpact();
  }

  void _addProductToShoppingList(
    ProductSearchItemDto product, [
    BuildContext? sourceContext,
  ]) {
    if (sourceContext != null) FlyToCartAnimation.run(sourceContext);
    final variant = product.variants.isNotEmpty ? product.variants.first : null;
    final unit = variant?.unit ?? 'phần';
    String pack = variant?.packSize ?? '';
    if (pack.isEmpty) {
      pack = '1 $unit';
    } else if (!pack.contains(unit) && unit.isNotEmpty) {
      pack = '$pack $unit';
    }
    final price = variant?.price ?? product.minPrice ?? 0;

    final newItem = ShoppingItem(
      id: '${product.productId}_${DateTime.now().millisecondsSinceEpoch}',
      name: product.productName,
      amount: pack,
      recipeSource: 'Chợ CookConnect',
      imageUrl: product.images.isNotEmpty ? product.images.first : null,
      price: price,
      unit: unit,
      productId: product.productId,
      supplierId: product.supplierId,
      category: product.whoCategoryCode,
      isCompleted: false,
    );

    _dataService.addShoppingItem(newItem);
    HapticFeedback.mediumImpact();
  }

  Future<void> _showAddCustomDialog() async {
    final newItem = await AddShoppingItemBottomSheet.show(context);
    if (newItem != null && mounted) {
      _dataService.addShoppingItem(newItem);
    }
  }

  Future<void> _navigateToCheckout(List<ShoppingItem> uncompletedItems) async {
    if (uncompletedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tất cả sản phẩm đã được đánh dấu đã mua!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OrderCheckoutScreen(items: uncompletedItems),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  String _formatPrice(num value) {
    final formatted = value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formatted đ';
  }

  // ==========================================
  // BUILD METHOD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Iconsax.shopping_cart, color: primaryColor, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đi chợ CookConnect',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Sổ tay nguyên liệu & Chợ tươi',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Order tracking shortcut
          IconButton(
            icon: const Icon(Iconsax.truck_fast, color: Color(0xFF0F172A)),
            tooltip: 'Đơn hàng của tôi',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
            },
          ),
          // More options menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF0F172A)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) {
              if (value == 'add') {
                _showAddCustomDialog();
              } else if (value == 'clear_completed') {
                _dataService.clearCompletedShoppingItems();
              } else if (value == 'mark_all_done') {
                _dataService.markAllShoppingItemsCompleted(completed: true);
              } else if (value == 'uncheck_all') {
                _dataService.markAllShoppingItemsCompleted(completed: false);
              } else if (value == 'clear_all') {
                _confirmClearAll();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Iconsax.add_circle, size: 18, color: Colors.black87),
                    SizedBox(width: 10),
                    Text('Thêm nguyên liệu mới'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_completed',
                child: Row(
                  children: [
                    Icon(Iconsax.trash, size: 18, color: Colors.orange),
                    SizedBox(width: 10),
                    Text('Xoá các món đã mua'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mark_all_done',
                child: Row(
                  children: [
                    Icon(Iconsax.tick_circle, size: 18, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Đánh dấu tất cả đã mua'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'uncheck_all',
                child: Row(
                  children: [
                    Icon(Iconsax.refresh, size: 18, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Bỏ chọn tất cả'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Iconsax.trash, size: 18, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      'Xoá toàn bộ danh sách',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
              ),
            ),
            child: AnimatedBuilder(
              animation: _dataService,
              builder: (context, _) {
                final uncompletedCount = _dataService.shoppingList
                    .where((i) => !i.isCompleted)
                    .length;

                return TabBar(
                  controller: _tabController,
                  indicatorColor: primaryColor,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.clipboard_text, size: 17),
                          const SizedBox(width: 6),
                          Text('Cần mua ($uncompletedCount)'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Iconsax.shop, size: 17),
                          SizedBox(width: 6),
                          Text('Chợ thực phẩm'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShoppingListTab(primaryColor),
          _buildMarketCatalogTab(primaryColor),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 0: DANH SÁCH CẦN MUA (SHOPPING LIST)
  // ==========================================
  Widget _buildShoppingListTab(Color primaryColor) {
    return AnimatedBuilder(
      animation: _dataService,
      builder: (context, _) {
        final allItems = _dataService.shoppingList;
        final uncompletedItems = allItems.where((i) => !i.isCompleted).toList();
        final completedItems = allItems.where((i) => i.isCompleted).toList();

        List<ShoppingItem> displayItems;
        if (_selectedListFilter == 'uncompleted') {
          displayItems = uncompletedItems;
        } else if (_selectedListFilter == 'completed') {
          displayItems = completedItems;
        } else {
          displayItems = allItems;
        }

        num uncompletedTotal = 0;
        for (final item in uncompletedItems) {
          uncompletedTotal += (item.price ?? 35000) * item.quantity;
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                children: [
                  // 1. Order tracking banner
                  _buildOrderBanner(primaryColor),
                  const SizedBox(height: 12),

                  // 2. Shopping progress card
                  _buildProgressCard(
                    primaryColor: primaryColor,
                    totalCount: allItems.length,
                    completedCount: completedItems.length,
                    uncompletedTotal: uncompletedTotal,
                    uncompletedItems: uncompletedItems,
                  ),
                  const SizedBox(height: 14),

                  // 3. Quick add bar & staple chips
                  _buildQuickAddBar(primaryColor),
                  const SizedBox(height: 14),

                  // 4. Filter chips & group toggle
                  if (allItems.isNotEmpty)
                    _buildFilterRow(
                      allItems: allItems,
                      uncompletedItems: uncompletedItems,
                      completedItems: completedItems,
                      primaryColor: primaryColor,
                    ),

                  const SizedBox(height: 10),

                  // 5. Items list or empty state
                  if (allItems.isEmpty)
                    _buildEmptyShoppingList(primaryColor)
                  else if (displayItems.isEmpty)
                    _buildNoFilterMatches()
                  else if (_groupByRecipe)
                    ..._buildGroupedItems(displayItems, primaryColor)
                  else
                    ...displayItems.map(
                      (item) => _buildItemTile(item, primaryColor),
                    ),
                ],
              ),
            ),

            // Bottom Sticky Checkout Bar
            if (uncompletedItems.isNotEmpty)
              _buildBottomCheckoutBar(
                primaryColor: primaryColor,
                uncompletedItems: uncompletedItems,
                uncompletedTotal: uncompletedTotal,
              ),
          ],
        );
      },
    );
  }

  // 1. Order tracking banner
  Widget _buildOrderBanner(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.08),
            Colors.orange.shade50.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.truck_fast,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theo dõi đơn hàng đã đặt',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Xem tiến độ giao hàng & lịch sử đi chợ',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 2. Shopping progress card
  Widget _buildProgressCard({
    required Color primaryColor,
    required int totalCount,
    required int completedCount,
    required num uncompletedTotal,
    required List<ShoppingItem> uncompletedItems,
  }) {
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;
    final isAllCompleted = totalCount > 0 && completedCount == totalCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiến độ mua sắm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Nguyên liệu cho các bữa ăn',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isAllCompleted
                      ? Colors.green.withValues(alpha: 0.1)
                      : primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$completedCount/$totalCount món (${(progress * 100).toInt()}%)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isAllCompleted ? Colors.green : primaryColor,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                isAllCompleted ? Colors.green : primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _showAddCustomDialog,
                icon: const Icon(Iconsax.add, size: 16),
                label: const Text(
                  'Thêm món',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              if (uncompletedItems.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => _navigateToCheckout(uncompletedItems),
                  icon: const Icon(Iconsax.bag_2, size: 16),
                  label: Text(
                    'Đặt mua (${uncompletedItems.length})',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              if (completedCount > 0)
                TextButton.icon(
                  onPressed: () => _dataService.clearCompletedShoppingItems(),
                  icon: const Icon(Iconsax.trash, size: 15, color: Colors.red),
                  label: const Text(
                    'Dọn đã mua',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Quick add bar & staple chips
  Widget _buildQuickAddBar(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Iconsax.add_circle, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _quickAddController,
                  focusNode: _quickAddFocusNode,
                  onSubmitted: (_) => _quickAddIngredient(),
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Thêm nhanh (VD: 500g sườn non, hành tím...)',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                color: primaryColor,
                onPressed: () => _quickAddIngredient(),
                tooltip: 'Thêm',
              ),
            ],
          ),
        ),
        if (_quickStaples.isNotEmpty) ...[
          const SizedBox(height: 8),
          // Staples carousel from real products
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _quickStaples.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final product = _quickStaples[index];
                final icon = _getCategoryEmoji(product.whoCategoryCode);
                return InkWell(
                  onTap: () => _addProductToShoppingList(product, context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '+ ${product.productName}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // 4. Filter chips & group toggle
  Widget _buildFilterRow({
    required List<ShoppingItem> allItems,
    required List<ShoppingItem> uncompletedItems,
    required List<ShoppingItem> completedItems,
    required Color primaryColor,
  }) {
    return Row(
      children: [
        _buildFilterChip(
          label: 'Tất cả (${allItems.length})',
          value: 'all',
          primaryColor: primaryColor,
        ),
        const SizedBox(width: 6),
        _buildFilterChip(
          label: 'Chưa mua (${uncompletedItems.length})',
          value: 'uncompleted',
          primaryColor: primaryColor,
        ),
        const SizedBox(width: 6),
        _buildFilterChip(
          label: 'Đã mua (${completedItems.length})',
          value: 'completed',
          primaryColor: primaryColor,
        ),
        const Spacer(),
        // Group toggle button
        IconButton(
          icon: Icon(
            _groupByRecipe ? Iconsax.category5 : Iconsax.category,
            size: 18,
            color: _groupByRecipe ? primaryColor : Colors.grey,
          ),
          tooltip: _groupByRecipe ? 'Xem dạng phẳng' : 'Gộp theo món ăn',
          onPressed: () {
            setState(() {
              _groupByRecipe = !_groupByRecipe;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required Color primaryColor,
  }) {
    final isSelected = _selectedListFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedListFilter = value;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? primaryColor : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // 5. Grouped Items
  List<Widget> _buildGroupedItems(
    List<ShoppingItem> items,
    Color primaryColor,
  ) {
    final Map<String, List<ShoppingItem>> grouped = {};
    for (final item in items) {
      final key = item.recipeSource.isEmpty ? 'Tự thêm' : item.recipeSource;
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final List<Widget> widgets = [];
    grouped.forEach((source, sourceItems) {
      final linkedItem = sourceItems.cast<ShoppingItem?>().firstWhere(
        (i) => i!.sourcePostId != null && i.sourcePostId!.isNotEmpty,
        orElse: () => null,
      );

      if (linkedItem != null) {
        widgets.add(
          _buildRecipeSourceHeader(
            title: source,
            postId: linkedItem.sourcePostId!,
            thumbnailUrl: linkedItem.sourceThumbnailUrl,
            items: sourceItems,
            primaryColor: primaryColor,
          ),
        );
        for (final item in sourceItems) {
          widgets.add(_buildItemTile(item, primaryColor));
        }
        return;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Row(
            children: [
              Icon(
                source == 'Tự thêm' || source == 'Gợi ý cần thiết'
                    ? Iconsax.edit_2
                    : Iconsax.book_1,
                size: 14,
                color: primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                source,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${sourceItems.length}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      for (final item in sourceItems) {
        widgets.add(_buildItemTile(item, primaryColor));
      }
    });

    return widgets;
  }

  /// Header cho nhóm nguyên liệu được thêm từ một video công thức trên Feed.
  Widget _buildRecipeSourceHeader({
    required String title,
    required String postId,
    required String? thumbnailUrl,
    required List<ShoppingItem> items,
    required Color primaryColor,
  }) {
    final completed = items.where((i) => i.isCompleted).length;
    final hasVideo = _dataService.linkedPost(postId) != null;

    Widget fallbackThumb() => Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A1A), Color(0xFFFF2D55)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Iconsax.video_play, color: Colors.white, size: 20),
    );

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF4EC),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD9BF)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openSourceIngredients(postId, title),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                      ? Image.network(
                          thumbnailUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              fallbackThumb(),
                        )
                      : fallbackThumb(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TỪ VIDEO CÔNG THỨC',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: Color(0xFFFF7A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$completed/${items.length} đã mua · Chạm để xem nguyên liệu',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (hasVideo)
                  IconButton(
                    tooltip: 'Xem lại video',
                    onPressed: () => _openSourceVideo(postId),
                    icon: const Icon(
                      Iconsax.play_circle5,
                      color: Color(0xFFFF2D55),
                      size: 28,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 6. Individual Item Tile
  Widget _buildItemTile(ShoppingItem item, Color primaryColor) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(right: 18),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Iconsax.trash, color: Colors.white, size: 20),
      ),
      onDismissed: (_) {
        _dataService.removeShoppingItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xoá "${item.name}"'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Hoàn tác',
              onPressed: () {
                _dataService.addShoppingItem(item);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: item.isCompleted ? const Color(0xFFF9FAFB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isCompleted
                ? Colors.grey.withValues(alpha: 0.15)
                : primaryColor.withValues(alpha: 0.22),
            width: item.isCompleted ? 1 : 1.2,
          ),
          boxShadow: item.isCompleted
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 2,
          ),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: item.isCompleted,
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (_) {
                  _dataService.toggleShoppingItem(item.id);
                },
              ),
              if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item.imageUrl!,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackCategoryIcon(primaryColor),
                  ),
                )
              else
                _buildFallbackCategoryIcon(primaryColor),
            ],
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
              color: item.isCompleted
                  ? Colors.grey[500]
                  : const Color(0xFF0F172A),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                item.sourcePostId != null
                    ? item.amount
                    : '${item.amount} • ${item.recipeSource}',
                style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
              ),
              if (item.productId == null && !item.isCompleted) ...[
                const SizedBox(height: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _applyNavigationRequest(
                    MarketNavigationRequest(
                      tabIndex: 1,
                      searchQuery: item.name,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.shop, size: 12, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Tìm mua ở Chợ',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (item.price != null && item.price! > 0) ...[
                const SizedBox(height: 2),
                Text(
                  item.formattedPrice,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: item.isCompleted ? Colors.grey[500] : primaryColor,
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quantity stepper
              if (!item.isCompleted) ...[
                InkWell(
                  onTap: () {
                    _dataService.updateShoppingItemQuantity(item.id, -1);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.remove,
                      size: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _dataService.updateShoppingItemQuantity(item.id, 1);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.add, size: 14, color: primaryColor),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                onPressed: () => _dataService.removeShoppingItem(item.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackCategoryIcon(Color primaryColor) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Iconsax.bag_2, color: primaryColor, size: 20),
    );
  }

  // 7. Empty State
  Widget _buildEmptyShoppingList(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.bag_2, size: 44, color: primaryColor),
          ),
          const SizedBox(height: 18),
          const Text(
            'Chưa có thực phẩm nào cần mua',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lên kế hoạch đi chợ thông minh bằng cách lưu công thức nấu ăn hoặc chọn mua trực tiếp từ Chợ thực phẩm CookConnect.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _showAddCustomDialog,
                icon: const Icon(Iconsax.add, size: 16),
                label: const Text('+ Thêm món'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                icon: const Icon(Iconsax.shop, size: 16),
                label: const Text('Dạo Chợ tươi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoFilterMatches() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: const Text(
        'Không có món nào trong mục này',
        style: TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }

  // 8. Sticky Checkout Bar
  Widget _buildBottomCheckoutBar({
    required Color primaryColor,
    required List<ShoppingItem> uncompletedItems,
    required num uncompletedTotal,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${uncompletedItems.length} món chưa mua',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ước tính: ${_formatPrice(uncompletedTotal)}',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _navigateToCheckout(uncompletedItems),
              icon: const Icon(Iconsax.bag_tick, size: 18),
              label: Text(
                'Đặt hàng ngay (${uncompletedItems.length})',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: CHỢ NGUYÊN LIỆU TƯƠI (MARKET CATALOG)
  // ==========================================
  Widget _buildMarketCatalogTab(Color primaryColor) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          _loadCategories(forceRefresh: true),
          _loadMarketProducts(
            query: _marketSearchController.text.trim().isEmpty
                ? null
                : _marketSearchController.text.trim(),
          ),
        ]);
      },
      child: Column(
        children: [
          // Search & Categories Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              children: [
                _buildSearchField(primaryColor),
                const SizedBox(height: 10),
                _buildCategorySelector(primaryColor),
              ],
            ),
          ),

          // Products Grid, Loading, Error, or Empty State
          Expanded(
            child: _isLoadingMarket
                ? const Center(child: CircularProgressIndicator())
                : _marketErrorMessage != null
                ? _buildMarketError()
                : _marketProducts.isEmpty
                ? _buildNoMarketProducts()
                : GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _marketProducts.length,
                    itemBuilder: (context, index) {
                      final product = _marketProducts[index];
                      return _buildProductCard(product, primaryColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: _marketSearchController,
            onChanged: _onMarketSearchChanged,
            onSubmitted: (val) {
              _searchDebounce?.cancel();
              setState(() {
                _searchSuggestions = [];
              });
              _loadMarketProducts(
                query: val.trim().isEmpty ? null : val.trim(),
              );
            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: const Icon(
                Iconsax.search_normal_1,
                size: 18,
                color: Colors.grey,
              ),
              suffixIcon: _marketSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        _marketSearchController.clear();
                        setState(() {
                          _searchSuggestions = [];
                        });
                        _loadMarketProducts();
                      },
                    )
                  : null,
              hintText: 'Tìm thịt, rau củ, hải sản, gia vị...',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
        if (_searchSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _searchSuggestions.map((sug) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectSuggestion(sug),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.search_normal_1,
                              size: 15,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                sug.productName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (sug.formattedPrice.isNotEmpty)
                              Text(
                                sug.formattedPrice,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategorySelector(Color primaryColor) {
    // Combine 'Tất cả' with server WHO categories or fallback standard categories
    final List<WhoCategoryDto> list = _categories.isNotEmpty
        ? _categories
        : _defaultWhoCategories;

    final allCategory = WhoCategoryDto(
      code: '',
      name: 'Tất cả',
      description: '',
      examples: '',
      order: 0,
    );

    final displayList = [allCategory, ...list];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: displayList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cat = displayList[index];
          final catCode = cat.code.isEmpty ? null : cat.code;
          final isSelected = _selectedCategoryCode == catCode;
          final icon = cat.code.isEmpty ? '🛒' : cat.icon;
          final name = cat.code.isEmpty ? 'Tất cả' : cat.shortName;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategoryCode = catCode;
                _searchSuggestions = [];
              });
              _loadMarketProducts(
                query: _marketSearchController.text.trim().isEmpty
                    ? null
                    : _marketSearchController.text.trim(),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : Colors.grey.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static final List<WhoCategoryDto> _defaultWhoCategories = [
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
    WhoCategoryDto(
      code: 'OTHER_FRUITS_VEG',
      name: 'Rau củ và quả khác',
      order: 3,
    ),
    WhoCategoryDto(code: 'DAIRY', name: 'Sữa và các sản phẩm từ sữa', order: 4),
    WhoCategoryDto(code: 'EGGS', name: 'Trứng tươi', order: 5),
    WhoCategoryDto(code: 'STAPLES', name: 'Lương thực chính', order: 6),
    WhoCategoryDto(
      code: 'LEGUMES_NUTS_SEEDS',
      name: 'Các loại đậu và hạt',
      order: 7,
    ),
    WhoCategoryDto(code: 'FATS_OILS', name: 'Chất béo và dầu mỡ', order: 8),
  ];

  String _getCategoryEmoji(String? code) {
    switch (code) {
      case 'MEAT_FISH_POULTRY':
        return '🥩';
      case 'VITAMIN_A_FRUITS_VEG':
        return '🥦';
      case 'OTHER_FRUITS_VEG':
        return '🍎';
      case 'DAIRY':
        return '🥛';
      case 'EGGS':
        return '🥚';
      case 'STAPLES':
        return '🍚';
      case 'LEGUMES_NUTS_SEEDS':
        return '🥜';
      case 'FATS_OILS':
        return '🧈';
      default:
        return '🛒';
    }
  }

  Widget _buildProductCard(ProductSearchItemDto product, Color primaryColor) {
    final variant = product.variants.isNotEmpty ? product.variants.first : null;
    final price = variant?.price ?? product.minPrice;
    final originalPrice = variant?.originalPrice;
    final unit = variant?.unit ?? 'phần';
    String packSize = variant?.packSize ?? '';
    if (packSize.isEmpty) {
      packSize = '1 $unit';
    } else if (!packSize.contains(unit) && unit.isNotEmpty) {
      packSize = '$packSize $unit';
    }
    final imageUrl = product.images.isNotEmpty ? product.images.first : '';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ProductDetailBottomSheet.show(
        context,
        product: product,
        service: _productSearchService,
        onAdd: () => _addProductToShoppingList(product, context),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    height: 125,
                    width: double.infinity,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[100],
                                  child: const Icon(
                                    Iconsax.image,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: const Icon(
                              Iconsax.image,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                if (product.origin != null && product.origin!.trim().isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.origin!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      packSize,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (originalPrice != null &&
                                  price != null &&
                                  originalPrice > price)
                                Text(
                                  _formatPrice(originalPrice),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                price != null && price > 0
                                    ? _formatPrice(price)
                                    : 'Liên hệ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add button
                        Builder(
                          builder: (btnContext) => InkWell(
                            onTap: () =>
                                _addProductToShoppingList(product, btnContext),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Iconsax.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMarketProducts() {
    final hasSearch =
        _marketSearchController.text.trim().isNotEmpty ||
        _selectedCategoryCode != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.search_status,
                size: 44,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch
                  ? 'Không tìm thấy sản phẩm phù hợp'
                  : 'Chưa có sản phẩm nào trên chợ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              hasSearch
                  ? 'Hãy thử tìm kiếm với từ khoá khác hoặc đổi danh mục'
                  : 'Các gian hàng đang chuẩn bị sản phẩm tươi sạch mới. Vui lòng quay lại sau!',
              style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (hasSearch) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _marketSearchController.clear();
                  setState(() {
                    _selectedCategoryCode = null;
                    _searchSuggestions = [];
                  });
                  _loadMarketProducts();
                },
                icon: const Icon(Iconsax.refresh, size: 16),
                label: const Text(
                  'Xem tất cả sản phẩm',
                  style: TextStyle(fontSize: 12.5),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMarketError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 44, color: Colors.orange),
            const SizedBox(height: 12),
            const Text(
              'Không thể kết nối máy chủ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              _marketErrorMessage ??
                  'Có lỗi xảy ra khi tải dữ liệu sản phẩm từ máy chủ.',
              style: const TextStyle(fontSize: 12.5, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadMarketProducts(
                query: _marketSearchController.text.trim().isEmpty
                    ? null
                    : _marketSearchController.text.trim(),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xoá toàn bộ danh sách?'),
        content: const Text(
          'Tất cả nguyên liệu trong danh sách đi chợ sẽ bị xoá vĩnh viễn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _dataService.clearAllShoppingItems();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xoá tất cả'),
          ),
        ],
      ),
    );
  }
}
