import 'package:cook_connect_seller/features/settings/presentation/pages/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/about/about_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/account/account_information_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/business/business_information_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/chat/chat_settings_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/holiday/holiday_mode_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/language/language_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/linked_accounts/linked_accounts_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/logout/logout_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/notifications/push_notifications_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/payment/payment_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/shipping/shipping_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/store/store_information_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/tax/tax_information_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/timezone/timezone_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/warehouse/warehouse_address_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: canPop
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black87,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Cài đặt',
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
              // Section 1: Tài khoản & Cửa hàng
              _buildSectionHeader('Tài khoản & Cửa hàng', isFirst: true),
              _buildSectionContainer(
                children: [
                  _buildSettingsItem(
                    icon: Iconsax.user,
                    title: 'Thông tin tài khoản',
                    onTap: () => _navigateTo(context, const AccountInformationScreen()),
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.shop,
                    title: 'Thông tin cửa hàng',
                    onTap: () => _navigateTo(context, const StoreInformationScreen()),
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.buildings,
                    title: 'Thông tin doanh nghiệp',
                    onTap: () => _navigateTo(context, const BusinessInformationScreen()),
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.receipt_item,
                    title: 'Thông tin thuế',
                    onTap: () => _navigateTo(context, const TaxInformationScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Section 2: Vận hành & Thanh toán
              _buildSectionHeader('Vận hành & Thanh toán'),
              _buildSectionContainer(
                children: [
                  _buildSettingsItem(
                    icon: Iconsax.wallet_3,
                    title: 'Ví & Doanh thu',
                    onTap: () => _navigateTo(context, const WalletScreen()),
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.truck_fast,
                    title: 'Giao hàng',
                    onTap: () => _navigateTo(context, const ShippingScreen()),
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.card,
                    title: 'Thanh toán',
                    onTap: () => _navigateTo(context, const PaymentScreen()),
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.house_2,
                    title: 'Địa chỉ kho hàng',
                    onTap: () => _navigateTo(context, const WarehouseAddressScreen()),
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.calendar_tick,
                    title: 'Chế độ nghỉ lễ',
                    onTap: () => _navigateTo(context, const HolidayModeScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Section 3: Kết nối & Tương tác
              _buildSectionHeader('Kết nối & Tương tác'),
              _buildSectionContainer(
                children: [
                  _buildSettingsItem(
                    icon: Iconsax.link_21,
                    title: 'Tài khoản được liên kết',
                    onTap: () => _navigateTo(context, const LinkedAccountsScreen()),
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.message_text,
                    title: 'Cài đặt trò chuyện',
                    onTap: () => _navigateTo(context, const ChatSettingsScreen()),
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.notification,
                    title: 'Thông báo đẩy',
                    onTap: () => _navigateTo(context, const PushNotificationsScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Section 4: Tùy chọn hệ thống
              _buildSectionHeader('Tùy chọn hệ thống'),
              _buildSectionContainer(
                children: [
                  _buildSettingsItem(
                    icon: Iconsax.global,
                    title: 'Ngôn ngữ',
                    onTap: () => _navigateTo(context, const LanguageScreen()),
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.clock,
                    title: 'Múi giờ',
                    onTap: () => _navigateTo(context, const TimezoneScreen()),
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.info_circle,
                    title: 'Giới thiệu',
                    onTap: () => _navigateTo(context, const AboutScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Section 5: Đăng nhập
              _buildSectionHeader('Đăng nhập'),
              _buildSectionContainer(
                children: [
                  _buildSettingsItem(
                    icon: Iconsax.logout,
                    title: 'Đăng xuất',
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () => _navigateTo(context, const LogoutScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isFirst = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, isFirst ? 12 : 8, 16, 8),
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

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
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
