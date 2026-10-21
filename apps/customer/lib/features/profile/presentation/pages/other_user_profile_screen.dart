import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'dart:async';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/core/widgets/custom_pull_to_refresh.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/chat/presentation/pages/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iconsax/iconsax.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;
  final String? initialName;
  final String? initialUsername;
  final String? initialAvatar;
  final String? initialBio;
  final Color? avatarBgColor;
  final bool initialIsFollowing;
  final ApiService? apiService;
  final Future<void> Function()? onRefresh;

  // Backwards-compatible aliases
  const OtherUserProfileScreen({
    super.key,
    required this.userId,
    String? name,
    String? username,
    String? avatar,
    String? bio,
    String? gender,
    int? videoCount,
    int? followerCount,
    int? likeCount,
    this.initialIsFollowing = false,
    this.avatarBgColor,
    this.apiService,
    this.onRefresh,
  })  : initialName = name,
        initialUsername = username,
        initialAvatar = avatar,
        initialBio = bio;

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen>
    with TickerProviderStateMixin {
  late final ApiService _apiService;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Screen State
  bool _isLoading = true;

  // User Profile Data loaded from API
  late String _displayName;
  late String _username;
  String? _avatar;
  String? _bio;
  int _recipesCount = 0;
  int _followerCount = 0;
  int _likeCount = 0;
  bool _isFollowing = false;
  bool _showAppBarTitle = false;

  // Pull-to-refresh overscroll state
  double _pullOffset = 0.0;
  bool _isRefreshing = false;
  late AnimationController _refreshAnimController;
  AnimationController? _collapseAnimController;
  Timer? _minRefreshTimer;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);

    _displayName = widget.initialName ?? '';
    _username = widget.initialUsername ?? '';
    _avatar = widget.initialAvatar;
    _bio = widget.initialBio;
    _isFollowing = widget.initialIsFollowing;

    _refreshAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _collapseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _fetchFullUserProfile();
  }

  @override
  void dispose() {
    _minRefreshTimer?.cancel();
    _tabController.removeListener(_onTabChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    _refreshAnimController.dispose();
    _collapseAnimController?.dispose();
    super.dispose();
  }

  Future<void> _fetchFullUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final token = AuthService.instance.tokens?.accessToken;

    try {
      if (token != null && token.isNotEmpty) {
        final result = await _apiService.getUserDetails(
          accessToken: token,
          userId: widget.userId,
        );

        if (!mounted) return;

        if (result.isSuccess && result.user != null) {
          _applyUserData(result.user!);
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Fallback if guest/demo mode or network returns empty
      if (!mounted) return;
      _applyFallbackOrInitial();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _applyFallbackOrInitial();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyUserData(AuthUser user) {
    _displayName = user.fullName.isNotEmpty
        ? user.fullName
        : (widget.initialName ?? 'Đầu bếp');
    _username = (user.username != null && user.username!.isNotEmpty)
        ? user.username!
        : (widget.initialUsername ?? '');
    _avatar = (user.avatar != null && user.avatar!.isNotEmpty)
        ? user.avatar
        : widget.initialAvatar;
    _bio = user.bio ?? widget.initialBio;
    _recipesCount = user.videoCount;
    _followerCount = user.followerCount;
    _likeCount = user.likeCount;
  }

  void _applyFallbackOrInitial() {
    _displayName = _displayName.isNotEmpty
        ? _displayName
        : (widget.initialName ?? 'Đầu bếp');
    _username = _username.isNotEmpty
        ? _username
        : (widget.initialUsername ?? '');
    _avatar = _avatar ?? widget.initialAvatar;
    _bio = _bio ?? widget.initialBio;
  }

  void _onTabChanged() {
    if (!mounted) return;
    setState(() {
      if (_tabController.index != 0) {
        _showAppBarTitle = false;
        if (_pullOffset > 0 || _isRefreshing) {
          _resetPullOffset();
        }
        if (_scrollController.hasClients && _scrollController.offset > 0) {
          _scrollController.jumpTo(0);
        }
      }
    });
  }

  void _onScroll() {
    final show = _scrollController.hasClients && _scrollController.offset > 70;
    if (show != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = show;
      });
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_tabController.index != 0) {
      if (_pullOffset > 0 || _isRefreshing) {
        _resetPullOffset();
      }
      return false;
    }

    // Safety guard: if page content is scrolled down, pull offset must be zero
    if (_scrollController.hasClients && _scrollController.offset > 5.0) {
      if (_pullOffset > 0 && !_isRefreshing) {
        _resetPullOffset();
      }
      return false;
    }

    if (notification is ScrollStartNotification) {
      if (!_isRefreshing && (_collapseAnimController?.isAnimating ?? false)) {
        _collapseAnimController?.stop();
      }
    } else if (notification is OverscrollNotification) {
      if (!_isRefreshing && notification.metrics.pixels <= 0) {
        if (notification.overscroll < 0) {
          final dy = notification.overscroll.abs();
          setState(() {
            _pullOffset = (_pullOffset + dy * 0.45).clamp(0.0, 75.0);
          });
        }
      }
    } else if (notification is ScrollUpdateNotification) {
      if (!_isRefreshing) {
        if (_pullOffset > 0 && notification.dragDetails != null) {
          final dy = notification.dragDetails!.primaryDelta ?? 0;
          setState(() {
            _pullOffset = (_pullOffset + dy * 0.55).clamp(0.0, 75.0);
          });
        }
      }
    } else if (notification is UserScrollNotification) {
      if (!_isRefreshing && notification.direction == ScrollDirection.idle) {
        if (_pullOffset >= 48.0) {
          _triggerCustomRefresh();
        } else if (_pullOffset > 0 &&
            !(_collapseAnimController?.isAnimating ?? false)) {
          _animateResetPullOffset();
        }
      }
    } else if (notification is ScrollEndNotification) {
      if (!_isRefreshing) {
        if (_pullOffset >= 48.0) {
          _triggerCustomRefresh();
        } else if (_pullOffset > 0 &&
            !(_collapseAnimController?.isAnimating ?? false)) {
          _animateResetPullOffset();
        }
      }
    }
    return false;
  }

  void _triggerCustomRefresh() async {
    if (_isRefreshing) return;
    _collapseAnimController?.stop();
    setState(() {
      _isRefreshing = true;
      _pullOffset = 60.0;
    });
    _refreshAnimController.repeat(reverse: true);

    try {
      final token = AuthService.instance.tokens?.accessToken;
      Future<void> fetchAction;
      if (widget.onRefresh != null) {
        fetchAction = widget.onRefresh!();
      } else if (token != null && token.isNotEmpty) {
        fetchAction = _apiService
            .getUserDetails(accessToken: token, userId: widget.userId)
            .then((res) {
          if (mounted && res.isSuccess && res.user != null) {
            setState(() {
              _applyUserData(res.user!);
            });
          }
        });
      } else {
        fetchAction = Future.delayed(const Duration(milliseconds: 600));
      }

      final completer = Completer<void>();
      _minRefreshTimer?.cancel();
      _minRefreshTimer = Timer(const Duration(milliseconds: 500), () {
        if (!completer.isCompleted) completer.complete();
      });
      await Future.wait([
        fetchAction.timeout(const Duration(seconds: 4), onTimeout: () {}),
        completer.future,
      ]);
    } catch (_) {}

    if (mounted) {
      _refreshAnimController.stop();
      setState(() {
        _isRefreshing = false;
      });
      _animateResetPullOffset();
    }
  }

  void _resetPullOffset() {
    _collapseAnimController?.stop();
    _refreshAnimController.stop();
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _pullOffset = 0.0;
      });
    }
  }

  void _animateResetPullOffset() {
    if (!mounted) return;
    if (_pullOffset <= 0.0) {
      _resetPullOffset();
      return;
    }
    _collapseAnimController?.stop();
    _refreshAnimController.stop();
    final double startOffset = _pullOffset;
    final Animation<double> curve = CurvedAnimation(
      parent: _collapseAnimController!,
      curve: Curves.easeOutCubic,
    );
    _collapseAnimController!.reset();

    void listener() {
      if (!mounted) return;
      setState(() {
        _pullOffset = (startOffset * (1.0 - curve.value)).clamp(0.0, 75.0);
      });
    }

    _collapseAnimController!.addListener(listener);
    _collapseAnimController!.forward().then((_) {
      _collapseAnimController?.removeListener(listener);
      if (mounted) {
        _refreshAnimController.stop();
        setState(() {
          _pullOffset = 0.0;
          _isRefreshing = false;
        });
      }
    });
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      if (_isFollowing) {
        _followerCount += 1;
      } else {
        _followerCount = (_followerCount - 1).clamp(0, 9999999);
      }
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFollowing
              ? ApiI18n.text(UiI18nKeys.profileFollowedToast).replaceAll('{name}', _displayName)
              : ApiI18n.text(UiI18nKeys.profileUnfollowedToast).replaceAll('{name}', _displayName),
          style: const TextStyle(fontSize: 13.5),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          name: _displayName,
          avatarBgColor: widget.avatarBgColor ?? const Color(0xFFFB923C),
          isOnline: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ApiI18n.languageNotifier,
      builder: (context, currentLanguage, child) {
        final primaryColor = Theme.of(context).colorScheme.primary;

        final formattedHandle = _username.isNotEmpty
            ? (_username.startsWith('@') ? _username : '@$_username')
            : '';

        return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
          tooltip: ApiI18n.text(UiI18nKeys.profileBack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: IgnorePointer(
          ignoring: !_showAppBarTitle || _isLoading,
          child: AnimatedOpacity(
            opacity: (!_isLoading && _showAppBarTitle) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Text(
              _displayName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.5,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87, size: 22),
            tooltip: ApiI18n.text(UiI18nKeys.profileShare),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ApiI18n.text(UiI18nKeys.profileLinkCopied)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.black87, size: 22),
            tooltip: ApiI18n.text(UiI18nKeys.profileMore),
            onPressed: () => _showMoreActionsSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? _buildCenterLoadingBox(primaryColor)
          : _buildLoadedContent(primaryColor, formattedHandle),
        );
      },
    );
  }

  /// Elegant centered card with jumping wave dots and smooth branding
  Widget _buildCenterLoadingBox(Color primaryColor) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomRefreshBadge(
              isRefreshing: true,
              percentage: 1.0,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              ApiI18n.text(UiI18nKeys.profileLoadingChef),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(Color primaryColor, String formattedHandle) {
    final hasBio = _bio != null && _bio!.trim().isNotEmpty;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: [Name + Handle on the Left] and [Avatar on the Right]
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Tên người dùng + @username + Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (formattedHandle.isNotEmpty)
                      Text(
                        formattedHandle,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 10),
                    // Social stats
                    Row(
                      children: [
                        _buildInlineStatItem('$_recipesCount', ApiI18n.text(UiI18nKeys.profileStatRecipes)),
                        const SizedBox(width: 28),
                        _buildInlineStatItem(
                          _followerCount >= 1000
                              ? '${(_followerCount / 1000).toStringAsFixed(1)}K'
                              : '$_followerCount',
                          ApiI18n.text(UiI18nKeys.profileStatFollowers),
                        ),
                        const SizedBox(width: 28),
                        _buildInlineStatItem(
                          _likeCount >= 1000
                              ? '${(_likeCount / 1000).toStringAsFixed(1)}K'
                              : '$_likeCount',
                          ApiI18n.text(UiI18nKeys.profileStatLikes),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Right Side: Avatar
              Stack(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: (_avatar != null && _avatar!.isNotEmpty)
                          ? Image.network(
                              _avatar!,
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildAvatarFallback(primaryColor),
                            )
                          : _buildAvatarFallback(primaryColor),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Iconsax.verify5,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bio Display
          if (hasBio)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                _bio!,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ),

          // 2 Nút hành động: Follow & Tin nhắn
          Row(
            children: [
              // Nút Follow / Đang theo dõi
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor:
                          _isFollowing ? const Color(0xFFF3F4F6) : primaryColor,
                      foregroundColor:
                          _isFollowing ? Colors.black87 : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: _isFollowing
                            ? BorderSide(color: Colors.grey.shade300)
                            : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isFollowing ? Iconsax.user_tick : Iconsax.user_add,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _isFollowing ? ApiI18n.text(UiI18nKeys.profileFollowing) : ApiI18n.text(UiI18nKeys.profileFollow),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Nút Nhắn tin
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: _openChat,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      foregroundColor: Colors.black87,
                      backgroundColor: const Color(0xFFF9FAFB),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.message, size: 16, color: Colors.black87),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            ApiI18n.text(UiI18nKeys.profileMessage),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(Color primaryColor) {
    final bgColor = widget.avatarBgColor ??
        Color((_displayName.hashCode & 0x00FFFFFF) | 0xFF000000);

    return Container(
      color: bgColor,
      alignment: Alignment.center,
      child: Text(
        _displayName.characters.isNotEmpty
            ? _displayName.characters.first
            : 'C',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInlineStatItem(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  TabBar _buildTabBar(Color primaryColor) {
    return TabBar(
      controller: _tabController,
      dividerColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      enableFeedback: false,
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey[500],
      indicatorColor: primaryColor,
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: const [
        Tab(icon: Icon(Iconsax.video_play, size: 21)),
        Tab(icon: Icon(Iconsax.heart, size: 21)),
      ],
    );
  }

  Widget _buildLoadedContent(Color primaryColor, String formattedHandle) {
    final bool isEmptyRecipes = _recipesCount <= 0;

    // Khi ở tab 1 (Yêu thích) hoặc tab 0 (Món ăn) nhưng chưa có món ăn nào:
    // Cố định trang như profile_screen để không bị cuộn xuống vô lý
    if (_tabController.index != 0 || isEmptyRecipes) {
      return Column(
        children: [
          _buildProfileHeaderCard(primaryColor, formattedHandle),
          Container(
            color: Colors.white,
            child: _buildTabBar(primaryColor),
          ),
          Expanded(
            child: _tabController.index == 0
                ? _buildEmptyRecipesView()
                : _buildLikesTab(),
          ),
        ],
      );
    }

    // Khi ở tab Món ăn và ĐÃ CÓ danh sách món ăn:
    // Sử dụng NestedScrollView để cuộn mượt mà giữa Header và Grid danh sách món ăn
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(
          overscroll: false,
          physics: const ClampingScrollPhysics(),
        ),
        child: NestedScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              if (_pullOffset > 0 || _isRefreshing)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: _pullOffset,
                    child: ClipRect(
                      child: Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: CustomRefreshBadge(
                          isRefreshing: _isRefreshing,
                          percentage: (_pullOffset / 55.0).clamp(0.0, 1.0),
                          primaryColor: primaryColor,
                          animController: _refreshAnimController,
                        ),
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: _buildProfileHeaderCard(
                  primaryColor,
                  formattedHandle,
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  _buildTabBar(primaryColor),
                ),
              ),
            ];
          },
          body: _buildRecipesGrid(primaryColor),
        ),
      ),
    );
  }

  Widget _buildEmptyRecipesView() {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 1.2),
            ),
            child: Center(
              child: Icon(
                Iconsax.video_slash,
                size: 34,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ApiI18n.text(UiI18nKeys.profileUserNotSharedTitle),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ApiI18n.text(UiI18nKeys.profileUserNotSharedSubtitle),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesGrid(Color primaryColor) {
    final mockVideoViews = [
      '14.2K', '8.9K', '3.5K', '19.8K', '6.1K', '11.4K',
      '2.4K', '25.3K', '7.7K', '1.8K', '32.0K', '9.2K',
    ];

    final displayCount = _recipesCount > 0 ? _recipesCount : 0;

    return Builder(
      builder: (context) {
        return CustomScrollView(
          key: const PageStorageKey<String>('other_user_tab_videos'),
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final views = mockVideoViews[index % mockVideoViews.length];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F2F5),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF3F4F6),
                              Color(0xFFE5E7EB),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 0.8,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const Center(
                              child: Icon(
                                Iconsax.video_play,
                                color: Color(0xFF9CA3AF),
                                size: 28,
                              ),
                            ),
                            Positioned(
                              bottom: 6,
                              left: 6,
                              child: Row(
                                children: [
                                  const Icon(
                                    Iconsax.play,
                                    size: 11,
                                    color: Color(0xFF4B5563),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    views,
                                    style: const TextStyle(
                                      color: Color(0xFF374151),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: displayCount.clamp(0, mockVideoViews.length),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLikesTab() {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.lock, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            ApiI18n.text(UiI18nKeys.profilePrivateLikesTitle),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ApiI18n.text(UiI18nKeys.profilePrivateLikesSubtitle),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: Colors.black87),
              title: Text(ApiI18n.text(UiI18nKeys.profileActionShare)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ApiI18n.text(UiI18nKeys.profileLinkCopied))),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.info_circle, color: Colors.black87),
              title: Text(ApiI18n.text(UiI18nKeys.profileActionReport)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ApiI18n.text(UiI18nKeys.profileReportThankYou))),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.slash, color: Colors.red),
              title: Text(ApiI18n.text(UiI18nKeys.profileActionBlock), style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ApiI18n.text(UiI18nKeys.profileBlockedToast).replaceAll('{name}', _displayName))),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
