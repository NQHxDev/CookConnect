import 'package:cookconnect/core/constants/api_codes/user_api_codes.dart';

/// Vietnamese translations for User Module API response codes
final Map<String, String> userMessagesVi = {
  UserApiErrorCode.fileRequired: 'Vui lòng chọn tệp hình ảnh để tải lên.',
  UserApiErrorCode.invalidFileType: 'Định dạng ảnh không hợp lệ. Chỉ chấp nhận định dạng JPG, PNG, WebP hoặc GIF (tối đa 5MB).',
  UserApiErrorCode.fileTooLarge: 'Kích thước tệp ảnh quá lớn. Vui lòng chọn ảnh nhỏ hơn 5MB.',
  UserApiErrorCode.userNotFound: 'Không tìm thấy thông tin người dùng.',
  UserApiErrorCode.usernameAlreadyTaken: 'Tên người dùng đã được sử dụng. Vui lòng chọn tên khác.',
  UserApiErrorCode.usernameChangeCooldown: 'Bạn chỉ có thể đổi tên người dùng sau 30 ngày kể từ lần đổi gần nhất.',
  UserApiErrorCode.invalidUsernameFormat: 'Tên người dùng không hợp lệ (từ 3-30 ký tự, chỉ gồm chữ cái, số và dấu gạch dưới).',
  UserApiErrorCode.userAlreadyExists: 'Email đã được đăng ký trong hệ thống',
  UserApiSuccessCode.uploadAvatarSuccess: 'Tải ảnh đại diện thành công.',
};
