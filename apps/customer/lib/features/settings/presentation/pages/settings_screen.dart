import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/settings/presentation/pages/language/language_selection_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/account_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/help/help_center_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/privacy/privacy_center_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/terms/terms_and_policies_screen.dart';
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

  bool get _isLoggedIn => widget.isLoggedIn ?? AuthService.instance.isLoggedIn;

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
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              ApiI18n.text(UiI18nKeys.settingsTitle),
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
                  // Section 1: Hoạt động / Activity (requires login)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      ApiI18n.text(UiI18nKeys.settingsSectionActivity),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isLoggedIn ? Colors.grey[600] : Colors.grey[400],
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
                          title: ApiI18n.text(UiI18nKeys.settingsManagePosts),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.slider_horizontal,
                          title: ApiI18n.text(UiI18nKeys.settingsContentPreferences),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.notification,
                          title: ApiI18n.text(UiI18nKeys.settingsNotifications),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.clock,
                          title: ApiI18n.text(UiI18nKeys.settingsScreenTime),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.people,
                          title: ApiI18n.text(UiI18nKeys.settingsFamily),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 2: Tài khoản / Account (requires login)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      ApiI18n.text(UiI18nKeys.settingsSectionAccount),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isLoggedIn ? Colors.grey[600] : Colors.grey[400],
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
                          title: ApiI18n.text(UiI18nKeys.settingsAccount),
                          enabled: _isLoggedIn,
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
                          title: ApiI18n.text(UiI18nKeys.settingsSecurityPermissions),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.share,
                          title: ApiI18n.text(UiI18nKeys.settingsShareProfile),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 3: Cài đặt hiển thị / Display settings (requires login)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      ApiI18n.text(UiI18nKeys.settingsSectionDisplaySettings),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isLoggedIn ? Colors.grey[600] : Colors.grey[400],
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
                          title: ApiI18n.text(UiI18nKeys.settingsPrivateAccount),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.user_minus,
                          title: ApiI18n.text(UiI18nKeys.settingsRestrictedAccounts),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.forbidden_2,
                          title: ApiI18n.text(UiI18nKeys.settingsBlockedAccounts),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 4: Tương tác / Interactions (requires login)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      ApiI18n.text(UiI18nKeys.settingsSectionInteractions),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isLoggedIn ? Colors.grey[600] : Colors.grey[400],
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
                          title: ApiI18n.text(UiI18nKeys.settingsComments),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.tag_user,
                          title: ApiI18n.text(UiI18nKeys.settingsMentions),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.direct,
                          title: ApiI18n.text(UiI18nKeys.settingsDirectMessages),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.arrow_circle_down,
                          title: ApiI18n.text(UiI18nKeys.settingsDownloads),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.eye,
                          title: ApiI18n.text(UiI18nKeys.settingsProfileViews),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 5: Tùy chọn / Preferences (mixed: audience & ads require login)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      ApiI18n.text(UiI18nKeys.settingsSectionPreferences),
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
                          title: ApiI18n.text(UiI18nKeys.settingsAudienceControl),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.presention_chart,
                          title: ApiI18n.text(UiI18nKeys.settingsAds),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.play_circle,
                          title: ApiI18n.text(UiI18nKeys.settingsVideoPlayback),
                          enabled: true,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.global,
                          title: ApiI18n.text(UiI18nKeys.settingsLanguage),
                          enabled: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LanguageSelectionScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.monitor,
                          title: ApiI18n.text(UiI18nKeys.settingsDisplay),
                          enabled: true,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.subtitle,
                          title: ApiI18n.text(UiI18nKeys.settingsAccessibility),
                          enabled: true,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 6: Bộ nhớ đệm & Dữ liệu di động / Cache & Cellular (offline videos requires login)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      ApiI18n.text(UiI18nKeys.settingsSectionCacheCellular),
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
                          title: ApiI18n.text(UiI18nKeys.settingsOfflineVideos),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.trash,
                          title: ApiI18n.text(UiI18nKeys.settingsFreeUpSpace),
                          enabled: true,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.simcard,
                          title: ApiI18n.text(UiI18nKeys.settingsDataSaver),
                          enabled: true,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 7: Hỗ trợ & Chính sách / Support & Policies (available to all)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      ApiI18n.text(UiI18nKeys.settingsSectionSupportPolicies),
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
                          title: ApiI18n.text(UiI18nKeys.settingsHelpCenter),
                          enabled: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpCenterScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.shield_tick,
                          title: ApiI18n.text(UiI18nKeys.settingsPrivacyCenter),
                          enabled: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrivacyCenterScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.clipboard_text,
                          title: ApiI18n.text(UiI18nKeys.settingsTermsPolicies),
                          enabled: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TermsAndPoliciesScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 8: Đăng nhập / Login (requires login)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      ApiI18n.text(UiI18nKeys.settingsSectionLogin),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isLoggedIn ? Colors.grey[600] : Colors.grey[400],
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
                          title: ApiI18n.text(UiI18nKeys.settingsSwitchAccount),
                          enabled: _isLoggedIn,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Iconsax.logout,
                          title: ApiI18n.text(UiI18nKeys.settingsLogout),
                          textColor: _isLoggedIn ? Colors.red : null,
                          iconColor: _isLoggedIn ? Colors.red : null,
                          enabled: _isLoggedIn,
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
      },
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Color? textColor,
    Color? iconColor,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final effectiveTextColor = enabled
        ? (textColor ?? Colors.black87)
        : Colors.grey.shade400;
    final effectiveIconColor = enabled
        ? (iconColor ?? Colors.black87)
        : Colors.grey.shade400;
    final effectiveArrowColor = enabled
        ? Colors.grey.shade400
        : Colors.grey.shade300;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
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
                color: effectiveArrowColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
