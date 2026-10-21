import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/settings/presentation/pages/account_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/account_information_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/account_inheritance_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/deactivate_or_delete_account_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/passkey_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/password_screen.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/verification_screen.dart';

void main() {
  group('AccountScreen', () {
    testWidgets('renders AppBar with back button and centered title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccountScreen(),
        ),
      );

      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);

      final appBar = tester.widget<AppBar>(appBarFinder);
      expect(appBar.centerTitle, isTrue);

      expect(find.text('Tài khoản'), findsOneWidget);
      expect(find.byIcon(Iconsax.arrow_left), findsOneWidget);
    });

    testWidgets('renders all 6 account option items without leading icons and with subtitles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccountScreen(),
        ),
      );

      // Verify the 6 option titles
      expect(find.text('Thông tin tài khoản'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Passkey'), findsOneWidget);
      expect(find.text('Xác minh'), findsOneWidget);
      expect(find.text('Thừa kế tài khoản'), findsOneWidget);
      expect(find.text('Hủy kích hoạt hoặc xóa tài khoản'), findsOneWidget);

      // Verify subtitles for Mật khẩu, Passkey, Thừa kế tài khoản
      expect(find.text('Cập nhật mật khẩu để bảo vệ tài khoản của bạn'), findsOneWidget);
      expect(find.text('Đăng nhập an toàn bằng sinh trắc học hoặc khóa màn hình'), findsOneWidget);
      expect(find.text('Chọn người liên hệ thừa kế để quản lý tài khoản của bạn'), findsOneWidget);

      // Verify only arrow_forward_ios_rounded icons exist in body (6 arrows)
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNWidgets(6));
    });

    testWidgets('tapping account items navigates to each respective screen and back', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccountScreen(),
        ),
      );

      // 1. Thông tin tài khoản
      await tester.tap(find.text('Thông tin tài khoản'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountInformationScreen), findsOneWidget);
      expect(find.text('Thông tin tài khoản'), findsNWidgets(2));
      await tester.tap(find.byIcon(Iconsax.arrow_left));
      await tester.pumpAndSettle();
      expect(find.byType(AccountScreen), findsOneWidget);

      // 2. Mật khẩu
      await tester.tap(find.text('Mật khẩu'));
      await tester.pumpAndSettle();
      expect(find.byType(PasswordScreen), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      await tester.tap(find.byIcon(Iconsax.arrow_left));
      await tester.pumpAndSettle();
      expect(find.byType(AccountScreen), findsOneWidget);

      // 3. Passkey
      await tester.tap(find.text('Passkey'));
      await tester.pumpAndSettle();
      expect(find.byType(PasskeyScreen), findsOneWidget);
      expect(find.text('Passkey'), findsOneWidget);
      await tester.tap(find.byIcon(Iconsax.arrow_left));
      await tester.pumpAndSettle();
      expect(find.byType(AccountScreen), findsOneWidget);

      // 4. Xác minh
      await tester.tap(find.text('Xác minh'));
      await tester.pumpAndSettle();
      expect(find.byType(VerificationScreen), findsOneWidget);
      expect(find.text('Xác minh'), findsOneWidget);
      await tester.tap(find.byIcon(Iconsax.arrow_left));
      await tester.pumpAndSettle();
      expect(find.byType(AccountScreen), findsOneWidget);

      // 5. Thừa kế tài khoản
      await tester.tap(find.text('Thừa kế tài khoản'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountInheritanceScreen), findsOneWidget);
      expect(find.text('Thừa kế tài khoản'), findsOneWidget);
      await tester.tap(find.byIcon(Iconsax.arrow_left));
      await tester.pumpAndSettle();
      expect(find.byType(AccountScreen), findsOneWidget);

      // 6. Hủy kích hoạt hoặc xóa tài khoản
      await tester.tap(find.text('Hủy kích hoạt hoặc xóa tài khoản'));
      await tester.pumpAndSettle();
      expect(find.byType(DeactivateOrDeleteAccountScreen), findsOneWidget);
      expect(find.text('Hủy kích hoạt hoặc xóa tài khoản'), findsOneWidget);
      await tester.tap(find.byIcon(Iconsax.arrow_left));
      await tester.pumpAndSettle();
      expect(find.byType(AccountScreen), findsOneWidget);
    });
  });
}
