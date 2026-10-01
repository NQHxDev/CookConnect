class Ingredient {
  final String id;
  final String name;
  final String amount;
  bool isChecked;

  Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    this.isChecked = false,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    String? amount,
    bool? isChecked,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

class CookingStep {
  final int stepNumber;
  final String title;
  final String description;
  final String? tip;
  final int? durationMinutes;

  const CookingStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.tip,
    this.durationMinutes,
  });
}

class Recipe {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String chefName;
  final String chefAvatar;
  final double rating;
  final int reviewsCount;
  final int cookTimeMinutes;
  final String difficulty; // 'Dễ', 'Trung bình', 'Khó'
  final int calories;
  final int servings;
  final List<String> tags;
  final List<Ingredient> ingredients;
  final List<CookingStep> steps;
  bool isFavorite;
  bool isSaved;
  final DateTime? lastViewedAt;
  final int cookedCount;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.chefName,
    required this.chefAvatar,
    required this.rating,
    required this.reviewsCount,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.calories,
    required this.servings,
    required this.tags,
    required this.ingredients,
    required this.steps,
    this.isFavorite = false,
    this.isSaved = false,
    this.lastViewedAt,
    this.cookedCount = 0,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? category,
    String? imageUrl,
    String? chefName,
    String? chefAvatar,
    double? rating,
    int? reviewsCount,
    int? cookTimeMinutes,
    String? difficulty,
    int? calories,
    int? servings,
    List<String>? tags,
    List<Ingredient>? ingredients,
    List<CookingStep>? steps,
    bool? isFavorite,
    bool? isSaved,
    DateTime? lastViewedAt,
    int? cookedCount,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      chefName: chefName ?? this.chefName,
      chefAvatar: chefAvatar ?? this.chefAvatar,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      difficulty: difficulty ?? this.difficulty,
      calories: calories ?? this.calories,
      servings: servings ?? this.servings,
      tags: tags ?? this.tags,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      isFavorite: isFavorite ?? this.isFavorite,
      isSaved: isSaved ?? this.isSaved,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      cookedCount: cookedCount ?? this.cookedCount,
    );
  }
}

class RecipeCollection {
  final String id;
  final String name;
  final String description;
  final String coverImageUrl;
  final int colorValue;
  final List<String> recipeIds;

  RecipeCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImageUrl,
    required this.colorValue,
    required this.recipeIds,
  });
}

class ShoppingItem {
  final String id;
  final String name;
  final String amount;
  final String recipeSource;
  bool isCompleted;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.recipeSource,
    this.isCompleted = false,
  });
}
