import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/recipe/data/models/comment_item.dart';

void main() {
  group('CommentItem Tests', () {
    test('CommentItem parses from json correctly', () {
      final json = {
        'commentId': 'cmt_123',
        'postId': 'post_456',
        'userId': 'user_789',
        'username': 'cheflong',
        'displayName': 'Chef Long',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'content': 'Món ăn trông ngon quá!',
        'likes': 12,
        'isLiked': true,
        'createdAt': '2026-10-30T10:00:00Z',
      };

      final comment = CommentItem.fromJson(json);

      expect(comment.commentId, 'cmt_123');
      expect(comment.postId, 'post_456');
      expect(comment.userId, 'user_789');
      expect(comment.username, 'cheflong');
      expect(comment.displayName, 'Chef Long');
      expect(comment.avatarUrl, 'https://example.com/avatar.jpg');
      expect(comment.content, 'Món ăn trông ngon quá!');
      expect(comment.likes, 12);
      expect(comment.isLiked, true);
    });

    test('CommentItem serializes to json correctly', () {
      final now = DateTime.now();
      final comment = CommentItem(
        commentId: 'c1',
        postId: 'p1',
        userId: 'u1',
        username: 'lananh',
        content: 'Tuyệt vời',
        likes: 5,
        isLiked: false,
        createdAt: now,
      );

      final json = comment.toJson();
      expect(json['commentId'], 'c1');
      expect(json['postId'], 'p1');
      expect(json['username'], 'lananh');
      expect(json['content'], 'Tuyệt vời');
      expect(json['likes'], 5);
      expect(json['isLiked'], false);
    });

    test('CommentItem timeAgo returns human readable Vietnamese formats', () {
      final justNow = CommentItem(
        commentId: 'c1',
        postId: 'p1',
        userId: 'u1',
        username: 'test',
        content: 'test',
        createdAt: DateTime.now().subtract(const Duration(seconds: 10)),
      );
      expect(justNow.timeAgo, 'Vừa xong');

      final minutesAgo = CommentItem(
        commentId: 'c2',
        postId: 'p1',
        userId: 'u1',
        username: 'test',
        content: 'test',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      );
      expect(minutesAgo.timeAgo, '15 phút trước');

      final hoursAgo = CommentItem(
        commentId: 'c3',
        postId: 'p1',
        userId: 'u1',
        username: 'test',
        content: 'test',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      );
      expect(hoursAgo.timeAgo, '3 giờ trước');
    });

    test('CommentItem copyWith creates modified instance', () {
      final comment = CommentItem(
        commentId: 'c1',
        postId: 'p1',
        userId: 'u1',
        username: 'user1',
        content: 'Hello',
        likes: 0,
        isLiked: false,
        createdAt: DateTime.now(),
      );

      final updated = comment.copyWith(
        isLiked: true,
        likes: 1,
      );

      expect(updated.isLiked, true);
      expect(updated.likes, 1);
      expect(updated.commentId, 'c1');
      expect(updated.content, 'Hello');
    });
  });
}
