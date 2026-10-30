import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/order/data/models/order_model.dart';
import 'package:cookconnect/features/order/data/services/order_api_service.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/services/recipe_data_service.dart';
import 'package:cookconnect/features/order/presentation/widgets/order_live_tracking_map.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final OrderDto? initialOrder;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late OrderDto? _order;
  bool _isLoading = false;
  bool _isCancelling = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder;
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail({bool showLoading = true}) async {
    if (_order == null && showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await OrderApiService.instance.getOrderDetail(widget.orderId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.isSuccess && result.data != null) {
        _order = result.data;
        _errorMessage = null;
      } else if (_order == null) {
        _errorMessage = result.message ?? 'Không thể tải thông tin đơn hàng';
      }
    });
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    return '$h:$m, $d/$mo/$y';
  }

  Future<void> _copyText(String text, String label) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleCancelOrder() async {
    final order = _order;
    if (order == null || !order.canCancel) return;

    String selectedReason = 'Muốn thay đổi địa chỉ nhận hàng';
    final customReasonController = TextEditingController();

    final reasons = [
      'Muốn thay đổi địa chỉ nhận hàng',
      'Muốn thay đổi số điện thoại người nhận',
      'Muốn thêm hoặc bớt sản phẩm',
      'Tìm được giá tốt hơn ở nơi khác',
      'Đổi ý không muốn mua nữa',
      'Lý do khác',
    ];

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hủy đơn hàng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Vui lòng chọn lý do bạn muốn hủy đơn hàng #${order.orderNumber}:',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ...reasons.map((r) {
                    final isSelected = selectedReason == r;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedReason = r;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 20,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                r,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (selectedReason == 'Lý do khác') ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: customReasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Nhập lý do chi tiết...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Giữ đơn hàng'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Xác nhận hủy',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    final reason = selectedReason == 'Lý do khác'
        ? (customReasonController.text.trim().isNotEmpty
            ? customReasonController.text.trim()
            : 'Lý do khác')
        : selectedReason;

    setState(() {
      _isCancelling = true;
    });

    final result = await OrderApiService.instance.cancelOrder(
      order.id,
      reason: reason,
    );

    if (!mounted) return;

    setState(() {
      _isCancelling = false;
    });

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy đơn hàng thành công'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadOrderDetail(showLoading: false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Hủy đơn hàng thất bại'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _reorderItems() {
    final order = _order;
    if (order == null || order.items.isEmpty) return;

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'Theo dõi đơn hàng',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_order != null)
              Text(
                '#${_order!.orderNumber}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, size: 20),
            tooltip: 'Làm mới trạng thái',
            onPressed: () => _loadOrderDetail(showLoading: true),
          ),
        ],
      ),
      body: _buildBody(theme, primaryColor),
      bottomNavigationBar: _order != null ? _buildBottomActions(theme, primaryColor) : null,
    );
  }

  Widget _buildBody(ThemeData theme, Color primaryColor) {
    if (_isLoading && _order == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _order == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.warning_2, size: 48, color: Colors.orange.shade400),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadOrderDetail(showLoading: true),
                icon: const Icon(Iconsax.refresh, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final order = _order;
    if (order == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: () => _loadOrderDetail(showLoading: false),
      color: primaryColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // 1. Hero Status Card
          _buildHeroStatusCard(order, primaryColor),
          const SizedBox(height: 16),

          // 1.1 Live Tracking Map
          if (!order.isCancelled) ...[
            OrderLiveTrackingMap(
              order: order,
              height: 230,
            ),
            const SizedBox(height: 16),
          ],

          // 2. Timeline Progress Stepper
          _buildTimelineStepper(order, primaryColor),
          const SizedBox(height: 16),

          // 3. Shipping & Shipper Details
          _buildShippingInfoSection(order, primaryColor),
          const SizedBox(height: 16),

          // 4. Products / Items list
          _buildOrderItemsSection(order, primaryColor),
          const SizedBox(height: 16),

          // 5. Payment Summary
          _buildPaymentSection(order, primaryColor),
        ],
      ),
    );
  }

  /// Top Hero Status Card
  Widget _buildHeroStatusCard(OrderDto order, Color primaryColor) {
    final statusColor = order.statusColor;
    final isCancelled = order.isCancelled;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: order.statusBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCancelled
                      ? Iconsax.close_circle
                      : order.isCompleted
                          ? Iconsax.tick_circle
                          : order.isShipping
                              ? Iconsax.truck_fast
                              : Iconsax.box_tick,
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.statusDisplay,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: order.statusBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.paymentStatusDisplay,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.statusDescription,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Iconsax.calendar_1, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    'Thời gian đặt:',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Text(
                _formatDateTime(order.createdAt),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          if (order.updatedAt != null && order.updatedAt != order.createdAt) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.clock, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      'Cập nhật gần nhất:',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Text(
                  _formatDateTime(order.updatedAt),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Stepper showing order progression
  Widget _buildTimelineStepper(OrderDto order, Color primaryColor) {
    if (order.isCancelled) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Iconsax.info_circle, color: Color(0xFFDC2626), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đơn hàng đã được hủy',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Đơn hàng không tiếp tục xử lý. Bạn có thể bấm "Mua lại đơn này" để thêm lại nguyên liệu vào giỏ.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade900,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final currentStep = order.currentStepIndex;

    final steps = [
      {
        'title': 'Đặt hàng',
        'subtitle': 'Đơn hàng được khởi tạo',
        'icon': Iconsax.receipt_text,
      },
      {
        'title': 'Xác nhận & Chuẩn bị',
        'subtitle': 'Người bán gom nguyên liệu',
        'icon': Iconsax.box,
      },
      {
        'title': 'Đang giao hàng',
        'subtitle': order.shipperTrackingCode != null
            ? 'Vận đơn: ${order.shipperTrackingCode}'
            : 'Shipper đang trên đường giao',
        'icon': Iconsax.truck_fast,
      },
      {
        'title': 'Hoàn thành',
        'subtitle': 'Giao hàng thành công',
        'icon': Iconsax.tick_circle,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.routing_2, size: 20, color: primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Hành trình đơn hàng',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            final isDone = index < currentStep;
            final isCurrent = index == currentStep;
            final isLast = index == steps.length - 1;

            final stepColor = isDone || isCurrent ? primaryColor : Colors.grey.shade300;
            final textColor = isDone || isCurrent ? const Color(0xFF0F172A) : Colors.grey.shade400;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column with icon + vertical line
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDone
                            ? primaryColor
                            : isCurrent
                                ? primaryColor.withValues(alpha: 0.15)
                                : Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: stepColor,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        isDone ? Icons.check : (steps[index]['icon'] as IconData),
                        size: 16,
                        color: isDone
                            ? Colors.white
                            : isCurrent
                                ? primaryColor
                                : Colors.grey.shade400,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 36,
                        color: isDone ? primaryColor : Colors.grey.shade200,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Text info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[index]['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          steps[index]['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isCurrent
                                ? primaryColor
                                : isDone
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                            fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Shipping & Receiver Information
  Widget _buildShippingInfoSection(OrderDto order, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.truck_fast, size: 20, color: primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Thông tin vận chuyển & Nhận hàng',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (order.shipperTrackingCode != null &&
              order.shipperTrackingCode!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.barcode, size: 18, color: Color(0xFF475569)),
                      const SizedBox(width: 8),
                      Text(
                        'Mã vận đơn: ${order.shipperTrackingCode}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _copyText(order.shipperTrackingCode!, 'mã vận đơn'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Sao chép',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Iconsax.user, size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.receiverName.isNotEmpty
                          ? order.receiverName
                          : 'Người nhận',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (order.receiverPhone.isNotEmpty)
                      Text(
                        order.receiverPhone,
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
              if (order.receiverPhone.isNotEmpty)
                IconButton(
                  icon: const Icon(Iconsax.call, size: 18, color: Colors.green),
                  tooltip: 'Gọi điện',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _copyText(order.receiverPhone, 'số điện thoại'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Iconsax.location, size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  order.shippingAddress.isNotEmpty
                      ? order.shippingAddress
                      : 'Địa chỉ chưa cập nhật',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (order.note != null && order.note!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.note_text, size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ghi chú: ${order.note}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Products line items
  Widget _buildOrderItemsSection(OrderDto order, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Iconsax.bag_2, size: 20, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Danh sách nguyên liệu (${order.items.length})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '${order.items.length} món',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, _) => const Divider(height: 20),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(item.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (item.imageUrl == null || item.imageUrl!.isEmpty)
                        ? Icon(
                            Iconsax.bag,
                            color: primaryColor.withValues(alpha: 0.6),
                            size: 24,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${item.quantity} x ${item.formattedUnitPrice}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item.formattedTotalPrice,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Payment Breakdown Card
  Widget _buildPaymentSection(OrderDto order, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.receipt_item, size: 20, color: primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Chi tiết thanh toán',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPriceRow('Tiền hàng', order.formattedSubtotal),
          const SizedBox(height: 8),
          _buildPriceRow('Phí vận chuyển', order.formattedShippingFee),
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Giảm giá', '- ${order.discountAmount} đ', isDiscount: true),
          ],
          const Divider(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                order.formattedTotalAmount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.card, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text(
                      order.paymentMethodDisplay,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: order.statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.paymentStatusDisplay,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: order.statusColor,
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

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Bottom action bar
  Widget _buildBottomActions(ThemeData theme, Color primaryColor) {
    final order = _order!;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (order.canCancel) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _isCancelling ? null : _handleCancelOrder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCancelling
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Hủy đơn hàng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (order.isTerminal) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _reorderItems,
                icon: const Icon(Iconsax.shopping_cart, size: 16),
                label: const Text('Mua lại đơn này'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showSupportDialog(context);
              },
              icon: const Icon(Iconsax.headphone, size: 16),
              label: const Text('Cần trợ giúp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Iconsax.headphone, color: Colors.orange),
              SizedBox(width: 8),
              Text('Hỗ trợ đơn hàng', style: TextStyle(fontSize: 17)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mọi thắc mắc hoặc cần khiếu nại về đơn hàng này, vui lòng liên hệ trung tâm hỗ trợ CookConnect:',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Iconsax.call, color: Colors.green),
                title: const Text('Hotline: 1900 6868'),
                subtitle: const Text('Hỗ trợ 24/7 (Miễn cước)'),
                onTap: () {
                  _copyText('19006868', 'Hotline');
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Iconsax.sms, color: Colors.blue),
                title: const Text('Email: support@cookconnect.vn'),
                subtitle: const Text('Phản hồi trong vòng 2 giờ'),
                onTap: () {
                  _copyText('support@cookconnect.vn', 'Email hỗ trợ');
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
