import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DeactivateOrDeleteAccountScreen extends StatelessWidget {
  const DeactivateOrDeleteAccountScreen({super.key});

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
          'Hủy kích hoạt hoặc xóa tài khoản',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
      body: const SizedBox.shrink(),
    );
  }
}
