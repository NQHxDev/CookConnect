import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/core/widgets/custom_pull_to_refresh.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/profile/presentation/pages/profile_screen.dart';

void main() {
  setUp(() {
    AuthService.instance.setGuestDemo(
      name: 'Test Chef',
      email: 'chef@cookconnect.app',
    );
  });

  tearDown(() {
    AuthService.instance.logout();
  });

  testWidgets(
    'ProfileScreen pull-to-refresh: rapid repeated pulls do not leave 3-dots badge hanging or frozen',
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

      final scrollableFinder = find.byType(Scrollable).first;
      final profileState = tester.state<ProfileScreenState>(find.byType(ProfileScreen));

      // 1. Initially, CustomRefreshBadge should not be in the tree or percentage <= 0
      expect(profileState.isRefreshing, isFalse);
      expect(profileState.pullOffset, equals(0.0));

      // 2. Perform first pull-to-refresh
      await tester.drag(scrollableFinder, const Offset(0, 120));
      await tester.pump(const Duration(milliseconds: 50));

      expect(profileState.isRefreshing, isTrue);
      expect(profileState.pullOffset, equals(60.0));
      expect(
        find.byWidgetPredicate((widget) =>
            widget is CustomRefreshBadge && widget.isRefreshing),
        findsOneWidget,
      );

      // 3. While refreshing, simulate repeated rapid user swipes (the exact user bug scenario)
      for (int i = 0; i < 5; i++) {
        await tester.drag(scrollableFinder, const Offset(0, 80));
        await tester.pump(const Duration(milliseconds: 60));
      }

      // 4. Let the refresh finish and animations settle
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // 5. Verify the loading badge is completely gone and NOT hanging/floating
      expect(profileState.isRefreshing, isFalse);
      expect(profileState.pullOffset, equals(0.0));
      expect(profileState.refreshAnimControllerDebug.isAnimating, isFalse);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is CustomRefreshBadge &&
            (widget.isRefreshing || widget.percentage > 0.01)),
        findsNothing,
      );
    },
  );

  testWidgets(
    'ProfileScreen pull-to-refresh: shallow pulls below threshold collapse cleanly back to 0',
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

      final scrollableFinder = find.byType(Scrollable).first;
      final profileState = tester.state<ProfileScreenState>(find.byType(ProfileScreen));

      // Pull slightly (below 48.0 threshold, e.g. 20px overscroll) and let it collapse
      await tester.drag(scrollableFinder, const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Badge must collapse cleanly and not remain visible or refreshing
      expect(profileState.isRefreshing, isFalse);
      expect(profileState.pullOffset, equals(0.0));
      expect(profileState.refreshAnimControllerDebug.isAnimating, isFalse);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is CustomRefreshBadge &&
            (widget.isRefreshing || widget.percentage > 0.01)),
        findsNothing,
      );
    },
  );

  testWidgets(
    'ProfileScreen pull-to-refresh: switching tabs immediately cleans up any refresh/pull state',
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

      final scrollableFinder = find.byType(Scrollable).first;
      final profileState = tester.state<ProfileScreenState>(find.byType(ProfileScreen));

      // Start refresh
      await tester.drag(scrollableFinder, const Offset(0, 120));
      await tester.pump(const Duration(milliseconds: 50));
      expect(profileState.isRefreshing, isTrue);

      // Switch to liked tab (tab 1)
      final tabs = find.byType(Tab);
      await tester.tap(tabs.at(1));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // State is completely cleaned up
      expect(profileState.isRefreshing, isFalse);
      expect(profileState.pullOffset, equals(0.0));
      expect(profileState.refreshAnimControllerDebug.isAnimating, isFalse);

      // Switch back to video tab (tab 0)
      await tester.tap(tabs.at(0));
      await tester.pumpAndSettle();

      // Badge must not be hanging or stuck
      expect(profileState.isRefreshing, isFalse);
      expect(profileState.pullOffset, equals(0.0));
      expect(profileState.refreshAnimControllerDebug.isAnimating, isFalse);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is CustomRefreshBadge &&
            (widget.isRefreshing || widget.percentage > 0.01)),
        findsNothing,
      );
    },
  );
}
