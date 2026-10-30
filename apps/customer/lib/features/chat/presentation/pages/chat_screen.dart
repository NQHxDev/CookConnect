import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/features/profile/presentation/pages/other_user_profile_screen.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/activity/presentation/pages/activity_screen.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/auth/presentation/pages/login_screen.dart';
import 'package:cookconnect/features/auth/presentation/pages/register_email_screen.dart';
import 'package:cookconnect/features/chat/data/models/user_suggestion.dart';
import 'package:cookconnect/features/chat/data/services/chat_api_service.dart';
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
  final String id;
  final String name;
  final String username;
  final String reason;
  final String? avatar;
  final Color avatarBgColor;
  bool isFollowing;

  SuggestedAccountItem({
    required this.id,
    required this.name,
    required this.username,
    required this.reason,
    this.avatar,
    required this.avatarBgColor,
    this.isFollowing = false,
  });
}

class ChatScreen extends StatefulWidget {
  final ChatApiService? chatApiService;

  const ChatScreen({super.key, this.chatApiService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatApiService _chatApiService;
  late final ScrollController _scrollController;

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
  final List<SuggestedAccountItem> _suggestedAccounts = [];
  bool _isLoadingSuggestions = false;
  bool _isLoadingMore = false;
  bool _hasMoreSuggestions = true;

  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _chatApiService = widget.chatApiService ?? ChatApiService();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Listen to auth state changes to rebuild UI when login/logout happens
    AuthService.instance.addListener(_onAuthChanged);

    _loadInitialSuggestions();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // Remove auth listener to prevent memory leaks
    AuthService.instance.removeListener(_onAuthChanged);

    super.dispose();
  }

  /// Callback when auth state changes (login/logout)
  void _onAuthChanged() {
    if (mounted) {
      setState(() {
        // Rebuild entire widget tree with new auth state
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Trigger when user scrolls within 200px of bottom
    if (maxScroll - currentScroll <= 200) {
      if (!_isLoadingSuggestions && !_isLoadingMore && _hasMoreSuggestions) {
        _loadMoreSuggestions();
      }
    }
  }

  List<SuggestedAccountItem> _getFallbackMockSuggestions() {
    return [
      SuggestedAccountItem(
        id: 'mock-1',
        name: 'Mai Anh',
        username: '@maianh_baking',
        reason: 'Có 15 người theo dõi chung',
        avatarBgColor: const Color(0xFF81C784),
        isFollowing: false,
      ),
      SuggestedAccountItem(
        id: 'mock-2',
        name: 'Hoàng Long',
        username: '@long_chefhouse',
        reason: 'Gợi ý cho bạn • Đầu bếp món Âu',
        avatarBgColor: const Color(0xFF64B5F6),
        isFollowing: false,
      ),
      SuggestedAccountItem(
        id: 'mock-3',
        name: 'Chef Hùng',
        username: '@hung_masterchef',
        reason: 'Theo dõi bởi Chef Nam',
        avatarBgColor: const Color(0xFFFFD54F),
        isFollowing: false,
      ),
      SuggestedAccountItem(
        id: 'mock-4',
        name: 'Thu Trang',
        username: '@trang_healthyfood',
        reason: 'Phổ biến trong Ẩm thực Healthy',
        avatarBgColor: const Color(0xFFBA68C8),
        isFollowing: false,
      ),
      SuggestedAccountItem(
        id: 'mock-5',
        name: 'Linh Chi',
        username: '@linhchi_pastry',
        reason: 'Từ danh bạ của bạn',
        avatarBgColor: const Color(0xFF4DB6AC),
        isFollowing: false,
      ),
    ];
  }

  SuggestedAccountItem _mapToItem(UserSuggestion s) {
    final name = (s.displayName != null && s.displayName!.isNotEmpty)
        ? s.displayName!
        : (s.username ?? ApiI18n.text(UiI18nKeys.chatDefaultChef));
    final usernameText = s.username != null && s.username!.isNotEmpty
        ? (s.username!.startsWith('@') ? s.username! : '@${s.username}')
        : '';
    return SuggestedAccountItem(
      id: s.id,
      name: name,
      username: usernameText,
      reason: s.formattedReason,
      avatar: s.avatar,
      avatarBgColor: s.avatarBgColor,
      isFollowing: s.isFollowing,
    );
  }

  Future<void> _loadInitialSuggestions() async {
    setState(() {
      _isLoadingSuggestions = true;
    });

    final token = AuthService.instance.tokens?.accessToken;
    if (token == null || token.isEmpty) {
      // Guest or mock session: fallback to initial list
      setState(() {
        _suggestedAccounts.clear();
        _suggestedAccounts.addAll(_getFallbackMockSuggestions());
        _isLoadingSuggestions = false;
        _hasMoreSuggestions = false;
      });
      return;
    }

    try {
      final fetched = await _chatApiService.getSuggestedUsers(
        accessToken: token,
        limit: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _suggestedAccounts.clear();
        if (fetched.isNotEmpty) {
          _suggestedAccounts.addAll(fetched.map(_mapToItem));
          // If returned items < pageSize, no more
          _hasMoreSuggestions = fetched.length >= _pageSize;
        } else {
          // If empty suggestions for new user, provide fallback
          _suggestedAccounts.addAll(_getFallbackMockSuggestions());
          _hasMoreSuggestions = false;
        }
        _isLoadingSuggestions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (_suggestedAccounts.isEmpty) {
          _suggestedAccounts.addAll(_getFallbackMockSuggestions());
        }
        _isLoadingSuggestions = false;
        _hasMoreSuggestions = false;
      });
    }
  }

  Future<void> _loadMoreSuggestions() async {
    if (_isLoadingMore || !_hasMoreSuggestions) return;

    setState(() {
      _isLoadingMore = true;
    });

    final token = AuthService.instance.tokens?.accessToken;
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _hasMoreSuggestions = false;
        });
      }
      return;
    }

