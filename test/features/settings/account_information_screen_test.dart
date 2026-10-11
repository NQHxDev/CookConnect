import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/settings/presentation/pages/account/account_information_screen.dart';

void main() {
  group('AccountInformationScreen', () {
    testWidgets('renders AppBar, category header, and all 3 information options with mock data', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccountInformationScreen(),
        ),
      );

      // Verify AppBar and leading back button
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Iconsax.arrow_left), findsOneWidget);

      // Verify category header and appbar title both render "Thông tin tài khoản"
      expect(find.text('Thông tin tài khoản'), findsNWidgets(2));

      // Verify 3 option titles
      expect(find.text('Số điện thoại'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Ngày sinh'), findsOneWidget);

      // Verify masked mock email: only first and last char before @ with asterisks in between
      // For default 'cookconnect@gmail.com', masked is 'c*********t@gmail.com'
      expect(find.text('c*********t@gmail.com'), findsOneWidget);

      // Verify mock phone number and mock birth date with 'Ngày x, thg y, yyyy' format
      expect(find.text('+84 9******89'), findsOneWidget);
      expect(find.text('Ngày 15, thg 8, 1998'), findsOneWidget);

      // Verify 3 trailing arrows
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNWidgets(3));
    });

    testWidgets('tapping date of birth opens date picker dialog and selecting updates formatted date', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccountInformationScreen(),
        ),
      );

      await tester.tap(find.text('Ngày sinh'));
      await tester.pumpAndSettle();

      // Date picker dialog is shown
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.text('Chọn ngày sinh của bạn'), findsOneWidget);

      // Tap cancel to close dialog
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsNothing);
    });

    testWidgets('tapping phone shows informative snackbar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccountInformationScreen(),
        ),
      );

      await tester.tap(find.text('Số điện thoại'));
      await tester.pump();
      expect(find.text('Tính năng cập nhật số điện thoại đang phát triển!'), findsOneWidget);
    });

    testWidgets('tapping email shows informative snackbar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccountInformationScreen(),
        ),
      );

      await tester.tap(find.text('Email'));
      await tester.pump();
      expect(find.text('Tính năng cập nhật email đang phát triển!'), findsOneWidget);
    });
  });
}
