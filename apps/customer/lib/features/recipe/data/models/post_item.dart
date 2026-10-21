class PostIngredientItem {
  final String ingredientId;
  final String name;
  final num? amount;
  final String? unit;
  final String? group;
  final int sortOrder;

  const PostIngredientItem({
    required this.ingredientId,
    required this.name,
    this.amount,
    this.unit,
    this.group,
    this.sortOrder = 0,
  });

  factory PostIngredientItem.fromJson(Map<String, dynamic> json) {
    num? parsedAmount;
    if (json['amount'] != null) {
      if (json['amount'] is num) {
        parsedAmount = json['amount'] as num;
      } else if (json['amount'] is String) {
        parsedAmount = num.tryParse(json['amount'] as String);
      }
    }

    return PostIngredientItem(
      ingredientId: json['ingredientId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: parsedAmount,
      unit: json['unit']?.toString(),
      group: json['group']?.toString(),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredientId': ingredientId,
      'name': name,
      if (amount != null) 'amount': amount,
      if (unit != null) 'unit': unit,
      if (group != null) 'group': group,
      'sortOrder': sortOrder,
    };
  }

  String get displayAmount {
    if (amount == null) return '';
    final formattedAmount = amount! % 1 == 0
        ? amount!.toInt().toString()
        : amount!.toString();
    if (unit != null && unit!.isNotEmpty) {
      return '$formattedAmount $unit';
    }
    return formattedAmount;
  }
}

class PostItem {
  final String postId;
  final String userId;
  final String title;
  final String? caption;
  final String? mediaId;
  final String videoUrl;
  final String? playbackUrl;
  final String thumbnailUrl;
  final String? blurHash;
  final int duration;
  final int? videoWidth;
  final int? videoHeight;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int saveCount;
  final bool allowComments;
  final bool allowDuet;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<PostIngredientItem> ingredients;

  // Local interaction states
  bool isLiked;
  bool isSaved;
  int localLikeCount;

  PostItem({
    required this.postId,
    required this.userId,
    required this.title,
    this.caption,
    this.mediaId,
    required this.videoUrl,
    this.playbackUrl,
    required this.thumbnailUrl,
    this.blurHash,
    this.duration = 0,
    this.videoWidth,
    this.videoHeight,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.saveCount = 0,
    this.allowComments = true,
    this.allowDuet = false,
    this.createdAt,
    this.updatedAt,
    this.ingredients = const [],
    this.isLiked = false,
    this.isSaved = false,
    int? localLikeCount,
  }) : localLikeCount = localLikeCount ?? likeCount;

  factory PostItem.fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'] as List<dynamic>? ?? [];
    final parsedIngredients = rawIngredients
        .map((i) => PostIngredientItem.fromJson(i as Map<String, dynamic>))
        .toList();

    return PostItem(
      postId: json['postId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      caption: json['caption']?.toString(),
      mediaId: json['mediaId']?.toString(),
      videoUrl: json['videoUrl']?.toString() ?? '',
      playbackUrl: json['playbackUrl']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      blurHash: json['blurHash']?.toString(),
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      videoWidth: (json['videoWidth'] as num?)?.toInt(),
      videoHeight: (json['videoHeight'] as num?)?.toInt(),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      saveCount: (json['saveCount'] as num?)?.toInt() ?? 0,
      allowComments: json['allowComments'] as bool? ?? true,
      allowDuet: json['allowDuet'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      ingredients: parsedIngredients,
    );
  }

  PostItem copyWith({
    String? postId,
    String? userId,
    String? title,
    String? caption,
    String? mediaId,
    String? videoUrl,
    String? playbackUrl,
    String? thumbnailUrl,
    String? blurHash,
    int? duration,
    int? videoWidth,
    int? videoHeight,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? saveCount,
    bool? allowComments,
    bool? allowDuet,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PostIngredientItem>? ingredients,
    bool? isLiked,
    bool? isSaved,
    int? localLikeCount,
  }) {
    return PostItem(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      caption: caption ?? this.caption,
      mediaId: mediaId ?? this.mediaId,
      videoUrl: videoUrl ?? this.videoUrl,
      playbackUrl: playbackUrl ?? this.playbackUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      blurHash: blurHash ?? this.blurHash,
      duration: duration ?? this.duration,
      videoWidth: videoWidth ?? this.videoWidth,
      videoHeight: videoHeight ?? this.videoHeight,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      saveCount: saveCount ?? this.saveCount,
      allowComments: allowComments ?? this.allowComments,
      allowDuet: allowDuet ?? this.allowDuet,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ingredients: ingredients ?? this.ingredients,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      localLikeCount: localLikeCount ?? this.localLikeCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'title': title,
      if (caption != null) 'caption': caption,
      if (mediaId != null) 'mediaId': mediaId,
      'videoUrl': videoUrl,
      if (playbackUrl != null) 'playbackUrl': playbackUrl,
      'thumbnailUrl': thumbnailUrl,
      if (blurHash != null) 'blurHash': blurHash,
      'duration': duration,
      if (videoWidth != null) 'videoWidth': videoWidth,
      if (videoHeight != null) 'videoHeight': videoHeight,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'saveCount': saveCount,
      'allowComments': allowComments,
      'allowDuet': allowDuet,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
    };
  }

  static PostItem sampleOnboarding() {
    return PostItem(
      postId: 'sample-post-onboarding-1',
      userId: 'chef-cookconnect-official',
      title: 'Bánh Mì Chảo Thập Cẩm Ăn Sáng Siêu Ngon 🍳🥖',
      caption: 'Bữa sáng nhanh gọn thơm ngon nóng hổi với pate, trứng ốp la và xúc xích xèo xèo chuẩn vị!',
      videoUrl: 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=800',
      duration: 30,
      viewCount: 15400,
      likeCount: 4200,
      commentCount: 312,
      shareCount: 120,
      saveCount: 1100,
      ingredients: const [
        PostIngredientItem(
          ingredientId: 'sample-ing-1',
          name: 'Bánh mì giòn rụm',
          amount: 2,
          unit: 'ổ',
          group: 'Nguyên liệu chính',
          sortOrder: 1,
        ),
        PostIngredientItem(
          ingredientId: 'sample-ing-2',
          name: 'Trứng gà ta',
          amount: 2,
          unit: 'quả',
          group: 'Nguyên liệu chính',
          sortOrder: 2,
        ),
        PostIngredientItem(
          ingredientId: 'sample-ing-3',
          name: 'Pate gan béo thơm',
          amount: 80,
          unit: 'g',
          group: 'Topping',
          sortOrder: 3,
        ),
        PostIngredientItem(
          ingredientId: 'sample-ing-4',
          name: 'Xúc xích Đức',
          amount: 2,
          unit: 'cây',
          group: 'Topping',
          sortOrder: 4,
        ),
        PostIngredientItem(
          ingredientId: 'sample-ing-5',
          name: 'Bơ thực vật thơm lừng',
          amount: 20,
          unit: 'g',
          group: 'Gia vị',
          sortOrder: 5,
        ),
      ],
    );
  }
}


class PostFeedResponse {
  final List<PostItem> items;
  final dynamic nextCursor;
  final bool hasMore;

  const PostFeedResponse({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });

  factory PostFeedResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final parsedItems = rawItems
        .map((e) => PostItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return PostFeedResponse(
      items: parsedItems,
      nextCursor: json['nextCursor'],
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
