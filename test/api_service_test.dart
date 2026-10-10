import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cookconnect/config/api_config.dart';
import 'package:cookconnect/services/api_service.dart';

void main() {
  tearDown(() {
    ApiService.tokenRefreshHandler = null;
    ApiService.sessionExpiredHandler = null;
  });

  group('ApiConfig Tests', () {
    test('Default configuration points to LAN IP 192.168.1.162:8080', () {
      expect(ApiConfig.baseUrl, 'http://192.168.1.162:8080');
      expect(ApiConfig.apiBaseUrl, 'http://192.168.1.162:8080/api/v1');
      expect(ApiConfig.healthUrl, 'http://192.168.1.162:8080/api/v1/health');
      expect(
        ApiConfig.sendOtpUrl,
        'http://192.168.1.162:8080/api/v1/auth/register/send-otp',
      );
      expect(
        ApiConfig.verifyOtpUrl,
        'http://192.168.1.162:8080/api/v1/auth/register/verify-otp',
      );
      expect(
        ApiConfig.registerUrl,
        'http://192.168.1.162:8080/api/v1/auth/register',
      );
      expect(ApiConfig.loginUrl, 'http://192.168.1.162:8080/api/v1/auth/login');
      expect(
        ApiConfig.logoutUrl,
        'http://192.168.1.162:8080/api/v1/auth/logout',
      );
      expect(
        ApiConfig.refreshUrl,
        'http://192.168.1.162:8080/api/v1/auth/refresh',
      );
      expect(ApiConfig.meUrl, 'http://192.168.1.162:8080/api/v1/auth/me');
      expect(ApiConfig.userMeUrl, 'http://192.168.1.162:8080/api/v1/users/me');
    });
  });

  group('AuthUser.fromJson Parsing Tests', () {
    test('Correctly parses nested profile and stats objects from backend User entity', () {
      final json = {
        'id': 'user-entity-1',
        'userId': 'auth-sub-1',
        'username': 'chef_dan',
        'email': 'dan@cookconnect.app',
        'status': 'ACTIVE',
        'profile': {
          'id': 'profile-1',
          'userId': 'user-entity-1',
          'displayName': 'Chef Linh Đan',
          'bio': 'Yêu nấu ăn và làm bánh',
          'avatar': 'https://example.com/avatar.jpg',
          'gender': 'FEMALE',
          'dateOfBirth': '1998-08-15',
        },
        'stats': {
          'followersCount': 1200,
          'followingCount': 85,
          'postsCount': 24,
          'likeCount': 5000,
        },
      };

      final user = AuthUser.fromJson(json);

      expect(user.id, 'user-entity-1');
      expect(user.fullName, 'Chef Linh Đan');
      expect(user.username, 'chef_dan');
      expect(user.bio, 'Yêu nấu ăn và làm bánh');
      expect(user.gender, 'FEMALE');
      expect(user.dateOfBirth, '1998-08-15');
      expect(user.avatar, 'https://example.com/avatar.jpg');
      expect(user.followerCount, 1200);
      expect(user.followingCount, 85);
      expect(user.videoCount, 24);
      expect(user.likeCount, 5000);
    });

    test('Falls back properly when profile fields are missing', () {
      final json = {
        'id': 'auth-sub-2',
        'email': 'simpleuser@example.com',
        'roles': ['USER'],
      };

      final user = AuthUser.fromJson(json);

      expect(user.id, 'auth-sub-2');
      expect(user.email, 'simpleuser@example.com');
      expect(user.fullName, 'simpleuser');
      expect(user.username, isNull);
      expect(user.bio, isNull);
      expect(user.followerCount, 0);
    });
  });

  group('ApiService Check Username Tests', () {
    test('checkUsername returns true when username is available', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/users/check-username');
        expect(request.url.queryParameters['username'], 'new_chef_user');
        return http.Response(
          '{"success":true,"statusCode":200,"data":{"available":true,"username":"new_chef_user"}}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final isAvailable = await service.checkUsername('new_chef_user');
      expect(isAvailable, isTrue);
    });

    test('checkUsername returns false when username is taken', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/users/check-username');
        expect(request.url.queryParameters['username'], 'taken_user');
        return http.Response(
          '{"success":true,"statusCode":200,"data":{"available":false,"username":"taken_user"}}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final isAvailable = await service.checkUsername('taken_user');
      expect(isAvailable, isFalse);
    });
  });

  group('ApiService Health Check Tests', () {
    test('checkHealth returns success when server responds 200 OK', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/health') {
          return http.Response(
            '{"success":true,"statusCode":200,"message":"HEALTH_CHECK_SUCCESS","data":{"status":"ok","uptime":3200}}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = ApiService(client: mockClient);
      final result = await service.checkHealth();

      expect(result.isHealthy, isTrue);
      expect(result.statusCode, 200);
      expect(result.message, 'HEALTH_CHECK_SUCCESS');
      expect(result.data?['status'], 'ok');
    });

    test('checkHealth handles network error gracefully', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Connection refused');
      });

      final service = ApiService(client: mockClient);
      final result = await service.checkHealth();

      expect(result.isHealthy, isFalse);
      expect(result.statusCode, 0);
      expect(result.error, contains('Connection refused'));
    });
  });

  group('ApiService OTP Tests', () {
    test('sendOtp returns success when server responds 200 OK', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/register/send-otp');
        return http.Response(
          '{"success":true,"statusCode":200,"message":"AUTH.OTP_SENT"}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.sendOtp(email: 'chef.otp@example.com');

      expect(result.isSuccess, isTrue);
      expect(result.statusCode, 200);
    });

    test('verifyOtp returns success with verificationToken', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/register/verify-otp');
        return http.Response(
          '''{
            "success": true,
            "statusCode": 200,
            "message": "AUTH.OTP_VERIFIED",
            "data": {
              "verificationToken": "valid-token-123"
            }
          }''',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.verifyOtp(
        email: 'chef.otp@example.com',
        otp: '123456',
      );

      expect(result.isSuccess, isTrue);
      expect(result.statusCode, 200);
      expect(result.verificationToken, 'valid-token-123');
    });

    test('verifyOtp returns error message on invalid OTP', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"success":false,"statusCode":400,"message":"AUTH.INVALID_OTP","errorCode":"AUTH.INVALID_OTP"}',
          400,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.verifyOtp(
        email: 'chef.otp@example.com',
        otp: '000000',
      );

      expect(result.isSuccess, isFalse);
      expect(result.statusCode, 400);
      expect(result.error, contains('không chính xác'));
    });
  });

  group('ApiService Register Tests', () {
    test('register returns success when server responds 201 Created', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/register');
        return http.Response(
          '''{
            "success": true,
            "statusCode": 201,
            "message": "AUTH.REGISTER_SUCCESS",
            "data": {
              "user": {
                "id": "user-uuid-123",
                "email": "chef.new@example.com",
                "fullName": "Chef New",
                "roles": ["USER"],
                "status": "ACTIVE",
                "isEmailVerified": false
              },
              "tokens": {
                "accessToken": "access-token-123",
                "refreshToken": "refresh-token-123",
                "tokenType": "Bearer",
                "expiresIn": 900
              }
            }
          }''',
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.register(
        email: 'chef.new@example.com',
        password: 'password123',
        fullName: 'Chef New',
      );

      expect(result.isSuccess, isTrue);
      expect(result.statusCode, 201);
      expect(result.user?.id, 'user-uuid-123');
      expect(result.user?.email, 'chef.new@example.com');
      expect(result.user?.fullName, 'Chef New');
      expect(result.tokens?.accessToken, 'access-token-123');
      expect(result.tokens?.refreshToken, 'refresh-token-123');
    });

    test('register returns error message when user already exists', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"success":false,"statusCode":409,"message":"AUTH.USER_ALREADY_EXISTS","errorCode":"AUTH.USER_ALREADY_EXISTS"}',
          409,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.register(
        email: 'existing@example.com',
        password: 'password123',
        fullName: 'Existing User',
      );

      expect(result.isSuccess, isFalse);
      expect(result.statusCode, 409);
      expect(result.error, contains('đã được đăng ký'));
    });
  });

  group('ApiService Login Tests', () {
    test('login returns success and enriches profile from user microservice', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/login') {
          return http.Response(
            '''{
              "success": true,
              "statusCode": 200,
              "message": "AUTH.LOGIN_SUCCESS",
              "data": {
                "user": {
                  "id": "user-uuid-123",
                  "email": "chef.linh@example.com",
                  "roles": ["USER"],
                  "status": "ACTIVE"
                },
                "tokens": {
                  "accessToken": "access-token-abc",
                  "refreshToken": "refresh-token-abc",
                  "tokenType": "Bearer",
                  "expiresIn": 900
                }
              }
            }''',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (request.url.path == '/api/v1/users/me') {
          return http.Response(
            '''{
              "success": true,
              "statusCode": 200,
              "data": {
                "id": "user-uuid-123",
                "username": "linhdan_cook",
                "profile": {
                  "displayName": "Chef Linh Đan",
                  "gender": "FEMALE",
                  "bio": "Yêu ẩm thực Việt"
                },
                "stats": {
                  "followersCount": 2450,
                  "postsCount": 18
                }
              }
            }''',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('{"success":false}', 404);
      });

      final service = ApiService(client: mockClient);
      final result = await service.login(
        email: 'chef.linh@example.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.statusCode, 200);
      expect(result.user?.email, 'chef.linh@example.com');
      expect(result.user?.fullName, 'Chef Linh Đan');
      expect(result.user?.username, 'linhdan_cook');
      expect(result.user?.gender, 'FEMALE');
      expect(result.user?.followerCount, 2450);
      expect(result.user?.videoCount, 18);
      expect(result.tokens?.accessToken, 'access-token-abc');
    });

    test('login returns error when credentials invalid', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"success":false,"statusCode":401,"message":"AUTH.INVALID_CREDENTIALS","errorCode":"AUTH.INVALID_CREDENTIALS"}',
          401,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.login(
        email: 'chef.linh@example.com',
        password: 'wrongpassword',
      );

      expect(result.isSuccess, isFalse);
      expect(result.statusCode, 401);
      expect(result.error, contains('không chính xác'));
    });
  });

  group('ApiService Profile & Session Tests', () {
    test('getProfile returns complete user data combining auth and user microservice', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/me') {
          return http.Response(
            '{"success":true,"statusCode":200,"data":{"id":"01a0","sub":"01a0","email":"test@test.com","roles":["USER"]}}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (request.url.path == '/api/v1/users/me' ||
            request.url.path == '/api/v1/users/01a0') {
          return http.Response(
            '''{
              "success": true,
              "statusCode": 200,
              "data": {
                "id": "01a0",
                "username": "chef_master",
                "profile": {
                  "displayName": "Chef Master",
                  "bio": "Bio master",
                  "gender": "MALE"
                }
              }
            }''',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('{"success":false}', 404);
      });

      final service = ApiService(client: mockClient);
      final result = await service.getProfile('valid-jwt-token');

      expect(result.isSuccess, isTrue);
      expect(result.user?.fullName, 'Chef Master');
      expect(result.user?.username, 'chef_master');
      expect(result.user?.bio, 'Bio master');
      expect(result.user?.gender, 'MALE');
    });

    test('getMyUserProfile fetches current user profile from /api/v1/users/me', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/users/me');
        return http.Response(
          '''{
            "success": true,
            "statusCode": 200,
            "data": {
              "id": "me-id",
              "username": "me_user",
              "profile": {
                "displayName": "Me User",
                "bio": "My self bio"
              }
            }
          }''',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.getMyUserProfile('valid-token');

      expect(result.isSuccess, isTrue);
      expect(result.user?.fullName, 'Me User');
      expect(result.user?.username, 'me_user');
      expect(result.user?.bio, 'My self bio');
    });

    test('getUserDetails fetches user by ID successfully', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/users/user-123');
        return http.Response(
          '''{
            "success": true,
            "statusCode": 200,
            "data": {
              "id": "user-123",
              "username": "linh_dan",
              "profile": {
                "displayName": "Linh Đan",
                "bio": "Đầu bếp nghiệp dư"
              }
            }
          }''',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.getUserDetails(
        accessToken: 'token-abc',
        userId: 'user-123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.user?.fullName, 'Linh Đan');
      expect(result.user?.username, 'linh_dan');
      expect(result.user?.bio, 'Đầu bếp nghiệp dư');
    });

    test('updateUserProfile updates user profile successfully', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/api/v1/users/me');
        return http.Response(
          '''{
            "success": true,
            "statusCode": 200,
            "data": {
              "id": "01a0",
              "email": "test@test.com",
              "username": "chefup",
              "profile": {
                "displayName": "Chef Updated",
                "gender": "MALE",
                "dateOfBirth": "1995-05-10",
                "bio": "My new bio"
              }
            }
          }''',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.updateUserProfile(
        accessToken: 'valid-jwt-token',
        displayName: 'Chef Updated',
        username: 'chefup',
        gender: 'MALE',
        dateOfBirth: '1995-05-10',
        bio: 'My new bio',
      );

      expect(result.isSuccess, isTrue);
      expect(result.user?.fullName, 'Chef Updated');
      expect(result.user?.username, 'chefup');
      expect(result.user?.gender, 'MALE');
      expect(result.user?.bio, 'My new bio');
    });

    test('uploadAvatar uploads image bytes via multipart request', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/users/me/avatar');
        expect(request.headers['Authorization'], 'Bearer valid-jwt-token');

        return http.Response(
          '''{
            "success": true,
            "statusCode": 200,
            "message": "USERS.UPLOAD_AVATAR_SUCCESS",
            "data": {
              "avatarUrl": "https://res.cloudinary.com/demo/image/upload/avatar_123.jpg",
              "user": {
                "id": "01a0",
                "email": "test@test.com",
                "avatar": "https://res.cloudinary.com/demo/image/upload/avatar_123.jpg"
              }
            }
          }''',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.uploadAvatar(
        accessToken: 'valid-jwt-token',
        fileBytes: [1, 2, 3, 4],
        filename: 'avatar.png',
      );

      expect(result.isSuccess, isTrue);
      expect(result.user?.avatar, 'https://res.cloudinary.com/demo/image/upload/avatar_123.jpg');
    });

    test('uploadAvatar correctly translates USER.INVALID_FILE_TYPE to friendly message', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '''{
            "success": false,
            "statusCode": 400,
            "errorCode": "USER.INVALID_FILE_TYPE",
            "message": "USER.INVALID_FILE_TYPE",
            "error": "BAD_REQUEST",
            "params": {"allowed": "image/jpeg, image/png, image/webp, image/gif"}
          }''',
          400,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.uploadAvatar(
        accessToken: 'valid-jwt-token',
        fileBytes: [1, 2, 3],
        filename: 'doc.pdf',
      );

      expect(result.isSuccess, isFalse);
      expect(result.error, 'Định dạng ảnh không hợp lệ!');
    });

    test('uploadAvatar correctly translates USER.FILE_REQUIRED to friendly message', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '''{
            "success": false,
            "statusCode": 400,
            "errorCode": "USER.FILE_REQUIRED",
            "message": "USER.FILE_REQUIRED",
            "error": "BAD_REQUEST"
          }''',
          400,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.uploadAvatar(
        accessToken: 'valid-jwt-token',
        fileBytes: [],
        filename: '',
      );

      expect(result.isSuccess, isFalse);
      expect(result.error, 'Vui lòng chọn tệp hình ảnh để tải lên.');
    });

    test('uploadAvatar correctly handles 401 Unauthorized and USER.USER_NOT_FOUND', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '''{
            "success": false,
            "statusCode": 404,
            "errorCode": "USER.USER_NOT_FOUND",
            "message": "USER.USER_NOT_FOUND",
            "error": "NOT_FOUND"
          }''',
          404,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.uploadAvatar(
        accessToken: 'valid-jwt-token',
        fileBytes: [1, 2],
        filename: 'avatar.jpg',
      );

      expect(result.isSuccess, isFalse);
      expect(result.error, 'Không tìm thấy thông tin người dùng.');
    });

    test('logout calls logout endpoint successfully', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/logout');
        return http.Response('{"success":true,"statusCode":200}', 200);
      });

      final service = ApiService(client: mockClient);
      final success = await service.logout('valid-jwt-token');
      expect(success, isTrue);
    });

    test('refreshToken refreshes token successfully', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/refresh');
        return http.Response(
          '{"success":true,"statusCode":200,"data":{"tokens":{"accessToken":"new-access","refreshToken":"new-refresh","tokenType":"Bearer","expiresIn":900}}}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.refreshToken('old-refresh');
      expect(result.isSuccess, isTrue);
      expect(result.tokens?.accessToken, 'new-access');
    });

    test('updateUserProfile automatically retries with refreshed token when receiving 401 Unauthorized', () async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        if (request.headers['Authorization'] == 'Bearer expired-token') {
          return http.Response('{"statusCode":401,"message":"Unauthorized"}', 401);
        }
        if (request.headers['Authorization'] == 'Bearer refreshed-token') {
          return http.Response(
            '{"success":true,"statusCode":200,"data":{"id":"01a0","profile":{"displayName":"Chef New Name"}}}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('{"success":false}', 404);
      });

      ApiService.tokenRefreshHandler = () async => 'refreshed-token';

      final service = ApiService(client: mockClient);
      final result = await service.updateUserProfile(
        accessToken: 'expired-token',
        displayName: 'Chef New Name',
      );

      expect(result.isSuccess, isTrue);
      expect(result.user?.fullName, 'Chef New Name');
      expect(requestCount, 2); // Initial request (401) + Retry with new token (200)
    });

    test('updateUserProfile triggers sessionExpiredHandler when 401 occurs and refresh returns null', () async {
      bool sessionExpiredCalled = false;
      final mockClient = MockClient((request) async {
        return http.Response('{"statusCode":401,"message":"Unauthorized"}', 401);
      });

      ApiService.tokenRefreshHandler = () async => null; // Refresh failed
      ApiService.sessionExpiredHandler = () {
        sessionExpiredCalled = true;
      };

      final service = ApiService(client: mockClient);
      final result = await service.updateUserProfile(
        accessToken: 'expired-token',
        displayName: 'Chef Test',
      );

      expect(result.isSuccess, isFalse);
      expect(result.statusCode, 401);
      expect(sessionExpiredCalled, isTrue);
    });
  });
}
