import 'package:flutter/widgets.dart';

/// Yêu cầu điều hướng tới trang "Đi chợ" (MarketScreen).
class MarketNavigationRequest {
  /// 0 = Danh sách cần mua, 1 = Chợ thực phẩm.
  final int tabIndex;

  /// Từ khoá tìm kiếm sẵn trong tab "Chợ thực phẩm" (nếu có).
  final String? searchQuery;

  const MarketNavigationRequest({this.tabIndex = 0, this.searchQuery});
}

/// Bộ điều hướng tab toàn cục giúp các màn hình (Feed, bottom sheet...) có thể
/// chuyển sang tab khác của [MainScreen] mà không cần truyền callback qua nhiều tầng.
class AppTabNavigator extends ChangeNotifier {
  AppTabNavigator._();
  static final AppTabNavigator instance = AppTabNavigator._();

  static const int homeTab = 0;
  static const int marketTab = 3;

  int? _pendingMainTab;
  MarketNavigationRequest? _pendingMarketRequest;

  /// Đóng toàn bộ route đang chồng lên (bottom sheet, màn video người dùng...)
  /// và mở tab "Đi chợ".
  void openMarket(
    BuildContext context, {
    int tabIndex = 0,
    String? searchQuery,
  }) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    _pendingMarketRequest = MarketNavigationRequest(
      tabIndex: tabIndex,
      searchQuery: searchQuery,
    );
    _pendingMainTab = marketTab;
    notifyListeners();
  }

  /// Mở danh sách cần mua.
  void openShoppingList(BuildContext context) =>
      openMarket(context, tabIndex: 0);

  /// Mở Chợ thực phẩm và tìm sẵn nguyên liệu.
  void searchInMarket(BuildContext context, String query) =>
      openMarket(context, tabIndex: 1, searchQuery: query);

  int? consumeMainTab() {
    final tab = _pendingMainTab;
    _pendingMainTab = null;
    return tab;
  }

  MarketNavigationRequest? consumeMarketRequest() {
    final request = _pendingMarketRequest;
    _pendingMarketRequest = null;
    return request;
  }
}

