import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/main/presentation/pages/main_screen.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/auth/presentation/widgets/auth_bottom_sheet.dart';
import 'package:cookconnect/features/recipe/presentation/pages/cooking_camera_screen.dart';
import 'package:cookconnect/core/storage/token_storage_service.dart';

void main() {
  setUp(() {
    AuthService.instance.configure(storage: InMemoryTokenStorageService());
    AuthService.instance.logout(callServer: false);
  });

  testWidgets(
    'Unauthenticated user tapping add button (+) shows AuthBottomSheet and does NOT open CookingCameraScreen',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      expect(AuthService.instance.isLoggedIn, isFalse);

      await tester.pumpWidget(
        const MaterialApp(
          home: MainScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Locate the add (+) button in bottom navigation
      final addButton = find.byIcon(Iconsax.add);
      expect(addButton, findsOneWidget);

      // Tap on the add (+) button
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify that CookingCameraScreen is NOT pushed
      expect(find.byType(CookingCameraScreen), findsNothing);

      // Verify that AuthBottomSheet is displayed
      expect(find.byType(AuthBottomSheet), findsOneWidget);
      expect(find.text('Đăng nhập vào CookConnect'), findsOneWidget);
      expect(find.text('Đăng nhập để đăng video công thức của bạn!'), findsOneWidget);
    },
  );

  testWidgets(
    'Authenticated user tapping add button (+) opens CookingCameraScreen without showing bottom sheet',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Log in user
      AuthService.instance.setGuestDemo();
      expect(AuthService.instance.isLoggedIn, isTrue);

      await tester.pumpWidget(
        const MaterialApp(
          home: MainScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Locate the add (+) button in bottom navigation
      final addButton = find.byIcon(Iconsax.add);
      expect(addButton, findsOneWidget);

      // Tap on the add (+) button
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify that AuthBottomSheet is NOT displayed
      expect(find.byType(AuthBottomSheet), findsNothing);

      // Verify CookingCameraScreen is opened
      expect(find.byType(CookingCameraScreen), findsOneWidget);
    },
  );
}
