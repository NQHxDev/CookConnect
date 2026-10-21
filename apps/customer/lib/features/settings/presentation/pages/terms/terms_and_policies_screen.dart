import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/settings/presentation/pages/terms/policy_detail_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/terms/terms_data.dart';

class TermsAndPoliciesScreen extends StatelessWidget {
  const TermsAndPoliciesScreen({super.key});

  void _openPolicyDetail(BuildContext context, PolicyItem policy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PolicyDetailScreen(policy: policy),
      ),
    );
  }

  void _showLegalInquirySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Iconsax.sms_tracking,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ApiI18n.text(UiI18nKeys.termsLegalInquiry),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'CookConnect Legal Operations Team',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  ApiI18n.currentLanguage == 'en'
                      ? 'For legal inquiries, copyright notices (DMCA), or privacy questions, please email our legal department directly.'
                      : 'Mọi thắc mắc pháp lý, khiếu nại bản quyền tác phẩm ẩm thực hoặc yêu cầu dữ liệu cá nhân, vui lòng liên hệ trực tiếp với bộ phận pháp lý của chúng tôi.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Colors.grey[700],
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
                      const Icon(Iconsax.sms, size: 18, color: Colors.black87),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          TermsData.legalEmail,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Iconsax.copy, size: 18, color: Colors.black87),
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(text: TermsData.legalEmail),
                          );
                          Navigator.pop(bottomSheetContext);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  ApiI18n.currentLanguage == 'en'
                                      ? 'Legal email copied to clipboard'
                                      : 'Đã sao chép địa chỉ email pháp lý',
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ApiI18n.languageNotifier,
      builder: (context, currentLanguage, child) {
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
              ApiI18n.text(UiI18nKeys.termsTitle),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Section 1: Thỏa thuận & Điều khoản pháp lý
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    ApiI18n.text(UiI18nKeys.termsSectionLegal),
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
                      _buildPolicyItem(
                        icon: TermsData.termsOfService.icon,
                        title: ApiI18n.text(TermsData.termsOfService.titleKey),
                        subtitle: ApiI18n.text(TermsData.termsOfService.subtitleKey),
                        onTap: () => _openPolicyDetail(context, TermsData.termsOfService),
                      ),
                      _buildDivider(),
                      _buildPolicyItem(
                        icon: TermsData.privacyPolicy.icon,
                        title: ApiI18n.text(TermsData.privacyPolicy.titleKey),
                        subtitle: ApiI18n.text(TermsData.privacyPolicy.subtitleKey),
                        onTap: () => _openPolicyDetail(context, TermsData.privacyPolicy),
                      ),
                      _buildDivider(),
                      _buildPolicyItem(
                        icon: TermsData.copyrightPolicy.icon,
                        title: ApiI18n.text(TermsData.copyrightPolicy.titleKey),
                        subtitle: ApiI18n.text(TermsData.copyrightPolicy.subtitleKey),
                        onTap: () => _openPolicyDetail(context, TermsData.copyrightPolicy),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Section 2: An toàn & Tiêu chuẩn cộng đồng
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    ApiI18n.text(UiI18nKeys.termsSectionCommunity),
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
                      _buildPolicyItem(
                        icon: TermsData.communityGuidelines.icon,
                        title: ApiI18n.text(TermsData.communityGuidelines.titleKey),
                        subtitle: ApiI18n.text(TermsData.communityGuidelines.subtitleKey),
                        onTap: () => _openPolicyDetail(context, TermsData.communityGuidelines),
                      ),
                      _buildDivider(),
                      _buildPolicyItem(
                        icon: TermsData.healthDisclaimer.icon,
                        title: ApiI18n.text(TermsData.healthDisclaimer.titleKey),
                        subtitle: ApiI18n.text(TermsData.healthDisclaimer.subtitleKey),
                        onTap: () => _openPolicyDetail(context, TermsData.healthDisclaimer),
                      ),
                      _buildDivider(),
                      _buildPolicyItem(
                        icon: TermsData.cookiePolicy.icon,
                        title: ApiI18n.text(TermsData.cookiePolicy.titleKey),
                        subtitle: ApiI18n.text(TermsData.cookiePolicy.subtitleKey),
                        onTap: () => _openPolicyDetail(context, TermsData.cookiePolicy),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Section 3: Pháp lý bổ sung & Mã nguồn
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    ApiI18n.text(UiI18nKeys.termsSectionOther),
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
                      _buildPolicyItem(
                        icon: Iconsax.code,
                        title: ApiI18n.text(UiI18nKeys.termsOpenSourceLicenses),
                        subtitle: ApiI18n.text(UiI18nKeys.termsOpenSourceLicensesSubtitle),
                        onTap: () {
                          showLicensePage(
                            context: context,
                            applicationName: 'CookConnect',
                            applicationVersion: '1.0.0',
                            applicationLegalese: '© 2026 CookConnect Inc. All rights reserved.',
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildPolicyItem(
                        icon: Iconsax.sms_tracking,
                        title: ApiI18n.text(UiI18nKeys.termsLegalInquiry),
                        subtitle: ApiI18n.text(UiI18nKeys.termsLegalInquirySubtitle),
                        onTap: () => _showLegalInquirySheet(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Footer Note
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        ApiI18n.text(UiI18nKeys.termsFooterNote),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'CookConnect v1.0.0 • ${ApiI18n.text(UiI18nKeys.termsLastUpdated)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 48,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildPolicyItem({
    required IconData icon,
    required String title,
    required String subtitle,
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
              Icon(icon, size: 18, color: Colors.black87),
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
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey[600],
                        height: 1.25,
                      ),
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
        ),
      ),
    );
  }
}
