import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/main.dart';

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

  String _selectedCity = _cities.first;
  String _selectedCategory = _supplierCategories.first;
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
      text: (userEmail != null && userEmail.contains('@')) ? userEmail : (widget.contact ?? ''),
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

    if (currentUser?.category != null && _supplierCategories.contains(currentUser!.category)) {
      _selectedCategory = currentUser.category!;
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeCodeController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveStore() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Iconsax.tick_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chào mừng bạn đến với CookConnect Supplier! Gian hàng "${profile.supplierName}" đã được kích hoạt thành công.',
                  style: const TextStyle(fontSize: 13.5),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
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

  Future<void> _confirmSignOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất tài khoản?'),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất? Bạn có thể đăng nhập lại bất kỳ lúc nào để tiếp tục thiết lập gian hàng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await SellerAuthService.instance.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Iconsax.info_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vui lòng hoàn tất thông tin gian hàng trước khi bắt đầu bán hàng.',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.grey[900],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Thông tin gian hàng',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Iconsax.logout, color: AppColors.textSecondary),
              tooltip: 'Đăng xuất',
              onPressed: _confirmSignOut,
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

                        // Contact Email (Required)
                        _buildFieldLabel('Email liên hệ chính thức *'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            hint: 'Ví dụ: contact@nhacungcap.vn',
                            icon: Iconsax.sms,
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

                        // City Dropdown
                        _buildFieldLabel('Tỉnh / Thành phố hoạt động *'),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedCity,
                              icon: const Icon(Iconsax.arrow_down_1, size: 18),
                              items: _cities.map((city) {
                                return DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(
                                    city,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCity = val);
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Category Dropdown
                        _buildFieldLabel('Lĩnh vực cung cấp chính *'),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedCategory,
                              icon: const Icon(Iconsax.arrow_down_1, size: 18),
                              items: _supplierCategories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCategory = val);
                                }
                              },
                            ),
                          ),
                        ),

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

                        // Submit Button
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSaveStore,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Hoàn tất & Kích hoạt gian hàng',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
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
