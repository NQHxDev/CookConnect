import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookconnect/core/config/api_config.dart';
import 'package:cookconnect/core/network/api_client.dart';
import 'package:cookconnect/core/storage/token_storage_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/recipe/data/models/comment_item.dart';

class CommentService {
  static final CommentService _instance = CommentService._internal();
  factory CommentService() => _instance;
  static CommentService get instance => _instance;

  final ApiClient _client;
  final FlutterSecureStorage _storage;
  final TokenStorageService _tokenStorage;

  // In-memory runtime cache: postId -> List<CommentItem>
  final Map<String, List<CommentItem>> _cache = {};

  CommentService._internal({
    ApiClient? apiClient,
    FlutterSecureStorage? storage,
    TokenStorageService? tokenStorage,
  }) : _client = apiClient ?? ApiClient(),
       _storage =
           storage ??
           const FlutterSecureStorage(
             aOptions: AndroidOptions(resetOnError: true),
             iOptions: IOSOptions(
               accessibility: KeychainAccessibility.first_unlock,
             ),
           ),
       _tokenStorage = tokenStorage ?? SecureTokenStorageService();

  /// Internal storage key for offline persistent comments
  String _storageKey(String postId) => 'cc_comments_$postId';

  /// Pre-populate cache (useful for testing and instant hydration)
  void setCachedComments(String postId, List<CommentItem> comments) {
    _cache[postId] = List<CommentItem>.from(comments);
  }

  /// Fetch real comments for a post
  Future<List<CommentItem>> getComments(String postId) async {
    // 1. Check in-memory cache first
    if (_cache.containsKey(postId)) {
      return List<CommentItem>.from(_cache[postId]!);
    }

    // 2. Try restoring from local secure storage
    try {
      final cachedJson = await _storage.read(key: _storageKey(postId));
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cachedJson) as List<dynamic>;
        final localList = decoded
            .map((item) => CommentItem.fromJson(item as Map<String, dynamic>))
            .toList();
        _cache[postId] = localList;
      }
    } catch (_) {
      // Ignore local storage parsing error
    }

    // 3. Try fetching live from backend API
    try {
      final tokens = await _tokenStorage.getTokens();
      final response = await _client.get(
        ApiConfig.postCommentsPath(postId),
        token: tokens?.accessToken,
      );

      final dynamic data = response['data'] ?? response;
      if (data is List) {
        final apiList = data
            .map((item) => CommentItem.fromJson(item as Map<String, dynamic>))
            .toList();

        // Merge existing local items not yet synced if any
        final existingIds = apiList.map((e) => e.commentId).toSet();
        final localOnly = (_cache[postId] ?? []).where(
          (item) => !existingIds.contains(item.commentId),
        );

        final mergedList = [...localOnly, ...apiList];
        _cache[postId] = mergedList;
        await _saveToStorage(postId, mergedList);
        return List<CommentItem>.from(mergedList);
      }
    } catch (_) {
      // If network fails or endpoint is not yet mounted on backend, fallback to local
    }

    return List<CommentItem>.from(_cache[postId] ?? []);
  }

  /// Post a new real comment authored by the current user
  Future<CommentItem> addComment({
    required String postId,
    required String content,
  }) async {
    final user = AuthService.instance.currentUser;
    final currentUserId =
        user?.id ?? user?.userId ?? 'guest_${Random().nextInt(10000)}';
    final username = (user?.username != null && user!.username!.isNotEmpty)
        ? user.username!
        : (user?.fullName.isNotEmpty == true ? user!.fullName : 'Người dùng');
    final displayName = user?.fullName;
    final avatarUrl = user?.avatar;

    final newComment = CommentItem(
      commentId:
          'cmt_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      postId: postId,
      userId: currentUserId,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      content: content.trim(),
      likes: 0,
      isLiked: false,
      createdAt: DateTime.now(),
    );

    // Optimistically update memory cache
    final currentList = _cache.putIfAbsent(postId, () => []);
    currentList.insert(0, newComment);
    _saveToStorage(postId, currentList);

    // Optimistically sync to backend API in background without blocking UI
    _syncCommentToBackend(postId, content.trim());

    return newComment;
  }

  Future<void> _syncCommentToBackend(String postId, String content) async {
    try {
      final tokens = await _tokenStorage.getTokens();
      await _client.post(
        ApiConfig.postCommentsPath(postId),
        body: {'content': content},
        token: tokens?.accessToken,
      );
    } catch (_) {
      // Backend sync error handled gracefully; local comment is preserved
    }
  }

  /// Toggle like status for a comment
  Future<void> toggleLike({
    required String postId,
    required String commentId,
  }) async {
    final list = _cache[postId];
    if (list == null) return;

    final index = list.indexWhere((c) => c.commentId == commentId);
    if (index == -1) return;

    final item = list[index];
    final newIsLiked = !item.isLiked;
    final newLikes = item.likes + (newIsLiked ? 1 : -1);

    list[index] = item.copyWith(
      isLiked: newIsLiked,
      likes: newLikes < 0 ? 0 : newLikes,
    );

    await _saveToStorage(postId, list);

    // Attempt backend sync if available
    try {
      final tokens = await _tokenStorage.getTokens();
      await _client.post(
        '${ApiConfig.postCommentsPath(postId)}/$commentId/like',
        token: tokens?.accessToken,
      );
    } catch (_) {
      // Offline/fallback
    }
  }

  /// Helper to get current known comment count
  int getCommentCount(String postId, int fallbackCount) {
    if (_cache.containsKey(postId)) {
      return _cache[postId]!.length;
    }
    return fallbackCount;
  }

  Future<void> _saveToStorage(String postId, List<CommentItem> items) async {
    try {
      final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
      await _storage.write(key: _storageKey(postId), value: encoded);
    } catch (_) {
      // Storage error ignored
    }
  }
}
