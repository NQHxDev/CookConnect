import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/auth/presentation/widgets/auth_bottom_sheet.dart';
import 'package:cookconnect/features/order/data/models/order_model.dart';
import 'package:cookconnect/features/order/data/services/order_api_service.dart';
import 'package:cookconnect/features/order/presentation/widgets/customer_order_card.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/services/recipe_data_service.dart';

class MyOrdersScreen extends StatefulWidget {
  final int initialTabIndex;

  const MyOrdersScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<OrderDto> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 4),
    );
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({bool showLoading = true}) async {
    if (!AuthService.instance.isLoggedIn) {
      if (mounted) {
        setState(() {
          _orders = [];
          _isLoading = false;
        });
      }
      return;
    }

    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await OrderApiService.instance.getMyOrders(page: 1, limit: 50);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.isSuccess && result.data != null) {
        _orders = result.data!;
        _errorMessage = null;
      } else {
        _errorMessage = result.message ?? 'Không thể tải danh sách đơn hàng';
      }
    });
  }

  List<OrderDto> _filterOrdersByTab(int tabIndex) {
    List<OrderDto> list;
    switch (tabIndex) {
      case 1: // Chờ xử lý
        list = _orders.where((o) {
          final s = o.orderStatus.toUpperCase();
          return s == 'PENDING' ||
              s == 'AWAITING_PAYMENT' ||
              s == 'CONFIRMED' ||
              s == 'PROCESSING';
        }).toList();
        break;
      case 2: // Đang giao
        list = _orders.where((o) => o.isShipping).toList();
        break;
      case 3: // Hoàn thành
        list = _orders.where((o) => o.isCompleted).toList();
        break;
      case 4: // Đã hủy
        list = _orders.where((o) => o.isCancelled).toList();
        break;
      case 0: // Tất cả
      default:
        list = List.from(_orders);
        break;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((o) {
        final matchesCode = o.orderNumber.toLowerCase().contains(q);
        final matchesItem = o.items.any(
          (i) => i.productName.toLowerCase().contains(q),
        );
        return matchesCode || matchesItem;
      }).toList();
    }

    return list;
  }

  void _reorderItems(OrderDto order) {
    if (order.items.isEmpty) return;

    final shoppingItems = order.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return ShoppingItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_$index',
        name: item.productName,
        amount: '${item.quantity} phần',
        recipeSource: 'Mua lại từ #${order.orderNumber}',
        isCompleted: false,
        imageUrl: item.imageUrl,
        price: item.unitPrice,
        productId: item.productId,
        supplierId: order.supplierId,
      );
    }).toList();

    RecipeDataService.instance.addShoppingItems(shoppingItems);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final isLoggedIn = AuthService.instance.isLoggedIn;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: const Text(
          'Đơn hàng của tôi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: isLoggedIn
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: primaryColor,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: primaryColor,
                    unselectedLabelColor: Colors.grey.shade600,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13.5,
                    ),
                    tabs: [
                      Tab(text: 'Tất cả (${_orders.length})'),
                      Tab(
                        text:
                            'Chờ xử lý (${_filterOrdersByTab(1).length})',
                      ),
                      Tab(
                        text:
                            'Đang giao (${_filterOrdersByTab(2).length})',
                      ),
                      Tab(
                        text:
                            'Hoàn thành (${_filterOrdersByTab(3).length})',
                      ),
                      Tab(
                        text:
                            'Đã hủy (${_filterOrdersByTab(4).length})',
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: isLoggedIn ? _buildAuthenticatedView(theme, primaryColor) : _buildGuestView(theme, primaryColor),
    );
  }

  Widget _buildGuestView(ThemeData theme, Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.box,
                size: 40,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Theo dõi đơn hàng dễ dàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng nhập tài khoản của bạn để xem lịch sử mua sắm và theo dõi hành trình giao nhận thực phẩm.',
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade600,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                showAuthBottomSheet(
                  context,
                  message: 'Đăng nhập để theo dõi các đơn hàng của bạn',
                ).then((_) {
                  if (AuthService.instance.isLoggedIn) {
                    _loadOrders();
                  }
                });
              },
              icon: const Icon(Iconsax.login, size: 18),
              label: const Text(
                'Đăng nhập ngay',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(ThemeData theme, Color primaryColor) {
    return Column(
      children: [
        // Search bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Tìm theo mã đơn (#ORD...) hoặc tên món...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: const Icon(Iconsax.search_normal, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
          ),
        ),

        // Tab Views
        Expanded(
          child: _isLoading && _orders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null && _orders.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.warning_2,
                              size: 48,
                              color: Colors.orange.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _loadOrders(showLoading: true),
                              icon: const Icon(Iconsax.refresh, size: 18),
                              label: const Text('Thử lại'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: List.generate(5, (tabIndex) {
                        return _buildOrdersList(tabIndex, primaryColor);
                      }),
                    ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(int tabIndex, Color primaryColor) {
    final list = _filterOrdersByTab(tabIndex);

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadOrders(showLoading: false),
        color: primaryColor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.box_remove,
                          size: 34,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Không tìm thấy đơn hàng phù hợp'
                            : tabIndex == 0
                                ? 'Bạn chưa có đơn hàng nào'
                                : 'Không có đơn hàng nào trong mục này',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Vui lòng kiểm tra lại từ khóa tìm kiếm'
                            : 'Hãy chọn nguyên liệu từ công thức và lên đơn ngay!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (tabIndex == 0 && _searchQuery.isEmpty) ...[
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Iconsax.shopping_cart, size: 16),
                          label: const Text(
                            'Đi chợ ngay',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadOrders(showLoading: false),
      color: primaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final order = list[index];
          return CustomerOrderCard(
            order: order,
            onCancelled: () => _loadOrders(showLoading: false),
            onReordered: () => _reorderItems(order),
          );
        },
      ),
    );
  }
}
