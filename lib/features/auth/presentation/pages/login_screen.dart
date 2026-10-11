import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/core/widgets/google_logo.dart';
import 'package:cookconnect/features/profile/presentation/pages/profile_setup_screen.dart';
import 'package:cookconnect/features/auth/presentation/pages/register_email_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function(String name, String contactInfo)? onLoginSuccess;
  final bool initialSignUp;
  final ApiService? apiService;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.initialSignUp = false,
    this.apiService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _lastTabIndex = 0;
  late bool _isSignUp; // Toggle between Login and Register
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String? _phoneAuthError;
  String? _emailAuthError;

  late final ApiService _apiService;

  // Phone Login State & Focus Nodes
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phonePasswordController = TextEditingController();
  final _otpController = TextEditingController();

  final _phoneFocusNode = FocusNode();
  final _phonePasswordFocusNode = FocusNode();
  final _otpFocusNode = FocusNode();

  bool _loginWithOtp = false;
  bool _otpSent = false;
  int _otpCountdown = 60;
  Timer? _countdownTimer;

  // Email Login State & Focus Nodes
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _emailPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _isSignUp = widget.initialSignUp;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabAnimation);

    _emailController.addListener(_onEmailInputChanged);
    _emailPasswordController.addListener(_onEmailInputChanged);
    _confirmPasswordController.addListener(_onEmailInputChanged);

    _phoneController.addListener(_onPhoneInputChanged);
    _phonePasswordController.addListener(_onPhoneInputChanged);
    _otpController.addListener(_onPhoneInputChanged);
  }

  void _onEmailInputChanged() {
    if (_emailAuthError != null) {
      setState(() => _emailAuthError = null);
    }
  }

  void _onPhoneInputChanged() {
    if (_phoneAuthError != null) {
      setState(() => _phoneAuthError = null);
    }
  }

  void _unfocusAll() {
    _phoneFocusNode.unfocus();
    _phonePasswordFocusNode.unfocus();
    _otpFocusNode.unfocus();
    _emailFocusNode.unfocus();
    _emailPasswordFocusNode.unfocus();
    _confirmPasswordFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _onTabChanged(int newIndex) {
    final hadPhoneFocus =
        _phoneFocusNode.hasFocus ||
        _phonePasswordFocusNode.hasFocus ||
        _otpFocusNode.hasFocus;
    final hadEmailFocus =
        _emailFocusNode.hasFocus ||
        _emailPasswordFocusNode.hasFocus ||
        _confirmPasswordFocusNode.hasFocus;

    // Unfocus all nodes to detach any active keyboard
    _unfocusAll();

    setState(() {
      _phoneAuthError = null;
      _emailAuthError = null;
    });

    if (newIndex == 1) {
      if (hadPhoneFocus) {
        Future.microtask(() {
          if (mounted) {
            _emailFocusNode.requestFocus();
          }
        });
      }
    } else if (newIndex == 0) {
      if (hadEmailFocus) {
        Future.microtask(() {
          if (mounted) {
            _phoneFocusNode.requestFocus();
          }
        });
      }
    }
  }

  void _handleTabAnimation() {
    if (_tabController.index != _lastTabIndex) {
      _lastTabIndex = _tabController.index;
      _onTabChanged(_lastTabIndex);
    }
  }

  void _toggleSignUp() {
    _unfocusAll();
    setState(() {
      _isSignUp = !_isSignUp;
      _phoneAuthError = null;
      _emailAuthError = null;
    });
  }

  void _openRegisterScreen() {
    _unfocusAll();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterEmailScreen(
          apiService: _apiService,
          onLoginSuccess: widget.onLoginSuccess,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabAnimation);
    _tabController.dispose();

    _phoneFocusNode.dispose();
    _phonePasswordFocusNode.dispose();
    _otpFocusNode.dispose();

    _emailFocusNode.dispose();
    _emailPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _phoneController.dispose();
    _phonePasswordController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _emailPasswordController.dispose();
    _confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startOtpTimer() {
    setState(() {
      _otpSent = true;
      _otpCountdown = 60;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpCountdown > 1) {
        setState(() {
          _otpCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _otpSent = false;
        });
      }
    });
  }

  void _submitPhoneAuth() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final password = _phonePasswordController.text;

    if (_loginWithOtp && !_otpSent) {
      _startOtpTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mã xác thực OTP 6 số đã được gửi đến +84 $phone'),
          backgroundColor: Colors.blue[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _phoneAuthError = null;
      _isLoading = true;
    });

    if (_loginWithOtp) {
      // Simulated OTP flow
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _isLoading = false);

      final displayName = 'Chef $phone';
      AuthService.instance.setGuestDemo(
        name: displayName,
        email: '$phone@cookconnect.app',
      );

      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!(displayName, phone);
      }

      Navigator.pop(context);
      return;
    }

    // Call real backend server with phone mapped to unique account
    final mappedEmail = '$phone@cookconnect.app';

    try {
      final AuthResult result;
      if (_isSignUp) {
        result = await _apiService.register(
          email: mappedEmail,
          password: password,
          confirmPassword: password,
        );
      } else {
        result = await _apiService.login(
          email: mappedEmail,
          password: password,
        );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        final authenticatedUser =
            result.user ??
            AuthUser(
              id: 'user-$phone',
              email: mappedEmail,
              fullName: 'Chef $phone',
              username: 'chef_$phone',
            );

        final tokens =
            result.tokens ??
            AuthTokens(
              accessToken: 'access-token-$phone',
              refreshToken: 'refresh-token-$phone',
            );

        AuthService.instance.setSession(
          user: authenticatedUser,
          tokens: tokens,
        );

        final displayName = authenticatedUser.fullName.isNotEmpty
            ? authenticatedUser.fullName
            : 'Chef $phone';

        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!(displayName, phone);
        }

        if (_isSignUp) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ProfileSetupScreen(),
            ),
            (route) => false,
          );
        } else {
          Navigator.of(context).pop();
        }
      } else {
        _phonePasswordController.clear();
        setState(() {
          _phoneAuthError = result.error ??
              (_isSignUp
                  ? 'Đăng ký không thành công'
                  : 'Thông tin đăng nhập không chính xác');
        });
      }
    } catch (e) {
      if (!mounted) return;
      _phonePasswordController.clear();
      setState(() {
        _isLoading = false;
        _phoneAuthError = 'Lỗi kết nối máy chủ: ${e.toString()}';
      });
    }
  }

  void _submitEmailAuth() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _emailPasswordController.text;

    setState(() {
      _emailAuthError = null;
      _isLoading = true;
    });

    try {
      final AuthResult result;
      if (_isSignUp) {
        result = await _apiService.register(
          email: email,
          password: password,
          confirmPassword: _confirmPasswordController.text.isNotEmpty
              ? _confirmPasswordController.text
              : password,
        );
      } else {
        result = await _apiService.login(email: email, password: password);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        final defaultName = email.contains('@')
            ? email.split('@').first
            : email;
        final authenticatedUser =
            result.user ??
            AuthUser(
              id: 'user-email',
              email: email,
              fullName: defaultName,
              username: defaultName,
            );

        final tokens =
            result.tokens ??
            AuthTokens(
              accessToken: 'access-token-email',
              refreshToken: 'refresh-token-email',
            );

        AuthService.instance.setSession(
          user: authenticatedUser,
          tokens: tokens,
        );

        final displayName = authenticatedUser.fullName.isNotEmpty
            ? authenticatedUser.fullName
            : defaultName;

        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!(displayName, email);
        }

        if (_isSignUp) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ProfileSetupScreen(),
            ),
            (route) => false,
          );
        } else {
          Navigator.of(context).pop();
        }
      } else {
        _emailPasswordController.clear();
        if (_isSignUp) {
          _confirmPasswordController.clear();
        }
        setState(() {
          _emailAuthError = result.error ??
              (_isSignUp
                  ? 'Đăng ký không thành công'
                  : 'Email hoặc mật khẩu không chính xác');
        });
      }
    } catch (e) {
      if (!mounted) return;
      _emailPasswordController.clear();
      setState(() {
        _isLoading = false;
        _emailAuthError = 'Lỗi kết nối máy chủ: ${e.toString()}';
      });
    }
  }

  Widget _buildInlineError(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFCA5A5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Iconsax.warning_2,
            color: Color(0xFFDC2626),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    _unfocusAll();
    final resetCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Iconsax.key, color: Colors.orange),
            SizedBox(width: 10),
            Text(
              'Quên mật khẩu?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập Email hoặc Số điện thoại bạn đã đăng ký để nhận liên kết đặt lại mật khẩu.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email hoặc SĐT...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Iconsax.sms, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hướng dẫn khôi phục mật khẩu đã được gửi đi!'),
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
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header title
                Text(
                  _isSignUp ? 'Tạo tài khoản mới' : 'Chào mừng trở lại!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isSignUp
                      ? 'Đăng ký để khám phá công thức & chia sẻ đam mê làm bếp'
                      : 'Đăng nhập bằng Số điện thoại hoặc Email của bạn',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey[600],
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),

                // Segmented Tab Bar (SĐT / Email)
                Container(
                  height: 46,
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
                      onTap: (index) {
                        _lastTabIndex = index;
                        _onTabChanged(index);
                      },
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      enableFeedback: false,
                      dividerColor: Colors.transparent,
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
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13.5,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerHeight: 0,
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.call, size: 16),
                              SizedBox(width: 6),
                              Text('Số điện thoại'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.sms, size: 16),
                              SizedBox(width: 6),
                              Text('Email'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tab View
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return _tabController.index == 0
                        ? _buildPhoneLoginForm(primaryColor)
                        : _buildEmailLoginForm(primaryColor);
                  },
                ),

                const SizedBox(height: 24),

                // Divider Or
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.withValues(alpha: 0.3),
                        thickness: 0.8,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'Hoặc tiếp tục với',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.withValues(alpha: 0.3),
                        thickness: 0.8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialCircle(
                      customChild: const GoogleLogoWidget(size: 22),
                      onTap: () => _showSocialUnderDevelopment('Google'),
                    ),
                    const SizedBox(width: 16),
                    _buildSocialCircle(
                      customChild: const Icon(
                        FlutterRemix.apple_fill,
                        color: Colors.black,
                        size: 24,
                      ),
                      onTap: () => _showSocialUnderDevelopment('Apple'),
                    ),
                    const SizedBox(width: 16),
                    _buildSocialCircle(
                      customChild: const Icon(
                        FlutterRemix.facebook_fill,
                        color: Color(0xFF1877F2),
                        size: 24,
                      ),
                      onTap: () => _showSocialUnderDevelopment('Facebook'),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Toggle Sign In / Sign Up Footer
                Center(
                  child: GestureDetector(
                    onTap: _isSignUp ? _toggleSignUp : _openRegisterScreen,
                    child: RichText(
                      text: TextSpan(
                        text: _isSignUp
                            ? 'Đã có tài khoản? '
                            : 'Chưa có tài khoản? ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.5,
                        ),
                        children: [
                          TextSpan(
                            text: _isSignUp
                                ? 'Đăng nhập ngay'
                                : 'Đăng ký tài khoản',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
    );
  }

  // ==========================================
  // PHONE LOGIN FORM
  // ==========================================
  Widget _buildPhoneLoginForm(Color primaryColor) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phone input with +84 prefix
          Text(
            'Số điện thoại',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              if (val.trim().length < 9) {
                return 'Số điện thoại không hợp lệ (từ 9 - 10 số)';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: '912 345 678',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
              prefixIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇻🇳', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 6),
                    Text(
                      '+84',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
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

          const SizedBox(height: 14),

          // Switch between OTP and Password login (when not registering)
          if (!_isSignUp) ...[
            if (!_loginWithOtp) ...[
              _buildTextFormField(
                controller: _phonePasswordController,
                focusNode: _phonePasswordFocusNode,
                label: 'Mật khẩu',
                hint: 'Nhập mật khẩu...',
                prefixIcon: Iconsax.lock,
                isPassword: true,
                obscureText: _obscurePassword,
                onTogglePassword: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (val.length < 6) {
                    return 'Mật khẩu tối thiểu 6 ký tự';
                  }
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // OTP Input
              Text(
                'Mã xác thực OTP',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _otpController,
                focusNode: _otpFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (val) {
                  if (_otpSent && (val == null || val.length < 6)) {
                    return 'Vui lòng nhập đủ 6 chữ số OTP';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nhập mã 6 số...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  prefixIcon: const Icon(Iconsax.security_safe, size: 20),
                  suffixIcon: _otpSent
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              '${_otpCountdown}s',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _unfocusAll();
                    setState(() {
                      _loginWithOtp = !_loginWithOtp;
                      _phoneAuthError = null;
                    });
                  },
                  child: Text(
                    _loginWithOtp
                        ? 'Đăng nhập bằng Mật khẩu'
                        : 'Đăng nhập bằng Mã OTP (SMS)',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Registration Password
            _buildTextFormField(
              controller: _phonePasswordController,
              focusNode: _phonePasswordFocusNode,
              label: 'Tạo mật khẩu',
              hint: 'Tối thiểu 6 ký tự...',
              prefixIcon: Iconsax.lock,
              isPassword: true,
              obscureText: _obscurePassword,
              onTogglePassword: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              validator: (val) {
                if (val == null || val.length < 6) {
                  return 'Mật khẩu phải từ 6 ký tự trở lên';
                }
                return null;
              },
            ),
          ],

          if (_phoneAuthError != null) ...[
            const SizedBox(height: 14),
            _buildInlineError(_phoneAuthError!),
          ] else ...[
            const SizedBox(height: 20),
          ],

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPhoneAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isSignUp
                          ? 'Đăng ký tài khoản'
                          : (_loginWithOtp && !_otpSent
                                ? 'Nhận mã OTP'
                                : 'Đăng nhập'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // EMAIL LOGIN FORM
  // ==========================================
  Widget _buildEmailLoginForm(Color primaryColor) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: _isSignUp ? 'Địa chỉ Email' : 'Email hoặc Tên đăng nhập',
            hint: 'name@example.com',
            prefixIcon: Iconsax.sms,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (_isSignUp) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(val.trim())) {
                  return 'Định dạng email không hợp lệ';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          _buildTextFormField(
            controller: _emailPasswordController,
            focusNode: _emailPasswordFocusNode,
            label: _isSignUp ? 'Tạo mật khẩu' : 'Mật khẩu',
            hint: 'Nhập mật khẩu...',
            prefixIcon: Iconsax.lock,
            isPassword: true,
            obscureText: _obscurePassword,
            onTogglePassword: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (val.length < 6) {
                return 'Mật khẩu phải từ 6 ký tự trở lên';
              }
              return null;
            },
          ),

          if (_isSignUp) ...[
            const SizedBox(height: 12),
            _buildTextFormField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              label: 'Xác nhận lại mật khẩu',
              hint: 'Nhập lại mật khẩu trên...',
              prefixIcon: Iconsax.lock_1,
              isPassword: true,
              obscureText: _obscureConfirmPassword,
              onTogglePassword: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
              validator: (val) {
                if (_isSignUp && val != _emailPasswordController.text) {
                  return 'Mật khẩu xác nhận không khớp';
                }
                return null;
              },
            ),
          ] else ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordDialog,
                child: Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],

          if (_emailAuthError != null) ...[
            const SizedBox(height: 14),
            _buildInlineError(_emailAuthError!),
          ] else ...[
            const SizedBox(height: 20),
          ],

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitEmailAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isSignUp ? 'Đăng ký tài khoản' : 'Đăng nhập',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER FORM FIELDS
  // ==========================================
  Widget _buildTextFormField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword ? obscureText : false,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
            prefixIcon: Icon(prefixIcon, size: 20, color: Colors.grey[600]),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Iconsax.eye_slash : Iconsax.eye,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
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
      ],
    );
  }

  Widget _buildSocialCircle({
    Widget? customChild,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: customChild),
      ),
    );
  }

  void _showSocialUnderDevelopment([String? provider]) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Iconsax.info_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tính năng đang phát triển',
                style: TextStyle(fontSize: 13.5),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF333333),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
