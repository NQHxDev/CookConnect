import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/core/storage/token_storage_service.dart';
import 'package:cook_connect_seller/core/network/api_exception.dart';
import '../../data/models/seller_product_item.dart';
import '../../data/models/product_category_type.dart';
import '../../data/models/product_category.dart';
import '../../data/models/product_dtos.dart';
import '../../data/services/product_category_service.dart';
import '../../data/services/product_api_service.dart';
import '../../data/services/product_background_queue_service.dart';
import '../widgets/product_images_uploader.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';

class _SkuFormData {
  final String id;
  final TextEditingController nameController;
  final TextEditingController skuController;
  final TextEditingController unitController;
  final TextEditingController packSizeController;
  final TextEditingController priceController;
  final TextEditingController originalPriceController;
  final TextEditingController stockController;
  final TextEditingController lowStockController;
  bool isDefault;
  VoidCallback? _listener;

  _SkuFormData({
    required this.id,
    String name = '',
    String sku = '',
    String unit = 'kg',
    String packSize = '',
    String price = '',
    String originalPrice = '',
    String stock = '10',
    String lowStock = '10',
    this.isDefault = false,
  })  : nameController = TextEditingController(text: name),
        skuController = TextEditingController(text: sku),
        unitController = TextEditingController(text: unit),
        packSizeController = TextEditingController(text: packSize),
        priceController = TextEditingController(text: price),
        originalPriceController = TextEditingController(text: originalPrice),
        stockController = TextEditingController(text: stock),
        lowStockController = TextEditingController(text: lowStock);

  void attachListener(VoidCallback listener) {
    detachListener();
    _listener = listener;
    nameController.addListener(listener);
    skuController.addListener(listener);
    unitController.addListener(listener);
    packSizeController.addListener(listener);
    priceController.addListener(listener);
    originalPriceController.addListener(listener);
    stockController.addListener(listener);
    lowStockController.addListener(listener);
  }

  void detachListener() {
    final l = _listener;
    if (l != null) {
      nameController.removeListener(l);
      skuController.removeListener(l);
      unitController.removeListener(l);
      packSizeController.removeListener(l);
      priceController.removeListener(l);
      originalPriceController.removeListener(l);
      stockController.removeListener(l);
      lowStockController.removeListener(l);
      _listener = null;
    }
  }

  void dispose() {
    detachListener();
    nameController.dispose();
    skuController.dispose();
    unitController.dispose();
    packSizeController.dispose();
    priceController.dispose();
    originalPriceController.dispose();
    stockController.dispose();
    lowStockController.dispose();
  }
}

class AddProductScreen extends StatefulWidget {
  final SellerProductItem? initialProduct;
  final List<String>? initialImages;
  final ValueChanged<SellerProductItem>? onAdd;
  final ProductCategoryService? categoryService;
  final ProductApiService? productApiService;
  final TokenStorageService? tokenStorage;
  final String? supplierId;
  final String? failedTaskId;

  const AddProductScreen({
    super.key,
    this.initialProduct,
    this.initialImages,
    this.onAdd,
    this.categoryService,
    this.productApiService,
    this.tokenStorage,
    this.supplierId,
    this.failedTaskId,
  });

