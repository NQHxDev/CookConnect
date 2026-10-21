/// Server API Error & Response Codes for Authentication & Authorization Module
class AuthApiErrorCode {
  AuthApiErrorCode._();

  static const String invalidCredentials = 'AUTH.INVALID_CREDENTIALS';
  static const String userNotFound = 'AUTH.USER_NOT_FOUND';
  static const String accountBlocked = 'AUTH.ACCOUNT_BLOCKED';
  static const String accountInactive = 'AUTH.ACCOUNT_INACTIVE';
  static const String accountLockedTemporarily = 'AUTH.ACCOUNT_LOCKED_TEMPORARILY';
  static const String emailAlreadyExists = 'AUTH.EMAIL_ALREADY_EXISTS';
  static const String userAlreadyExists = 'AUTH.USER_ALREADY_EXISTS';
  static const String invalidEmailFormat = 'AUTH.INVALID_EMAIL_FORMAT';
  static const String otpCooldownActive = 'AUTH.OTP_COOLDOWN_ACTIVE';
  static const String otpMaxAttemptsExceeded = 'AUTH.OTP_MAX_ATTEMPTS_EXCEEDED';
  static const String otpInvalid = 'AUTH.OTP_INVALID';
  static const String invalidOtp = 'AUTH.INVALID_OTP';
  static const String otpExpired = 'AUTH.OTP_EXPIRED';
  static const String expiredOtp = 'AUTH.EXPIRED_OTP';
  static const String verificationTokenInvalid = 'AUTH.VERIFICATION_TOKEN_INVALID';
  static const String verificationTokenExpired = 'AUTH.VERIFICATION_TOKEN_EXPIRED';
  static const String refreshTokenRequired = 'AUTH.REFRESH_TOKEN_REQUIRED';
  static const String refreshTokenInvalid = 'AUTH.REFRESH_TOKEN_INVALID';
  static const String refreshTokenRevoked = 'AUTH.REFRESH_TOKEN_REVOKED';
  static const String refreshTokenExpired = 'AUTH.REFRESH_TOKEN_EXPIRED';
  static const String tokenRevoked = 'AUTH.TOKEN_REVOKED';
  static const String tokenInvalidOrExpired = 'AUTH.TOKEN_INVALID_OR_EXPIRED';
  static const String invalidOldPassword = 'AUTH.INVALID_OLD_PASSWORD';
  static const String passwordUnchanged = 'AUTH.PASSWORD_UNCHANGED';
  static const String sessionAlreadyRevoked = 'AUTH.SESSION_ALREADY_REVOKED';
  static const String sessionNotFound = 'AUTH.SESSION_NOT_FOUND';
  static const String currentSessionRequired = 'AUTH.CURRENT_SESSION_REQUIRED';
}

class AuthApiSuccessCode {
  AuthApiSuccessCode._();

  static const String loginSuccess = 'AUTH.LOGIN_SUCCESS';
  static const String registerSuccess = 'AUTH.REGISTER_SUCCESS';
  static const String sendOtpSuccess = 'AUTH.SEND_OTP_SUCCESS';
  static const String verifyOtpSuccess = 'AUTH.VERIFY_OTP_SUCCESS';
  static const String sendChangePasswordOtpSuccess = 'AUTH.SEND_CHANGE_PASSWORD_OTP_SUCCESS';
}
