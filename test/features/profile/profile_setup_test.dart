import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/auth/data/models/auth_user.dart';
import 'package:cookconnect/features/auth/data/models/auth_tokens.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/profile/presentation/widgets/profile_setup_dialog.dart';

void main() {
  setUp(() {
    AuthService.instance.setGuestDemo(
      name: 'Chef Minh Quân',
      email: 'minhquan@cookconnect.app',
    );
  });

  tearDown(() {
    AuthService.instance.logout();
  });

  testWidgets(
    'ProfileSetupDialog renders all profile fields and updates user correctly',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProfileSetupDialog(isFirstTime: true)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dialog title and fields
      expect(find.text('Hoàn tất hồ sơ Chef'), findsOneWidget);
      expect(find.text('Họ và tên / Tên hiển thị'), findsOneWidget);
      expect(find.text('Tên người dùng'), findsOneWidget);
      expect(find.text('Giới tính'), findsOneWidget);
      expect(find.text('Ngày sinh'), findsOneWidget);
      expect(find.text('Tiểu sử giới thiệu (Bio)'), findsOneWidget);

      // Enter full name
      final nameField = find.widgetWithText(TextFormField, 'Chef Minh Quân');
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, 'Nguyễn Minh Quân');
      await tester.pumpAndSettle();

      // Select Gender "Nam"
      await tester.tap(find.text('Nam'));
      await tester.pumpAndSettle();

      // Tap Save button
      await tester.tap(find.text('Hoàn tất & Bắt đầu'));
      await tester.pumpAndSettle();

      // Verify AuthService updated
      expect(AuthService.instance.currentUser?.fullName, 'Nguyễn Minh Quân');
      expect(AuthService.instance.currentUser?.gender, 'MALE');
    },
  );

  testWidgets(
    'ProfileSetupScreen has no Skip button and PopScope prevents pop',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileSetupScreen(isFirstTime: true),
        ),
      );
      await tester.pumpAndSettle();

      // Verify NO skip / "Để sau" button
      expect(find.text('Để sau'), findsNothing);

      // Verify PopScope has canPop == false
      final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
      expect(popScopeFinder, findsOneWidget);
      final PopScope popScope = tester.widget(popScopeFinder);
      expect(popScope.canPop, isFalse);
    },
  );

  testWidgets(
    'ProfileSetupScreen enforces mandatory fields and validations for name, username and date of birth',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Set user without date of birth and empty name
      AuthService.instance.setSession(
        user: AuthUser(
          id: 'fresh-user-1',
          email: '',
          fullName: '',
          username: '',
          dateOfBirth: null,
        ),
        tokens: AuthTokens(accessToken: 'mock-token', refreshToken: 'mock-refresh'),
      );

      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileSetupScreen(
            onComplete: () {
              completed = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap submit with empty inputs
      await tester.tap(find.text('Hoàn tất & Bắt đầu'));
      await tester.pumpAndSettle();

      // Verify validations triggered
      expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
      expect(find.text('Vui lòng nhập username'), findsOneWidget);
      expect(find.text('Vui lòng chọn ngày sinh của bạn'), findsOneWidget);
      expect(completed, isFalse);

      // Enter short name (<2 chars) and short username (<3 chars)
      final nameField = find.byType(TextFormField).at(0);
      final usernameField = find.byType(TextFormField).at(1);
      await tester.enterText(nameField, 'A');
      await tester.enterText(usernameField, 'ab');
      await tester.tap(find.text('Hoàn tất & Bắt đầu'));
      await tester.pumpAndSettle();

      expect(find.text('Họ và tên phải có ít nhất 2 ký tự'), findsOneWidget);
      expect(find.text('Username tối thiểu 3 ký tự'), findsOneWidget);
      expect(completed, isFalse);

      // Enter invalid username with spaces/special characters
      await tester.enterText(usernameField, 'bad user@name');
      await tester.tap(find.text('Hoàn tất & Bắt đầu'));
      await tester.pumpAndSettle();
      expect(
        find.text('Username chỉ được chứa chữ cái, chữ số và dấu gạch dưới (_)'),
        findsOneWidget,
      );

      // Enter valid name and username
      await tester.enterText(nameField, 'Trần Minh Tuấn');
      await tester.enterText(usernameField, 'minhtuan_chef');
      await tester.tap(find.text('Hoàn tất & Bắt đầu'));
      await tester.pumpAndSettle();

      // Date of birth is still required!
      expect(find.text('Vui lòng chọn ngày sinh của bạn'), findsOneWidget);
      expect(completed, isFalse);

      // Pick date of birth
      await tester.tap(find.text('Chọn ngày sinh của bạn...'));
      await tester.pumpAndSettle();

      // Confirm date picker dialog
      expect(find.text('Xác nhận'), findsOneWidget);
      await tester.tap(find.text('Xác nhận'));
      await tester.pumpAndSettle();

      // Date error should now be gone
      expect(find.text('Vui lòng chọn ngày sinh của bạn'), findsNothing);

      // Tap submit button again
      await tester.tap(find.text('Hoàn tất & Bắt đầu'));
      await tester.pumpAndSettle();

      // Verify callback succeeded and AuthService updated
      expect(completed, isTrue);
      expect(AuthService.instance.currentUser?.fullName, 'Trần Minh Tuấn');
      expect(AuthService.instance.currentUser?.username, 'minhtuan_chef');
      expect(AuthService.instance.currentUser?.dateOfBirth, isNotNull);
    },
  );
}
