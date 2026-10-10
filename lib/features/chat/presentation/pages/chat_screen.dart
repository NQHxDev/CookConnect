import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/activity/presentation/pages/activity_screen.dart';
import 'package:cookconnect/features/chat/presentation/pages/chat_detail_screen.dart';
import 'package:cookconnect/features/notification/presentation/pages/system_notification_screen.dart';

class StoryItem {
  final String name;
  final String? avatarUrl;
  final Color avatarBgColor;
  final bool hasUnseenStory;
  final bool isOnline;

  const StoryItem({
    required this.name,
    this.avatarUrl,
    required this.avatarBgColor,
    this.hasUnseenStory = true,
    this.isOnline = false,
  });
}

class ChatConversationItem {
  final String name;
  final Color avatarBgColor;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isLastMessageFromMe;

  const ChatConversationItem({
    required this.name,
    required this.avatarBgColor,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isLastMessageFromMe = false,
  });
}

class SuggestedAccountItem {
  final String name;
  final String username;
  final String reason;
  final Color avatarBgColor;
  bool isFollowing;

  SuggestedAccountItem({
    required this.name,
    required this.username,
    required this.reason,
    required this.avatarBgColor,
    this.isFollowing = false,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<StoryItem> _mockStories = const [
    StoryItem(
      name: 'Chef Nam',
      avatarBgColor: Color(0xFFFFB74D),
      hasUnseenStory: true,
      isOnline: true,
    ),
    StoryItem(
      name: 'Mai Anh',
      avatarBgColor: Color(0xFF81C784),
      hasUnseenStory: true,
      isOnline: false,
    ),
    StoryItem(
      name: 'Bếp Mẹ Làm',
      avatarBgColor: Color(0xFFE57373),
      hasUnseenStory: true,
      isOnline: true,
    ),
    StoryItem(
      name: 'Hoàng Long',
      avatarBgColor: Color(0xFF64B5F6),
      hasUnseenStory: false,
      isOnline: false,
    ),
    StoryItem(
      name: 'Thu Trang',
      avatarBgColor: Color(0xFFBA68C8),
      hasUnseenStory: true,
      isOnline: true,
    ),
    StoryItem(
      name: 'Chef Hùng',
      avatarBgColor: Color(0xFFFFD54F),
      hasUnseenStory: false,
      isOnline: false,
    ),
    StoryItem(
      name: 'Linh Chi',
      avatarBgColor: Color(0xFF4DB6AC),
      hasUnseenStory: true,
      isOnline: false,
    ),
  ];

  // 3 cuộc trò chuyện tin nhắn gần đây
  final List<ChatConversationItem> _mockConversations = const [
    ChatConversationItem(
      name: 'Chef Linh',
      avatarBgColor: Color(0xFFFB923C),
      lastMessage: 'Chào bạn! Mình thấy công thức Bò Sốt Vang của bạn ngon quá!',
      time: '10:30',
      unreadCount: 2,
      isOnline: true,
      isLastMessageFromMe: false,
    ),
    ChatConversationItem(
      name: 'Chef Nam',
      avatarBgColor: Color(0xFFFFB74D),
      lastMessage: 'Cuối tuần này mình sẽ lên bài hướng dẫn chi tiết nhé!',
      time: '09:45',
      unreadCount: 0,
      isOnline: true,
      isLastMessageFromMe: true,
    ),
    ChatConversationItem(
      name: 'Bếp Mẹ Làm',
      avatarBgColor: Color(0xFFE57373),
      lastMessage: 'Công thức nước sốt salad này bảo quản được mấy ngày vậy bạn?',
      time: 'Hôm qua',
      unreadCount: 1,
      isOnline: true,
      isLastMessageFromMe: false,
    ),
  ];

  // Danh sách tài khoản được đề xuất (Suggested Accounts)
  late List<SuggestedAccountItem> _suggestedAccounts;

  @override
  void initState() {
    super.initState();
    _suggestedAccounts = [
      SuggestedAccountItem(
        name: 'Mai Anh',
        username: '@maianh_baking',
        reason: 'Có 15 người theo dõi chung',
        avatarBgColor: const Color(0xFF81C784),
        isFollowing: false,
      ),
      SuggestedAccountItem(
        name: 'Hoàng Long',
        username: '@long_chefhouse',
        reason: 'Gợi ý cho bạn • Đầu bếp món Âu',
        avatarBgColor: const Color(0xFF64B5F6),
        isFollowing: false,
      ),
      SuggestedAccountItem(
        name: 'Chef Hùng',
        username: '@hung_masterchef',
        reason: 'Theo dõi bởi Chef Nam',
        avatarBgColor: const Color(0xFFFFD54F),
        isFollowing: false,
      ),
      SuggestedAccountItem(
        name: 'Thu Trang',
        username: '@trang_healthyfood',
        reason: 'Phổ biến trong Ẩm thực Healthy',
        avatarBgColor: const Color(0xFFBA68C8),
        isFollowing: false,
      ),
      SuggestedAccountItem(
        name: 'Linh Chi',
        username: '@linhchi_pastry',
        reason: 'Từ danh bạ của bạn',
        avatarBgColor: const Color(0xFF4DB6AC),
        isFollowing: false,
      ),
    ];
  }

  Future<void> _handleRefresh() async {
    // Mock 2s network load time
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {});
    }
  }

