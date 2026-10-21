import 'package:flutter/material.dart';

class SystemNotificationScreen extends StatelessWidget {
  const SystemNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Thông báo hệ thống',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Chưa có thông báo hệ thống',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
