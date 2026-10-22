import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_store_setup_screen.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/welcome_auth_screen.dart';
import 'package:cook_connect_seller/main.dart';

/// Root Authentication Gate for CookConnect Seller.
///
/// Reactively switches between:
/// 1. Splash / Loading if session initialization is ongoing.
/// 2. [WelcomeAuthScreen] when unauthenticated.
/// 3. [SellerStoreSetupScreen] when authenticated but onboarding is incomplete (no supplier store linked yet).
/// 4. [MainNavigationScreen] when authenticated and supplier onboarding is verified.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SellerAuthService.instance,
      builder: (context, _) {
        final authService = SellerAuthService.instance;

        // 1. Initializing session from secure storage
        if (!authService.isInitialized) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.shop, size: 64, color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'CookConnect Seller',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 2. Unauthenticated: Render WelcomeAuthScreen
        if (!authService.isLoggedIn) {
          return const WelcomeAuthScreen(key: ValueKey('supplier_welcome_auth_screen'));
        }

        // 3. Authenticated but onboarding incomplete: Render SellerStoreSetupScreen
        if (!authService.hasSupplier) {
          return const SellerStoreSetupScreen(key: ValueKey('supplier_store_setup'));
        }

        // 4. Authenticated & Onboarded: Render MainNavigationScreen
        return const MainNavigationScreen(key: ValueKey('supplier_main_navigation'));
      },
    );
  }
}
