import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../data/models/order_model.dart';

/// Modal dialog hiển thị thông báo đặt hàng thành công với phong cách hiện đại,
/// hiệu ứng chuyển động mượt mà và thông tin biên nhận (receipt) chi tiết.
class OrderSuccessDialog extends StatefulWidget {
  final OrderDto order;
  final VoidCallback? onPrimaryAction;

  const OrderSuccessDialog({
    super.key,
    required this.order,
    this.onPrimaryAction,
  });

  /// Hiển thị dialog đặt hàng thành công kèm hiệu ứng mờ hậu cảnh (backdrop blur)
  /// và chuyển động phóng to mượt mà (scale + fade).
  static Future<T?> show<T>(
    BuildContext context,
    OrderDto order, {
    VoidCallback? onPrimaryAction,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'OrderSuccessDialog',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) {
        return OrderSuccessDialog(
          order: order,
          onPrimaryAction: onPrimaryAction,
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        );
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5 * anim1.value,
            sigmaY: 5 * anim1.value,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
            child: FadeTransition(
              opacity: anim1,
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  State<OrderSuccessDialog> createState() => _OrderSuccessDialogState();
}

class _OrderSuccessDialogState extends State<OrderSuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _badgeScaleAnimation;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _badgeScaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _copyOrderNumber() async {
    HapticFeedback.lightImpact();
    setState(() => _copied = true);
    await Clipboard.setData(ClipboardData(text: widget.order.orderNumber));

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Vừa xong';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    return '$h:$m, $d/$mo/$y';
  }

  String get _paymentMethodLabel {
    switch (widget.order.paymentMethod.toUpperCase()) {
      case 'COD':
        return 'Tiền mặt khi nhận hàng (COD)';
      case 'MOMO':
        return 'Ví điện tử MoMo';
      case 'VNPAY':
        return 'Cổng thanh toán VNPAY';
      case 'CREDIT_CARD':
        return 'Thẻ tín dụng / Ghi nợ';
      default:
        return widget.order.paymentMethod;
    }
  }

  IconData get _paymentMethodIcon {
    switch (widget.order.paymentMethod.toUpperCase()) {
      case 'COD':
        return Iconsax.money_recive;
      case 'MOMO':
        return Iconsax.wallet_3;
      case 'VNPAY':
        return Iconsax.scan_barcode;
      case 'CREDIT_CARD':
        return Iconsax.card;
      default:
        return Iconsax.wallet_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final mediaQuery = MediaQuery.of(context);

    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          width: mediaQuery.size.width * 0.9,
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: mediaQuery.size.height * 0.88,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Material(
              color: Colors.white,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge chúc mừng với hiệu ứng vòng tròn đa tầng & confetti
                    _buildCelebrationHeader(primaryColor),

                    const SizedBox(height: 16),

                    // Tiêu đề & phụ đề
                    const Text(
                      'Đặt hàng thành công!',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Đơn hàng đã được chuyển tới người bán để chuẩn bị nguyên liệu tươi ngon nhất.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 18),

                    // Phiếu thông tin đơn hàng kiểu Receipt Ticket hiện đại
                    _buildOrderReceiptCard(primaryColor),

                    const SizedBox(height: 14),

                    // Thông báo cam kết dịch vụ / thời gian chuẩn bị
                    _buildTrustBanner(),

                    const SizedBox(height: 20),

                    // Các nút hành động chính
                    _buildActionButtons(primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header chúc mừng với icon tick xanh, hào quang phát sáng và các hạt confetti
  Widget _buildCelebrationHeader(Color primaryColor) {
    return ScaleTransition(
      scale: _badgeScaleAnimation,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Vòng hào quang ngoài cùng
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
            ),
          ),

          // Vòng hào quang thứ hai
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
            ),
          ),

          // Vòng tròn trung tâm chứa biểu tượng Tick xanh tươi
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF34D399), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

          // Confetti hạt sao góc trên bên phải
          Positioned(
            top: -3,
            right: 14,
            child: Transform.rotate(
              angle: 0.3,
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
            ),
          ),

          // Confetti chấm tròn màu cam thương hiệu góc trên bên trái
          Positioned(
            top: 6,
            left: 16,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF7A00),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Confetti viên ngọc xanh dương góc dưới bên trái
          Positioned(
            bottom: 2,
            left: 18,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          // Confetti hạt sao nhỏ góc dưới bên phải
          Positioned(
            bottom: 4,
            right: 16,
            child: Transform.rotate(
              angle: 0.6,
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFF10B981),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Khung phiếu biên nhận đơn hàng với nét đứt (dashed lines)
  Widget _buildOrderReceiptCard(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // Header của Receipt: Mã đơn hàng & Nút sao chép nhanh
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MÃ ĐƠN HÀNG',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.order.orderNumber,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _copyOrderNumber,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _copied
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _copied
                            ? const Color(0xFFA7F3D0)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied ? Iconsax.tick_circle : Iconsax.copy,
                          size: 13,
                          color: _copied
                              ? const Color(0xFF059669)
                              : const Color(0xFF475569),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _copied ? 'Đã chép' : 'Sao chép',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _copied
                                ? const Color(0xFF059669)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Đường kẻ đứt ngăn cách
          const _DashedLineDivider(),

          // Chi tiết đơn hàng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Trạng thái đơn hàng
                _buildReceiptRow(
                  icon: Iconsax.clock,
                  iconColor: const Color(0xFFD97706),
                  label: 'Trạng thái',
                  valueWidget: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      widget.order.statusDisplay,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Thời gian đặt
                _buildReceiptRow(
                  icon: Iconsax.calendar_1,
                  iconColor: const Color(0xFF64748B),
                  label: 'Thời gian',
                  valueWidget: Text(
                    _formatDateTime(widget.order.createdAt),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Phương thức thanh toán
                _buildReceiptRow(
                  icon: _paymentMethodIcon,
                  iconColor: const Color(0xFF64748B),
                  label: 'Thanh toán',
                  valueWidget: Text(
                    _paymentMethodLabel,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),

                // Người nhận & Địa chỉ giao
                _buildReceiptRow(
                  icon: Iconsax.location,
                  iconColor: const Color(0xFF64748B),
                  label: 'Giao đến',
                  valueWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.order.receiverName.isNotEmpty
                            ? '${widget.order.receiverName} • ${widget.order.receiverPhone}'
                            : (widget.order.receiverPhone.isNotEmpty
                                ? widget.order.receiverPhone
                                : 'Người nhận'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.order.shippingAddress.isNotEmpty)
                        Text(
                          widget.order.shippingAddress,
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
                const SizedBox(height: 10),

                // Số lượng nguyên liệu
                _buildReceiptRow(
                  icon: Iconsax.bag_2,
                  iconColor: const Color(0xFF64748B),
                  label: 'Số lượng',
                  valueWidget: Text(
                    '${widget.order.items.isNotEmpty ? widget.order.items.length : 1} nguyên liệu',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Đường kẻ đứt ngăn cách
          const _DashedLineDivider(),

          // Dòng tổng tiền thanh toán nổi bật
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tổng thanh toán:',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.order.formattedTotalAmount,
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget valueWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: valueWidget,
          ),
        ),
      ],
    );
  }

  /// Banner cam kết / gợi ý người dùng
  Widget _buildTrustBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Iconsax.shield_tick,
            size: 18,
            color: Color(0xFF059669),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'CookConnect cam kết nguyên liệu tươi sạch và hỗ trợ cập nhật hành trình nhanh chóng.',
              style: TextStyle(
                fontSize: 11.5,
                color: const Color(0xFF065F46),
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Nút hành động chính và phụ
  Widget _buildActionButtons(Color primaryColor) {
    return Column(
      children: [
        // Nút chính: Theo dõi đơn hàng
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                primaryColor,
                Color.lerp(primaryColor, Colors.deepOrange, 0.3) ?? primaryColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop('track');
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.truck_fast, size: 19, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Theo dõi đơn hàng',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Nút phụ: Quay về danh sách đi chợ
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onPrimaryAction?.call();
              Navigator.of(context).pop();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.shopping_cart, size: 17),
                SizedBox(width: 8),
                Text(
                  'Về danh sách đi chợ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget vẽ đường kẻ đứt nét (dashed line divider) kiểu vé/hóa đơn sử dụng CustomPainter
class _DashedLineDivider extends StatelessWidget {
  const _DashedLineDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: const Color(0xFFE2E8F0),
          dashWidth: 5,
          dashSpace: 4,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      final endX = (startX + dashWidth > size.width) ? size.width : (startX + dashWidth);
      canvas.drawLine(
        Offset(startX, 0),
        Offset(endX, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}
