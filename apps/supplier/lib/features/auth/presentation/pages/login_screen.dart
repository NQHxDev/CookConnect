import 'package:flutter/material.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/welcome_auth_screen.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_register_contact_screen.dart';

export 'package:cook_connect_seller/features/auth/presentation/pages/welcome_auth_screen.dart';
export 'package:cook_connect_seller/features/auth/presentation/pages/email_phone_auth_screen.dart';
export 'package:cook_connect_seller/features/auth/presentation/pages/seller_register_contact_screen.dart';
export 'package:cook_connect_seller/features/auth/presentation/pages/seller_register_otp_screen.dart';
export 'package:cook_connect_seller/features/auth/presentation/pages/seller_register_password_screen.dart';
export 'package:cook_connect_seller/features/auth/presentation/pages/seller_store_setup_screen.dart';
export 'package:cook_connect_seller/features/auth/presentation/pages/social_auth_screen.dart';

/// Convenient wrapper for the Seller Authentication Flow
class LoginScreen extends StatelessWidget {
  final VoidCallback? onLoginSuccess;
  final bool initialRegisterMode;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.initialRegisterMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (initialRegisterMode) {
      return SellerRegisterContactScreen(
        onLoginSuccess: onLoginSuccess,
      );
    }
    return WelcomeAuthScreen(onLoginSuccess: onLoginSuccess);
  }
}
