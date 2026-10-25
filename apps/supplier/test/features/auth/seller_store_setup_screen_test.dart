import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/features/auth/data/models/seller_auth.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_store_setup_screen.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/welcome_auth_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  Widget buildTestWidget({String? contact, bool isPhone = false}) {
    return MaterialApp(
      home: SellerStoreSetupScreen(
        contact: contact ?? 'partner@cookconnect.vn',
        isPhone: isPhone,
      ),
    );
  }

  testWidgets('AppBar has Back arrow button and NO Exit / Logout button', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Thông tin gian hàng'), findsOneWidget);

    // Back arrow button is in the AppBar
    expect(find.byKey(const Key('store_setup_back_button')), findsOneWidget);
    expect(find.byIcon(Iconsax.arrow_left), findsOneWidget);

    // Exit / Logout icon must not exist
    expect(find.byIcon(Iconsax.logout), findsNothing);
    expect(find.byTooltip('Đăng xuất'), findsNothing);
  });

  testWidgets('Tapping Back arrow navigates to WelcomeAuthScreen and clears session', (WidgetTester tester) async {
    // Set a dummy user session
    authService.setSession(
      user: SellerUser(
        id: 'user_1',
        email: 'partner@cookconnect.vn',
        phone: '0901234567',
        fullName: 'Nguyen Van Test',
      ),
      tokens: AuthTokens(accessToken: 'demo_access', refreshToken: 'demo_refresh'),
    );
    expect(authService.isLoggedIn, isTrue);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final backButton = find.byKey(const Key('store_setup_back_button'));
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Navigated to WelcomeAuthScreen
    expect(find.byType(WelcomeAuthScreen), findsOneWidget);
    expect(authService.isLoggedIn, isFalse);
  });

  testWidgets('Contact email field is read-only and cannot request focus', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(contact: 'supplier.chef@gmail.com'));
    await tester.pumpAndSettle();

    // Verify initial value
    expect(find.text('supplier.chef@gmail.com'), findsOneWidget);

    // Verify lock icon is not present
    expect(find.byIcon(Icons.lock_outline), findsNothing);

    // Find the email TextField
    final textFieldFinder = find.descendant(
      of: find.widgetWithText(TextFormField, 'supplier.chef@gmail.com'),
      matching: find.byType(TextField),
    );
    expect(textFieldFinder, findsOneWidget);

    final textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.readOnly, isTrue);
    expect(textField.canRequestFocus, isFalse);
    expect(textField.enableInteractiveSelection, isFalse);
  });

  testWidgets('City field opens Bottom Sheet Modal and allows selecting a city', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Initial placeholder should be present
    expect(find.text('Chọn Tỉnh / Thành phố hoạt động'), findsOneWidget);

    // Scroll to city picker field and tap
    final cityField = find.byKey(const Key('city_picker_field'));
    await tester.ensureVisible(cityField);
    await tester.tap(cityField);
    await tester.pumpAndSettle();

    // Bottom sheet is shown
    expect(find.text('Tỉnh / Thành phố hoạt động'), findsWidgets);
    expect(find.text('Chọn khu vực gian hàng cung ứng chính'), findsOneWidget);
    expect(find.text('Hồ Chí Minh'), findsOneWidget);
    expect(find.text('Hà Nội'), findsOneWidget);
    expect(find.text('Đà Nẵng'), findsOneWidget);

    // Tap on 'Hà Nội' (city_item_1)
    await tester.tap(find.byKey(const Key('city_item_1')));
    await tester.pumpAndSettle();

    // Bottom sheet closes and city field displays 'Hà Nội'
    expect(find.text('Hà Nội'), findsOneWidget);
    expect(find.text('Chọn Tỉnh / Thành phố hoạt động'), findsNothing);
  });

  testWidgets('Category field has NO default selection and opens Bottom Sheet Modal to select', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Initial placeholder: no default category is pre-selected
    expect(find.text('Chọn lĩnh vực cung cấp chính'), findsOneWidget);

    // Scroll to category picker field and tap
    final categoryField = find.byKey(const Key('category_picker_field'));
    await tester.ensureVisible(categoryField);
    await tester.tap(categoryField);
    await tester.pumpAndSettle();

    // Bottom sheet is shown
    expect(find.text('Chọn lĩnh vực cung cấp chính'), findsWidgets);
    expect(find.text('Chọn ngành hàng thực phẩm / nguyên liệu chủ lực'), findsOneWidget);
    expect(find.text('Nguyên liệu tươi sống & Nông sản'), findsOneWidget);
    expect(find.text('Thịt, Gia cầm & Thủy hải sản'), findsOneWidget);

    // Tap on 'Thịt, Gia cầm & Thủy hải sản' (category_item_1)
    await tester.tap(find.byKey(const Key('category_item_1')));
    await tester.pumpAndSettle();

    // Bottom sheet closes and category field displays 'Thịt, Gia cầm & Thủy hải sản'
    expect(find.text('Thịt, Gia cầm & Thủy hải sản'), findsOneWidget);
    expect(find.text('Chọn lĩnh vực cung cấp chính'), findsNothing);
  });

  testWidgets('Confirm button is in AppBar and is disabled until all required fields are filled', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Confirm button in header
    final confirmButtonFinder = find.byKey(const Key('store_setup_confirm_button'));
    expect(confirmButtonFinder, findsOneWidget);
    expect(find.text('Xác nhận'), findsOneWidget);

    // The old bottom button should not exist
    expect(find.text('Hoàn tất & Kích hoạt gian hàng'), findsNothing);

    // Initially disabled because city, category, store name, address are incomplete
    TextButton confirmButton = tester.widget<TextButton>(confirmButtonFinder);
    expect(confirmButton.onPressed, isNull);

    // Fill store name
    final storeNameFinder = find.widgetWithText(TextFormField, 'Tên gian hàng / Nhà cung cấp *');
    await tester.enterText(
      find.descendant(of: storeNameFinder, matching: find.byType(TextField)),
      'Nông Sản Sạch Đà Lạt',
    );
    await tester.pump();

    // Fill owner name
    final ownerNameFinder = find.widgetWithText(TextFormField, 'Họ và tên người đại diện *');
    await tester.enterText(
      find.descendant(of: ownerNameFinder, matching: find.byType(TextField)),
      'Trần Văn B',
    );
    await tester.pump();

    // Fill address
    final addressFinder = find.widgetWithText(TextFormField, 'Địa chỉ kho hàng / Trụ sở *');
    await tester.enterText(
      find.descendant(of: addressFinder, matching: find.byType(TextField)),
      '123 Đường Rau Quả, P.1, Đà Lạt',
    );
    await tester.pump();

    // Still disabled because City and Category are not chosen yet
    confirmButton = tester.widget<TextButton>(confirmButtonFinder);
    expect(confirmButton.onPressed, isNull);

    // Select City
    final cityField = find.byKey(const Key('city_picker_field'));
    await tester.ensureVisible(cityField);
    await tester.tap(cityField);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('city_item_0'))); // Hồ Chí Minh
    await tester.pumpAndSettle();

    // Still disabled because Category is not chosen yet
    confirmButton = tester.widget<TextButton>(confirmButtonFinder);
    expect(confirmButton.onPressed, isNull);

    // Select Category
    final categoryField = find.byKey(const Key('category_picker_field'));
    await tester.ensureVisible(categoryField);
    await tester.tap(categoryField);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('category_item_0'))); // Nguyên liệu tươi sống & Nông sản
    await tester.pumpAndSettle();

    // Now all required fields are filled -> Confirm button is active!
    confirmButton = tester.widget<TextButton>(confirmButtonFinder);
    expect(confirmButton.onPressed, isNotNull);
  });
}
