import 'package:flutter/material.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';

/// Navigation Observer that verifies authentication state on every route push/replace.
/// Prevents bypassing the login wall via deep link or manual route manipulation.
class AuthNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _validateRouteAccess(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _validateRouteAccess(newRoute);
    }
  }

  void _validateRouteAccess(Route<dynamic> route) {
    final routeName = route.settings.name;
    // Allow public / auth routes
    if (routeName == '/login' || routeName == '/auth' || routeName == '/register') {
      return;
    }

    // If not logged in, enforce redirect back to login root
    if (!SellerAuthService.instance.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SellerAuthService.instance.handleSessionExpired();
      });
    }
  }
}
