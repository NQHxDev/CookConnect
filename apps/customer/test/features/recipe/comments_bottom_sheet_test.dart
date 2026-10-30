import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/recipe/data/models/comment_item.dart';
import 'package:cookconnect/features/recipe/data/models/post_item.dart';
import 'package:cookconnect/features/recipe/data/services/comment_service.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/comments_bottom_sheet.dart';

void main() {
  group('CommentsBottomSheet Widget Tests', () {
    late PostItem testPost;

    setUp(() {
      testPost = PostItem(
        postId: 'test_post_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'author_123',
        title: 'Món Bò Kho Tiêu',
        videoUrl: 'https://example.com/video.mp4',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        duration: 45,
        commentCount: 0,
        allowComments: true,
      );
      CommentService.instance.setCachedComments(testPost.postId, []);
    });

    testWidgets(
        'Renders empty state when post has no comments and NO placeholder comments',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentsBottomSheet(
              post: testPost,
            ),
          ),
        ),
      );

      // Pump through async init
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Confirms old hardcoded mock comments are completely removed
      expect(find.text('foodlover99'), findsNothing);
      expect(find.text('chefmaster'), findsNothing);
      expect(find.text('cooking_enthusiast'), findsNothing);

      // Confirms modern empty state is displayed
      expect(find.text('Chưa có bình luận nào'), findsOneWidget);
      expect(
        find.text('Hãy là người đầu tiên để lại bình luận cho video này!'),
        findsOneWidget,
      );
      expect(find.text('0 bình luận'), findsOneWidget);
    });

    testWidgets('Allows typing and adding a real comment', (tester) async {
      int? updatedCount;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentsBottomSheet(
              post: testPost,
              onCommentCountChanged: (count) {
                updatedCount = count;
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the TextField and enter comment text
      final inputField = find.byType(TextField);
      expect(inputField, findsOneWidget);

      await tester.enterText(
          inputField, 'Món này nhìn hấp dẫn quá, xin công thức!');
      await tester.pump();

      // Send button should be enabled and tappable
      final sendButton = find.byIcon(Iconsax.send_2);
      expect(sendButton, findsOneWidget);

      await tester.tap(sendButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Confirms comment is displayed in list and empty state disappears
      expect(
          find.text('Món này nhìn hấp dẫn quá, xin công thức!'), findsOneWidget);
      expect(find.text('Chưa có bình luận nào'), findsNothing);
      expect(find.text('1 bình luận'), findsOneWidget);
      expect(updatedCount, 1);
    });

    testWidgets('Displays lock message when comments are disabled for post',
        (tester) async {
      final disabledPost = PostItem(
        postId: 'disabled_post_123',
        userId: 'author_123',
        title: 'Món Bò Kho Tiêu',
        videoUrl: 'https://example.com/video.mp4',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        duration: 45,
        commentCount: 0,
        allowComments: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentsBottomSheet(
              post: disabledPost,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Confirms disabled message and no input text field
      expect(
        find.text('Tác giả đã tắt tính năng bình luận cho bài viết này'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNothing);
    });
  });
}
