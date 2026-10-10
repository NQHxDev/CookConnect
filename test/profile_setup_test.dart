import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/services/auth_service.dart';
import 'package:cookconnect/widgets/profile_setup_dialog.dart';

void main() {
  setUp(() {
    AuthService.instance.setGuestDemo(
      name: 'Chef Minh Quân',
      email: 'minhquan@cookconnect.app',
    );
  });

  tearDown(() {
    AuthService.instance.logout();
  });

  testWidgets(
    'ProfileSetupDialog renders all profile fields and updates user correctly',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProfileSetupDialog(isFirstTime: true)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dialog title and fields
      expect(find.text('Hoàn tất hồ sơ Chef'), findsOneWidget);
      expect(find.text('Họ và tên / Tên hiển thị'), findsOneWidget);
      expect(find.text('Tên người dùng'), findsOneWidget);
      expect(find.text('Giới tính'), findsOneWidget);
      expect(find.text('Ngày sinh'), findsOneWidget);
      expect(find.text('Tiểu sử giới thiệu (Bio)'), findsOneWidget);

      // Enter full name
      final nameField = find.widgetWithText(TextFormField, 'Chef Minh Quân');
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, 'Nguyễn Minh Quân');
      await tester.pumpAndSettle();

      // Select Gender "Nam"
      await tester.tap(find.text('Nam'));
      await tester.pumpAndSettle();

      // Tap Save button
      await tester.tap(find.text('Hoàn tất & Bắt đầu'));
      await tester.pumpAndSettle();

      // Verify AuthService updated
      expect(AuthService.instance.currentUser?.fullName, 'Nguyễn Minh Quân');
      expect(AuthService.instance.currentUser?.gender, 'MALE');
    },
  );
}
