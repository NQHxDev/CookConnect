import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/account_information_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/account_inheritance_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/deactivate_or_delete_account_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/passkey_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/password_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/verification_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tài khoản',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildAccountItem(
                    context: context,
                    title: 'Thông tin tài khoản',
                    destination: const AccountInformationScreen(),
                  ),
                  _buildAccountItem(
                    context: context,
                    title: 'Mật khẩu',
                    subtitle: 'Cập nhật mật khẩu để bảo vệ tài khoản của bạn',
                    destination: const PasswordScreen(),
                  ),
                  _buildAccountItem(
                    context: context,
                    title: 'Passkey',
                    subtitle: 'Đăng nhập an toàn bằng sinh trắc học hoặc khóa màn hình',
                    destination: const PasskeyScreen(),
                  ),
                  _buildAccountItem(
                    context: context,
                    title: 'Xác minh',
                    destination: const VerificationScreen(),
                  ),
                  _buildAccountItem(
                    context: context,
                    title: 'Thừa kế tài khoản',
                    subtitle: 'Chọn người liên hệ thừa kế để quản lý tài khoản của bạn',
                    destination: const AccountInheritanceScreen(),
                  ),
                  _buildAccountItem(
                    context: context,
                    title: 'Hủy kích hoạt hoặc xóa tài khoản',
                    destination: const DeactivateOrDeleteAccountScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget destination,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey[600],
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
