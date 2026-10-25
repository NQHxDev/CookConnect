class Validators {
  Validators._();

  static String? requiredField(String? value, [String message = 'Trường này không được để trống']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    // Hỗ trợ cả định dạng plus-addressing (ví dụ: email+1@gmail.com, name+dev@domain.vn)
    final emailRegex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? validateEmail(String? value) => email(value);

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  static String? validatePassword(String? value) => password(value);

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  static String? validatePhone(String? value) => phone(value);

  /// Kiểm tra định dạng verificationToken từ verify-otp:
  /// Bắt buộc bắt đầu bằng 'vtok_' và có độ dài 37 (compact UUIDv7) hoặc 41 (hyphenated UUIDv7).
  static bool isValidVerificationToken(String? value) {
    if (value == null) return false;
    final clean = value.trim();
    if (!clean.startsWith('vtok_')) return false;
    return clean.length == 37 || clean.length == 41;
  }

  static String? verificationToken(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng cung cấp mã xác thực OTP';
    }
    if (!isValidVerificationToken(value)) {
      return 'Mã xác thực không hợp lệ (yêu cầu định dạng vtok_...)';
    }
    return null;
  }
}
