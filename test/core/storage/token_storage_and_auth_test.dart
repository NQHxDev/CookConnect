import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/core/storage/token_storage_service.dart';

String createMockJwt({required int expSeconds}) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
  final payload = base64Url.encode(utf8.encode('{"sub":"usr-123","exp":$expSeconds}'));
  final signature = base64Url.encode(utf8.encode('signature'));
  return '$header.$payload.$signature';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryTokenStorageService storage;
  late AuthService authService;

  setUp(() {
    storage = InMemoryTokenStorageService();
    authService = AuthService.instance;
    authService.configure(storage: storage, apiService: ApiService());
    authService.logout(callServer: false);
  });

  tearDown(() {
    authService.logout(callServer: false);
  });

  group('TokenStorageService Tests', () {
    test(
      'Saves, retrieves, and clears tokens and user profile in storage',
      () async {
        final tokens = AuthTokens(
          accessToken: 'saved-access-token',
          refreshToken: 'saved-refresh-token',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );
        final user = AuthUser(
          id: 'usr-100',
          email: 'chef@cookconnect.app',
          fullName: 'Chef Test',
          username: 'cheftest',
        );

        await storage.saveTokens(tokens);
        await storage.saveUser(user);

        final retrievedTokens = await storage.getTokens();
        final retrievedUser = await storage.getUser();

        expect(retrievedTokens?.accessToken, 'saved-access-token');
        expect(retrievedTokens?.refreshToken, 'saved-refresh-token');
        expect(retrievedTokens?.expiresIn, 3600);

        expect(retrievedUser?.id, 'usr-100');
        expect(retrievedUser?.email, 'chef@cookconnect.app');
        expect(retrievedUser?.fullName, 'Chef Test');
        expect(retrievedUser?.username, 'cheftest');

        await storage.clearAuth();
        expect(await storage.getTokens(), isNull);
        expect(await storage.getUser(), isNull);
      },
    );
  });

  group('Token Expiration & JWT Validation Tests', () {
    test('Correctly identifies expired JWT access token', () {
      final pastTimestamp = (DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch / 1000).round();
      final expiredJwt = createMockJwt(expSeconds: pastTimestamp);

      final tokens = AuthTokens(
        accessToken: expiredJwt,
        refreshToken: 'valid-refresh-token',
      );

      expect(tokens.isAccessTokenExpired(), isTrue);
    });

    test('Correctly identifies valid (non-expired) JWT access token', () {
      final futureTimestamp = (DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch / 1000).round();
      final validJwt = createMockJwt(expSeconds: futureTimestamp);

      final tokens = AuthTokens(
        accessToken: validJwt,
        refreshToken: 'valid-refresh-token',
      );

      expect(tokens.isAccessTokenExpired(), isFalse);
    });

    test('Identifies token expired via createdAt + expiresIn duration fallback', () {
      final oldTokens = AuthTokens(
        accessToken: 'opaque-access-token',
        refreshToken: 'opaque-refresh-token',
        expiresIn: 60, // 60 seconds
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(oldTokens.isAccessTokenExpired(), isTrue);
    });
  });

  group('AuthService Auto-Restore & Persistence Tests', () {
    test('setSession persists tokens and user into secure storage', () async {
      final user = AuthUser(
        id: 'usr-200',
        email: 'chef200@cookconnect.app',
        fullName: 'Chef Two',
      );
      final tokens = AuthTokens(
        accessToken: 'access-200',
        refreshToken: 'refresh-200',
      );

      authService.setSession(user: user, tokens: tokens);

      expect(authService.isLoggedIn, isTrue);
      expect(authService.currentUser?.fullName, 'Chef Two');

      final storedTokens = await storage.getTokens();
      final storedUser = await storage.getUser();

      expect(storedTokens?.accessToken, 'access-200');
      expect(storedUser?.email, 'chef200@cookconnect.app');
    });

    test(
      'init restores session when valid token exists and updates profile from server',
      () async {
        final initialTokens = AuthTokens(
          accessToken: 'valid-access-token',
          refreshToken: 'valid-refresh-token',
        );
        final cachedUser = AuthUser(
          id: 'usr-cached',
          email: 'cached@cookconnect.app',
          fullName: 'Cached Name',
          username: 'cached_user',
        );

        await storage.saveTokens(initialTokens);
        await storage.saveUser(cachedUser);

        final mockClient = MockClient((request) async {
          if (request.url.path == '/api/v1/auth/me') {
            return http.Response(
              '{"success":true,"statusCode":200,"data":{"id":"usr-cached","sub":"usr-cached","email":"cached@cookconnect.app","roles":["USER"]}}',
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          if (request.url.path == '/api/v1/users/usr-cached') {
            return http.Response(
              '{"success":true,"statusCode":200,"data":{"id":"usr-cached","username":"server_username","profile":{"displayName":"Updated Server Name","bio":"Server Bio","gender":"MALE"}}}',
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          return http.Response('{"success":false}', 404);
        });

        authService.configure(
          storage: storage,
          apiService: ApiService(client: mockClient),
        );

        await authService.init();

        expect(authService.isLoggedIn, isTrue);
        expect(authService.currentUser?.fullName, 'Updated Server Name');
        expect(authService.currentUser?.username, 'server_username');
        expect(authService.currentUser?.bio, 'Server Bio');
        final updatedStorageUser = await storage.getUser();
        expect(updatedStorageUser?.fullName, 'Updated Server Name');
      },
    );

    test(
      'init preserves cached displayName and username if server returns empty/null',
      () async {
        final initialTokens = AuthTokens(
          accessToken: 'valid-access-token',
          refreshToken: 'valid-refresh-token',
        );
        final cachedUser = AuthUser(
          id: 'usr-cached-2',
          email: 'chef_linh@example.com',
          fullName: 'Chef Linh Đan',
          username: 'linhdan_cook',
          bio: 'Yêu nấu ăn',
        );

        await storage.saveTokens(initialTokens);
        await storage.saveUser(cachedUser);

        final mockClient = MockClient((request) async {
          if (request.url.path == '/api/v1/auth/me') {
            // Auth /me returns bare JWT payload
            return http.Response(
              '{"success":true,"statusCode":200,"data":{"sub":"usr-cached-2","email":"chef_linh@example.com","roles":["USER"]}}',
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          return http.Response('{"success":false}', 404);
        });

        authService.configure(
          storage: storage,
          apiService: ApiService(client: mockClient),
        );

        await authService.init();

        expect(authService.isLoggedIn, isTrue);
        // Ensure fullName and username did not revert to 'chef_linh'
        expect(authService.currentUser?.fullName, 'Chef Linh Đan');
        expect(authService.currentUser?.username, 'linhdan_cook');
        expect(authService.currentUser?.bio, 'Yêu nấu ăn');
      },
    );

    test(
      'init uses refresh token when access token is expired (401) and restores session',
      () async {
        final expiredTokens = AuthTokens(
          accessToken: 'expired-access-token',
          refreshToken: 'valid-refresh-token',
        );
        final cachedUser = AuthUser(
          id: 'usr-300',
          email: 'user300@cookconnect.app',
          fullName: 'User 300',
        );

        await storage.saveTokens(expiredTokens);
        await storage.saveUser(cachedUser);

        final mockClient = MockClient((request) async {
          if (request.url.path == '/api/v1/auth/me') {
            if (request.headers['Authorization'] ==
                'Bearer expired-access-token') {
              return http.Response('{"success":false,"statusCode":401}', 401);
            }
            if (request.headers['Authorization'] == 'Bearer new-access-token') {
              return http.Response(
                '{"success":true,"statusCode":200,"data":{"id":"usr-300","email":"user300@cookconnect.app","fullName":"User 300 Fresh","roles":["USER"]}}',
                200,
                headers: {'content-type': 'application/json; charset=utf-8'},
              );
            }
          }
          if (request.url.path == '/api/v1/auth/refresh') {
            return http.Response(
              '{"success":true,"statusCode":200,"data":{"tokens":{"accessToken":"new-access-token","refreshToken":"new-refresh-token","tokenType":"Bearer","expiresIn":900}}}',
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          return http.Response('{"success":false}', 404);
        });

        authService.configure(
          storage: storage,
          apiService: ApiService(client: mockClient),
        );

        await authService.init();

        expect(authService.isLoggedIn, isTrue);
        expect(authService.tokens?.accessToken, 'new-access-token');
        expect(authService.tokens?.refreshToken, 'new-refresh-token');
        expect(authService.currentUser?.fullName, 'User 300 Fresh');

        final savedTokens = await storage.getTokens();
        expect(savedTokens?.accessToken, 'new-access-token');
      },
    );

    test('init logs out and kicks user out when refresh token is invalid/expired (401)', () async {
      final invalidTokens = AuthTokens(
        accessToken: 'expired-access-token',
        refreshToken: 'invalid-refresh-token',
      );
      final cachedUser = AuthUser(
        id: 'usr-400',
        email: 'user400@cookconnect.app',
        fullName: 'User 400',
      );

      await storage.saveTokens(invalidTokens);
      await storage.saveUser(cachedUser);

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/me') {
          return http.Response('{"success":false,"statusCode":401}', 401);
        }
        if (request.url.path == '/api/v1/auth/refresh') {
          return http.Response('{"success":false,"statusCode":401}', 401);
        }
        return http.Response('{"success":false}', 404);
      });

      authService.configure(
        storage: storage,
        apiService: ApiService(client: mockClient),
      );

      await authService.init();

      expect(authService.isLoggedIn, isFalse);
      expect(authService.currentUser, isNull);
      expect(await storage.getTokens(), isNull);
    });

    test('init kicks user out when refresh token fails with 400 Bad Request or server rejection', () async {
      final invalidTokens = AuthTokens(
        accessToken: 'expired-access-token',
        refreshToken: 'malformed-refresh-token',
      );
      final cachedUser = AuthUser(
        id: 'usr-401',
        email: 'user401@cookconnect.app',
        fullName: 'User 401',
      );

      await storage.saveTokens(invalidTokens);
      await storage.saveUser(cachedUser);

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/me') {
          return http.Response('{"success":false,"statusCode":401}', 401);
        }
        if (request.url.path == '/api/v1/auth/refresh') {
          return http.Response('{"success":false,"statusCode":400,"message":"Invalid token"}', 400);
        }
        return http.Response('{"success":false}', 404);
      });

      authService.configure(
        storage: storage,
        apiService: ApiService(client: mockClient),
      );

      await authService.init();

      expect(authService.isLoggedIn, isFalse);
      expect(authService.currentUser, isNull);
      expect(await storage.getTokens(), isNull);
    });

    test('init immediately kicks user out without network call when both tokens are expired locally', () async {
      final pastTimestamp = (DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch / 1000).round();
      final expiredAccessToken = createMockJwt(expSeconds: pastTimestamp);
      final expiredRefreshToken = createMockJwt(expSeconds: pastTimestamp);

      final tokens = AuthTokens(
        accessToken: expiredAccessToken,
        refreshToken: expiredRefreshToken,
      );
      final cachedUser = AuthUser(
        id: 'usr-expired',
        email: 'expired@cookconnect.app',
        fullName: 'Expired User',
      );

      await storage.saveTokens(tokens);
      await storage.saveUser(cachedUser);

      int networkCalls = 0;
      final mockClient = MockClient((request) async {
        networkCalls++;
        return http.Response('{"success":false}', 404);
      });

      authService.configure(
        storage: storage,
        apiService: ApiService(client: mockClient),
      );

      await authService.init();

      expect(authService.isLoggedIn, isFalse);
      expect(authService.currentUser, isNull);
      expect(await storage.getTokens(), isNull);
      expect(networkCalls, 0); // No useless network calls when both tokens expired locally
    });

    test(
      'init preserves cached session when offline or network error occurs (statusCode 0)',
      () async {
        final initialTokens = AuthTokens(
          accessToken: 'offline-access-token',
          refreshToken: 'offline-refresh-token',
        );
        final cachedUser = AuthUser(
          id: 'usr-offline',
          email: 'offline@cookconnect.app',
          fullName: 'Offline Chef',
        );

        await storage.saveTokens(initialTokens);
        await storage.saveUser(cachedUser);

        final mockClient = MockClient((request) async {
          throw Exception('SocketException: Failed host lookup');
        });

        authService.configure(
          storage: storage,
          apiService: ApiService(client: mockClient),
        );

        await authService.init();

        expect(authService.isLoggedIn, isTrue);
        expect(authService.currentUser?.fullName, 'Offline Chef');
        expect(authService.tokens?.accessToken, 'offline-access-token');
      },
    );

    test('logout clears both memory and secure storage', () async {
      final user = AuthUser(
        id: 'usr-500',
        email: 'user500@cookconnect.app',
        fullName: 'Chef Five',
      );
      final tokens = AuthTokens(
        accessToken: 'access-500',
        refreshToken: 'refresh-500',
      );

      authService.setSession(user: user, tokens: tokens);
      expect(authService.isLoggedIn, isTrue);

      authService.logout(callServer: false);

      expect(authService.isLoggedIn, isFalse);
      expect(authService.currentUser, isNull);
      expect(authService.tokens, isNull);
      expect(await storage.getTokens(), isNull);
      expect(await storage.getUser(), isNull);
    });

    test('Concurrent refresh calls deduplicate into single network request', () async {
      int refreshCallCount = 0;
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/refresh') {
          refreshCallCount++;
          await Future.delayed(const Duration(milliseconds: 50));
          return http.Response(
            '{"success":true,"statusCode":200,"data":{"tokens":{"accessToken":"refreshed-access","refreshToken":"refreshed-refresh","tokenType":"Bearer","expiresIn":900}}}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('{"success":false}', 404);
      });

      authService.configure(
        storage: storage,
        apiService: ApiService(client: mockClient),
      );

      authService.setSession(
        user: AuthUser(id: 'usr-dup', email: 'dup@test.com', fullName: 'Dup User'),
        tokens: AuthTokens(accessToken: 'old-access', refreshToken: 'old-refresh'),
      );

      final futures = await Future.wait([
        authService.refreshAccessToken(),
        authService.refreshAccessToken(),
        authService.refreshAccessToken(),
      ]);

      expect(refreshCallCount, 1); // Only 1 network request made despite 3 concurrent calls
      expect(futures[0], 'refreshed-access');
      expect(futures[1], 'refreshed-access');
      expect(futures[2], 'refreshed-access');
      expect(authService.tokens?.accessToken, 'refreshed-access');
    });
  });
}
