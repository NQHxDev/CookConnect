import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/main.dart';
import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/welcome_auth_screen.dart';

void main() {
  late InMemoryTokenStorageService storage;
  late SellerAuthService authService;

  setUp(() {
    storage = InMemoryTokenStorageService();
    authService = SellerAuthService.instance;
    authService.configure(storage: storage);
  });

  tearDown(() async {
    await authService.logout(callServer: false);
  });

  testWidgets('App displays WelcomeAuthScreen when unauthenticated (no public access)', (WidgetTester tester) async {
    await tester.pumpWidget(const CookConnectSellerApp());
    await tester.pumpAndSettle();

    // Verify default API Base URL is 192.168.1.162
    expect(ApiConfig.baseUrl, equals('http://192.168.1.162:8080'));

    // Should display WelcomeAuthScreen with 3 vertical buttons, not MainNavigationScreen
    expect(find.byType(WelcomeAuthScreen), findsOneWidget);
    expect(find.byType(MainNavigationScreen), findsNothing);
    expect(find.text('CookConnect Seller'), findsOneWidget);
    expect(find.text('KÊNH NGƯỜI BÁN HÀNG'), findsOneWidget);
    expect(find.text('Đăng nhập bằng Email / Số điện thoại'), findsOneWidget);
    expect(find.text('Tiếp tục với Google'), findsOneWidget);
    expect(find.text('Tiếp tục với Apple'), findsOneWidget);
  });

  testWidgets('App renders main navigation with all 6 tabs when authenticated and prevents bypass', (WidgetTester tester) async {
    // Authenticate seller first
    authService.setDemoSession();

    await tester.pumpWidget(const CookConnectSellerApp());
    await tester.pumpAndSettle();

    // Verify all 6 navigation items exist in BottomNavBar
    expect(find.widgetWithText(InkWell, 'Trang chủ'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Sản phẩm'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Đơn hàng'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Quảng cáo'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Trò chuyện'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Cài đặt'), findsOneWidget);

    // Verify switching tabs
    await tester.tap(find.widgetWithText(InkWell, 'Sản phẩm'));
    await tester.pumpAndSettle();
    expect(find.text('Quản lý sản phẩm'), findsOneWidget);

    await tester.tap(find.widgetWithText(InkWell, 'Đơn hàng'));
    await tester.pumpAndSettle();
    expect(find.text('Quản lý đơn hàng'), findsOneWidget);

    await tester.tap(find.widgetWithText(InkWell, 'Quảng cáo'));
    await tester.pumpAndSettle();
    expect(find.text('Quảng cáo & Tiếp thị'), findsOneWidget);

    await tester.tap(find.widgetWithText(InkWell, 'Trò chuyện'));
    await tester.pumpAndSettle();
    expect(find.text('Trò chuyện'), findsWidgets);

    await tester.tap(find.widgetWithText(InkWell, 'Cài đặt'));
    await tester.pumpAndSettle();
    expect(find.text('Cài đặt'), findsWidgets);
    expect(find.text('Thông tin cửa hàng'), findsOneWidget);

    // Anti-bypass check: simulate session invalidated, then attempt to switch tab
    await authService.logout(callServer: false);
    await tester.tap(find.widgetWithText(InkWell, 'Trang chủ'));
    await tester.pumpAndSettle();

    // Must be redirected to WelcomeAuthScreen immediately
    expect(find.byType(WelcomeAuthScreen), findsOneWidget);
    expect(find.byType(MainNavigationScreen), findsNothing);
  });
}
