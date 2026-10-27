import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/add_product_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/shipping/shipping_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/warehouse/warehouse_address_screen.dart';
import 'package:cook_connect_seller/features/store/presentation/pages/store_profile_screen.dart';
import 'package:cook_connect_seller/main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isOpen = true;

  @override
  void initState() {
    super.initState();
    SellerAuthService.instance.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    SellerAuthService.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  void _switchTab(int tabIndex) {
    MainNavigationScreen.navigateToTab(context, tabIndex);
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông báo vận hành',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.box_add, color: AppColors.primary, size: 20),
              ),
              title: const Text(
                '3 đơn hàng mới chờ duyệt',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Khách hàng vừa đặt các đơn hàng nguyên liệu tươi',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _switchTab(2); // Go to Orders
              },
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.message, color: Colors.blue, size: 20),
              ),
              title: const Text(
                'Tin nhắn mới từ khách hàng',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Hỏi về thời gian giao hàng thịt bò phi lê',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _switchTab(4); // Go to Chat
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStoreQrDialog(String storeName, String storeCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            storeName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 160, color: Colors.black87),
                  const SizedBox(height: 8),
                  Text(
                    'Mã gian hàng: $storeCode',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Quét mã để mở trực tiếp trang gian hàng trên ứng dụng CookConnect',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SellerAuthService.instance.currentUser;
    final supplier = SellerAuthService.instance.supplierProfile;

    final storeName = supplier?.supplierName ??
        user?.storeName ??
        'Đại Siêu Thị CookConnect';
    final storeCode = supplier?.supplierCode ?? user?.storeId ?? 'SUPP-88992';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 600));
            if (mounted) setState(() {});
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              // Top Header Card: Store info, Open toggle, Notifications & QR
              _buildStoreHeader(storeName, storeCode),

              const SizedBox(height: 14),

              // Action Center: Việc cần xử lý hôm nay (Crucial for operations)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildActionCenter(),
              ),

              const SizedBox(height: 16),

              // Operational Performance: Hiệu suất hôm nay (100% money-free)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildPerformanceMetrics(),
              ),

              const SizedBox(height: 16),

              // Inventory Warning Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildInventoryAlertCard(),
              ),

              const SizedBox(height: 16),

              // Quick Management Toolkit: Tiện ích quản lý
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildQuickToolsGrid(),
              ),

              const SizedBox(height: 16),

              // Seller University / Guides: Cẩm nang nhà bán hàng
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSellerGuidesSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreHeader(String storeName, String storeCode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Iconsax.shop, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              // Store name and code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            storeName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF1E88E5),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            storeCode,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Đối tác CookConnect',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Quick action buttons: QR & Notification
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.qr_code_rounded, color: Colors.black87, size: 22),
                tooltip: 'Mã QR gian hàng',
                onPressed: () => _showStoreQrDialog(storeName, storeCode),
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Iconsax.notification, color: Colors.black87, size: 22),
                    tooltip: 'Thông báo',
                    onPressed: _showNotificationSheet,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status bar: Đang mở cửa / Tạm nghỉ nhận đơn
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isOpen ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isOpen ? const Color(0xFFBBF7D0) : const Color(0xFFFED7AA),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isOpen ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isOpen
                        ? 'Đang mở cửa • Sẵn sàng nhận đơn mới tự động'
                        : 'Tạm ngưng nhận đơn • Gian hàng đang ở chế độ nghỉ',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _isOpen ? const Color(0xFF15803D) : const Color(0xFFC2410C),
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: _isOpen,
                    activeColor: const Color(0xFF16A34A),
                    activeTrackColor: const Color(0xFFBBF7D0),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade200,
                    onChanged: (val) {
                      setState(() => _isOpen = val);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              val
                                  ? 'Gian hàng đã mở cửa nhận đơn!'
                                  : 'Gian hàng đã tạm dừng nhận đơn mới.',
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCenter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Iconsax.task_square, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Việc cần xử lý',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _switchTab(2), // Tab Đơn hàng
                child: const Row(
                  children: [
                    Text(
                      'Tất cả đơn',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildActionItem(
                count: '3',
                label: 'Chờ xác nhận',
                icon: Iconsax.timer_1,
                color: const Color(0xFFFF9800),
                bgColor: const Color(0xFFFFF3E0),
                onTap: () => _switchTab(2),
              ),
              const SizedBox(width: 8),
              _buildActionItem(
                count: '5',
                label: 'Chờ đóng gói',
                icon: Iconsax.box_add,
                color: const Color(0xFF2196F3),
                bgColor: const Color(0xFFE3F2FD),
                onTap: () => _switchTab(2),
              ),
              const SizedBox(width: 8),
              _buildActionItem(
                count: '12',
                label: 'Đang giao',
                icon: Iconsax.truck_fast,
                color: const Color(0xFF9C27B0),
                bgColor: const Color(0xFFF3E5F5),
                onTap: () => _switchTab(2),
              ),
              const SizedBox(width: 8),
              _buildActionItem(
                count: '0',
                label: 'Khiếu nại/Trả',
                icon: Iconsax.rotate_left,
                color: const Color(0xFF607D8B),
                bgColor: const Color(0xFFECEFF1),
                onTap: () => _switchTab(2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required String count,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 6),
              Text(
                count,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Iconsax.chart_2, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Hiệu suất hôm nay',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Vận hành xuất sắc',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMetricCard(
                title: 'Đơn hoàn thành',
                value: '18 đơn',
                subtext: '+3 đơn so với hôm qua',
                icon: Iconsax.bag_tick_2,
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 10),
              _buildMetricCard(
                title: 'Thời gian chuẩn bị',
                value: '12 phút',
                subtext: 'Nhanh hơn chuẩn 8p',
                icon: Iconsax.clock,
                color: const Color(0xFF00ACC1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMetricCard(
                title: 'Đánh giá gian hàng',
                value: '4.9 ★',
                subtext: '1.240 lượt đánh giá',
                icon: Iconsax.star_1,
                color: const Color(0xFFFFB300),
              ),
              const SizedBox(width: 10),
              _buildMetricCard(
                title: 'Tỉ lệ phản hồi chat',
                value: '98%',
                subtext: 'Phản hồi trong < 3 phút',
                icon: Iconsax.messages_2,
                color: const Color(0xFF7E57C2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtext,
              style: TextStyle(
                fontSize: 10.5,
                color: Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryAlertCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.box_time, color: Color(0xFFB45309), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cảnh báo tồn kho trong ngày',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '2 mặt hàng tươi sống sắp chạm ngưỡng tối thiểu (Thịt bò phi lê, Nấm đông cô). Hãy kiểm tra để không bị hết hàng.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.brown[700],
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _switchTab(1), // Tab Sản phẩm
                  child: const Row(
                    children: [
                      Text(
                        'Kiểm tra kho & Cập nhật ngay',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFFB45309)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickToolsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.category, size: 18, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Tiện ích quản lý',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: [
              _buildToolItem(
                icon: Iconsax.add_circle,
                label: 'Thêm món',
                color: AppColors.primary,
                bgColor: const Color(0xFFFBE9E7),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddProductScreen()),
                  );
                },
              ),
              _buildToolItem(
                icon: FlutterRemix.shopping_bag_line,
                label: 'Thực đơn',
                color: const Color(0xFF00897B),
                bgColor: const Color(0xFFE0F2F1),
                onTap: () => _switchTab(1),
              ),
              _buildToolItem(
                icon: Iconsax.receipt_2,
                label: 'Đơn hàng',
                color: const Color(0xFF1E88E5),
                bgColor: const Color(0xFFE3F2FD),
                onTap: () => _switchTab(2),
              ),
              _buildToolItem(
                icon: Iconsax.presention_chart,
                label: 'Quảng cáo',
                color: const Color(0xFF8E24AA),
                bgColor: const Color(0xFFF3E5F5),
                onTap: () => _switchTab(3),
              ),
              _buildToolItem(
                icon: Iconsax.message,
                label: 'Trò chuyện',
                color: const Color(0xFF3949AB),
                bgColor: const Color(0xFFE8EAF6),
                onTap: () => _switchTab(4),
              ),
              _buildToolItem(
                icon: Iconsax.shop,
                label: 'Hồ sơ quán',
                color: const Color(0xFFFB8C00),
                bgColor: const Color(0xFFFFF3E0),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StoreProfileScreen()),
                  );
                },
              ),
              _buildToolItem(
                icon: Iconsax.truck_fast,
                label: 'Giao hàng',
                color: const Color(0xFF43A047),
                bgColor: const Color(0xFFE8F5E9),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ShippingScreen()),
                  );
                },
              ),
              _buildToolItem(
                icon: Iconsax.house_2,
                label: 'Kho hàng',
                color: const Color(0xFF546E7A),
                bgColor: const Color(0xFFECEFF1),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WarehouseAddressScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSellerGuidesSection() {
    final guides = [
      {
        'title': 'Tiêu chuẩn bảo quản & đóng gói thực phẩm tươi sống 2026',
        'tag': 'Vận hành',
        'readTime': '3 phút đọc',
        'color': const Color(0xFF2E7D32),
      },
      {
        'title': 'Bí quyết tăng tỉ lệ đơn đặt lặp lại từ các quán ăn & gia đình',
        'tag': 'Tăng trưởng',
        'readTime': '4 phút đọc',
        'color': const Color(0xFF1565C0),
      },
      {
        'title': 'Chính sách hỗ trợ phí vận chuyển cho nhà bán hàng 5 sao',
        'tag': 'Chính sách',
        'readTime': '2 phút đọc',
        'color': const Color(0xFFE65100),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cẩm nang nhà bán hàng',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Xem tất cả',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: guides.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, index) {
            final guide = guides[index];
            final color = guide['color'] as Color;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Iconsax.book_1, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide['title'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                guide['tag'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              guide['readTime'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
