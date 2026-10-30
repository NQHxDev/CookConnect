import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_pool/video_pool.dart';
import 'package:cookconnect/features/recipe/data/models/post_item.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/feed_video_page.dart';

/// Full-screen vertical swipe video player feed for user posted videos.
class UserVideoFeedScreen extends StatefulWidget {
  final List<PostItem> posts;
  final int initialIndex;
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatar;
  final PlayerAdapter Function(int)? adapterFactory;

  const UserVideoFeedScreen({
    super.key,
    required this.posts,
    this.initialIndex = 0,
    this.authorName,
    this.authorUsername,
    this.authorAvatar,
    this.adapterFactory,
  });

  @override
  State<UserVideoFeedScreen> createState() => _UserVideoFeedScreenState();
}

class _UserVideoFeedScreenState extends State<UserVideoFeedScreen> {
  final Map<String, String> _diskCachedVideoPaths = {};

  @override
  void initState() {
    super.initState();
    _resolveDiskCachedFiles(widget.posts);
  }

  PlayerAdapter _createAdapter(int index) {
    if (widget.adapterFactory != null) {
      return widget.adapterFactory!(index);
    }
    try {
      return VideoPlayerAdapter();
    } catch (_) {
      return _NoopVideoAdapter();
    }
  }

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

  VideoSource _resolveSource(PostItem post) {
    final cachedPath = _diskCachedVideoPaths[post.videoUrl];
    if (cachedPath != null && cachedPath.isNotEmpty) {
      return VideoSource(
        url: cachedPath,
        type: VideoSourceType.file,
      );
    }
    return VideoSource(
      url: post.videoUrl,
      type: VideoSourceType.network,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Không có video nào',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final videoSources = widget.posts.map(_resolveSource).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          VideoPoolScope(
            config: const VideoPoolConfig(
              maxConcurrent: 3,
              preloadCount: 1,
            ),
            adapterFactory: _createAdapter,
            sourceResolver: (index) {
              if (index < 0 || index >= widget.posts.length) return null;
              return _resolveSource(widget.posts[index]);
            },
            child: Builder(
              builder: (scopedContext) {
                return VideoFeedView(
                  sources: videoSources,
                  initialPage: widget.initialIndex.clamp(0, widget.posts.length - 1),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index, source) {
                    final post = widget.posts[index];
                    return FeedVideoPage(
                      index: index,
                      post: post,
                      source: source,
                      authorName: widget.authorName,
                      authorUsername: widget.authorUsername,
                      authorAvatar: widget.authorAvatar,
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

          // Floating Back Button at top-left
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoopVideoAdapter extends PlayerAdapter {
  final _notifier = ValueNotifier<PlayerState>(
    const PlayerState(phase: PlaybackPhase.idle),
  );

  @override
  ValueNotifier<PlayerState> get stateNotifier => _notifier;

  @override
  Widget get videoWidget => const SizedBox.shrink();

  @override
  Duration get position => Duration.zero;

  @override
  Duration get duration => Duration.zero;

  @override
  int get estimatedMemoryBytes => 0;

  @override
  bool get isReusable => true;

  @override
  Future<void> prepare() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> swapSource(VideoSource source) async {}

  @override
  Future<void> seekTo(Duration position) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> setLooping(bool loop) async {}

  @override
  Future<void> dispose() async {
    _notifier.dispose();
  }
}
