import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/core/constants/api_response_codes.dart';
import 'package:cookconnect/core/i18n/api_i18n.dart';

void main() {
  setUp(() {
    ApiI18n.currentLanguage = 'vi';
  });

  group('ApiErrorCode Constants & Translation Tests', () {
    test('Translates avatar error codes correctly in Vietnamese', () {
      expect(
        ApiI18n.translate(ApiErrorCode.userFileRequired),
        'Vui lòng chọn tệp hình ảnh để tải lên.',
      );
      expect(
        ApiI18n.translate(ApiErrorCode.userInvalidFileType),
        'Định dạng ảnh không hợp lệ. Chỉ chấp nhận định dạng JPG, PNG, WebP hoặc GIF (tối đa 5MB).',
      );
      expect(
        ApiI18n.translate(ApiErrorCode.userFileTooLarge),
        'Kích thước tệp ảnh quá lớn. Vui lòng chọn ảnh nhỏ hơn 5MB.',
      );
    });

    test('Translates avatar error codes correctly in English when language is switched', () {
      ApiI18n.currentLanguage = 'en';

      expect(
        ApiI18n.translate(ApiErrorCode.userFileRequired),
        'Please select an image file to upload.',
      );
      expect(
        ApiI18n.translate(ApiErrorCode.userInvalidFileType),
        'Invalid file format. Only JPG, PNG, WebP or GIF are allowed (max 5MB).',
      );
      expect(
        ApiI18n.translate(ApiErrorCode.userFileTooLarge),
        'Image file size is too large (maximum 5MB).',
      );
    });

    test('Translates auth error codes correctly', () {
      expect(
        ApiI18n.translate(ApiErrorCode.authInvalidCredentials),
        'Email hoặc mật khẩu không chính xác.',
      );
      expect(
        ApiI18n.translate(ApiErrorCode.authOtpExpired),
        'Mã OTP đã hết hạn. Vui lòng nhấn gửi lại mã mới.',
      );
      expect(
        ApiI18n.translate(ApiErrorCode.authAccountBlocked),
        'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ hỗ trợ.',
      );
    });

    test('Translates common error codes correctly', () {
      expect(
        ApiI18n.translate(ApiErrorCode.commonUnauthorized),
        'Phiên đăng nhập đã hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.',
      );
      expect(
        ApiI18n.translate(ApiErrorCode.commonForbidden),
        'Bạn không có quyền thực hiện thao tác này.',
      );
    });
  });

  group('ApiI18n.resolveErrorMessage Tests', () {
    test('Resolves error from errorCode field', () {
      final json = {
        'success': false,
        'statusCode': 400,
        'errorCode': ApiErrorCode.userInvalidFileType,
        'message': ApiErrorCode.userInvalidFileType,
      };

      final msg = ApiI18n.resolveErrorMessage(json);
      expect(msg, 'Định dạng ảnh không hợp lệ. Chỉ chấp nhận định dạng JPG, PNG, WebP hoặc GIF (tối đa 5MB).');
    });

    test('Resolves error from message field', () {
      final json = {
        'success': false,
        'statusCode': 400,
        'message': ApiErrorCode.userFileRequired,
      };

      final msg = ApiI18n.resolveErrorMessage(json);
      expect(msg, 'Vui lòng chọn tệp hình ảnh để tải lên.');
    });

    test('Resolves validation error details list', () {
      final json = {
        'success': false,
        'statusCode': 400,
        'errorCode': ApiErrorCode.commonValidationFailed,
        'errors': [
          {'field': 'email', 'message': 'Email không hợp lệ', 'code': 'isEmail'}
        ]
      };

      final msg = ApiI18n.resolveErrorMessage(json);
      expect(msg, 'Email không hợp lệ');
    });

    test('Never leaks unknown uppercase error code key to user', () {
      final json = {
        'success': false,
        'statusCode': 500,
        'errorCode': 'UNKNOWN_CUSTOM_MODULE.SERVER_ERROR_CODE',
        'message': 'UNKNOWN_CUSTOM_MODULE.SERVER_ERROR_CODE',
      };

      final msg = ApiI18n.resolveErrorMessage(
        json,
        defaultMessage: 'Không thể xử lý yêu cầu. Vui lòng thử lại sau.',
      );
      expect(msg, 'Không thể xử lý yêu cầu. Vui lòng thử lại sau.');
      expect(msg.contains('UNKNOWN_CUSTOM_MODULE'), isFalse);
    });

    test('Preserves already human-readable Vietnamese sentences', () {
      final json = {
        'success': false,
        'statusCode': 400,
        'message': 'Đường truyền mạng không ổn định, vui lòng thử lại',
      };

      final msg = ApiI18n.resolveErrorMessage(json);
      expect(msg, 'Đường truyền mạng không ổn định, vui lòng thử lại');
    });
  });

  group('ApiI18n.resolveSuccessMessage Tests', () {
    test('Resolves success code to localized message', () {
      final json = {
        'success': true,
        'message': ApiSuccessCode.usersUploadAvatarSuccess,
      };

      final msg = ApiI18n.resolveSuccessMessage(json);
      expect(msg, 'Tải ảnh đại diện thành công.');
    });
  });
}
