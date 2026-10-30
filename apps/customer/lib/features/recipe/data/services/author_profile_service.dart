import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';

/// Resolved author representation for video posts and creator feeds
class AuthorProfile {
  final String userId;
  final String displayName;
  final String? username;
  final String? avatar;

  const AuthorProfile({
    required this.userId,
    required this.displayName,
    this.username,
    this.avatar,
  });

  /// Formatted handle for UI rendering (e.g. '@anhjkrr7' or '@nguyen_quang_hung')
  String get handle {
    final cleanUsername = username?.trim();
    if (cleanUsername != null && cleanUsername.isNotEmpty) {
      return '@$cleanUsername';
    }
    final cleanName = displayName.trim();
    if (cleanName.isNotEmpty) {
      final asciiName = _removeDiacritics(cleanName);
      final slug = asciiName
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
          .replaceAll(RegExp(r'_+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '')
          .toLowerCase();
      return slug.isNotEmpty ? '@$slug' : '@daubep';
    }
    return '@daubep';
  }

  static String _removeDiacritics(String str) {
    const vietnameseMap = {
      'a': '[àáạảãâầấậẩẫăằắặẳẵ]',
      'e': '[èéẹẻẽêềếệểễ]',
      'i': '[ìíịỉĩ]',
      'o': '[òóọỏõôồốộổỗơờớợởỡ]',
      'u': '[ùúụủũưừứựửữ]',
      'y': '[ỳýỵỷỹ]',
      'd': '[đ]',
      'A': '[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]',
      'E': '[ÈÉẸẺẼÊỀẾỆỂỄ]',
      'I': '[ÌÍỊỈĨ]',
      'O': '[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]',
      'U': '[ÙÚỤỦŨƯỪỨỰỬỮ]',
      'Y': '[ỲÝỴỶỸ]',
      'D': '[Đ]',
    };
    var result = str;
    vietnameseMap.forEach((nonAccent, regex) {
      result = result.replaceAll(RegExp(regex), nonAccent);
    });
    return result;
  }
}

/// Centralized thread-safe cache and resolver for video post authors
class AuthorProfileService {
  AuthorProfileService._();
  static final AuthorProfileService instance = AuthorProfileService._();

  final Map<String, AuthorProfile> _cache = {};
  final Map<String, Future<AuthorProfile?>> _inFlight = {};

  /// Retrieves author synchronously from cache if present
  AuthorProfile? getCached(String userId) {
    final cleanId = userId.trim();
    if (cleanId.isEmpty) return null;
    return _cache[cleanId];
  }

  /// Manually injects or overrides cached author data
  void setCached(String userId, AuthorProfile profile) {
    final cleanId = userId.trim();
    if (cleanId.isNotEmpty) {
      _cache[cleanId] = profile;
    }
  }

  /// Resolves author details with single-flight deduplication and local caching
  Future<AuthorProfile?> resolveAuthor(
    String userId, {
    String? explicitToken,
  }) async {
    final cleanId = userId.trim();
    if (cleanId.isEmpty) return null;

    // 1. Fast match against current authenticated user (matches accountId, userId, or profileId)
    final currentUser = AuthService.instance.currentUser;
    if (currentUser != null) {
      final matchesCurrent =
          cleanId == currentUser.userId ||
          cleanId == currentUser.id ||
          (currentUser.accountId != null && cleanId == currentUser.accountId) ||
          (currentUser.userProfileId != null &&
              cleanId == currentUser.userProfileId);

      if (matchesCurrent) {
        final profile = AuthorProfile(
          userId: cleanId,
          displayName: currentUser.fullName.trim().isNotEmpty
              ? currentUser.fullName.trim()
              : (currentUser.username?.trim().isNotEmpty == true
                    ? currentUser.username!.trim()
                    : 'Tôi'),
          username: currentUser.username?.trim(),
          avatar: currentUser.avatar,
        );
        _cache[cleanId] = profile;
        return profile;
      }
    }

    // 2. Return from in-memory cache if available
    if (_cache.containsKey(cleanId)) {
      return _cache[cleanId];
    }

    // 3. Deduplicate simultaneous requests for the same author
    if (_inFlight.containsKey(cleanId)) {
      return _inFlight[cleanId];
    }

    final future = _fetchAuthor(cleanId, explicitToken: explicitToken);
    _inFlight[cleanId] = future;

    try {
      final profile = await future;
      if (profile != null) {
        _cache[cleanId] = profile;
      }
      return profile;
    } finally {
      _inFlight.remove(cleanId);
    }
  }

  Future<AuthorProfile?> _fetchAuthor(
    String userId, {
    String? explicitToken,
  }) async {
    try {
      final token = explicitToken ?? AuthService.instance.tokens?.accessToken;
      if (token == null || token.isEmpty) return null;

      final res = await ApiService.instance.user.getUserDetails(
        accessToken: token,
        userId: userId,
      );

      if (res.isSuccess && res.user != null) {
        final u = res.user!;
        final resolvedName = u.fullName.trim().isNotEmpty
            ? u.fullName.trim()
            : (u.username?.trim().isNotEmpty == true
                  ? u.username!.trim()
                  : 'Đầu bếp');

        return AuthorProfile(
          userId: userId,
          displayName: resolvedName,
          username: u.username?.trim(),
          avatar: (u.avatar != null && u.avatar!.trim().isNotEmpty)
              ? u.avatar!.trim()
              : null,
        );
      }
    } catch (_) {
      // Ignore network errors in background profile resolution
    }
    return null;
  }

  /// Clears in-memory author cache (e.g. on logout or app reset)
  void clear() {
    _cache.clear();
    _inFlight.clear();
  }
}
