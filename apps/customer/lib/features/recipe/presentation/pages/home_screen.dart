import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_pool/video_pool.dart';

import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/core/widgets/heart_animation_overlay.dart';
import 'package:cookconnect/features/recipe/presentation/pages/search_screen.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/comments_bottom_sheet.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/ingredients_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Default to tab index 2: "Dành cho bạn" (For You)
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ApiI18n.languageNotifier,
      builder: (context, currentLanguage, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 50,
            titleSpacing: 8,
            title: Row(
              children: [
                // Live icon (leftmost)
                IconButton(
                  tooltip: ApiI18n.text(UiI18nKeys.homeLive),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: const Icon(
                    Iconsax.video_square,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
                // Center tabs: "Bạn bè", "Đang theo dõi", "Dành cho bạn"
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 2.0,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
                    labelStyle: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    tabs: [
                      Tab(text: ApiI18n.text(UiI18nKeys.homeTabFriends)),
                      Tab(text: ApiI18n.text(UiI18nKeys.homeTabFollowing)),
                      Tab(text: ApiI18n.text(UiI18nKeys.homeTabForYou)),
                    ],
                  ),
                ),
                // Search icon (rightmost)
                IconButton(
                  tooltip: ApiI18n.text(UiI18nKeys.homeSearch),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: const Icon(
                    Iconsax.search_normal_1,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildUnderDevelopmentTab(ApiI18n.text(UiI18nKeys.homeTabFriends)),
              _buildUnderDevelopmentTab(ApiI18n.text(UiI18nKeys.homeTabFollowing)),
              _ForYouFeedTab(isActive: _tabController.index == 2),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnderDevelopmentTab(String tabName) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withValues(alpha: 0.12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Iconsax.code_1,
                size: 46,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tính năng đang phát triển',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mục "$tabName" đang được xây dựng và sẽ sớm ra mắt trong các bản cập nhật tiếp theo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(2);
              },
              icon: const Icon(Iconsax.play_circle, size: 18),
              label: const Text(
                'Khám phá video Dành cho bạn',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Dành cho bạn" (For You) tab with vertical snapping full-screen feed.
/// Features Offline Cache-First persistence, zero-latency resume, and graceful fallback.
class _ForYouFeedTab extends StatefulWidget {
  final bool isActive;

  const _ForYouFeedTab({required this.isActive});

  @override
  State<_ForYouFeedTab> createState() => _ForYouFeedTabState();
}

class _ForYouFeedTabState extends State<_ForYouFeedTab>
    with AutomaticKeepAliveClientMixin {
  final List<PostItem> _posts = [];
  final Map<String, String> _diskCachedVideoPaths = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isOfflineMode = false;
  String? _errorMessage;
  dynamic _nextCursor;
  bool _hasMore = false;
  VideoPool? _currentPool;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initFeedWithCacheFirst();
  }

  @override
  void didUpdateWidget(covariant _ForYouFeedTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive && _currentPool != null) {
      if (!widget.isActive) {
        _currentPool?.onVisibilityChanged(primaryIndex: -1, visibilityRatios: const {});
      } else {
        _currentPool?.resumeLastState();
      }
    }
  }

  /// TikTok-Style Cache-First initialization:
  /// 1. Immediately load persisted feed from device storage (instant display, 0ms latency)
  /// 2. Silently revalidate fresh feed from server in the background
  Future<void> _initFeedWithCacheFirst() async {
    final cached = await FeedCacheService.instance.getCachedFeed();
    if (cached.isNotEmpty && mounted) {
      setState(() {
        _posts.clear();
        _posts.addAll(cached);
        _isLoading = false;
      });
      _resolveDiskCachedFiles(cached);
    }

    // Now fetch fresh feed from server
    await _fetchFeed(isInitialSilentRevalidate: cached.isNotEmpty);
  }

  Future<void> _fetchFeed({
    bool isRefresh = false,
    bool isInitialSilentRevalidate = false,
  }) async {
    if (!isRefresh && !isInitialSilentRevalidate && _posts.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await ApiService.instance.post.getFeed(limit: 5);

      if (mounted) {
        setState(() {
          if (isRefresh || isInitialSilentRevalidate) {
            _posts.clear();
          }
          _posts.addAll(response.items);
          _nextCursor = response.nextCursor;
          _hasMore = response.hasMore;
          _isLoading = false;
          _isOfflineMode = false;
          _errorMessage = null;
        });

        // Persist fresh feed to local storage for offline use
        FeedCacheService.instance.saveFeed(_posts);

        // Precache video files to disk via flutter_cache_manager
        _warmupCache(response.items);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_posts.isEmpty) {
            _errorMessage = 'Không có kết nối mạng hoặc lỗi máy chủ: $e';
          } else {
            // We already have cached posts loaded, so switch to offline mode
            _isOfflineMode = true;
          }
        });
      }
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || _isOfflineMode) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await ApiService.instance.post.getFeed(
        cursor: _nextCursor?.toString(),
        limit: 5,
      );

      if (mounted) {
        setState(() {
          _posts.addAll(response.items);
          _nextCursor = response.nextCursor;
          _hasMore = response.hasMore;
          _isLoadingMore = false;
        });

        FeedCacheService.instance.saveFeed(_posts);
        _warmupCache(response.items);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  /// Warm up video files with DefaultCacheManager in background
  void _warmupCache(List<PostItem> items) {
    for (final post in items) {
      if (post.videoUrl.isNotEmpty) {
        DefaultCacheManager().downloadFile(post.videoUrl).then((fileInfo) {
          if (mounted && fileInfo.file.existsSync()) {
            setState(() {
              _diskCachedVideoPaths[post.videoUrl] = fileInfo.file.path;
            });
          }
        }, onError: (_) {});
      }
    }
  }

  /// Check if previously cached files already exist on disk
  Future<void> _resolveDiskCachedFiles(List<PostItem> items) async {
    for (final post in items) {
      if (post.videoUrl.isNotEmpty) {
        final info = await DefaultCacheManager().getFileFromCache(post.videoUrl);
        if (info != null && info.file.existsSync() && mounted) {
          setState(() {
            _diskCachedVideoPaths[post.videoUrl] = info.file.path;
          });
        }
      }
    }
  }

  /// Use bundled onboarding sample post when zero data exists
  void _loadOnboardingSample() {
    final sample = PostItem.sampleOnboarding();
    setState(() {
      _posts.clear();
      _posts.add(sample);
      _isLoading = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Initial loading indicator
    if (_isLoading && _posts.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.orange, strokeWidth: 2.5),
              SizedBox(height: 16),
              Text(
                'Đang chuẩn bị video cho bạn...',
                style: TextStyle(color: Colors.white70, fontSize: 13.5),
              ),
            ],
          ),
        ),
      );
    }

    // Network / Server Error Screen (when no local cache is available)
    if (_errorMessage != null && _posts.isEmpty) {
      return _buildOfflineErrorScreen();
    }

    // Empty State Screen (when backend database has 0 posts)
    if (_posts.isEmpty) {
      return _buildEmptyStateScreen();
    }

    final videoSources = _posts.map((p) => _resolveSource(p)).toList();

    return RefreshIndicator(
      color: Colors.orange,
      backgroundColor: const Color(0xFF1E1E1E),
      onRefresh: () => _fetchFeed(isRefresh: true),
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoPoolScope(
            config: const VideoPoolConfig(
              maxConcurrent: 3,
              preloadCount: 1,
            ),
            adapterFactory: (_) => MediaKitAdapter(),
            sourceResolver: (index) {
              if (index < 0 || index >= _posts.length) return null;
              return _resolveSource(_posts[index]);
            },
            child: Builder(
              builder: (scopedContext) {
                _currentPool = VideoPoolProvider.maybeOf(scopedContext);

                return VideoFeedView(
                  sources: videoSources,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (page) {
                    if (page >= _posts.length - 2 && _hasMore && !_isLoadingMore) {
                      _fetchNextPage();
                    }
                  },
                  itemBuilder: (context, index, source) {
                    final post = _posts[index];
                    return _FeedVideoPage(
                      index: index,
                      post: post,
                      source: source,
                      onLikeChanged: (isLiked, newCount) {
                        setState(() {
                          post.isLiked = isLiked;
                          post.localLikeCount = newCount;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Offline indicator banner at top (TikTok-style)
          if (_isOfflineMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 50,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xCC1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Chế độ ngoại tuyến • Đang phát video đã lưu',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    InkWell(
                      onTap: () => _fetchFeed(isRefresh: true),
                      child: const Text(
                        'Thử lại',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  VideoSource _resolveSource(PostItem post) {
    final cachedPath = _diskCachedVideoPaths[post.videoUrl];
    if (cachedPath != null && cachedPath.isNotEmpty) {
      return VideoSource(
        url: cachedPath,
        type: VideoSourceType.file,
        thumbnailUrl: post.thumbnailUrl.isNotEmpty ? post.thumbnailUrl : null,
      );
    }
    return VideoSource(
      url: post.videoUrl,
      type: VideoSourceType.network,
      thumbnailUrl: post.thumbnailUrl.isNotEmpty ? post.thumbnailUrl : null,
    );
  }

  /// Network Error / No Connection state
  Widget _buildOfflineErrorScreen() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withValues(alpha: 0.12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.35), width: 1.5),
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.orange),
            ),
            const SizedBox(height: 22),
            const Text(
              'Không có kết nối mạng',
              style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Không thể kết nối với máy chủ. Vui lòng kiểm tra đường truyền Wi-Fi hoặc 4G/5G của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _fetchFeed(isRefresh: true),
                  icon: const Icon(Iconsax.refresh, size: 18),
                  label: const Text('Thử lại kết nối', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _loadOnboardingSample,
                  icon: const Icon(Iconsax.play_circle, size: 18, color: Colors.white70),
                  label: const Text('Xem video mẫu', style: TextStyle(color: Colors.white70)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State Screen (Zero posts in database)
  Widget _buildEmptyStateScreen() {
    return RefreshIndicator(
      color: Colors.orange,
      backgroundColor: const Color(0xFF1E1E1E),
      onRefresh: () => _fetchFeed(isRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.withValues(alpha: 0.12),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.35), width: 1.5),
                      ),
                      child: const Icon(Iconsax.cake, size: 48, color: Colors.orange),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Hôm nay gian bếp chưa có món mới',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy là người đầu tiên chia sẻ công thức món ăn đặc biệt của bạn cùng cộng đồng CookConnect!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13.5, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chạm vào dấu (+) trên thanh điều hướng để đăng món mới!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Iconsax.add_circle, size: 18),
                          label: const Text('Đăng món đầu tiên', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _loadOnboardingSample,
                          icon: const Icon(Iconsax.play_circle, size: 18, color: Colors.white70),
                          label: const Text('Xem video mẫu', style: TextStyle(color: Colors.white70)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full screen page representing a single video item in the vertical feed
class _FeedVideoPage extends StatefulWidget {
  final int index;
  final PostItem post;
  final VideoSource source;
  final void Function(bool isLiked, int newCount)? onLikeChanged;

  const _FeedVideoPage({
    required this.index,
    required this.post,
    required this.source,
    this.onLikeChanged,
  });

  @override
  State<_FeedVideoPage> createState() => _FeedVideoPageState();
}

class _FeedVideoPageState extends State<_FeedVideoPage> {
  late bool _isLiked;
  late int _likeCount;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.localLikeCount;
    _isSaved = widget.post.isSaved;
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

  @override
  Widget build(BuildContext context) {
    final pool = VideoPoolProvider.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: pool.reconciliationNotifier,
      builder: (context, _, _) {
        final entry = pool.getEntryForIndex(widget.index);

        return HeartAnimationOverlay(
          onLike: _handleDoubleTapHeart,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => pool.togglePlayPause(widget.index),
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
                      if (lifecycleState == LifecycleState.paused) {
                        return Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        );
                      }
                      if (lifecycleState == LifecycleState.buffering) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                            strokeWidth: 3.0,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
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
          label: _formatCount(widget.post.commentCount),
          onTap: () {
            showCommentsBottomSheet(context);
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

  Widget _buildBottomInfo(BuildContext context) {
    // Placeholder author handle
    final authorHandle = '@chef_cookconnect';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Author handle & chef badge
        Row(
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

        // Prominent "Nguyên liệu" button box
        GestureDetector(
          onTap: () {
            showIngredientsBottomSheet(
              context,
              recipeTitle: widget.post.title,
              ingredients: widget.post.ingredients,
              postId: widget.post.postId,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.25),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Iconsax.bag_2,
                  color: Colors.orange,
                  size: 15,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Nguyên liệu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.post.ingredients.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.post.ingredients.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 10,
                ),
              ],
            ),
          ),
        ),

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

  Widget _buildAvatarWithPlus() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.deepOrangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(Iconsax.user, color: Colors.white, size: 24),
          ),
        ),
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
