/// Unified namespace for API response & error codes
class ApiErrorCode {
  ApiErrorCode._();

  // Common errors
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String badRequest = 'BAD_REQUEST';
  static const String notFound = 'NOT_FOUND';
  static const String conflict = 'CONFLICT';
  static const String validationFailed = 'VALIDATION_FAILED';
  static const String internalServerError = 'INTERNAL_SERVER_ERROR';

  // Auth & Seller errors
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String sellerNotFound = 'SELLER_NOT_FOUND';
  static const String storeInactive = 'STORE_INACTIVE';
  static const String tokenExpired = 'TOKEN_EXPIRED';
  static const String tokenInvalid = 'TOKEN_INVALID';

  // Order errors
  static const String orderNotFound = 'ORDER_NOT_FOUND';
  static const String invalidOrderStatus = 'INVALID_ORDER_STATUS';

  // Menu item errors
  static const String itemNotFound = 'ITEM_NOT_FOUND';
  static const String itemOutOfStock = 'ITEM_OUT_OF_STOCK';
}

class ApiSuccessCode {
  ApiSuccessCode._();

  static const String ok = 'OK';
  static const String created = 'CREATED';
  static const String updated = 'UPDATED';
  static const String deleted = 'DELETED';
}
