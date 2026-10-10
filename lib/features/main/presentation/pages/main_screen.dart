import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/recipe/presentation/pages/home_screen.dart';
import 'package:cookconnect/features/recipe/presentation/pages/library_screen.dart';
import 'package:cookconnect/features/recipe/presentation/pages/upload_screen.dart';
import 'package:cookconnect/features/chat/presentation/pages/chat_screen.dart';
import 'package:cookconnect/features/profile/presentation/pages/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LibraryScreen(),
    UploadScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
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
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Iconsax.home,
                  activeIcon: Iconsax.home5,
                  label: 'Trang chủ',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Iconsax.layer,
                  activeIcon: Iconsax.layer5,
                  label: 'Thư viện',
                  index: 1,
                ),
                _buildAddButton(),
                _buildNavItem(
                  icon: Iconsax.sms,
                  activeIcon: Iconsax.sms5,
                  label: 'Hộp thư',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Iconsax.profile_circle,
                  activeIcon: Iconsax.profile_circle5,
                  label: 'Cá nhân',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    final isActive = _currentIndex == 2;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(2),
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? primaryColor
                  : primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isActive ? Iconsax.add5 : Iconsax.add,
              color: isActive ? Colors.white : primaryColor,
              size: 20,
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
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Colors.grey[600];

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
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
