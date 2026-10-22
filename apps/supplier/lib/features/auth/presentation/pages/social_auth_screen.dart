import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/core/widgets/google_logo.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';

class SocialAuthScreen extends StatefulWidget {
  final String provider; // 'google' | 'apple'
  final VoidCallback? onLoginSuccess;

  const SocialAuthScreen({
    super.key,
    required this.provider,
    this.onLoginSuccess,
  });

  @override
  State<SocialAuthScreen> createState() => _SocialAuthScreenState();
}

class _SocialAuthScreenState extends State<SocialAuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isGoogle => widget.provider.toLowerCase() == 'google';
  String get providerTitle => isGoogle ? 'Google' : 'Apple';

  Future<void> _handleAuthorize() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await SellerAuthService.instance.loginWithSocial(
        provider: widget.provider,
        email: isGoogle
            ? 'partner.google@cookconnect.app'
            : 'partner.apple@cookconnect.app',
        displayName: isGoogle ? 'Google Seller Partner' : 'Apple Seller Partner',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        widget.onLoginSuccess?.call();
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Đã xảy ra lỗi khi xác thực: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailDisplay = isGoogle
        ? 'partner.google@cookconnect.app'
        : 'partner.apple@cookconnect.app';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đăng nhập với $providerTitle',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isGoogle
                        ? const GoogleLogoWidget(size: 42)
                        : const Icon(FlutterRemix.apple_fill, size: 44, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Xác thực qua $providerTitle ID',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cho phép CookConnect Seller liên kết tài khoản $providerTitle của bạn để tạo và quản lý gian hàng ẩm thực.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(
                        isGoogle ? Iconsax.user : FlutterRemix.apple_fill,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGoogle ? 'Google Seller Partner' : 'Apple Seller Partner',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            emailDisplay,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Iconsax.tick_circle, color: AppColors.success, size: 20),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.warning_2, color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuthorize,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGoogle ? AppColors.primary : Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Tiếp tục với tư cách $providerTitle ID',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Chọn phương thức khác',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
