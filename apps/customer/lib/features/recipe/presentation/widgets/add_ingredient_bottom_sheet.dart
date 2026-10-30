import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/recipe/data/models/product_search_model.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/services/product_search_service.dart';

class AddIngredientBottomSheet extends StatefulWidget {
  final Ingredient? editItem;
  final String? prefillName;
  final ProductSearchService? searchService;

  const AddIngredientBottomSheet({
    super.key,
    this.editItem,
    this.prefillName,
    this.searchService,
  });

  /// Static helper to display this bottom sheet smoothly
  static Future<Ingredient?> show(
    BuildContext context, {
    Ingredient? editItem,
    String? prefillName,
    ProductSearchService? searchService,
  }) {
    return showModalBottomSheet<Ingredient>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddIngredientBottomSheet(
        editItem: editItem,
        prefillName: prefillName,
        searchService: searchService,
      ),
    );
  }

  @override
  State<AddIngredientBottomSheet> createState() => _AddIngredientBottomSheetState();
}

class _AddIngredientBottomSheetState extends State<AddIngredientBottomSheet> {
  late final ProductSearchService _searchService;
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();

  Timer? _debounceTimer;
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  List<ProductSearchItemDto> _searchResults = [];

  ProductSearchItemDto? _selectedProduct;
  ProductVariantDto? _selectedVariant;

  final List<String> _commonUnits = [
    '100g',
    '250g',
    '500g',
    '1kg',
    '1 quả',
    '2 quả',
    '1 củ',
    '1 muỗng canh',
    '1 thìa cafe',
    'Vừa đủ',
  ];

