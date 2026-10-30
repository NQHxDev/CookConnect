import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/navigation/app_tab_navigator.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/services/recipe_data_service.dart';
import 'package:cookconnect/features/recipe/presentation/widgets/ingredient_visuals.dart';

void showIngredientsBottomSheet(
  BuildContext context, {
  required String recipeTitle,
  required List<PostIngredientItem> ingredients,
  String? postId,
  PostItem? post,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (context) => IngredientsBottomSheet(
      recipeTitle: recipeTitle,
      ingredients: ingredients,
      postId: postId ?? post?.postId,
      post: post,
    ),
  );
}

/// Bottom sheet hiển thị nguyên liệu của một bài Post trên Feed và
/// kết nối trực tiếp với trang "Đi chợ" (danh sách cần mua + chợ thực phẩm).
class IngredientsBottomSheet extends StatefulWidget {
  final String recipeTitle;
  final List<PostIngredientItem> ingredients;
  final String? postId;
  final PostItem? post;

  const IngredientsBottomSheet({
    super.key,
    required this.recipeTitle,
    required this.ingredients,
    this.postId,
    this.post,
  });

  @override
  State<IngredientsBottomSheet> createState() => _IngredientsBottomSheetState();
}

class _IngredientsBottomSheetState extends State<IngredientsBottomSheet> {
  static const _accent = Color(0xFFFF7A1A);
  static const _accentEnd = Color(0xFFFF2D55);
  static const _sheetBg = Color(0xFF161618);
  static const _tileBg = Color(0xFF222226);
  static const _inCartColor = Color(0xFF34C759);

  final RecipeDataService _dataService = RecipeDataService.instance;

