import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import '../../data/models/seller_product_item.dart';
import '../../data/models/product_category_type.dart';

class _SkuFormData {
  final String id;
  final TextEditingController nameController;
  final TextEditingController skuController;
  final TextEditingController priceController;
  final TextEditingController originalPriceController;
  final TextEditingController stockController;

  _SkuFormData({
    required this.id,
    String name = '',
    String sku = '',
    String price = '',
    String originalPrice = '',
    String stock = '10',
  })  : nameController = TextEditingController(text: name),
        skuController = TextEditingController(text: sku),
        priceController = TextEditingController(text: price),
        originalPriceController = TextEditingController(text: originalPrice),
        stockController = TextEditingController(text: stock);

  void dispose() {
    nameController.dispose();
    skuController.dispose();
    priceController.dispose();
    originalPriceController.dispose();
    stockController.dispose();
  }
}

class AddProductScreen extends StatefulWidget {
  final SellerProductItem? initialProduct;
  final ValueChanged<SellerProductItem>? onAdd;

  const AddProductScreen({
    super.key,
    this.initialProduct,
    this.onAdd,
  });

  static Future<SellerProductItem?> navigate(
    BuildContext context, {
    SellerProductItem? initialProduct,
    ValueChanged<SellerProductItem>? onAdd,
  }) {
    return Navigator.of(context).push<SellerProductItem>(
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          initialProduct: initialProduct,
          onAdd: onAdd,
        ),
      ),
    );
  }

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _priceController;
  late final TextEditingController _originalPriceController;
  late final TextEditingController _stockController;

  late String _selectedFoodCategory;
  late List<String> _images;

  // SKU Variants state
  late bool _hasMultipleSkus;
  final List<_SkuFormData> _skuItems = [];

  // Initial values for dirty check
  late final String _initialName;
  late final String _initialSku;
  late final String _initialPrice;
  late final String _initialOriginalPrice;
  late final String _initialStock;
  late final String _initialFoodCategory;
  late final List<String> _initialImages;
  late final bool _initialHasMultipleSkus;
  late final List<ProductSkuItem> _initialSkusSnapshot;

  final List<String> _foodCategories = const [
    'Thịt bò',
    'Thịt heo',
    'Thịt gia cầm',
    'Thịt cừu & dê',
    'Thủy hải sản',
    'Trứng các loại',
    'Rau củ tươi',
    'Nấm & Đậu hũ',
    'Trái cây tươi',
    'Thực phẩm chế biến',
    'Gia vị & Nước sốt',
    'Đồ khô & Ngũ cốc',
    'Bơ, Sữa & Phô mai',
    'Đồ đông lạnh',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;
    _initialName = p?.name ?? '';
    _initialSku = p?.sku ?? '';
    _initialPrice = p != null ? p.price.round().toString() : '';
    _initialOriginalPrice = p?.originalPrice != null ? p!.originalPrice!.round().toString() : '';
    _initialStock = p != null ? p.stock.toString() : '10';
    _initialFoodCategory = p?.foodCategory ?? 'Thịt bò';
    _initialImages = List.from(p?.images ?? (p?.imageUrl != null ? [p!.imageUrl!] : const []));
    _initialHasMultipleSkus = p?.hasMultipleSkus ?? false;
    _initialSkusSnapshot = List.from(p?.skus ?? const []);

    _nameController = TextEditingController(text: _initialName);
    _skuController = TextEditingController(text: _initialSku);
    _priceController = TextEditingController(text: _initialPrice);
    _originalPriceController = TextEditingController(text: _initialOriginalPrice);
    _stockController = TextEditingController(text: _initialStock);

    _selectedFoodCategory = _foodCategories.contains(_initialFoodCategory)
        ? _initialFoodCategory
        : _foodCategories.first;
    _images = List.from(_initialImages);
    _hasMultipleSkus = _initialHasMultipleSkus;

    if (_hasMultipleSkus && p != null && p.skus.isNotEmpty) {
      for (final sku in p.skus) {
        _skuItems.add(
          _SkuFormData(
            id: sku.id,
            name: sku.name,
            sku: sku.sku,
            price: sku.price.round().toString(),
            originalPrice: sku.originalPrice != null ? sku.originalPrice!.round().toString() : '',
            stock: sku.stock.toString(),
          ),
        );
      }
    } else {
      // Default initial 2 SKU items if user switches to multiple SKUs
      _skuItems.add(
        _SkuFormData(
          id: 'sku_${DateTime.now().millisecondsSinceEpoch}_1',
          name: 'Gói nhỏ (250g)',
          sku: _initialSku.isNotEmpty ? '$_initialSku-250G' : '',
          price: _initialPrice,
          originalPrice: _initialOriginalPrice,
          stock: '10',
        ),
      );
      _skuItems.add(
        _SkuFormData(
          id: 'sku_${DateTime.now().millisecondsSinceEpoch}_2',
          name: 'Gói lớn (500g)',
          sku: _initialSku.isNotEmpty ? '$_initialSku-500G' : '',
          price: _initialPrice.isNotEmpty
              ? ((double.tryParse(_initialPrice) ?? 0) * 1.8).round().toString()
              : '',
          originalPrice: '',
          stock: '10',
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    for (final item in _skuItems) {
      item.dispose();
    }
    super.dispose();
  }

  bool _hasChanges() {
    if (_nameController.text.trim() != _initialName.trim()) return true;
    if (_selectedFoodCategory != _initialFoodCategory) return true;
    if (_hasMultipleSkus != _initialHasMultipleSkus) return true;
    if (_images.length != _initialImages.length) return true;
    for (int i = 0; i < _images.length; i++) {
      if (_images[i] != _initialImages[i]) return true;
    }

    if (!_hasMultipleSkus) {
      if (_skuController.text.trim() != _initialSku.trim()) return true;
      if (_priceController.text.trim() != _initialPrice.trim()) return true;
      if (_originalPriceController.text.trim() != _initialOriginalPrice.trim()) return true;
      if (_stockController.text.trim() != _initialStock.trim()) return true;
    } else {
      if (_skuItems.length != _initialSkusSnapshot.length) return true;
      for (int i = 0; i < _skuItems.length; i++) {
        final form = _skuItems[i];
        final snap = _initialSkusSnapshot[i];
        if (form.nameController.text.trim() != snap.name.trim()) return true;
        if (form.skuController.text.trim() != snap.sku.trim()) return true;
        if (form.priceController.text.trim() != snap.price.round().toString()) return true;
        final orig = snap.originalPrice != null ? snap.originalPrice!.round().toString() : '';
        if (form.originalPriceController.text.trim() != orig) return true;
        if (form.stockController.text.trim() != snap.stock.toString()) return true;
      }
    }

    return false;
  }

  Future<void> _handleBackNavigation() async {
    if (!_hasChanges()) {
      Navigator.of(context).pop();
      return;
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Icon badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Iconsax.document_favorite,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Lưu bản nháp?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Bạn có thông tin thực phẩm đang chỉnh sửa chưa được gửi. Bạn có muốn lưu lại vào danh mục Bản nháp để không bị mất dữ liệu không?',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey.shade600,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Action 1: Lưu nháp (Primary)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(ctx).pop('save_draft'),
                  icon: const Icon(Iconsax.archive_book, size: 18),
                  label: const Text(
                    'Lưu bản nháp',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Action 2: Không lưu (Discard without saving)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(ctx).pop('discard'),
                  icon: const Icon(Iconsax.trash, size: 18, color: AppColors.error),
                  label: const Text(
                    'Không lưu',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                    backgroundColor: AppColors.error.withValues(alpha: 0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Action 3: Tiếp tục sửa (Stay)
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop('stay'),
                  child: const Text(
                    'Tiếp tục chỉnh sửa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == 'discard') {
      if (mounted) Navigator.of(context).pop();
    } else if (result == 'save_draft') {
      _saveDraftAndExit();
    }
  }

  void _saveDraftAndExit() {
    final name = _nameController.text.trim().isEmpty
        ? 'Bản nháp thực phẩm-${DateTime.now().millisecondsSinceEpoch % 100000}'
        : _nameController.text.trim();

    double price = 0;
    double? originalPrice;
    int stock = 0;
    String sku = _skuController.text.trim();
    final List<ProductSkuItem> skus = [];

    if (_hasMultipleSkus && _skuItems.isNotEmpty) {
      for (final item in _skuItems) {
        final itemPrice = double.tryParse(item.priceController.text.trim()) ?? 0;
        final origStr = item.originalPriceController.text.trim();
        final itemOriginalPrice = origStr.isNotEmpty ? double.tryParse(origStr) : null;
        final itemStock = int.tryParse(item.stockController.text.trim()) ?? 0;
        final itemName = item.nameController.text.trim().isNotEmpty
            ? item.nameController.text.trim()
            : 'Phân loại';

        skus.add(
          ProductSkuItem(
            id: item.id,
            name: itemName,
            sku: item.skuController.text.trim(),
            price: itemPrice,
            originalPrice: itemOriginalPrice,
            stock: itemStock,
          ),
        );
      }
      price = skus.map((s) => s.price).reduce((a, b) => a < b ? a : b);
      stock = skus.fold(0, (sum, s) => sum + s.stock);
      if (sku.isEmpty) {
        sku = skus.first.sku.isNotEmpty ? skus.first.sku : 'NHAP-${DateTime.now().millisecondsSinceEpoch % 100000}';
      }
    } else {
      price = double.tryParse(_priceController.text.trim()) ?? 0;
      final originalPriceText = _originalPriceController.text.trim();
      originalPrice = originalPriceText.isNotEmpty ? double.tryParse(originalPriceText) : null;
      stock = int.tryParse(_stockController.text.trim()) ?? 0;
      if (sku.isEmpty) {
        sku = 'NHAP-${DateTime.now().millisecondsSinceEpoch % 100000}';
      }
    }

    final draftProduct = SellerProductItem(
      id: widget.initialProduct?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      sku: sku,
      price: price,
      originalPrice: originalPrice,
      stock: stock,
      imageUrl: _images.isNotEmpty ? _images.first : null,
      images: _images,
      categoryType: ProductCategoryType.draft,
      foodCategory: _selectedFoodCategory,
      isAvailable: false,
      updatedAt: DateTime.now(),
      skus: skus,
    );

    if (widget.onAdd != null) {
      widget.onAdd!(draftProduct);
    }

    Navigator.of(context).pop(draftProduct);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (photo != null) {
          setState(() {
            _images.add(photo.path);
          });
        }
      } else {
        final List<XFile> picked = await _picker.pickMultiImage(
          imageQuality: 85,
        );
        if (picked.isNotEmpty) {
          setState(() {
            _images.addAll(picked.map((e) => e.path));
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Thêm ảnh thực phẩm',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Iconsax.camera, color: AppColors.primary),
                ),
                title: const Text('Chụp ảnh từ máy ảnh', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Chụp trực tiếp hình ảnh thực phẩm thực tế'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Iconsax.gallery, color: AppColors.primary),
                ),
                title: const Text('Chọn ảnh từ thư viện', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Có thể chọn nhiều ảnh cùng lúc'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  const Icon(Iconsax.category_2, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Chọn danh mục thực phẩm',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, color: AppColors.textHint, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _foodCategories.length,
                separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final cat = _foodCategories[index];
                  final isSelected = cat == _selectedFoodCategory;
                  return ListTile(
                    leading: Icon(
                      _getFoodCategoryIcon(cat),
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      size: 22,
                    ),
                    title: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Iconsax.tick_circle, color: AppColors.primary, size: 20)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedFoodCategory = cat;
                      });
                      Navigator.of(ctx).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFoodCategoryIcon(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('bò') || lower.contains('heo') || lower.contains('cừu') || lower.contains('gia cầm')) {
      return Iconsax.reserve;
    }
    if (lower.contains('thủy hải sản') || lower.contains('tôm') || lower.contains('cá')) {
      return Icons.set_meal;
    }
    if (lower.contains('trứng')) {
      return Icons.egg_outlined;
    }
    if (lower.contains('rau')) {
      return Icons.eco_outlined;
    }
    if (lower.contains('nấm') || lower.contains('đậu hũ')) {
      return Iconsax.box_1;
    }
    if (lower.contains('trái cây')) {
      return Icons.apple;
    }
    if (lower.contains('chế biến') || lower.contains('xúc xích')) {
      return Iconsax.archive_book;
    }
    if (lower.contains('gia vị')) {
      return Iconsax.magic_star;
    }
    if (lower.contains('đông lạnh')) {
      return Icons.ac_unit;
    }
    if (lower.contains('đồ hộp')) {
      return Iconsax.box_1;
    }
    if (lower.contains('sữa') || lower.contains('bơ')) {
      return Iconsax.cup;
    }
    return Iconsax.category;
  }

  void _addSkuItem() {
    setState(() {
      final index = _skuItems.length + 1;
      _skuItems.add(
        _SkuFormData(
          id: 'sku_${DateTime.now().millisecondsSinceEpoch}_$index',
          name: '',
          sku: '',
          price: '',
          originalPrice: '',
          stock: '10',
        ),
      );
    });
  }

  void _removeSkuItem(int index) {
    if (_skuItems.length <= 1) return;
    setState(() {
      final item = _skuItems.removeAt(index);
      item.dispose();
    });
  }

  void _submitForReview() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại các trường thông tin bắt buộc (*)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_images.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng tải lên tối thiểu 5 ảnh thực phẩm trước khi gửi xét duyệt (hiện có: ${_images.length}/5 ảnh)',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    double price = 0;
    double? originalPrice;
    int stock = 0;
    String sku = _skuController.text.trim();
    final List<ProductSkuItem> skus = [];

    if (_hasMultipleSkus) {
      if (_skuItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng thêm ít nhất một phân loại SKU'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      for (int i = 0; i < _skuItems.length; i++) {
        final form = _skuItems[i];
        final name = form.nameController.text.trim();
        final p = double.tryParse(form.priceController.text.trim());
        final s = int.tryParse(form.stockController.text.trim());

        if (name.isEmpty || p == null || p <= 0 || s == null || s < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vui lòng nhập đủ Tên, Giá bán (> 0) và Tồn kho cho Phân loại #${i + 1}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        final origStr = form.originalPriceController.text.trim();
        final orig = origStr.isNotEmpty ? double.tryParse(origStr) : null;

        skus.add(
          ProductSkuItem(
            id: form.id,
            name: name,
            sku: form.skuController.text.trim().isNotEmpty
                ? form.skuController.text.trim()
                : 'SKU-${i + 1}',
            price: p,
            originalPrice: orig,
            stock: s,
          ),
        );
      }

      price = skus.map((s) => s.price).reduce((a, b) => a < b ? a : b);
      stock = skus.fold(0, (sum, s) => sum + s.stock);
      if (sku.isEmpty) {
        sku = skus.first.sku;
      }
    } else {
      price = double.tryParse(_priceController.text.trim()) ?? 0;
      final originalPriceText = _originalPriceController.text.trim();
      originalPrice = originalPriceText.isNotEmpty ? double.tryParse(originalPriceText) : null;
      stock = int.tryParse(_stockController.text.trim()) ?? 0;
      if (sku.isEmpty) {
        sku = 'TP-${DateTime.now().millisecondsSinceEpoch % 100000}';
      }
    }

    final product = SellerProductItem(
      id: widget.initialProduct?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      sku: sku,
      price: price,
      originalPrice: originalPrice,
      stock: stock,
      imageUrl: _images.first,
      images: _images,
      categoryType: ProductCategoryType.underReview,
      foodCategory: _selectedFoodCategory,
      isAvailable: false,
      updatedAt: DateTime.now(),
      skus: skus,
    );

    if (widget.onAdd != null) {
      widget.onAdd!(product);
    }

    Navigator.of(context).pop(product);
  }

  void _adjustStock(int delta) {
    final current = int.tryParse(_stockController.text.trim()) ?? 0;
    final updated = (current + delta).clamp(0, 99999);
    setState(() {
      _stockController.text = updated.toString();
    });
  }

  void _adjustSkuStock(int index, int delta) {
    final controller = _skuItems[index].stockController;
    final current = int.tryParse(controller.text.trim()) ?? 0;
    final updated = (current + delta).clamp(0, 99999);
    setState(() {
      controller.text = updated.toString();
    });
  }

  Widget _buildImageThumb(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Center(
          child: Icon(Iconsax.image, color: AppColors.textHint, size: 24),
        ),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Center(
        child: Icon(Iconsax.image, color: AppColors.textHint, size: 24),
      ),
    );
  }

  String _formatPrice(double amount) {
    final int val = amount.round();
    final str = val.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join('')} đ';
  }

  @override
  Widget build(BuildContext context) {
    final hasEnoughImages = _images.length >= 5;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: _handleBackNavigation,
          ),
          title: Text(
            widget.initialProduct != null ? 'Chỉnh sửa thực phẩm' : 'Thêm sản phẩm mới',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                onPressed: _submitForReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                child: const Text('Xét duyệt'),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              // 1. Real Images Picker Section (Tối thiểu 5 ảnh thật)
              _buildSectionCard(
                title: 'Hình ảnh sản phẩm *',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: hasEnoughImages
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_images.length}/5 ảnh tối thiểu',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: hasEnoughImages ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
                subtitle: hasEnoughImages
                    ? 'Đã đủ số lượng ảnh tối thiểu. Ảnh đầu tiên sẽ làm ảnh bìa.'
                    : 'Yêu cầu tải lên tối thiểu 5 ảnh thật từ máy ảnh hoặc thư viện ảnh thiết bị.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        // Uploaded Images
                        ..._images.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final imgPath = entry.value;
                          final isCover = idx == 0;
                          return Stack(
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isCover ? AppColors.primary : Colors.grey.shade300,
                                    width: isCover ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildImageThumb(imgPath),
                                ),
                              ),
                              // Cover Badge
                              if (isCover)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                                    ),
                                    child: const Text(
                                      'Ảnh bìa',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              // Delete Button
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _images.removeAt(idx);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 12),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        // Add Button
                        InkWell(
                          onTap: _showImagePickerSheet,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: hasEnoughImages ? Colors.grey.shade300 : AppColors.error,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.camera,
                                  size: 26,
                                  color: hasEnoughImages ? AppColors.textSecondary : AppColors.error,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+ Thêm ảnh',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: hasEnoughImages ? AppColors.textSecondary : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!hasEnoughImages) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Cần tải lên thêm ít nhất ${5 - _images.length} ảnh nữa để đủ điều kiện xét duyệt',
                        style: const TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Food Basic Information Section
              _buildSectionCard(
                title: 'Thông tin thực phẩm',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tên thực phẩm *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'VD: Thịt thăn bò Úc, Xúc xích xông khói, Trứng gà ta...',
                        prefixIcon: Icon(Iconsax.tag, size: 18),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập tên thực phẩm';
                        }
                        if (val.trim().length < 2) {
                          return 'Tên thực phẩm quá ngắn';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Food category picker (opens Modal Bottom Sheet)
                    const Text(
                      'Danh mục thực phẩm *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _showCategoryBottomSheet,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getFoodCategoryIcon(_selectedFoodCategory),
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedFoodCategory,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(
                              Iconsax.arrow_down_1,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Price, Stock & Multiple SKUs Section
              _buildSectionCard(
                title: 'Phân loại & Giá bán (SKU)',
                subtitle: 'Chọn hình thức quy cách phù hợp cho thực phẩm của bạn',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segmented Type Selector
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _hasMultipleSkus = false),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: !_hasMultipleSkus ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: !_hasMultipleSkus
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Iconsax.box,
                                      size: 16,
                                      color: !_hasMultipleSkus ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Duy nhất 1 loại',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: !_hasMultipleSkus ? FontWeight.bold : FontWeight.w500,
                                        color: !_hasMultipleSkus ? AppColors.primary : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _hasMultipleSkus = true),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: _hasMultipleSkus ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: _hasMultipleSkus
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Iconsax.element_plus,
                                      size: 16,
                                      color: _hasMultipleSkus ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Nhiều phân loại (SKU)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _hasMultipleSkus ? FontWeight.bold : FontWeight.w500,
                                        color: _hasMultipleSkus ? AppColors.primary : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CASE A: Single SKU mode
                    if (!_hasMultipleSkus) ...[
                      const Text(
                        'Mã SKU (Tùy chọn)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _skuController,
                        decoration: const InputDecoration(
                          hintText: 'VD: TP-001',
                          prefixIcon: Icon(Iconsax.barcode, size: 18),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          // Selling price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giá bán (VNĐ) *',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: const InputDecoration(
                                    hintText: 'VD: 55000',
                                    suffixText: 'đ',
                                    prefixIcon: Icon(Iconsax.money, size: 18),
                                  ),
                                  validator: (val) {
                                    if (!_hasMultipleSkus) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Nhập giá bán';
                                      }
                                      final p = double.tryParse(val.trim());
                                      if (p == null || p <= 0) {
                                        return 'Giá không hợp lệ';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Original price with Icon
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giá gốc (Nếu có)',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _originalPriceController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: const InputDecoration(
                                    hintText: 'VD: 65000',
                                    suffixText: 'đ',
                                    prefixIcon: Icon(Iconsax.ticket_discount, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Số lượng tồn kho ban đầu *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildStockButton(
                            icon: Icons.remove,
                            onTap: () => _adjustStock(-5),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(
                                hintText: '10',
                                prefixIcon: Icon(Iconsax.box, size: 18),
                              ),
                              validator: (val) {
                                if (!_hasMultipleSkus) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Nhập số lượng tồn kho';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStockButton(
                            icon: Icons.add,
                            onTap: () => _adjustStock(5),
                          ),
                        ],
                      ),
                    ]
                    // CASE B: Multiple SKUs mode
                    else ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Iconsax.info_circle, color: AppColors.primary, size: 16),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Thêm các quy cách / phân loại của thực phẩm (VD: Gói nhỏ 250g, Gói to 500g, 1kg hoặc Vị cay / Vị truyền thống...).',
                                style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // List of SKU items
                      ..._skuItems.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Phân loại #${idx + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_skuItems.length > 1)
                                    IconButton(
                                      icon: const Icon(Iconsax.trash, size: 17, color: AppColors.error),
                                      onPressed: () => _removeSkuItem(idx),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: 'Xóa phân loại này',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Tên phân loại / Quy cách *',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: item.nameController,
                                decoration: const InputDecoration(
                                  hintText: 'VD: Gói nhỏ 250g, Gói to 500g, Cắt khúc...',
                                  prefixIcon: Icon(Iconsax.tag, size: 16),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Mã SKU phân loại (Tùy chọn)',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: item.skuController,
                                decoration: const InputDecoration(
                                  hintText: 'VD: XX-250G',
                                  prefixIcon: Icon(Iconsax.barcode, size: 16),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Giá bán (VNĐ) *',
                                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        TextFormField(
                                          controller: item.priceController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: const InputDecoration(
                                            hintText: 'VD: 45000',
                                            suffixText: 'đ',
                                            prefixIcon: Icon(Iconsax.money, size: 16),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Giá gốc (Nếu có)',
                                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        TextFormField(
                                          controller: item.originalPriceController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: const InputDecoration(
                                            hintText: 'VD: 55000',
                                            suffixText: 'đ',
                                            prefixIcon: Icon(Iconsax.ticket_discount, size: 16),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Số lượng tồn kho *',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildStockButton(
                                    icon: Icons.remove,
                                    onTap: () => _adjustSkuStock(idx, -5),
                                    size: 38,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: item.stockController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: const InputDecoration(
                                        hintText: '10',
                                        prefixIcon: Icon(Iconsax.box, size: 16),
                                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStockButton(
                                    icon: Icons.add,
                                    onTap: () => _adjustSkuStock(idx, 5),
                                    size: 38,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      // Add SKU Button
                      OutlinedButton.icon(
                        onPressed: _addSkuItem,
                        icon: const Icon(Iconsax.add_circle, size: 18),
                        label: const Text('+ Thêm phân loại SKU mới'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // SKU Summary Box
                      Builder(builder: (context) {
                        final totalStock = _skuItems.fold<int>(
                          0,
                          (sum, item) => sum + (int.tryParse(item.stockController.text.trim()) ?? 0),
                        );
                        final prices = _skuItems
                            .map((e) => double.tryParse(e.priceController.text.trim()) ?? 0)
                            .where((p) => p > 0)
                            .toList();

                        String priceRangeText = 'Chưa thiết lập';
                        if (prices.isNotEmpty) {
                          final min = prices.reduce((a, b) => a < b ? a : b);
                          final max = prices.reduce((a, b) => a > b ? a : b);
                          priceRangeText = min == max
                              ? _formatPrice(min)
                              : '${_formatPrice(min)} - ${_formatPrice(max)}';
                        }

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('Số phân loại', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_skuItems.length} SKU',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                              Container(height: 24, width: 1, color: Colors.grey.shade300),
                              Column(
                                children: [
                                  const Text('Tổng kho', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$totalStock',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              Container(height: 24, width: 1, color: Colors.grey.shade300),
                              Column(
                                children: [
                                  const Text('Khoảng giá', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    priceRangeText,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Policy info note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Iconsax.info_circle, color: AppColors.info, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Thực phẩm sau khi bấm "Xét duyệt" sẽ được chuyển đến trạng thái Đang xét duyệt để đội ngũ kiểm duyệt nội dung an toàn thực phẩm, nguồn gốc và chất lượng trước khi chính thức mở bán.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          height: 1.35,
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

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ?trailing,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildStockButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 44,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: size * 0.45, color: AppColors.textPrimary),
      ),
    );
  }
}