  void _showSuggestedAccountsExplanation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final primaryColor = Theme.of(context).colorScheme.primary;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tài khoản được đề xuất',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Các tài khoản này được đề xuất dựa trên sở thích ẩm thực, các kết nối bạn bè chung, hoạt động tương tác gần đây, danh bạ hoặc những đầu bếp nổi bật mà bạn có thể quen biết trên CookConnect.',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Đã hiểu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.group_add_outlined),
          onPressed: () {},
        ),
        title: const Text(
          'Hộp thư',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal_1, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Cupertino-style Pull-to-refresh: đẩy danh sách tin xuống nhường chỗ cho spinner ở trên
          CupertinoSliverRefreshControl(
            onRefresh: _handleRefresh,
            builder: (
              BuildContext context,
              RefreshIndicatorMode refreshState,
              double pulledExtent,
              double refreshTriggerPullDistance,
              double refreshIndicatorExtent,
            ) {
              final double percentageComplete =
                  (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);

              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: (refreshState == RefreshIndicatorMode.refresh ||
                          refreshState == RefreshIndicatorMode.armed)
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        )
                      : Opacity(
                          opacity: percentageComplete,
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              value: percentageComplete > 0.1 ? percentageComplete : null,
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
          // Danh sách Tin / Story của bạn bè & người đã follow
          SliverToBoxAdapter(
            child: _buildStoriesSection(context),
          ),
          // Mục thông báo chung (Hoạt động & Follower mới)
          SliverToBoxAdapter(
            child: _buildNotificationTile(
              context: context,
              icon: Iconsax.notification,
              iconBgColor: const Color(0xFFEF4444),
              title: 'Hoạt động mới',
              subtitle: 'Follower mới, lượt thích, bình luận và nhắc đến',
              hasUnread: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ActivityScreen(),
                  ),
                );
              },
            ),
          ),
          // Mục Thông báo hệ thống
          SliverToBoxAdapter(
            child: _buildNotificationTile(
              context: context,
              icon: Iconsax.message_text,
              iconBgColor: Colors.black87,
              title: 'Thông báo hệ thống',
              subtitle: 'Cập nhật ứng dụng, chính sách và tin từ CookConnect',
              hasUnread: false,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SystemNotificationScreen(),
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 6),
          ),
          // Tiêu đề danh sách Tin nhắn
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Tin nhắn',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // Danh sách 3 tin nhắn cuộc trò chuyện
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _mockConversations[index];
                return _buildChatItem(context, item);
              },
              childCount: _mockConversations.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 12),
          ),
          // Tiêu đề phần Tài khoản được đề xuất + Icon hỏi chấm
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'Tài khoản được đề xuất',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _showSuggestedAccountsExplanation(context),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 17,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Danh sách tài khoản được đề xuất
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final account = _suggestedAccounts[index];
                return _buildSuggestedAccountTile(context, account, index, primaryColor);
              },
              childCount: _suggestedAccounts.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedAccountTile(
    BuildContext context,
    SuggestedAccountItem account,
    int index,
    Color primaryColor,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 4, top: 2, bottom: 2),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: account.avatarBgColor,
        child: Text(
          account.name.characters.first,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        account.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
        ),
      ),
      subtitle: Text(
        account.reason,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12.5,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  account.isFollowing = !account.isFollowing;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: account.isFollowing
                    ? const Color(0xFFF3F4F6)
                    : primaryColor,
                foregroundColor: account.isFollowing
                    ? Colors.black87
                    : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                account.isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: Colors.grey.shade400),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            onPressed: () {
              setState(() {
                _suggestedAccounts.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesSection(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      height: 94,
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _mockStories.length + 1, // +1 cho "Tạo tin"
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCreateStoryItem(context, primaryColor);
          }
          final story = _mockStories[index - 1];
          return _buildFriendStoryItem(context, story, primaryColor);
        },
      ),
    );
  }

  Widget _buildCreateStoryItem(BuildContext context, Color primaryColor) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(
                    Iconsax.user,
                    color: Colors.grey.shade500,
                    size: 24,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Tạo tin',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendStoryItem(
    BuildContext context,
    StoryItem story,
    Color primaryColor,
  ) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: story.hasUnseenStory
                        ? LinearGradient(
                            colors: [
                              primaryColor,
                              Colors.pinkAccent.shade400,
                              Colors.orangeAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: !story.hasUnseenStory
                        ? Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundColor: story.avatarBgColor,
                      child: Text(
                        story.name.characters.first,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                if (story.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              story.name,
              style: TextStyle(
                fontSize: 12,
                color: story.hasUnseenStory
                    ? Colors.black87
                    : Colors.grey.shade600,
                fontWeight: story.hasUnseenStory
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool hasUnread,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      visualDensity: const VisualDensity(vertical: -1),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconBgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasUnread)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatConversationItem item) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              name: item.name,
              avatarBgColor: item.avatarBgColor,
              isOnline: item.isOnline,
            ),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: item.avatarBgColor,
            child: Text(
              item.name.characters.first,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (item.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        item.name,
        style: TextStyle(
          fontWeight: item.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        item.isLastMessageFromMe ? 'Bạn: ${item.lastMessage}' : item.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: item.unreadCount > 0 ? Colors.black87 : Colors.grey[600],
          fontWeight: item.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13.5,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            item.time,
            style: TextStyle(
              fontSize: 12,
              color: item.unreadCount > 0
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[500],
              fontWeight:
                  item.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (item.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${item.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
