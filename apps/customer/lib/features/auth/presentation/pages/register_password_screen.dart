import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/profile/presentation/pages/profile_setup_screen.dart';

class RegisterPasswordScreen extends StatefulWidget {
  final String email;
  final String? verificationToken;
  final ApiService? apiService;
  final Function(String name, String contactInfo)? onLoginSuccess;

  const RegisterPasswordScreen({
    super.key,
    required this.email,
    this.verificationToken,
    this.apiService,
    this.onLoginSuccess,
  });

  @override
  State<RegisterPasswordScreen> createState() => _RegisterPasswordScreenState();
}

class _RegisterPasswordScreenState extends State<RegisterPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late final ApiService _apiService;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _hasMinLength => _passwordController.text.length >= 6;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasDigit => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasLettersAndNumbers => _hasUppercase && _hasLowercase && _hasDigit;
  bool get _hasSpecialChar => _passwordController.text.contains(RegExp(r'[^a-zA-Z0-9]'));
  bool get _isPasswordValid =>
      _hasMinLength &&
      _hasLettersAndNumbers &&
      _hasSpecialChar;

  bool get _isConfirmValid =>
      _confirmPasswordController.text.isNotEmpty &&
      _confirmPasswordController.text == _passwordController.text;

  bool get _isFormValid => _isPasswordValid && _isConfirmValid;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _passwordController.addListener(_onTextChanged);
    _confirmPasswordController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onTextChanged);
    _confirmPasswordController.removeListener(_onTextChanged);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _unfocusAll() {
    _passwordFocusNode.unfocus();
    _confirmPasswordFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future<void> _submitRegister() async {
    _unfocusAll();
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.register(
        email: widget.email,
        password: password,
        confirmPassword: confirmPassword,
        verificationToken: widget.verificationToken,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (result.isSuccess) {
        final defaultName = widget.email.contains('@')
            ? widget.email.split('@').first
            : widget.email;

        final authenticatedUser =
            result.user ??
            AuthUser(
              id: 'user-${DateTime.now().millisecondsSinceEpoch}',
              email: widget.email,
              fullName: defaultName,
              username: defaultName,
            );

        final tokens =
            result.tokens ??
            AuthTokens(
              accessToken: 'access-token-${DateTime.now().millisecondsSinceEpoch}',
              refreshToken: 'refresh-token-${DateTime.now().millisecondsSinceEpoch}',
            );

        // Update active session
        AuthService.instance.setSession(
          user: authenticatedUser,
          tokens: tokens,
        );

        final displayName = authenticatedUser.fullName.isNotEmpty
            ? authenticatedUser.fullName
            : defaultName;

        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!(displayName, widget.email);
        }

        // Navigate to mandatory full-screen profile setup
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ProfileSetupScreen(),
          ),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Đăng ký tài khoản thất bại. Vui lòng thử lại.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.warning_2, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi kết nối: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: _unfocusAll,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Tạo mật khẩu',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  // Header title
                  const Text(
                    'Thiết lập mật khẩu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tạo mật khẩu an toàn để đăng nhập vào tài khoản ${widget.email}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Password Field
                  Text(
                    'Mật khẩu',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (val.length < 6) {
                        return 'Mật khẩu phải từ 6 ký tự trở lên';
                      }
                      if (val.length > 100) {
                        return 'Mật khẩu tối đa 100 ký tự';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Tối thiểu 6 ký tự...',
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      prefixIcon: const Icon(Iconsax.lock, size: 20, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Password policy checklist
                  _buildPasswordRequirementsCard(),

                  const SizedBox(height: 18),

                  // Confirm Password Field
                  Text(
                    'Xác nhận mật khẩu',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) => _submitRegister(),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Vui lòng nhập lại mật khẩu';
                      }
                      if (val != _passwordController.text) {
                        return 'Mật khẩu xác nhận không trùng khớp';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Nhập lại mật khẩu trên...',
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      prefixIcon: const Icon(Iconsax.lock_1, size: 20, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword,
                        ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
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

                  const SizedBox(height: 32),

                  // Submit Button: Hoàn tất đăng ký
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_isLoading || !_isFormValid) ? null : _submitRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: primaryColor.withValues(alpha: 0.45),
                        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
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
                                  'Hoàn tất đăng ký',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Iconsax.tick_circle, size: 18),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildPasswordRequirementsCard() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _passwordController,
      builder: (context, _, child) {
        return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yêu cầu mật khẩu:',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('Tối thiểu 6 ký tự', _hasMinLength),
          const SizedBox(height: 6),
          _buildRequirementItem(
            'Có chữ hoa, chữ thường và chữ số',
            _hasLettersAndNumbers,
          ),
          const SizedBox(height: 6),
          _buildRequirementItem(
            'Có ký tự đặc biệt (!@#\$%^&*...)',
            _hasSpecialChar,
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildRequirementItem(String label, bool isMet) {
    return Row(
      children: [
        Icon(
          Icons.check,
          size: 16,
          color: isMet ? const Color(0xFF10B981) : Colors.grey[400],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: isMet ? const Color(0xFF1F2937) : Colors.grey[500],
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

}
