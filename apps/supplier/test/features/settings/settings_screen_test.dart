import 'package:cook_connect_seller/features/settings/presentation/pages/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/settings_screen.dart';
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

void main() {
  testWidgets('SettingsScreen displays all 16 options and navigates to each blank screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final options = <String, Type>{
      'Thông tin tài khoản': AccountInformationScreen,
      'Thông tin cửa hàng': StoreInformationScreen,
      'Thông tin doanh nghiệp': BusinessInformationScreen,
      'Thông tin thuế': TaxInformationScreen,
      'Ví & Doanh thu': WalletScreen,
      'Giao hàng': ShippingScreen,
      'Thanh toán': PaymentScreen,
      'Địa chỉ kho hàng': WarehouseAddressScreen,
      'Chế độ nghỉ lễ': HolidayModeScreen,
      'Tài khoản được liên kết': LinkedAccountsScreen,
      'Cài đặt trò chuyện': ChatSettingsScreen,
      'Thông báo đẩy': PushNotificationsScreen,
      'Ngôn ngữ': LanguageScreen,
      'Múi giờ': TimezoneScreen,
      'Giới thiệu': AboutScreen,
      'Đăng xuất': LogoutScreen,
    };

    for (final entry in options.entries) {
      final itemFinder = find.text(entry.key);
      await tester.scrollUntilVisible(itemFinder, 100);
      expect(itemFinder, findsOneWidget);

      await tester.tap(itemFinder);
      await tester.pumpAndSettle();

      expect(find.byType(entry.value), findsOneWidget);

      // Tap back button
      final backButton = find.byTooltip('Back');
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
      } else {
        await tester.tap(find.byType(IconButton).first);
      }
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    }
  });
}
