class AuthUser {
  final String id;
  final String email;
  final String fullName;
  final String? username;
  final String? gender;
  final String? dateOfBirth;
  final String? bio;
  final String? avatar;
  final List<String> roles;
  final String? status;
  final bool isEmailVerified;
  final int videoCount;
  final int followerCount;
  final int followingCount;
  final int likeCount;

  AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.username,
    this.gender,
    this.dateOfBirth,
    this.bio,
    this.avatar,
    this.roles = const ['USER'],
    this.status,
    this.isEmailVerified = false,
    this.videoCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.likeCount = 0,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    // 1. Support nested profile object (from User microservice)
    final profile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : null;

    // 2. Support nested stats object (from User microservice)
    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : null;

    // 3. User Identifier (supports id, userId, sub)
    final id = json['id']?.toString() ??
        json['userId']?.toString() ??
        json['sub']?.toString() ??
        '';

    // 4. Email address
    final email = json['email']?.toString() ??
        profile?['email']?.toString() ??
        '';

    // 5. Display Name / Full Name
    final rawName = json['fullName'] ??
        json['displayName'] ??
        json['name'] ??
        profile?['displayName'] ??
        profile?['fullName'] ??
        profile?['name'];

    final name = rawName != null && rawName.toString().trim().isNotEmpty
        ? rawName.toString().trim()
        : (json['username'] != null && json['username'].toString().trim().isNotEmpty
            ? json['username'].toString().trim()
            : (email.isNotEmpty
                ? email.split('@').first
                : ''));

    // 6. Username
    final username = json['username']?.toString() ??
        profile?['username']?.toString();

    // 7. Profile details
    final gender = json['gender']?.toString() ?? profile?['gender']?.toString();
    final dateOfBirth = json['dateOfBirth']?.toString() ??
        profile?['dateOfBirth']?.toString();
    final bio = json['bio']?.toString() ?? profile?['bio']?.toString();
    final avatar = json['avatar']?.toString() ?? profile?['avatar']?.toString();

    // 8. Roles
    final roles = (json['roles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const ['USER'];

    // 9. Stats
    final videoCount = (json['videoCount'] as num?)?.toInt() ??
        (stats?['postsCount'] as num?)?.toInt() ??
        (json['postsCount'] as num?)?.toInt() ??
        0;

    final followerCount = (json['followerCount'] as num?)?.toInt() ??
        (stats?['followersCount'] as num?)?.toInt() ??
        (json['followersCount'] as num?)?.toInt() ??
        0;

    final followingCount = (json['followingCount'] as num?)?.toInt() ??
        (stats?['followingCount'] as num?)?.toInt() ??
        (json['followingCount'] as num?)?.toInt() ??
        0;

    final likeCount = (json['likeCount'] as num?)?.toInt() ??
        (stats?['likeCount'] as num?)?.toInt() ??
        0;

    return AuthUser(
      id: id,
      email: email,
      fullName: name,
      username: username,
      gender: gender,
      dateOfBirth: dateOfBirth,
      bio: bio,
      avatar: avatar,
      roles: roles,
      status: json['status']?.toString(),
      isEmailVerified: json['isEmailVerified'] == true,
      videoCount: videoCount,
      followerCount: followerCount,
      followingCount: followingCount,
      likeCount: likeCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'displayName': fullName,
    if (username != null) 'username': username,
    if (gender != null) 'gender': gender,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    if (bio != null) 'bio': bio,
    if (avatar != null) 'avatar': avatar,
    'roles': roles,
    'status': status,
    'isEmailVerified': isEmailVerified,
    'videoCount': videoCount,
    'followerCount': followerCount,
    'followingCount': followingCount,
    'likeCount': likeCount,
  };

  AuthUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? gender,
    String? dateOfBirth,
    String? bio,
    String? avatar,
    List<String>? roles,
    String? status,
    bool? isEmailVerified,
    int? videoCount,
    int? followerCount,
    int? followingCount,
    int? likeCount,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      videoCount: videoCount ?? this.videoCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}