  static Future<SellerProductItem?> navigate(
    BuildContext context, {
    SellerProductItem? initialProduct,
    ValueChanged<SellerProductItem>? onAdd,
    ProductCategoryService? categoryService,
    ProductApiService? productApiService,
    TokenStorageService? tokenStorage,
    String? supplierId,
    String? failedTaskId,
  }) {
    return Navigator.of(context).push<SellerProductItem>(
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          initialProduct: initialProduct,
          onAdd: onAdd,
          categoryService: categoryService,
          productApiService: productApiService,
          tokenStorage: tokenStorage,
          supplierId: supplierId,
          failedTaskId: failedTaskId,
        ),
      ),
    );
  }

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  String _resolveSupplierId() {
    if (widget.supplierId != null && widget.supplierId!.isNotEmpty) {
      return widget.supplierId!;
    }
    if (widget.initialProduct?.supplierId != null &&
        widget.initialProduct!.supplierId!.isNotEmpty) {
      return widget.initialProduct!.supplierId!;
    }
    final authSupplierId = SellerAuthService.instance.supplierProfile?.supplierId ??
        SellerAuthService.instance.currentUser?.storeId;
    if (authSupplierId != null && authSupplierId.isNotEmpty) {
      return authSupplierId;
    }
    return '';
  }

  // 1. Basic product info controllers
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _priceController;
  late final TextEditingController _originalPriceController;
  late final TextEditingController _unitController;
  late final TextEditingController _packSizeController;
  late final TextEditingController _stockController;
  late final TextEditingController _lowStockThresholdController;

  // 2. Additional food attributes matching Swagger schema CreateProductDto
  late final TextEditingController _descriptionController;
  late final TextEditingController _originController;
  late final TextEditingController _storageConditionController;
  late final TextEditingController _shelfLifeDaysController;

  String? _selectedFoodCategory;
  String? _categoryError;
  late List<String> _images;

  // SKU Variants state
  late bool _hasMultipleSkus;
  final List<_SkuFormData> _skuItems = [];
  late final ProductCategoryService _categoryService;
  late final ProductApiService _productApiService;
  late final TokenStorageService _tokenStorage;
  String? _selectedWhoCategoryCode;

  // Loading state
  bool _isSubmitting = false;
  String? _submittingStatusMessage;

  // Initial values for dirty check
  late final String _initialName;
  late final String _initialSku;
  late final String _initialPrice;
  late final String _initialOriginalPrice;
  late final String _initialUnit;
  late final String _initialPackSize;
  late final String _initialStock;
  late final String _initialLowStock;
  late final String _initialDescription;
  late final String _initialOrigin;
  late final String _initialStorageCondition;
  late final String _initialShelfLifeDays;
  late final String? _initialFoodCategory;
  late final List<String> _initialImages;
  late final bool _initialHasMultipleSkus;
  late final List<ProductSkuItem> _initialSkusSnapshot;

  List<ProductCategory> _categories = ProductCategory.defaultCategories;

  static const List<String> _commonUnits = [
    'kg',
    'g',
    'túi',
    'hộp',
    'khay',
    'bó',
    'chai',
    'con',
    'thùng',
  ];

  static const List<String> _storageSuggestions = [
    'Nơi khô ráo, thoáng mát',
    'Ngăn mát 2-4°C',
    'Ngăn đông -18°C',
    'Tránh ánh nắng trực tiếp',
  ];

  static const List<String> _shelfLifeSuggestions = [
    '7',
    '14',
    '30',
    '60',
    '90',
    '180',
    '365',
  ];

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      if (mounted && categories.isNotEmpty) {
        setState(() {
          _categories = categories;
          if (_selectedWhoCategoryCode != null) {
            final found = _categories
                .where(
                  (c) =>
                      c.code.toUpperCase() ==
                      _selectedWhoCategoryCode!.toUpperCase(),
                )
                .firstOrNull;
            if (found != null) {
              _selectedFoodCategory = found.name;
            }
          }
        });
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _categoryService = widget.categoryService ?? ProductCategoryService();
    _productApiService = widget.productApiService ?? ProductApiService();
    _tokenStorage = widget.tokenStorage ?? SecureTokenStorageService();
    _loadCategories();

    final p = widget.initialProduct;
    _initialName = p?.name ?? '';
    _initialSku = p?.sku ?? '';
    _initialPrice = p != null ? p.price.round().toString() : '';
    _initialOriginalPrice = p?.originalPrice != null
        ? p!.originalPrice!.round().toString()
        : '';
    _initialUnit = p?.unit.isNotEmpty == true ? p!.unit : 'kg';
    _initialPackSize = p?.packSize ?? '';
    _initialStock = p != null ? p.stock.toString() : '10';
    _initialLowStock = p != null && p.skus.isNotEmpty
        ? p.skus.first.lowStockThreshold.toString()
        : '10';

    _initialDescription = p?.description ?? '';
    _initialOrigin = p?.origin ?? '';
    _initialStorageCondition = p?.storageCondition ?? '';
    _initialShelfLifeDays = p?.shelfLifeDays != null
        ? p!.shelfLifeDays.toString()
        : '';

    _initialFoodCategory = p?.foodCategory;
    _initialImages = List.from(
      widget.initialImages ??
          p?.images ??
          (p?.imageUrl != null ? [p!.imageUrl!] : const []),
    );
    _initialHasMultipleSkus = p?.hasMultipleSkus ?? false;
    _initialSkusSnapshot = List.from(p?.skus ?? const []);

    _nameController = TextEditingController(text: _initialName);
    _skuController = TextEditingController(text: _initialSku);
    _priceController = TextEditingController(text: _initialPrice);
    _originalPriceController = TextEditingController(text: _initialOriginalPrice);
    _unitController = TextEditingController(text: _initialUnit);
    _packSizeController = TextEditingController(text: _initialPackSize);
    _stockController = TextEditingController(text: _initialStock);
    _lowStockThresholdController = TextEditingController(text: _initialLowStock);

    _descriptionController = TextEditingController(text: _initialDescription);
    _originController = TextEditingController(text: _initialOrigin);
    _storageConditionController = TextEditingController(text: _initialStorageCondition);
    _shelfLifeDaysController = TextEditingController(text: _initialShelfLifeDays);

    final initialFoodCat = _initialFoodCategory;
    if (initialFoodCat != null && initialFoodCat.trim().isNotEmpty) {
      final matching = _categories
          .where(
            (c) =>
                c.name == initialFoodCat ||
                (p?.whoCategoryCode != null &&
                    c.code.toUpperCase() == p!.whoCategoryCode!.toUpperCase()),
          )
          .firstOrNull;
      if (matching != null) {
        _selectedFoodCategory = matching.name;
        _selectedWhoCategoryCode = matching.code;
      } else {
        final mapped = ProductCategory.mapToWhoCategory(_initialFoodCategory);
        _selectedFoodCategory = mapped.name;
        _selectedWhoCategoryCode = mapped.code;
      }
    } else if (p?.whoCategoryCode != null && p!.whoCategoryCode!.isNotEmpty) {
      final found = ProductCategory.findByCode(p.whoCategoryCode);
      if (found != null) {
        _selectedFoodCategory = found.name;
        _selectedWhoCategoryCode = found.code;
      } else {
        _selectedFoodCategory = null;
        _selectedWhoCategoryCode = null;
      }
    } else {
      _selectedFoodCategory = null;
      _selectedWhoCategoryCode = null;
    }
    _images = List.from(_initialImages);
    _hasMultipleSkus = _initialHasMultipleSkus;

    if (_hasMultipleSkus && p != null && p.skus.isNotEmpty) {
      for (final sku in p.skus) {
        _skuItems.add(
          _SkuFormData(
            id: sku.id,
            name: sku.name,
            sku: sku.sku,
            unit: sku.unit.isNotEmpty ? sku.unit : 'kg',
            packSize: sku.packSize ?? '',
            price: sku.price.round().toString(),
            originalPrice: sku.originalPrice != null
                ? sku.originalPrice!.round().toString()
                : '',
            stock: sku.stock.toString(),
            lowStock: sku.lowStockThreshold.toString(),
            isDefault: sku.isDefault,
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
          unit: 'túi',
          packSize: '250g',
          price: _initialPrice,
          originalPrice: _initialOriginalPrice,
          stock: '10',
          lowStock: '10',
          isDefault: true,
        ),
      );
      _skuItems.add(
        _SkuFormData(
          id: 'sku_${DateTime.now().millisecondsSinceEpoch}_2',
          name: 'Gói lớn (500g)',
          sku: _initialSku.isNotEmpty ? '$_initialSku-500G' : '',
          unit: 'túi',
          packSize: '500g',
          price: _initialPrice.isNotEmpty
              ? ((double.tryParse(_initialPrice) ?? 0) * 1.8).round().toString()
              : '',
          originalPrice: '',
          stock: '10',
          lowStock: '10',
          isDefault: false,
        ),
      );
    }

    _nameController.addListener(_onFormFieldChanged);
    _skuController.addListener(_onFormFieldChanged);
    _priceController.addListener(_onFormFieldChanged);
    _originalPriceController.addListener(_onFormFieldChanged);
    _unitController.addListener(_onFormFieldChanged);
    _packSizeController.addListener(_onFormFieldChanged);
    _stockController.addListener(_onFormFieldChanged);
    _lowStockThresholdController.addListener(_onFormFieldChanged);
    _descriptionController.addListener(_onFormFieldChanged);
    _originController.addListener(_onFormFieldChanged);
    _storageConditionController.addListener(_onFormFieldChanged);
    _shelfLifeDaysController.addListener(_onFormFieldChanged);

    for (final item in _skuItems) {
      item.attachListener(_onFormFieldChanged);
    }
  }

  void _onFormFieldChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _isFormValid {
    // 1. Tối thiểu 5 ảnh thực phẩm theo quy định
    if (_images.length < 5) {
      return false;
    }

    // 2. Tên thực phẩm: bắt buộc, từ 2 đến 200 ký tự
    final name = _nameController.text.trim();
    if (name.length < 2 || name.length > 200) {
      return false;
    }

    // 3. Danh mục thực phẩm: bắt buộc
    if (_selectedFoodCategory == null || _selectedFoodCategory!.trim().isEmpty) {
      return false;
    }

    // 4. Phân loại & Giá bán
    if (!_hasMultipleSkus) {
      // Giá bán > 0
      final price = double.tryParse(_priceController.text.trim());
      if (price == null || price <= 0) {
        return false;
      }

      // Đơn vị tính: bắt buộc
      if (_unitController.text.trim().isEmpty) {
        return false;
      }

      // Số lượng tồn kho ban đầu: >= 0
      final stock = int.tryParse(_stockController.text.trim());
      if (stock == null || stock < 0) {
        return false;
      }
    } else {
      // Nhiều phân loại: cần ít nhất 1 phân loại và mỗi phân loại phải có đủ Tên, Đơn vị, Giá > 0, Tồn kho >= 0
      if (_skuItems.isEmpty) {
        return false;
      }
      for (final item in _skuItems) {
        if (item.nameController.text.trim().isEmpty) {
          return false;
        }
        if (item.unitController.text.trim().isEmpty) {
          return false;
        }
        final p = double.tryParse(item.priceController.text.trim());
        if (p == null || p <= 0) {
          return false;
        }
        final s = int.tryParse(item.stockController.text.trim());
        if (s == null || s < 0) {
          return false;
        }
      }
    }

    // 5. Mô tả chi tiết thực phẩm: bắt buộc, tối thiểu 10 ký tự
    final desc = _descriptionController.text.trim();
    if (desc.length < 10) {
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormFieldChanged);
    _skuController.removeListener(_onFormFieldChanged);
    _priceController.removeListener(_onFormFieldChanged);
    _originalPriceController.removeListener(_onFormFieldChanged);
    _unitController.removeListener(_onFormFieldChanged);
    _packSizeController.removeListener(_onFormFieldChanged);
    _stockController.removeListener(_onFormFieldChanged);
    _lowStockThresholdController.removeListener(_onFormFieldChanged);
    _descriptionController.removeListener(_onFormFieldChanged);
    _originController.removeListener(_onFormFieldChanged);
    _storageConditionController.removeListener(_onFormFieldChanged);
    _shelfLifeDaysController.removeListener(_onFormFieldChanged);

    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _unitController.dispose();
    _packSizeController.dispose();
    _stockController.dispose();
    _lowStockThresholdController.dispose();

    _descriptionController.dispose();
    _originController.dispose();
    _storageConditionController.dispose();
    _shelfLifeDaysController.dispose();

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
    if (_descriptionController.text.trim() != _initialDescription.trim()) return true;
    if (_originController.text.trim() != _initialOrigin.trim()) return true;
    if (_storageConditionController.text.trim() != _initialStorageCondition.trim()) return true;
    if (_shelfLifeDaysController.text.trim() != _initialShelfLifeDays.trim()) return true;

    for (int i = 0; i < _images.length; i++) {
      if (_images[i] != _initialImages[i]) return true;
    }

    if (!_hasMultipleSkus) {
      if (_skuController.text.trim() != _initialSku.trim()) return true;
      if (_unitController.text.trim() != _initialUnit.trim()) return true;
      if (_packSizeController.text.trim() != _initialPackSize.trim()) return true;
      if (_priceController.text.trim() != _initialPrice.trim()) return true;
      if (_originalPriceController.text.trim() != _initialOriginalPrice.trim()) return true;
      if (_stockController.text.trim() != _initialStock.trim()) return true;
      if (_lowStockThresholdController.text.trim() != _initialLowStock.trim()) return true;
    } else {
      if (_skuItems.length != _initialSkusSnapshot.length) return true;
      for (int i = 0; i < _skuItems.length; i++) {
        final form = _skuItems[i];
        final snap = _initialSkusSnapshot[i];
        if (form.nameController.text.trim() != snap.name.trim()) return true;
        if (form.skuController.text.trim() != snap.sku.trim()) return true;
        if (form.unitController.text.trim() != snap.unit.trim()) return true;
        if (form.packSizeController.text.trim() != (snap.packSize ?? '').trim()) return true;
        if (form.priceController.text.trim() != snap.price.round().toString()) return true;
        final orig = snap.originalPrice != null ? snap.originalPrice!.round().toString() : '';
        if (form.originalPriceController.text.trim() != orig) return true;
        if (form.stockController.text.trim() != snap.stock.toString()) return true;
        if (form.lowStockController.text.trim() != snap.lowStockThreshold.toString()) return true;
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
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
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
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(ctx).pop('discard'),
                  icon: const Icon(
                    Iconsax.trash,
                    size: 18,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    'Không lưu',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                    backgroundColor: AppColors.error.withValues(alpha: 0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
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
      await _saveDraftAndExit();
    }
  }

  Future<void> _saveDraftAndExit() async {
    setState(() {
      _isSubmitting = true;
      _submittingStatusMessage = 'Đang lưu bản nháp...';
    });

    try {
      final name = _nameController.text.trim().isEmpty
          ? 'Bản nháp thực phẩm-${DateTime.now().millisecondsSinceEpoch % 100000}'
          : _nameController.text.trim();

      double price = 0;
      double? originalPrice;
      int stock = 0;
      String sku = _skuController.text.trim();
      String unit = _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : 'kg';
      String? packSize = _packSizeController.text.trim().isNotEmpty ? _packSizeController.text.trim() : null;
      final List<ProductSkuItem> skus = [];

      if (_hasMultipleSkus && _skuItems.isNotEmpty) {
        for (int i = 0; i < _skuItems.length; i++) {
          final item = _skuItems[i];
          final itemPrice = double.tryParse(item.priceController.text.trim()) ?? 0;
          final origStr = item.originalPriceController.text.trim();
          final itemOriginalPrice = origStr.isNotEmpty ? double.tryParse(origStr) : null;
          final itemStock = int.tryParse(item.stockController.text.trim()) ?? 0;
          final itemLowStock = int.tryParse(item.lowStockController.text.trim()) ?? 10;
          final itemName = item.nameController.text.trim().isNotEmpty
              ? item.nameController.text.trim()
              : 'Phân loại #${i + 1}';
          final itemUnit = item.unitController.text.trim().isNotEmpty
              ? item.unitController.text.trim()
              : unit;
          final itemPack = item.packSizeController.text.trim().isNotEmpty
              ? item.packSizeController.text.trim()
              : null;

          skus.add(
            ProductSkuItem(
              id: item.id,
              name: itemName,
              sku: item.skuController.text.trim().isNotEmpty
                  ? item.skuController.text.trim()
                  : 'SKU-${i + 1}',
              price: itemPrice,
              originalPrice: itemOriginalPrice,
              stock: itemStock,
              unit: itemUnit,
              packSize: itemPack,
              lowStockThreshold: itemLowStock,
              isDefault: item.isDefault || i == 0,
            ),
          );
        }
        price = skus.map((s) => s.price).reduce((a, b) => a < b ? a : b);
        stock = skus.fold(0, (sum, s) => sum + s.stock);
        unit = skus.first.unit;
        packSize = skus.first.packSize;
        if (sku.isEmpty) {
          sku = skus.first.sku.isNotEmpty
              ? skus.first.sku
              : 'NHAP-${DateTime.now().millisecondsSinceEpoch % 100000}';
        }
      } else {
        price = double.tryParse(_priceController.text.trim()) ?? 0;
        final originalPriceText = _originalPriceController.text.trim();
        originalPrice = originalPriceText.isNotEmpty ? double.tryParse(originalPriceText) : null;
        stock = int.tryParse(_stockController.text.trim()) ?? 0;
        if (sku.isEmpty) {
          sku = 'NHAP-${DateTime.now().millisecondsSinceEpoch % 100000}';
        }
        final lowStock = int.tryParse(_lowStockThresholdController.text.trim()) ?? 10;
        skus.add(
          ProductSkuItem(
            id: 'sku_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            sku: sku,
            price: price,
            originalPrice: originalPrice,
            stock: stock,
            unit: unit,
            packSize: packSize,
            lowStockThreshold: lowStock,
            isDefault: true,
          ),
        );
      }

      final shelfLife = int.tryParse(_shelfLifeDaysController.text.trim());

      var draftProduct = SellerProductItem(
        id: widget.initialProduct?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        sku: sku,
        price: price,
        originalPrice: originalPrice,
        stock: stock,
        unit: unit,
        packSize: packSize,
        imageUrl: _images.isNotEmpty ? _images.first : null,
        images: _images,
        categoryType: ProductCategoryType.draft,
        foodCategory: _selectedFoodCategory ?? 'Lương thực chính (Tinh bột)',
        whoCategoryCode: _selectedWhoCategoryCode ??
            ProductCategory.mapToWhoCategory(_selectedFoodCategory).code,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        origin: _originController.text.trim().isNotEmpty
            ? _originController.text.trim()
            : null,
        storageCondition: _storageConditionController.text.trim().isNotEmpty
            ? _storageConditionController.text.trim()
            : null,
        shelfLifeDays: shelfLife,
        isAvailable: false,
        status: 'DRAFT',
        moderationStatus: 'DRAFT',
        updatedAt: DateTime.now(),
        skus: skus,
      );

      AuthTokens? activeTokens = SellerAuthService.instance.tokens;
      activeTokens ??= await _tokenStorage.getTokens();
      String? token;
      if (activeTokens != null) {
        if (!activeTokens.isAccessTokenExpired()) {
          token = activeTokens.accessToken;
        } else if (activeTokens.refreshToken.isNotEmpty &&
            !activeTokens.isRefreshTokenExpired()) {
          token = await SellerAuthService.instance.refreshAccessToken();
        } else {
          token = activeTokens.accessToken;
        }
      }
      debugPrint("🔑 [SUBMIT] Token: " + (token != null ? "HAS TOKEN" : "NO TOKEN"));

      if (token != null) {
        // Upload images if any
        final uploadedImages = List<String>.from(_images);
        for (int i = 0; i < _images.length; i++) {
          final img = _images[i];
          if (!img.startsWith('http://') && !img.startsWith('https://')) {
            if (mounted) {
              setState(() {
                _submittingStatusMessage = 'Đang tải ảnh (${i + 1}/${_images.length})...';
              });
            }
            final cdn = await _productApiService.uploadMediaImage(
              token: token,
              imagePath: img,
              folder: 'cookconnect/products',
            );
            uploadedImages[i] = cdn;
          }
        }

        draftProduct = draftProduct.copyWith(
          images: uploadedImages,
          imageUrl: uploadedImages.isNotEmpty ? uploadedImages.first : null,
        );

        if (widget.initialProduct == null) {
          String supplierId = _resolveSupplierId();
          if (supplierId.isEmpty) {
            try {
              final status = await SellerAuthService.instance.checkSupplierStatus();
              supplierId = status?.supplier?.supplierId ?? '';
            } catch (e) {
              debugPrint('Could not fetch supplier profile: $e');
            }
          }

          final createDto = CreateProductDto.fromSellerProductItem(
            draftProduct,
            supplierId: supplierId,
          );
          final serverProduct = await _productApiService.createProduct(
            token: token,
            dto: createDto,
          );
          draftProduct = serverProduct.toSellerProductItem().copyWith(
            categoryType: ProductCategoryType.draft,
          );
        } else {
          final updateDto = UpdateProductDto.fromSellerProductItem(draftProduct);
          final serverProduct = await _productApiService.updateProduct(
            token: token,
            productId: widget.initialProduct!.id,
            dto: updateDto,
          );
          draftProduct = serverProduct.toSellerProductItem().copyWith(
            categoryType: ProductCategoryType.draft,
          );
        }
      }

      if (widget.onAdd != null) {
        widget.onAdd!(draftProduct);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu bản nháp "${draftProduct.name}" thành công'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(draftProduct);
      }
    } catch (e) {
      debugPrint('Save draft error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu bản nháp: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submittingStatusMessage = null;
        });
      }
    }
  }


  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
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
                  const Icon(
                    Iconsax.category_2,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chọn danh mục thực phẩm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '8 nhóm dinh dưỡng thực phẩm tiêu chuẩn WHO từ Server',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Iconsax.close_circle,
                      color: AppColors.textHint,
                      size: 20,
                    ),
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
                itemCount: _categories.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected =
                      cat.code == _selectedWhoCategoryCode ||
                      cat.name == _selectedFoodCategory;
                  return ListTile(
                    key: Key('category_item_$index'),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(cat.code),
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: cat.examples.isNotEmpty
                        ? Text(
                            cat.examples,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : (cat.description.isNotEmpty
                            ? Text(
                                cat.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textHint,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null),
                    trailing: isSelected
                        ? const Icon(
                            Iconsax.tick_circle,
                            color: AppColors.primary,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedFoodCategory = cat.name;
                        _selectedWhoCategoryCode = cat.code;
                        _categoryError = null;
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

  IconData _getCategoryIcon(String? codeOrName) {
    if (codeOrName == null) {
      return Iconsax.category_2;
    }
    final upper = codeOrName.toUpperCase();
    if (upper == 'STAPLES' ||
        upper.contains('LƯƠNG THỰC') ||
        upper.contains('TINH BỘT')) {
      return Icons.grain;
    }
    if (upper == 'LEGUMES_NUTS_SEEDS' ||
        upper.contains('ĐẬU') ||
        upper.contains('HẠT')) {
      return Iconsax.box_1;
    }
    if (upper == 'DAIRY' || upper.contains('SỮA')) {
      return Icons.local_drink_outlined;
    }
    if (upper == 'MEAT_FISH_POULTRY' ||
        upper.contains('THỊT') ||
        upper.contains('CÁ') ||
        upper.contains('GIA CẦM')) {
      return Iconsax.reserve;
    }
    if (upper == 'EGGS' || upper.contains('TRỨNG')) {
      return Icons.egg_outlined;
    }
    if (upper == 'VITAMIN_A_FRUITS_VEG' || upper.contains('VITAMIN A')) {
      return Icons.eco_outlined;
    }
    if (upper == 'OTHER_FRUITS_VEG' ||
        upper.contains('RAU CỦ') ||
        upper.contains('HOA QUẢ') ||
        upper.contains('TRÁI CÂY')) {
      return Icons.apple;
    }
    if (upper == 'FATS_OILS' ||
        upper.contains('CHẤT BÉO') ||
        upper.contains('DẦU') ||
        upper.contains('MỠ')) {
      return Iconsax.blend_2;
    }
    return _getFoodCategoryIcon(codeOrName);
  }

  IconData _getFoodCategoryIcon(String? cat) {
    if (cat == null) {
      return Iconsax.category_2;
    }
    final lower = cat.toLowerCase();
    if (lower.contains('lương thực') ||
        lower.contains('tinh bột') ||
        lower.contains('gạo')) {
      return Icons.grain;
    }
    if (lower.contains('sữa') ||
        lower.contains('bơ') ||
        lower.contains('phô mai')) {
      return Icons.local_drink_outlined;
    }
    if (lower.contains('dầu') || lower.contains('mỡ')) {
      return Iconsax.blend_2;
    }
    if (lower.contains('bò') ||
        lower.contains('heo') ||
        lower.contains('cừu') ||
        lower.contains('gia cầm') ||
        lower.contains('thịt')) {
      return Iconsax.reserve;
    }
    if (lower.contains('thủy hải sản') ||
        lower.contains('tôm') ||
        lower.contains('cá')) {
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
    return Iconsax.category;
  }

  void _addSkuItem() {
    setState(() {
      final index = _skuItems.length + 1;
      final newItem = _SkuFormData(
        id: 'sku_${DateTime.now().millisecondsSinceEpoch}_$index',
        name: '',
        sku: '',
        unit: _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : 'kg',
        packSize: '',
        price: '',
        originalPrice: '',
        stock: '10',
        lowStock: '10',
        isDefault: false,
      );
      newItem.attachListener(_onFormFieldChanged);
      _skuItems.add(newItem);
    });
  }

  void _removeSkuItem(int index) {
    if (_skuItems.length <= 1) return;
    setState(() {
      final item = _skuItems.removeAt(index);
      item.dispose();
    });
  }

  Future<String> _uploadSingleProductImage(String localPath) async {
    try {
      AuthTokens? activeTokens = SellerAuthService.instance.tokens;
      activeTokens ??= await _tokenStorage.getTokens();
      String? token;
      if (activeTokens != null) {
        if (!activeTokens.isAccessTokenExpired()) {
          token = activeTokens.accessToken;
        } else if (activeTokens.refreshToken.isNotEmpty &&
            !activeTokens.isRefreshTokenExpired()) {
          token = await SellerAuthService.instance.refreshAccessToken();
        } else {
          token = activeTokens.accessToken;
        }
      }
      if (token != null) {
        final cdnUrl = await _productApiService.uploadMediaImage(
          token: token,
          imagePath: localPath,
          folder: 'cookconnect/products',
        );
        return cdnUrl;
      }
    } catch (e) {
      rethrow;
    }
    return localPath;
  }

  Future<void> _submitForReview() async {
    // 1. Validate Category first (as expected by UX and widget tests)
    if (_selectedFoodCategory == null || _selectedFoodCategory!.trim().isEmpty) {
      setState(() {
        _categoryError = 'Vui lòng chọn danh mục thực phẩm';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn danh mục thực phẩm cho sản phẩm'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 2. Validate Form fields
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng kiểm tra lại các trường thông tin bắt buộc (*)',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 3. Image requirement (minimum 5 images)
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
    String unit = _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : 'kg';
    String? packSize = _packSizeController.text.trim().isNotEmpty ? _packSizeController.text.trim() : null;
    final List<ProductSkuItem> skus = [];

    if (_hasMultipleSkus) {
      if (_skuItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng thêm ít nhất một phân loại'),
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
        final u = form.unitController.text.trim();
        final low = int.tryParse(form.lowStockController.text.trim()) ?? 10;

        if (name.isEmpty || p == null || p <= 0 || s == null || s < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Vui lòng nhập đủ Tên, Giá bán (> 0) và Tồn kho cho Phân loại #${i + 1}',
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        final origStr = form.originalPriceController.text.trim();
        final orig = origStr.isNotEmpty ? double.tryParse(origStr) : null;
        final ps = form.packSizeController.text.trim().isNotEmpty
            ? form.packSizeController.text.trim()
            : null;

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
            unit: u.isNotEmpty ? u : unit,
            packSize: ps,
            lowStockThreshold: low,
            isDefault: form.isDefault || i == 0,
          ),
        );
      }

      price = skus.map((s) => s.price).reduce((a, b) => a < b ? a : b);
      stock = skus.fold(0, (sum, s) => sum + s.stock);
      unit = skus.first.unit;
      packSize = skus.first.packSize;
      if (sku.isEmpty) {
        sku = skus.first.sku;
      }
    } else {
      price = double.tryParse(_priceController.text.trim()) ?? 0;
      final originalPriceText = _originalPriceController.text.trim();
      originalPrice = originalPriceText.isNotEmpty ? double.tryParse(originalPriceText) : null;
      stock = int.tryParse(_stockController.text.trim()) ?? 0;
      final low = int.tryParse(_lowStockThresholdController.text.trim()) ?? 10;
      if (sku.isEmpty) {
        sku = 'TP-${DateTime.now().millisecondsSinceEpoch % 100000}';
      }

      skus.add(
        ProductSkuItem(
          id: 'sku_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          sku: sku,
          price: price,
          originalPrice: originalPrice,
          stock: stock,
          unit: unit,
          packSize: packSize,
          lowStockThreshold: low,
          isDefault: true,
        ),
      );
    }

    final shelfLife = int.tryParse(_shelfLifeDaysController.text.trim());

    final product = SellerProductItem(
      id: widget.initialProduct?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      sku: sku,
      price: price,
      originalPrice: originalPrice,
      stock: stock,
      unit: unit,
      packSize: packSize,
      imageUrl: _images.first,
      images: _images,
      categoryType: ProductCategoryType.underReview,
      foodCategory: _selectedFoodCategory!,
      whoCategoryCode: _selectedWhoCategoryCode ??
          ProductCategory.mapToWhoCategory(_selectedFoodCategory).code,
      description: _descriptionController.text.trim(),
      origin: _originController.text.trim().isNotEmpty
          ? _originController.text.trim()
          : null,
      storageCondition: _storageConditionController.text.trim().isNotEmpty
          ? _storageConditionController.text.trim()
          : null,
      shelfLifeDays: shelfLife,
      isAvailable: false,
      updatedAt: DateTime.now(),
      skus: skus,
    );

    final String supplierId = _resolveSupplierId();

    // Enqueue background upload & submission (Optimistic non-blocking flow)
    ProductBackgroundQueueService.instance.enqueue(
      product: product,
      images: _images,
      isUpdate: widget.initialProduct != null,
      supplierId: supplierId,
      apiService: _productApiService,
      tokenStorage: _tokenStorage,
      replaceTaskId: widget.failedTaskId,
    );

    if (widget.onAdd != null) {
      widget.onAdd!(product);
    }

    if (mounted) {
      // Đóng màn hình ngay lập tức để đẩy card ra ngoài danh sách,
      // im luôn vì mặc định là thành công (nếu lỗi background queue sẽ thông báo)
      Navigator.of(context).pop(product);
    }
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
    final theme = Theme.of(context);
    const subtleHintStyle = TextStyle(
      color: Color(0xFFB0B0B0),
      fontSize: 13.5,
      fontWeight: FontWeight.normal,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isSubmitting) {
          _handleBackNavigation();
        }
      },
      child: Theme(
        data: theme.copyWith(
          hintColor: const Color(0xFFB0B0B0),
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            hintStyle: subtleHintStyle,
            prefixIconColor: const Color(0xFF9E9E9E),
          ),
        ),
        child: Stack(
          children: [
            Scaffold(
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
            widget.initialProduct != null
                ? 'Chỉnh sửa thực phẩm'
                : 'Thêm sản phẩm mới',
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
                key: const Key('submit_for_review_button'),
                onPressed: (_isFormValid && !_isSubmitting) ? _submitForReview : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.border,
                  disabledForegroundColor: AppColors.textHint,
                  elevation: 0,
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Xét duyệt'),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          onChanged: _onFormFieldChanged,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              // 1. Real Images Picker Section (Tối thiểu 5 ảnh thật)
              ProductImagesUploader(
                images: _images,
                onImagesChanged: (updated) {
                  setState(() {
                    _images = updated;
                  });
                },
                minImages: 5,
                maxImages: 10,
              ),
              const SizedBox(height: 16),

              // 2. Food Basic Information Section (TextFormField #0: Tên thực phẩm)
              _buildSectionCard(
                title: 'Thông tin thực phẩm',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tên thực phẩm *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('product_name_input'),
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText:
                            'VD: Gạo ST25 Sóc Trăng Đạt Chuẩn GACP, Thịt thăn bò Úc...',
                        prefixIcon: Icon(Iconsax.tag, size: 18),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập tên thực phẩm';
                        }
                        if (val.trim().length < 2) {
                          return 'Tên thực phẩm quá ngắn';
                        }
                        if (val.trim().length > 200) {
                          return 'Tên thực phẩm không vượt quá 200 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Food category picker (opens Modal Bottom Sheet with WHO 8 Categories)
                    const Text(
                      'Danh mục thực phẩm *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      key: const Key('category_picker_field'),
                      onTap: _showCategoryBottomSheet,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _categoryError != null
                                ? AppColors.error
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(
                                _selectedWhoCategoryCode ?? _selectedFoodCategory,
                              ),
                              size: 18,
                              color: _selectedFoodCategory != null
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedFoodCategory ?? 'Chọn danh mục thực phẩm',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedFoodCategory != null
                                      ? AppColors.textPrimary
                                      : AppColors.textHint,
                                  fontWeight: _selectedFoodCategory != null
                                      ? FontWeight.w500
                                      : FontWeight.normal,
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
                    if (_categoryError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _categoryError!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),
                    // Product SKU (TextFormField #1)
                    const Text(
                      'Mã sản phẩm / SKU chính (Tùy chọn)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('product_sku_input'),
                      controller: _skuController,
                      decoration: const InputDecoration(
                        hintText: 'VD: RICE-ST25-5KG, THIT-BO-UC-01',
                        prefixIcon: Icon(Iconsax.barcode, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Price, Stock & Multiple SKUs Section (TextFormField #2: Giá bán)
              _buildSectionCard(
                title: 'Phân loại & Giá bán',
                subtitle:
                    'Chọn hình thức quy cách phù hợp cho thực phẩm của bạn',
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
                                  color: !_hasMultipleSkus
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: !_hasMultipleSkus
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
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
                                      color: !_hasMultipleSkus
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Duy nhất 1 loại',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: !_hasMultipleSkus
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: !_hasMultipleSkus
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
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
                                  color: _hasMultipleSkus
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: _hasMultipleSkus
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
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
                                      color: _hasMultipleSkus
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Nhiều phân loại',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _hasMultipleSkus
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: _hasMultipleSkus
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
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
                      Row(
                        children: [
                          // Selling price (TextFormField #2)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giá bán (VNĐ) *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  key: const Key('product_price_input'),
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
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
                          // Original price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giá gốc (Nếu có)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _originalPriceController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: 'VD: 65000',
                                    suffixText: 'đ',
                                    prefixIcon: Icon(
                                      Iconsax.ticket_discount,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Unit & Pack Size
                      Row(
                        children: [
                          // Unit (Bắt buộc theo Swagger CreateProductVariantDto)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Đơn vị tính *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  key: const Key('product_unit_input'),
                                  controller: _unitController,
                                  decoration: const InputDecoration(
                                    hintText: 'VD: kg, túi, khay',
                                    prefixIcon: Icon(Iconsax.weight, size: 18),
                                  ),
                                  validator: (val) {
                                    if (!_hasMultipleSkus) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Nhập đơn vị tính';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Pack Size (Quy cách đóng gói)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quy cách đóng gói',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  key: const Key('product_pack_size_input'),
                                  controller: _packSizeController,
                                  decoration: const InputDecoration(
                                    hintText: 'VD: 5kg, Khay 300g',
                                    prefixIcon: Icon(Iconsax.box_add, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Common Unit Chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _commonUnits.map((u) {
                          final isSelected =
                              _unitController.text.trim().toLowerCase() == u;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _unitController.text = u;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                u,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Stock & Low Stock
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Số lượng tồn kho ban đầu *',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: const InputDecoration(
                                          hintText: '10',
                                        ),
                                        validator: (val) {
                                          if (!_hasMultipleSkus) {
                                            if (val == null || val.trim().isEmpty) {
                                              return 'Nhập tồn kho';
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
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cảnh báo tồn ít',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _lowStockThresholdController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: '10',
                                    prefixIcon: Icon(Iconsax.warning_2, size: 18),
                                  ),
                                ),
                              ],
                            ),
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
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Iconsax.info_circle,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Thêm các quy cách / phân loại của thực phẩm (VD: Gói nhỏ 250g, Gói to 500g, 1kg hoặc Vị cay / Vị truyền thống...). Mỗi phân loại có SKU, Đơn vị tính và Giá riêng.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
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
                                      icon: const Icon(
                                        Iconsax.trash,
                                        size: 17,
                                        color: AppColors.error,
                                      ),
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
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: item.nameController,
                                decoration: const InputDecoration(
                                  hintText:
                                      'VD: Gói nhỏ 250g, Gói to 500g, Cắt khúc...',
                                  prefixIcon: Icon(Iconsax.tag, size: 16),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
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
                                          'Mã SKU phân loại',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        TextFormField(
                                          controller: item.skuController,
                                          decoration: const InputDecoration(
                                            hintText: 'VD: XX-250G',
                                            prefixIcon: Icon(Iconsax.barcode, size: 16),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
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
                                          'Đơn vị tính *',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        TextFormField(
                                          controller: item.unitController,
                                          decoration: const InputDecoration(
                                            hintText: 'VD: túi, hộp, kg',
                                            prefixIcon: Icon(Iconsax.weight, size: 16),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        TextFormField(
                                          controller: item.priceController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          decoration: const InputDecoration(
                                            hintText: 'VD: 45000',
                                            suffixText: 'đ',
                                            prefixIcon: Icon(
                                              Iconsax.money,
                                              size: 16,
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
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
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        TextFormField(
                                          controller: item.originalPriceController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          decoration: const InputDecoration(
                                            hintText: 'VD: 55000',
                                            suffixText: 'đ',
                                            prefixIcon: Icon(
                                              Iconsax.ticket_discount,
                                              size: 16,
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Số lượng tồn kho *',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly,
                                                ],
                                                decoration: const InputDecoration(
                                                  hintText: '10',
                                                  contentPadding: EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
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
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Quy cách gói',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        TextFormField(
                                          controller: item.packSizeController,
                                          decoration: const InputDecoration(
                                            hintText: 'VD: 250g',
                                            prefixIcon: Icon(Iconsax.box_add, size: 16),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
                        label: const Text('+ Thêm phân loại mới'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // SKU Summary Box
                      Builder(
                        builder: (context) {
                          final totalStock = _skuItems.fold<int>(
                            0,
                            (sum, item) =>
                                sum +
                                (int.tryParse(item.stockController.text.trim()) ?? 0),
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
                                    const Text(
                                      'Số phân loại',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_skuItems.length} loại',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 24,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      'Tổng kho',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$totalStock',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 24,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      'Khoảng giá',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      priceRangeText,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Detailed Description, Origin, Storage & Shelf Life (Theo chuẩn Swagger CreateProductDto)
              _buildSectionCard(
                title: 'Mô tả & Thuộc tính thực phẩm',
                subtitle: 'Các thông tin bắt buộc & bổ trợ kiểm duyệt an toàn thực phẩm',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mô tả chi tiết thực phẩm (Required in Swagger)
                    const Text(
                      'Mô tả chi tiết thực phẩm *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('product_description_input'),
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText:
                            'Giới thiệu nguồn gốc, chất lượng, cách sơ chế và hướng dẫn sử dụng món ăn...',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Iconsax.document_text, size: 18),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập mô tả chi tiết cho thực phẩm';
                        }
                        if (val.trim().length < 10) {
                          return 'Mô tả nên có ít nhất 10 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Xuất xứ / Nguồn gốc sản xuất (Swagger: origin, maxLength 100)
                    const Text(
                      'Nguồn gốc / Xuất xứ (Tùy chọn)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('product_origin_input'),
                      controller: _originController,
                      decoration: const InputDecoration(
                        hintText: 'VD: Sóc Trăng, Việt Nam; Đà Lạt, Lâm Đồng...',
                        prefixIcon: Icon(Iconsax.location, size: 18),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Điều kiện bảo quản (Swagger: storageCondition, maxLength 200)
                    const Text(
                      'Điều kiện bảo quản (Tùy chọn)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('product_storage_input'),
                      controller: _storageConditionController,
                      decoration: const InputDecoration(
                        hintText: 'VD: Bảo quản nơi khô ráo thoáng mát, tránh ánh nắng trực tiếp...',
                        prefixIcon: Icon(Iconsax.shield_tick, size: 18),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _storageSuggestions.map((s) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _storageConditionController.text = s;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Hạn sử dụng theo ngày (Swagger: shelfLifeDays, number)
                    const Text(
                      'Hạn sử dụng theo ngày (Tùy chọn)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const Key('product_shelflife_input'),
                            controller: _shelfLifeDaysController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              hintText: 'VD: 30, 90, 180...',
                              suffixText: 'ngày',
                              prefixIcon: Icon(Iconsax.calendar_tick, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _shelfLifeSuggestions.map((d) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _shelfLifeDaysController.text = d;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              '$d ngày',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. Policy info note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Iconsax.info_circle, color: AppColors.info, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Thực phẩm sau khi bấm "Xét duyệt" sẽ được chuyển đến trạng thái Đang xét duyệt để đội ngũ kiểm duyệt nội dung an toàn thực phẩm, nguồn gốc và chất lượng theo 8 nhóm dinh dưỡng WHO chuẩn server trước khi chính thức mở bán.',
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
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            MediaQuery.of(context).padding.bottom + 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Save Draft Button
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  key: const Key('save_draft_button'),
                  onPressed: !_isSubmitting ? _saveDraftAndExit : null,
                  icon: const Icon(Iconsax.document_download, size: 16),
                  label: const Text('Lưu nháp'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Submit for Review Button
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  key: const Key('bottom_submit_for_review_button'),
                  onPressed: (_isFormValid && !_isSubmitting) ? _submitForReview : null,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Iconsax.send_2, size: 16),
                  label: Text(_isSubmitting ? 'Đang gửi...' : 'Gửi xét duyệt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.border,
                    disabledForegroundColor: AppColors.textHint,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (_isSubmitting)
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.35),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _submittingStatusMessage ?? 'Đang xử lý...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
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
