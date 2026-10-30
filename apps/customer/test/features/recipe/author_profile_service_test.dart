import 'package:flutter_test/flutter_test.dart';
import 'package:cookconnect/features/auth/data/models/auth_tokens.dart';
import 'package:cookconnect/features/auth/data/models/auth_user.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/recipe/data/services/author_profile_service.dart';

void main() {
  group('AuthorProfile Model', () {
    test('formats handle from username correctly', () {
      const profile = AuthorProfile(
        userId: 'u1',
        displayName: 'Nguyễn Văn A',
        username: 'nguyenvana',
      );
      expect(profile.handle, '@nguyenvana');
    });

    test('generates handle from displayName when username is null or empty', () {
      const profile = AuthorProfile(
        userId: 'u2',
        displayName: 'Nguyễn Quang Hưng',
      );
      expect(profile.handle, '@nguyen_quang_hung');
    });

    test('falls back to @daubep when both username and displayName are empty', () {
      const profile = AuthorProfile(
        userId: 'u3',
        displayName: '',
        username: '',
      );
      expect(profile.handle, '@daubep');
    });
  });

  group('AuthorProfileService', () {
    final dummyTokens = AuthTokens(
      accessToken: 'dummy-access-token',
      refreshToken: 'dummy-refresh-token',
    );

    setUp(() {
      AuthorProfileService.instance.clear();
    });

    tearDown(() {
      AuthService.instance.logout(callServer: false);
    });

    test('setCached and getCached work synchronously', () {
      const profile = AuthorProfile(
        userId: 'u100',
        displayName: 'Chef Test',
        username: 'cheftest',
      );

      AuthorProfileService.instance.setCached('u100', profile);
      final retrieved = AuthorProfileService.instance.getCached('u100');

      expect(retrieved, isNotNull);
      expect(retrieved!.displayName, 'Chef Test');
      expect(retrieved.username, 'cheftest');
    });

    test('resolves current user immediately when post.userId matches accountId', () async {
      final mockCurrentUser = AuthUser(
        id: 'user-pk-123',
        userId: 'user-pk-123',
        accountId: 'acc-pk-456',
        userProfileId: 'prof-pk-789',
        email: 'test@cookconnect.com',
        fullName: 'Nguyễn Quang Hưng',
        username: 'anhjkrr7',
      );

      AuthService.instance.setSession(
        user: mockCurrentUser,
        tokens: dummyTokens,
      );

      final profile = await AuthorProfileService.instance.resolveAuthor('acc-pk-456');

      expect(profile, isNotNull);
      expect(profile!.username, 'anhjkrr7');
      expect(profile.displayName, 'Nguyễn Quang Hưng');
      expect(profile.handle, '@anhjkrr7');
    });

    test('resolves current user immediately when post.userId matches userId or userProfileId', () async {
      final mockCurrentUser = AuthUser(
        id: 'user-pk-123',
        userId: 'user-pk-123',
        accountId: 'acc-pk-456',
        userProfileId: 'prof-pk-789',
        email: 'test@cookconnect.com',
        fullName: 'Nguyễn Quang Hưng',
        username: 'anhjkrr7',
      );

      AuthService.instance.setSession(
        user: mockCurrentUser,
        tokens: dummyTokens,
      );

      final profileFromUserPk = await AuthorProfileService.instance.resolveAuthor('user-pk-123');
      expect(profileFromUserPk, isNotNull);
      expect(profileFromUserPk!.handle, '@anhjkrr7');

      final profileFromProfilePk = await AuthorProfileService.instance.resolveAuthor('prof-pk-789');
      expect(profileFromProfilePk, isNotNull);
      expect(profileFromProfilePk!.handle, '@anhjkrr7');
    });
  });
}
