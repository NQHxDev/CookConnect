import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/core/utils/validators.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_register_otp_screen.dart';

class SellerRegisterContactScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final int initialTabIndex;

  const SellerRegisterContactScreen({
    super.key,
    this.onLoginSuccess,
    this.initialTabIndex = 0,
  });

  @override
  State<SellerRegisterContactScreen> createState() => _SellerRegisterContactScreenState();
}

class _SellerRegisterContactScreenState extends State<SellerRegisterContactScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  bool _isLoading = false;
  String? _emailErrorMessage;
  String? _phoneErrorMessage;

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
    _emailController.dispose();
    _phoneController.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
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

  Future<void> _handleEmailSubmit() async {
    _unfocus();
    setState(() => _emailErrorMessage = null);

    if (!_emailFormKey.currentState!.validate()) return;

    final contact = _emailController.text.trim().toLowerCase();
    setState(() => _isLoading = true);

    try {
      final result = await SellerAuthService.instance.sendOtp(contact: contact);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        _showSuccessSnackBar(result.message ?? 'Mã OTP xác thực đã được gửi tới $contact');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SellerRegisterOtpScreen(
              contact: contact,
              isPhone: false,
              verificationToken: result.verificationToken,
              onLoginSuccess: widget.onLoginSuccess,
            ),
          ),
        );
      } else {
        setState(() {
          _emailErrorMessage = result.error ?? 'Không thể gửi mã OTP. Vui lòng thử lại sau.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailErrorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
      });
    }
  }

  void _handlePhoneSubmit() {
    _unfocus();
    setState(() {
      _phoneErrorMessage = 'Cổng đăng ký Nhà Cung Cấp yêu cầu xác thực bằng Email doanh nghiệp / chủ quán để bảo mật hồ sơ thương mại. Vui lòng sử dụng Email để tiếp tục.';
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.sms_tracking, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13.5),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            'Đăng ký gian hàng',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Step Progress Indicator placed logically under AppBar
              _buildStepIndicator(step: 1, title: 'Bước 1/3: Thông tin liên hệ'),

              // Smooth Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Modern Card Header
                      _buildIntroCard(
                        title: 'Mở gian hàng CookConnect',
                        subtitle: 'Nhập thông tin liên hệ để nhận mã xác thực OTP tạo tài khoản đối tác bán hàng',
                      ),

                      const SizedBox(height: 20),

                      // Sleek Segmented Pill Switcher
                      _buildSegmentedTabBar(primaryColor),

                      const SizedBox(height: 24),

                      // Smooth Animated Switcher between Email and Phone
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
                                  ? _buildEmailRegisterTab(primaryColor)
                                  : _buildPhoneRegisterTab(primaryColor),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Login Footer
                      _buildLoginFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator({required int step, required String title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                '33%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.33,
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 5,
            ),
          ),
        ],
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

  Widget _buildEmailRegisterTab(Color primaryColor) {
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
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            decoration: _inputDecoration(
              hint: 'vidu@quanbanhang.vn',
              icon: Iconsax.sms,
              controller: _emailController,
            ),
            validator: Validators.email,
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Icon(Iconsax.info_circle, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'CookConnect sẽ gửi mã OTP gồm 6 chữ số đến email này.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),

          if (_emailErrorMessage != null) ...[
            const SizedBox(height: 14),
            _buildErrorBox(_emailErrorMessage!),
          ],

          const SizedBox(height: 26),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleEmailSubmit,
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
                      'Tiếp tục & Nhận mã OTP',
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

  Widget _buildPhoneRegisterTab(Color primaryColor) {
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
            textInputAction: TextInputAction.done,
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              final clean = value.trim();
              if (clean.length < 9 || clean.length > 12) {
                return 'Số điện thoại không hợp lệ (từ 9 đến 11 số)';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Iconsax.info_circle, size: 18, color: Colors.amber[800]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cổng đăng ký Nhà Cung Cấp yêu cầu xác thực bằng Email chính thức để gửi hợp đồng và thông báo thanh toán.',
                    style: TextStyle(fontSize: 12.5, color: Colors.amber[900], height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _tabController.animateTo(0),
            icon: const Icon(Iconsax.sms, size: 16),
            label: const Text('Chuyển sang đăng ký qua Email (Khuyên dùng)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          if (_phoneErrorMessage != null) ...[
            const SizedBox(height: 14),
            _buildErrorBox(_phoneErrorMessage!),
          ],

          const SizedBox(height: 26),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePhoneSubmit,
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
                      'Tiếp tục & Nhận mã OTP',
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

  Widget _buildIntroCard({required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.shop,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
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

  Widget _buildLoginFooter() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: RichText(
          text: const TextSpan(
            text: 'Đã có tài khoản gian hàng? ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
            ),
            children: [
              TextSpan(
                text: 'Đăng nhập ngay',
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
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
      prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
      suffixIcon: ValueListenableBuilder<TextEditingValue>(
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
