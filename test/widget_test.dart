import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/main.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';

void main() {
  setUp(() {
    AuthService.instance.logout();
    ApiService.defaultClient = MockClient((request) async {
      if (request.url.path == '/api/v1/auth/login') {
        return http.Response(
          '{"success":true,"statusCode":200,"message":"AUTH.LOGIN_SUCCESS","data":{"user":{"id":"01a0f080-73a0-752e-b10c-65dccdb76f60","email":"chef.linh@example.com","fullName":"Chef Linh Đan","username":"linhdan_cook","roles":["USER"],"status":"ACTIVE"},"tokens":{"accessToken":"mock-access-token","refreshToken":"mock-refresh-token","tokenType":"Bearer","expiresIn":900}}}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      if (request.url.path == '/api/v1/auth/register') {
        return http.Response(
          '{"success":true,"statusCode":201,"message":"AUTH.REGISTER_SUCCESS","data":{"user":{"id":"01a0f080-73a0-752e-b10c-65dccdb76f60","email":"chef.linh@example.com","fullName":"Chef Linh Đan","username":"linhdan_cook","roles":["USER"],"status":"ACTIVE"},"tokens":{"accessToken":"mock-access-token","refreshToken":"mock-refresh-token","tokenType":"Bearer","expiresIn":900}}}',
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      return http.Response('{"success":false,"statusCode":404}', 404);
    });
  });

  tearDown(() {
    ApiService.defaultClient = null;
    AuthService.instance.logout();
  });

  testWidgets('CookConnect smoke test, profile, edit profile, and bio flow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CookConnect());
    await tester.pumpAndSettle();

    // Verify app renders with navigation bar
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Cá nhân'), findsOneWidget);

    // Tap on profile tab
    await tester.tap(find.text('Cá nhân'));
    await tester.pumpAndSettle();

    // Verify unauthenticated guest profile components
    expect(find.text('Tham gia CookConnect'), findsOneWidget);
    expect(find.text('Đặc quyền khi có tài khoản'), findsOneWidget);

    // Open Login / Register
    await tester.tap(find.text('Đăng nhập / Đăng ký ngay'));
    await tester.pumpAndSettle();

    // Tap "Sử dụng SĐT / Email / Username"
    expect(find.text('Sử dụng SĐT / Email / Username'), findsOneWidget);
    await tester.tap(find.text('Sử dụng SĐT / Email / Username'));
    await tester.pumpAndSettle();

    // Verify Login Screen tabs
    expect(find.widgetWithText(Tab, 'Số điện thoại'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Email'), findsOneWidget);

    // Switch to Email tab
    await tester.tap(find.widgetWithText(Tab, 'Email'));
    await tester.pumpAndSettle();

    // Enter email and password
    final emailField = find.widgetWithText(TextFormField, '').first;
    await tester.enterText(emailField, 'chef.linh@example.com');
    final passwordField = find.widgetWithText(TextFormField, '').last;
    await tester.enterText(passwordField, 'password123');
    await tester.pumpAndSettle();

    // Submit Email Login
    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
    await tester.pumpAndSettle();

    // Verify user is logged in
    expect(find.text('Chef Linh Đan'), findsWidgets);
    expect(find.byIcon(Iconsax.edit_2), findsOneWidget);
    expect(find.text('Thêm tiểu sử'), findsOneWidget);

    // Tap Edit Pen icon in AppBar -> opens EditProfileScreen ("Sửa thông tin")
    await tester.tap(find.byIcon(Iconsax.edit_2));
    await tester.pumpAndSettle();

    expect(find.text('Sửa thông tin'), findsOneWidget);
    expect(find.text('Thông tin cơ bản'), findsOneWidget);
    expect(find.text('Thông tin chi tiết & Liên hệ'), findsOneWidget);

    // Tap "Tên" item -> opens EditNameScreen
    await tester.tap(find.text('Tên'));
    await tester.pumpAndSettle();
    expect(find.text('Tên hiển thị'), findsOneWidget);

    // Go back to EditProfileScreen
    await tester.tap(find.byIcon(Iconsax.arrow_left));
    await tester.pumpAndSettle();

    // Tap "Tên người dùng" item -> opens EditUsernameScreen
    await tester.tap(find.text('Tên người dùng'));
    await tester.pumpAndSettle();
    expect(find.text('Tên người dùng'), findsAtLeastNWidgets(1));

    // Go back to EditProfileScreen
    await tester.tap(find.byIcon(Iconsax.arrow_left));
    await tester.pumpAndSettle();

    // Tap "Giới tính" item -> opens EditContactInfoScreen
    await tester.tap(find.text('Giới tính'));
    await tester.pumpAndSettle();
    expect(find.text('Thông tin cá nhân & Liên hệ'), findsOneWidget);

    // Go back
    await tester.tap(find.byIcon(Iconsax.arrow_left));
    await tester.pumpAndSettle();

    // Go back to ProfileScreen
    await tester.tap(find.byIcon(Iconsax.arrow_left));
    await tester.pumpAndSettle();

    // Tap "+ Thêm tiểu sử" button -> opens EditBioScreen
    await tester.tap(find.text('Thêm tiểu sử'));
    await tester.pumpAndSettle();

    expect(find.text('Tiểu sử cá nhân'), findsOneWidget);
    expect(find.text('Giới thiệu bản thân'), findsOneWidget);
  });
}
