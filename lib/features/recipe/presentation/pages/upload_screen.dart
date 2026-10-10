import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng video mới')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.video_square5,
                size: 120,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 32),
              const Text(
                'Chia sẻ công thức nấu ăn của bạn',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Tạo và đăng video nấu ăn để chia sẻ với cộng đồng',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Iconsax.video),
                label: const Text('Quay video'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Iconsax.gallery),
                label: const Text('Chọn từ thư viện'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
