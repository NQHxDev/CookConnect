import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/features/orders/presentation/pages/orders_screen.dart';
import 'package:shared_widgets/shared_widgets.dart';

void main() {
  testWidgets('OrdersScreen integrates CustomPullToRefresh with CustomSliverRefreshControl', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: OrdersScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify OrdersScreen renders title
    expect(find.text('Quản lý đơn hàng'), findsOneWidget);

    // Verify CustomPullToRefresh is rendered
    expect(find.byType(CustomPullToRefresh), findsOneWidget);

    // Verify CustomSliverRefreshControl is embedded inside CustomPullToRefresh
    expect(find.byType(CustomSliverRefreshControl, skipOffstage: false), findsOneWidget);

    // Pull down to trigger refresh
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, 150));
    await tester.pump(const Duration(milliseconds: 50));

    // CustomRefreshBadge should be present and refreshing
    expect(
      find.byWidgetPredicate((w) => w is CustomRefreshBadge && w.isRefreshing),
      findsOneWidget,
    );

    // Complete refresh
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify orders are still rendered properly
    expect(find.text('Nguyễn Văn An'), findsOneWidget);
  });
}
