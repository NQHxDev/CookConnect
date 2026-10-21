import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/core/theme/app_theme.dart';
import 'package:cook_connect_seller/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:cook_connect_seller/features/orders/presentation/pages/orders_screen.dart';
import 'package:cook_connect_seller/features/menu/presentation/pages/menu_screen.dart';
import 'package:cook_connect_seller/features/store/presentation/pages/store_profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('CookConnect Seller started with Base URL: ${ApiConfig.baseUrl}');
  runApp(const CookConnectSellerApp());
}

class CookConnectSellerApp extends StatelessWidget {
  const CookConnectSellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookConnect Seller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
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
    OrdersScreen(),
    MenuScreen(),
    StoreProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.element_4),
              activeIcon: Icon(Iconsax.element_45),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.receipt_2),
              activeIcon: Icon(Iconsax.receipt_25),
              label: 'Đơn hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.menu_board),
              activeIcon: Icon(Iconsax.menu_board5),
              label: 'Thực đơn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.shop),
              activeIcon: Icon(Iconsax.shop5),
              label: 'Cửa hàng',
            ),
          ],
        ),
      ),
    );
  }
}
