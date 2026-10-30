class CommentItem {
  final String commentId;
  final String postId;
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String content;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;

  const CommentItem({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.content,
    this.likes = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  CommentItem copyWith({
    String? commentId,
    String? postId,
    String? userId,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? content,
    int? likes,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return CommentItem(
      commentId: commentId ?? this.commentId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    return CommentItem(
      commentId: json['commentId']?.toString() ?? json['id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? 'Người dùng',
      displayName:
          json['displayName']?.toString() ?? json['fullName']?.toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar']?.toString(),
      content: json['content']?.toString() ?? json['comment']?.toString() ?? '',
      likes:
          (json['likes'] as num?)?.toInt() ??
          (json['likeCount'] as num?)?.toInt() ??
          0,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'content': content,
      'likes': likes,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 45) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} tuần trước';
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }
}
