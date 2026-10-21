import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';

class DownloadDataScreen extends StatefulWidget {
  const DownloadDataScreen({super.key});

  @override
  State<DownloadDataScreen> createState() => _DownloadDataScreenState();
}

class _DownloadDataScreenState extends State<DownloadDataScreen> {
  // Data categories selected
  bool _includeProfile = true;
  bool _includeRecipes = true;
  bool _includeActivity = true;
  bool _includeSaved = true;

  // Format: 'html' or 'json'
  String _selectedFormat = 'html';

  // Request state
  bool _hasPendingRequest = false;
  DateTime? _requestedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final currentUser = AuthService.instance.currentUser;
    final userEmail = (currentUser?.email != null && currentUser!.email.isNotEmpty)
        ? currentUser.email
        : 'cookconnect.user@gmail.com';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          ApiI18n.text(
            UiI18nKeys.privacyDownloadData,
            fallback: 'Tải xuống dữ liệu của bạn',
          ),
          style: const TextStyle(
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // Info Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.document_download,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bản sao lưu trữ dữ liệu cá nhân',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bạn có thể yêu cầu tải về một bản sao lưu toàn bộ thông tin tài khoản, các công thức nấu ăn bạn đã đăng, bình luận và danh sách món ăn yêu thích.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey[600],
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (_hasPendingRequest) ...[
                const SizedBox(height: 16),
                // Pending Request status card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.clock,
                            color: Colors.orange.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Đang chuẩn bị dữ liệu của bạn',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Yêu cầu của bạn đã được tiếp nhận vào ${_requestedAt != null ? "${_requestedAt!.day}/${_requestedAt!.month}/${_requestedAt!.year} ${_requestedAt!.hour}:${_requestedAt!.minute.toString().padLeft(2, '0')}" : "gần đây"}.\n'
                        'Chúng tôi sẽ gửi một liên kết tải xuống file lưu trữ đến email $userEmail trong vòng 24 - 48 giờ.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.orange.shade900,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Section 1: Choose data categories
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Chọn loại dữ liệu cần sao lưu',
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
                    _buildCheckboxTile(
                      title: 'Thông tin hồ sơ & Tài khoản',
                      subtitle: 'Tên đầu bếp, tiểu sử, ngày sinh, email và cài đặt',
                      icon: Iconsax.user,
                      value: _includeProfile,
                      onChanged: (v) => setState(() => _includeProfile = v ?? false),
                    ),
                    _buildDivider(),
                    _buildCheckboxTile(
                      title: 'Công thức & Bài viết ẩm thực',
                      subtitle: 'Danh sách nguyên liệu, các bước nấu và ảnh/video',
                      icon: Iconsax.book_1,
                      value: _includeRecipes,
                      onChanged: (v) => setState(() => _includeRecipes = v ?? false),
                    ),
                    _buildDivider(),
                    _buildCheckboxTile(
                      title: 'Hoạt động & Tương tác',
                      subtitle: 'Bình luận, lượt thích công thức và lịch sử tìm kiếm',
                      icon: Iconsax.message_favorite,
                      value: _includeActivity,
                      onChanged: (v) => setState(() => _includeActivity = v ?? false),
                    ),
                    _buildDivider(),
                    _buildCheckboxTile(
                      title: 'Bộ sưu tập & Món ăn đã lưu',
                      subtitle: 'Danh mục các món ăn yêu thích bạn đã bookmark',
                      icon: Iconsax.archive_book,
                      value: _includeSaved,
                      onChanged: (v) => setState(() => _includeSaved = v ?? false),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 2: Choose File Format
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Chọn định dạng file',
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
                    _buildRadioTile(
                      title: 'HTML',
                      subtitle: 'Dễ dàng đọc và xem lại trên trình duyệt web điện thoại hoặc máy tính',
                      value: 'html',
                      groupValue: _selectedFormat,
                      onChanged: (v) => setState(() => _selectedFormat = v!),
                    ),
                    _buildDivider(),
                    _buildRadioTile(
                      title: 'JSON',
                      subtitle: 'Tệp dữ liệu có cấu trúc, thuận tiện nhập vào các phần mềm hoặc dịch vụ khác',
                      value: 'json',
                      groupValue: _selectedFormat,
                      onChanged: (v) => setState(() => _selectedFormat = v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Email notification destination
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Địa chỉ nhận tệp dữ liệu',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.sms, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email liên kết tài khoản',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _hasPendingRequest ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: primaryColor.withValues(alpha: 0.45),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _hasPendingRequest ? 'Đã gửi yêu cầu' : 'Yêu cầu tải dữ liệu',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _submitRequest() {
    if (!_includeProfile && !_includeRecipes && !_includeActivity && !_includeSaved) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ít nhất một danh mục dữ liệu cần tải!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Xác nhận yêu cầu sao lưu',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: const Text(
          'CookConnect sẽ tiến hành đóng gói dữ liệu của bạn và gửi đường dẫn tải về qua email trong vòng 24 - 48 giờ. Bạn có chắc chắn muốn tiếp tục?',
          style: TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Hủy',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _hasPendingRequest = true;
                _requestedAt = DateTime.now();
              });
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Yêu cầu tải dữ liệu đã được gửi thành công!',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Đồng ý',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }
}
