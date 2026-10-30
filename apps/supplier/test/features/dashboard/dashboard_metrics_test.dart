import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/dashboard/data/models/dashboard_stats.dart';
import 'package:cook_connect_seller/features/dashboard/data/services/dashboard_api_service.dart';
import 'package:cook_connect_seller/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:cook_connect_seller/features/orders/presentation/pages/orders_screen.dart';

void main() {
  group('DashboardStats Model Tests', () {
    test('Calculates comparison text for today vs yesterday correctly', () {
      const statsMore = DashboardStats(
        todayCompletedOrders: 10,
        yesterdayCompletedOrders: 6,
      );
      expect(statsMore.completedComparisonText, '+4 đơn so với hôm qua');

      const statsFewer = DashboardStats(
        todayCompletedOrders: 3,
        yesterdayCompletedOrders: 5,
      );
      expect(statsFewer.completedComparisonText, '-2 đơn so với hôm qua');

      const statsEqual = DashboardStats(
        todayCompletedOrders: 7,
        yesterdayCompletedOrders: 7,
      );
      expect(statsEqual.completedComparisonText, 'Bằng hôm qua (7 đơn)');

      const statsZero = DashboardStats(
        todayCompletedOrders: 0,
        yesterdayCompletedOrders: 0,
      );
      expect(statsZero.completedComparisonText, 'Chưa có đơn hôm nay');
    });

    test('Formats preparation time and subtext appropriately', () {
      const statsFast = DashboardStats(avgPrepMinutes: 14);
      expect(statsFast.prepTimeString, '14 phút');
      expect(statsFast.prepTimeSubtext, 'Nhanh hơn chuẩn 6p');

      const statsStandard = DashboardStats(avgPrepMinutes: 20);
      expect(statsStandard.prepTimeSubtext, 'Đúng chuẩn 20 phút');

      const statsNull = DashboardStats(avgPrepMinutes: null);
      expect(statsNull.prepTimeString, '~15 phút');
      expect(statsNull.prepTimeSubtext, 'Thời gian chuẩn bị dự kiến');
    });

    test('Formats rating and operational status badge', () {
      const statsHigh = DashboardStats(storeRating: 4.8, returnsCount: 0);
      expect(statsHigh.ratingString, '4.8 ★');
      expect(statsHigh.operationalStatusBadge, 'Vận hành xuất sắc');

      const statsGood = DashboardStats(storeRating: 4.2, returnsCount: 1);
      expect(statsGood.ratingString, '4.2 ★');
      expect(statsGood.operationalStatusBadge, 'Vận hành tốt');

      const statsNeedsWork = DashboardStats(storeRating: 3.8);
      expect(statsNeedsWork.operationalStatusBadge, 'Đang chuẩn hóa');
    });

    test('Serializes to and from JSON faithfully', () {
      final original = DashboardStats(
        pendingConfirmationCount: 4,
        packagingCount: 7,
        shippingCount: 11,
        returnsCount: 1,
        todayCompletedOrders: 15,
        yesterdayCompletedOrders: 12,
        avgPrepMinutes: 16,
        storeRating: 4.7,
        chatResponseRate: 99,
      );

      final json = original.toJson();
      final restored = DashboardStats.fromJson(json);

      expect(restored.pendingConfirmationCount, 4);
      expect(restored.packagingCount, 7);
      expect(restored.shippingCount, 11);
      expect(restored.returnsCount, 1);
      expect(restored.todayCompletedOrders, 15);
      expect(restored.yesterdayCompletedOrders, 12);
      expect(restored.avgPrepMinutes, 16);
      expect(restored.storeRating, 4.7);
      expect(restored.chatResponseRate, 99);
    });
  });

  group('DashboardApiService Operational Metrics Tests', () {
    test('Returns structured operational stats for demo / preview environment', () async {
      final service = DashboardApiService();
      final profile = SupplierProfile(
        supplierId: 'supp-test',
        supplierName: 'Fresh Store',
        rating: 4.9,
      );

      final stats = await service.getOperationalDashboardStats(
        token: 'demo-token-xyz',
        supplierProfile: profile,
      );

      expect(stats.storeRating, 4.9);
      expect(stats.pendingConfirmationCount, greaterThan(0));
      expect(stats.packagingCount, greaterThan(0));
      expect(stats.shippingCount, greaterThan(0));
      expect(stats.todayCompletedOrders, greaterThan(0));
    });
  });

  group('DashboardScreen Action Center Navigation Tests', () {
    setUp(() {
      SellerAuthService.instance.setDemoSession();
    });

    testWidgets('Tapping Action Center items dispatches target filters to OrdersScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      String? lastCategory;
      String? lastStatus;
      OrdersScreen.onApplyFilter = (cat, stat) {
        lastCategory = cat;
        lastStatus = stat;
      };

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Chờ xác nhận"
      await tester.tap(find.text('Chờ xác nhận'));
      await tester.pumpAndSettle();
      expect(lastCategory, 'needs_action');
      expect(lastStatus, 'Cần vận chuyển trong vòng 24h');

      // Tap "Chờ đóng gói"
      await tester.tap(find.text('Chờ đóng gói'));
      await tester.pumpAndSettle();
      expect(lastCategory, 'shipping');
      expect(lastStatus, 'Đang chờ vận chuyển');

      // Tap "Đang giao"
      await tester.tap(find.text('Đang giao'));
      await tester.pumpAndSettle();
      expect(lastCategory, 'shipping');
      expect(lastStatus, 'Đang trung chuyển');

      // Tap "Khiếu nại/Trả"
      await tester.tap(find.text('Khiếu nại/Trả'));
      await tester.pumpAndSettle();
      expect(lastCategory, 'shipping');
      expect(lastStatus, 'Đã hủy');

      // Tap "Tất cả đơn"
      await tester.tap(find.text('Tất cả đơn'));
      await tester.pumpAndSettle();
      expect(lastCategory, 'shipping');
      expect(lastStatus, 'Tất cả');
    });
  });
}
