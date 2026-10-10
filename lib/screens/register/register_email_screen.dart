import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/profile_setup_dialog.dart';
import 'register_otp_screen.dart';

typedef RegisterScreen = RegisterEmailScreen;

class RegisterEmailScreen extends StatefulWidget {
  final ApiService? apiService;
  final Function(String name, String contactInfo)? onLoginSuccess;
  final int initialTabIndex;

  const RegisterEmailScreen({super.key, this.apiService, this.onLoginSuccess, this.initialTabIndex = 0});

  @override
  State<RegisterEmailScreen> createState() => _RegisterEmailScreenState();
}

class _RegisterEmailScreenState extends State<RegisterEmailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Phone registration state
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phonePasswordController = TextEditingController();
  final _phoneConfirmPasswordController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _phonePasswordFocusNode = FocusNode();
  final _phoneConfirmPasswordFocusNode = FocusNode();
  bool _phoneObscurePassword = true;
  bool _phoneObscureConfirmPassword = true;
  bool _isPhoneLoading = false;
  String? _phoneErrorMessage;

  // Email registration state
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _isEmailLoading = false;
  String? _emailErrorMessage;

  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex.clamp(0, 1));
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _unfocus();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();

    _phoneController.dispose();
    _phonePasswordController.dispose();
    _phoneConfirmPasswordController.dispose();
    _phoneFocusNode.dispose();
    _phonePasswordFocusNode.dispose();
    _phoneConfirmPasswordFocusNode.dispose();

    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _unfocus() {
    _phoneFocusNode.unfocus();
    _phonePasswordFocusNode.unfocus();
    _phoneConfirmPasswordFocusNode.unfocus();
    _emailFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future<void> _submitPhoneRegister() async {
    _unfocus();
    setState(() {
      _phoneErrorMessage = null;
    });

    if (!_phoneFormKey.currentState!.validate()) {
      return;
    }

    final phone = _phoneController.text.trim();
    
    setState(() {
      _isPhoneLoading = true;
    });

    try {
      // Simulate network registration delay
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      final displayName = 'Chef $phone';
      final authUser = AuthUser(
        id: 'phone-user-${DateTime.now().millisecondsSinceEpoch}',
        email: '$phone@cookconnect.app',
        fullName: displayName,
        username: 'user_$phone',
      );

      final tokens = AuthTokens(
        accessToken: 'phone-access-token-${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'phone-refresh-token-${DateTime.now().millisecondsSinceEpoch}',
      );

      AuthService.instance.setSession(user: authUser, tokens: tokens);

      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!(displayName, phone);
      }

      setState(() {
        _isPhoneLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Iconsax.tick_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Đăng ký tài khoản thành công! Chào mừng bạn.', style: TextStyle(fontSize: 13.5))),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );

      final navigator = Navigator.of(context);
      navigator.popUntil((route) => route.isFirst);

      Future.microtask(() {
        final rootContext = navigator.context;
        if (rootContext.mounted) {
          ProfileSetupDialog.show(rootContext, isFirstTime: true);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPhoneLoading = false;
        _phoneErrorMessage = 'Lỗi kết nối: ${e.toString()}';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_phoneErrorMessage!), backgroundColor: Colors.red[700], behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _submitEmail() async {
    _unfocus();
    setState(() {
      _emailErrorMessage = null;
    });

    if (!_emailFormKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim().toLowerCase();

    setState(() {
      _isEmailLoading = true;
    });

    try {
      final result = await _apiService.sendOtp(email: email);

      if (!mounted) return;
      setState(() {
        _isEmailLoading = false;
      });

      if (result.isSuccess) {
        // Navigate to OTP Screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RegisterOtpScreen(email: email, apiService: _apiService, onLoginSuccess: widget.onLoginSuccess),
          ),
        );
      } else {
        setState(() {
          _emailErrorMessage = result.error ?? 'Không thể gửi mã OTP. Vui lòng thử lại.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.warning_2, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(_emailErrorMessage!, style: const TextStyle(fontSize: 13.5))),
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
        _isEmailLoading = false;
        _emailErrorMessage = 'Lỗi kết nối: ${e.toString()}';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_emailErrorMessage!), backgroundColor: Colors.red[700], behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: _unfocus,
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
            'Đăng ký tài khoản',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Theme(
                data: Theme.of(context).copyWith(splashColor: Colors.transparent, highlightColor: Colors.transparent, hoverColor: Colors.transparent),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  indicatorColor: primaryColor,
                  indicatorWeight: 2.5,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  enableFeedback: false,
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.grey[500],
                  labelStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.phone_android_rounded, size: 18), SizedBox(width: 6), Text('Số điện thoại')],
                      ),
                    ),
                    Tab(
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Iconsax.sms, size: 18), SizedBox(width: 6), Text('Email')]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(controller: _tabController, children: [_buildPhoneRegisterTab(primaryColor), _buildEmailRegisterTab(primaryColor)]),
        ),
      ),
    );
  }

  Widget _buildPhoneRegisterTab(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _phoneFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đăng ký bằng SĐT',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text('Nhập số điện thoại và mật khẩu để tạo tài khoản CookConnect.', style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4)),

            const SizedBox(height: 24),

            // Phone Field
            Text(
              'Số điện thoại',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _phonePasswordFocusNode.requestFocus(),
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                final phone = val.trim();
                if (phone.length < 9 || phone.length > 11) {
                  return 'Số điện thoại không hợp lệ';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: '0912 345 678',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.phone_android_rounded, size: 20, color: Colors.grey),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _phoneController,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () => _phoneController.clear(),
                    );
                  },
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
              ),
            ),

            const SizedBox(height: 16),

            // Password Field
            Text(
              'Mật khẩu',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phonePasswordController,
              focusNode: _phonePasswordFocusNode,
              obscureText: _phoneObscurePassword,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _phoneConfirmPasswordFocusNode.requestFocus(),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if (val.length < 6) {
                  return 'Mật khẩu phải từ 6 ký tự trở lên';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Tối thiểu 6 ký tự...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                prefixIcon: const Icon(Iconsax.lock, size: 20, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(_phoneObscurePassword ? Iconsax.eye_slash : Iconsax.eye, size: 20, color: Colors.grey[600]),
                  onPressed: () => setState(() => _phoneObscurePassword = !_phoneObscurePassword),
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
              ),
            ),

            const SizedBox(height: 16),

            // Confirm Password Field
            Text(
              'Xác nhận mật khẩu',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneConfirmPasswordController,
              focusNode: _phoneConfirmPasswordFocusNode,
              obscureText: _phoneObscureConfirmPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitPhoneRegister(),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Vui lòng nhập lại mật khẩu';
                }
                if (val != _phonePasswordController.text) {
                  return 'Mật khẩu xác nhận không trùng khớp';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Nhập lại mật khẩu trên...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                prefixIcon: const Icon(Iconsax.lock_1, size: 20, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(_phoneObscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye, size: 20, color: Colors.grey[600]),
                  onPressed: () => setState(() => _phoneObscureConfirmPassword = !_phoneObscureConfirmPassword),
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
              ),
            ),

            if (_phoneErrorMessage != null) ...[
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
                      child: Text(_phoneErrorMessage!, style: TextStyle(fontSize: 13, color: Colors.red[900])),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isPhoneLoading ? null : _submitPhoneRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isPhoneLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                    : const Text('Đăng ký tài khoản', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 28),

            // Footer
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    text: 'Đã có tài khoản? ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13.5),
                    children: [
                      TextSpan(
                        text: 'Đăng nhập ngay',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailRegisterTab(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _emailFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header title & description
            const Text(
              'Nhập địa chỉ Email',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Chúng tôi sẽ gửi mã xác thực OTP gồm 6 chữ số đến hòm thư này để xác minh tài khoản của bạn.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
            ),

            const SizedBox(height: 24),

            // Email input field
            Text(
              'Email',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitEmail(),
              autofillHints: const [AutofillHints.email],
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Vui lòng nhập địa chỉ email';
                }
                final email = val.trim();
                final emailRegex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
                if (!emailRegex.hasMatch(email)) {
                  return 'Định dạng email không hợp lệ (ví dụ: name@example.com)';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'name@example.com',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                prefixIcon: const Icon(Iconsax.sms, size: 20, color: Colors.grey),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _emailController,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () => _emailController.clear(),
                    );
                  },
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
              ),
            ),

            if (_emailErrorMessage != null) ...[
              const SizedBox(height: 12),
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
                      child: Text(_emailErrorMessage!, style: TextStyle(fontSize: 13, color: Colors.red[900])),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Submit Button: Gửi mã xác thực
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isEmailLoading ? null : _submitEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isEmailLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                    : const Text('Tiếp tục', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 28),

            // Footer: Đã có tài khoản? Đăng nhập
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    text: 'Đã có tài khoản? ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13.5),
                    children: [
                      TextSpan(
                        text: 'Đăng nhập ngay',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
