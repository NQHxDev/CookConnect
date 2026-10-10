import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/profile/presentation/pages/profile_screen.dart';

void main() {
  setUp(() {
    AuthService.instance.setGuestDemo(
      name: 'Nguyễn Văn A',
      email: 'nguyenvana@cookconnect.app',
    );
  });

  tearDown(() {
    AuthService.instance.logout();
  });

  testWidgets(
    'ProfileScreen HeaderNavBar remains white and shows user name on scroll down, hides on scroll up',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify AppBar properties
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);

      final appBar = tester.widget<AppBar>(appBarFinder);
      expect(appBar.backgroundColor, Colors.white);
      expect(appBar.scrolledUnderElevation, 0.0);
      expect(appBar.surfaceTintColor, Colors.transparent);

      // Initially at top (offset 0): Title AnimatedOpacity should have opacity 0.0
      final nameFinder = find.text('Nguyễn Văn A');
      // User name exists on the profile card (large) and in the AppBar (small)
      expect(nameFinder, findsNWidgets(2));

      // Find the AnimatedOpacity inside AppBar
      final appBarAnimatedOpacityFinder = find.descendant(
        of: appBarFinder,
        matching: find.byType(AnimatedOpacity),
      );
      expect(appBarAnimatedOpacityFinder, findsOneWidget);

      AnimatedOpacity animOpacity = tester.widget<AnimatedOpacity>(appBarAnimatedOpacityFinder);
      expect(animOpacity.opacity, 0.0);

      // Scroll down by 200 pixels
      final scrollableFinder = find.byType(Scrollable).first;
      await tester.drag(scrollableFinder, const Offset(0, -200));
      await tester.pumpAndSettle();

      // Now opacity should be 1.0 (name visible in header)
      animOpacity = tester.widget<AnimatedOpacity>(appBarAnimatedOpacityFinder);
      expect(animOpacity.opacity, 1.0);

      // Scroll back up by 200 pixels
      await tester.drag(scrollableFinder, const Offset(0, 200));
      await tester.pumpAndSettle();

      // Opacity should return to 0.0 (name hidden in header)
      animOpacity = tester.widget<AnimatedOpacity>(appBarAnimatedOpacityFinder);
      expect(animOpacity.opacity, 0.0);
    },
  );
}
