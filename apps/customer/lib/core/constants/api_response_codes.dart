export 'api_codes/ui_i18n_keys.dart';
export 'api_codes/user_api_codes.dart';
export 'api_codes/auth_api_codes.dart';
export 'api_codes/common_api_codes.dart';

import 'package:cookconnect/core/constants/api_codes/user_api_codes.dart';
import 'package:cookconnect/core/constants/api_codes/auth_api_codes.dart';
import 'package:cookconnect/core/constants/api_codes/common_api_codes.dart';

/// Unified namespace alias for all API Error Codes across modules
class ApiErrorCode {
  ApiErrorCode._();

  // User Module
  static const String userFileRequired = UserApiErrorCode.fileRequired;
  static const String userInvalidFileType = UserApiErrorCode.invalidFileType;
  static const String userFileTooLarge = UserApiErrorCode.fileTooLarge;
  static const String userNotFound = UserApiErrorCode.userNotFound;
  static const String userUsernameAlreadyTaken = UserApiErrorCode.usernameAlreadyTaken;
  static const String userInvalidUsernameFormat = UserApiErrorCode.invalidUsernameFormat;
  static const String userAlreadyExists = UserApiErrorCode.userAlreadyExists;

  // Auth Module
  static const String authInvalidCredentials = AuthApiErrorCode.invalidCredentials;
  static const String authUserNotFound = AuthApiErrorCode.userNotFound;
  static const String authAccountBlocked = AuthApiErrorCode.accountBlocked;
  static const String authAccountInactive = AuthApiErrorCode.accountInactive;
  static const String authAccountLockedTemporarily = AuthApiErrorCode.accountLockedTemporarily;
  static const String authEmailAlreadyExists = AuthApiErrorCode.emailAlreadyExists;
  static const String authUserAlreadyExists = AuthApiErrorCode.userAlreadyExists;
  static const String authInvalidEmailFormat = AuthApiErrorCode.invalidEmailFormat;
  static const String authOtpCooldownActive = AuthApiErrorCode.otpCooldownActive;
  static const String authOtpMaxAttemptsExceeded = AuthApiErrorCode.otpMaxAttemptsExceeded;
  static const String authOtpInvalid = AuthApiErrorCode.otpInvalid;
  static const String authInvalidOtp = AuthApiErrorCode.invalidOtp;
  static const String authOtpExpired = AuthApiErrorCode.otpExpired;
  static const String authExpiredOtp = AuthApiErrorCode.expiredOtp;
  static const String authVerificationTokenInvalid = AuthApiErrorCode.verificationTokenInvalid;
  static const String authVerificationTokenExpired = AuthApiErrorCode.verificationTokenExpired;
  static const String authRefreshTokenRequired = AuthApiErrorCode.refreshTokenRequired;
  static const String authRefreshTokenInvalid = AuthApiErrorCode.refreshTokenInvalid;
  static const String authRefreshTokenRevoked = AuthApiErrorCode.refreshTokenRevoked;
  static const String authRefreshTokenExpired = AuthApiErrorCode.refreshTokenExpired;
  static const String authTokenRevoked = AuthApiErrorCode.tokenRevoked;
  static const String authTokenInvalidOrExpired = AuthApiErrorCode.tokenInvalidOrExpired;
  static const String authInvalidOldPassword = AuthApiErrorCode.invalidOldPassword;
  static const String authPasswordUnchanged = AuthApiErrorCode.passwordUnchanged;
  static const String authSessionAlreadyRevoked = AuthApiErrorCode.sessionAlreadyRevoked;
  static const String authSessionNotFound = AuthApiErrorCode.sessionNotFound;
  static const String authCurrentSessionRequired = AuthApiErrorCode.currentSessionRequired;

  // Common Module
  static const String commonUnauthorized = CommonApiErrorCode.unauthorized;
  static const String commonForbidden = CommonApiErrorCode.forbidden;
  static const String commonNotOwnerOrAdmin = CommonApiErrorCode.notOwnerOrAdmin;
  static const String commonValidationFailed = CommonApiErrorCode.validationFailed;
  static const String commonInvalidRequest = CommonApiErrorCode.invalidRequest;
  static const String commonInternalServerError = CommonApiErrorCode.internalServerError;

  // HTTP status keys
  static const String badRequest = CommonApiErrorCode.badRequest;
  static const String unauthorized = CommonApiErrorCode.httpUnauthorized;
  static const String forbidden = CommonApiErrorCode.httpForbidden;
  static const String notFound = CommonApiErrorCode.notFound;
  static const String conflict = CommonApiErrorCode.conflict;
  static const String tooManyRequests = CommonApiErrorCode.tooManyRequests;
  static const String internalServerError = CommonApiErrorCode.httpInternalServerError;
}

/// Unified namespace alias for all API Success Codes across modules
class ApiSuccessCode {
  ApiSuccessCode._();

  static const String usersUploadAvatarSuccess = UserApiSuccessCode.uploadAvatarSuccess;
  static const String authLoginSuccess = AuthApiSuccessCode.loginSuccess;
  static const String authRegisterSuccess = AuthApiSuccessCode.registerSuccess;
  static const String authSendOtpSuccess = AuthApiSuccessCode.sendOtpSuccess;
  static const String authVerifyOtpSuccess = AuthApiSuccessCode.verifyOtpSuccess;
  static const String authSendChangePasswordOtpSuccess = AuthApiSuccessCode.sendChangePasswordOtpSuccess;
}
