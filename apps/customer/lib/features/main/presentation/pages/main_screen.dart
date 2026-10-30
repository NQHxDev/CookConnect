import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/core/navigation/app_tab_navigator.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/auth/presentation/widgets/auth_bottom_sheet.dart';
import 'package:cookconnect/features/recipe/data/services/home_video_feed_controller.dart';
import 'package:cookconnect/features/recipe/presentation/pages/home_screen.dart';
import 'package:cookconnect/features/recipe/presentation/pages/library_screen.dart';
import 'package:cookconnect/features/recipe/presentation/pages/upload_screen.dart';
import 'package:cookconnect/features/recipe/presentation/pages/cooking_camera_screen.dart';
import 'package:cookconnect/features/market/presentation/pages/market_screen.dart';
import 'package:cookconnect/features/market/presentation/widgets/fly_to_cart_animation.dart';
import 'package:cookconnect/features/recipe/data/services/recipe_data_service.dart';
import 'package:cookconnect/features/profile/presentation/pages/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    AppTabNavigator.instance.addListener(_handleTabNavigationRequest);
  }

  @override
  void dispose() {
    AppTabNavigator.instance.removeListener(_handleTabNavigationRequest);
    super.dispose();
  }

  /// Chuyển tab khi có yêu cầu từ màn hình khác (VD: Feed -> Đi chợ).
  void _handleTabNavigationRequest() {
    final tab = AppTabNavigator.instance.consumeMainTab();
    if (tab == null || !mounted || tab == _currentIndex) return;
    _onTabTapped(tab);
  }

  void _onTabTapped(int index) {
    if (index == 0 && _currentIndex != 0) {
      // Gửi tín hiệu phát video ngay trước khi switch tab sang Trang chủ
      HomeVideoFeedController.instance.prePlayFeed();
    } else if (index != 0 && _currentIndex == 0) {
      // Dừng phát và tắt tiếng video ngay lập tức khi rời khỏi Trang chủ
      HomeVideoFeedController.instance.setHomeMainTabActive(false);
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _onAddButtonPressed() {
    if (!AuthService.instance.isLoggedIn) {
      showAuthBottomSheet(
        context,
        message: ApiI18n.text(UiI18nKeys.profileBenefitUploadMsg),
      );
      return;
    }
    _openCookingCamera();
  }

  Future<void> _openCookingCamera() async {
    HomeVideoFeedController.instance.pauseFeed();
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CookingCameraScreen(),
      ),
    );
    if (_currentIndex == 0 && mounted && (ModalRoute.of(context)?.isCurrent ?? true)) {
      HomeVideoFeedController.instance.resumeFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(isActive: _currentIndex == 0),
      const LibraryScreen(),
      UploadScreen(
        onCancel: () => _onTabTapped(0),
        onPublished: () => _onTabTapped(0),
      ),
      const MarketScreen(),
      ProfileScreen(isActive: _currentIndex == 4),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: ValueListenableBuilder<String>(
        valueListenable: ApiI18n.languageNotifier,
        builder: (context, currentLanguage, child) {
          return Container(
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
                      icon: Iconsax.home_2,
                      activeIcon: Iconsax.home_25,
                      label: ApiI18n.text(UiI18nKeys.navHome),
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Iconsax.layer,
                      activeIcon: Iconsax.layer5,
                      label: ApiI18n.text(UiI18nKeys.navLibrary),
                      index: 1,
                    ),
                    _buildAddButton(),
                    AnimatedBuilder(
                      animation: RecipeDataService.instance,
                      builder: (context, _) {
                        final uncompletedCount = RecipeDataService
                            .instance
                            .shoppingList
                            .where((i) => !i.isCompleted)
                            .length;
                        return _buildNavItem(
                          icon: Iconsax.shopping_cart,
                          activeIcon: Iconsax.shopping_cart5,
                          label: ApiI18n.text(UiI18nKeys.navMarket),
                          index: 3,
                          badgeCount: uncompletedCount,
                        );
                      },
                    ),
                    _buildNavItem(
                      icon: Iconsax.profile_circle,
                      activeIcon: Iconsax.profile_circle5,
                      label: ApiI18n.text(UiI18nKeys.navProfile),
                      index: 4,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return Expanded(
      child: InkWell(
        onTap: _onAddButtonPressed,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5722), Color(0xFFFF2D55)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF2D55).withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Iconsax.add, color: Colors.white, size: 20),
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
    int? badgeCount,
  }) {
    final isActive = _currentIndex == index;
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Colors.grey[600];

    return Expanded(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          // Gửi tín hiệu phát video ngay khi ngón tay chạm xuống tab Trang chủ trước khi nhấc lên
          if (index == 0 && _currentIndex != 0) {
            HomeVideoFeedController.instance.prePlayFeed();
          } else if (index != 0 && _currentIndex == 0) {
            HomeVideoFeedController.instance.setHomeMainTabActive(false);
          }
        },
        child: InkWell(
          onTapDown: (_) {
            if (index == 0 && _currentIndex != 0) {
              HomeVideoFeedController.instance.prePlayFeed();
            } else if (index != 0 && _currentIndex == 0) {
              HomeVideoFeedController.instance.setHomeMainTabActive(false);
            }
          },
          onTap: () => _onTabTapped(index),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    key: index == 3 ? FlyToCartAnimation.cartIconKey : null,
                    color: color,
                    size: 21,
                  ),
                  if (badgeCount != null && badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2D55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 13,
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
      ),
    );
  }
}
