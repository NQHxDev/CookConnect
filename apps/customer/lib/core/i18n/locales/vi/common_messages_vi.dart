import 'package:cookconnect/core/constants/api_codes/common_api_codes.dart';

/// Vietnamese translations for Common & System API response codes
final Map<String, String> commonMessagesVi = {
  CommonApiErrorCode.unauthorized: 'Phiên đăng nhập đã hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.',
  CommonApiErrorCode.forbidden: 'Bạn không có quyền thực hiện thao tác này.',
  CommonApiErrorCode.notOwnerOrAdmin: 'Bạn không có quyền chỉnh sửa thông tin này.',
  CommonApiErrorCode.validationFailed: 'Thông tin không hợp lệ hoặc không đúng định dạng.',
  CommonApiErrorCode.invalidRequest: 'Yêu cầu không hợp lệ. Vui lòng thử lại.',
  CommonApiErrorCode.internalServerError: 'Hệ thống đang bảo trì hoặc gặp sự cố. Vui lòng thử lại sau.',
  CommonApiErrorCode.httpInternalServerError: 'Hệ thống đang bảo trì hoặc gặp sự cố. Vui lòng thử lại sau.',
};
