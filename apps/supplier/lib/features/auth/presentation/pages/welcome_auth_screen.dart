import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/core/widgets/google_logo.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/email_phone_auth_screen.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_register_contact_screen.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/social_auth_screen.dart';

class WelcomeAuthScreen extends StatelessWidget {
  final VoidCallback? onLoginSuccess;

  const WelcomeAuthScreen({super.key, this.onLoginSuccess});

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmailPhoneAuthScreen(
          onLoginSuccess: onLoginSuccess,
        ),
      ),
    );
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SellerRegisterContactScreen(
          onLoginSuccess: onLoginSuccess,
        ),
      ),
    );
  }

  void _navigateToSocial(BuildContext context, String provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SocialAuthScreen(
          provider: provider,
          onLoginSuccess: onLoginSuccess,
        ),
      ),
    );
  }

  void _handleDemoLogin(BuildContext context) {
    SellerAuthService.instance.setDemoSession();
    onLoginSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Top Brand Header
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Iconsax.shop,
                      size: 46,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'CookConnect Seller',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'KÊNH NGƯỜI BÁN HÀNG',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nền tảng quản lý gian hàng & kết nối triệu khách hàng ẩm thực toàn quốc',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const Spacer(),

              // ================= 3 VERTICAL ACTION BUTTONS =================
              // 1. Email / Phone Button
              _buildAuthActionButton(
                label: 'Đăng nhập bằng Email / Số điện thoại',
                icon: const Icon(Iconsax.sms, color: Colors.white, size: 20),
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                onPressed: () => _navigateToLogin(context),
              ),

              const SizedBox(height: 14),

              // 2. Google Button
              _buildAuthActionButton(
                label: 'Tiếp tục với Google',
                icon: const GoogleLogoWidget(size: 20),
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                borderColor: Colors.grey.shade300,
                onPressed: () => _navigateToSocial(context, 'google'),
              ),

              const SizedBox(height: 14),

              // 3. Apple Button
              _buildAuthActionButton(
                label: 'Tiếp tục với Apple',
                icon: const Icon(FlutterRemix.apple_fill, color: Colors.black87, size: 21),
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                borderColor: Colors.grey.shade300,
                onPressed: () => _navigateToSocial(context, 'apple'),
              ),

              const SizedBox(height: 20),

              // Quick Demo Seller Access
              Center(
                child: TextButton.icon(
                  onPressed: () => _handleDemoLogin(context),
                  icon: const Icon(Iconsax.magicpen, size: 16, color: AppColors.primary),
                  label: const Text(
                    'Dùng thử tài khoản mẫu (Demo Seller)',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Footer: Register new store link
              Center(
                child: GestureDetector(
                  onTap: () => _navigateToRegister(context),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Chưa có tài khoản gian hàng? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Đăng ký ngay',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bằng việc tiếp tục, bạn đồng ý với Điều khoản dịch vụ & Chính sách bảo mật của CookConnect Seller.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthActionButton({
    required String label,
    required Widget icon,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          side: borderColor != null ? BorderSide(color: borderColor, width: 1.2) : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          children: [
            SizedBox(width: 24, height: 24, child: Center(child: icon)),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
