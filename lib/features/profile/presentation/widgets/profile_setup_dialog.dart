import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';

class ProfileSetupDialog extends StatefulWidget {
  final bool isFirstTime;
  final VoidCallback? onComplete;

  const ProfileSetupDialog({
    super.key,
    this.isFirstTime = false,
    this.onComplete,
  });

  static Future<void> show(
    BuildContext context, {
    bool isFirstTime = false,
    VoidCallback? onComplete,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          ProfileSetupDialog(isFirstTime: isFirstTime, onComplete: onComplete),
    );
  }

  @override
  State<ProfileSetupDialog> createState() => _ProfileSetupDialogState();
}

class _ProfileSetupDialogState extends State<ProfileSetupDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  String _selectedGender = 'MALE';
  DateTime? _selectedDateOfBirth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;

    _nameController = TextEditingController(text: user?.fullName ?? '');

    String initialUsername = user?.username ?? '';
    if (initialUsername.isEmpty && user != null && user.email.isNotEmpty) {
      initialUsername = user.email
          .split('@')
          .first
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')
          .toLowerCase();
    }
    _usernameController = TextEditingController(text: initialUsername);

    _bioController = TextEditingController(text: user?.bio ?? '');

    if (user?.gender != null && user!.gender!.isNotEmpty) {
      _selectedGender = user.gender!;
    }

    if (user?.dateOfBirth != null && user!.dateOfBirth!.isNotEmpty) {
      try {
        _selectedDateOfBirth = DateTime.parse(user.dateOfBirth!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _selectedDateOfBirth ?? DateTime(2000, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1930),
      lastDate: now,
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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatIsoDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final fullName = _nameController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();
    final bio = _bioController.text.trim();
    final dobIso = _selectedDateOfBirth != null
        ? _formatIsoDate(_selectedDateOfBirth!)
        : null;

    final token = AuthService.instance.tokens?.accessToken;
    final userId = AuthService.instance.currentUser?.id;

    if (token != null && token.isNotEmpty) {
      final apiService = ApiService();
      await apiService.updateUserProfile(
        accessToken: token,
        userId: userId,
        displayName: fullName,
        username: username,
        gender: _selectedGender,
        dateOfBirth: dobIso,
        bio: bio,
      );
    }

    // Always update local session so UI updates instantly
    AuthService.instance.updateUser(
      fullName: fullName,
      username: username,
      gender: _selectedGender,
      dateOfBirth: dobIso,
      bio: bio,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pop(context);
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isFirstTime
                              ? 'Hoàn tất hồ sơ Chef'
                              : 'Chỉnh sửa thông tin hồ sơ',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Thông tin giúp bạn kết nối với cộng đồng yêu bếp',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isFirstTime)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Để sau',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Full Name Field
              _buildFieldLabel('Họ và tên / Tên hiển thị'),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  hint: 'Ví dụ: Lê Bảo Linh',
                  prefixIcon: Iconsax.user,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Username Field
              _buildFieldLabel('Tên người dùng'),
              TextFormField(
                controller: _usernameController,
                decoration: _buildInputDecoration(
                  hint: 'lebaolinh_chef',
                  prefixIcon: Iconsax.hashtag,
                  prefixText: '@',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập username';
                  }
                  if (val.trim().length < 3) {
                    return 'Username tối thiểu 3 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Gender Selector
              _buildFieldLabel('Giới tính'),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderOption(
                      label: 'Nam',
                      value: 'MALE',
                      icon: Iconsax.man,
                      primaryColor: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildGenderOption(
                      label: 'Nữ',
                      value: 'FEMALE',
                      icon: Iconsax.woman,
                      primaryColor: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildGenderOption(
                      label: 'Khác',
                      value: 'OTHER',
                      icon: Iconsax.people,
                      primaryColor: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Date of Birth Field
              _buildFieldLabel('Ngày sinh'),
              InkWell(
                onTap: _pickDateOfBirth,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.calendar_1,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDateOfBirth != null
                              ? _formatDate(_selectedDateOfBirth!)
                              : 'Chọn ngày sinh của bạn...',
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedDateOfBirth != null
                                ? Colors.black87
                                : Colors.grey[400],
                            fontWeight: _selectedDateOfBirth != null
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Icon(
                        Iconsax.arrow_down_1,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Bio Field
              _buildFieldLabel('Tiểu sử giới thiệu (Bio)'),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  hint: 'Chia sẻ đam mê nấu ăn, phong cách ẩm thực của bạn...',
                  prefixIcon: Iconsax.note_text,
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
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
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.isFirstTime
                              ? 'Hoàn tất & Bắt đầu'
                              : 'Lưu thay đổi',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
    String? prefixText,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey[400]),
      prefixIcon: Icon(prefixIcon, size: 20, color: Colors.grey[600]),
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildGenderOption({
    required String label,
    required String value,
    required IconData icon,
    required Color primaryColor,
  }) {
    final isSelected = _selectedGender == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? primaryColor : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryColor : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
