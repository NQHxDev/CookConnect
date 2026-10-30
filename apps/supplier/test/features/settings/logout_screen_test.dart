import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/welcome_auth_screen.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/logout/logout_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryTokenStorageService storage;

  setUp(() async {
    storage = InMemoryTokenStorageService();
    SellerAuthService.instance.configure(storage: storage);
    await SellerAuthService.instance.init();
  });

  tearDown(() async {
    await SellerAuthService.instance.logout(callServer: false);
  });

  testWidgets('LogoutScreen renders confirmation UI and cancels when tapping Huy bo',
      (WidgetTester tester) async {
    SellerAuthService.instance.setDemoSession();
    expect(SellerAuthService.instance.isLoggedIn, isTrue);

    await tester.pumpWidget(
      const MaterialApp(
        home: LogoutScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bạn có chắc chắn muốn đăng xuất?'), findsOneWidget);
    expect(find.text('Xác nhận đăng xuất'), findsOneWidget);
    expect(find.text('Huỷ bỏ'), findsOneWidget);

    await tester.tap(find.text('Huỷ bỏ'));
    await tester.pumpAndSettle();

    // User is still logged in
    expect(SellerAuthService.instance.isLoggedIn, isTrue);
  });

  testWidgets('LogoutScreen clears session, wipes tokens, and navigates out to WelcomeAuthScreen on confirm',
      (WidgetTester tester) async {
    SellerAuthService.instance.setDemoSession();
    expect(SellerAuthService.instance.isLoggedIn, isTrue);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: SellerAuthService.navigatorKey,
        home: const LogoutScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final confirmButton = find.text('Xác nhận đăng xuất');
    expect(confirmButton, findsOneWidget);

    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // Session must be completely cleared
    expect(SellerAuthService.instance.isLoggedIn, isFalse);
    expect(SellerAuthService.instance.currentUser, isNull);
    expect(SellerAuthService.instance.tokens, isNull);

    // Secure storage must be empty
    final storedTokens = await storage.getTokens();
    expect(storedTokens, isNull);

    // Navigation must have redirected to WelcomeAuthScreen via AuthGate
    expect(find.byType(WelcomeAuthScreen), findsOneWidget);
    expect(find.byType(LogoutScreen), findsNothing);
  });
}
