class CreatePostIngredientDto {
  final String name;
  final num? amount;
  final String? unit;
  final String? group;
  final int sortOrder;
  final String? catalogIngredientId;

  const CreatePostIngredientDto({
    required this.name,
    this.amount,
    this.unit,
    this.group,
    this.sortOrder = 0,
    this.catalogIngredientId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (amount != null) 'amount': amount,
      if (unit != null && unit!.isNotEmpty) 'unit': unit,
      if (group != null && group!.isNotEmpty) 'group': group,
      'sortOrder': sortOrder,
      if (catalogIngredientId != null && catalogIngredientId!.isNotEmpty)
        'catalogIngredientId': catalogIngredientId,
    };
  }
}

class CreateRecipeStepDto {
  final int stepNumber;
  final String instruction;
  final String? title;
  final int? timestampSeconds;
  final String? imageUrl;
  final String? mediaId;

  const CreateRecipeStepDto({
    required this.stepNumber,
    required this.instruction,
    this.title,
    this.timestampSeconds,
    this.imageUrl,
    this.mediaId,
  });

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'instruction': instruction,
      if (title != null && title!.isNotEmpty) 'title': title,
      if (timestampSeconds != null) 'timestampSeconds': timestampSeconds,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
      if (mediaId != null && mediaId!.isNotEmpty) 'mediaId': mediaId,
    };
  }
}

class CreateRecipeDto {
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty; // EASY, MEDIUM, HARD, EXPERT
  final int? calories;
  final String? cuisine;
  final String? chefTips;
  final List<CreateRecipeStepDto>? steps;

  const CreateRecipeDto({
    this.prepTimeMinutes = 0,
    this.cookTimeMinutes = 0,
    this.servings = 1,
    this.difficulty = 'EASY',
    this.calories,
    this.cuisine,
    this.chefTips,
    this.steps,
  });

  Map<String, dynamic> toJson() {
    return {
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      if (calories != null) 'calories': calories,
      if (cuisine != null && cuisine!.isNotEmpty) 'cuisine': cuisine,
      if (chefTips != null && chefTips!.isNotEmpty) 'chefTips': chefTips,
      if (steps != null && steps!.isNotEmpty)
        'steps': steps!.map((s) => s.toJson()).toList(),
    };
  }
}

class CreatePostDto {
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final num duration;
  final String? caption;
  final String? mediaId;
  final String? playbackUrl;
  final String? blurHash;
  final int? videoWidth;
  final int? videoHeight;
  final String visibility; // PUBLIC, FOLLOWERS_ONLY, PRIVATE
  final bool allowComments;
  final bool allowDuet;
  final List<String>? tags;
  final List<String>? mentionedUserIds;
  final List<String>? categoryIds;
  final List<CreatePostIngredientDto>? ingredients;
  final CreateRecipeDto? recipe;

  const CreatePostDto({
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    this.caption,
    this.mediaId,
    this.playbackUrl,
    this.blurHash,
    this.videoWidth,
    this.videoHeight,
    this.visibility = 'PUBLIC',
    this.allowComments = true,
    this.allowDuet = false,
    this.tags,
    this.mentionedUserIds,
    this.categoryIds,
    this.ingredients,
    this.recipe,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      if (caption != null && caption!.isNotEmpty) 'caption': caption,
      if (mediaId != null && mediaId!.isNotEmpty) 'mediaId': mediaId,
      if (playbackUrl != null && playbackUrl!.isNotEmpty)
        'playbackUrl': playbackUrl,
      if (blurHash != null && blurHash!.isNotEmpty) 'blurHash': blurHash,
      if (videoWidth != null) 'videoWidth': videoWidth,
      if (videoHeight != null) 'videoHeight': videoHeight,
      'visibility': visibility,
      'allowComments': allowComments,
      'allowDuet': allowDuet,
      if (tags != null && tags!.isNotEmpty) 'tags': tags,
      if (mentionedUserIds != null && mentionedUserIds!.isNotEmpty)
        'mentionedUserIds': mentionedUserIds,
      if (categoryIds != null && categoryIds!.isNotEmpty)
        'categoryIds': categoryIds,
      if (ingredients != null && ingredients!.isNotEmpty)
        'ingredients': ingredients!.map((i) => i.toJson()).toList(),
      if (recipe != null) 'recipe': recipe!.toJson(),
    };
  }
}
