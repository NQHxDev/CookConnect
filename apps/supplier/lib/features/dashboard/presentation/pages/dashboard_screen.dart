import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_kyb_verification_screen.dart';
import 'package:cook_connect_seller/features/menu/data/models/seller_product_item.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/add_product_screen.dart';
import 'package:cook_connect_seller/features/dashboard/data/models/dashboard_stats.dart';
import 'package:cook_connect_seller/features/dashboard/data/services/dashboard_api_service.dart';
import 'package:cook_connect_seller/features/orders/presentation/pages/orders_screen.dart';
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
  final DashboardApiService _dashboardApiService = DashboardApiService();
  DashboardStats _dashboardStats = const DashboardStats(isLoading: true);

  @override
  void initState() {
    super.initState();
    SellerAuthService.instance.addListener(_onAuthChanged);
    _loadDashboardData(showLoading: false);
  }

  @override
  void dispose() {
    SellerAuthService.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    _loadDashboardData(showLoading: false);
    if (mounted) setState(() {});
  }

  Future<void> _loadDashboardData({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _dashboardStats = _dashboardStats.copyWith(isLoading: true);
      });
    }

    try {
      final token = await SellerAuthService.instance.getValidAccessToken();
      final profile = SellerAuthService.instance.supplierProfile;

      final stats = await _dashboardApiService.getOperationalDashboardStats(
        token: token ?? '',
        supplierProfile: profile,
      );

      if (mounted) {
        setState(() {
          _dashboardStats = stats;
        });
      }
    } catch (e) {
      debugPrint('DashboardScreen _loadDashboardData error: $e');
      if (mounted) {
        setState(() {
          _dashboardStats = _dashboardStats.copyWith(isLoading: false);
        });
      }
    }
  }

  void _switchTab(int tabIndex) {
    MainNavigationScreen.navigateToTab(context, tabIndex);
  }

  void _navigateToOrders({required String category, required String status}) {
    OrdersScreen.onApplyFilter?.call(category, status);
    _switchTab(2); // Go to Orders tab
  }

  void _showNotificationSheet() {
    final pendingCount = _dashboardStats.pendingConfirmationCount;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
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
              title: Text(
                pendingCount > 0
                    ? '$pendingCount đơn hàng mới chờ duyệt'
                    : 'Không có đơn hàng mới chờ duyệt',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                pendingCount > 0
                    ? 'Khách hàng vừa đặt các đơn hàng nguyên liệu tươi'
                    : 'Hệ thống sẵn sàng nhận đơn mới',
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToOrders(
                  category: 'needs_action',
                  status: 'Cần vận chuyển trong vòng 24h',
                );
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
    final kybBanner = _buildKybProgressCard(supplier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomPullToRefresh(
          primaryColor: AppColors.primary,
          onRefresh: () async {
            await Future.wait([
              SellerAuthService.instance.checkSupplierStatus(),
              _loadDashboardData(showLoading: false),
            ]);
            if (mounted) setState(() {});
          },
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Top Header Card: Store info, Notifications & QR
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildStoreHeader(storeName, storeCode, supplier),
                  ),

                  // KYB Onboarding Progress Banner (Nhỏ gọn, bấm vào mở trang chi tiết)
                  if (kybBanner != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: kybBanner,
                    ),
                  ],

                  const SizedBox(height: 16),

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
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader(String storeName, String storeCode, SupplierProfile? supplier) {
    final isVerified = supplier?.isVerified ?? false;
    final status = supplier?.supplierStatus ?? 'PENDING';
    final isApproved = isVerified && status == 'ACTIVE';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar / Store Icon
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StoreProfileScreen()),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: (supplier?.supplierLogoUrl != null &&
                      supplier!.supplierLogoUrl!.isNotEmpty &&
                      (supplier.supplierLogoUrl!.startsWith('http://') ||
                          supplier.supplierLogoUrl!.startsWith('https://')))
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.network(
                        supplier.supplierLogoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Iconsax.shop,
                          color: Color(0xFF374151),
                          size: 18,
                        ),
                      ),
                    )
                  : const Icon(
                      Iconsax.shop,
                      color: Color(0xFF374151),
                      size: 18,
                    ),
            ),
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
                    Icon(
                      isApproved
                          ? Icons.verified_rounded
                          : Icons.access_time_rounded,
                      color: isApproved
                          ? const Color(0xFF1E88E5)
                          : const Color(0xFFE65100),
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
                    Flexible(
                      child: Text(
                        isApproved ? 'Đối tác chính thức' : 'Đang thiết lập gian hàng',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isApproved ? Colors.grey[600] : const Color(0xFFE65100),
                          fontWeight: isApproved ? FontWeight.normal : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
              if (_dashboardStats.pendingConfirmationCount > 0)
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
    );
  }

  /// Banner nhỏ gọn hiển thị trạng thái hồ sơ Supplier (KYB)
  /// Nhấn vào để chuyển sang màn hình hoàn thiện/xem hồ sơ SellerKybVerificationScreen
  Widget? _buildKybProgressCard(SupplierProfile? supplier) {
    final status = supplier?.supplierStatus ?? 'PENDING';
    final isVerified = supplier?.isVerified ?? false;
    final rejectionReason = supplier?.rejectionReason;

    // Trạng thái 1: Đã xác minh hoàn tất (ACTIVE & isVerified: true) -> Không cần hiển thị banner
    if (isVerified && status == 'ACTIVE') {
      return null;
    }

    // Trạng thái 2: Đang thẩm định hồ sơ (UNDER_REVIEW)
    if (status == 'UNDER_REVIEW') {
      return _buildCompactKybBanner(
        icon: Icons.hourglass_top_rounded,
        iconColor: const Color(0xFF111827),
        iconBgColor: const Color(0xFFF3F4F6),
        title: 'Hồ sơ đang được xét duyệt',
        subtitle: 'CookConnect đang duyệt thông tin • Nhấn để xem',
        bgColor: Colors.white,
        borderColor: const Color(0xFFE5E7EB),
        titleColor: const Color(0xFF111827),
        subtitleColor: const Color(0xFF6B7280),
        trailingBadge: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Đang duyệt',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SellerKybVerificationScreen(),
            ),
          );
        },
      );
    }

    // Trạng thái 3: Bị từ chối duyệt (REJECTED)
    if (status == 'REJECTED') {
      return _buildCompactKybBanner(
        icon: Iconsax.close_circle,
        iconColor: const Color(0xFFDC2626),
        iconBgColor: const Color(0xFFFEE2E2),
        title: 'Hồ sơ chưa được duyệt',
        subtitle: (rejectionReason != null && rejectionReason.isNotEmpty)
            ? 'Lý do: $rejectionReason • Nhấn để sửa'
            : 'Vui lòng kiểm tra lại thông tin & gửi lại',
        bgColor: Colors.white,
        borderColor: const Color(0xFFFCA5A5),
        titleColor: const Color(0xFF991B1B),
        subtitleColor: const Color(0xFFB91C1C),
        trailingBadge: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Cần sửa',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFFDC2626),
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SellerKybVerificationScreen(),
            ),
          );
        },
      );
    }

    // Trạng thái 4: PENDING - Chưa nộp / Chưa hoàn thành hồ sơ đối tác
    return _buildCompactKybBanner(
      icon: Iconsax.shield_security,
      iconColor: const Color(0xFF111827),
      iconBgColor: const Color(0xFFF3F4F6),
      title: 'Hoàn thành hồ sơ đối tác',
      subtitle: 'Xác minh thông tin để mở bán • Nhấn để thực hiện',
      bgColor: Colors.white,
      borderColor: const Color(0xFFE5E7EB),
      titleColor: const Color(0xFF111827),
      subtitleColor: const Color(0xFF6B7280),
      trailingBadge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Chưa nộp',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SellerKybVerificationScreen(),
          ),
        );
      },
    );
  }

  Widget _buildCompactKybBanner({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color borderColor,
    required Color titleColor,
    required Color subtitleColor,
    required VoidCallback onTap,
    Widget? trailingBadge,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1.5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: subtitleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (trailingBadge != null) ...[
                trailingBadge,
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: titleColor.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
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
                onTap: () => _navigateToOrders(
                  category: 'shipping',
                  status: 'Tất cả',
                ),
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
                count: _dashboardStats.pendingConfirmationCount.toString(),
                label: 'Chờ xác nhận',
                icon: Iconsax.timer_1,
                color: const Color(0xFFFF9800),
                bgColor: const Color(0xFFFFF3E0),
                onTap: () => _navigateToOrders(
                  category: 'needs_action',
                  status: 'Cần vận chuyển trong vòng 24h',
                ),
              ),
              const SizedBox(width: 8),
              _buildActionItem(
                count: _dashboardStats.packagingCount.toString(),
                label: 'Chờ đóng gói',
                icon: Iconsax.box_add,
                color: const Color(0xFF2196F3),
                bgColor: const Color(0xFFE3F2FD),
                onTap: () => _navigateToOrders(
                  category: 'shipping',
                  status: 'Đang chờ vận chuyển',
                ),
              ),
              const SizedBox(width: 8),
              _buildActionItem(
                count: _dashboardStats.shippingCount.toString(),
                label: 'Đang giao',
                icon: Iconsax.truck_fast,
                color: const Color(0xFF9C27B0),
                bgColor: const Color(0xFFF3E5F5),
                onTap: () => _navigateToOrders(
                  category: 'shipping',
                  status: 'Đang trung chuyển',
                ),
              ),
              const SizedBox(width: 8),
              _buildActionItem(
                count: _dashboardStats.returnsCount.toString(),
                label: 'Khiếu nại/Trả',
                icon: Iconsax.rotate_left,
                color: const Color(0xFF607D8B),
                bgColor: const Color(0xFFECEFF1),
                onTap: () => _navigateToOrders(
                  category: 'shipping',
                  status: 'Đã hủy',
                ),
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
    final supplier = SellerAuthService.instance.supplierProfile;
    final isVerified = supplier?.isVerified ?? false;

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
              const Expanded(
                child: Row(
                  children: [
                    Icon(Iconsax.chart_2, size: 18, color: AppColors.primary),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Hiệu suất hôm nay',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _dashboardStats.operationalStatusBadge,
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
                value: '${_dashboardStats.todayCompletedOrders} đơn',
                subtext: _dashboardStats.completedComparisonText,
                icon: Iconsax.bag_tick_2,
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 10),
              _buildMetricCard(
                title: 'Thời gian chuẩn bị',
                value: _dashboardStats.prepTimeString,
                subtext: _dashboardStats.prepTimeSubtext,
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
                value: _dashboardStats.ratingString,
                subtext: isVerified ? 'Gian hàng đã xác minh' : 'Đánh giá vận hành',
                icon: Iconsax.star_1,
                color: const Color(0xFFFFB300),
              ),
              const SizedBox(width: 10),
              _buildMetricCard(
                title: 'Tỉ lệ phản hồi chat',
                value: '${_dashboardStats.chatResponseRate}%',
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
                onTap: () async {
                  final newProduct = await Navigator.of(context).push<SellerProductItem>(
                    MaterialPageRoute(builder: (_) => const AddProductScreen()),
                  );
                  if (newProduct != null && mounted) {
                    _switchTab(1); // Chuyển sang tab Thực đơn để thấy ngay card sản phẩm vừa đăng
                  }
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
          separatorBuilder: (_, _) => const SizedBox(height: 8),
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