  /// Các nguyên liệu (chưa có trong giỏ) người dùng đang chọn để thêm.
  final Set<String> _selectedKeys = {};
  late List<PostIngredientItem> _ingredients;
  int _servingMultiplier = 1;
  bool _isLoading = false;
  bool _justAdded = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setIngredients(widget.ingredients);
    if (_ingredients.isEmpty &&
        widget.postId != null &&
        widget.postId!.isNotEmpty) {
      _loadIngredients();
    }
  }

  void _setIngredients(List<PostIngredientItem> items) {
    _ingredients = List.of(items)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _selectedKeys
      ..clear()
      ..addAll(
        _ingredients
            .where((i) => !_dataService.isIngredientInShoppingList(i.name))
            .map(_keyOf),
      );
  }

  String _keyOf(PostIngredientItem item) =>
      item.ingredientId.isNotEmpty ? item.ingredientId : item.name;

  Future<void> _loadIngredients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetched = await ApiService.instance.post.getPostIngredients(
        widget.postId!,
      );
      if (!mounted) return;
      setState(() {
        _setIngredients(fetched);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải nguyên liệu. Vui lòng thử lại.';
      });
    }
  }

  // ==========================================
  // ACTIONS
  // ==========================================
  String _amountOf(PostIngredientItem item) => IngredientVisuals.scaledAmount(
    item.amount,
    item.unit,
    _servingMultiplier,
  );

  void _toggleSelect(PostIngredientItem item) {
    HapticFeedback.selectionClick();
    setState(() {
      final key = _keyOf(item);
      if (!_selectedKeys.remove(key)) _selectedKeys.add(key);
      _justAdded = false;
    });
  }

  void _toggleSelectAll(List<PostIngredientItem> notInCart) {
    HapticFeedback.selectionClick();
    setState(() {
      final allSelected = notInCart.every(
        (i) => _selectedKeys.contains(_keyOf(i)),
      );
      if (allSelected) {
        _selectedKeys.clear();
      } else {
        _selectedKeys.addAll(notInCart.map(_keyOf));
      }
    });
  }

  void _addSelectedToShoppingList(List<PostIngredientItem> notInCart) {
    final toAdd = notInCart
        .where((i) => _selectedKeys.contains(_keyOf(i)))
        .toList();
    if (toAdd.isEmpty) return;

    final post = widget.post;
    if (post != null) _dataService.registerLinkedPost(post);

    final now = DateTime.now().millisecondsSinceEpoch;
    final source = widget.recipeTitle.trim().isNotEmpty
        ? widget.recipeTitle.trim()
        : 'Công thức từ Feed';

    _dataService.addShoppingItems([
      for (var i = 0; i < toAdd.length; i++)
        ShoppingItem(
          id: 'post_${widget.postId ?? 'local'}_${_keyOf(toAdd[i])}_${now}_$i',
          name: toAdd[i].name,
          amount: _amountOf(toAdd[i]).isNotEmpty
              ? _amountOf(toAdd[i])
              : '1 phần',
          recipeSource: source,
          sourcePostId: widget.postId,
          sourceThumbnailUrl: post?.thumbnailUrl,
        ),
    ]);

    HapticFeedback.mediumImpact();
    setState(() {
      _selectedKeys.clear();
      _justAdded = true;
    });
  }

  void _removeFromCart(PostIngredientItem item) {
    HapticFeedback.lightImpact();
    _dataService.removeIngredientFromShoppingList(item.name);
    setState(() => _justAdded = false);
  }

  // ==========================================
  // BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.82;

    return AnimatedBuilder(
      animation: _dataService,
      builder: (context, _) {
        final inCartKeys = <String>{
          for (final i in _ingredients)
            if (_dataService.isIngredientInShoppingList(i.name)) _keyOf(i),
        };
        final notInCart = _ingredients
            .where((i) => !inCartKeys.contains(_keyOf(i)))
            .toList();
        // Bỏ chọn những món vừa được thêm từ nơi khác.
        _selectedKeys.removeAll(inCartKeys);

        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: const BoxDecoration(
            color: _sheetBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHandle(),
                _buildHeader(inCartCount: inCartKeys.length),
                if (_ingredients.isNotEmpty && !_isLoading) ...[
                  const SizedBox(height: 14),
                  _buildServingSelector(),
                ],
                const SizedBox(height: 10),
                Flexible(child: _buildContent(inCartKeys)),
                if (_ingredients.isNotEmpty && !_isLoading)
                  _buildFooter(notInCart),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader({required int inCartCount}) {
    final total = _ingredients.length;
    final progress = total == 0 ? 0.0 : inCartCount / total;
    final thumbnail = widget.post?.thumbnailUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(thumbnail),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NGUYÊN LIỆU',
                      style: TextStyle(
                        color: _accent.withValues(alpha: 0.95),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.recipeTitle.isNotEmpty
                          ? widget.recipeTitle
                          : 'Món ăn từ Feed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildStatChip(
                          icon: Iconsax.reserve,
                          label: '$total nguyên liệu',
                          color: Colors.white70,
                        ),
                        if (inCartCount > 0)
                          _buildStatChip(
                            icon: Iconsax.shopping_cart,
                            label: '$inCartCount trong giỏ',
                            color: _inCartColor,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              _buildCircleIconButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1 ? _inCartColor : _accent,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThumbnail(String? url) {
    final fallback = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_accent, _accentEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Iconsax.reserve, color: Colors.white, size: 26),
    );
    if (url == null || url.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildServingSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Icon(
            Iconsax.people,
            size: 16,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          Text(
            'Khẩu phần',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [1, 2, 3, 4].map((m) {
                final selected = _servingMultiplier == m;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _servingMultiplier = m);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(colors: [_accent, _accentEnd])
                          : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'x$m',
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Set<String> inCartKeys) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }

    if (_errorMessage != null) {
      return _buildMessageState(
        icon: Iconsax.info_circle,
        iconColor: Colors.redAccent,
        message: _errorMessage!,
        action: TextButton.icon(
          onPressed: _loadIngredients,
          icon: const Icon(Iconsax.refresh, color: _accent, size: 16),
          label: const Text('Thử lại', style: TextStyle(color: _accent)),
        ),
      );
    }

    if (_ingredients.isEmpty) {
      return _buildMessageState(
        icon: Iconsax.note_remove,
        iconColor: Colors.white.withValues(alpha: 0.3),
        message: 'Bài đăng này chưa có danh sách nguyên liệu cụ thể',
        action: TextButton.icon(
          onPressed: () =>
              AppTabNavigator.instance.openMarket(context, tabIndex: 1),
          icon: const Icon(Iconsax.shop, color: _accent, size: 16),
          label: const Text(
            'Khám phá Chợ thực phẩm',
            style: TextStyle(color: _accent),
          ),
        ),
      );
    }

    // Gom nhóm nguyên liệu, giữ thứ tự xuất hiện.
    final Map<String, List<PostIngredientItem>> grouped = {};
    for (final item in _ingredients) {
      final groupName = (item.group != null && item.group!.trim().isNotEmpty)
          ? item.group!.trim()
          : 'Nguyên liệu';
      grouped.putIfAbsent(groupName, () => []).add(item);
    }
    final showGroupHeaders =
        grouped.length > 1 || grouped.keys.first != 'Nguyên liệu';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        for (final entry in grouped.entries) ...[
          if (showGroupHeaders)
            _buildGroupHeader(entry.key, entry.value.length),
          for (final item in entry.value)
            _buildIngredientTile(
              item,
              inCart: inCartKeys.contains(_keyOf(item)),
            ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required Color iconColor,
    required String message,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 44),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13.5,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 10), action],
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8, left: 2),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_accent, _accentEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '· $count',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientTile(PostIngredientItem item, {required bool inCart}) {
    final selected = _selectedKeys.contains(_keyOf(item));
    final amount = _amountOf(item);

    final Color borderColor = inCart
        ? _inCartColor.withValues(alpha: 0.35)
        : selected
        ? _accent.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.05);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: inCart ? null : () => _toggleSelect(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
            decoration: BoxDecoration(
              color: inCart
                  ? _inCartColor.withValues(alpha: 0.07)
                  : selected
                  ? _accent.withValues(alpha: 0.08)
                  : _tileBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                // Emoji minh hoạ
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    IngredientVisuals.emojiFor(item.name),
                    style: const TextStyle(fontSize: 21),
                  ),
                ),
                const SizedBox(width: 12),
                // Tên + trạng thái
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (inCart)
                        const Row(
                          children: [
                            Icon(
                              Iconsax.tick_circle5,
                              size: 12,
                              color: _inCartColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Đã có trong giỏ đi chợ',
                              style: TextStyle(
                                color: _inCartColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          amount.isNotEmpty ? amount : 'Tuỳ khẩu vị',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                // Định lượng (khi đã trong giỏ vẫn hiện)
                if (inCart && amount.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      amount,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                // Tìm mua ở chợ
                IconButton(
                  tooltip: 'Tìm "${item.name}" ở Chợ',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Iconsax.shop,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  onPressed: () => AppTabNavigator.instance.searchInMarket(
                    context,
                    item.name,
                  ),
                ),
                // Chọn / bỏ khỏi giỏ
                if (inCart)
                  IconButton(
                    tooltip: 'Bỏ khỏi giỏ đi chợ',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Iconsax.minus_cirlce,
                      size: 20,
                      color: Colors.white54,
                    ),
                    onPressed: () => _removeFromCart(item),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: selected
                            ? const LinearGradient(
                                colors: [_accent, _accentEnd],
                              )
                            : null,
                        border: selected
                            ? null
                            : Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(List<PostIngredientItem> notInCart) {
    final selectedCount = notInCart
        .where((i) => _selectedKeys.contains(_keyOf(i)))
        .length;
    final allInCart = notInCart.isEmpty;
    final allSelected = !allInCart && selectedCount == notInCart.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _sheetBg,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_justAdded || allInCart)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.tick_circle5,
                    color: _inCartColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      allInCart
                          ? 'Đủ nguyên liệu trong giỏ rồi, đi chợ thôi!'
                          : 'Đã thêm vào danh sách đi chợ',
                      style: const TextStyle(
                        color: _inCartColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              if (!allInCart) ...[
                // Chọn tất cả
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _toggleSelectAll(notInCart),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          allSelected
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 20,
                          color: allSelected ? _accent : Colors.white54,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Tất cả',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Mở danh sách đi chợ
              _buildSecondaryButton(
                icon: Iconsax.shopping_cart,
                label: allInCart || _justAdded ? 'Xem giỏ đi chợ' : null,
                onTap: () => AppTabNavigator.instance.openShoppingList(context),
              ),
              if (!allInCart) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPrimaryButton(
                    label: selectedCount == 0
                        ? 'Chọn nguyên liệu cần mua'
                        : 'Thêm $selectedCount món vào giỏ',
                    enabled: selectedCount > 0,
                    onTap: () => _addSelectedToShoppingList(notInCart),
                  ),
                ),
              ] else ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPrimaryButton(
                    label: 'Đặt mua ở Chợ',
                    icon: Iconsax.shop,
                    enabled: true,
                    onTap: () =>
                        AppTabNavigator.instance.openShoppingList(context),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    String? label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: label == null ? 14 : 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 19),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    IconData icon = Iconsax.bag_tick,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.45,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_accent, _accentEnd]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _accentEnd.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onTap : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
