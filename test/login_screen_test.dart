import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cookconnect/screens/login_screen.dart';
import 'package:cookconnect/services/api_service.dart';
import 'package:cookconnect/services/auth_service.dart';
import 'package:cookconnect/services/token_storage_service.dart';

void main() {
  setUp(() {
    AuthService.instance.configure(storage: InMemoryTokenStorageService());
    AuthService.instance.logout(callServer: false);
  });

  testWidgets(
    'LoginScreen smoothly switches focus and keyboard type between phone and email tabs',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();

      // Verify initially on phone tab
      expect(find.widgetWithText(Tab, 'Số điện thoại'), findsOneWidget);
      expect(find.text('+84'), findsOneWidget);

      // 1. Tap on the phone number field
      final phoneField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.keyboardType == TextInputType.phone,
      );
      expect(phoneField, findsOneWidget);
      await tester.tap(phoneField);
      await tester.pumpAndSettle();

      // Verify phone field has focus and numeric keyboard
      final phoneEditableText = find.descendant(
        of: phoneField,
        matching: find.byType(EditableText),
      );
      final EditableText phoneWidget = tester.widget(phoneEditableText);
      expect(phoneWidget.focusNode.hasFocus, isTrue);
      expect(phoneWidget.keyboardType, TextInputType.phone);

      // 2. Switch to Email tab while phone field was focused
      await tester.tap(find.widgetWithText(Tab, 'Email'));
      await tester.pumpAndSettle();

      // Phone field should no longer have focus
      expect(phoneWidget.focusNode.hasFocus, isFalse);

      // Find email field
      final emailField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.keyboardType == TextInputType.emailAddress,
      );
      expect(emailField, findsOneWidget);

      // Verify email field automatically receives focus with text/email keyboard
      final emailEditableText = find.descendant(
        of: emailField,
        matching: find.byType(EditableText),
      );
      final EditableText emailWidget = tester.widget(emailEditableText);
      expect(emailWidget.focusNode.hasFocus, isTrue);
      expect(emailWidget.keyboardType, TextInputType.emailAddress);

      // 3. Switch back to Phone tab
      await tester.tap(find.widgetWithText(Tab, 'Số điện thoại'));
      await tester.pumpAndSettle();

      // Email field should no longer have focus
      expect(emailWidget.focusNode.hasFocus, isFalse);

      // Phone field should have focus with phone keyboard
      expect(phoneWidget.focusNode.hasFocus, isTrue);
      expect(phoneWidget.keyboardType, TextInputType.phone);
    },
  );

  testWidgets(
    'Email login failure displays inline error banner and clears password field without showing SnackBar popup',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/login') {
          return http.Response(
            '{"success":false,"statusCode":401,"message":"AUTH.INVALID_CREDENTIALS","errorCode":"AUTH.INVALID_CREDENTIALS"}',
            401,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('{"success":false}', 404);
      });

      final mockApiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(apiService: mockApiService),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Email tab
      await tester.tap(find.widgetWithText(Tab, 'Email'));
      await tester.pumpAndSettle();

      // Enter email and wrong password
      final emailField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.keyboardType == TextInputType.emailAddress,
      );
      final passwordField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.obscureText == true,
      );

      await tester.enterText(emailField, 'chef@example.com');
      await tester.enterText(passwordField, 'wrongpassword123');
      await tester.pump();

      // Tap Đăng nhập button
      final loginBtn = find.widgetWithText(ElevatedButton, 'Đăng nhập');
      await tester.tap(loginBtn);
      await tester.pump();
      await tester.pumpAndSettle();

      // 1. Password field must be cleared
      final passwordWidget = tester.widget<TextField>(passwordField);
      expect(passwordWidget.controller?.text, isEmpty);

      // 2. Inline error banner must be visible in the form
      expect(find.text('Email hoặc mật khẩu không chính xác.'), findsOneWidget);

      // 3. No red SnackBar popup
      expect(find.byType(SnackBar), findsNothing);

      // 4. Typing a new character in password field clears the inline error
      await tester.enterText(passwordField, 'a');
      await tester.pump();
      expect(find.text('Email hoặc mật khẩu không chính xác.'), findsNothing);
    },
  );
}
