import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/settings/presentation/pages/holiday/holiday_mode_screen.dart';

/// Màn hình quản lý và hiển thị thông tin gian hàng / nhà cung cấp
class StoreInformationScreen extends StatefulWidget {
  const StoreInformationScreen({super.key});

  @override
  State<StoreInformationScreen> createState() => _StoreInformationScreenState();
}

class _StoreInformationScreenState extends State<StoreInformationScreen> {
  // Store profile fields
  late String _storeName;
  late String _storeCode;
  late String _storeSlug;
  late String _category;
  late String _description;
  late String _phone;
  late String _email;
  late String _city;
  late String _address;
  late String _ownerName;
  String? _logoUrl;
  File? _localLogoFile;

  // Operating status
  late bool _isOpen;
  late String _openTime;
  late String _closeTime;
  late double _rating;
  late bool _isVerified;
  bool _isLoading = false;

  static const List<String> _cities = [
    'Hồ Chí Minh',
    'Hà Nội',
    'Đà Nẵng',
    'Cần Thơ',
    'Hải Phòng',
    'Bình Dương',
    'Đồng Nai',
    'Khác',
  ];

  static const List<String> _supplierCategories = [
    'Nguyên liệu tươi sống & Nông sản',
    'Thịt, Gia cầm & Thủy hải sản',
    'Rau, Củ & Trái cây sạch',
    'Gia vị, Nước xốt & Phụ liệu nấu nướng',
    'Thực phẩm đông lạnh & Đóng hộp',
    'Cơm văn phòng & Món gia đình',
    'Trà sữa, Cà phê & Đồ uống',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _loadStoreData();
    SellerAuthService.instance.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    SellerAuthService.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {
        _loadStoreData();
      });
    }
  }

  void _loadStoreData() {
    final user = SellerAuthService.instance.currentUser;
    final supplier = SellerAuthService.instance.supplierProfile;

    _storeName = supplier?.supplierName ??
        user?.storeName ??
        'Đại Siêu Thị Nguyên Liệu Tươi CookConnect';

    _storeCode = supplier?.supplierCode ??
        user?.storeId ??
        'SUPP-COOK-01';

    _storeSlug = supplier?.supplierSlug ??
        _storeName
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'^-+|-+$'), '');
    if (_storeSlug.isEmpty) _storeSlug = 'gian-hang-cookconnect';

    _category = user?.category ?? 'Nguyên liệu tươi sống & Nông sản';
    _description = user?.description ??
        'Chuyên cung ứng nguồn thực phẩm, nông sản hữu cơ và nguyên liệu tươi sống sạch đạt chuẩn VietGAP cho các nhà hàng & hộ gia đình.';

    _phone = supplier?.contactPhone ?? user?.phone ?? '0987654321';
    _email = supplier?.contactEmail ??
        ((user?.email != null && user!.email.contains('@'))
            ? user.email
            : 'supplier.cookconnect@gmail.com');

    _city = supplier?.city ?? 'Hồ Chí Minh';
    _address = supplier?.address ??
        user?.address ??
        '123 Đường Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh';

    _ownerName = user?.fullName ?? 'Nguyễn Quang Hải';
    _logoUrl = supplier?.supplierLogoUrl;

    _rating = supplier?.rating ?? 4.9;
    _isVerified = supplier?.isVerified ?? true;
    _isOpen = (supplier?.supplierStatus ?? 'ACTIVE') == 'ACTIVE';

    _openTime = '07:30';
    _closeTime = '21:30';
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await SellerAuthService.instance.checkSupplierStatus();
    if (mounted) {
      setState(() {
        _loadStoreData();
        _isLoading = false;
      });
      _showSuccessSnackBar('Đã làm mới thông tin cửa hàng');
    }
  }

  Future<void> _saveChanges({
    String? storeName,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? category,
    String? description,
    String? logoUrl,
    String? ownerName,
    bool? isOpen,
  }) async {
    setState(() => _isLoading = true);

    final statusString = (isOpen ?? _isOpen) ? 'ACTIVE' : 'SUSPENDED';

    final success = await SellerAuthService.instance.updateSupplierStoreDetails(
      storeName: storeName ?? _storeName,
      contactPhone: phone ?? _phone,
      contactEmail: email ?? _email,
      address: address ?? _address,
      city: city ?? _city,
      category: category ?? _category,
      description: description ?? _description,
      logoUrl: logoUrl ?? _logoUrl,
      supplierStatus: statusString,
      ownerName: ownerName ?? _ownerName,
    );

    if (mounted) {
      setState(() {
        if (storeName != null) _storeName = storeName;
        if (phone != null) _phone = phone;
        if (email != null) _email = email;
        if (address != null) _address = address;
        if (city != null) _city = city;
        if (category != null) _category = category;
        if (description != null) _description = description;
        if (logoUrl != null) _logoUrl = logoUrl;
        if (ownerName != null) _ownerName = ownerName;
        if (isOpen != null) _isOpen = isOpen;
        _isLoading = false;
      });

      if (success) {
        _showSuccessSnackBar('Đã cập nhật thông tin cửa hàng thành công');
      } else {
        _showErrorSnackBar('Cập nhật lên máy chủ thất bại, đã lưu trên thiết bị');
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showSuccessSnackBar('Đã sao chép $label: $text');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Iconsax.info_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _localLogoFile = File(picked.path);
        });
        _saveChanges(logoUrl: picked.path);
        _showSuccessSnackBar('Đã cập nhật ảnh đại diện cửa hàng');
      }
    } catch (e) {
      _showErrorSnackBar('Không thể chọn ảnh: $e');
    }
  }

  void _showAvatarOptionsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Ảnh đại diện gian hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.gallery, color: AppColors.primary),
                ),
                title: const Text('Chọn ảnh từ thư viện'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.camera, color: AppColors.primary),
                ),
                title: const Text('Chụp ảnh mới'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.link, color: Colors.blue),
                ),
                title: const Text('Nhập liên kết ảnh (URL)'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  _showImageUrlDialog();
                },
              ),
              if (_logoUrl != null || _localLogoFile != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.trash, color: Colors.red),
                  ),
                  title: const Text(
                    'Gỡ ảnh đại diện',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _localLogoFile = null;
                      _logoUrl = null;
                    });
                    _saveChanges(logoUrl: '');
                    _showSuccessSnackBar('Đã gỡ ảnh đại diện');
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

  void _showImageUrlDialog() {
    final controller = TextEditingController(text: _logoUrl ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Liên kết ảnh đại diện',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'https://example.com/logo.png',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                setState(() {
                  _logoUrl = newUrl;
                  _localLogoFile = null;
                });
                _saveChanges(logoUrl: newUrl);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showEditTextDialog({
    required String title,
    required String label,
    required String initialValue,
    required void Function(String) onSave,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hintText,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hintText ?? 'Nhập $label...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                onSave(text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showCityBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.location, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chọn Tỉnh / Thành phố',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, color: AppColors.textHint, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _cities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final isSelected = city == _city;
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _saveChanges(city: city);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.buildings,
                              size: 18,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                city,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Iconsax.tick_circle, color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.category, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Lĩnh vực cung cấp chính',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, color: AppColors.textHint, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _supplierCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final category = _supplierCategories[index];
                    final isSelected = category == _category;
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _saveChanges(category: category);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 18,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Iconsax.tick_circle, color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('tươi sống') || category.contains('Nông sản')) {
      return Icons.eco_outlined;
    }
    if (category.contains('Thịt') || category.contains('thủy hải sản')) {
      return Iconsax.reserve;
    }
    if (category.contains('Rau') || category.contains('Trái cây')) {
      return Icons.apple;
    }
    if (category.contains('Gia vị') || category.contains('xốt')) {
      return Iconsax.magic_star;
    }
    if (category.contains('đông lạnh') || category.contains('hộp')) {
      return Icons.ac_unit;
    }
    if (category.contains('Cơm') || category.contains('gia đình')) {
      return Iconsax.shop;
    }
    if (category.contains('Trà sữa') || category.contains('Cà phê')) {
      return Icons.coffee;
    }
    return Iconsax.box_1;
  }

  Future<void> _pickOperatingHours() async {
    final openTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 30),
      helpText: 'Chọn giờ mở cửa hàng ngày',
    );
    if (openTime == null || !mounted) return;

    final closeTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 21, minute: 30),
      helpText: 'Chọn giờ đóng cửa hàng ngày',
    );
    if (closeTime == null || !mounted) return;

    final openStr =
        '${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')}';
    final closeStr =
        '${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}';

    setState(() {
      _openTime = openStr;
      _closeTime = closeStr;
    });

    _showSuccessSnackBar('Đã cập nhật giờ mở cửa: $openStr - $closeStr');
  }

  void _showStorePreviewSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header Preview Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.eye, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Xem trước giao diện khách hàng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, color: AppColors.textHint, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Preview content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Banner & Logo Preview Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.primary.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildStoreAvatar(size: 72),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                _storeName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (_isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: Colors.blue, size: 18),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$_rating',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '•  $_category',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isOpen ? AppColors.success : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isOpen
                                  ? 'Đang mở cửa • $_openTime - $_closeTime'
                                  : 'Tạm đóng cửa',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _isOpen ? AppColors.success : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Store Bio
                  if (_description.isNotEmpty) ...[
                    const Text(
                      'Giới thiệu gian hàng',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _description,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Address & Hotline preview
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Iconsax.location, size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _address,
                                style: const TextStyle(fontSize: 13, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Iconsax.call, size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              _phone,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            const Icon(Iconsax.sms, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _email,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Iconsax.copy, size: 18),
                      label: const Text(
                        'Sao chép liên kết gian hàng',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _copyToClipboard('https://cookconnect.vn/store/$_storeSlug', 'Link gian hàng');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreAvatar({double size = 84}) {
    ImageProvider? imageProvider;
    if (_localLogoFile != null) {
      imageProvider = FileImage(_localLogoFile!);
    } else if (_logoUrl != null &&
        _logoUrl!.isNotEmpty &&
        (_logoUrl!.startsWith('http://') || _logoUrl!.startsWith('https://'))) {
      imageProvider = NetworkImage(_logoUrl!);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 2.5,
        ),
        image: imageProvider != null
            ? DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageProvider == null
          ? Center(
              child: Icon(
                Iconsax.shop,
                size: size * 0.45,
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông tin cửa hàng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Xem trước gian hàng',
            icon: const Icon(
              Iconsax.eye,
              color: AppColors.primary,
              size: 22,
            ),
            onPressed: _showStorePreviewSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refreshData,
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // HERO STORE PROFILE CARD
              _buildStoreHeroCard(),

              const SizedBox(height: 12),

              // SHORTCUTS / ACTION BAR
              _buildActionBar(),

              const SizedBox(height: 16),

              // SECTION 1: THÔNG TIN THƯƠNG HIỆU & ĐỊNH DANH
              _buildSectionHeader('Thông tin thương hiệu & Định danh', isFirst: true),
              _buildSectionContainer(
                children: [
                  _buildStoreInfoItem(
                    title: 'Tên gian hàng',
                    value: _storeName,
                    onTap: () => _showEditTextDialog(
                      title: 'Đổi tên gian hàng',
                      label: 'Tên gian hàng / Nhà cung cấp',
                      initialValue: _storeName,
                      onSave: (val) => _saveChanges(storeName: val),
                    ),
                  ),
                  _buildStoreInfoItem(
                    title: 'Mã nhà cung cấp',
                    value: _storeCode,
                    trailingIcon: Iconsax.copy,
                    onTap: () => _copyToClipboard(_storeCode, 'Mã nhà cung cấp'),
                  ),
                  _buildStoreInfoItem(
                    title: 'Đường dẫn gian hàng',
                    value: 'cookconnect.vn/store/$_storeSlug',
                    trailingIcon: Iconsax.link_21,
                    onTap: () => _copyToClipboard(
                      'https://cookconnect.vn/store/$_storeSlug',
                      'Liên kết gian hàng',
                    ),
                  ),
                  _buildStoreInfoItem(
                    title: 'Lĩnh vực cung cấp',
                    value: _category,
                    onTap: _showCategoryBottomSheet,
                  ),
                  _buildStoreInfoItem(
                    title: 'Giới thiệu gian hàng',
                    value: _description.isEmpty ? 'Chưa có mô tả' : _description,
                    maxLines: 2,
                    onTap: () => _showEditTextDialog(
                      title: 'Mô tả gian hàng',
                      label: 'Giới thiệu năng lực cung ứng',
                      initialValue: _description,
                      maxLines: 4,
                      onSave: (val) => _saveChanges(description: val),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SECTION 2: LIÊN HỆ & ĐỊA CHỈ KHO
              _buildSectionHeader('Liên hệ & Địa chỉ kinh doanh'),
              _buildSectionContainer(
                children: [
                  _buildStoreInfoItem(
                    title: 'Hotline / Số điện thoại',
                    value: _phone,
                    onTap: () => _showEditTextDialog(
                      title: 'Đổi số điện thoại',
                      label: 'Hotline liên hệ',
                      initialValue: _phone,
                      keyboardType: TextInputType.phone,
                      onSave: (val) => _saveChanges(phone: val),
                    ),
                  ),
                  _buildStoreInfoItem(
                    title: 'Email đối tác',
                    value: _email,
                    onTap: () => _showEditTextDialog(
                      title: 'Đổi email liên hệ',
                      label: 'Email hỗ trợ',
                      initialValue: _email,
                      keyboardType: TextInputType.emailAddress,
                      onSave: (val) => _saveChanges(email: val),
                    ),
                  ),
                  _buildStoreInfoItem(
                    title: 'Tỉnh / Thành phố',
                    value: _city,
                    onTap: _showCityBottomSheet,
                  ),
                  _buildStoreInfoItem(
                    title: 'Địa chỉ kho / Trụ sở',
                    value: _address,
                    maxLines: 2,
                    onTap: () => _showEditTextDialog(
                      title: 'Đổi địa chỉ kho hàng',
                      label: 'Địa chỉ chi tiết',
                      initialValue: _address,
                      maxLines: 2,
                      onSave: (val) => _saveChanges(address: val),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SECTION 3: VẬN HÀNH & GIỜ NHẬN ĐƠN
              _buildSectionHeader('Vận hành & Giờ hoạt động'),
              _buildSectionContainer(
                children: [
                  _buildSwitchItem(
                    title: 'Trạng thái nhận đơn hàng',
                    subtitle: _isOpen
                        ? 'Đang mở cửa • Nhận đơn từ khách hàng'
                        : 'Tạm đóng cửa • Không tiếp nhận đơn mới',
                    value: _isOpen,
                    onChanged: (val) {
                      _saveChanges(isOpen: val);
                    },
                  ),
                  _buildStoreInfoItem(
                    title: 'Giờ mở cửa hàng ngày',
                    value: '$_openTime - $_closeTime',
                    trailingIcon: Iconsax.clock,
                    onTap: _pickOperatingHours,
                  ),
                  _buildStoreInfoItem(
                    title: 'Chế độ nghỉ lễ',
                    value: 'Thiết lập ngày nghỉ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HolidayModeScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SECTION 4: ĐẠI DIỆN & PHÁP LÝ
              _buildSectionHeader('Đại diện & Pháp lý gian hàng'),
              _buildSectionContainer(
                children: [
                  _buildStoreInfoItem(
                    title: 'Người đại diện pháp lý',
                    value: _ownerName,
                    onTap: () => _showEditTextDialog(
                      title: 'Đổi người đại diện',
                      label: 'Họ và tên người đại diện',
                      initialValue: _ownerName,
                      onSave: (val) => _saveChanges(ownerName: val),
                    ),
                  ),
                  _buildStoreInfoItem(
                    title: 'Xác thực nhà cung cấp',
                    customValue: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          _isVerified ? Icons.verified : Iconsax.info_circle,
                          size: 16,
                          color: _isVerified ? Colors.blue : Colors.amber[800],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isVerified ? 'Đã xác thực đối tác' : 'Chờ kiểm duyệt',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _isVerified ? Colors.blue[700] : Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                    showArrow: false,
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Store Hero Header Card with Avatar & Status
  Widget _buildStoreHeroCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with camera icon
              Stack(
                children: [
                  _buildStoreAvatar(size: 70),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _showAvatarOptionsSheet,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Iconsax.camera,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              // Store name, rating, status badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _storeName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (_isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.blue, size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                              const SizedBox(width: 3),
                              Text(
                                '$_rating',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: _isOpen
                                ? AppColors.success.withValues(alpha: 0.12)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _isOpen ? AppColors.success : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _isOpen ? 'Đang mở cửa' : 'Tạm đóng cửa',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: _isOpen ? AppColors.success : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Action Bar with Quick Utilities
  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionTile(
              icon: Iconsax.eye,
              label: 'Xem trước',
              onTap: _showStorePreviewSheet,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionTile(
              icon: Iconsax.copy,
              label: 'Sao chép link',
              onTap: () => _copyToClipboard(
                'https://cookconnect.vn/store/$_storeSlug',
                'Liên kết gian hàng',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionTile(
              icon: Iconsax.refresh,
              label: 'Làm mới',
              isLoading: _isLoading,
              onTap: _refreshData,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: const Color(0xFFF5F6F8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                )
              else
                Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isFirst = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, isFirst ? 4 : 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildStoreInfoItem({
    required String title,
    String? value,
    Widget? customValue,
    IconData? trailingIcon,
    VoidCallback? onTap,
    bool showArrow = true,
    int maxLines = 1,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: customValue ??
                    Text(
                      value ?? '',
                      textAlign: TextAlign.right,
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[600],
                      ),
                    ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  trailingIcon,
                  size: 15,
                  color: AppColors.primary,
                ),
              ] else if (showArrow) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Colors.grey[400],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
