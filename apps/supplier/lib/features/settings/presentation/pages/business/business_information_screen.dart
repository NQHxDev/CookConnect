import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_kyb_verification_screen.dart';

class BusinessInformationScreen extends StatelessWidget {
  const BusinessInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SellerAuthService.instance,
      builder: (context, _) {
        final profile = SellerAuthService.instance.supplierProfile;
        final isEnterprise = profile?.merchantType == 'ENTERPRISE';

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black87,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Thông tin pháp lý & Doanh nghiệp',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.black87,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isEnterprise ? Iconsax.buildings : Iconsax.user,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEnterprise ? 'Doanh nghiệp / Công ty' : 'Cá nhân / Hộ kinh doanh',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      if (isEnterprise) ...[
                        _buildInfoRow('Tên công ty pháp nhân', profile?.businessName ?? 'Chưa cập nhật'),
                        _buildInfoRow('Mã số thuế doanh nghiệp', profile?.taxCode ?? 'Chưa cập nhật'),
                      ] else ...[
                        _buildInfoRow('Số CMND / CCCD', profile?.citizenId ?? 'Chưa cập nhật'),
                        _buildInfoRow('Ngày cấp CCCD', profile?.citizenIdIssuedDate?.split('T').first ?? 'Chưa cập nhật'),
                      ],
                      _buildInfoRow('Trạng thái xác minh', profile?.isVerified == true ? 'Đã xác minh chính thức' : 'Chờ thẩm định / Chưa nộp'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SellerKybVerificationScreen()),
                      );
                    },
                    icon: const Icon(Iconsax.edit, size: 18),
                    label: const Text(
                      'Cập nhật hồ sơ pháp lý (KYB)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
