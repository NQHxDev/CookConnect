import 'package:flutter/material.dart';

class UserSuggestion {
  final String id;
  final String? username;
  final String? displayName;
  final String? avatar;
  final String? bio;
  final bool isVerified;
  final int followersCount;
  final int followingCount;
  final int mutualCount;
  final bool isFollowing;
  final bool isFollower;
  final String? reason;

  const UserSuggestion({
    required this.id,
    this.username,
    this.displayName,
    this.avatar,
    this.bio,
    this.isVerified = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.mutualCount = 0,
    this.isFollowing = false,
    this.isFollower = false,
    this.reason,
  });

  factory UserSuggestion.fromJson(Map<String, dynamic> json) {
    return UserSuggestion(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString(),
      displayName: json['displayName']?.toString() ?? json['fullName']?.toString(),
      avatar: json['avatar']?.toString(),
      bio: json['bio']?.toString(),
      isVerified: json['isVerified'] == true,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      mutualCount: (json['mutualCount'] as num?)?.toInt() ?? 0,
      isFollowing: json['isFollowing'] == true,
      isFollower: json['isFollower'] == true,
      reason: json['reason']?.toString(),
    );
  }

  String get formattedReason {
    if (reason == 'mutual_friends' || mutualCount > 0) {
      return 'Có $mutualCount người theo dõi chung';
    }
    if (reason == 'popular' || followersCount > 0) {
      return 'Phổ biến • Gợi ý cho bạn';
    }
    return 'Gợi ý cho bạn';
  }

  Color get avatarBgColor {
    final colors = [
      const Color(0xFFFB923C),
      const Color(0xFF81C784),
      const Color(0xFFE57373),
      const Color(0xFF64B5F6),
      const Color(0xFFBA68C8),
      const Color(0xFFFFD54F),
      const Color(0xFF4DB6AC),
    ];
    final code = id.isNotEmpty ? id.codeUnits.reduce((a, b) => a + b) : 0;
    return colors[code % colors.length];
  }

  UserSuggestion copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatar,
    String? bio,
    bool? isVerified,
    int? followersCount,
    int? followingCount,
    int? mutualCount,
    bool? isFollowing,
    bool? isFollower,
    String? reason,
  }) {
    return UserSuggestion(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      mutualCount: mutualCount ?? this.mutualCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollower: isFollower ?? this.isFollower,
      reason: reason ?? this.reason,
    );
  }
}
