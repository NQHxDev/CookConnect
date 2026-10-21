import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/main.dart';
import 'package:cook_connect_seller/core/config/api_config.dart';

void main() {
  testWidgets('App renders main navigation and displays default Base URL', (WidgetTester tester) async {
    await tester.pumpWidget(const CookConnectSellerApp());
    await tester.pumpAndSettle();

    // Verify default API Base URL is 192.168.1.162
    expect(ApiConfig.baseUrl, equals('http://192.168.1.162:8080'));

    // Verify main screen navigation exists
    expect(find.text('Tổng quan'), findsWidgets);
    expect(find.text('Đơn hàng'), findsOneWidget);
    expect(find.text('Thực đơn'), findsOneWidget);
    expect(find.text('Cửa hàng'), findsOneWidget);
  });
}
