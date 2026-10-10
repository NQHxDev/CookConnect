import 'user_messages_vi.dart';
import 'auth_messages_vi.dart';
import 'common_messages_vi.dart';

export 'user_messages_vi.dart';
export 'auth_messages_vi.dart';
export 'common_messages_vi.dart';

/// Combined Vietnamese translations across all modules
final Map<String, String> viTranslations = {
  ...userMessagesVi,
  ...authMessagesVi,
  ...commonMessagesVi,
};
