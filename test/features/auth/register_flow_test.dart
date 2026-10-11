import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/core/storage/token_storage_service.dart';
import 'package:cookconnect/features/auth/presentation/pages/register_email_screen.dart';
import 'package:cookconnect/features/auth/presentation/pages/register_otp_screen.dart';
import 'package:cookconnect/features/auth/presentation/pages/register_password_screen.dart';

void main() {
  group('RegisterEmailScreen Tests', () {
    testWidgets('Renders phone and email tabs and allows phone registration', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AuthService.instance.configure(storage: InMemoryTokenStorageService());

      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterEmailScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify UI elements
      expect(find.text('Đăng ký tài khoản'), findsWidgets);
      expect(find.text('Số điện thoại'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Đăng ký bằng SĐT'), findsOneWidget);

      // Submit with empty phone
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng ký tài khoản'));
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng nhập số điện thoại'), findsOneWidget);

      // Enter phone and mismatched passwords
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), '0912345678');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.enterText(textFields.at(2), 'password456');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng ký tài khoản'));
      await tester.pumpAndSettle();
      expect(find.text('Mật khẩu xác nhận không trùng khớp'), findsOneWidget);

      // Fix confirm password and submit
      await tester.enterText(textFields.at(2), 'password123');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng ký tài khoản'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(AuthService.instance.isLoggedIn, isTrue);
      expect(AuthService.instance.currentUser?.fullName, 'Chef 0912345678');
    });

    testWidgets('Validates empty and invalid email format in Email tab', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterEmailScreen(initialTabIndex: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Verify UI elements on Email tab
      expect(find.text('Đăng ký tài khoản'), findsWidgets);
      expect(find.text('Nhập địa chỉ Email'), findsOneWidget);
      expect(find.text('Tiếp tục'), findsOneWidget);

      // Tap submit with empty email
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập địa chỉ email'), findsOneWidget);

      // Enter invalid email (in Email tab, text field index 3 because phone tab fields exist)
      final emailField = find.widgetWithText(TextFormField, '').last;
      await tester.enterText(emailField, 'invalid-email-format');
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();

      expect(
        find.text('Định dạng email không hợp lệ (ví dụ: name@example.com)'),
        findsOneWidget,
      );
    });

    testWidgets('Submits valid email and navigates to RegisterOtpScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/register/send-otp') {
          return http.Response(
            '{"success":true,"statusCode":200,"message":"OTP_SENT_SUCCESS"}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final mockApiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        MaterialApp(
          home: RegisterEmailScreen(
            apiService: mockApiService,
            initialTabIndex: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid email
      final emailField = find.widgetWithText(TextFormField, '').last;
      await tester.enterText(emailField, 'chef.linh@example.com');
      await tester.pumpAndSettle();

      // Tap submit
      await tester.tap(find.text('Tiếp tục'));
      await tester.pump(); // Start request
      await tester.pumpAndSettle(); // Settle navigation

      // Verify navigated to RegisterOtpScreen
      expect(find.byType(RegisterOtpScreen), findsOneWidget);
      expect(find.text('chef.linh@example.com'), findsOneWidget);
      expect(find.text('Nhập mã xác thực'), findsOneWidget);
      expect(find.text('Xác thực OTP'), findsWidgets);
    });

    testWidgets('Displays localized error message when email is already registered (400 / 409 AUTH.EMAIL_ALREADY_EXISTS)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/register/send-otp') {
          return http.Response(
            '{"success":false,"statusCode":400,"message":"AUTH.EMAIL_ALREADY_EXISTS","error":"Bad Request","errorCode":"AUTH.EMAIL_ALREADY_EXISTS"}',
            400,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final mockApiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        MaterialApp(
          home: RegisterEmailScreen(
            apiService: mockApiService,
            initialTabIndex: 1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter duplicate email
      final emailField = find.widgetWithText(TextFormField, '').last;
      await tester.enterText(emailField, 'existing@example.com');
      await tester.pumpAndSettle();

      // Tap submit
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();

      // Verify that localized Vietnamese message is displayed inline and NO SnackBar popup exists
      expect(find.text('Bad Request'), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Email đã được đăng ký trong hệ thống'), findsOneWidget);
    });
  });

  group('RegisterOtpScreen Tests', () {
    testWidgets('Renders 6-digit OTP fields and navigates to RegisterPasswordScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool otpVerifiedCalled = false;

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/register/verify-otp') {
          return http.Response(
            '''{
              "success": true,
              "statusCode": 200,
              "message": "OTP_VERIFIED",
              "data": {
                "verificationToken": "mock-verify-token-xyz"
              }
            }''',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final mockApiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        MaterialApp(
          home: RegisterOtpScreen(
            email: 'test@example.com',
            apiService: mockApiService,
            onOtpVerified: (email, token) {
              otpVerifiedCalled = true;
              expect(email, 'test@example.com');
              expect(token, 'mock-verify-token-xyz');
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Đổi email'), findsOneWidget);

      // Find 6 digit input fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(6));

      // Enter 6 digits
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '${i + 1}');
        await tester.pump();
      }

      // Scroll and tap confirm button
      final confirmBtn = find.widgetWithText(ElevatedButton, 'Xác nhận');
      expect(confirmBtn, findsOneWidget);
      await tester.ensureVisible(confirmBtn);
      await tester.pumpAndSettle();
      await tester.tap(confirmBtn);
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify callback called
      expect(otpVerifiedCalled, isTrue);

      // Verify navigated to RegisterPasswordScreen
      expect(find.byType(RegisterPasswordScreen), findsOneWidget);
      expect(find.text('Thiết lập mật khẩu'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsWidgets);
      expect(find.text('Xác nhận mật khẩu'), findsOneWidget);
    });
  });

  group('RegisterPasswordScreen Tests', () {
    testWidgets('Validates password match and completes registration', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AuthService.instance.configure(storage: InMemoryTokenStorageService());

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/register') {
          return http.Response(
            '''{
              "success": true,
              "statusCode": 201,
              "message": "AUTH.REGISTER_SUCCESS",
              "data": {
                "user": {
                  "id": "new-user-id",
                  "email": "chef.linh@example.com",
                  "fullName": "chef.linh",
                  "roles": ["USER"],
                  "status": "ACTIVE"
                },
                "tokens": {
                  "accessToken": "new-access-jwt",
                  "refreshToken": "new-refresh-jwt",
                  "tokenType": "Bearer",
                  "expiresIn": 900
                }
              }
            }''',
            201,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final mockApiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        MaterialApp(
          home: RegisterPasswordScreen(
            email: 'chef.linh@example.com',
            verificationToken: 'valid-vtok-123',
            apiService: mockApiService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      final completeBtnFinder = find.widgetWithText(ElevatedButton, 'Hoàn tất đăng ký');
      final ElevatedButton initialBtn = tester.widget(completeBtnFinder);
      expect(initialBtn.onPressed, isNull);

      // Verify visual requirements list rendered
      expect(find.text('Yêu cầu mật khẩu:'), findsOneWidget);
      expect(find.text('Tối thiểu 6 ký tự'), findsOneWidget);
      expect(find.text('Có chữ hoa, chữ thường và chữ số'), findsOneWidget);
      expect(find.text('Có ký tự đặc biệt (!@#\$%^&*...)'), findsOneWidget);

      // Enter password lacking uppercase or special char
      await tester.enterText(textFields.at(0), 'password123');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pump();

      // Button remains disabled because uppercase & special char are missing
      final ElevatedButton invalidPolicyBtn = tester.widget(completeBtnFinder);
      expect(invalidPolicyBtn.onPressed, isNull);

      // Enter password meeting all requirements: min 6 chars, uppercase, lowercase, digit, special char
      await tester.enterText(textFields.at(0), 'Password@123');
      await tester.enterText(textFields.at(1), 'Password@999');
      await tester.pump();

      // Button is disabled because confirm password does not match
      final ElevatedButton mismatchedBtn = tester.widget(completeBtnFinder);
      expect(mismatchedBtn.onPressed, isNull);

      // Fix confirm password to match
      await tester.enterText(textFields.at(1), 'Password@123');
      await tester.pump();

      // Button is now enabled
      final ElevatedButton enabledBtn = tester.widget(completeBtnFinder);
      expect(enabledBtn.onPressed, isNotNull);

      await tester.tap(completeBtnFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify AuthService session is updated
      expect(AuthService.instance.isLoggedIn, isTrue);
      expect(AuthService.instance.currentUser?.email, 'chef.linh@example.com');
      expect(AuthService.instance.tokens?.accessToken, 'new-access-jwt');
    });
  });
}
