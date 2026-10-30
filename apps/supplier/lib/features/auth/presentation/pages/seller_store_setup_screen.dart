import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/auth_gate.dart';

class SellerStoreSetupScreen extends StatefulWidget {
  final String? contact;
  final bool isPhone;
  final VoidCallback? onLoginSuccess;

  const SellerStoreSetupScreen({
    super.key,
    this.contact,
    this.isPhone = false,
    this.onLoginSuccess,
  });

  @override
  State<SellerStoreSetupScreen> createState() => _SellerStoreSetupScreenState();
}

class _SellerStoreSetupScreenState extends State<SellerStoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _storeNameController;
  late final TextEditingController _storeCodeController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;

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

  String? _selectedCity;
  String? _selectedCategory;
  String? _cityError;
  String? _categoryError;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final currentUser = SellerAuthService.instance.currentUser;

    _storeNameController = TextEditingController(
      text: currentUser?.storeName?.contains('@') == false ? (currentUser?.storeName ?? '') : '',
    );
    _storeCodeController = TextEditingController();
    _ownerNameController = TextEditingController(
      text: currentUser?.fullName ?? '',
    );
    final userEmail = currentUser?.email;
    _emailController = TextEditingController(
      text: (userEmail != null && userEmail.contains('@'))
          ? userEmail
          : (widget.contact != null && widget.contact!.contains('@') ? widget.contact! : ''),
    );
    _phoneController = TextEditingController(
      text: currentUser?.phone ?? (widget.isPhone && widget.contact != null ? widget.contact! : ''),
    );
    _addressController = TextEditingController(
      text: currentUser?.address ?? '',
    );
    _descriptionController = TextEditingController(
      text: currentUser?.description ?? '',
    );

    _storeNameController.addListener(_onFormFieldChanged);
    _ownerNameController.addListener(_onFormFieldChanged);
    _emailController.addListener(_onFormFieldChanged);
    _phoneController.addListener(_onFormFieldChanged);
    _addressController.addListener(_onFormFieldChanged);

    // Both City and Category start unselected (no default selection) so user chooses explicitly
    _selectedCity = null;
    _selectedCategory = null;
  }

  void _onFormFieldChanged() {
    setState(() {});
  }

  bool get _isFormValid {
    final storeName = _storeNameController.text.trim();
    final ownerName = _ownerNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    final isStoreNameValid = storeName.length >= 3;
    final isOwnerNameValid = ownerName.isNotEmpty;
    final isEmailValid = email.isNotEmpty && email.contains('@');
    final isPhoneValid = phone.length >= 9;
    final isCityValid = _selectedCity != null && _selectedCity!.isNotEmpty;
    final isCategoryValid = _selectedCategory != null && _selectedCategory!.isNotEmpty;
    final isAddressValid = address.isNotEmpty;

    return isStoreNameValid &&
        isOwnerNameValid &&
        isEmailValid &&
        isPhoneValid &&
        isCityValid &&
        isCategoryValid &&
        isAddressValid;
  }

  Future<void> _handleBackToWelcome() async {
    FocusScope.of(context).unfocus();
    await SellerAuthService.instance.logout(callServer: false);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AuthGate(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _storeNameController.removeListener(_onFormFieldChanged);
    _ownerNameController.removeListener(_onFormFieldChanged);
    _emailController.removeListener(_onFormFieldChanged);
    _phoneController.removeListener(_onFormFieldChanged);
    _addressController.removeListener(_onFormFieldChanged);
    _storeNameController.dispose();
    _storeCodeController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showCityBottomSheet() {
    FocusScope.of(context).unfocus();
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
              // Drag handle
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

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.location,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tỉnh / Thành phố hoạt động',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Chọn khu vực gian hàng cung ứng chính',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, color: AppColors.textHint, size: 22),
                    onPressed: () => Navigator.of(ctx).pop(),
                    tooltip: 'Đóng',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Cities List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _cities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final isSelected = city == _selectedCity;

                    return InkWell(
                      key: Key('city_item_$index'),
                      onTap: () {
                        setState(() {
                          _selectedCity = city;
                          _cityError = null;
                        });
                        Navigator.of(ctx).pop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Iconsax.buildings,
                                size: 18,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                city,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Iconsax.tick_circle,
                                color: AppColors.primary,
                                size: 20,
                              )
                            else
                              const Icon(
                                Iconsax.arrow_right_3,
                                color: AppColors.textHint,
                                size: 16,
                              ),
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

  void _showCategoryBottomSheet() {
    FocusScope.of(context).unfocus();
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
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
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

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.category,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chọn lĩnh vực cung cấp chính',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Chọn ngành hàng thực phẩm / nguyên liệu chủ lực',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, color: AppColors.textHint, size: 22),
                    onPressed: () => Navigator.of(ctx).pop(),
                    tooltip: 'Đóng',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Categories List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _supplierCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final category = _supplierCategories[index];
                    final isSelected = category == _selectedCategory;

                    return InkWell(
                      key: Key('category_item_$index'),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                          _categoryError = null;
                        });
                        Navigator.of(ctx).pop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getCategoryIcon(category),
                                size: 18,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Iconsax.tick_circle,
                                color: AppColors.primary,
                                size: 20,
                              )
                            else
                              const Icon(
                                Iconsax.arrow_right_3,
                                color: AppColors.textHint,
                                size: 16,
                              ),
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

  Future<void> _handleSaveStore() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
      _cityError = null;
      _categoryError = null;
    });

    bool hasError = false;
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      _cityError = 'Vui lòng chọn Tỉnh / Thành phố hoạt động';
      hasError = true;
    }
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      _categoryError = 'Vui lòng chọn lĩnh vực cung cấp chính';
      hasError = true;
    }

    if (!_formKey.currentState!.validate() || hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    final storeName = _storeNameController.text.trim();
    final storeCode = _storeCodeController.text.trim();
    final ownerName = _ownerNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final description = _descriptionController.text.trim();

    try {
      // 1. Call Backend API POST /api/v1/suppliers
      final profile = await SellerAuthService.instance.createSupplierStore(
        supplierName: storeName,
        supplierCode: storeCode.isNotEmpty ? storeCode : null,
        contactEmail: email.isNotEmpty ? email : null,
        contactPhone: phone.isNotEmpty ? phone : null,
        address: address.isNotEmpty ? address : null,
        city: _selectedCity,
      );

      // 2. Persist local store profile details
      await SellerAuthService.instance.updateStoreProfile(
        storeName: profile.supplierName,
        fullName: ownerName.isNotEmpty ? ownerName : profile.supplierName,
        phone: phone.isNotEmpty ? phone : null,
        category: _selectedCategory,
        address: address.isNotEmpty ? address : null,
        description: description.isNotEmpty ? description : null,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('ApiException: ', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Iconsax.warning_2, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_errorMessage ?? 'Lưu thông tin thất bại. Vui lòng thử lại.'),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackToWelcome();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            key: const Key('store_setup_back_button'),
            icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
            tooltip: 'Quay lại',
            onPressed: _isLoading ? null : _handleBackToWelcome,
          ),
          title: const Text(
            'Thông tin gian hàng',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                key: const Key('store_setup_confirm_button'),
                onPressed: (_isFormValid && !_isLoading) ? _handleSaveStore : null,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: AppColors.textHint.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: (_isFormValid && !_isLoading)
                              ? AppColors.primary
                              : AppColors.textHint.withValues(alpha: 0.5),
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Store Avatar Header
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Iconsax.shop,
                                    size: 44,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Iconsax.camera,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),
                        const Center(
                          child: Text(
                            'Thiết lập gian hàng nhà cung cấp',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Center(
                          child: Text(
                            'Đăng ký thông tin nhà cung cấp / đối tác cung ứng nguyên liệu CookConnect',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.info_circle, size: 18, color: Colors.red[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Store Name (Required)
                        _buildFieldLabel('Tên gian hàng / Nhà cung cấp *'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _storeNameController,
                          decoration: _inputDecoration(
                            hint: 'Ví dụ: Nông Trại Xanh An Phú / Mega Market',
                            icon: Iconsax.shop,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên gian hàng';
                            }
                            if (value.trim().length < 3) {
                              return 'Tên gian hàng tối thiểu 3 ký tự';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Store Code (Optional)
                        _buildFieldLabel('Mã ký hiệu nhà cung cấp (Tùy chọn)'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _storeCodeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: _inputDecoration(
                            hint: 'Ví dụ: SUPP-AP-01 (tự sinh nếu để trống)',
                            icon: Iconsax.barcode,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Owner Name (Required)
                        _buildFieldLabel('Họ và tên người đại diện *'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _ownerNameController,
                          decoration: _inputDecoration(
                            hint: 'Ví dụ: Nguyễn Văn A',
                            icon: Iconsax.user,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập họ và tên người đại diện';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Contact Email (Read-only / Not changeable at this step)
                        _buildFieldLabel('Email liên hệ chính thức *'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          canRequestFocus: false,
                          enableInteractiveSelection: false,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _inputDecoration(
                            hint: 'Ví dụ: contact@nhacungcap.vn',
                            icon: Iconsax.sms,
                          ).copyWith(
                            fillColor: Colors.grey.shade100,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập email liên hệ';
                            }
                            if (!value.contains('@')) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'Email đăng ký tài khoản được dùng cố định làm email liên hệ chính thức.',
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Phone Number (Required)
                        _buildFieldLabel('Số điện thoại liên hệ / Hotline *'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(
                            hint: 'Ví dụ: 0987654321',
                            icon: Iconsax.call,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập số điện thoại liên hệ';
                            }
                            if (value.trim().length < 9) {
                              return 'Số điện thoại không hợp lệ';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // City Picker (Bottom Sheet Modal)
                        _buildFieldLabel('Tỉnh / Thành phố hoạt động *'),
                        const SizedBox(height: 6),
                        InkWell(
                          key: const Key('city_picker_field'),
                          onTap: _showCityBottomSheet,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _cityError != null ? Colors.red.shade400 : Colors.grey.shade300,
                                width: _cityError != null ? 1.2 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.location,
                                  color: _selectedCity != null ? AppColors.primary : AppColors.textHint,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedCity ?? 'Chọn Tỉnh / Thành phố hoạt động',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _selectedCity != null
                                          ? AppColors.textPrimary
                                          : Colors.grey.shade400,
                                      fontWeight: _selectedCity != null ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Iconsax.arrow_down_1,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_cityError != null) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              _cityError!,
                              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Category Picker (Bottom Sheet Modal - No Default Selection)
                        _buildFieldLabel('Lĩnh vực cung cấp chính *'),
                        const SizedBox(height: 6),
                        InkWell(
                          key: const Key('category_picker_field'),
                          onTap: _showCategoryBottomSheet,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _categoryError != null ? Colors.red.shade400 : Colors.grey.shade300,
                                width: _categoryError != null ? 1.2 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.category,
                                  color: _selectedCategory != null ? AppColors.primary : AppColors.textHint,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedCategory ?? 'Chọn lĩnh vực cung cấp chính',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _selectedCategory != null
                                          ? AppColors.textPrimary
                                          : Colors.grey.shade400,
                                      fontWeight: _selectedCategory != null ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Iconsax.arrow_down_1,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_categoryError != null) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              _categoryError!,
                              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Address (Required)
                        _buildFieldLabel('Địa chỉ kho hàng / Trụ sở *'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: _inputDecoration(
                            hint: 'Số nhà, tên đường, phường/xã, quận/huyện',
                            icon: Iconsax.location,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập địa chỉ';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Description / Bio (Optional)
                        _buildFieldLabel('Mô tả nhà cung cấp (Tùy chọn)'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            hint: 'Năng lực cung ứng, danh mục sản phẩm chủ lực...',
                            icon: Iconsax.note_text,
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
