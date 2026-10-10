import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/services/recipe_data_service.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/recipe_detail_sheet.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _searchQuery = '';
  bool _isRecentExpanded = false;

  final List<String> _recentSearches = [
    'Phở bò',
    'Bún bò Huế',
    'Salad ức gà',
    'Bánh mì nướng',
    'Cơm tấm sườn',
    'Lẩu Thái',
  ];

  // The first 3 items are hot items (displayed in red)
  final List<String> _trendingKeywords = [
    'Phở bò Hà Nội',
    'Cơm tấm sườn bì chả',
    'Bánh xèo miền Tây giòn rụm',
    'Bún đậu mắm tôm',
    'Salad giảm cân Eat Clean',
    'Gà sốt cay phô mai',
    'Lẩu Thái chua cay',
    'Bánh mì chảo sốt bơ',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.trim().isNotEmpty) {
        _recentSearches.remove(query.trim());
        _recentSearches.insert(0, query.trim());
      }
    });
  }

  void _applyKeyword(String keyword) {
    _focusNode.unfocus();
    _searchController.text = keyword;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );
    _onSearch(keyword);
  }

  List<Recipe> _getFilteredRecipes() {
    final allRecipes = RecipeDataService.instance.allRecipes;
    if (_searchQuery.trim().isEmpty) return [];

    final q = _searchQuery.toLowerCase().trim();
    return allRecipes.where((recipe) {
      final inTitle = recipe.title.toLowerCase().contains(q);
      final inChef = recipe.chefName.toLowerCase().contains(q);
      final inCategory = recipe.category.toLowerCase().contains(q);
      final inTags = recipe.tags.any((t) => t.toLowerCase().contains(q));
      final inIngredients =
          recipe.ingredients.any((i) => i.name.toLowerCase().contains(q));

      return inTitle || inChef || inCategory || inTags || inIngredients;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = _getFilteredRecipes();
    final isSearching = _searchQuery.trim().isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: isSearching
            ? _buildSearchResults(filteredRecipes)
            : _buildDiscoverContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left_2, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Container(
        height: 44,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            _focusNode.unfocus();
            _onSearch(val);
          },
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            prefixIcon: const Icon(
              Iconsax.search_normal_1,
              color: Colors.grey,
              size: 18,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            hintText: 'Tìm món ăn, nguyên liệu, đầu bếp...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFF3F4F6),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildDiscoverContent() {
    final displayedRecent = _isRecentExpanded
        ? _recentSearches
        : _recentSearches.take(3).toList();

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(top: 4),
        children: [
          // Recent searches compact vertical list
          if (_recentSearches.isNotEmpty) ...[
            ...displayedRecent.map((term) => _buildRecentSearchItem(term)),
            if (_recentSearches.length > 3 && !_isRecentExpanded)
              InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _isRecentExpanded = true;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Xem thêm',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              )
            else
              InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _recentSearches.clear();
                    _isRecentExpanded = false;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(
                    child: Text(
                      'Xóa tất cả',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 4),
            const Divider(height: 16, thickness: 6, color: Color(0xFFF9FAFB)),
          ],

          // Trending keywords (No icon, bullet points, top 3 in red, larger font size)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Text(
              'Tìm kiếm phổ biến',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 36,
                crossAxisSpacing: 12,
                mainAxisSpacing: 2,
              ),
              itemCount: _trendingKeywords.length,
              itemBuilder: (context, index) {
                final keyword = _trendingKeywords[index];
                final isHot = index < 3;
                final textColor =
                    isHot ? const Color(0xFFEF4444) : const Color(0xFF161823);
                final bulletColor =
                    isHot ? const Color(0xFFEF4444) : Colors.grey.shade400;

                return InkWell(
                  onTap: () => _applyKeyword(keyword),
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: bulletColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          keyword,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isHot ? FontWeight.w600 : FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 16, thickness: 6, color: Color(0xFFF9FAFB)),

          // Featured / Recommended recipes (Larger font size)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Text(
              'Gợi ý món hôm nay',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: RecipeDataService.instance.allRecipes.take(4).map(
                (recipe) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRecipeCard(recipe),
                ),
              ).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
  }

  Widget _buildRecentSearchItem(String term) {
    return InkWell(
      onTap: () => _applyKeyword(term),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(
              Iconsax.clock,
              size: 16,
              color: Color(0xFF8A8B91),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                term,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF161823),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _recentSearches.remove(term);
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Color(0xFF8A8B91),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<Recipe> results) {
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.search_status,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Không tìm thấy món ăn nào',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hãy thử tìm với từ khoá khác hoặc xem danh sách gợi ý',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text(
            'Tìm thấy ${results.length} món ăn',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final recipe = results[index];
              return _buildRecipeCard(recipe);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return InkWell(
      onTap: () {
        RecipeDetailSheet.show(
          context,
          recipe: recipe,
          onRecipeChanged: (_) => setState(() {}),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Recipe image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                recipe.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade200,
                  child: const Icon(Iconsax.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Recipe info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.user,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recipe.chefName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Rating
                      const Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: Color(0xFFFFB800),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${recipe.rating}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Time
                      const Icon(
                        Iconsax.clock,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${recipe.cookTimeMinutes}p',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          recipe.difficulty,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF7A00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Favorite Button
            IconButton(
              icon: Icon(
                recipe.isFavorite ? Iconsax.heart5 : Iconsax.heart,
                color: recipe.isFavorite
                    ? const Color(0xFFEF4444)
                    : Colors.grey.shade400,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  RecipeDataService.instance.toggleFavorite(recipe.id);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
