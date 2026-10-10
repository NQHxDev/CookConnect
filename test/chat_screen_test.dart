import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/screens/chat_screen.dart';
import 'package:cookconnect/screens/chat_detail_screen.dart';
import 'package:cookconnect/screens/activity_screen.dart';
import 'package:cookconnect/screens/system_notification_screen.dart';

void main() {
  testWidgets('ChatScreen renders header, stories list with "Tạo tin" and friends', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Verify leading icon (2 people with plus: group_add_outlined)
    expect(find.byIcon(Icons.group_add_outlined), findsOneWidget);

    // Verify title text 'Hộp thư'
    expect(find.text('Hộp thư'), findsOneWidget);

    // Verify search action icon
    expect(find.byIcon(Iconsax.search_normal_1), findsOneWidget);

    // Verify "Tạo tin" story item
    expect(find.text('Tạo tin'), findsOneWidget);

    // Verify stories
    expect(find.text('Chef Nam'), findsWidgets);
  });

  testWidgets('ChatScreen renders 3 direct messages and suggested accounts section with question mark modal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Verify 3 chat conversations
    expect(find.text('Chef Linh'), findsOneWidget);
    expect(find.text('Chef Nam'), findsWidgets);
    expect(find.text('Bếp Mẹ Làm'), findsWidgets);

    // Verify suggested accounts header and question mark icon
    expect(find.text('Tài khoản được đề xuất'), findsOneWidget);
    expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);

    // Tap question mark icon to show explanation modal
    await tester.tap(find.byIcon(Icons.help_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Đã hiểu'), findsOneWidget);
    expect(find.textContaining('Các tài khoản này được đề xuất dựa trên sở thích'), findsOneWidget);

    // Tap "Đã hiểu" to close modal
    await tester.tap(find.text('Đã hiểu'));
    await tester.pumpAndSettle();

    // Verify suggested account follow button toggle
    final followButtons = find.widgetWithText(ElevatedButton, 'Theo dõi');
    expect(followButtons, findsWidgets);

    await tester.ensureVisible(followButtons.first);
    await tester.pumpAndSettle();

    await tester.tap(followButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('Đang theo dõi'), findsOneWidget);
  });

  testWidgets('ChatScreen supports pull-to-refresh pushing content down', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Trigger pull down
    await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('ChatScreen navigates to ChatDetailScreen and allows sending a message', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Tap on Chef Linh conversation
    await tester.tap(find.text('Chef Linh'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatDetailScreen), findsOneWidget);
    expect(find.text('Chào bạn! Mình thấy công thức Bò Sốt Vang của bạn trên CookConnect ngon quá!'), findsOneWidget);

    // Send a message
    final inputField = find.widgetWithText(TextField, 'Nhắn tin...');
    expect(inputField, findsOneWidget);

    await tester.enterText(inputField, 'Chào bạn nha, chúc bạn nấu thành công!');
    await tester.tap(find.byIcon(Iconsax.send_1));
    await tester.pumpAndSettle();

    expect(find.text('Chào bạn nha, chúc bạn nấu thành công!'), findsOneWidget);
  });

  testWidgets('ChatScreen navigates to ActivityScreen and SystemNotificationScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Tap on Hoạt động mới
    await tester.tap(find.text('Hoạt động mới'));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityScreen), findsOneWidget);

    // Go back
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Tap on Thông báo hệ thống
    await tester.tap(find.text('Thông báo hệ thống'));
    await tester.pumpAndSettle();

    expect(find.byType(SystemNotificationScreen), findsOneWidget);
  });
}
