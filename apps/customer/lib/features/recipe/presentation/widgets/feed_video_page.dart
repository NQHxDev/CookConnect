import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_pool/video_pool.dart';
import 'package:cookconnect/core/widgets/heart_animation_overlay.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/profile/presentation/pages/other_user_profile_screen.dart';
import 'package:cookconnect/features/profile/presentation/pages/profile_screen.dart';
import 'package:cookconnect/features/recipe/data/models/post_item.dart';
import 'package:cookconnect/features/recipe/data/services/author_profile_service.dart';
import 'package:cookconnect/features/recipe/data/services/video_analytics_service.dart';
import 'package:cookconnect/features/recipe/data/services/video_watch_tracker.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/comments_bottom_sheet.dart';
import 'package:cookconnect/features/recipe/data/services/recipe_data_service.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/ingredient_visuals.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/ingredients_bottom_sheet.dart';

/// Full screen page representing a single video item in the vertical feed
class FeedVideoPage extends StatefulWidget {
  final int index;
  final PostItem post;
  final VideoSource source;
  final void Function(bool isLiked, int newCount)? onLikeChanged;
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatar;

  const FeedVideoPage({
    super.key,
    required this.index,
    required this.post,
    required this.source,
    this.onLikeChanged,
    this.authorName,
    this.authorUsername,
    this.authorAvatar,
  });

  @override
  State<FeedVideoPage> createState() => _FeedVideoPageState();
}

