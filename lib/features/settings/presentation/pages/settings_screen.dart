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
  String _selectedLanguage = 'Tiếng Việt';
  bool _notificationsEnabled = true;
  bool _dataSaverEnabled = false;
  double _cacheSizeMb = 34.8;

  @override
  void initState() {
    super.initState();
    AuthService.instance.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  bool get _isLoggedIn =>
      AuthService.instance.isLoggedIn || (widget.isLoggedIn ?? false);

  String get _userName {
    final user = AuthService.instance.currentUser;
    if (user != null && user.fullName.isNotEmpty) {
      return user.fullName;
    }
    return _isLoggedIn ? 'Chef Linh Đan' : 'Khách (Chưa đăng nhập)';
  }

  String get _userSubtitle {
    final user = AuthService.instance.currentUser;
    if (user != null && user.email.isNotEmpty) {
      return '${user.email} • Đang hoạt động';
    }
    return _isLoggedIn
        ? '@linhdan_cook • Đang hoạt động'
        : 'Đăng nhập để đồng bộ dữ liệu của bạn';
  }

  void _clearAppCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Iconsax.trash, color: Colors.red),
            SizedBox(width: 10),
            Text('Xoá bộ nhớ đệm?'),
          ],
        ),
        content: Text(
          'Dọn dẹp ${_cacheSizeMb.toStringAsFixed(1)} MB hình ảnh & video tạm thời để giải phóng dung lượng máy. Dữ liệu công thức đã lưu của bạn sẽ không bị ảnh hưởng.',
          style: const TextStyle(fontSize: 14, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _cacheSizeMb = 0.0;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Iconsax.tick_circle5, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Đã dọn dẹp sạch bộ nhớ đệm!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Xoá ngay'),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Chọn ngôn ngữ hiển thị',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                _buildLanguageOption('Tiếng Việt', 'Tiếng Việt (Mặc định)'),
                _buildLanguageOption('English (US)', 'English (United States)'),
                _buildLanguageOption(
                  '日本語',
                  'Japanese (Sắp ra mắt)',
                  disabled: true,
                ),
                _buildLanguageOption(
                  '한국어',
                  'Korean (Sắp ra mắt)',
                  disabled: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String lang,
    String subtitle, {
    bool disabled = false,
  }) {
    final isSelected = _selectedLanguage == lang;
    return ListTile(
      enabled: !disabled,
      title: Text(
        lang,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: disabled ? Colors.grey[400] : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: isSelected
          ? Icon(
              Iconsax.tick_circle5,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        setState(() => _selectedLanguage = lang);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã đổi ngôn ngữ sang $lang'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  void _showFaqModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
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
                const Row(
                  children: [
                    Icon(
                      Iconsax.message_question,
                      color: Colors.orange,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Trung tâm trợ giúp & FAQ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFaqTile(
                  'Tôi có thể đăng video nấu ăn như thế nào?',
                  'Bạn chỉ cần đăng nhập tài khoản, nhấn vào nút biểu tượng dấu "+" ở thanh menu dưới màn hình chính để quay trực tiếp hoặc tải video lên từ thư viện máy.',
                ),
                _buildFaqTile(
                  'Ứng dụng CookConnect có tốn phí không?',
                  'CookConnect hoàn toàn miễn phí 100% cho mọi người dùng xem, tìm kiếm và chia sẻ công thức nấu ăn.',
                ),
                _buildFaqTile(
                  'Làm sao để lưu lại công thức tôi thích?',
                  'Bạn chỉ cần nhấn vào biểu tượng Bookmark (dấu trang) ở thanh tương tác bên phải video khi đã đăng nhập tài khoản.',
                ),
                _buildFaqTile(
                  'Cách báo cáo video vi phạm hoặc nội dung xấu?',
                  'Nhấn giữ vào màn hình video hoặc bấm nút "Chia sẻ" > Chọn "Báo cáo vi phạm" để đội ngũ quản trị kiểm duyệt và xử lý nhanh chóng.',
                ),
                _buildFaqTile(
                  'Quên mật khẩu tài khoản xử lý thế nào?',
                  'Tại màn hình Đăng nhập, chọn "Quên mật khẩu" và làm theo hướng dẫn để nhận mã xác minh OTP qua Email hoặc Số điện thoại của bạn.',
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        shape: const Border(),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackModal() {
    final TextEditingController feedbackCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gửi phản hồi & Đóng góp ý kiến',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ý kiến của bạn giúp chúng tôi cải thiện trải nghiệm nấu nướng tuyệt vời hơn mỗi ngày.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung góp ý hoặc thông báo lỗi của bạn...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Iconsax.tick_circle5, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Cảm ơn bạn! Phản hồi đã được gửi đến đội ngũ phát triển.',
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text(
                  'Gửi đóng góp',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Điều khoản & Quyền riêng tư'),
        content: const SingleChildScrollView(
          child: Text(
            'Chào mừng bạn đến với CookConnect. Chúng tôi cam kết bảo vệ thông tin và dữ liệu cá nhân của người dùng:\n\n'
            '1. Bản quyền nội dung: Mọi video và hình ảnh món ăn bạn đăng tải đều thuộc quyền sở hữu trí tuệ của bạn.\n\n'
            '2. Bảo mật thông tin: Chúng tôi không bao giờ chia sẻ thông tin cá nhân của bạn cho bên thứ ba vì mục đích thương mại khi chưa có sự đồng ý.\n\n'
            '3. An toàn cộng đồng: Nghiêm cấm các nội dung kích động thù địch, vi phạm thuần phong mỹ tục hoặc thông tin sai lệch về an toàn vệ sinh thực phẩm.',
            style: TextStyle(fontSize: 13.5, height: 1.45),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.cake,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'CookConnect',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Phiên bản 1.0.0 (Build 100)',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 14),
            const Text(
              'Nền tảng mạng xã hội video ẩm thực & chia sẻ công thức nấu ăn sáng tạo hàng đầu dành cho người yêu bếp.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, height: 1.45),
            ),
            const SizedBox(height: 18),
            Text(
              '© 2026 CookConnect Inc. All rights reserved.',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // 1. Account Status Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: primaryColor.withValues(alpha: 0.12),
                  child: Icon(
                    _isLoggedIn ? Iconsax.user_tick : Iconsax.user,
                    color: primaryColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userSubtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (!_isLoggedIn)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (widget.onLoginRequested != null) {
                        widget.onLoginRequested!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Đăng nhập'),
                  ),
              ],
            ),
          ),

          // 2. Section: Cài đặt ứng dụng
          _buildSettingsGroup(
            title: 'Cài đặt ứng dụng',
            items: [
              _buildSettingsTile(
                icon: Iconsax.global,
                title: 'Ngôn ngữ',
                value: _selectedLanguage,
                onTap: _showLanguagePicker,
              ),
              _buildSettingsTile(
                icon: Iconsax.notification,
                title: 'Thông báo đẩy',
                subtitle: 'Gợi ý món ăn ngon và hoạt động mới',
                trailing: Switch.adaptive(
                  value: _notificationsEnabled,
                  activeTrackColor: primaryColor,
                  onChanged: (val) {
                    setState(() => _notificationsEnabled = val);
                  },
                ),
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Iconsax.video_circle,
                title: 'Tiết kiệm dữ liệu mạng',
                subtitle: 'Giảm độ phân giải video khi dùng 3G/4G',
                trailing: Switch.adaptive(
                  value: _dataSaverEnabled,
                  activeTrackColor: primaryColor,
                  onChanged: (val) {
                    setState(() => _dataSaverEnabled = val);
                  },
                ),
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Iconsax.trash,
                title: 'Xoá bộ nhớ đệm',
                subtitle: 'Giải phóng bộ nhớ tạm thời',
                value: '${_cacheSizeMb.toStringAsFixed(1)} MB',
                onTap: _clearAppCache,
              ),
            ],
          ),

          // 3. Section: Hỗ trợ & Thông tin
          _buildSettingsGroup(
            title: 'Hỗ trợ & Thông tin',
            items: [
              _buildSettingsTile(
                icon: Iconsax.message_question,
                title: 'Trung tâm trợ giúp & FAQ',
                subtitle: 'Câu hỏi thường gặp và hướng dẫn',
                onTap: _showFaqModal,
              ),
              _buildSettingsTile(
                icon: Iconsax.direct_send,
                title: 'Gửi góp ý & Báo lỗi',
                subtitle: 'Phản hồi giúp cải thiện sản phẩm',
                onTap: _showFeedbackModal,
              ),
              _buildSettingsTile(
                icon: Iconsax.star,
                title: 'Đánh giá ứng dụng',
                subtitle: 'Ủng hộ CookConnect 5 sao trên App Store',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cảm ơn tình cảm và sự ủng hộ của bạn dành cho CookConnect! ❤️',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Iconsax.shield_tick,
                title: 'Điều khoản & Quyền riêng tư',
                onTap: _showPrivacyDialog,
              ),
              _buildSettingsTile(
                icon: Iconsax.info_circle,
                title: 'Về CookConnect',
                value: 'v1.0.0',
                onTap: _showAboutDialog,
              ),
            ],
          ),

          // 4. Logout action if logged in
          if (_isLoggedIn)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: OutlinedButton.icon(
                onPressed: () {
                  AuthService.instance.logout();
                  Navigator.pop(context);
                  if (widget.onLogoutRequested != null) {
                    widget.onLogoutRequested!();
                  }
                },
                icon: const Icon(Iconsax.logout, color: Colors.red, size: 20),
                label: const Text(
                  'Đăng xuất tài khoản',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  'CookConnect v1.0.0 (Build 100)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Make with ❤️ for food lovers',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
                letterSpacing: 0.3,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? value,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (trailing != null)
              trailing
            else
              Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
