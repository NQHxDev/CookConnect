import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  State<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  late String _fullName;
  late String _phoneNumber;
  late String _email;
  late String _storeName;
  late String _accountId;
  late String _role;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
        _loadUserData();
      });
    }
  }

  void _loadUserData() {
    final user = SellerAuthService.instance.currentUser;
    final supplier = SellerAuthService.instance.supplierProfile;

    _fullName = user?.fullName ?? 'Nguyễn Quang Hải';
    final rawPhone = user?.phone ?? supplier?.contactPhone ?? '0987654321';
    _phoneNumber = _maskPhone(rawPhone);

    final rawEmail = (user?.email != null && user!.email.isNotEmpty)
        ? user.email
        : (supplier?.contactEmail ?? 'supplier.cookconnect@gmail.com');
    _email = _maskEmail(rawEmail);

    _storeName = user?.storeName ?? supplier?.supplierName ?? 'Gian hàng CookConnect';
    _accountId = supplier?.supplierCode ?? user?.storeId ?? user?.id ?? 'SUPP-88992';
    _role = user?.role ?? 'SUPPLIER_ADMIN';
  }

  /// Formats date as 'Ngày x, thg y, yyyy'

  /// Masks email so only the first and last character before '@' are shown,
  /// with the rest replaced by '*'.
  String _maskEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex <= 1) return email;

    final username = email.substring(0, atIndex);
    final domain = email.substring(atIndex);

    if (username.length <= 2) {
      return '$username$domain';
    }

    final first = username[0];
    final last = username[username.length - 1];
    final stars = '*' * (username.length - 2);

    return '$first$stars$last$domain';
  }

  /// Masks phone number so center digits are hidden
  String _maskPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < 6) return phone;
    final prefix = cleaned.substring(0, 3);
    final suffix = cleaned.substring(cleaned.length - 3);
    final stars = '*' * (cleaned.length - prefix.length - suffix.length);
    return '$prefix $stars $suffix';
  }

  void _editFullName() {
    final textController = TextEditingController(text: _fullName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Đổi tên chủ tài khoản',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nhập họ và tên...',
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
              final newName = textController.text.trim();
              if (newName.isNotEmpty) {
                setState(() => _fullName = newName);
                SellerAuthService.instance.updateStoreProfile(
                  storeName: _storeName,
                  fullName: newName,
                );
                Navigator.pop(ctx);
                _showSuccessSnackBar('Đã cập nhật họ và tên');
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _copyAccountId() {
    Clipboard.setData(ClipboardData(text: _accountId));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Đã sao chép mã tài khoản: $_accountId'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _showComingSoonSnackBar(String field) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Tính năng cập nhật $field đang phát triển!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final roleDisplay = _role == 'SUPPLIER_ADMIN'
        ? 'Quản trị viên gian hàng'
        : _role;

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
          'Thông tin tài khoản',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            // Section 1: Thông tin tài khoản
            _buildSectionHeader('Thông tin tài khoản', isFirst: true),
            _buildSectionContainer(
              children: [
                _buildAccountInfoItem(
                  title: 'Họ và tên',
                  value: _fullName,
                  onTap: _editFullName,
                ),
                _buildAccountInfoItem(
                  title: 'Số điện thoại',
                  value: _phoneNumber,
                  onTap: () => _showComingSoonSnackBar('số điện thoại'),
                ),
                _buildAccountInfoItem(
                  title: 'Email',
                  value: _email,
                  onTap: () => _showComingSoonSnackBar('email'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 2: Định danh & Quyền hạn
            _buildSectionHeader('Định danh & Quyền hạn'),
            _buildSectionContainer(
              children: [
                _buildAccountInfoItem(
                  title: 'Mã tài khoản',
                  value: _accountId,
                  trailingIcon: Iconsax.copy,
                  onTap: _copyAccountId,
                ),
                _buildAccountInfoItem(
                  title: 'Gian hàng liên kết',
                  value: _storeName,
                  showArrow: false,
                ),
                _buildAccountInfoItem(
                  title: 'Vai trò tài khoản',
                  value: roleDisplay,
                  showArrow: false,
                ),
                _buildAccountInfoItem(
                  title: 'Trạng thái tài khoản',
                  customValue: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Đang hoạt động',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
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

  Widget _buildAccountInfoItem({
    required String title,
    String? value,
    Widget? customValue,
    IconData? trailingIcon,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
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
}
