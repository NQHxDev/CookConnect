import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/main.dart';

void main() {
  testWidgets(
    'Bottom sheet contains Đăng ký tài khoản and Quên mật khẩu options',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const CookConnect());
      await tester.pumpAndSettle();

      // Tap on profile tab
      await tester.tap(find.text('Cá nhân'));
      await tester.pumpAndSettle();

      // Tap "Đăng nhập / Đăng ký ngay"
      await tester.tap(find.text('Đăng nhập / Đăng ký ngay'));
      await tester.pumpAndSettle();

      // Verify "Đăng nhập vào CookConnect" bottom sheet is visible
      expect(find.text('Đăng nhập vào CookConnect'), findsOneWidget);

      // Verify "Đăng ký tài khoản" and "Quên mật khẩu?" buttons exist in the bottom sheet
      expect(find.text('Đăng ký tài khoản'), findsOneWidget);
      expect(find.text('Quên mật khẩu?'), findsOneWidget);

      // Tap on "Quên mật khẩu?"
      await tester.tap(find.text('Quên mật khẩu?'));
      await tester.pumpAndSettle();

      // Verify forgot password dialog appears
      expect(find.text('Quên mật khẩu?'), findsOneWidget);
      expect(find.text('Gửi yêu cầu'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
    },
  );
}
