import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CommentsBottomSheet extends StatefulWidget {
  const CommentsBottomSheet({super.key});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Placeholder comments data
  final List<Map<String, dynamic>> _comments = [
    {
      'username': 'foodlover99',
      'avatar': Colors.blue,
      'comment': 'This looks absolutely delicious! 😍',
      'likes': 234,
      'time': '2h ago',
      'isLiked': false,
    },
    {
      'username': 'chefmaster',
      'avatar': Colors.orange,
      'comment': 'Great technique! What temperature did you use?',
      'likes': 89,
      'time': '5h ago',
      'isLiked': false,
    },
    {
      'username': 'cooking_enthusiast',
      'avatar': Colors.purple,
      'comment':
          'I tried this recipe yesterday and it turned out amazing! Thank you for sharing 🙏',
      'likes': 156,
      'time': '1d ago',
      'isLiked': true,
    },
    {
      'username': 'pasta_lover',
      'avatar': Colors.pink,
      'comment': 'Can I substitute the ingredients?',
      'likes': 45,
      'time': '1d ago',
      'isLiked': false,
    },
    {
      'username': 'homecook_daily',
      'avatar': Colors.teal,
      'comment': 'Perfect for dinner tonight! 🍝',
      'likes': 67,
      'time': '2d ago',
      'isLiked': false,
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleLike(int index) {
    setState(() {
      _comments[index]['isLiked'] = !_comments[index]['isLiked'];
      if (_comments[index]['isLiked']) {
        _comments[index]['likes']++;
      } else {
        _comments[index]['likes']--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          // Comments list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return _buildCommentItem(_comments[index], index);
              },
            ),
          ),
          // Comment input
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
                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: const Icon(
                    Iconsax.user,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                // Input field
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Thêm bình luận...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        // TODO: Handle send comment
                        _commentController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                IconButton(
                  icon: Icon(
                    Iconsax.send_2,
                    color: _commentController.text.isEmpty
                        ? Colors.grey[400]
                        : Colors.orange,
                  ),
                  onPressed: () {
                    if (_commentController.text.trim().isNotEmpty) {
                      // TODO: Handle send comment
                      _commentController.clear();
                      setState(() {});
                    }
                  },
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

  Widget _buildCommentItem(Map<String, dynamic> comment, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: comment['avatar'],
            ),
            child: const Icon(Iconsax.user, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                Text(
                  comment['username'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // Comment text
                Text(comment['comment'], style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                // Time and reply
                Row(
                  children: [
                    Text(
                      comment['time'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${comment['likes']} lượt thích',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Trả lời',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Like button
          IconButton(
            icon: Icon(
              comment['isLiked'] ? Iconsax.heart5 : Iconsax.heart,
              color: comment['isLiked'] ? Colors.red : Colors.grey[600],
              size: 20,
            ),
            onPressed: () => _toggleLike(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

void showCommentsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CommentsBottomSheet(),
  );
}
