import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/core/theme/app_theme.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/navigation/auth_navigation_observer.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/auth_gate.dart';
import 'package:cook_connect_seller/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/menu_screen.dart';
import 'package:cook_connect_seller/features/orders/presentation/pages/orders_screen.dart';
import 'package:cook_connect_seller/features/ads/presentation/pages/ads_screen.dart';
import 'package:cook_connect_seller/features/chat/presentation/pages/chat_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('CookConnect Seller started with Base URL: ${ApiConfig.baseUrl}');
  await SellerAuthService.instance.init();
  runApp(const CookConnectSellerApp());
}

class CookConnectSellerApp extends StatelessWidget {
  const CookConnectSellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: SellerAuthService.navigatorKey,
      scaffoldMessengerKey: SellerAuthService.scaffoldMessengerKey,
      navigatorObservers: [AuthNavigationObserver()],
      title: 'CookConnect Seller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    MenuScreen(),
    OrdersScreen(),
    AdsScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  void _onNavItemTapped(int index) {
    // Anti-bypass check on every tab transition
    if (!SellerAuthService.instance.isLoggedIn) {
      SellerAuthService.instance.handleSessionExpired();
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // If not on first tab, back goes to Dashboard
        if (_currentIndex != 0) {
          _onNavItemTapped(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.withValues(alpha: 0.18),
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Iconsax.home_2,
                    activeIcon: Iconsax.home_25,
                    label: 'Trang chủ',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: FlutterRemix.shopping_bag_line,
                    activeIcon: FlutterRemix.shopping_bag_fill,
                    label: 'Sản phẩm',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Iconsax.receipt_2,
                    activeIcon: Iconsax.receipt_25,
                    label: 'Đơn hàng',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Iconsax.presention_chart,
                    activeIcon: Iconsax.presention_chart5,
                    label: 'Quảng cáo',
                    index: 3,
                  ),
                  _buildNavItem(
                    icon: Iconsax.message,
                    activeIcon: Iconsax.message5,
                    label: 'Trò chuyện',
                    index: 4,
                  ),
                  _buildNavItem(
                    icon: FlutterRemix.settings_3_line,
                    activeIcon: FlutterRemix.settings_3_fill,
                    label: 'Cài đặt',
                    index: 5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    final color = isActive ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavItemTapped(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon, color: color, size: 21),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9.5,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.1,
                fontFamily: AppTheme.fontFamily,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
