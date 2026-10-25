import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/core/utils/validators.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_store_setup_screen.dart';

class SellerRegisterPasswordScreen extends StatefulWidget {
  final String contact;
  final bool isPhone;
  final String? verificationToken;
  final VoidCallback? onLoginSuccess;

  const SellerRegisterPasswordScreen({
    super.key,
    required this.contact,
    this.isPhone = false,
    this.verificationToken,
    this.onLoginSuccess,
  });

  @override
  State<SellerRegisterPasswordScreen> createState() => _SellerRegisterPasswordScreenState();
}

class _SellerRegisterPasswordScreenState extends State<SellerRegisterPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _hasMinLength => _passwordController.text.length >= 6;
  bool get _hasLettersAndNumbers =>
      RegExp(r'[a-zA-Z]').hasMatch(_passwordController.text) &&
      RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasSpecialChar =>
      RegExp(r'[^a-zA-Z0-9]').hasMatch(_passwordController.text);

  bool get _isPasswordValid => _hasMinLength && _hasLettersAndNumbers;
  bool get _isConfirmValid =>
      _confirmPasswordController.text.isNotEmpty &&
      _confirmPasswordController.text == _passwordController.text;

  bool get _isFormValid => _isPasswordValid && _isConfirmValid;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onTextChanged);
    _confirmPasswordController.addListener(_onTextChanged);
    if (!Validators.isValidVerificationToken(widget.verificationToken)) {
      _errorMessage = 'Mã xác thực không hợp lệ (yêu cầu định dạng vtok_...). Vui lòng quay lại bước xác thực OTP.';
    }
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
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate() || !_isFormValid) {
      return;
    }

    if (!Validators.isValidVerificationToken(widget.verificationToken)) {
      setState(() {
        _errorMessage = 'Mã xác thực không hợp lệ (yêu cầu định dạng vtok_...). Vui lòng xác thực lại OTP.';
      });
      return;
    }

    setState(() => _isLoading = true);

    final email = widget.isPhone
        ? '${widget.contact}@seller.cookconnect.app'
        : widget.contact;
    final phone = widget.isPhone ? widget.contact : null;

    try {
      final result = await SellerAuthService.instance.register(
        email: email,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        phone: phone,
        verificationToken: widget.verificationToken,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        // Mandatory Next Step: Store setup screen (cannot bypass)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => SellerStoreSetupScreen(
              contact: widget.contact,
              isPhone: widget.isPhone,
              onLoginSuccess: widget.onLoginSuccess,
            ),
          ),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = result.message.isNotEmpty
              ? result.message
              : 'Đăng ký tài khoản thất bại. Vui lòng thử lại.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';
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
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tạo mật khẩu',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Thiết lập mật khẩu đăng nhập',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Mật khẩu sẽ dùng để bảo vệ tài khoản người bán và truy cập trang quản lý đơn hàng của bạn.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Password Field
                      const Text(
                        'Mật khẩu mới',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Nhập mật khẩu (tối thiểu 6 ký tự)',
                          prefixIcon: const Icon(Iconsax.lock, color: AppColors.primary, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password Field
                      const Text(
                        'Xác nhận mật khẩu',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Nhập lại mật khẩu vừa tạo',
                          prefixIcon: const Icon(Iconsax.shield_tick, color: AppColors.primary, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng xác nhận mật khẩu';
                          }
                          if (value != _passwordController.text) {
                            return 'Mật khẩu xác nhận không khớp';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password checklist indicators
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quy chuẩn mật khẩu:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRuleRow(label: 'Tối thiểu 6 ký tự', satisfied: _hasMinLength),
                            const SizedBox(height: 6),
                            _buildRuleRow(
                              label: 'Bao gồm cả chữ cái và chữ số',
                              satisfied: _hasLettersAndNumbers,
                            ),
                            const SizedBox(height: 6),
                            _buildRuleRow(
                              label: 'Ký tự đặc biệt (!@#\$%...) (khuyên dùng)',
                              satisfied: _hasSpecialChar,
                              isOptional: true,
                            ),
                            if (_confirmPasswordController.text.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _buildRuleRow(
                                label: 'Mật khẩu xác nhận trùng khớp',
                                satisfied: _isConfirmValid,
                              ),
                            ],
                          ],
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

                      const SizedBox(height: 28),

                      // Submit Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (_isLoading || !_isFormValid || !Validators.isValidVerificationToken(widget.verificationToken)) ? null : _submitRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
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
                                  'Tạo tài khoản & Thiết lập gian hàng',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRuleRow({
    required String label,
    required bool satisfied,
    bool isOptional = false,
  }) {
    return Row(
      children: [
        Icon(
          satisfied ? Iconsax.tick_circle : (isOptional ? Iconsax.info_circle : Iconsax.close_circle),
          size: 16,
          color: satisfied
              ? Colors.green[600]
              : (isOptional ? Colors.grey[500] : Colors.grey[400]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: satisfied
                  ? Colors.green[800]
                  : (isOptional ? Colors.grey[600] : Colors.grey[600]),
              fontWeight: satisfied ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
