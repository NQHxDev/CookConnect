/// Server API Error & Response Codes for User Module
class UserApiErrorCode {
  UserApiErrorCode._();

  static const String fileRequired = 'USER.FILE_REQUIRED';
  static const String invalidFileType = 'USER.INVALID_FILE_TYPE';
  static const String fileTooLarge = 'USER.FILE_TOO_LARGE';
  static const String userNotFound = 'USER.USER_NOT_FOUND';
  static const String usernameAlreadyTaken = 'USER.USERNAME_ALREADY_TAKEN';
  static const String usernameChangeCooldown = 'USER.USERNAME_CHANGE_COOLDOWN';
  static const String invalidUsernameFormat = 'USER.INVALID_USERNAME_FORMAT';
  static const String userAlreadyExists = 'USER.USER_ALREADY_EXISTS';
}

class UserApiSuccessCode {
  UserApiSuccessCode._();

  static const String uploadAvatarSuccess = 'USERS.UPLOAD_AVATAR_SUCCESS';
}
