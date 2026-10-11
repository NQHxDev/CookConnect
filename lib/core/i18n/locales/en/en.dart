import 'user_messages_en.dart';
import 'auth_messages_en.dart';
import 'common_messages_en.dart';
import 'ui_messages_en.dart';

export 'user_messages_en.dart';
export 'auth_messages_en.dart';
export 'common_messages_en.dart';
export 'ui_messages_en.dart';

/// Combined English translations across all modules
final Map<String, String> enTranslations = {
  ...userMessagesEn,
  ...authMessagesEn,
  ...commonMessagesEn,
  ...uiMessagesEn,
};
