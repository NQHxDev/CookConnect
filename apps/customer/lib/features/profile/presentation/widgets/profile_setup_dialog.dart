import 'package:flutter/material.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/profile/presentation/pages/profile_setup_screen.dart';

export 'package:cookconnect/features/profile/presentation/pages/profile_setup_screen.dart';

class ProfileSetupDialog extends StatelessWidget {
  final bool isFirstTime;
  final VoidCallback? onComplete;
  final ApiService? apiService;

  const ProfileSetupDialog({
    super.key,
    this.isFirstTime = true,
    this.onComplete,
    this.apiService,
  });

  static Future<void> show(
    BuildContext context, {
    bool isFirstTime = true,
    VoidCallback? onComplete,
    ApiService? apiService,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (ctx) => ProfileSetupScreen(
          isFirstTime: isFirstTime,
          onComplete: onComplete,
          apiService: apiService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSetupScreen(
      isFirstTime: isFirstTime,
      onComplete: onComplete,
      apiService: apiService,
    );
  }
}
