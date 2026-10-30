import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/recipe/data/models/comment_item.dart';
import 'package:cookconnect/features/recipe/data/models/post_item.dart';
import 'package:cookconnect/features/recipe/data/services/comment_service.dart';

class CommentsBottomSheet extends StatefulWidget {
  final PostItem post;
  final ValueChanged<int>? onCommentCountChanged;

  const CommentsBottomSheet({
    super.key,
    required this.post,
    this.onCommentCountChanged,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<CommentItem> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _replyingTo;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _commentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final items = await CommentService.instance.getComments(widget.post.postId);
      if (mounted) {
        setState(() {
          _comments = items;
          _isLoading = false;
        });
        widget.onCommentCountChanged?.call(_comments.length);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleLike(int index) async {
    final comment = _comments[index];
    final newIsLiked = !comment.isLiked;
    final newLikes = comment.likes + (newIsLiked ? 1 : -1);

    setState(() {
      _comments[index] = comment.copyWith(
        isLiked: newIsLiked,
        likes: newLikes < 0 ? 0 : newLikes,
      );
    });

    await CommentService.instance.toggleLike(
      postId: widget.post.postId,
      commentId: comment.commentId,
    );
  }

  Future<void> _handleSendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    final commentText = _replyingTo != null ? '@$_replyingTo $text' : text;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final newComment = await CommentService.instance.addComment(
        postId: widget.post.postId,
        content: commentText,
      );

      if (mounted) {
        setState(() {
          _comments.insert(0, newComment);
          _commentController.clear();
          _replyingTo = null;
          _isSubmitting = false;
        });

        widget.onCommentCountChanged?.call(_comments.length);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể gửi bình luận lúc này. Vui lòng thử lại!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _startReply(String username) {
    setState(() {
      _replyingTo = username;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;
    final allowComments = widget.post.allowComments;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_comments.length} bình luận',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Comments body
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  )
                : _comments.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return _buildCommentItem(_comments[index], index);
                        },
                      ),
          ),

          // Replying banner
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.withValues(alpha: 0.08),
              child: Row(
                children: [
                  const Icon(Iconsax.undo, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đang trả lời @$_replyingTo',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: const Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),

          // Comment input or disabled message
          if (!allowComments)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.lock, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Tác giả đã tắt tính năng bình luận cho bài viết này',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: Row(
                children: [
                  // Current user avatar
                  _buildUserAvatar(
                    avatarUrl: currentUser?.avatar,
                    size: 36,
                    fallbackInitial: currentUser?.fullName.isNotEmpty == true
                        ? currentUser!.fullName[0]
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Input field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _commentController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: _replyingTo != null
                              ? 'Trả lời @$_replyingTo...'
                              : 'Thêm bình luận...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSendComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send button
                  if (_isSubmitting)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Iconsax.send_2,
                        color: _commentController.text.trim().isEmpty
                            ? Colors.grey[400]
                            : Colors.orange,
                        size: 22,
                      ),
                      onPressed: _commentController.text.trim().isEmpty
                          ? null
                          : _handleSendComment,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Iconsax.message_text,
                size: 36,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có bình luận nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hãy là người đầu tiên để lại bình luận cho video này!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(CommentItem comment, int index) {
    final currentUserId = AuthService.instance.currentUser?.id ??
        AuthService.instance.currentUser?.userId;
    final isMe = currentUserId != null && currentUserId == comment.userId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Avatar
          _buildUserAvatar(
            avatarUrl: comment.avatarUrl,
            size: 38,
            fallbackInitial: comment.displayName?.isNotEmpty == true
                ? comment.displayName![0]
                : (comment.username.isNotEmpty ? comment.username[0] : null),
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username + Author tag if me
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.displayName?.isNotEmpty == true
                            ? comment.displayName!
                            : comment.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Bạn',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Comment text
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Footer: Time, likes count, reply
                Row(
                  children: [
                    Text(
                      comment.timeAgo,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    if (comment.likes > 0) ...[
                      const SizedBox(width: 14),
                      Text(
                        '${comment.likes} lượt thích',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: () => _startReply(
                        comment.displayName?.isNotEmpty == true
                            ? comment.displayName!
                            : comment.username,
                      ),
                      child: Text(
                        'Trả lời',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Heart like button
          IconButton(
            icon: Icon(
              comment.isLiked ? Iconsax.heart5 : Iconsax.heart,
              color: comment.isLiked ? Colors.red : Colors.grey[400],
              size: 18,
            ),
            onPressed: () => _toggleLike(index),
            padding: const EdgeInsets.only(left: 8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar({
    String? avatarUrl,
    required double size,
    String? fallbackInitial,
  }) {
    final hasValidUrl = avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'));

    if (hasValidUrl) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallbackAvatar(size, fallbackInitial),
        ),
      );
    }

    return _buildFallbackAvatar(size, fallbackInitial);
  }

  Widget _buildFallbackAvatar(double size, String? initial) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      alignment: Alignment.center,
      child: initial != null
          ? Text(
              initial.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: size * 0.42,
                color: Colors.grey[700],
              ),
            )
          : Icon(
              Iconsax.user,
              size: size * 0.55,
              color: Colors.grey[500],
            ),
    );
  }
}

void showCommentsBottomSheet(
  BuildContext context, {
  required PostItem post,
  ValueChanged<int>? onCommentCountChanged,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CommentsBottomSheet(
      post: post,
      onCommentCountChanged: onCommentCountChanged,
    ),
  );
}
