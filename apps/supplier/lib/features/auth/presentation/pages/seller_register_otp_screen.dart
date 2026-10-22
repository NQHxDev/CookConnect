import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/auth/data/services/seller_auth_service.dart';
import 'package:cook_connect_seller/features/auth/presentation/pages/seller_register_password_screen.dart';

class SellerRegisterOtpScreen extends StatefulWidget {
  final String contact;
  final bool isPhone;
  final String? verificationToken;
  final VoidCallback? onLoginSuccess;

  const SellerRegisterOtpScreen({
    super.key,
    required this.contact,
    this.isPhone = false,
    this.verificationToken,
    this.onLoginSuccess,
  });

  @override
  State<SellerRegisterOtpScreen> createState() => _SellerRegisterOtpScreenState();
}

class _SellerRegisterOtpScreenState extends State<SellerRegisterOtpScreen> {
  static const int _otpLength = 6;
  late final TextEditingController _otpController;
  late final FocusNode _otpFocusNode;

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;

  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();
    _otpFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    _startCountdownTimer();
  }

  void _startCountdownTimer([int seconds = 60]) {
    setState(() {
      _countdown = seconds;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _countdown = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _unfocusAll() {
    _otpFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  String get _currentOtpCode => _otpController.text.trim();
  bool get _isOtpComplete => _currentOtpCode.length == _otpLength;

  void _onOtpChanged(String value) {
    setState(() {
      _errorMessage = null;
    });

    if (value.length >= _otpLength) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && _isOtpComplete && !_isLoading) {
          _unfocusAll();
          _submitOtp();
        }
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final rawText = data?.text ?? '';
      final match = RegExp(r'\b\d{6}\b').firstMatch(rawText) ?? RegExp(r'\d{6}').firstMatch(rawText);

      if (match != null) {
        final code = match.group(0)!;
        _otpController.text = code;
        _otpController.selection = TextSelection.collapsed(offset: code.length);
        _onOtpChanged(code);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Iconsax.tick_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('Đã dán mã OTP: $code'),
                ],
              ),
              backgroundColor: Colors.green[700],
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Iconsax.info_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Không tìm thấy mã OTP 6 số trong bộ nhớ tạm'),
                  ),
                ],
              ),
              backgroundColor: Colors.grey[800],
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _resendOtp() async {
    if (_countdown > 0 || _isResending) return;

    _unfocusAll();
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final result = await SellerAuthService.instance.sendOtp(
        contact: widget.contact,
      );

      if (!mounted) return;
      setState(() => _isResending = false);

      if (result.isSuccess) {
        _startCountdownTimer(result.cooldownSeconds ?? 60);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.tick_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.message ?? 'Đã gửi lại mã OTP thành công!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Không thể gửi lại mã OTP. Vui lòng thử lại.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _errorMessage = 'Gửi lại mã OTP thất bại. Vui lòng thử lại sau.';
      });
    }
  }

  Future<void> _submitOtp() async {
    final otpCode = _currentOtpCode;
    if (otpCode.length != _otpLength) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đủ 6 chữ số mã OTP';
      });
      return;
    }

    _unfocusAll();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await SellerAuthService.instance.verifyOtp(
        contact: widget.contact,
        otp: otpCode,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        TextInput.finishAutofillContext();

        // Navigate to Step 3: Password creation screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SellerRegisterPasswordScreen(
              contact: widget.contact,
              isPhone: widget.isPhone,
              verificationToken: result.verificationToken ?? widget.verificationToken,
              onLoginSuccess: widget.onLoginSuccess,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Mã xác thực OTP không chính xác. Vui lòng kiểm tra lại.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Đã có lỗi xảy ra trong quá trình xác thực OTP.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;

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
          'Xác thực OTP',
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
            // Step Progress Indicator
            _buildStepIndicator(step: 2, title: 'Bước 2/3: Xác thực mã OTP'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sent to banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.isPhone ? Iconsax.call : Iconsax.sms_tracking,
                                  color: primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Mã OTP đã được gửi đến',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.contact,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(Iconsax.edit_2, size: 14, color: primaryColor),
                                      SizedBox(width: 4),
                                      Text(
                                        'Đổi',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Nhập mã xác nhận 6 số',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 6-digit OTP Box row
                    _buildOtpInputBoxes(primaryColor),

                    // Paste button
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _pasteFromClipboard,
                          icon: const Icon(Iconsax.clipboard_text, size: 14, color: primaryColor),
                          label: const Text(
                            'Dán mã từ clipboard',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),

                    if (_errorMessage != null) ...[
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

                    const SizedBox(height: 24),

                    // Countdown / Resend Row
                    Center(
                      child: _countdown > 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Iconsax.timer_1, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(
                                  'Gửi lại mã sau ${_countdown}s',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : TextButton.icon(
                              onPressed: _isResending ? null : _resendOtp,
                              icon: _isResending
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: primaryColor,
                                      ),
                                    )
                                  : const Icon(Iconsax.refresh, size: 16, color: primaryColor),
                              label: const Text(
                                'Gửi lại mã OTP ngay',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_isLoading || !_isOtpComplete) ? null : _submitOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: primaryColor.withValues(alpha: 0.4),
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
                                'Xác nhận & Tiếp tục',
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
          ],
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
                '66%',
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
              value: 0.66,
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputBoxes(Color primaryColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = 5 * 8.0;
        final boxWidth = ((constraints.maxWidth - totalSpacing) / _otpLength).clamp(42.0, 52.0);
        const boxHeight = 56.0;
        final currentText = _otpController.text;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Visible custom PIN boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_otpLength, (index) {
                final isCurrentFocus = _otpFocusNode.hasFocus &&
                    (index == currentText.length ||
                        (currentText.length == _otpLength && index == _otpLength - 1));
                final isFilled = index < currentText.length;
                final digit = isFilled ? currentText[index] : '';

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  width: boxWidth,
                  height: boxHeight,
                  decoration: BoxDecoration(
                    color: isCurrentFocus
                        ? primaryColor.withValues(alpha: 0.05)
                        : (isFilled ? Colors.white : const Color(0xFFF9FAFB)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrentFocus
                          ? primaryColor
                          : (isFilled
                              ? primaryColor.withValues(alpha: 0.6)
                              : Colors.grey.shade300),
                      width: isCurrentFocus ? 2.0 : (isFilled ? 1.5 : 1.0),
                    ),
                    boxShadow: isCurrentFocus
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      digit,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              }),
            ),

            // Invisible real TextField for keyboard inputs and OS SMS autofill
            Positioned.fill(
              child: Opacity(
                opacity: 0.0,
                child: TextField(
                  controller: _otpController,
                  focusNode: _otpFocusNode,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  maxLength: _otpLength,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_otpLength),
                  ],
                  cursorWidth: 0,
                  enableInteractiveSelection: true,
                  showCursor: false,
                  onChanged: _onOtpChanged,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
