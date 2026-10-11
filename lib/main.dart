import 'package:flutter/material.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/main/presentation/pages/main_screen.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiI18n.init();
  await AuthService.instance.init();
  runApp(const CookConnect());
}

class CookConnect extends StatelessWidget {
  const CookConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AuthService.navigatorKey,
      scaffoldMessengerKey: AuthService.scaffoldMessengerKey,
      title: 'CookConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        fontFamily: 'TikTokSans',
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'TikTokSans',
        ),
        primaryTextTheme: ThemeData.light().primaryTextTheme.apply(
          fontFamily: 'TikTokSans',
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
