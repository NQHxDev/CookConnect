import 'package:flutter/foundation.dart';
import 'package:cookconnect/features/recipe/data/models/post_item.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/mock/mock_recipes.dart';

class RecipeDataService with ChangeNotifier {
  static final RecipeDataService instance = RecipeDataService._internal();

  RecipeDataService._internal() {
    _initData();
  }

  final List<Recipe> _recipes = [];
  final List<RecipeCollection> _collections = [];
  final List<ShoppingItem> _shoppingList = [];

  /// Các bài Post (video công thức) đã được thêm nguyên liệu vào danh sách đi chợ,
  /// dùng để trang Đi chợ có thể mở ngược lại video/nguyên liệu gốc.
  final Map<String, PostItem> _linkedPosts = {};

  List<Recipe> get allRecipes => List.unmodifiable(_recipes);
  List<Recipe> get favoriteRecipes =>
      _recipes.where((r) => r.isFavorite).toList();
  List<Recipe> get historyRecipes =>
      _recipes.where((r) => r.lastViewedAt != null).toList()
        ..sort((a, b) => b.lastViewedAt!.compareTo(a.lastViewedAt!));
  List<Recipe> get cookedRecipes =>
      _recipes.where((r) => r.cookedCount > 0).toList()
        ..sort((a, b) => b.cookedCount.compareTo(a.cookedCount));
  List<RecipeCollection> get collections => List.unmodifiable(_collections);
  List<ShoppingItem> get shoppingList => List.unmodifiable(_shoppingList);

  void toggleFavorite(String recipeId) {
    final index = _recipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _recipes[index] = _recipes[index].copyWith(
        isFavorite: !_recipes[index].isFavorite,
      );
      notifyListeners();
    }
  }

  void updateRecipe(Recipe updated) {
    final index = _recipes.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _recipes[index] = updated;
      notifyListeners();
    }
  }

  void markAsCooked(String recipeId) {
    final index = _recipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _recipes[index] = _recipes[index].copyWith(
        cookedCount: _recipes[index].cookedCount + 1,
        lastViewedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void addRecipe(Recipe recipe) {
    _recipes.insert(0, recipe);
    notifyListeners();
  }

  void addCollection(RecipeCollection collection) {
    _collections.add(collection);
    notifyListeners();
  }

  void addShoppingItems(List<ShoppingItem> items) {
    for (final item in items) {
      _mergeOrAddShoppingItem(item);
    }
    notifyListeners();
  }

  void addShoppingItem(ShoppingItem item) {
    _mergeOrAddShoppingItem(item);
    notifyListeners();
  }

  /// Gộp nguyên liệu trùng (cùng productId hoặc cùng tên) và tăng số lượng.
  void _mergeOrAddShoppingItem(ShoppingItem item) {
    final name = item.name.trim().toLowerCase();
    final index = _shoppingList.indexWhere((e) {
      if (item.productId != null && e.productId != null) {
        return e.productId == item.productId;
      }
      return e.productId == item.productId &&
          e.name.trim().toLowerCase() == name;
    });
    if (index == -1) {
      _shoppingList.add(item);
    } else {
      final existing = _shoppingList[index];
      existing.quantity += item.quantity;
      existing.isCompleted = false;
    }
  }

  // ==========================================
  // LIÊN KẾT FEED <-> ĐI CHỢ
  // ==========================================

  static String normalizeName(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Tìm món trong danh sách đi chợ khớp với tên nguyên liệu của công thức
  /// (khớp chính xác, hoặc tên này chứa tên kia - VD "Trứng gà" ~ "Trứng gà ta 10 quả").
  ShoppingItem? findShoppingItemForIngredient(String ingredientName) {
    final target = normalizeName(ingredientName);
    if (target.isEmpty) return null;
    for (final item in _shoppingList) {
      if (normalizeName(item.name) == target) return item;
    }
    if (target.length < 3) return null;
    for (final item in _shoppingList) {
      final name = normalizeName(item.name);
      if (name.length >= 3 && (name.contains(target) || target.contains(name))) {
        return item;
      }
    }
    return null;
  }

  bool isIngredientInShoppingList(String ingredientName) =>
      findShoppingItemForIngredient(ingredientName) != null;

  void registerLinkedPost(PostItem post) {
    if (post.postId.isEmpty) return;
    _linkedPosts[post.postId] = post;
  }

  PostItem? linkedPost(String? postId) =>
      postId == null ? null : _linkedPosts[postId];

  /// Xoá nguyên liệu (thuộc công thức) khỏi danh sách đi chợ.
  void removeIngredientFromShoppingList(String ingredientName) {
    final item = findShoppingItemForIngredient(ingredientName);
    if (item == null) return;
    _shoppingList.remove(item);
    notifyListeners();
  }

  void toggleShoppingItem(String id) {
    final index = _shoppingList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _shoppingList[index].isCompleted = !_shoppingList[index].isCompleted;
      notifyListeners();
    }
  }

  void markShoppingItemsCompleted(List<String> ids) {
    for (final item in _shoppingList) {
      if (ids.contains(item.id)) {
        item.isCompleted = true;
      }
    }
    notifyListeners();
  }

  void markAllShoppingItemsCompleted({required bool completed}) {
    for (final item in _shoppingList) {
      item.isCompleted = completed;
    }
    notifyListeners();
  }

  void updateShoppingItemQuantity(String id, int delta) {
    final index = _shoppingList.indexWhere((item) => item.id == id);
    if (index != -1) {
      final newQty = (_shoppingList[index].quantity + delta).clamp(1, 99);
      _shoppingList[index].quantity = newQty;
      notifyListeners();
    }
  }

  void removeShoppingItem(String id) {
    _shoppingList.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearCompletedShoppingItems() {
    _shoppingList.removeWhere((item) => item.isCompleted);
    notifyListeners();
  }

  void clearAllShoppingItems() {
    _shoppingList.clear();
    notifyListeners();
  }

  void _initData() {
    _recipes.addAll(getInitialRecipes());
    _collections.addAll(getInitialCollections());
  }
}