  @override
  void initState() {
    super.initState();
    _searchService = widget.searchService ?? ProductSearchService();
    _nameController = TextEditingController(
      text: widget.editItem?.name ?? widget.prefillName ?? '',
    );
    _amountController = TextEditingController(
      text: widget.editItem?.amount ?? '',
    );

    // Initial search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialQuery = _nameController.text.trim();
      _fetchProducts(query: initialQuery.isEmpty ? null : initialQuery);
    });

    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _amountController.dispose();
    _nameFocusNode.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    // If user edited name while a product was selected, clear selection if name changed drastically
    if (_selectedProduct != null &&
        _nameController.text.trim() != _selectedProduct!.productName) {
      setState(() {
        _selectedProduct = null;
        _selectedVariant = null;
      });
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      final query = _nameController.text.trim();
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
        _errorMessage = 'Không thể tải sản phẩm: $e';
      });
    }
  }

  void _selectProduct(ProductSearchItemDto product) {
    setState(() {
      _selectedProduct = product;
      _selectedVariant =
          product.variants.isNotEmpty ? product.variants.first : null;
      _nameController.text = product.productName;

      // Suggest default amount if empty
      if (_amountController.text.trim().isEmpty) {
        if (_selectedVariant?.packSize != null &&
            _selectedVariant!.packSize!.isNotEmpty) {
          _amountController.text = _selectedVariant!.packSize!;
        } else if (_selectedVariant?.unit != null &&
            _selectedVariant!.unit!.isNotEmpty) {
          _amountController.text = '1 ${_selectedVariant!.unit}';
        } else {
          _amountController.text = 'Vừa đủ';
        }
      }
    });

    // Move focus to amount input
    _amountFocusNode.requestFocus();
  }

  void _clearSelection() {
    setState(() {
      _selectedProduct = null;
      _selectedVariant = null;
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    final amount = _amountController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập hoặc chọn tên nguyên liệu!'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      _nameFocusNode.requestFocus();
      return;
    }

    final result = Ingredient(
      id: widget.editItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      amount: amount.isEmpty ? 'Vừa đủ' : amount,
      productId: _selectedProduct?.productId ?? widget.editItem?.productId,
      productVariantId: _selectedVariant?.variantId ?? widget.editItem?.productVariantId,
      imageUrl: _selectedProduct?.primaryImage ?? widget.editItem?.imageUrl,
      price: _selectedVariant?.price ??
          _selectedProduct?.minPrice ??
          widget.editItem?.price,
      unit: _selectedVariant?.unit ?? widget.editItem?.unit,
      supplierId: _selectedProduct?.supplierId ?? widget.editItem?.supplierId,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.88,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            spreadRadius: 2,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.shopping_cart,
                      color: Color(0xFFFF4D30),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.editItem == null
                              ? 'Thêm nguyên liệu'
                              : 'Chỉnh sửa nguyên liệu',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tìm kiếm sản phẩm từ nhà cung cấp hoặc tự nhập',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    splashRadius: 20,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 16),

            // Scrollable Search & Results Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Search & Input Field
                  _buildSearchField(),

                  const SizedBox(height: 12),

                  // Selected Product Card (if chosen)
                  if (_selectedProduct != null) ...[
                    _buildSelectedProductCard(),
                    const SizedBox(height: 14),
                  ],

                  // Amount / Quantity Input
                  _buildAmountInputSection(),

                  const SizedBox(height: 16),

                  // Supplier Products Header
                  _buildProductsHeader(),

                  const SizedBox(height: 8),

                  // Supplier Products Search Results
                  _buildSearchResultsSection(),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tên nguyên liệu / Tìm sản phẩm',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _selectedProduct != null
                  ? const Color(0xFFFF4D30)
                  : Colors.grey.shade300,
              width: _selectedProduct != null ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'VD: Thịt bò, Gạo ST25, Cà chua...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: const Icon(
                Iconsax.search_normal_1,
                size: 18,
                color: Color(0xFFFF4D30),
              ),
              suffixIcon: _nameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _nameController.clear();
                        _clearSelection();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedProductCard() {
    final prod = _selectedProduct!;
    final variant = _selectedVariant;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD0C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Sản phẩm từ Nhà cung cấp',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _clearSelection,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Đổi / Hủy',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF4D30),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 54,
                  height: 54,
                  color: Colors.grey.shade200,
                  child: prod.primaryImage != null && prod.primaryImage!.isNotEmpty
                      ? Image.network(
                          prod.primaryImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Iconsax.box,
                            color: Colors.grey,
                            size: 26,
                          ),
                        )
                      : const Icon(
                          Iconsax.box,
                          color: Colors.grey,
                          size: 26,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prod.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          variant != null && variant.price != null
                              ? '${variant.price!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ'
                              : prod.formattedPrice,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF4D30),
                          ),
                        ),
                        if (variant?.packSize != null || variant?.unit != null) ...[
                          Text(
                            ' / ${variant?.packSize ?? variant?.unit}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Variants Selector if multiple variants exist
          if (prod.variants.length > 1) ...[
            const SizedBox(height: 10),
            const Text(
              'Chọn quy cách đóng gói:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: prod.variants.map((v) {
                  final isSelected = _selectedVariant?.variantId == v.variantId;
                  final label = v.variantName ?? v.packSize ?? v.unit ?? 'Mặc định';
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFFECE8),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? const Color(0xFFFF4D30)
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFFF4D30)
                            : Colors.grey.shade300,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedVariant = v;
                            if (v.packSize != null && v.packSize!.isNotEmpty) {
                              _amountController.text = v.packSize!;
                            } else if (v.unit != null && v.unit!.isNotEmpty) {
                              _amountController.text = '1 ${v.unit}';
                            }
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Định lượng cho công thức',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'VD: 300g, 2 quả, 1 muỗng canh, Vừa đủ...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: const Icon(
                Iconsax.weight_1,
                size: 18,
                color: Colors.black54,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Quick quantity chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _commonUnits.map((unit) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ActionChip(
                  label: Text(unit),
                  labelStyle: const TextStyle(fontSize: 11, color: Colors.black87),
                  backgroundColor: Colors.grey.shade100,
                  side: BorderSide(color: Colors.grey.shade300, width: 0.8),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () {
                    setState(() {
                      _amountController.text = unit;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Iconsax.shop, size: 16, color: Color(0xFFFF4D30)),
            const SizedBox(width: 6),
            const Text(
              'Sản phẩm từ Nhà cung cấp',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 6),
            if (!_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_searchResults.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
        if (_isLoading)
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4D30)),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResultsSection() {
    if (_isLoading && _searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4D30)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đang tìm kiếm sản phẩm...',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null && _searchResults.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 18, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () => _fetchProducts(query: _nameController.text.trim()),
              child: const Text('Thử lại', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty && _hasSearched) {
      final query = _nameController.text.trim();
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Iconsax.box_search, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              query.isNotEmpty
                  ? 'Chưa có sản phẩm nào cho "$query"'
                  : 'Chưa có sản phẩm nào từ nhà cung cấp',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Bạn vẫn có thể thêm nguyên liệu này vào công thức để chia sẻ!',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            if (query.isNotEmpty) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF4D30),
                  side: const BorderSide(color: Color(0xFFFF4D30)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.check, size: 16),
                label: Text('Dùng "$query" làm nguyên liệu tự nhập'),
                onPressed: () {
                  _amountFocusNode.requestFocus();
                },
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: _searchResults.map((product) {
        final isSelected = _selectedProduct?.productId == product.productId;
        return _buildProductItemCard(product, isSelected: isSelected);
      }).toList(),
    );
  }

  Widget _buildProductItemCard(ProductSearchItemDto product, {required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF7F5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFFFF4D30) : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFFFF4D30).withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: InkWell(
        onTap: () => _selectProduct(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 52,
                  height: 52,
                  color: Colors.grey.shade100,
                  child: product.primaryImage != null &&
                          product.primaryImage!.isNotEmpty
                      ? Image.network(
                          product.primaryImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Iconsax.box,
                            color: Colors.grey,
                            size: 24,
                          ),
                        )
                      : const Icon(
                          Iconsax.box,
                          color: Colors.grey,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 10),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xFFFF4D30)
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF4D30),
                          ),
                        ),
                        if (product.displayUnit.isNotEmpty) ...[
                          Text(
                            ' • ${product.displayUnit}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Select button / check icon
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF4D30)
                      : const Color(0xFFFFECE8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSelected ? 'Đã chọn' : 'Chọn',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFFFF4D30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                'Hủy',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D30),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check, size: 18),
              label: Text(
                widget.editItem == null ? 'Thêm vào công thức' : 'Lưu thay đổi',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
