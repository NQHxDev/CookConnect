import 'package:cookconnect/core/constants/api_codes/auth_api_codes.dart';

/// Vietnamese translations for Auth Module API response codes
final Map<String, String> authMessagesVi = {
  AuthApiErrorCode.invalidCredentials: 'Email hoặc mật khẩu không chính xác.',
  AuthApiErrorCode.userNotFound: 'Tài khoản không tồn tại trong hệ thống.',
  AuthApiErrorCode.accountBlocked: 'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ hỗ trợ.',
  AuthApiErrorCode.accountInactive: 'Tài khoản chưa được kích hoạt.',
  AuthApiErrorCode.accountLockedTemporarily: 'Tài khoản tạm thời bị khóa do đăng nhập sai nhiều lần. Vui lòng thử lại sau.',
  AuthApiErrorCode.emailAlreadyExists: 'Email đã được đăng ký trong hệ thống',
  AuthApiErrorCode.userAlreadyExists: 'Email đã được đăng ký trong hệ thống',
  AuthApiErrorCode.invalidEmailFormat: 'Định dạng email không hợp lệ.',
  AuthApiErrorCode.otpCooldownActive: 'Vui lòng chờ ít phút trước khi yêu cầu mã OTP mới.',
  AuthApiErrorCode.otpMaxAttemptsExceeded: 'Bạn đã nhập sai mã OTP quá nhiều lần. Vui lòng gửi lại mã mới.',
  AuthApiErrorCode.otpInvalid: 'Mã xác thực OTP không chính xác. Vui lòng kiểm tra lại.',
  AuthApiErrorCode.invalidOtp: 'Mã xác thực OTP không chính xác. Vui lòng kiểm tra lại.',
  AuthApiErrorCode.otpExpired: 'Mã OTP đã hết hạn. Vui lòng nhấn gửi lại mã mới.',
  AuthApiErrorCode.expiredOtp: 'Mã OTP đã hết hạn. Vui lòng nhấn gửi lại mã mới.',
  AuthApiErrorCode.verificationTokenInvalid: 'Mã xác thực không hợp lệ hoặc đã được sử dụng.',
  AuthApiErrorCode.verificationTokenExpired: 'Phiên xác thực đã hết hạn. Vui lòng thử lại từ đầu.',
  AuthApiErrorCode.refreshTokenRequired: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
  AuthApiErrorCode.refreshTokenInvalid: 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.',
  AuthApiErrorCode.refreshTokenRevoked: 'Phiên đăng nhập đã bị thu hồi. Vui lòng đăng nhập lại.',
  AuthApiErrorCode.refreshTokenExpired: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
  AuthApiErrorCode.tokenRevoked: 'Phiên đăng nhập đã bị thu hồi. Vui lòng đăng nhập lại.',
  AuthApiErrorCode.tokenInvalidOrExpired: 'Phiên đăng nhập đã hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.',
  AuthApiErrorCode.invalidOldPassword: 'Mật khẩu hiện tại không chính xác.',
  AuthApiErrorCode.passwordUnchanged: 'Mật khẩu mới không được trùng với mật khẩu cũ.',
  AuthApiErrorCode.sessionAlreadyRevoked: 'Phiên làm việc đã bị thu hồi.',
  AuthApiErrorCode.sessionNotFound: 'Phiên làm việc không tồn tại.',
  AuthApiErrorCode.currentSessionRequired: 'Yêu cầu phiên làm việc hiện tại.',

  // Success
  AuthApiSuccessCode.loginSuccess: 'Đăng nhập thành công.',
  AuthApiSuccessCode.registerSuccess: 'Đăng ký tài khoản thành công.',
  AuthApiSuccessCode.sendOtpSuccess: 'Mã OTP xác thực đã được gửi đến email của bạn.',
  AuthApiSuccessCode.verifyOtpSuccess: 'Xác thực OTP thành công.',
  AuthApiSuccessCode.sendChangePasswordOtpSuccess: 'Mã OTP đổi mật khẩu đã được gửi đến email của bạn.',
};
