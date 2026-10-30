class AuthUser {
  final String id;
  final String? accountId;
  final String? userId;
  final String? userProfileId;
  final String email;
  final String fullName;
  final String? username;
  final String? gender;
  final String? dateOfBirth;
  final String? bio;
  final String? avatar;
  final String? coverImage;
  final String? website;
  final String? location;
  final String? address;
  final List<String> roles;
  final String? status;
  final bool isEmailVerified;
  final int videoCount;
  final int followerCount;
  final int followingCount;
  final int likeCount;

  AuthUser({
    required this.id,
    this.accountId,
    this.userId,
    this.userProfileId,
    required this.email,
    required this.fullName,
    this.username,
    this.gender,
    this.dateOfBirth,
    this.bio,
    this.avatar,
    this.coverImage,
    this.website,
    this.location,
    this.address,
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

    // 3. User Profile Identifier (primary key of user_profiles table)
    final userProfileId = profile?['id']?.toString() ??
        json['userProfileId']?.toString();

    // 4. Disambiguate accountId vs userId
    // - Auth microservice (/api/v1/auth/*): returns Account { id, email, ... } -> accountId
    // - User microservice (/api/v1/users/*): returns User { id (User PK), userId (Account FK), profile, stats }
    // - Storage cache (toJson): persists accountId, userId, userProfileId explicitly
    final explicitAccountId = json['accountId']?.toString();
    final explicitUserId = json['userId']?.toString();
    final rawId = json['id']?.toString();
    final rawSub = json['sub']?.toString();

    String? resolvedAccountId;
    String? resolvedUserId;

    if (explicitAccountId != null && explicitAccountId.isNotEmpty) {
      resolvedAccountId = explicitAccountId;
      resolvedUserId = explicitUserId ?? rawId;
    } else if (profile != null ||
        stats != null ||
        (rawId != null &&
            explicitUserId != null &&
            rawId.isNotEmpty &&
            explicitUserId.isNotEmpty &&
            rawId != explicitUserId)) {
      // User microservice structure: id = User PK (userId), userId = Account FK (accountId)
      resolvedUserId = rawId;
      resolvedAccountId = explicitUserId ?? rawSub;
    } else {
      // Auth microservice structure: id/sub = Account PK (accountId)
      resolvedAccountId = rawId ?? rawSub;
      resolvedUserId = (explicitUserId != null && explicitUserId != resolvedAccountId)
          ? explicitUserId
          : null;
    }

    final id = (resolvedUserId != null && resolvedUserId.isNotEmpty)
        ? resolvedUserId
        : ((resolvedAccountId != null && resolvedAccountId.isNotEmpty)
            ? resolvedAccountId
            : (rawId ?? ''));

    // 5. Email address
    final email = json['email']?.toString() ??
        profile?['email']?.toString() ??
        '';

    // 6. Display Name / Full Name
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

    // 7. Username
    final username = json['username']?.toString() ??
        profile?['username']?.toString();

    // 8. Profile details
    final gender = json['gender']?.toString() ?? profile?['gender']?.toString();
    final dateOfBirth = json['dateOfBirth']?.toString() ??
        profile?['dateOfBirth']?.toString();
    final bio = json['bio']?.toString() ?? profile?['bio']?.toString();
    final avatar = json['avatar']?.toString() ?? profile?['avatar']?.toString();
    final coverImage = json['coverImage']?.toString() ?? profile?['coverImage']?.toString();
    final website = json['website']?.toString() ?? profile?['website']?.toString();
    final location = json['location']?.toString() ?? profile?['location']?.toString();
    final address = json['address']?.toString() ?? profile?['address']?.toString();

    // 9. Roles
    final roles = (json['roles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const ['USER'];

    // 10. Stats
    final videoCount = (json['videoCount'] as num?)?.toInt() ??
        (stats?['recipesCount'] as num?)?.toInt() ??
        (json['recipesCount'] as num?)?.toInt() ??
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
        (stats?['likesCount'] as num?)?.toInt() ??
        (stats?['likeCount'] as num?)?.toInt() ??
        (json['likesCount'] as num?)?.toInt() ??
        0;

    return AuthUser(
      id: id,
      accountId: resolvedAccountId,
      userId: resolvedUserId,
      userProfileId: userProfileId,
      email: email,
      fullName: name,
      username: username,
      gender: gender,
      dateOfBirth: dateOfBirth,
      bio: bio,
      avatar: avatar,
      coverImage: coverImage,
      website: website,
      location: location,
      address: address,
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
    if (accountId != null) 'accountId': accountId,
    if (userId != null) 'userId': userId,
    if (userProfileId != null) 'userProfileId': userProfileId,
    'email': email,
    'fullName': fullName,
    'displayName': fullName,
    if (username != null) 'username': username,
    if (gender != null) 'gender': gender,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    if (bio != null) 'bio': bio,
    if (avatar != null) 'avatar': avatar,
    if (coverImage != null) 'coverImage': coverImage,
    if (website != null) 'website': website,
    if (location != null) 'location': location,
    if (address != null) 'address': address,
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
    String? accountId,
    String? userId,
    String? userProfileId,
    String? email,
    String? fullName,
    String? username,
    String? gender,
    String? dateOfBirth,
    String? bio,
    String? avatar,
    String? coverImage,
    String? website,
    String? location,
    String? address,
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
      accountId: accountId ?? this.accountId,
      userId: userId ?? this.userId,
      userProfileId: userProfileId ?? this.userProfileId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      coverImage: coverImage ?? this.coverImage,
      website: website ?? this.website,
      location: location ?? this.location,
      address: address ?? this.address,
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
