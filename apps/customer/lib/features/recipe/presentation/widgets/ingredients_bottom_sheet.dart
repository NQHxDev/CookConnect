import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/network/api_service.dart';

void showIngredientsBottomSheet(
  BuildContext context, {
  required String recipeTitle,
  required List<PostIngredientItem> ingredients,
  String? postId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => IngredientsBottomSheet(
      recipeTitle: recipeTitle,
      ingredients: ingredients,
      postId: postId,
    ),
  );
}

class IngredientsBottomSheet extends StatefulWidget {
  final String recipeTitle;
  final List<PostIngredientItem> ingredients;
  final String? postId;

  const IngredientsBottomSheet({
    super.key,
    required this.recipeTitle,
    required this.ingredients,
    this.postId,
  });

  @override
  State<IngredientsBottomSheet> createState() => _IngredientsBottomSheetState();
}

class _IngredientsBottomSheetState extends State<IngredientsBottomSheet> {
  final Set<String> _checkedIngredients = {};
  late List<PostIngredientItem> _ingredients;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ingredients = List.from(widget.ingredients);
    if (_ingredients.isEmpty && widget.postId != null && widget.postId!.isNotEmpty) {
      _loadIngredients();
    }
  }

  Future<void> _loadIngredients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetched = await ApiService.instance.post.getPostIngredients(widget.postId!);
      if (mounted) {
        setState(() {
          _ingredients = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không thể tải nguyên liệu: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.75;

    // Group ingredients by group
    final Map<String, List<PostIngredientItem>> grouped = {};
    for (final item in _ingredients) {
      final groupName = (item.group != null && item.group!.trim().isNotEmpty)
          ? item.group!.trim()
          : 'Nguyên liệu khác';
      grouped.putIfAbsent(groupName, () => []).add(item);
    }

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.bag_2,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nguyên liệu món ăn',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.recipeTitle.isNotEmpty
                              ? widget.recipeTitle
                              : '${_ingredients.length} nguyên liệu cần chuẩn bị',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2C2C2C), height: 1),

            // Content
            Flexible(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: Colors.orange),
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Iconsax.info_circle, color: Colors.redAccent, size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: _loadIngredients,
                                  icon: const Icon(Iconsax.refresh, color: Colors.orange, size: 16),
                                  label: const Text('Thử lại', style: TextStyle(color: Colors.orange)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _ingredients.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Iconsax.note_remove,
                                      size: 48,
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Chưa có danh sách nguyên liệu cụ thể',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shrinkWrap: true,
                              itemCount: grouped.keys.length,
                              itemBuilder: (context, groupIndex) {
                                final groupTitle = grouped.keys.elementAt(groupIndex);
                                final itemsInGroup = grouped[groupTitle]!;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8, bottom: 6),
                                      child: Text(
                                        groupTitle,
                                        style: const TextStyle(
                                          color: Colors.orangeAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    ...itemsInGroup.map((ingredient) {
                                      final isChecked =
                                          _checkedIngredients.contains(ingredient.ingredientId);
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (isChecked) {
                                              _checkedIngredients.remove(ingredient.ingredientId);
                                            } else {
                                              _checkedIngredients.add(ingredient.ingredientId);
                                            }
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 4,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isChecked
                                                    ? Icons.check_circle_rounded
                                                    : Icons.radio_button_unchecked_rounded,
                                                color: isChecked
                                                    ? Colors.orange
                                                    : Colors.white.withValues(alpha: 0.4),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  ingredient.name,
                                                  style: TextStyle(
                                                    color: isChecked
                                                        ? Colors.white.withValues(alpha: 0.45)
                                                        : Colors.white,
                                                    fontSize: 14.5,
                                                    decoration: isChecked
                                                        ? TextDecoration.lineThrough
                                                        : null,
                                                    decorationColor:
                                                        Colors.white.withValues(alpha: 0.45),
                                                  ),
                                                ),
                                              ),
                                              if (ingredient.displayAmount.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withValues(alpha: 0.08),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: Colors.white.withValues(alpha: 0.12),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    ingredient.displayAmount,
                                                    style: TextStyle(
                                                      color: isChecked
                                                          ? Colors.white.withValues(alpha: 0.4)
                                                          : Colors.white.withValues(alpha: 0.9),
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              },
                            ),
            ),

            // Bottom tip info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã lưu danh sách nguyên liệu cần chuẩn bị'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Iconsax.tick_circle, size: 18),
                  label: const Text(
                    'Đã hiểu / Chuẩn bị xong',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
