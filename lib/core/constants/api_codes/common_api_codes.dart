/// Server API Error & Response Codes for Common & System Level Operations
class CommonApiErrorCode {
  CommonApiErrorCode._();

  static const String unauthorized = 'COMMON.UNAUTHORIZED';
  static const String forbidden = 'COMMON.FORBIDDEN';
  static const String notOwnerOrAdmin = 'COMMON.NOT_OWNER_OR_ADMIN';
  static const String validationFailed = 'COMMON.VALIDATION_FAILED';
  static const String invalidRequest = 'COMMON.INVALID_REQUEST';
  static const String internalServerError = 'COMMON.INTERNAL_SERVER_ERROR';

  // HTTP status code keys
  static const String badRequest = 'BAD_REQUEST';
  static const String httpUnauthorized = 'UNAUTHORIZED';
  static const String httpForbidden = 'FORBIDDEN';
  static const String notFound = 'NOT_FOUND';
  static const String conflict = 'CONFLICT';
  static const String tooManyRequests = 'TOO_MANY_REQUESTS';
  static const String httpInternalServerError = 'INTERNAL_SERVER_ERROR';
}
