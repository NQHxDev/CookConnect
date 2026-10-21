import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  State<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  late String _phoneNumber;
  late String _email;
  late DateTime _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _phoneNumber = '+84 9******89';

    final rawEmail = (user?.email != null && user!.email.isNotEmpty)
        ? user.email
        : 'cookconnect@gmail.com';
    _email = _maskEmail(rawEmail);

    DateTime initialDate = DateTime(1998, 8, 15);
    if (user?.dateOfBirth != null && user!.dateOfBirth!.isNotEmpty) {
      try {
        initialDate = DateTime.parse(user.dateOfBirth!);
      } catch (_) {}
    }
    _selectedDateOfBirth = initialDate;
  }

  /// Formats date as 'Ngày x, thg y, yyyy'
  String _formatDate(DateTime dt) {
    return 'Ngày ${dt.day}, thg ${dt.month}, ${dt.year}';
  }

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

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth,
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      helpText: 'Chọn ngày sinh của bạn',
      cancelText: 'Huỷ',
      confirmText: 'Xác nhận',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
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
          icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
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
            // Category header (dòng chữ nhỏ màu xám đánh dấu danh mục)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Thông tin tài khoản',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            // Information box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildAccountInfoItem(
                    title: 'Số điện thoại',
                    value: _phoneNumber,
                    onTap: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tính năng cập nhật số điện thoại đang phát triển!',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    },
                  ),
                  _buildAccountInfoItem(
                    title: 'Email',
                    value: _email,
                    onTap: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tính năng cập nhật email đang phát triển!',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    },
                  ),
                  _buildAccountInfoItem(
                    title: 'Ngày sinh',
                    value: _formatDate(_selectedDateOfBirth),
                    onTap: _selectDateOfBirth,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoItem({
    required String title,
    required String value,
    VoidCallback? onTap,
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
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
