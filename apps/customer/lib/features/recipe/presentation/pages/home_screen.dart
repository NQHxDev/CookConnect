import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:video_pool/video_pool.dart';

import 'package:cookconnect/core/constants/api_codes/ui_i18n_keys.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/recipe/data/services/home_video_feed_controller.dart';
import 'package:cookconnect/features/recipe/presentation/pages/search_screen.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/feed_video_page.dart';

typedef _FeedVideoPage = FeedVideoPage;

class HomeScreen extends StatefulWidget {
  final bool isActive;

  const HomeScreen({super.key, this.isActive = true});

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
      if (mounted) {
        setState(() {});
        if (widget.isActive) {
          HomeVideoFeedController.instance.updateSubTabActive(_tabController.index == 2);
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      HomeVideoFeedController.instance.setHomeMainTabActive(widget.isActive);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    VideoAnalyticsService.instance.flush();
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
                      Tab(
                        child: ValueListenableBuilder<
                            ({bool visible, bool refreshing, double percentage})>(
                          valueListenable: _feedRefreshState,
                          builder: (context, state, _) {
                            if (state.visible && _tabController.index == 2) {
                              return SizedBox(
                                height: 36,
                                child: FittedBox(
                                  child: CustomRefreshBadge(
                                    isRefreshing: state.refreshing,
                                    percentage: state.percentage,
                                    primaryColor: Colors.orange,
                                  ),
                                ),
                              );
                            }
                            return Text(ApiI18n.text(UiI18nKeys.homeTabForYou));
                          },
                        ),
                      ),
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
                  onPressed: () async {
                    HomeVideoFeedController.instance.pauseFeed();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                    if (widget.isActive && _tabController.index == 2 && mounted) {
                      HomeVideoFeedController.instance.resumeFeed();
                    }
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
              _ForYouFeedTab(isActive: widget.isActive && _tabController.index == 2),
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

/// Pull-to-refresh state of the "Dành cho bạn" feed, consumed by the tab bar
/// so the custom animation shows inside the category label.
final ValueNotifier<({bool visible, bool refreshing, double percentage})>
    _feedRefreshState = ValueNotifier((visible: false, refreshing: false, percentage: 0.0));

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
  void _onRefreshStatusChange(RefreshIndicatorStatus? status) {
    switch (status) {
      case RefreshIndicatorStatus.drag:
        _feedRefreshState.value = (visible: true, refreshing: false, percentage: 0.6);
      case RefreshIndicatorStatus.armed:
        _feedRefreshState.value = (visible: true, refreshing: false, percentage: 1.0);
      case RefreshIndicatorStatus.snap:
      case RefreshIndicatorStatus.refresh:
        _feedRefreshState.value = (visible: true, refreshing: true, percentage: 1.0);
      default:
        _feedRefreshState.value = (visible: false, refreshing: false, percentage: 0.0);
    }
  }

  final List<PostItem> _posts = [];
  final Map<String, String> _diskCachedVideoPaths = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isOfflineMode = false;
  String? _errorMessage;
  dynamic _nextCursor;
  bool _hasMore = false;
  VideoPool? _currentPool;
  int _activePageIndex = 0;

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
    if (oldWidget.isActive != widget.isActive) {
      if (!widget.isActive) {
        HomeVideoFeedController.instance.pauseFeed();
      } else {
        HomeVideoFeedController.instance.resumeFeed();
      }
    }
  }

  @override
  void dispose() {
    HomeVideoFeedController.instance.detachPool();
    super.dispose();
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

  /// Warm up video files with DefaultCacheManager and pre-resolve authors in background
  void _warmupCache(List<PostItem> items) {
    for (final post in items) {
      if (post.userId.trim().isNotEmpty) {
        AuthorProfileService.instance.resolveAuthor(post.userId.trim());
      }
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

    return RefreshIndicator.noSpinner(
      // No default spinner; the custom wave-dots badge is shown in the active
      // category tab instead (see _feedRefreshState).
      onStatusChange: _onRefreshStatusChange,
      onRefresh: () => _fetchFeed(isRefresh: true),
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoPoolScope(
            config: const VideoPoolConfig(
              maxConcurrent: 3,
              preloadCount: 1,
            ),
            adapterFactory: (_) => VideoPlayerAdapter(),
            sourceResolver: (index) {
              if (index < 0 || index >= _posts.length) return null;
              return _resolveSource(_posts[index]);
            },
            child: Builder(
              builder: (scopedContext) {
                _currentPool = VideoPoolProvider.maybeOf(scopedContext);
                if (_currentPool != null) {
                  HomeVideoFeedController.instance.attachPool(
                    _currentPool!,
                    activeIndex: _activePageIndex,
                  );
                }

                return VideoFeedView(
                  sources: videoSources,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (page) {
                    _activePageIndex = page;
                    HomeVideoFeedController.instance.updateActiveIndex(page);
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
    return RefreshIndicator.noSpinner(
      // No default spinner; the custom wave-dots badge is shown in the active
      // category tab instead (see _feedRefreshState).
      onStatusChange: _onRefreshStatusChange,
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

