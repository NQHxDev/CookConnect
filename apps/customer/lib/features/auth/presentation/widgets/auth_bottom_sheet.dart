import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/core/widgets/google_logo.dart';
import 'package:cookconnect/features/auth/presentation/pages/login_screen.dart';
import 'package:cookconnect/features/auth/presentation/pages/register_email_screen.dart';

/// Hiển thị BottomSheet chuẩn yêu cầu người dùng đăng nhập hoặc đăng ký tài khoản.
Future<T?> showAuthBottomSheet<T>(
  BuildContext context, {
  String? message,
  VoidCallback? onLoginSuccess,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AuthBottomSheet(
      message: message,
      onLoginSuccess: onLoginSuccess,
    ),
  );
}

class AuthBottomSheet extends StatelessWidget {
  final String? message;
  final VoidCallback? onLoginSuccess;

  const AuthBottomSheet({
    super.key,
    this.message,
    this.onLoginSuccess,
  });

  void _navigateToLoginScreen(BuildContext context, {bool initialSignUp = false}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => initialSignUp
            ? RegisterEmailScreen(
                onLoginSuccess: onLoginSuccess != null
                    ? (_, __) => onLoginSuccess!()
                    : null,
              )
            : LoginScreen(
                initialSignUp: false,
                onLoginSuccess: onLoginSuccess != null
                    ? (_, __) => onLoginSuccess!()
                    : null,
              ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showSocialUnderDevelopment(BuildContext context, [String? provider]) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.info_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ApiI18n.text(UiI18nKeys.profileFeatureInDevelopment),
                style: const TextStyle(fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final resetCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Iconsax.key, color: Colors.orange),
            const SizedBox(width: 10),
            Text(
              ApiI18n.text(UiI18nKeys.profileForgotPasswordTitle),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ApiI18n.text(UiI18nKeys.profileForgotPasswordDesc),
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetCtrl,
              decoration: InputDecoration(
                hintText: ApiI18n.text(UiI18nKeys.profileForgotPasswordHint),
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Iconsax.sms, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ApiI18n.text(UiI18nKeys.profileCancel)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ApiI18n.text(UiI18nKeys.profileForgotPasswordSent)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(ApiI18n.text(UiI18nKeys.profileForgotPasswordSubmit)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Logo / Header
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.profile_circle5, size: 36, color: primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            ApiI18n.text(UiI18nKeys.profileAuthSheetTitle),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message ?? ApiI18n.text(UiI18nKeys.profileAuthSheetDesc),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // SĐT / Email / Username Option (Primary)
          _buildAuthOptionButton(
            leading: Icon(
              Icons.phone_android_rounded,
              size: 22,
              color: primaryColor,
            ),
            title: ApiI18n.text(UiI18nKeys.profileAuthOptionCredentials),
            onTap: () {
              Navigator.pop(context);
              _navigateToLoginScreen(context);
            },
          ),
          const SizedBox(height: 10),

          // Google Login Button with authentic 4-color Google logo
          _buildAuthOptionButton(
            leading: const GoogleLogoWidget(size: 22),
            title: ApiI18n.text(UiI18nKeys.profileAuthOptionGoogle),
            onTap: () {
              Navigator.pop(context);
              _showSocialUnderDevelopment(context, 'Google');
            },
          ),
          const SizedBox(height: 10),

          // Apple Login Button
          _buildAuthOptionButton(
            leading: const Icon(
              FlutterRemix.apple_fill,
              size: 22,
              color: Colors.black,
            ),
            title: ApiI18n.text(UiI18nKeys.profileAuthOptionApple),
            onTap: () {
              Navigator.pop(context);
              _showSocialUnderDevelopment(context, 'Apple');
            },
          ),

          const SizedBox(height: 16),

          // Row for "Quên mật khẩu?" (left) and "Đăng ký tài khoản" (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showForgotPasswordDialog(context);
                },
                icon: Icon(Iconsax.key, size: 16, color: Colors.grey[600]),
                label: Text(
                  ApiI18n.text(UiI18nKeys.profileForgotPasswordTitle),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToLoginScreen(context, initialSignUp: true);
                },
                icon: Icon(Iconsax.user_add, size: 16, color: primaryColor),
                label: Text(
                  ApiI18n.text(UiI18nKeys.profileAuthRegister),
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            ApiI18n.text(UiI18nKeys.profileAuthDisclaimer),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthOptionButton({
    required Widget leading,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF6F7F9),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
