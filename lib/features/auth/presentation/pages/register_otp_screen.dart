import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/presentation/pages/register_password_screen.dart';

class RegisterOtpScreen extends StatefulWidget {
  final String email;
  final ApiService? apiService;
  final Function(String name, String contactInfo)? onLoginSuccess;
  final Function(String email, String? verificationToken)? onOtpVerified;

  const RegisterOtpScreen({
    super.key,
    required this.email,
    this.apiService,
    this.onLoginSuccess,
    this.onOtpVerified,
  });

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  static const int _otpLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  late final ApiService _apiService;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;

  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();

    _controllers = List.generate(
      _otpLength,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      _otpLength,
      (index) => FocusNode(),
    );

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
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _unfocusAll() {
    for (var f in _focusNodes) {
      f.unfocus();
    }
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  String get _currentOtpCode {
    return _controllers.map((c) => c.text).join();
  }

  bool get _isOtpComplete {
    return _currentOtpCode.length == _otpLength;
  }

  void _onDigitChanged(int index, String value) {
    setState(() {
      _errorMessage = null;
    });

    if (value.length > 1) {
      // Handles pasting multiple digits
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        for (int i = 0; i < _otpLength; i++) {
          if (i < digits.length) {
            _controllers[i].text = digits[i];
          }
        }
        final nextFocusIndex = digits.length < _otpLength ? digits.length : _otpLength - 1;
        _focusNodes[nextFocusIndex].requestFocus();

        if (digits.length >= _otpLength) {
          _unfocusAll();
          _submitOtp();
        }
        return;
      }
    }

    if (value.isNotEmpty) {
      _controllers[index].text = value;
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_isOtpComplete) {
          _submitOtp();
        }
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_countdown > 0 || _isResending) return;

    _unfocusAll();
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.sendOtp(
        email: widget.email,
      );

      if (!mounted) return;
      setState(() {
        _isResending = false;
      });

      if (result.isSuccess) {
        // Clear entered digits
        for (var c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
        _startCountdownTimer(result.cooldownSeconds ?? 60);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.tick_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.message ?? 'Đã gửi lại mã OTP mới đến email của bạn',
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Không thể gửi lại mã OTP. Vui lòng thử lại sau.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _errorMessage = 'Lỗi kết nối: ${e.toString()}';
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
      final result = await _apiService.verifyOtp(
        email: widget.email,
        otp: otpCode,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (result.isSuccess) {
        if (widget.onOtpVerified != null) {
          widget.onOtpVerified!(widget.email, result.verificationToken);
        }

        // Navigate immediately to Step 3: Password Creation Screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RegisterPasswordScreen(
              email: widget.email,
              verificationToken: result.verificationToken,
              apiService: _apiService,
              onLoginSuccess: widget.onLoginSuccess,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Mã xác thực OTP không chính xác. Vui lòng kiểm tra lại.';
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
            'Xác thực OTP',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                // Header title
                const Text(
                  'Nhập mã xác thực',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle + Email display with edit button
                Text(
                  'Mã xác thực gồm 6 chữ số đã được gửi đến email:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.sms, size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.email,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Icon(Iconsax.edit_2, size: 14, color: primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                'Đổi email',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 6-digit PIN Box Row
                _buildOtpInputBoxes(primaryColor),

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

                const SizedBox(height: 24),

                // Resend Countdown Row
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
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(Iconsax.rotate_left, size: 16, color: primaryColor),
                          label: Text(
                            'Gửi lại mã OTP',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 28),

                // Submit Button: Xác nhận OTP
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_isOtpComplete) ? null : _submitOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: primaryColor.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
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
                        : const Text(
                            'Xác nhận',
                            style: TextStyle(
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
      ),
    );
  }

  Widget _buildOtpInputBoxes(Color primaryColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = (constraints.maxWidth - (5 * 8)) / 6;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_otpLength, (index) {
            final isFocused = _focusNodes[index].hasFocus;
            final isFilled = _controllers[index].text.isNotEmpty;

            return SizedBox(
              width: boxSize.clamp(42.0, 52.0),
              height: 56,
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace) {
                    if (_controllers[index].text.isEmpty && index > 0) {
                      _controllers[index - 1].clear();
                      _focusNodes[index - 1].requestFocus();
                    }
                  }
                },
                child: TextFormField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: isFocused
                        ? primaryColor.withValues(alpha: 0.04)
                        : const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isFilled ? primaryColor.withValues(alpha: 0.6) : Colors.grey.shade300,
                        width: isFilled ? 1.5 : 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2.0),
                    ),
                  ),
                  onChanged: (val) => _onDigitChanged(index, val),
                ),
              ),
            );
          }),
        );
      },
    );
  }


}