    try {
      final fetched = await _chatApiService.getSuggestedUsers(
        accessToken: token,
        limit: _pageSize,
      );

      if (!mounted) return;

      final existingIds = _suggestedAccounts.map((a) => a.id).toSet();
      final newItems = fetched
          .where((s) => !existingIds.contains(s.id))
          .map(_mapToItem)
          .toList();

      setState(() {
        _isLoadingMore = false;
        if (newItems.isNotEmpty) {
          _suggestedAccounts.addAll(newItems);
          if (fetched.length < _pageSize) {
            _hasMoreSuggestions = false;
          }
        } else {
          _hasMoreSuggestions = false;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _hasMoreSuggestions = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadInitialSuggestions();
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
                    Expanded(
                      child: Text(
                        ApiI18n.text(UiI18nKeys.chatSuggestedAccountsTitle),
                        style: const TextStyle(
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
                  ApiI18n.text(UiI18nKeys.chatSuggestedAccountsExplanation),
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
                    child: Text(
                      ApiI18n.text(UiI18nKeys.chatUnderstood),
                      style: const TextStyle(
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
    // Get fresh auth state on every build

    return ValueListenableBuilder<String>(
      valueListenable: ApiI18n.languageNotifier,
      builder: (context, currentLanguage, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
            leading: AuthService.instance.isLoggedIn ? IconButton(
              icon: const Icon(Icons.group_add_outlined),
              onPressed: () {},
            ) : null,
            title: Text(
              ApiI18n.text(UiI18nKeys.chatInboxTitle),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: AuthService.instance.isLoggedIn ? [
              IconButton(
                icon: const Icon(Iconsax.search_normal_1, size: 20),
                onPressed: () {},
              ),
            ] : null,
          ),
          body: !AuthService.instance.isLoggedIn
              ? _buildLoginRequiredView(context, primaryColor)
              : CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Custom Pull-to-refresh: đẩy danh sách tin xuống nhường chỗ cho hiệu ứng 3 chấm nhảy sóng ở trên
              CustomSliverRefreshControl(
                onRefresh: _handleRefresh,
                primaryColor: primaryColor,
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
                  title: ApiI18n.text(UiI18nKeys.chatNewActivityTitle),
                  subtitle: ApiI18n.text(UiI18nKeys.chatNewActivitySubtitle),
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
                  title: ApiI18n.text(UiI18nKeys.chatSystemNotificationTitle),
                  subtitle: ApiI18n.text(UiI18nKeys.chatSystemNotificationSubtitle),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    ApiI18n.text(UiI18nKeys.chatMessagesSectionTitle),
                    style: const TextStyle(
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
                      Text(
                        ApiI18n.text(UiI18nKeys.chatSuggestedAccountsTitle),
                        style: const TextStyle(
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
          // Loading ban đầu cho danh sách đề xuất
          if (_isLoadingSuggestions && _suggestedAccounts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CustomRefreshBadge(
                    isRefreshing: true,
                    percentage: 1.0,
                    primaryColor: primaryColor,
                  ),
                ),
              ),
            )
          else ...[
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
            // Loading thêm khi cuộn trang (Infinite scroll indicator)
            if (_isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: CustomRefreshBadge(
                      isRefreshing: true,
                      percentage: 1.0,
                      primaryColor: primaryColor,
                    ),
                  ),
                ),
              ),
          ],
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
      },
    );
  }


  /// Build login required view for guests
  Widget _buildLoginRequiredView(BuildContext context, Color primaryColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.message,
                        size: 48,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 28),
                    
                    // Title
                    Text(
                      'Kết nối với cộng đồng yêu ẩm thực',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      'Đăng nhập để nhắn tin với các chef, chia sẻ công thức và khám phá thế giới ẩm thực cùng hàng nghìn người dùng khác.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Features list
                    _buildFeatureItem(
                      icon: Iconsax.message_text,
                      title: 'Trò chuyện trực tiếp',
                      description: 'Nhắn tin với các chef và người dùng',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Iconsax.notification,
                      title: 'Nhận thông báo',
                      description: 'Cập nhật hoạt động mới nhất',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Iconsax.profile_2user,
                      title: 'Kết nối bạn bè',
                      description: 'Theo dõi và tương tác với cộng đồng',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 36),
                    
                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Đăng nhập ngay',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Register link
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterEmailScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Chưa có tài khoản? Đăng ký',
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color primaryColor,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedAccountTile(
    BuildContext context,
    SuggestedAccountItem account,
    int index,
    Color primaryColor,
  ) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtherUserProfileScreen(
              userId: account.id,
              name: account.name,
              username: account.username,
              avatar: account.avatar,
              avatarBgColor: account.avatarBgColor,
              initialIsFollowing: account.isFollowing,
            ),
          ),
        );
      },
      contentPadding: const EdgeInsets.only(left: 16, right: 4, top: 2, bottom: 2),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: account.avatarBgColor,
        backgroundImage: account.avatar != null && account.avatar!.isNotEmpty
            ? NetworkImage(account.avatar!)
            : null,
        child: (account.avatar == null || account.avatar!.isEmpty)
            ? Text(
                account.name.characters.first,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
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
                account.isFollowing
                    ? ApiI18n.text(UiI18nKeys.profileFollowing)
                    : ApiI18n.text(UiI18nKeys.profileFollow),
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
              ApiI18n.text(UiI18nKeys.chatCreateStory),
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
        item.isLastMessageFromMe ? '${ApiI18n.text(UiI18nKeys.chatYouPrefix)}: ${item.lastMessage}' : item.lastMessage,
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
