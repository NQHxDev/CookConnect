import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final sections = [
      _PolicySection(
        number: '1',
        title: 'Thông tin chúng tôi thu thập',
        content:
            'Chúng tôi thu thập các thông tin bạn cung cấp trực tiếp khi tạo tài khoản CookConnect, chẳng hạn như tên hiển thị, địa chỉ email, số điện thoại và ngày sinh.\n\n'
            'Ngoài ra, chúng tôi lưu giữ các bài đăng công thức nấu ăn, video hướng dẫn, hình ảnh món ăn, bình luận và danh sách món ăn yêu thích do bạn chủ động chia sẻ.\n\n'
            'Chúng tôi cũng tự động ghi nhận một số thông tin kỹ thuật như địa chỉ IP, loại thiết bị và dữ liệu tương tác để tối ưu hiệu năng ứng dụng.',
        icon: Iconsax.document_text,
      ),
      _PolicySection(
        number: '2',
        title: 'Cách chúng tôi sử dụng thông tin',
        content:
            'Thông tin của bạn được sử dụng nhằm mục đích:\n'
            '• Cung cấp, duy trì và nâng cao trải nghiệm ứng dụng CookConnect.\n'
            '• Cá nhân hóa gợi ý công thức và gợi ý đầu bếp phù hợp trên tab Dành cho bạn.\n'
            '• Hỗ trợ bạn kết nối, trò chuyện và trao đổi kinh nghiệm ẩm thực với cộng đồng.\n'
            '• Phát hiện và ngăn chặn các hành vi gian lận, vi phạm bản quyền công thức nấu ăn hoặc quấy rối.',
        icon: Iconsax.magic_star,
      ),
      _PolicySection(
        number: '3',
        title: 'Bảo mật và Chia sẻ dữ liệu',
        content:
            'CookConnect cam kết KHÔNG bán dữ liệu cá nhân của bạn cho bất kỳ bên thứ ba nào vì mục đích thương mại độc lập.\n\n'
            'Chúng tôi chỉ chia sẻ dữ liệu khi có sự đồng ý của bạn, hoặc với các nhà cung cấp dịch vụ đám mây hạ tầng đạt chứng chỉ an ninh quốc tế (như máy chủ lưu trữ, dịch vụ gửi mã OTP).\n\n'
            'Toàn bộ kết nối truyền tải đều được bảo vệ bằng mã hóa chuẩn công nghiệp SSL/TLS 256-bit.',
        icon: Iconsax.shield_security,
      ),
      _PolicySection(
        number: '4',
        title: 'Quyền kiểm soát của bạn',
        content:
            'Bạn luôn nắm giữ toàn quyền đối với dữ liệu của mình trên CookConnect:\n'
            '• Bạn có thể chỉnh sửa thông tin hồ sơ bất kỳ lúc nào.\n'
            '• Bạn có thể cài đặt chế độ riêng tư cho từng bài viết/công thức (Công khai, Bạn bè, hoặc Chỉ mình tôi).\n'
            '• Bạn có quyền yêu cầu trích xuất bản sao toàn bộ dữ liệu cá nhân (file JSON/HTML).\n'
            '• Bạn có quyền yêu cầu xóa vĩnh viễn tài khoản và toàn bộ dữ liệu kèm theo.',
        icon: Iconsax.user_edit,
      ),
      _PolicySection(
        number: '5',
        title: 'Bảo vệ trẻ vị thành niên',
        content:
            'CookConnect không hướng tới đối tượng người dùng dưới 13 tuổi. Chúng tôi không cố ý thu thập thông tin nhận dạng cá nhân từ trẻ em.\n\n'
            'Nếu phát hiện tài khoản thuộc sở hữu của người dưới độ tuổi quy định mà không có sự đồng thuận từ phụ huynh, chúng tôi sẽ tiến hành vô hiệu hóa tài khoản và xóa dữ liệu liên quan.',
        icon: Iconsax.security_user,
      ),
      _PolicySection(
        number: '6',
        title: 'Thay đổi chính sách & Liên hệ',
        content:
            'Chính sách này có thể được cập nhật theo thời gian nhằm đáp ứng quy định pháp luật và cải tiến dịch vụ. Chúng tôi sẽ thông báo trước thông qua thông báo ứng dụng hoặc email.\n\n'
            'Nếu có bất kỳ thắc mắc nào, vui lòng liên hệ Bộ phận Bảo vệ Quyền riêng tư qua email: privacy@cookconnect.app.',
        icon: Iconsax.info_circle,
      ),
    ];

    final filteredSections = _searchQuery.trim().isEmpty
        ? sections
        : sections
            .where((s) =>
                s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.content.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

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
            UiI18nKeys.privacyPolicyDoc,
            fallback: 'Chính sách Quyền riêng tư',
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
              // Hero update note card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.shield_tick,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cam kết minh bạch',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'CookConnect cam kết minh bạch về cách thu thập, lưu trữ và bảo vệ dữ liệu ẩm thực của bạn.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey[700],
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Iconsax.clock,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  'Hiệu lực: Tháng 10, 2024 • Phiên bản 2.4',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm điều khoản...',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey[500],
                      ),
                      prefixIcon: Icon(
                        Iconsax.search_normal,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Policy Sections List
              if (filteredSections.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 32,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.document_filter,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Không tìm thấy điều khoản phù hợp',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vui lòng thử tìm kiếm bằng từ khóa khác',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Các điều khoản quy định (${filteredSections.length})',
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
                    children: List.generate(filteredSections.length, (index) {
                      final section = filteredSections[index];
                      final isLast = index == filteredSections.length - 1;
                      return Column(
                        children: [
                          _buildExpansionSection(section, primaryColor),
                          if (!isLast)
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                              color: Colors.grey.shade200,
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Contact DPO Box
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.message_question,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Cần hỗ trợ thêm về quyền riêng tư?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Nếu bạn có bất kỳ câu hỏi hoặc khiếu nại nào liên quan đến cách CookConnect xử lý dữ liệu của bạn, hãy liên hệ nhân viên bảo vệ dữ liệu (DPO).',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey[600],
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          const ClipboardData(text: 'privacy@cookconnect.app'),
                        );
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Đã sao chép email: privacy@cookconnect.app',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.sms, size: 15, color: primaryColor),
                            const SizedBox(width: 8),
                            const Text(
                              'privacy@cookconnect.app',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Iconsax.copy,
                              size: 13,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildExpansionSection(_PolicySection section, Color primaryColor) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: ExpansionTile(
        initiallyExpanded: section.number == '1',
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            section.number,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        title: Text(
          section.title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        iconColor: primaryColor,
        collapsedIconColor: Colors.grey[500],
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              section.content,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _PolicySection {
  final String number;
  final String title;
  final String content;
  final IconData icon;

  _PolicySection({
    required this.number,
    required this.title,
    required this.content,
    required this.icon,
  });
}
