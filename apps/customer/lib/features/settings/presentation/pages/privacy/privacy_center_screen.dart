import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/settings/presentation/pages/privacy/download_data_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/privacy/privacy_policy_screen.dart';

class PrivacyCenterScreen extends StatefulWidget {
  const PrivacyCenterScreen({super.key});

  @override
  State<PrivacyCenterScreen> createState() => _PrivacyCenterScreenState();
}

class _PrivacyCenterScreenState extends State<PrivacyCenterScreen> {
  // Privacy preferences states
  int _recipeAudienceIndex = 0; // 0: Public, 1: Followers, 2: Only me
  bool _allowRecipeRemix = true;
  bool _suggestLocations = true;
  bool _suggestAccount = true;
  bool _activeStatus = true;
  bool _syncContactsSearch = false;
  bool _personalizedFeed = true;
  bool _personalizedAds = false;

  final List<String> _audienceLabels = [
    'Mọi người (Công khai)',
    'Người theo dõi',
    'Chỉ mình tôi (Bí quyết riêng)',
  ];

  final List<String> _audienceDescriptions = [
    'Bất kỳ ai trên CookConnect đều có thể xem công thức và mẹo nấu ăn của bạn.',
    'Chỉ những đầu bếp và bạn bè đang theo dõi bạn mới có thể xem nội dung này.',
    'Chỉ một mình bạn có thể xem các công thức và ghi chú ẩm thực này.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ValueListenableBuilder<String>(
      valueListenable: ApiI18n.languageNotifier,
      builder: (context, _, child) {
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
                UiI18nKeys.settingsPrivacyCenter,
                fallback: 'Trung tâm Quyền riêng tư',
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // 1. Hero Commitment Banner
                  _buildHeroCard(primaryColor),

                  const SizedBox(height: 16),

                  // 2. Section: Dữ liệu cá nhân & Tải xuống
                  _buildSectionHeader(
                    ApiI18n.text(
                      UiI18nKeys.privacySectionData,
                      fallback: 'Dữ liệu cá nhân & Tải xuống',
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
                        _buildSettingsRow(
                          icon: Iconsax.document_download,
                          title: ApiI18n.text(
                            UiI18nKeys.privacyDownloadData,
                            fallback: 'Tải xuống dữ liệu của bạn',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacyDownloadDataSubtitle,
                            fallback:
                                'Yêu cầu bản sao thông tin tài khoản, công thức đã chia sẻ và lịch sử',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DownloadDataScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildSettingsRow(
                          icon: Iconsax.search_status,
                          title: ApiI18n.text(
                            UiI18nKeys.privacyClearSearch,
                            fallback: 'Xóa lịch sử tìm kiếm món ăn',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacyClearSearchSubtitle,
                            fallback:
                                'Xóa toàn bộ từ khóa công thức, đầu bếp và nguyên liệu đã lưu',
                          ),
                          onTap: _showClearSearchHistoryDialog,
                        ),
                        _buildDivider(),
                        _buildSettingsRow(
                          icon: Iconsax.mobile,
                          title: ApiI18n.text(
                            UiI18nKeys.privacyDevicePermissions,
                            fallback: 'Quyền truy cập thiết bị',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacyDevicePermissionsSubtitle,
                            fallback:
                                'Xem và quản lý quyền Máy ảnh, Thư viện ảnh, Vị trí và Thông báo',
                          ),
                          onTap: _showDevicePermissionsSheet,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Section: Công thức & Nội dung ẩm thực
                  _buildSectionHeader(
                    ApiI18n.text(
                      UiI18nKeys.privacySectionContent,
                      fallback: 'Công thức & Nội dung ẩm thực',
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
                        _buildSettingsRow(
                          icon: Iconsax.eye,
                          title: ApiI18n.text(
                            UiI18nKeys.privacyRecipeAudience,
                            fallback: 'Quyền riêng tư công thức mặc định',
                          ),
                          subtitle: _audienceLabels[_recipeAudienceIndex],
                          onTap: _showAudiencePickerSheet,
                        ),
                        _buildDivider(),
                        _buildSwitchRow(
                          icon: Iconsax.repeat,
                          title: ApiI18n.text(
                            UiI18nKeys.privacyAllowRemix,
                            fallback: 'Cho phép lưu & biến tấu công thức',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacyAllowRemixSubtitle,
                            fallback:
                                'Cho phép đầu bếp khác tạo biến tấu hoặc trích dẫn công thức của bạn',
                          ),
                          value: _allowRecipeRemix,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            setState(() => _allowRecipeRemix = val);
                          },
                        ),
                        _buildDivider(),
                        _buildSwitchRow(
                          icon: Iconsax.location,
                          title: ApiI18n.text(
                            UiI18nKeys.privacyLocationTags,
                            fallback: 'Gợi ý vị trí quán ăn / nhà hàng',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacyLocationTagsSubtitle,
                            fallback:
                                'Hiển thị địa điểm ẩm thực khi chia sẻ công thức hoặc trải nghiệm',
                          ),
                          value: _suggestLocations,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            setState(() => _suggestLocations = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. Section: Khả năng hiển thị & Kết nối
                  _buildSectionHeader(
                    ApiI18n.text(
                      UiI18nKeys.privacySectionSocial,
                      fallback: 'Khả năng hiển thị & Kết nối',
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
                        _buildSwitchRow(
                          icon: Iconsax.profile_2user,
                          title: ApiI18n.text(
                            UiI18nKeys.privacySuggestAccount,
                            fallback: 'Đề xuất tài khoản cho người khác',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacySuggestAccountSubtitle,
                            fallback:
                                'Gợi ý tài khoản của bạn cho những người có cùng đam mê ẩm thực',
                          ),
                          value: _suggestAccount,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            setState(() => _suggestAccount = val);
                          },
                        ),
                        _buildDivider(),
                        _buildSwitchRow(
                          icon: Iconsax.status_up,
                          title: ApiI18n.text(
                            UiI18nKeys.privacyActiveStatus,
                            fallback: 'Trạng thái hoạt động trong bếp',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacyActiveStatusSubtitle,
                            fallback:
                                'Cho phép bạn bè thấy khi bạn đang online trên ứng dụng CookConnect',
                          ),
                          value: _activeStatus,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            setState(() => _activeStatus = val);
                          },
                        ),
                        _buildDivider(),
                        _buildSwitchRow(
                          icon: Iconsax.user_search,
                          title: ApiI18n.text(
                            UiI18nKeys.privacySyncContacts,
                            fallback: 'Tìm kiếm bằng SĐT / Email',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacySyncContactsSubtitle,
                            fallback:
                                'Cho phép người quen có thông tin liên hệ tìm thấy tài khoản của bạn',
                          ),
                          value: _syncContactsSearch,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            setState(() => _syncContactsSearch = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. Section: Cá nhân hóa & Quảng cáo
                  _buildSectionHeader(
                    ApiI18n.text(
                      UiI18nKeys.privacySectionPersonalization,
                      fallback: 'Cá nhân hóa & Quảng cáo',
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
                        _buildSwitchRow(
                          icon: Iconsax.magic_star,
                          title: ApiI18n.text(
                            UiI18nKeys.privacyPersonalizedFeed,
                            fallback: 'Cá nhân hóa nguồn cấp dữ liệu',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacyPersonalizedFeedSubtitle,
                            fallback:
                                'Sử dụng lịch sử xem món ăn để tối ưu gợi ý trang Dành cho bạn',
                          ),
                          value: _personalizedFeed,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            setState(() => _personalizedFeed = val);
                          },
                        ),
                        _buildDivider(),
                        _buildSwitchRow(
                          icon: Iconsax.presention_chart,
                          title: ApiI18n.text(
                            UiI18nKeys.privacyPersonalizedAds,
                            fallback: 'Quảng cáo được cá nhân hóa',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacyPersonalizedAdsSubtitle,
                            fallback:
                                'Nhận quảng cáo nguyên liệu và địa điểm ăn uống phù hợp với sở thích',
                          ),
                          value: _personalizedAds,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            setState(() => _personalizedAds = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 6. Section: Chính sách & Pháp lý
                  _buildSectionHeader(
                    ApiI18n.text(
                      UiI18nKeys.privacySectionPolicy,
                      fallback: 'Chính sách & Pháp lý',
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
                        _buildSettingsRow(
                          icon: Iconsax.shield_tick,
                          title: ApiI18n.text(
                            UiI18nKeys.privacyPolicyDoc,
                            fallback: 'Chính sách Quyền riêng tư CookConnect',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacyPolicyDocSubtitle,
                            fallback:
                                'Quy định chi tiết về thu thập, xử lý và bảo vệ dữ liệu cá nhân',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildSettingsRow(
                          icon: Iconsax.archive_tick,
                          title: ApiI18n.text(
                            UiI18nKeys.privacyCookiePolicy,
                            fallback: 'Chính sách Cookie & Lưu trữ ứng dụng',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacyCookiePolicySubtitle,
                            fallback:
                                'Cách CookConnect sử dụng bộ nhớ đệm và công nghệ lưu trữ cục bộ',
                          ),
                          onTap: _showCookiePolicySheet,
                        ),
                        _buildDivider(),
                        _buildSettingsRow(
                          icon: Iconsax.sms_tracking,
                          title: ApiI18n.text(
                            UiI18nKeys.privacyContactDpo,
                            fallback: 'Liên hệ Đội ngũ Bảo vệ Dữ liệu (DPO)',
                          ),
                          subtitle: ApiI18n.text(
                            UiI18nKeys.privacyContactDpoSubtitle,
                            fallback:
                                'privacy@cookconnect.app • Giải đáp thắc mắc quyền riêng tư',
                          ),
                          onTap: _showContactDpoDialog,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Hero Card at the top
  Widget _buildHeroCard(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.16),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.security_safe,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ApiI18n.text(
                    UiI18nKeys.privacyHeroBadge,
                    fallback: 'Bảo mật & Minh bạch',
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ApiI18n.text(
              UiI18nKeys.privacyHeroTitle,
              fallback: 'Quyền kiểm soát dữ liệu của bạn',
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            ApiI18n.text(
              UiI18nKeys.privacyHeroSubtitle,
              fallback:
                  'CookConnect cam kết bảo vệ thông tin cá nhân và cho phép bạn toàn quyền kiểm soát cách công thức, hoạt động và dữ liệu của mình hiển thị.',
            ),
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey[700],
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // Section title header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  // Row with arrow navigation
  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 16.5, color: Colors.black87),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.25,
                        ),
                      ),
                    ],
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
        ),
      ),
    );
  }

  // Row with Switch toggle
  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16.5, color: Colors.black87),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeTrackColor: activeColor.withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return activeColor;
              }
              return null;
            }),
            onChanged: onChanged,
          ),
        ],
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

  // Dialog: Xóa lịch sử tìm kiếm món ăn
  void _showClearSearchHistoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Xóa lịch sử tìm kiếm ẩm thực?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: const Text(
          'Toàn bộ các từ khóa món ăn, nguyên liệu, và tên đầu bếp bạn đã tìm kiếm gần đây sẽ bị xóa hoàn toàn khỏi thiết bị.',
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
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Đã xóa sạch lịch sử tìm kiếm món ăn của bạn!',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Xóa',
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

  // BottomSheet: Chọn quyền riêng tư bài viết mặc định
  void _showAudiencePickerSheet() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Quyền riêng tư công thức mặc định',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Cài đặt này sẽ được áp dụng tự động cho các công thức và bài chia sẻ ẩm thực mới của bạn.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (int i = 0; i < _audienceLabels.length; i++) ...[
                      InkWell(
                        onTap: () {
                          setState(() => _recipeAudienceIndex = i);
                          Navigator.pop(ctx);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _audienceLabels[i],
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: _recipeAudienceIndex == i
                                            ? primaryColor
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _audienceDescriptions[i],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_recipeAudienceIndex == i)
                                Icon(
                                  Iconsax.tick_circle,
                                  color: primaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (i < _audienceLabels.length - 1)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                          color: Colors.grey.shade100,
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // BottomSheet: Quyền truy cập thiết bị
  void _showDevicePermissionsSheet() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Quyền truy cập trên thiết bị',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'CookConnect chỉ yêu cầu các quyền cần thiết để bạn có trải nghiệm nấu nướng và sáng tạo tốt nhất.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPermissionItem(
                  icon: Iconsax.camera,
                  title: 'Máy ảnh (Camera)',
                  desc: 'Chụp ảnh món ăn và quay video công thức trực tiếp',
                  status: 'Đã cấp',
                  isGranted: true,
                  primaryColor: primaryColor,
                ),
                _buildPermissionItem(
                  icon: Iconsax.gallery,
                  title: 'Thư viện hình ảnh',
                  desc: 'Tải ảnh món ăn và video từ bộ sưu tập của bạn',
                  status: 'Đã cấp',
                  isGranted: true,
                  primaryColor: primaryColor,
                ),
                _buildPermissionItem(
                  icon: Iconsax.location,
                  title: 'Vị trí địa lý',
                  desc: 'Gợi ý quán ăn lân cận và địa điểm mua sắm nguyên liệu',
                  status: 'Khi dùng ứng dụng',
                  isGranted: true,
                  primaryColor: primaryColor,
                ),
                _buildPermissionItem(
                  icon: Iconsax.notification,
                  title: 'Thông báo',
                  desc: 'Nhận thông báo khi có người bình luận hoặc thích công thức',
                  status: 'Đã bật',
                  isGranted: true,
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      'Bạn có thể thay đổi các quyền này bất kỳ lúc nào trong phần Cài đặt của điện thoại.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String desc,
    required String status,
    required bool isGranted,
    required Color primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16.5, color: Colors.black87),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isGranted ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isGranted ? Colors.green.shade700 : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BottomSheet: Chính sách Cookie & Lưu trữ ứng dụng
  void _showCookiePolicySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                Row(
                  children: [
                    Icon(
                      Iconsax.archive_tick,
                      size: 22,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Cookie & Bộ nhớ ứng dụng',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'CookConnect sử dụng công nghệ lưu trữ cục bộ (Local Storage & Cache) trên thiết bị của bạn nhằm:\n\n'
                  '• Ghi nhớ trạng thái đăng nhập và tùy chọn ngôn ngữ.\n'
                  '• Tải trước video và hình ảnh món ăn giúp trải nghiệm xem công thức mượt mà hơn.\n'
                  '• Lưu trữ giỏ nguyên liệu và danh sách cần mua sắm khi không có kết nối mạng.\n\n'
                  'Bạn có thể xóa các dữ liệu lưu đệm này bất kỳ lúc nào tại mục Cài đặt & Quyền riêng tư > Giải phóng dung lượng.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Đã hiểu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dialog: Liên hệ Cán bộ Bảo vệ Dữ liệu (DPO)
  void _showContactDpoDialog() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Iconsax.sms_tracking, color: primaryColor, size: 22),
            const SizedBox(width: 10),
            const Text(
              'Cán bộ Bảo vệ Dữ liệu',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nếu bạn có thắc mắc hoặc yêu cầu cụ thể liên quan đến quyền riêng tư, quyền truy cập hoặc xóa dữ liệu cá nhân theo quy định pháp luật, hãy gửi email trực tiếp đến:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.sms, size: 16, color: primaryColor),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'privacy@cookconnect.app',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Iconsax.copy, size: 16, color: Colors.grey[600]),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(text: 'privacy@cookconnect.app'),
                      );
                      Navigator.pop(ctx);
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Thời gian phản hồi thông thường: Trong vòng 24 - 48 giờ làm việc.',
              style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Đóng',
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
}
