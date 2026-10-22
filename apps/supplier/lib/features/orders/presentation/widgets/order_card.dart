import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/orders/data/models/seller_order.dart';

class OrderCard extends StatelessWidget {
  final SellerOrder order;
  final VoidCallback? onTap;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  String _formatCurrency(num amount) {
    final parts = amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$parts đ';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    return '$hour:$minute, $day/$month';
  }

  _StatusConfig _getStatusConfig(String status) {
    final lower = status.toLowerCase();

    // Nhóm Cần xử lý / Khẩn cấp
    if (lower.contains('24h') ||
        lower.contains('cần xử lý') ||
        lower.contains('quá hạn') ||
        lower.contains('pending') ||
        lower.contains('needs_action')) {
      return _StatusConfig(
        label: status,
        textColor: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
        borderColor: const Color(0xFFFDE68A),
        icon: Iconsax.clock,
      );
    }

    // Nhóm Chờ vận chuyển / Vận chuyển
    if (lower.contains('chờ vận chuyển') ||
        lower.contains('chờ lấy hàng') ||
        lower.contains('trung chuyển') ||
        lower.contains('shipping') ||
        lower.contains('ready')) {
      return _StatusConfig(
        label: status,
        textColor: const Color(0xFF0284C7),
        bgColor: const Color(0xFFE0F2FE),
        borderColor: const Color(0xFFBAE6FD),
        icon: Iconsax.truck_fast,
      );
    }

    // Hoàn thành / Đã giao
    if (lower.contains('hoàn thành') || lower.contains('đã giao') || lower.contains('completed')) {
      return _StatusConfig(
        label: status,
        textColor: const Color(0xFF16A34A),
        bgColor: const Color(0xFFDCFCE7),
        borderColor: const Color(0xFFBBF7D0),
        icon: Iconsax.tick_circle,
      );
    }

    // Đã hủy / Giao không thành công / Thất bại
    if (lower.contains('hủy') || lower.contains('không thành công') || lower.contains('cancelled')) {
      return _StatusConfig(
        label: status,
        textColor: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEE2E2),
        borderColor: const Color(0xFFFECACA),
        icon: Iconsax.close_circle,
      );
    }

    return _StatusConfig(
      label: status,
      textColor: AppColors.textSecondary,
      bgColor: Colors.grey.shade100,
      borderColor: Colors.grey.shade300,
      icon: Iconsax.receipt,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(order.status);
    final totalItemsCount = order.items.fold<int>(0, (sum, it) => sum + it.quantity);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card: Mã đơn + Trạng thái
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Iconsax.receipt_2,
                      size: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.id}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatTime(order.createdAt),
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusConfig.bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: statusConfig.borderColor, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusConfig.icon, size: 11, color: statusConfig.textColor),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            statusConfig.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: statusConfig.textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 0.6),

            // Khách hàng & địa chỉ
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.user, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        order.customerName,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (order.customerPhone.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '• ${order.customerPhone}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (order.deliveryAddress.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Iconsax.location, size: 13, color: AppColors.textHint),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            order.deliveryAddress,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Danh sách món ăn rút gọn
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ...order.items.take(2).map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatCurrency(item.price * item.quantity),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (order.items.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '+ thêm ${order.items.length - 2} món khác...',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Tổng tiền & nút hành động
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng ($totalItemsCount món):',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatCurrency(order.totalAmount),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildActions(order.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('24h') ||
        lower.contains('pending') ||
        lower.contains('cần xử lý') ||
        lower.contains('needs_action')) {
      return ElevatedButton(
        onPressed: onPrimaryAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: const Size(0, 30),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text(
          'Xác nhận đơn',
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
        ),
      );
    } else if (lower.contains('chờ vận chuyển') ||
        lower.contains('chờ lấy hàng') ||
        lower.contains('ready') ||
        lower.contains('shipping_pending')) {
      return ElevatedButton.icon(
        onPressed: onPrimaryAction,
        icon: const Icon(Iconsax.truck_fast, size: 13),
        label: const Text('Giao shipper', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(0, 30),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      );
    }

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(0, 30),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: const Text(
        'Chi tiết',
        style: TextStyle(fontSize: 11.5, color: AppColors.textPrimary),
      ),
    );
  }
}

class _StatusConfig {
  final String label;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  final IconData icon;

  _StatusConfig({
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
    required this.icon,
  });
}
