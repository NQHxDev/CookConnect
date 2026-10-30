import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/recipe/data/models/product_search_model.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/services/product_search_service.dart';

class AddShoppingItemBottomSheet extends StatefulWidget {
  final ProductSearchService? searchService;
  final String? prefillName;

  const AddShoppingItemBottomSheet({
    super.key,
    this.searchService,
    this.prefillName,
  });

  /// Static helper to display this bottom sheet smoothly
  static Future<ShoppingItem?> show(
    BuildContext context, {
    ProductSearchService? searchService,
    String? prefillName,
  }) {
    return showModalBottomSheet<ShoppingItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddShoppingItemBottomSheet(
        searchService: searchService,
        prefillName: prefillName,
      ),
    );
  }

  @override
  State<AddShoppingItemBottomSheet> createState() =>
      _AddShoppingItemBottomSheetState();
}

class _AddShoppingItemBottomSheetState
    extends State<AddShoppingItemBottomSheet> {
  late final ProductSearchService _searchService;
  late final TextEditingController _searchController;
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();

  Timer? _debounceTimer;
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  List<ProductSearchItemDto> _searchResults = [];

  ProductSearchItemDto? _selectedProduct;
  ProductVariantDto? _selectedVariant;
  String? _selectedCategoryCode;

  List<WhoCategoryDto> _categories = [];

  static final List<WhoCategoryDto> _defaultWhoCategories = [
    WhoCategoryDto(code: 'MEAT_FISH_POULTRY', name: 'Thịt, cá và gia cầm', order: 1),
    WhoCategoryDto(code: 'VITAMIN_A_FRUITS_VEG', name: 'Rau củ giàu Vitamin A', order: 2),
    WhoCategoryDto(code: 'OTHER_FRUITS_VEG', name: 'Rau củ và quả khác', order: 3),
    WhoCategoryDto(code: 'DAIRY', name: 'Sữa và các sản phẩm từ sữa', order: 4),
    WhoCategoryDto(code: 'EGGS', name: 'Trứng tươi', order: 5),
    WhoCategoryDto(code: 'STAPLES', name: 'Lương thực chính', order: 6),
    WhoCategoryDto(code: 'LEGUMES_NUTS_SEEDS', name: 'Các loại đậu và hạt', order: 7),
    WhoCategoryDto(code: 'FATS_OILS', name: 'Chất béo và dầu mỡ', order: 8),
  ];

  final List<String> _quickAmounts = [
    '1 phần',
    '200g',
    '300g',
    '500g',
    '1kg',
    '1 bó',
    '1 vỉ',
    '1 hộp',
    '1 chai',
    'Vừa đủ',
  ];

  @override
  void initState() {
    super.initState();
    _searchService = widget.searchService ?? ProductSearchService();
    _searchController = TextEditingController(text: widget.prefillName ?? '');
    _nameController = TextEditingController(text: widget.prefillName ?? '');
    _amountController = TextEditingController(text: '1 phần');
    _noteController = TextEditingController(text: 'Tự thêm');

    _loadCategories();

    // Trigger initial search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = _searchController.text.trim();
      _fetchProducts(query: query.isEmpty ? null : query);
    });

    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _searchService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = cats;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _nameFocusNode.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      final query = _searchController.text.trim();
      // If user is searching and hasn't manually altered name, reflect search text
      if (_selectedProduct == null && query.isNotEmpty) {
        _nameController.text = query;
      }
      _fetchProducts(query: query.isEmpty ? null : query);
    });
  }

  Future<void> _fetchProducts({String? query}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _searchService.searchProducts(
        query: query,
        whoCategoryCode: _selectedCategoryCode,
        limit: 15,
      );
      if (!mounted) return;
      setState(() {
        _searchResults = result.items;
        _isLoading = false;
        _hasSearched = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _hasSearched = true;
        _errorMessage = 'Không thể tải danh sách sản phẩm: $e';
      });
    }
  }

  void _selectProduct(ProductSearchItemDto product) {
    setState(() {
      if (_selectedProduct?.productId == product.productId) {
        // Toggle unselect
        _selectedProduct = null;
        _selectedVariant = null;
      } else {
        _selectedProduct = product;
        _selectedVariant =
            product.variants.isNotEmpty ? product.variants.first : null;
        _nameController.text = product.productName;

        if (_selectedVariant != null) {
          if (_selectedVariant!.packSize != null &&
              _selectedVariant!.packSize!.isNotEmpty) {
            _amountController.text = _selectedVariant!.packSize!;
          } else if (_selectedVariant!.unit != null &&
              _selectedVariant!.unit!.isNotEmpty) {
            _amountController.text = '1 ${_selectedVariant!.unit!}';
          }
        }
      }
    });
  }

  void _selectCategory(String? code) {
    setState(() {
      _selectedCategoryCode = code;
    });
    final query = _searchController.text.trim();
    _fetchProducts(query: query.isEmpty ? null : query);
  }

  void _submit() {
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : _searchController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập hoặc chọn tên thực phẩm cần mua'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final amount = _amountController.text.trim().isNotEmpty
        ? _amountController.text.trim()
        : '1 phần';

    final source = _noteController.text.trim().isNotEmpty
        ? _noteController.text.trim()
        : 'Tự thêm';

    final newItem = ShoppingItem(
      id: 'shop_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      amount: amount,
      recipeSource: source,
      productId: _selectedProduct?.productId,
      imageUrl: _selectedProduct?.primaryImage,
      price: _selectedVariant?.price ?? _selectedProduct?.minPrice,
      unit: _selectedVariant?.unit ?? _selectedProduct?.displayUnit,
      currency: _selectedProduct?.currency ?? 'VND',
      supplierId: _selectedProduct?.supplierId,
    );

    Navigator.of(context).pop(newItem);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Sheet Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Iconsax.bag_2, color: primaryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thêm thực phẩm đi chợ',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Tìm kiếm nguyên liệu hoặc nhập tay',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 22),
                      color: Colors.grey.shade600,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.15),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm thịt, rau củ, hải sản, gia vị...',
                            hintStyle: TextStyle(
                              fontSize: 13.5,
                              color: Colors.grey.shade500,
                            ),
                            prefixIcon: const Icon(
                              Iconsax.search_normal_1,
                              size: 18,
                              color: Colors.grey,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category Filter Chips
                      Builder(
                        builder: (context) {
                          final List<WhoCategoryDto> list = _categories.isNotEmpty
                              ? _categories
                              : _defaultWhoCategories;
                          final displayList = [
                            WhoCategoryDto(code: '', name: 'Tất cả'),
                            ...list,
                          ];

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: displayList.map((cat) {
                                final catCode =
                                    cat.code.isEmpty ? null : cat.code;
                                final isSelected =
                                    _selectedCategoryCode == catCode;
                                final icon =
                                    cat.code.isEmpty ? '🛒' : cat.icon;
                                final name =
                                    cat.code.isEmpty ? 'Tất cả' : cat.shortName;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(
                                      '$icon $name',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? primaryColor
                                            : Colors.black87,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor:
                                        primaryColor.withValues(alpha: 0.12),
                                    backgroundColor: const Color(0xFFF8F9FA),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? primaryColor
                                            : Colors.grey.shade300,
                                        width: isSelected ? 1.4 : 0.8,
                                      ),
                                    ),
                                    onSelected: (_) =>
                                        _selectCategory(catCode),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Products Search Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _searchController.text.trim().isEmpty
                                ? 'Nguyên liệu gợi ý từ kho CookConnect'
                                : 'Kết quả tìm kiếm (${_searchResults.length})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (_isLoading)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Search Results Carousel / List
                      if (_isLoading && _searchResults.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          ),
                        )
                      else if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_searchResults.isEmpty && _hasSearched)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.info_circle,
                                color: Colors.grey.shade500,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Chưa có trong kho hàng CookConnect. Bạn vẫn có thể nhập tên và số lượng bên dưới để lưu vào danh sách.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 128,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _searchResults.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final product = _searchResults[index];
                              return _buildProductCard(product, primaryColor);
                            },
                          ),
                        ),

                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Item Details Configuration Area
                      const Text(
                        'Thông tin món cần mua',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Name Field
                      TextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Tên thực phẩm / nguyên liệu *',
                          labelStyle: const TextStyle(fontSize: 13),
                          hintText: 'Ví dụ: Thịt bò tươi, Cà chua bi, Sữa chua...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                          prefixIcon: Icon(
                            Iconsax.note_text,
                            size: 18,
                            color: primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Amount Field & Quick Chips
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _amountController,
                              focusNode: _amountFocusNode,
                              decoration: InputDecoration(
                                labelText: 'Số lượng / Định lượng',
                                labelStyle: const TextStyle(fontSize: 13),
                                hintText: 'Ví dụ: 500g, 1 vỉ...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: Icon(
                                  Iconsax.weight,
                                  size: 18,
                                  color: primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _noteController,
                              decoration: InputDecoration(
                                labelText: 'Ghi chú / Món dự kiến',
                                labelStyle: const TextStyle(fontSize: 13),
                                hintText: 'Ví dụ: Nấu lẩu, Bữa tối...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: const Icon(
                                  Iconsax.bookmark,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Quick Amount Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _quickAmounts.map((amt) {
                            final isCurrent = _amountController.text == amt;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  setState(() {
                                    _amountController.text = amt;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? primaryColor.withValues(alpha: 0.15)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isCurrent
                                          ? primaryColor
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Text(
                                    amt,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isCurrent
                                          ? primaryColor
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Sticky Action Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Huỷ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Iconsax.bag_tick_2, size: 18),
                        label: const Text(
                          'Thêm vào giỏ đi chợ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
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

  Widget _buildProductCard(ProductSearchItemDto product, Color primaryColor) {
    final isSelected = _selectedProduct?.productId == product.productId;

    return GestureDetector(
      onTap: () => _selectProduct(product),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 180,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 60,
                child: product.primaryImage != null
                    ? Image.network(
                        product.primaryImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.orange.withValues(alpha: 0.1),
                          child: Icon(
                            Iconsax.box,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.orange.withValues(alpha: 0.1),
                        child: Icon(
                          Iconsax.box,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.formattedPrice,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  if (product.displayUnit.isNotEmpty)
                    Text(
                      product.displayUnit,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),

            if (isSelected)
              Icon(Icons.check_circle, color: primaryColor, size: 18),
          ],
        ),
      ),
    );
  }
}
