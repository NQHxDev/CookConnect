import 'package:cookconnect/core/constants/api_codes/user_api_codes.dart';

/// English translations for User Module API response codes
final Map<String, String> userMessagesEn = {
  UserApiErrorCode.fileRequired: 'Please select an image file to upload.',
  UserApiErrorCode.invalidFileType: 'Invalid file format. Only JPG, PNG, WebP or GIF are allowed (max 5MB).',
  UserApiErrorCode.fileTooLarge: 'Image file size is too large (maximum 5MB).',
  UserApiErrorCode.userNotFound: 'User not found.',
  UserApiErrorCode.usernameAlreadyTaken: 'Username is already taken. Please choose another.',
  UserApiErrorCode.invalidUsernameFormat: 'Invalid username format (3-30 chars, letters, numbers, underscores).',
  UserApiErrorCode.userAlreadyExists: 'This email is already registered.',
  UserApiSuccessCode.uploadAvatarSuccess: 'Avatar uploaded successfully.',
};
