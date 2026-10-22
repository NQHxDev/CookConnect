import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import '../../data/models/product_category_type.dart';

class CategoryTabsBar extends StatefulWidget {
  final ProductCategoryType selectedCategory;
  final Map<ProductCategoryType, int> counts;
  final ValueChanged<ProductCategoryType> onCategoryChanged;
  final VoidCallback onOpenAllCategories;

  const CategoryTabsBar({
    super.key,
    required this.selectedCategory,
    required this.counts,
    required this.onCategoryChanged,
    required this.onOpenAllCategories,
  });

  @override
  State<CategoryTabsBar> createState() => CategoryTabsBarState();
}

class CategoryTabsBarState extends State<CategoryTabsBar> {
  final ScrollController _scrollController = ScrollController();
  final Map<ProductCategoryType, GlobalKey> _tabKeys = {
    for (var cat in ProductCategoryType.values) cat: GlobalKey(),
  };

  @override
  void didUpdateWidget(covariant CategoryTabsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToSelectedCategory();
      });
    }
  }

  void scrollToSelectedCategory() {
    final key = _tabKeys[widget.selectedCategory];
    if (key == null || key.currentContext == null) return;
    final context = key.currentContext!;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.3,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Horizontal scrolling tabs
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: ProductCategoryType.values.map((cat) {
                  final isSelected = cat == widget.selectedCategory;
                  final count = widget.counts[cat] ?? 0;

                  return InkWell(
                    key: _tabKeys[cat],
                    onTap: () {
                      widget.onCategoryChanged(cat);
                    },
                    splashColor: AppColors.primary.withValues(alpha: 0.08),
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            child: Row(
                              children: [
                                Text(
                                  cat.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '($count)',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                    color: isSelected ? AppColors.primary : AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Underline indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 2.5,
                            width: isSelected ? 36 : 0,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Vertical divider line
          Container(
            height: 24,
            width: 1,
            color: Colors.grey.withValues(alpha: 0.25),
          ),
          // Three-bar hamburger menu icon at the end of the list
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const ValueKey('all_categories_button'),
                onTap: widget.onOpenAllCategories,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: const Tooltip(
                    message: 'Tất cả danh mục',
                    child: Icon(
                      Iconsax.menu_1,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
