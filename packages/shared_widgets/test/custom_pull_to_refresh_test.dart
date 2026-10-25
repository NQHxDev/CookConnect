import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_widgets/shared_widgets.dart';

void main() {
  group('CustomRefreshBadge', () {
    testWidgets('renders properly with given percentage and state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomRefreshBadge(
                isRefreshing: false,
                percentage: 0.5,
                primaryColor: Colors.deepOrange,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomRefreshBadge), findsOneWidget);
    });

    testWidgets('returns SizedBox.shrink when not refreshing and percentage <= 0.01', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomRefreshBadge(
                isRefreshing: false,
                percentage: 0.0,
              ),
            ),
          ),
        ),
      );

      final sizedBoxFinder = find.descendant(
        of: find.byType(CustomRefreshBadge),
        matching: find.byType(SizedBox),
      );
      expect(sizedBoxFinder, findsOneWidget);
    });
  });

  group('CustomPullToRefresh', () {
    testWidgets('renders slivers and CustomSliverRefreshControl correctly', (tester) async {
      bool refreshed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPullToRefresh(
              onRefresh: () async {
                refreshed = true;
              },
              slivers: const [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: Text('Test Item'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CustomSliverRefreshControl, skipOffstage: false), findsOneWidget);
      expect(find.text('Test Item'), findsOneWidget);
      expect(refreshed, isFalse);
    });
  });
}