class _FeedVideoPageState extends State<FeedVideoPage>
    with WidgetsBindingObserver {
  late bool _isLiked;
  late int _likeCount;
  late int _commentCount;
  bool _isSaved = false;

  // Author metadata resolution
  AuthorProfile? _authorProfile;

  // Video watch behavior tracking
  late final VideoWatchTracker _tracker;
  PoolEntry? _trackedEntry;
  bool _isUserManuallyPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.localLikeCount;
    _commentCount = widget.post.localCommentCount;
    _isSaved = widget.post.isSaved;

    _loadAuthorProfile();

    _tracker = VideoWatchTracker(
      postId: widget.post.postId,
      videoUrl: widget.post.videoUrl,
      initialDuration: Duration(seconds: widget.post.duration),
    );
  }

  @override
  void didUpdateWidget(FeedVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.userId != widget.post.userId ||
        oldWidget.post.author?.displayName != widget.post.author?.displayName ||
        oldWidget.authorUsername != widget.authorUsername ||
        oldWidget.authorName != widget.authorName ||
        oldWidget.authorAvatar != widget.authorAvatar) {
      _loadAuthorProfile();
    }
  }

  void _loadAuthorProfile() {
    // 1. Explicitly provided via widget parameters (e.g., from Profile/OtherUserProfile)
    if (widget.authorUsername != null || widget.authorName != null) {
      _authorProfile = AuthorProfile(
        userId: widget.post.userId,
        displayName: widget.authorName ?? widget.authorUsername ?? '',
        username: widget.authorUsername,
        avatar: widget.authorAvatar,
      );
      return;
    }

    // 1b. Server-provided author info embedded in the post response
    final postAuthorName = widget.post.author?.displayName?.trim();
    if (postAuthorName != null && postAuthorName.isNotEmpty) {
      _authorProfile = AuthorProfile(
        userId: widget.post.userId,
        displayName: postAuthorName,
        avatar: widget.post.author?.avatarUrl,
      );
      return;
    }

    // 2. Belongs to current logged-in user
    if (_isCurrentUserAuthor) {
      final user = AuthService.instance.currentUser;
      if (user != null) {
        _authorProfile = AuthorProfile(
          userId: widget.post.userId,
          displayName: user.fullName.trim().isNotEmpty
              ? user.fullName.trim()
              : (user.username?.trim().isNotEmpty == true
                  ? user.username!.trim()
                  : 'Tôi'),
          username: user.username?.trim(),
          avatar: user.avatar,
        );
        return;
      }
    }

    // 3. Fast sync check in AuthorProfileService memory cache
    final cached = AuthorProfileService.instance.getCached(widget.post.userId);
    if (cached != null) {
      _authorProfile = cached;
      return;
    }

    // 4. Async background fetch & update
    AuthorProfileService.instance.resolveAuthor(widget.post.userId).then((profile) {
      if (mounted && profile != null) {
        setState(() {
          _authorProfile = profile;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _flushAnalytics(reason: 'APP_BACKGROUND');
      VideoAnalyticsService.instance.flush();
    }
  }

  void _onEntryLifecycleChanged() {
    final entry = _trackedEntry;
    if (entry == null) return;
    if (entry.lifecycleState == LifecycleState.playing) {
      if (_isUserManuallyPaused && mounted) {
        setState(() {
          _isUserManuallyPaused = false;
        });
      }
      _tracker.start();
    } else {
      _tracker.pause();
    }
  }

  void _onPlayerStateChanged() {
    final entry = _trackedEntry;
    if (entry == null) return;
    final state = entry.adapter.stateNotifier.value;
    _tracker.onPositionUpdated(state.position, state.duration);
    if (state.phase == PlaybackPhase.playing) {
      _tracker.start();
    } else if (state.phase == PlaybackPhase.paused ||
        state.phase == PlaybackPhase.buffering ||
        state.phase == PlaybackPhase.idle) {
      _tracker.pause();
    }
  }

  void _attachTrackerToEntry(PoolEntry? entry) {
    if (_trackedEntry == entry) return;
    _detachEntryListeners();
    _trackedEntry = entry;
    if (entry != null) {
      entry.lifecycleNotifier.addListener(_onEntryLifecycleChanged);
      entry.adapter.stateNotifier.addListener(_onPlayerStateChanged);
      if (entry.lifecycleState == LifecycleState.playing) {
        _tracker.start();
      }
    }
  }

  void _detachEntryListeners() {
    if (_trackedEntry != null) {
      _trackedEntry!.lifecycleNotifier.removeListener(_onEntryLifecycleChanged);
      _trackedEntry!.adapter.stateNotifier.removeListener(_onPlayerStateChanged);
      _trackedEntry = null;
    }
  }

  void _flushAnalytics({String reason = 'SCROLLED'}) {
    final event = _tracker.finish(reason: reason);
    if (event != null) {
      VideoAnalyticsService.instance.enqueue(event);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flushAnalytics(reason: 'SCROLLED');
    _detachEntryListeners();
    super.dispose();
  }

  void _handleLikeToggle() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
      widget.onLikeChanged?.call(_isLiked, _likeCount);
    });
  }

  void _handleDoubleTapHeart() {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _likeCount += 1;
        widget.onLikeChanged?.call(_isLiked, _likeCount);
      });
    }
  }

  void _handleSaveToggle() {
    setState(() {
      _isSaved = !_isSaved;
      widget.post.isSaved = _isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved ? 'Đã lưu công thức' : 'Đã bỏ lưu'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleTapPlayPause(VideoPool pool) {
    final entry = pool.getEntryForIndex(widget.index);
    final willBePaused = entry?.lifecycleState == LifecycleState.playing;
    setState(() {
      _isUserManuallyPaused = willBePaused;
    });
    pool.togglePlayPause(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    final pool = VideoPoolProvider.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: pool.reconciliationNotifier,
      builder: (context, _, _) {
        final entry = pool.getEntryForIndex(widget.index);
        _attachTrackerToEntry(entry);

        return HeartAnimationOverlay(
          onLike: _handleDoubleTapHeart,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _handleTapPlayPause(pool),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video player / thumbnail layer
                VideoCard(
                  index: widget.index,
                  source: widget.source,
                  showOverlay: false,
                ),

                // Top gradient scrim for app bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom gradient scrim for info & actions readability
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 290,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // Center pause / buffering indicators
                if (entry != null)
                  ValueListenableBuilder<LifecycleState>(
                    valueListenable: entry.lifecycleNotifier,
                    builder: (context, lifecycleState, _) {
                      final shouldShowPauseIcon =
                          lifecycleState == LifecycleState.paused && _isUserManuallyPaused;

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: shouldShowPauseIcon
                            ? const ModernPauseOverlay(key: ValueKey('paused'))
                            : (lifecycleState == LifecycleState.buffering
                                ? const Center(
                                    key: ValueKey('buffering'),
                                    child: CircularProgressIndicator(
                                      color: Colors.orange,
                                      strokeWidth: 3.0,
                                    ),
                                  )
                                : const SizedBox.shrink(key: ValueKey('none'))),
                      );
                    },
                  ),

                // Right side action buttons
                Positioned(
                  right: 12,
                  bottom: 24,
                  child: _buildRightActions(context),
                ),

                // Bottom left information & Ingredients Box
                Positioned(
                  left: 14,
                  right: 88,
                  bottom: 24,
                  child: _buildBottomInfo(context),
                ),

                // Bottom video progress indicator
                if (entry != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildProgressBar(entry),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(PoolEntry entry) {
    return ValueListenableBuilder<PlayerState>(
      valueListenable: entry.adapter.stateNotifier,
      builder: (context, state, _) {
        final pos = state.position;
        final dur = state.duration;
        final progress = dur.inMilliseconds > 0
            ? pos.inMilliseconds / dur.inMilliseconds
            : 0.0;

        return LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          minHeight: 2.5,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
        );
      },
    );
  }

  Widget _buildRightActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar placeholder with '+' button
        _buildAvatarWithPlus(),
        const SizedBox(height: 18),

        // Like button
        _buildActionButton(
          icon: _isLiked ? Iconsax.heart5 : Iconsax.heart,
          iconColor: _isLiked ? Colors.redAccent : Colors.white,
          label: _formatCount(_likeCount),
          onTap: _handleLikeToggle,
        ),
        const SizedBox(height: 16),

        // Comment button
        _buildActionButton(
          icon: Iconsax.message_text,
          label: _formatCount(_commentCount),
          onTap: () {
            showCommentsBottomSheet(
              context,
              post: widget.post,
              onCommentCountChanged: (newCount) {
                setState(() {
                  _commentCount = newCount;
                  widget.post.localCommentCount = newCount;
                });
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Save button
        _buildActionButton(
          icon: _isSaved ? Iconsax.archive_1 : Iconsax.archive_add,
          iconColor: _isSaved ? Colors.amber : Colors.white,
          label: _formatCount(widget.post.saveCount + (_isSaved ? 1 : 0)),
          onTap: _handleSaveToggle,
        ),
        const SizedBox(height: 16),

        // Share button
        _buildActionButton(
          icon: Iconsax.send_2,
          label: _formatCount(widget.post.shareCount),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Liên kết đã được sao chép'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // More button
        _buildActionButton(
          icon: Iconsax.more,
          label: '',
          iconSize: 22,
          onTap: () {},
        ),
      ],
    );
  }

  String get _authorHandle {
    final serverName = widget.post.author?.displayName?.trim();
    if (serverName != null && serverName.isNotEmpty) {
      return serverName;
    }
    if (_authorProfile != null) {
      return _authorProfile!.handle;
    }
    final rawId = widget.post.userId.replaceAll('-', '').trim();
    if (rawId.length >= 6) {
      return '@user_${rawId.substring(0, 6)}';
    }
    return '@user';
  }

  String? get _authorAvatar =>
      _authorProfile?.avatar ??
      widget.authorAvatar ??
      (_isCurrentUserAuthor ? AuthService.instance.currentUser?.avatar : null);

  void _openIngredientsSheet() {
    showIngredientsBottomSheet(
      context,
      recipeTitle: widget.post.title,
      ingredients: widget.post.ingredients,
      postId: widget.post.postId,
      post: widget.post,
    );
  }

  /// Thẻ xem trước nguyên liệu trên video: hiển thị vài nguyên liệu đầu tiên
  /// và trạng thái đã có trong giỏ "Đi chợ" hay chưa.
  Widget _buildIngredientsPreview(BuildContext context) {
    const accent = Color(0xFFFF7A1A);
    const accentEnd = Color(0xFFFF2D55);
    const inCartColor = Color(0xFF34C759);

    final ingredients = widget.post.ingredients;

    return AnimatedBuilder(
      animation: RecipeDataService.instance,
      builder: (context, _) {
        final total = ingredients.length;
        final inCart = ingredients
            .where(
              (i) => RecipeDataService.instance.isIngredientInShoppingList(
                i.name,
              ),
            )
            .length;
        final allInCart = total > 0 && inCart == total;

        final preview = ingredients.take(3).toList();
        final remaining = total - preview.length;

        return GestureDetector(
          onTap: _openIngredientsSheet,
          behavior: HitTestBehavior.opaque,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon giỏ nguyên liệu
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: allInCart
                            ? [inCartColor, const Color(0xFF30B0C7)]
                            : [accent, accentEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      allInCart ? Iconsax.bag_tick_2 : Iconsax.reserve,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              total > 0 ? 'Nguyên liệu · $total' : 'Nguyên liệu',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (inCart > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: inCartColor.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  allInCart ? 'Đủ trong giỏ' : '$inCart/$total trong giỏ',
                                  style: const TextStyle(
                                    color: inCartColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          preview.isEmpty
                              ? 'Xem & thêm vào giỏ đi chợ'
                              : [
                                  ...preview.map(
                                    (i) =>
                                        '${IngredientVisuals.emojiFor(i.name)} ${i.name}',
                                  ),
                                  if (remaining > 0) '+$remaining',
                                ].join('  ·  '),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    final authorHandle = _authorHandle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Author handle & chef badge
        GestureDetector(
          onTap: _navigateToAuthorProfile,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                authorHandle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Đầu bếp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Post Title
        Text(
          widget.post.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // Post Caption
        if (widget.post.caption != null && widget.post.caption!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.post.caption!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13.5,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 8),

        // Ingredients preview card (liên kết với trang Đi chợ)
        _buildIngredientsPreview(context),

        const SizedBox(height: 6),

        // Music / sound tag
        Row(
          children: [
            const Icon(Iconsax.music, color: Colors.white, size: 13),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Âm thanh gốc - CookConnect Chef',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToAuthorProfile() {
    if (_isCurrentUserAuthor) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        ),
      );
    } else if (widget.post.userId.trim().isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtherUserProfileScreen(
            userId: widget.post.userId.trim(),
            name: _authorProfile?.displayName ?? widget.authorName,
            username: _authorProfile?.username ?? widget.authorUsername,
            avatar: _authorAvatar,
          ),
        ),
      );
    }
  }

  bool get _isCurrentUserAuthor {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;
    final pUid = widget.post.userId.trim();
    if (pUid.isEmpty) return false;
    return pUid == user.userId ||
        pUid == user.id ||
        (user.accountId != null && pUid == user.accountId) ||
        (user.userProfileId != null && pUid == user.userProfileId);
  }

  Widget _buildAvatarWithPlus() {
    final avatarUrl = _authorAvatar;

    final hasAvatar = avatarUrl != null && avatarUrl.trim().isNotEmpty;

    return GestureDetector(
      onTap: _navigateToAuthorProfile,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              // Clean dark slate-gray background for avatar fallback instead of bright orange!
              gradient: hasAvatar
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF3E3E42), Color(0xFF262628)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
            child: ClipOval(
              child: hasAvatar
                  ? Image.network(
                      avatarUrl.trim(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3E3E42), Color(0xFF262628)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Iconsax.user, color: Colors.white70, size: 22),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(Iconsax.user, color: Colors.white70, size: 22),
                    ),
            ),
          ),
          if (!_isCurrentUserAuthor)
            Positioned(
              bottom: -6,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color iconColor = Colors.white,
    double iconSize = 28,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

/// Minimalist pause overlay with smooth entry animation, no background, and subtle opacity
class ModernPauseOverlay extends StatelessWidget {
  const ModernPauseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.75, end: 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white.withValues(alpha: 0.65),
              size: 72,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
