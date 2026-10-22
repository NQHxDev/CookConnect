import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';

class OrderFilterState {
  final String dateRange;
  final String shippingMethod;
  final String paymentStatus;
  final String sortBy;

  const OrderFilterState({
    this.dateRange = 'Tất cả',
    this.shippingMethod = 'Tất cả',
    this.paymentStatus = 'Tất cả',
    this.sortBy = 'Mới nhất trước',
  });

  bool get hasActiveFilter =>
      dateRange != 'Tất cả' ||
      shippingMethod != 'Tất cả' ||
      paymentStatus != 'Tất cả' ||
      sortBy != 'Mới nhất trước';

  OrderFilterState copyWith({
    String? dateRange,
    String? shippingMethod,
    String? paymentStatus,
    String? sortBy,
  }) {
    return OrderFilterState(
      dateRange: dateRange ?? this.dateRange,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class OrderFilterBottomSheet extends StatefulWidget {
  final OrderFilterState initialFilter;
  final ValueChanged<OrderFilterState> onApply;

  const OrderFilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  static Future<OrderFilterState?> show({
    required BuildContext context,
    required OrderFilterState currentFilter,
    required ValueChanged<OrderFilterState> onApply,
  }) {
    return showModalBottomSheet<OrderFilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderFilterBottomSheet(
        initialFilter: currentFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<OrderFilterBottomSheet> createState() => _OrderFilterBottomSheetState();
}

class _OrderFilterBottomSheetState extends State<OrderFilterBottomSheet> {
  late String _selectedDateRange;
  late String _selectedShipping;
  late String _selectedPayment;
  late String _selectedSort;

  final List<String> _dateOptions = const [
    'Tất cả',
    'Hôm nay',
    'Hôm qua',
    '7 ngày qua',
    'Tháng này',
  ];

  final List<String> _shippingOptions = const [
    'Tất cả',
    'Giao hàng tận nơi',
    'Khách tự đến lấy',
  ];

  final List<String> _paymentOptions = const [
    'Tất cả',
    'Đã thanh toán',
    'Thanh toán COD',
  ];

  final List<String> _sortOptions = const [
    'Mới nhất trước',
    'Cũ nhất trước',
    'Giá trị cao nhất',
    'Giá trị thấp nhất',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDateRange = widget.initialFilter.dateRange;
    _selectedShipping = widget.initialFilter.shippingMethod;
    _selectedPayment = widget.initialFilter.paymentStatus;
    _selectedSort = widget.initialFilter.sortBy;
  }

  void _reset() {
    setState(() {
      _selectedDateRange = 'Tất cả';
      _selectedShipping = 'Tất cả';
      _selectedPayment = 'Tất cả';
      _selectedSort = 'Mới nhất trước';
    });
  }

  void _apply() {
    final newState = OrderFilterState(
      dateRange: _selectedDateRange,
      shippingMethod: _selectedShipping,
      paymentStatus: _selectedPayment,
      sortBy: _selectedSort,
    );
    widget.onApply(newState);
    Navigator.of(context).pop(newState);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Iconsax.filter_edit, size: 22, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Bộ lọc đơn hàng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _reset,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text(
                      'Thiết lập lại',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, size: 22, color: AppColors.textHint),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),

            // Content scrollable
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _buildSectionTitle('Thời gian tạo đơn', Iconsax.calendar_1),
                  _buildFilterChips(
                    options: _dateOptions,
                    selectedValue: _selectedDateRange,
                    onSelected: (val) => setState(() => _selectedDateRange = val),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Hình thức nhận hàng', Iconsax.truck_fast),
                  _buildFilterChips(
                    options: _shippingOptions,
                    selectedValue: _selectedShipping,
                    onSelected: (val) => setState(() => _selectedShipping = val),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Trạng thái thanh toán', Iconsax.card_tick),
                  _buildFilterChips(
                    options: _paymentOptions,
                    selectedValue: _selectedPayment,
                    onSelected: (val) => setState(() => _selectedPayment = val),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Sắp xếp theo', Iconsax.sort),
                  _buildFilterChips(
                    options: _sortOptions,
                    selectedValue: _selectedSort,
                    onSelected: (val) => setState(() => _selectedSort = val),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Đóng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Áp dụng bộ lọc',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips({
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selectedValue;
        return InkWell(
          onTap: () => onSelected(option),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
