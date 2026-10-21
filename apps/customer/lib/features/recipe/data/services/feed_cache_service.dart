import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookconnect/features/recipe/data/models/post_item.dart';

/// Local offline cache service for video posts feed.
///
/// Stores feed metadata in secure storage so that when the device is offline,
/// previous videos and their recipe details can be played back instantly.
class FeedCacheService {
  static const String _keyCachedFeed = 'cookconnect_cached_feed_posts';
  static final FeedCacheService instance = FeedCacheService._internal();

  FeedCacheService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Persists recent feed posts to offline cache.
  Future<void> saveFeed(List<PostItem> posts) async {
    try {
      if (posts.isEmpty) return;
      final toSave = posts.take(15).map((p) => p.toJson()).toList();
      await _storage.write(key: _keyCachedFeed, value: jsonEncode(toSave));
    } catch (_) {
      // Graceful error handling
    }
  }

  /// Retrieves cached feed posts when offline.
  Future<List<PostItem>> getCachedFeed() async {
    try {
      final jsonStr = await _storage.read(key: _keyCachedFeed);
      if (jsonStr == null || jsonStr.trim().isEmpty) return [];
      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded
            .map((item) => PostItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Clears feed cache.
  Future<void> clearCache() async {
    try {
      await _storage.delete(key: _keyCachedFeed);
    } catch (_) {}
  }
}
