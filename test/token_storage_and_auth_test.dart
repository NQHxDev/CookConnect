import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cookconnect/services/api_service.dart';
import 'package:cookconnect/services/auth_service.dart';
import 'package:cookconnect/services/token_storage_service.dart';

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
      'init restores session when valid token exists and updates profile',
      () async {
        final initialTokens = AuthTokens(
          accessToken: 'valid-access-token',
          refreshToken: 'valid-refresh-token',
        );
        final cachedUser = AuthUser(
          id: 'usr-cached',
          email: 'cached@cookconnect.app',
          fullName: 'Cached Name',
        );

        await storage.saveTokens(initialTokens);
        await storage.saveUser(cachedUser);

        final mockClient = MockClient((request) async {
          if (request.url.path == '/api/v1/auth/me') {
            return http.Response(
              '{"success":true,"statusCode":200,"data":{"id":"usr-cached","email":"cached@cookconnect.app","fullName":"Updated Server Name","roles":["USER"]}}',
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
        final updatedStorageUser = await storage.getUser();
        expect(updatedStorageUser?.fullName, 'Updated Server Name');
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

    test('init logs out when refresh token is invalid/expired (401)', () async {
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
  });
}
