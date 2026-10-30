import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_kyb_verification_screen.dart';

void main() {
  testWidgets('DashboardScreen displays KYB Onboarding Progress Card when store is PENDING',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Setup an unverified supplier (PENDING - Step 2 required)
    final pendingProfile = SupplierProfile(
      supplierId: 'pending-supp-01',
      supplierName: 'Nông Sản Hữu Cơ Đà Lạt',
      supplierCode: 'SUPP-DL-01',
      isVerified: false,
      supplierStatus: 'PENDING',
    );

    final pendingUser = SellerUser(
      id: 'pending-user-01',
      email: 'dalat@supplier.vn',
      fullName: 'Chủ Nông Trại',
      storeName: 'Nông Sản Hữu Cơ Đà Lạt',
      storeId: 'pending-supp-01',
      supplierProfile: pendingProfile,
    );

    final tokens = AuthTokens(
      accessToken: 'demo-token-pending',
      refreshToken: 'demo-refresh-pending',
      expiresIn: 3600,
    );

    SellerAuthService.instance.setSession(user: pendingUser, tokens: tokens);

    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify KYB Progress card is shown prominently
    expect(find.text('Hoàn thành hồ sơ đối tác'), findsOneWidget);
    expect(find.text('Chưa nộp'), findsOneWidget);
    expect(find.textContaining('Xác minh thông tin để mở bán'), findsOneWidget);

    // 2. Tap on KYB banner navigates to SellerKybVerificationScreen
    await tester.tap(find.text('Hoàn thành hồ sơ đối tác'));
    await tester.pumpAndSettle();

    expect(find.byType(SellerKybVerificationScreen), findsOneWidget);
    expect(find.text('Xác minh gian hàng'), findsOneWidget);
    expect(find.text('1. Loại hình kinh doanh'), findsOneWidget);
    expect(find.text('3. Tài khoản ngân hàng nhận doanh thu'), findsOneWidget);
  });
}
