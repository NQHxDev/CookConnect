import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';

class StoreProfileScreen extends StatelessWidget {
  const StoreProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cửa hàng'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(Iconsax.shop, color: AppColors.primary),
            ),
            title: Text(
              'Cửa hàng CookConnect',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Đang mở cửa'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Iconsax.link_2),
            title: const Text('Cấu hình API Host'),
            subtitle: Text(ApiConfig.baseUrl),
          ),
          ListTile(
            leading: const Icon(Iconsax.clock),
            title: const Text('Giờ mở cửa'),
            subtitle: const Text('08:00 - 22:00'),
          ),
          ListTile(
            leading: const Icon(Iconsax.location),
            title: const Text('Địa chỉ'),
            subtitle: const Text('Thiết lập vị trí cửa hàng'),
          ),
        ],
      ),
    );
  }
}
