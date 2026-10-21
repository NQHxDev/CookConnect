import 'package:cookconnect/core/constants/api_codes/common_api_codes.dart';

/// English translations for Common & System API response codes
final Map<String, String> commonMessagesEn = {
  CommonApiErrorCode.unauthorized: 'Session expired or invalid. Please log in again.',
  CommonApiErrorCode.forbidden: 'You do not have permission to perform this action.',
  CommonApiErrorCode.notOwnerOrAdmin: 'You do not have permission to modify this resource.',
  CommonApiErrorCode.validationFailed: 'Invalid data submitted. Please check and try again.',
  CommonApiErrorCode.invalidRequest: 'Invalid request. Please try again.',
  CommonApiErrorCode.internalServerError: 'Server error. Please try again later.',
  CommonApiErrorCode.httpInternalServerError: 'Server error. Please try again later.',
};
