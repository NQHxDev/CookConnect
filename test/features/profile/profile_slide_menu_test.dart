import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/main/presentation/pages/main_screen.dart';
import 'package:cookconnect/features/profile/presentation/pages/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen 8/2 slide menu renders section titles and handles slide actions', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );

    // Initial state: menu is closed
    expect(find.text('Công cụ cá nhân'), findsNothing);
    expect(find.text('Cài đặt'), findsNothing);

    // Tap the menu icon (3-bar menu)
    final menuButtonFinder = find.byTooltip('Menu');
    expect(menuButtonFinder, findsOneWidget);
    await tester.tap(menuButtonFinder);
    await tester.pumpAndSettle();

    // Now options panel is open with section headers and items
    expect(find.text('Công cụ cá nhân'), findsOneWidget);
    expect(find.text('Trung tâm hoạt động'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);
    expect(find.text('Cài đặt và quyền riêng tư'), findsOneWidget);

    // Tap on the 20% left overlay area (e.g. at x = 20, y = 300) to close
    await tester.tapAt(const Offset(20, 300));
    await tester.pumpAndSettle();

    // Menu is closed
    expect(find.text('Công cụ cá nhân'), findsNothing);
  });

  testWidgets('MainScreen automatically closes profile options menu when switching to another tab', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainScreen(),
      ),
    );

    // Switch to Profile Tab (index 4)
    final profileTabFinder = find.text('Cá nhân');
    expect(profileTabFinder, findsOneWidget);
    await tester.tap(profileTabFinder);
    await tester.pumpAndSettle();

    // Open options menu
    final menuButtonFinder = find.byTooltip('Menu');
    expect(menuButtonFinder, findsOneWidget);
    await tester.tap(menuButtonFinder);
    await tester.pumpAndSettle();

    // Menu is opened
    expect(find.text('Công cụ cá nhân'), findsOneWidget);

    // Tap Home Tab (Trang chủ)
    final homeTabFinder = find.text('Trang chủ');
    expect(homeTabFinder, findsOneWidget);
    await tester.tap(homeTabFinder);
    await tester.pumpAndSettle();

    // Now tap back to Profile Tab (Cá nhân)
    await tester.tap(profileTabFinder);
    await tester.pumpAndSettle();

    // Options menu must be closed when returning to Profile tab
    expect(find.text('Công cụ cá nhân'), findsNothing);
  });
}
