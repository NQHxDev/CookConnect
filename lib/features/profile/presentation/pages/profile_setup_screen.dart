import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/main/presentation/pages/main_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isFirstTime;
  final VoidCallback? onComplete;
  final ApiService? apiService;

  const ProfileSetupScreen({
    super.key,
    this.isFirstTime = true,
    this.onComplete,
    this.apiService,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  String _selectedGender = 'MALE';
  DateTime? _selectedDateOfBirth;
  String? _dobError;
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
        _dobError = null;
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
    final formValid = _formKey.currentState!.validate();

    if (_selectedDateOfBirth == null) {
      setState(() {
        _dobError = 'Vui lòng chọn ngày sinh của bạn';
      });
    } else {
      if (_dobError != null) {
        setState(() {
          _dobError = null;
        });
      }
    }

    if (!formValid || _selectedDateOfBirth == null) {
      return;
    }

    setState(() => _isLoading = true);

    final fullName = _nameController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();
    final bio = _bioController.text.trim();
    final dobIso = _formatIsoDate(_selectedDateOfBirth!);

    final token = AuthService.instance.tokens?.accessToken;
    final userId = AuthService.instance.currentUser?.id;

    try {
      if (token != null && token.isNotEmpty) {
        final apiService = widget.apiService ?? ApiService();
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
    } catch (_) {
      // Continue even if remote network fails, to keep session active
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

    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng hoàn tất thông tin hồ sơ để tiếp tục.'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            widget.isFirstTime ? 'Hoàn tất hồ sơ Chef' : 'Chỉnh sửa thông tin hồ sơ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome hero banner
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Iconsax.profile_circle5,
                            size: 46,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Thiết lập hồ sơ người dùng',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Thông tin giúp bạn kết nối với cộng đồng yêu bếp và bảo mật tài khoản',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Full Name Field
                  _buildFieldLabel('Họ và tên / Tên hiển thị', isRequired: true),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: _buildInputDecoration(
                      hint: 'Ví dụ: Lê Bảo Linh',
                      prefixIcon: Iconsax.user,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      if (val.trim().length < 2) {
                        return 'Họ và tên phải có ít nhất 2 ký tự';
                      }
                      if (val.trim().length > 50) {
                        return 'Họ và tên tối đa 50 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Username Field
                  _buildFieldLabel('Tên người dùng', isRequired: true),
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: _buildInputDecoration(
                      hint: 'lebaolinh_chef',
                      prefixIcon: Iconsax.hashtag,
                      prefixText: '@',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập username';
                      }
                      final trimmed = val.trim();
                      if (trimmed.length < 3) {
                        return 'Username tối thiểu 3 ký tự';
                      }
                      if (trimmed.length > 30) {
                        return 'Username tối đa 30 ký tự';
                      }
                      final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
                      if (!usernameRegex.hasMatch(trimmed)) {
                        return 'Username chỉ được chứa chữ cái, chữ số và dấu gạch dưới (_)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 16),

                  // Date of Birth Field (Required)
                  _buildFieldLabel('Ngày sinh', isRequired: true),
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
                        border: Border.all(
                          color: _dobError != null
                              ? Colors.red.shade400
                              : Colors.grey.shade300,
                          width: _dobError != null ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.calendar_1,
                            size: 20,
                            color: _dobError != null
                                ? Colors.red.shade400
                                : Colors.grey[600],
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
                  if (_dobError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 6),
                      child: Text(
                        _dobError!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Bio Field (Optional)
                  _buildFieldLabel('Tiểu sử giới thiệu (Bio)'),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    maxLength: 150,
                    decoration: _buildInputDecoration(
                      hint: 'Chia sẻ đam mê nấu ăn, phong cách ẩm thực của bạn...',
                      prefixIcon: Iconsax.note_text,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button (Required to continue)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
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
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Hoàn tất & Bắt đầu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Iconsax.arrow_right_3, size: 18),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
        ],
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
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
