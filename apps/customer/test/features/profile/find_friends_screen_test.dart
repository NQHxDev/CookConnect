import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/profile/presentation/pages/find_friends_screen.dart';

void main() {
  testWidgets('FindFriendsScreen renders with Appbar and blank body',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FindFriendsScreen(),
      ),
    );

    expect(find.text('Tìm bạn bè'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
