import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/recipe.dart';
import '../services/recipe_data_service.dart';
import '../widgets/recipe_detail_sheet.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final RecipeDataService _dataService = RecipeDataService.instance;

  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  String _selectedSort = 'newest'; // 'newest', 'fastest', 'rating', 'calories'
  bool _isGridView = true;
  String? _selectedCollectionFilterId;

  final List<String> _categories = [
    'Tất cả',
    'Eat Clean',
    'Món chính',
    'Món nước',
    'Đồ uống',
    'Bánh ngọt',
    '< 20 phút',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> _getFilteredFavorites() {
    List<Recipe> list = _dataService.allRecipes.where((r) {
      if (_selectedCollectionFilterId != null) {
        final col = _dataService.collections.firstWhere(
          (c) => c.id == _selectedCollectionFilterId,
        );
        return col.recipeIds.contains(r.id);
      }
      return r.isFavorite || r.isSaved;
    }).toList();

    // Category filter
    if (_selectedCategory == '< 20 phút') {
      list = list.where((r) => r.cookTimeMinutes <= 20).toList();
    } else if (_selectedCategory != 'Tất cả') {
      list = list.where((r) => r.category == _selectedCategory).toList();
    }

    // Search filter
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      list = list.where((r) {
        return r.title.toLowerCase().contains(query) ||
            r.chefName.toLowerCase().contains(query) ||
            r.category.toLowerCase().contains(query) ||
            r.tags.any((t) => t.toLowerCase().contains(query)) ||
            r.ingredients.any((i) => i.name.toLowerCase().contains(query));
      }).toList();
    }

    // Sort
    switch (_selectedSort) {
      case 'fastest':
        list.sort((a, b) => a.cookTimeMinutes.compareTo(b.cookTimeMinutes));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'calories':
        list.sort((a, b) => a.calories.compareTo(b.calories));
        break;
      case 'newest':
      default:
        break;
    }

    return list;
  }

  void _showCreateCollectionDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int selectedColor = 0xFFE76F51;

    final colorOptions = [
      0xFFE76F51, // Orange/Coral
      0xFF2A9D8F, // Teal
      0xFF457B9D, // Ocean Blue
      0xFF9C27B0, // Purple
      0xFFE63946, // Red
      0xFFF4A261, // Warm Amber
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Row(
                children: [
                  Icon(Iconsax.folder_add, color: Colors.orange, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Tạo bộ sưu tập mới',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tên bộ sưu tập',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: Món ăn dặm cho bé, Lẩu cuối tuần...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Mô tả ngắn',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Mô tả về các món ăn trong bộ sưu tập này...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Chọn màu chủ đề',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: colorOptions.map((c) {
                        final isSelected = selectedColor == c;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = c;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black87
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Huỷ'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;

                    final newCollection = RecipeCollection(
                      id: 'col_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      description: descCtrl.text.trim(),
                      coverImageUrl:
                          'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=600&auto=format&fit=crop&q=80',
                      colorValue: selectedColor,
                      recipeIds: [],
                    );

                    setState(() {
                      _dataService.addCollection(newCollection);
                    });

                    Navigator.pop(dialogCtx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã tạo bộ sưu tập "$name" thành công!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Tạo mới'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddCustomShoppingItemDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Iconsax.bag_2, color: Colors.orange, size: 22),
              SizedBox(width: 8),
              Text(
                'Thêm món cần mua',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên nguyên liệu / thực phẩm',
                  hintText: 'Ví dụ: Trứng gà, Sữa chua, Rau xà lách...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                decoration: InputDecoration(
                  labelText: 'Số lượng / Định lượng',
                  hintText: 'Ví dụ: 500g, 1 vỉ, 2 quả...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final newItem = ShoppingItem(
                  id: 'shop_custom_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  amount: amountCtrl.text.trim().isEmpty
                      ? '1 phần'
                      : amountCtrl.text.trim(),
                  recipeSource: 'Tự thêm',
                );

                setState(() {
                  _dataService.addShoppingItem(newItem);
                });

                Navigator.pop(ctx);
              },
              child: const Text('Thêm vào giỏ'),
            ),
          ],
        );
      },
    );
  }

  void _openRecipeDetail(Recipe recipe) {
    RecipeDetailSheet.show(
      context,
      recipe: recipe,
      onRecipeChanged: (updated) {
        setState(() {
          _dataService.updateRecipe(updated);
        });
      },
      onAddToShoppingList: (items) {
        setState(() {
          _dataService.addShoppingItems(items);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Iconsax.book_1, color: primaryColor, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thư viện ẩm thực',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Công thức & Sổ tay nấu nướng',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.folder_add, color: Colors.black87),
            tooltip: 'Tạo bộ sưu tập',
            onPressed: _showCreateCollectionDialog,
          ),
          IconButton(
            icon: const Icon(Iconsax.bag_2, color: Colors.black87),
            tooltip: 'Thêm đồ cần mua',
            onPressed: _showAddCustomShoppingItemDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  child: Row(
                    children: [
                      const Icon(Iconsax.heart5, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Yêu thích (${_dataService.favoriteRecipes.length})',
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Iconsax.folder_2, size: 16),
                      const SizedBox(width: 6),
                      Text('Bộ sưu tập (${_dataService.collections.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Iconsax.clock, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Đã nấu & Xem (${_dataService.cookedRecipes.length})',
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Iconsax.shopping_cart, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Đi chợ (${_dataService.shoppingList.where((i) => !i.isCompleted).length})',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoritesTab(primaryColor),
          _buildCollectionsTab(primaryColor),
          _buildHistoryAndCookedTab(primaryColor),
          _buildShoppingListTab(primaryColor),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: FAVORITES & ALL SAVED RECIPES
  // ==========================================
  Widget _buildFavoritesTab(Color primaryColor) {
    final filteredList = _getFilteredFavorites();

    return Column(
      children: [
        // Top Search Bar & View Mode
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              // Search Input
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    prefixIcon: const Icon(
                      Iconsax.search_normal_1,
                      size: 18,
                      color: Colors.grey,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    hintText: 'Tìm theo tên món, nguyên liệu, tag...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Chips Carousel
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? cat : 'Tất cả';
                        });
                      },
                      selectedColor: primaryColor,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.withValues(alpha: 0.25),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Collection Filter Notice Banner (if active)
        if (_selectedCollectionFilterId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: primaryColor.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(Iconsax.folder_open, size: 18, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đang lọc theo bộ sưu tập: ${_dataService.collections.firstWhere((c) => c.id == _selectedCollectionFilterId).name}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    setState(() {
                      _selectedCollectionFilterId = null;
                    });
                  },
                ),
              ],
            ),
          ),

        // Results stats & View toggle bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${filteredList.length} công thức món ngon',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              // Sort dropdown
              PopupMenuButton<String>(
                initialValue: _selectedSort,
                onSelected: (val) {
                  setState(() {
                    _selectedSort = val;
                  });
                },
                child: Row(
                  children: [
                    Icon(Iconsax.sort, size: 16, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      _selectedSort == 'newest'
                          ? 'Mới nhất'
                          : _selectedSort == 'fastest'
                          ? 'Nhanh nhất'
                          : _selectedSort == 'rating'
                          ? 'Đánh giá cao'
                          : 'Ít Calo',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'newest', child: Text('Mới nhất')),
                  const PopupMenuItem(
                    value: 'fastest',
                    child: Text('Nấu nhanh nhất'),
                  ),
                  const PopupMenuItem(
                    value: 'rating',
                    child: Text('Đánh giá cao nhất'),
                  ),
                  const PopupMenuItem(
                    value: 'calories',
                    child: Text('Lượng Calo thấp nhất'),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // View Grid/List toggle
              InkWell(
                onTap: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    _isGridView ? Iconsax.grid_1 : Iconsax.row_vertical,
                    size: 18,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main Recipe Items Display
        Expanded(
          child: filteredList.isEmpty
              ? _buildEmptyView(
                  title: 'Chưa tìm thấy công thức phù hợp',
                  subtitle:
                      'Hãy thử tìm kiếm với từ khoá khác hoặc xoá bộ lọc hiện tại.',
                  actionLabel: 'Xoá bộ lọc',
                  onAction: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                      _selectedCategory = 'Tất cả';
                      _selectedCollectionFilterId = null;
                    });
                  },
                )
              : _isGridView
              ? GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, idx) {
                    return _buildRecipeGridCard(
                      filteredList[idx],
                      primaryColor,
                    );
                  },
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filteredList.length,
                  itemBuilder: (context, idx) {
                    return _buildRecipeListCard(
                      filteredList[idx],
                      primaryColor,
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: COLLECTIONS (BỘ SƯU TẬP)
  // ==========================================
  Widget _buildCollectionsTab(Color primaryColor) {
    final collections = _dataService.collections;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Create collection prompt card
        InkWell(
          onTap: _showCreateCollectionDialog,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.4),
                style: BorderStyle.solid,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: primaryColor.withValues(alpha: 0.12),
                  child: Icon(
                    Iconsax.folder_add,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tạo bộ sưu tập món mới',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nhóm các món theo chủ đề, dịp lễ hay thực đơn tuần',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Iconsax.add_circle5, color: primaryColor, size: 24),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bộ sưu tập của tôi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '${collections.length} thư mục',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Collection Cards List
        ...collections.map((col) {
          final count = col.recipeIds.length;
          final color = Color(col.colorValue);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedCollectionFilterId = col.id;
                    _tabController.animateTo(0);
                  });
                },
                child: Row(
                  children: [
                    // Cover image
                    Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        image: DecorationImage(
                          image: NetworkImage(col.coverImageUrl),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {},
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              color.withValues(alpha: 0.6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    col.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (col.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                col.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Iconsax.book_1, size: 14, color: color),
                                const SizedBox(width: 4),
                                Text(
                                  '$count công thức',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Mở xem',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Icon(
                                  Iconsax.arrow_right_3,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // TAB 3: COOKED & HISTORY (ĐÃ NẤU & LỊCH SỬ)
  // ==========================================
  Widget _buildHistoryAndCookedTab(Color primaryColor) {
    final cookedList = _dataService.cookedRecipes;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Cooking Stats Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.85),
                const Color(0xFFFF8C42),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.crown1, color: primaryColor, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thành tích bếp trưởng',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bạn đã hoàn thành ${cookedList.fold(0, (acc, r) => acc + r.cookedCount)} bữa ăn ngon miệng!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Lịch sử món đã nấu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        ...cookedList.map((recipe) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    recipe.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey[200],
                      child: const Icon(Iconsax.image),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Iconsax.tick_circle,
                            size: 14,
                            color: Colors.green[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Đã nấu ${recipe.cookedCount} lần',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thời gian: ${recipe.cookTimeMinutes}p • ${recipe.difficulty}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _openRecipeDetail(recipe);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.withValues(alpha: 0.12),
                    foregroundColor: primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Nấu lại',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // TAB 4: SHOPPING LIST (DANH SÁCH ĐI CHỢ)
  // ==========================================
  Widget _buildShoppingListTab(Color primaryColor) {
    final items = _dataService.shoppingList;
    final completedCount = items.where((i) => i.isCompleted).length;
    final totalCount = items.length;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Shopping list progress overview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tiến độ mua sắm thực phẩm',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    '$completedCount/$totalCount món',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: totalCount == 0 ? 0 : completedCount / totalCount,
                  minHeight: 8,
                  backgroundColor: Colors.grey.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completedCount == totalCount && totalCount > 0
                        ? Colors.green
                        : primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _showAddCustomShoppingItemDialog,
                    icon: const Icon(Iconsax.add, size: 16),
                    label: const Text(
                      'Thêm món',
                      style: TextStyle(fontSize: 12.5),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (completedCount > 0)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _dataService.clearCompletedShoppingItems();
                        });
                      },
                      icon: const Icon(
                        Iconsax.trash,
                        size: 16,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Xoá món đã mua',
                        style: TextStyle(color: Colors.red, fontSize: 12.5),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (items.isEmpty)
          _buildEmptyView(
            title: 'Chưa có thực phẩm nào cần mua',
            subtitle:
                'Thêm nguyên liệu từ công thức món ăn hoặc bấm nút "+ Thêm món" ở trên.',
            actionLabel: '+ Thêm món mới',
            onAction: _showAddCustomShoppingItemDialog,
          )
        else
          ...items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: item.isCompleted
                    ? const Color(0xFFF9FAFB)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: item.isCompleted
                      ? Colors.grey.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.2),
                ),
              ),
              child: ListTile(
                leading: Checkbox(
                  value: item.isCompleted,
                  activeColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _dataService.toggleShoppingItem(item.id);
                    });
                  },
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    decoration: item.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: item.isCompleted ? Colors.grey[500] : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Nguồn: ${item.recipeSource}',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.amount,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _dataService.removeShoppingItem(item.id);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // CARD WIDGETS
  // ==========================================
  Widget _buildRecipeGridCard(Recipe recipe, Color primaryColor) {
    return GestureDetector(
      onTap: () => _openRecipeDetail(recipe),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite heart badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.network(
                    recipe.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Iconsax.image),
                    ),
                  ),
                ),
                // Difficulty Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      recipe.difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _dataService.toggleFavorite(recipe.id);
                      });
                    },
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: Icon(
                        recipe.isFavorite ? Iconsax.heart5 : Iconsax.heart,
                        color: recipe.isFavorite
                            ? Colors.red
                            : Colors.grey[700],
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Iconsax.clock, size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(
                        '${recipe.cookTimeMinutes}p',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Iconsax.flash_1,
                        size: 12,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${recipe.calories} kcal',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Iconsax.star1, size: 13, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        '${recipe.rating}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        recipe.category,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeListCard(Recipe recipe, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openRecipeDetail(recipe),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  recipe.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[200],
                    child: const Icon(Iconsax.image),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            recipe.category,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _dataService.toggleFavorite(recipe.id);
                            });
                          },
                          child: Icon(
                            recipe.isFavorite ? Iconsax.heart5 : Iconsax.heart,
                            color: recipe.isFavorite ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bởi ${recipe.chefName} • ${recipe.ingredients.length} nguyên liệu',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Iconsax.clock, size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookTimeMinutes} phút',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Iconsax.flash,
                          size: 13,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${recipe.calories} kcal',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Iconsax.star1,
                          size: 13,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${recipe.rating}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView({
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.search_status,
                size: 48,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
