import 'package:cookconnect/features/settings/presentation/pages/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  final bool? isLoggedIn;
  final VoidCallback? onLoginRequested;
  final VoidCallback? onLogoutRequested;

  const SettingsScreen({
    super.key,
    this.isLoggedIn,
    this.onLoginRequested,
    this.onLogoutRequested,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cài đặt & Quyền riêng tư',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Section 1: Hoạt động
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Hoạt động',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Iconsax.document_text,
                      title: 'Quản lý bài đăng',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.slider_horizontal,
                      title: 'Tùy chọn nội dung',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.notification,
                      title: 'Thông báo',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.clock,
                      title: 'Thời gian sử dụng',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.people,
                      title: 'Gia đình',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 2: Tài khoản
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Tài khoản',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Iconsax.user,
                      title: 'Tài khoản',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.security_safe,
                      title: 'Bảo mật & Quyền',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.share,
                      title: 'Chia sẻ hồ sơ',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 3: Cài đặt hiển thị
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Cài đặt hiển thị',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Iconsax.lock,
                      title: 'Tài khoản riêng tư',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.user_minus,
                      title: 'Tài khoản hạn chế',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.forbidden_2,
                      title: 'Tài khoản bị chặn',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 4: Tương tác
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Tương tác',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Iconsax.message_text,
                      title: 'Bình luận',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.tag_user,
                      title: 'Nhắc đến',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.direct,
                      title: 'Tin nhắn trực tiếp',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.arrow_circle_down,
                      title: 'Tải về',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.eye,
                      title: 'Người xem',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 5: Tùy chọn
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Tùy chọn',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Iconsax.profile_2user,
                      title: 'Kiểm soát khán giả',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.presention_chart,
                      title: 'Quảng cáo',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.play_circle,
                      title: 'Phát video',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.global,
                      title: 'Ngôn ngữ',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.monitor,
                      title: 'Hiển thị',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.subtitle,
                      title: 'Trợ năng',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 6: Bộ nhớ đệm & Dữ liệu di động
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Bộ nhớ đệm & Dữ liệu di động',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Iconsax.video_slash,
                      title: 'Video ngoại tuyến',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.trash,
                      title: 'Giải phóng dung lượng',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.simcard,
                      title: 'Trình tiết kiệm dữ liệu',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 7: Hỗ trợ & Chính sách
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Hỗ trợ & Chính sách',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Iconsax.message_question,
                      title: 'Trung tâm Trợ giúp',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.shield_tick,
                      title: 'Trung tâm Quyền riêng tư',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.clipboard_text,
                      title: 'Điều khoản và Chính sách',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 8: Đăng nhập
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Iconsax.arrow_swap_horizontal,
                      title: 'Chuyển đổi tài khoản',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Iconsax.logout,
                      title: 'Đăng xuất',
                      textColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: () {
                        AuthService.instance.logout();
                        Navigator.pop(context);
                        if (widget.onLogoutRequested != null) {
                          widget.onLogoutRequested!();
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Color? textColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final effectiveTextColor = textColor ?? Colors.black87;
    final effectiveIconColor = iconColor ?? Colors.black87;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 16.5, color: effectiveIconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: effectiveTextColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
