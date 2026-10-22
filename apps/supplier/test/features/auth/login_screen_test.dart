import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/auth_gate.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/welcome_auth_screen.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/email_phone_auth_screen.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_register_contact_screen.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_register_otp_screen.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_register_password_screen.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_store_setup_screen.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/social_auth_screen.dart';
import 'package:cook_connect_seller/main.dart';

void main() {
  late InMemoryTokenStorageService storage;
  late SellerAuthService authService;

  setUp(() {
    storage = InMemoryTokenStorageService();
    authService = SellerAuthService.instance;
    authService.configure(storage: storage);
  });

  tearDown(() async {
    await authService.logout(callServer: false);
  });

  testWidgets('AuthGate displays WelcomeAuthScreen with 3 vertical buttons when unauthenticated',
      (WidgetTester tester) async {
    await authService.init();

    await tester.pumpWidget(
      const MaterialApp(
        home: AuthGate(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify WelcomeAuthScreen components
    expect(find.byType(WelcomeAuthScreen), findsOneWidget);
    expect(find.text('CookConnect Seller'), findsOneWidget);
    expect(find.text('KÊNH NGƯỜI BÁN HÀNG'), findsOneWidget);

    // Verify 3 vertical action buttons
    expect(find.text('Đăng nhập bằng Email / Số điện thoại'), findsOneWidget);
    expect(find.text('Tiếp tục với Google'), findsOneWidget);
    expect(find.text('Tiếp tục với Apple'), findsOneWidget);

    // Verify quick demo and register footer
    expect(find.text('Dùng thử tài khoản mẫu (Demo Seller)'), findsOneWidget);
    expect(find.text('Đăng ký ngay'), findsOneWidget);
  });

  testWidgets('Tapping Email / Phone button opens dedicated EmailPhoneAuthScreen for Login',
      (WidgetTester tester) async {
    await authService.init();

    await tester.pumpWidget(
      const MaterialApp(
        home: AuthGate(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Email / Phone button
    await tester.tap(find.text('Đăng nhập bằng Email / Số điện thoại'));
    await tester.pumpAndSettle();

    // Now on dedicated EmailPhoneAuthScreen (Login only, not congested with register form)
    expect(find.byType(EmailPhoneAuthScreen), findsOneWidget);
    expect(find.text('Đăng nhập tài khoản'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Số điện thoại'), findsOneWidget);
    expect(find.text('Đăng nhập với Email'), findsOneWidget);

    // Go back to welcome screen
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeAuthScreen), findsOneWidget);
  });

  testWidgets('Tapping Google button opens dedicated SocialAuthScreen for Google',
      (WidgetTester tester) async {
    await authService.init();

    await tester.pumpWidget(
      const MaterialApp(
        home: AuthGate(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Google button
    await tester.tap(find.text('Tiếp tục với Google'));
    await tester.pumpAndSettle();

    expect(find.byType(SocialAuthScreen), findsOneWidget);
    expect(find.text('Đăng nhập với Google'), findsOneWidget);
    expect(find.text('Tiếp tục với tư cách Google ID'), findsOneWidget);

    // Tap to authorize Google
    await tester.tap(find.text('Tiếp tục với tư cách Google ID'));
    await tester.pumpAndSettle();

    // Successfully logged in and on MainNavigationScreen
    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });

  testWidgets('Tapping Apple button opens dedicated SocialAuthScreen for Apple',
      (WidgetTester tester) async {
    await authService.init();

    await tester.pumpWidget(
      const MaterialApp(
        home: AuthGate(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Apple button
    await tester.tap(find.text('Tiếp tục với Apple'));
    await tester.pumpAndSettle();

    expect(find.byType(SocialAuthScreen), findsOneWidget);
    expect(find.text('Đăng nhập với Apple'), findsOneWidget);
    expect(find.text('Tiếp tục với tư cách Apple ID'), findsOneWidget);

    // Tap to authorize Apple
    await tester.tap(find.text('Tiếp tục với tư cách Apple ID'));
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });

  testWidgets('Multi-step registration flow: Step 1 (Contact) -> Step 2 (OTP) -> Step 3 (Password) -> Step 4 (Store Setup)',
      (WidgetTester tester) async {
    await authService.init();

    await tester.pumpWidget(
      const MaterialApp(
        home: AuthGate(),
      ),
    );
    await tester.pumpAndSettle();

    // ================= STEP 1: CONTACT SCREEN =================
    // Tap "Đăng ký ngay"
    await tester.tap(find.text('Đăng ký ngay'));
    await tester.pumpAndSettle();

    expect(find.byType(SellerRegisterContactScreen), findsOneWidget);
    expect(find.text('Đăng ký gian hàng'), findsOneWidget);
    expect(find.text('Bước 1/3: Thông tin liên hệ'), findsOneWidget);
    expect(find.text('Mở gian hàng CookConnect'), findsOneWidget);

    // Enter email
    final emailField = find.widgetWithText(TextFormField, '');
    await tester.enterText(emailField, 'quan.viet@cookconnect.app');
    await tester.pumpAndSettle();

    // Tap "Tiếp tục & Nhận mã OTP"
    await tester.tap(find.text('Tiếp tục & Nhận mã OTP'));
    await tester.pumpAndSettle();

    // ================= STEP 2: OTP SCREEN =================
    expect(find.byType(SellerRegisterOtpScreen), findsOneWidget);
    expect(find.text('Xác thực OTP'), findsOneWidget);
    expect(find.text('Bước 2/3: Xác thực mã OTP'), findsOneWidget);
    expect(find.text('quan.viet@cookconnect.app'), findsOneWidget);
    expect(find.text('Nhập mã xác nhận 6 số'), findsOneWidget);

    // Enter 6-digit OTP
    final otpField = find.byType(TextField).last;
    await tester.enterText(otpField, '123456');
    await tester.pumpAndSettle();

    // Tap "Xác nhận & Tiếp tục"
    await tester.tap(find.text('Xác nhận & Tiếp tục'));
    await tester.pumpAndSettle();

    // ================= STEP 3: PASSWORD SCREEN =================
    expect(find.byType(SellerRegisterPasswordScreen), findsOneWidget);
    expect(find.text('Tạo mật khẩu'), findsOneWidget);
    expect(find.text('Bước 3/3: Tạo mật khẩu bảo vệ'), findsOneWidget);
    expect(find.text('Thiết lập mật khẩu đăng nhập'), findsOneWidget);

    // Enter Password and Confirm Password
    final passwordFields = find.byType(TextFormField);
    await tester.enterText(passwordFields.at(0), 'CookConnect123@');
    await tester.enterText(passwordFields.at(1), 'CookConnect123@');
    await tester.pumpAndSettle();

    // Tap "Tạo tài khoản & Thiết lập gian hàng"
    await tester.tap(find.text('Tạo tài khoản & Thiết lập gian hàng'));
    await tester.pumpAndSettle();

    // ================= STEP 4: STORE SETUP SCREEN =================
    expect(find.byType(SellerStoreSetupScreen), findsOneWidget);
    expect(find.text('Thông tin gian hàng'), findsOneWidget);
    expect(find.text('Thiết lập gian hàng'), findsOneWidget);

    // Fill store info
    final storeFields = find.byType(TextFormField);
    // 0: Store Name
    await tester.enterText(storeFields.at(0), 'Quán Cơm Quê Việt');
    // 1: Owner Name
    await tester.enterText(storeFields.at(1), 'Nguyễn Văn Nam');
    // 2: Phone Number
    await tester.enterText(storeFields.at(2), '0912345678');
    // 3: Address
    await tester.enterText(storeFields.at(3), '78 Lê Lợi, Phường Bến Nghé, Quận 1, TP. HCM');
    // 4: Description
    await tester.enterText(storeFields.at(4), 'Đậm đà hương vị quê hương ba miền');
    await tester.pumpAndSettle();

    // Tap "Hoàn tất & Mở gian hàng"
    await tester.tap(find.text('Hoàn tất & Mở gian hàng'));
    await tester.pumpAndSettle();

    // Successfully opened store, now in MainNavigationScreen!
    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser?.storeName, equals('Quán Cơm Quê Việt'));
    expect(authService.currentUser?.fullName, equals('Nguyễn Văn Nam'));
    expect(authService.currentUser?.phone, equals('0912345678'));
  });
}
