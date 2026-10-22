import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/core/utils/validators.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_register_contact_screen.dart';

class EmailPhoneAuthScreen extends StatefulWidget {
  final bool initialRegisterMode;
  final VoidCallback? onLoginSuccess;
  final int initialTabIndex;

  const EmailPhoneAuthScreen({
    super.key,
    this.initialRegisterMode = false,
    this.onLoginSuccess,
    this.initialTabIndex = 0,
  });

  @override
  State<EmailPhoneAuthScreen> createState() => _EmailPhoneAuthScreenState();
}

class _EmailPhoneAuthScreenState extends State<EmailPhoneAuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Error messages per tab
  String? _emailErrorMessage;
  String? _phoneErrorMessage;

  // Password visibility
  bool _obscureEmailPassword = true;
  bool _obscurePhonePassword = true;

  // Phone OTP login state
  bool _phoneLoginWithOtp = false;
  bool _otpSent = false;
  int _otpCountdown = 60;
  Timer? _countdownTimer;

  // Email form
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _emailPasswordFocusNode = FocusNode();

  // Phone form
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phonePasswordController = TextEditingController();
  final _phoneOtpController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _phonePasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _unfocus();
      if (mounted) {
        setState(() {
          _emailErrorMessage = null;
          _phoneErrorMessage = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _countdownTimer?.cancel();
    _emailController.dispose();
    _emailPasswordController.dispose();
    _phoneController.dispose();
    _phonePasswordController.dispose();
    _phoneOtpController.dispose();
    _emailFocusNode.dispose();
    _emailPasswordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _phonePasswordFocusNode.dispose();
    super.dispose();
  }

  void _unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _onTabTapped(int index) {
    _unfocus();
    setState(() {
      _emailErrorMessage = null;
      _phoneErrorMessage = null;
    });
  }

  void _startOtpTimer() {
    setState(() => _otpCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpCountdown > 1) {
        setState(() => _otpCountdown--);
      } else {
        timer.cancel();
        setState(() => _otpCountdown = 0);
      }
    });
  }

  Future<void> _handleSendPhoneOtp() async {
    _unfocus();
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      setState(() => _phoneErrorMessage = 'Vui lòng nhập số điện thoại hợp lệ');
      return;
    }

    setState(() {
      _isLoading = true;
      _phoneErrorMessage = null;
    });

    try {
      final result = await SellerAuthService.instance.sendOtp(contact: phone);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
      _startOtpTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Đã gửi mã OTP đến $phone'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _phoneErrorMessage = 'Không thể gửi mã OTP. Vui lòng thử lại.';
      });
    }
  }

  Future<void> _handleEmailLogin() async {
    _unfocus();
    setState(() => _emailErrorMessage = null);

    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _emailPasswordController.text;

    try {
      final result = await SellerAuthService.instance.loginWithEmail(
        email: email,
        password: password,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        widget.onLoginSuccess?.call();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        setState(() {
          _emailErrorMessage = result.message.isNotEmpty
              ? result.message
              : 'Đăng nhập thất bại. Vui lòng kiểm tra lại email và mật khẩu.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailErrorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';
      });
    }
  }

  Future<void> _handlePhoneLogin() async {
    _unfocus();
    setState(() => _phoneErrorMessage = null);

    if (!_phoneFormKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    setState(() => _isLoading = true);

    try {
      if (_phoneLoginWithOtp) {
        final otp = _phoneOtpController.text.trim();
        final verifyResult = await SellerAuthService.instance.verifyOtp(
          contact: phone,
          otp: otp,
        );

        if (!mounted) return;

        if (verifyResult.isSuccess) {
          final loginResult = await SellerAuthService.instance.loginWithPhone(
            phone: phone,
            password: '',
          );
          if (!mounted) return;
          setState(() => _isLoading = false);

          if (loginResult.success) {
            widget.onLoginSuccess?.call();
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            setState(() => _phoneErrorMessage = loginResult.message);
          }
        } else {
          setState(() {
            _isLoading = false;
            _phoneErrorMessage = verifyResult.error ?? 'Mã xác thực OTP không chính xác';
          });
        }
      } else {
        final password = _phonePasswordController.text;
        final result = await SellerAuthService.instance.loginWithPhone(
          phone: phone,
          password: password,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (result.success) {
          widget.onLoginSuccess?.call();
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          setState(() {
            _phoneErrorMessage = result.message.isNotEmpty
                ? result.message
                : 'Đăng nhập thất bại. Vui lòng kiểm tra lại số điện thoại và mật khẩu.';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _phoneErrorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';
      });
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SellerRegisterContactScreen(
          onLoginSuccess: widget.onLoginSuccess,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialRegisterMode) {
      return SellerRegisterContactScreen(onLoginSuccess: widget.onLoginSuccess);
    }

    const primaryColor = AppColors.primary;

    return GestureDetector(
      onTap: _unfocus,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Đăng nhập tài khoản',
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Clean welcoming title
                const Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Đăng nhập bằng Email hoặc Số điện thoại để quản lý gian hàng CookConnect.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 22),

                // Sleek Segmented Switcher (iOS / Pill style)
                _buildSegmentedTabBar(primaryColor),

                const SizedBox(height: 24),

                // Smooth view transition between Email and Phone
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(_tabController.index),
                        child: _tabController.index == 0
                            ? _buildEmailLoginForm(primaryColor)
                            : _buildPhoneLoginForm(primaryColor),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Register Link Footer
                _buildRegisterFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTabBar(Color primaryColor) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: TabBar(
          controller: _tabController,
          onTap: _onTabTapped,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          enableFeedback: false,
          dividerColor: Colors.transparent,
          dividerHeight: 0,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.sms, size: 18),
                  SizedBox(width: 8),
                  Text('Email'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_android_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Số điện thoại'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailLoginForm(Color primaryColor) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Địa chỉ Email',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailPasswordFocusNode.requestFocus(),
            autofillHints: const [AutofillHints.email],
            decoration: _inputDecoration(
              hint: 'vidu@quanbanhang.vn',
              icon: Iconsax.sms,
              controller: _emailController,
            ),
            validator: Validators.email,
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mật khẩu',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: _showForgotPasswordDialog,
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailPasswordController,
            focusNode: _emailPasswordFocusNode,
            obscureText: _obscureEmailPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleEmailLogin(),
            decoration: _inputDecoration(
              hint: 'Nhập mật khẩu',
              icon: Iconsax.lock,
              controller: _emailPasswordController,
              suffixWidget: IconButton(
                icon: Icon(
                  _obscureEmailPassword ? Iconsax.eye_slash : Iconsax.eye,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() => _obscureEmailPassword = !_obscureEmailPassword);
                },
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu';
              return null;
            },
          ),

          if (_emailErrorMessage != null) ...[
            const SizedBox(height: 14),
            _buildErrorBox(_emailErrorMessage!),
          ],

          const SizedBox(height: 26),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleEmailLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
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
                      'Đăng nhập với Email',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLoginForm(Color primaryColor) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Số điện thoại',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
              LengthLimitingTextInputFormatter(12),
            ],
            decoration: _inputDecoration(
              hint: '0987 654 321',
              icon: Icons.phone_android_rounded,
              controller: _phoneController,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
              if (val.trim().length < 9) return 'Số điện thoại không hợp lệ';
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Toggle Password / OTP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _phoneLoginWithOtp ? 'Xác thực OTP' : 'Mật khẩu',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _phoneLoginWithOtp = !_phoneLoginWithOtp;
                    _phoneErrorMessage = null;
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _phoneLoginWithOtp ? 'Đăng nhập với Mật khẩu' : 'Đăng nhập nhanh bằng OTP',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_phoneLoginWithOtp) ...[
            TextFormField(
              controller: _phoneOtpController,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                hintText: 'Nhập mã 6 chữ số',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                prefixIcon: Icon(Iconsax.security, color: Colors.grey.shade600, size: 20),
                suffixIcon: TextButton(
                  onPressed: (_otpCountdown > 0 || _isLoading) ? null : _handleSendPhoneOtp,
                  child: Text(
                    _otpSent
                        ? (_otpCountdown > 0 ? '${_otpCountdown}s' : 'Gửi lại')
                        : 'Lấy mã',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: (_otpCountdown > 0 && _otpSent)
                          ? Colors.grey
                          : primaryColor,
                    ),
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().length != 6) {
                  return 'Vui lòng nhập đủ 6 chữ số OTP';
                }
                return null;
              },
            ),
          ] else ...[
            TextFormField(
              controller: _phonePasswordController,
              focusNode: _phonePasswordFocusNode,
              obscureText: _obscurePhonePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handlePhoneLogin(),
              decoration: _inputDecoration(
                hint: 'Nhập mật khẩu',
                icon: Iconsax.lock,
                controller: _phonePasswordController,
                suffixWidget: IconButton(
                  icon: Icon(
                    _obscurePhonePassword ? Iconsax.eye_slash : Iconsax.eye,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() => _obscurePhonePassword = !_obscurePhonePassword);
                  },
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu';
                return null;
              },
            ),
          ],

          if (_phoneErrorMessage != null) ...[
            const SizedBox(height: 14),
            _buildErrorBox(_phoneErrorMessage!),
          ],

          const SizedBox(height: 26),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePhoneLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
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
                      'Đăng nhập với Số điện thoại',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    _unfocus();
    final resetCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Iconsax.key, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              'Quên mật khẩu?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập Email gian hàng đã đăng ký để nhận mã khôi phục mật khẩu.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: resetCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'vidu@quanbanhang.vn',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: const Icon(Iconsax.sms, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hướng dẫn khôi phục mật khẩu đã được gửi!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
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
              message,
              style: TextStyle(
                fontSize: 13,
                color: Colors.red[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterFooter() {
    return Center(
      child: GestureDetector(
        onTap: _navigateToRegister,
        child: RichText(
          text: const TextSpan(
            text: 'Chưa có tài khoản gian hàng? ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
            ),
            children: [
              TextSpan(
                text: 'Đăng ký ngay',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    Widget? suffixWidget,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
      prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
      suffixIcon: suffixWidget ??
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                onPressed: () => controller.clear(),
              );
            },
          ),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
