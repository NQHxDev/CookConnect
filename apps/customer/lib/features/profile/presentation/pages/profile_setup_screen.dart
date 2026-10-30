import 'package:flutter/cupertino.dart'
    show
        CupertinoDatePicker,
        CupertinoDatePickerMode,
        DatePickerDateOrder,
        CupertinoTheme,
        CupertinoThemeData,
        CupertinoTextThemeData;
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
  late TextEditingController _addressController;
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

    _addressController = TextEditingController(text: user?.address ?? '');

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
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _formatDisplayDate(DateTime dt) {
    return 'Ngày ${dt.day.toString().padLeft(2, '0')} tháng ${dt.month.toString().padLeft(2, '0')}, ${dt.year}';
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final maxDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final minDate = DateTime(1930, 1, 1);

    DateTime tempDate = _selectedDateOfBirth ?? DateTime(2000, 1, 1);
    if (tempDate.isAfter(maxDate)) {
      tempDate = DateTime(now.year, now.month, now.day);
    }
    if (tempDate.isBefore(minDate)) {
      tempDate = minDate;
    }

    final primaryColor = Theme.of(context).colorScheme.primary;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final age = _calculateAge(tempDate);

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 42,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Iconsax.calendar_1,
                                  size: 18,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Chọn ngày sinh',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => Navigator.of(bottomSheetContext).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Live selected date card preview
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Iconsax.cake,
                                color: primaryColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDisplayDate(tempDate),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    age >= 0 ? '$age tuổi' : 'Chưa hợp lệ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Cupertino wheel date picker
                      SizedBox(
                        height: 210,
                        child: CupertinoTheme(
                          data: const CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                fontFamily: 'TikTokSans',
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            dateOrder: DatePickerDateOrder.dmy,
                            initialDateTime: tempDate,
                            minimumDate: minDate,
                            maximumDate: maxDate,
                            onDateTimeChanged: (DateTime newDate) {
                              setModalState(() {
                                tempDate = newDate;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Confirm button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedDateOfBirth = tempDate;
                              _dobError = null;
                            });
                            Navigator.of(bottomSheetContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.tick_circle, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Xác nhận',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
    final address = _addressController.text.trim();
    final bio = _bioController.text.trim();
    final dobIso = _formatIsoDate(_selectedDateOfBirth!);

    final token = AuthService.instance.tokens?.accessToken;

    try {
      if (token != null && token.isNotEmpty) {
        final apiService = widget.apiService ?? ApiService();
        final createResult = await apiService.createUserProfile(
          accessToken: token,
          displayName: fullName,
          username: username.isNotEmpty ? username : null,
          gender: _selectedGender,
          dateOfBirth: dobIso,
          bio: bio.isNotEmpty ? bio : null,
          address: address,
        );
        if (!createResult.isSuccess) {
          await apiService.updateUserProfile(
            accessToken: token,
            displayName: fullName,
            username: username.isNotEmpty ? username : null,
            gender: _selectedGender,
            dateOfBirth: dobIso,
            bio: bio.isNotEmpty ? bio : null,
            address: address,
          );
        }
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
      address: address,
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedDateOfBirth != null
                            ? primaryColor.withValues(alpha: 0.04)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _dobError != null
                              ? Colors.red.shade400
                              : _selectedDateOfBirth != null
                                  ? primaryColor.withValues(alpha: 0.5)
                                  : Colors.grey.shade300,
                          width: _dobError != null || _selectedDateOfBirth != null ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _selectedDateOfBirth != null
                                  ? primaryColor.withValues(alpha: 0.12)
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _selectedDateOfBirth != null
                                  ? Iconsax.calendar_tick
                                  : Iconsax.calendar_1,
                              size: 19,
                              color: _dobError != null
                                  ? Colors.red.shade400
                                  : _selectedDateOfBirth != null
                                      ? primaryColor
                                      : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _selectedDateOfBirth != null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatDate(_selectedDateOfBirth!),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatDisplayDate(_selectedDateOfBirth!),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Chọn ngày sinh của bạn...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          ),
                          if (_selectedDateOfBirth != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.cake,
                                    size: 13,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_calculateAge(_selectedDateOfBirth!)} tuổi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Iconsax.edit_2,
                              size: 16,
                              color: primaryColor,
                            ),
                          ] else
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

                  // Address Field (Required)
                  _buildFieldLabel('Địa chỉ', isRequired: true),
                  TextFormField(
                    controller: _addressController,
                    textInputAction: TextInputAction.next,
                    decoration: _buildInputDecoration(
                      hint: 'Ví dụ: 123 Nguyễn Trãi, Thanh Xuân, Hà Nội',
                      prefixIcon: Iconsax.location,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập địa chỉ';
                      }
                      final trimmed = val.trim();
                      if (trimmed.length < 3) {
                        return 'Địa chỉ phải có ít nhất 3 ký tự';
                      }
                      if (trimmed.length > 255) {
                        return 'Địa chỉ tối đa 255 ký tự';
                      }
                      return null;
                    },
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
