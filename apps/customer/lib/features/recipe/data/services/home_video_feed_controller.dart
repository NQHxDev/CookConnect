import 'package:video_pool/video_pool.dart';

/// Coordinator that controls Home Feed video playback lifecycle across app tabs and sub-tabs.
///
/// Ensures:
/// 1. Instant zero-latency pause & mute when the user leaves the Home tab or navigates away.
/// 2. Ultra-fast pre-warming & resumption signal BEFORE the user lands back on Home tab
///    (anticipating pointer down / tap down events on the navigation bar), eliminating
///    any waiting time or UI hesitation.
class HomeVideoFeedController {
  HomeVideoFeedController._();
  static final HomeVideoFeedController instance = HomeVideoFeedController._();

  VideoPool? _pool;
  int _activePageIndex = 0;
  bool _isHomeMainTabActive = true;
  bool _isForYouSubTabActive = true;
  bool _wasPlayingBeforePause = true;

  int get activePageIndex => _activePageIndex;
  bool get isHomeMainTabActive => _isHomeMainTabActive;
  bool get isForYouSubTabActive => _isForYouSubTabActive;
  bool get wasPlayingBeforePause => _wasPlayingBeforePause;
  bool get shouldPlay => _isHomeMainTabActive && _isForYouSubTabActive;

  /// Backwards compatibility getter
  bool get isTabActive => _isHomeMainTabActive;

  /// Attach the current VideoPool instance from the Home feed
  void attachPool(VideoPool pool, {int activeIndex = 0}) {
    _pool = pool;
    _activePageIndex = activeIndex;
  }

  /// Detach when the feed is disposed
  void detachPool() {
    _pool = null;
  }

  /// Update the current video page index as user scrolls
  void updateActiveIndex(int index) {
    _activePageIndex = index;
  }

  /// Update main tab status (Home tab in bottom navigation bar)
  void setHomeMainTabActive(bool active) {
    _isHomeMainTabActive = active;
    if (!active) {
      pauseFeed();
    } else if (_isForYouSubTabActive) {
      resumeFeed();
    }
  }

  /// Update sub-tab status (e.g. "Dành cho bạn" vs "Bạn bè" in Home tab)
  void updateSubTabActive(bool isForYou) {
    _isForYouSubTabActive = isForYou;
    if (!isForYou) {
      pauseFeed();
    } else if (_isHomeMainTabActive) {
      resumeFeed();
    }
  }

  /// Instantly pause and mute active video playback.
  /// Called immediately when switching away from the Home tab or leaving the For You sub-tab.
  void pauseFeed() {
    final pool = _pool;
    if (pool == null) return;

    final entry = pool.getEntryForIndex(_activePageIndex);
    if (entry != null) {
      _wasPlayingBeforePause = (entry.lifecycleState == LifecycleState.playing);
      // Immediately mute to prevent any audio bleed
      entry.adapter.setVolume(0.0).catchError((_) {});
      entry.adapter.pause().catchError((_) {});
      entry.lifecycleNotifier.value = LifecycleState.paused;
    }
  }

  /// Pre-play / Resume video playback with priority signal.
  ///
  /// Can be triggered on PointerDown / TapDown BEFORE the user finishes tapping
  /// the Home tab icon so the native decoder starts rendering immediately.
  void prePlayFeed() {
    _isHomeMainTabActive = true;
    if (!_isForYouSubTabActive) return;

    final pool = _pool;
    if (pool == null) return;

    final entry = pool.getEntryForIndex(_activePageIndex);
    if (entry != null) {
      // Restore full volume and start playback immediately
      entry.adapter.setVolume(1.0).catchError((_) {});
      entry.adapter.play().catchError((_) {});
      entry.lifecycleNotifier.value = LifecycleState.playing;
    } else {
      // Re-trigger visibility if entry hasn't been assigned
      pool.onVisibilityChanged(
        primaryIndex: _activePageIndex,
        visibilityRatios: {_activePageIndex: 1.0},
      );
    }
  }

  /// Resume playback when Home tab becomes active
  void resumeFeed() {
    prePlayFeed();
  }
}
