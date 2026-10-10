import 'package:cookconnect/core/constants/api_codes/auth_api_codes.dart';

/// English translations for Auth Module API response codes
final Map<String, String> authMessagesEn = {
  AuthApiErrorCode.invalidCredentials: 'Invalid email or password.',
  AuthApiErrorCode.userNotFound: 'User account does not exist.',
  AuthApiErrorCode.accountBlocked: 'Your account has been blocked. Please contact support.',
  AuthApiErrorCode.accountInactive: 'Your account is inactive.',
  AuthApiErrorCode.accountLockedTemporarily: 'Account is temporarily locked due to multiple failed logins.',
  AuthApiErrorCode.emailAlreadyExists: 'This email is already registered.',
  AuthApiErrorCode.userAlreadyExists: 'This email is already registered.',
  AuthApiErrorCode.invalidEmailFormat: 'Invalid email format.',
  AuthApiErrorCode.otpCooldownActive: 'Please wait a few moments before requesting a new OTP.',
  AuthApiErrorCode.otpMaxAttemptsExceeded: 'You have exceeded maximum OTP attempts. Please request a new code.',
  AuthApiErrorCode.otpInvalid: 'Incorrect OTP code. Please check and try again.',
  AuthApiErrorCode.invalidOtp: 'Incorrect OTP code. Please check and try again.',
  AuthApiErrorCode.otpExpired: 'OTP code has expired. Please request a new code.',
  AuthApiErrorCode.expiredOtp: 'OTP code has expired. Please request a new code.',
  AuthApiErrorCode.verificationTokenInvalid: 'Invalid or already used verification token.',
  AuthApiErrorCode.verificationTokenExpired: 'Verification session has expired. Please start over.',
  AuthApiErrorCode.refreshTokenRequired: 'Session expired. Please log in again.',
  AuthApiErrorCode.refreshTokenInvalid: 'Invalid session. Please log in again.',
  AuthApiErrorCode.refreshTokenRevoked: 'Session has been revoked. Please log in again.',
  AuthApiErrorCode.refreshTokenExpired: 'Session expired. Please log in again.',
  AuthApiErrorCode.tokenRevoked: 'Token revoked. Please log in again.',
  AuthApiErrorCode.tokenInvalidOrExpired: 'Session expired or invalid. Please log in again.',
  AuthApiErrorCode.invalidOldPassword: 'Current password is incorrect.',
  AuthApiErrorCode.passwordUnchanged: 'New password must be different from current password.',
  AuthApiErrorCode.sessionAlreadyRevoked: 'Session has already been revoked.',
  AuthApiErrorCode.sessionNotFound: 'Session not found.',
  AuthApiErrorCode.currentSessionRequired: 'Current session is required.',

  // Success
  AuthApiSuccessCode.loginSuccess: 'Logged in successfully.',
  AuthApiSuccessCode.registerSuccess: 'Account registered successfully.',
  AuthApiSuccessCode.sendOtpSuccess: 'OTP verification code has been sent to your email.',
  AuthApiSuccessCode.verifyOtpSuccess: 'OTP verified successfully.',
  AuthApiSuccessCode.sendChangePasswordOtpSuccess: 'Password change OTP code has been sent to your email.',
};
