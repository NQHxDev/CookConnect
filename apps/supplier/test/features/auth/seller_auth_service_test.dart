import 'package:flutter_test/flutter_test.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';

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

  test('Initial state is not logged in', () {
    expect(authService.isLoggedIn, isFalse);
    expect(authService.currentUser, isNull);
    expect(authService.tokens, isNull);
  });

  test('sendOtp and verifyOtp work successfully', () async {
    final sendResult = await authService.sendOtp(contact: 'seller.new@cookconnect.app');
    expect(sendResult.isSuccess, isTrue);
    expect(sendResult.verificationToken, isNotNull);

    final verifyResult = await authService.verifyOtp(
      contact: 'seller.new@cookconnect.app',
      otp: '123456',
    );
    expect(verifyResult.isSuccess, isTrue);
    expect(verifyResult.verificationToken, isNotNull);
  });

  test('register and updateStoreProfile flow', () async {
    final regResult = await authService.register(
      email: 'quancuatoi@cookconnect.app',
      password: 'StrongPassword123!',
      verificationToken: 'vtoken-123',
    );

    expect(regResult.success, isTrue);
    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser?.email, equals('quancuatoi@cookconnect.app'));

    await authService.updateStoreProfile(
      storeName: 'Bếp Nhà Tôi',
      fullName: 'Trần Văn An',
      phone: '0901234567',
      category: 'Cơm văn phòng & Món gia đình',
      address: '100 Hai Bà Trưng, Q1, TP. HCM',
      description: 'Cơm ngon chuẩn vị mẹ nấu',
    );

    expect(authService.currentUser?.storeName, equals('Bếp Nhà Tôi'));
    expect(authService.currentUser?.fullName, equals('Trần Văn An'));
    expect(authService.currentUser?.phone, equals('0901234567'));
    expect(authService.currentUser?.category, equals('Cơm văn phòng & Món gia đình'));
    expect(authService.currentUser?.address, equals('100 Hai Bà Trưng, Q1, TP. HCM'));
    expect(authService.currentUser?.description, equals('Cơm ngon chuẩn vị mẹ nấu'));
  });

  test('setDemoSession sets valid session and notifies listeners', () {
    bool notified = false;
    authService.addListener(() => notified = true);

    authService.setDemoSession();

    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser?.storeName, contains('Đại Siêu Thị Nguyên Liệu Tươi'));
    expect(authService.currentUser?.role, equals('SUPPLIER_ADMIN'));
    expect(authService.tokens?.accessToken, startsWith('demo-seller-token'));
    expect(notified, isTrue);
  });

  test('loginWithSocial sets valid session for Google and Apple', () async {
    final googleResult = await authService.loginWithSocial(provider: 'google');
    expect(googleResult.success, isTrue);
    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser?.fullName, equals('Google Seller Partner'));
    expect(authService.tokens?.accessToken, startsWith('social-google-'));

    final appleResult = await authService.loginWithSocial(provider: 'apple');
    expect(appleResult.success, isTrue);
    expect(authService.currentUser?.fullName, equals('Apple Seller Partner'));
    expect(authService.tokens?.accessToken, startsWith('social-apple-'));
  });

  test('logout clears session and storage', () async {
    authService.setDemoSession();
    expect(authService.isLoggedIn, isTrue);

    await authService.logout(callServer: false);

    expect(authService.isLoggedIn, isFalse);
    expect(authService.currentUser, isNull);
    expect(authService.tokens, isNull);
    final storedTokens = await storage.getTokens();
    expect(storedTokens, isNull);
  });

  test('Expired tokens on init are rejected and cleared', () async {
    final expiredTokens = AuthTokens(
      accessToken: 'expired-token',
      refreshToken: 'expired-refresh',
      expiresIn: -100, // already expired
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    );
    await storage.saveTokens(expiredTokens);

    await authService.init();

    expect(authService.isLoggedIn, isFalse);
    expect(authService.tokens, isNull);
  });

  test('Valid cached tokens on init restore session', () async {
    final validTokens = AuthTokens(
      accessToken: 'valid-token',
      refreshToken: 'valid-refresh',
      expiresIn: 3600,
      createdAt: DateTime.now(),
    );
    final user = SellerUser(
      id: 'seller-123',
      email: 'quanan@cookconnect.app',
      storeName: 'Quán Ăn Ngon',
      role: 'seller',
    );
    await storage.saveTokens(validTokens);
    await storage.saveSellerProfile(user.toJson());

    await authService.init();

    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser?.storeName, equals('Quán Ăn Ngon'));
  });
}
