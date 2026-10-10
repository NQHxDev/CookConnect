import 'dart:convert';

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime createdAt;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 900,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final createdAtMillis = (json['createdAt'] as num?)?.toInt();
    return AuthTokens(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 900,
      createdAt: createdAtMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(createdAtMillis)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'expiresIn': expiresIn,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  /// Checks whether the access token is expired based on JWT payload or issuance duration.
  bool isAccessTokenExpired({Duration buffer = const Duration(seconds: 10)}) {
    if (accessToken.isEmpty) return true;
    if (accessToken.startsWith('demo-')) return false;

    // 1. Check JWT 'exp' timestamp
    final jwtExp = getJwtExpiryDate(accessToken);
    if (jwtExp != null) {
      return DateTime.now().add(buffer).isAfter(jwtExp);
    }

    // 2. Check local duration
    if (expiresIn > 0) {
      final expiryTime = createdAt.add(Duration(seconds: expiresIn));
      return DateTime.now().add(buffer).isAfter(expiryTime);
    }

    return false;
  }

  /// Checks whether the refresh token is expired (if JWT formatted).
  bool isRefreshTokenExpired({Duration buffer = const Duration(seconds: 5)}) {
    if (refreshToken.isEmpty) return true;
    if (refreshToken.startsWith('demo-')) return false;

    final jwtExp = getJwtExpiryDate(refreshToken);
    if (jwtExp != null) {
      return DateTime.now().add(buffer).isAfter(jwtExp);
    }
    return false;
  }

  /// Extracts expiry DateTime from JWT payload if available.
  static DateTime? getJwtExpiryDate(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded);
      if (map is Map<String, dynamic> && map.containsKey('exp')) {
        final expNum = map['exp'];
        if (expNum is num) {
          return DateTime.fromMillisecondsSinceEpoch(expNum.toInt() * 1000);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
