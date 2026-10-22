import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/orders/data/models/seller_order.dart';
import 'package:cook_connect_seller/features/orders/presentation/widgets/order_card.dart';
import 'package:cook_connect_seller/features/orders/presentation/widgets/order_filter_bottom_sheet.dart';
import 'package:cook_connect_seller/features/orders/presentation/widgets/shipping_status_bottom_sheet.dart';
import 'package:cook_connect_seller/features/orders/presentation/widgets/needs_action_bottom_sheet.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Tab danh mục chính: 'shipping' (Chờ vận chuyển) hoặc 'needs_action' (Cần xử lý)
  String _activeMainCategory = 'shipping';

  // Lựa chọn con của "Chờ vận chuyển" (Mặc định: 'Đang chờ vận chuyển')
  String _selectedShippingStatus = 'Đang chờ vận chuyển';

  // Lựa chọn con của "Cần xử lý" (Mặc định: 'Tất cả đơn hàng cần xử lý')
  String _selectedNeedsActionStatus = 'Tất cả đơn hàng cần xử lý';

  // Trạng thái bộ lọc phụ (Icon ngoài cùng bên trái)
  OrderFilterState _filterState = const OrderFilterState();

  // Search query
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Danh sách đơn hàng
  late List<SellerOrder> _orders;

  @override
  void initState() {
    super.initState();
    _orders = _getInitialMockOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SellerOrder> _getInitialMockOrders() {
    final now = DateTime.now();
    return [
      SellerOrder(
        id: 'ORD-9842',
        customerName: 'Nguyễn Văn An',
        customerPhone: '0901 234 567',
        deliveryAddress: 'Phòng 402, Toà S1.02 Vinhomes Grand Park, TP. Thủ Đức',
        totalAmount: 145000,
        status: 'Đang chờ vận chuyển',
        createdAt: now.subtract(const Duration(minutes: 18)),
        items: [
          OrderItem(id: '1', title: 'Cơm tấm sườn nướng đặc biệt', quantity: 2, price: 55000),
          OrderItem(id: '2', title: 'Canh rong biển thịt bằm', quantity: 1, price: 15000),
          OrderItem(id: '3', title: 'Trà tắc khổng lồ', quantity: 1, price: 20000),
        ],
      ),
      SellerOrder(
        id: 'ORD-9839',
        customerName: 'Trần Thị Thuỳ Dung',
        customerPhone: '0988 765 432',
        deliveryAddress: '24 Đường D1, P. Tăng Nhơn Phú A, TP. Thủ Đức',
        totalAmount: 210000,
        status: 'Đang chờ lấy hàng',
        createdAt: now.subtract(const Duration(minutes: 32)),
        items: [
          OrderItem(id: '4', title: 'Bún chả Hà Nội (Suất đặc biệt)', quantity: 2, price: 75000),
          OrderItem(id: '5', title: 'Nem rán giòn (3 cuốn)', quantity: 2, price: 30000),
        ],
      ),
      SellerOrder(
        id: 'ORD-9837',
        customerName: 'Lê Hoàng Nam',
        customerPhone: '0912 345 890',
        deliveryAddress: 'Tầng 8, Toà nhà Bitexco, Q.1, TP.HCM',
        totalAmount: 95000,
        status: 'Đang chờ vận chuyển',
        createdAt: now.subtract(const Duration(minutes: 55)),
        items: [
          OrderItem(id: '6', title: 'Cơm gà xối mỡ chiên giòn', quantity: 1, price: 65000),
          OrderItem(id: '7', title: 'Trà chanh mật ong', quantity: 1, price: 30000),
        ],
      ),
      SellerOrder(
        id: 'ORD-9845',
        customerName: 'Hoàng Minh Quân',
        customerPhone: '0934 112 233',
        deliveryAddress: '15 Lê Duẩn, P. Bến Nghé, Quận 1',
        totalAmount: 180000,
        status: 'Cần vận chuyển trong vòng 24h',
        createdAt: now.subtract(const Duration(minutes: 3)),
        items: [
          OrderItem(id: '8', title: 'Phở bò tái nạm đặc biệt', quantity: 2, price: 75000),
          OrderItem(id: '9', title: 'Quẩy giòn (2 cái)', quantity: 2, price: 15000),
        ],
      ),
      SellerOrder(
        id: 'ORD-9844',
        customerName: 'Phạm Thu Thảo',
        customerPhone: '0977 445 566',
        deliveryAddress: '128 Điện Biên Phủ, P. 15, Q. Bình Thạnh',
        totalAmount: 65000,
        status: 'Tự động hủy trong 24h trở xuống',
        createdAt: now.subtract(const Duration(minutes: 7)),
        items: [
          OrderItem(id: '10', title: 'Bánh mì chảo thập cẩm', quantity: 1, price: 50000),
          OrderItem(id: '11', title: 'Sữa đậu nành nóng', quantity: 1, price: 15000),
        ],
      ),
      SellerOrder(
        id: 'ORD-9830',
        customerName: 'Vũ Đức Thịnh',
        customerPhone: '0965 999 888',
        deliveryAddress: '45 Nguyễn Thị Minh Khai, P. Bến Nghé, Quận 1',
        totalAmount: 320000,
        status: 'Đã hoàn thành',
        createdAt: now.subtract(const Duration(hours: 3)),
        items: [
          OrderItem(id: '12', title: 'Lẩu mini bò kim chi', quantity: 1, price: 199000),
          OrderItem(id: '13', title: 'Bò thêm (100g)', quantity: 1, price: 65000),
          OrderItem(id: '14', title: 'Nước ngọt có ga', quantity: 2, price: 28000),
        ],
      ),
      SellerOrder(
        id: 'ORD-9821',
        customerName: 'Đặng Ngọc Mai',
        customerPhone: '0908 123 789',
        deliveryAddress: '72 Lê Thánh Tôn, P. Bến Nghé, Quận 1',
        totalAmount: 50000,
        status: 'Đã hủy',
        createdAt: now.subtract(const Duration(hours: 5)),
        items: [
          OrderItem(id: '15', title: 'Cà phê muối đá xay', quantity: 1, price: 50000),
        ],
      ),
    ];
  }

  // Danh sách các trạng thái thuộc nhóm "Chờ vận chuyển"
  final Set<String> _shippingStatuses = const {
    'Đang chờ vận chuyển',
    'Đang chờ lấy hàng',
    'Giao hàng không thành công',
    'Đang trung chuyển',
    'Đã giao hàng',
    'Chưa thanh toán',
    'Tạm hoãn',
    'Đã hủy',
    'Đã hoàn thành',
  };

  // Danh sách các trạng thái thuộc nhóm "Cần xử lý"
  final Set<String> _needsActionStatuses = const {
    'Cần vận chuyển trong vòng 24h',
    'Tự động hủy trong 24h trở xuống',
    'Quá hạn vận chuyển',
    'Đã hủy yêu cầu',
    'Vấn đề gửi hàng',
    'Vấn đề vận chuyển hoặc giao hàng không thành công',
    'Đã yêu cầu trả hàng - Hoàn tiền',
    'pending',
  };

  List<SellerOrder> get _filteredOrders {
    return _orders.where((order) {
      // 1. Lọc theo Menu Dropdown đang active
      if (_activeMainCategory == 'shipping') {
        if (_selectedShippingStatus == 'Tất cả') {
          // Hiện tất cả đơn trong nhóm vận chuyển
          final isShippingRelated = _shippingStatuses.contains(order.status) ||
              order.status == 'shipping_pending' ||
              order.status == 'ready' ||
              order.status == 'completed' ||
              order.status == 'cancelled';
          if (!isShippingRelated) return false;
        } else {
          // Lọc theo mục con cụ thể
          final match = order.status == _selectedShippingStatus ||
              (_selectedShippingStatus == 'Đang chờ vận chuyển' &&
                  (order.status == 'shipping_pending' || order.status == 'ready'));
          if (!match) return false;
        }
      } else if (_activeMainCategory == 'needs_action') {
        if (_selectedNeedsActionStatus == 'Tất cả đơn hàng cần xử lý') {
          final isNeedsActionRelated = _needsActionStatuses.contains(order.status) ||
              order.status == 'pending' ||
              order.status == 'needs_action';
          if (!isNeedsActionRelated) return false;
        } else {
          final match = order.status == _selectedNeedsActionStatus ||
              (_selectedNeedsActionStatus == 'Cần vận chuyển trong vòng 24h' &&
                  order.status == 'pending');
          if (!match) return false;
        }
      }

      // 2. Lọc theo tìm kiếm
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchId = order.id.toLowerCase().contains(query);
        final matchName = order.customerName.toLowerCase().contains(query);
        final matchPhone = order.customerPhone.contains(query);
        final matchItem = order.items.any((it) => it.title.toLowerCase().contains(query));
        if (!matchId && !matchName && !matchPhone && !matchItem) return false;
      }

      return true;
    }).toList();
  }

  // Số lượng đơn cho Chờ vận chuyển
  int get _shippingCount {
    return _orders.where((o) {
      return _shippingStatuses.contains(o.status) ||
          o.status == 'shipping_pending' ||
          o.status == 'ready';
    }).length;
  }

  // Số lượng đơn cho Cần xử lý
  int get _needsActionCount {
    return _orders.where((o) {
      return _needsActionStatuses.contains(o.status) ||
          o.status == 'pending' ||
          o.status == 'needs_action';
    }).length;
  }

  // Mở BottomModel Bộ lọc ngoài cùng bên trái
  void _openFilterBottomSheet() {
    OrderFilterBottomSheet.show(
      context: context,
      currentFilter: _filterState,
      onApply: (newState) {
        setState(() {
          _filterState = newState;
        });
      },
    );
  }

  // Mở BottomModel cho "Chờ vận chuyển"
  void _openShippingMenu() {
    setState(() {
      _activeMainCategory = 'shipping';
    });

    ShippingStatusBottomSheet.show(
      context: context,
      currentStatus: _selectedShippingStatus,
      onSelected: (val) {
        setState(() {
          _selectedShippingStatus = val;
        });
      },
    );
  }

  // Mở BottomModel cho "Cần xử lý"
  void _openNeedsActionMenu() {
    setState(() {
      _activeMainCategory = 'needs_action';
    });

    NeedsActionBottomSheet.show(
      context: context,
      currentStatus: _selectedNeedsActionStatus,
      onSelected: (val) {
        setState(() {
          _selectedNeedsActionStatus = val;
        });
      },
    );
  }

  void _confirmOrder(SellerOrder order) {
    setState(() {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = SellerOrder(
          id: order.id,
          customerName: order.customerName,
          customerPhone: order.customerPhone,
          deliveryAddress: order.deliveryAddress,
          totalAmount: order.totalAmount,
          status: 'Đang chờ vận chuyển',
          createdAt: order.createdAt,
          items: order.items,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đơn hàng #${order.id} đã chuyển sang "Đang chờ vận chuyển"'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handoverToShipper(SellerOrder order) {
    setState(() {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = SellerOrder(
          id: order.id,
          customerName: order.customerName,
          customerPhone: order.customerPhone,
          deliveryAddress: order.deliveryAddress,
          totalAmount: order.totalAmount,
          status: 'Đã hoàn thành',
          createdAt: order.createdAt,
          items: order.items,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã giao shipper đơn #${order.id}!'),
        backgroundColor: const Color(0xFF0284C7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm theo mã đơn, khách hàng...',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              )
            : const Text('Quản lý đơn hàng'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Iconsax.search_normal, size: 20),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh, size: 20),
            onPressed: () {
              setState(() {
                _orders = _getInitialMockOrders();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ============================================================
          // THANH CHỌN DANH MỤC NHỎ GỌN, ĐẸP MẮT:
          // [Icon bộ lọc] | [Chờ vận chuyển ▾] | [Cần xử lý ▾]
          // ============================================================
          _buildCompactCategoryBar(),

          // Thanh thông báo khi có bộ lọc hoạt động
          if (_filterState.hasActiveFilter) _buildActiveFilterBanner(),

          // Danh sách đơn hàng
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
                setState(() {});
              },
              color: AppColors.primary,
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final order = filtered[index];
                        return OrderCard(
                          order: order,
                          onTap: () => _showOrderDetail(order),
                          onPrimaryAction: () {
                            if (_activeMainCategory == 'needs_action' ||
                                _needsActionStatuses.contains(order.status)) {
                              _confirmOrder(order);
                            } else {
                              _handoverToShipper(order);
                            }
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Thanh chọn danh mục thiết kế nhỏ gọn, tinh tế
  /// Bên trái ngoài cùng là Icon bộ lọc (click ra BottomModel)
  /// Bên phải icon là Menu Dropdown [Chờ vận chuyển ▾] (click ra BottomModel)
  /// Cạnh nữa là Menu Dropdown [Cần xử lý ▾] (click ra BottomModel)
  Widget _buildCompactCategoryBar() {
    final isShippingActive = _activeMainCategory == 'shipping';
    final isNeedsActionActive = _activeMainCategory == 'needs_action';
    final hasActiveFilter = _filterState.hasActiveFilter;

    // Hiển thị text ngắn gọn nếu mục con được chọn
    final shippingLabel = _selectedShippingStatus == 'Đang chờ vận chuyển'
        ? 'Chờ vận chuyển'
        : _selectedShippingStatus;

    final needsActionLabel = _selectedNeedsActionStatus == 'Tất cả đơn hàng cần xử lý'
        ? 'Cần xử lý'
        : _selectedNeedsActionStatus;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.8),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        children: [
          // 1. ICON BỘ LỌC Ở BÊN TRÁI NGOÀI CÙNG (nhỏ gọn, ấn mở BottomModel)
          Material(
            color: hasActiveFilter
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _openFilterBottomSheet,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 34,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasActiveFilter ? AppColors.primary : Colors.grey.shade300,
                    width: 0.9,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Iconsax.filter,
                      size: 15,
                      color: hasActiveFilter ? AppColors.primary : AppColors.textPrimary,
                    ),
                    if (hasActiveFilter)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Đường phân cách mảnh nhẹ
          Container(
            width: 0.8,
            height: 20,
            color: Colors.grey.shade300,
          ),

          const SizedBox(width: 8),

          // 2. MỤC CHỜ VẬN CHUYỂN (Menu Drop ra BottomModel)
          Expanded(
            child: _buildDropdownMenuChip(
              isActive: isShippingActive,
              label: shippingLabel,
              count: _shippingCount,
              onTap: () {
                if (!isShippingActive) {
                  setState(() => _activeMainCategory = 'shipping');
                }
                _openShippingMenu();
              },
            ),
          ),

          const SizedBox(width: 8),

          // 3. MỤC CẦN XỬ LÝ (Menu Drop ra BottomModel)
          Expanded(
            child: _buildDropdownMenuChip(
              isActive: isNeedsActionActive,
              label: needsActionLabel,
              count: _needsActionCount,
              onTap: () {
                if (!isNeedsActionActive) {
                  setState(() => _activeMainCategory = 'needs_action');
                }
                _openNeedsActionMenu();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget cho từng nút Menu Dropdown nhỏ gọn, thẩm mỹ
  Widget _buildDropdownMenuChip({
    required bool isActive,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    final activeColor = AppColors.primary;
    final inactiveColor = AppColors.textPrimary;
    final inactiveBg = Colors.grey.shade100;
    final activeBg = activeColor.withValues(alpha: 0.08);

    return Material(
      color: isActive ? activeBg : inactiveBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? activeColor : Colors.grey.shade300,
              width: isActive ? 1.1 : 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 3),
              Icon(
                Iconsax.arrow_down_1,
                size: 13,
                color: isActive ? activeColor : AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterBanner() {
    return Container(
      width: double.infinity,
      color: AppColors.primaryLight.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        children: [
          const Icon(Iconsax.info_circle, size: 13, color: AppColors.primaryDark),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Lọc: ${_filterState.dateRange} • ${_filterState.shippingMethod}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _filterState = const OrderFilterState();
              });
            },
            child: const Text(
              'Xoá lọc',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.receipt_2,
                size: 48,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Không tìm thấy đơn hàng nào',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Không có đơn hàng nào khớp với danh mục đang chọn.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetail(SellerOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      'Chi tiết đơn #${order.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInfoRow('Khách hàng:', order.customerName),
                    const SizedBox(height: 6),
                    _buildInfoRow('Điện thoại:', order.customerPhone),
                    const SizedBox(height: 6),
                    _buildInfoRow('Địa chỉ:', order.deliveryAddress),
                    const SizedBox(height: 12),
                    const Text('Món đã đặt', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ...order.items.map((it) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${it.quantity}x ${it.title}', style: const TextStyle(fontSize: 13)),
                              Text('${(it.price * it.quantity).toInt()} đ',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        )),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${order.totalAmount.toInt()} đ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}
