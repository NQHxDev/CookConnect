import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/screens/login_screen.dart';

void main() {
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
}
