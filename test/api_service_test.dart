import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cookconnect/config/api_config.dart';
import 'package:cookconnect/services/api_service.dart';

void main() {
  group('ApiConfig Tests', () {
    test('Default configuration points to LAN IP 192.168.1.162:8080', () {
      expect(ApiConfig.baseUrl, 'http://192.168.1.162:8080');
      expect(ApiConfig.apiBaseUrl, 'http://192.168.1.162:8080/api/v1');
      expect(ApiConfig.healthUrl, 'http://192.168.1.162:8080/api/v1/health');
      expect(
        ApiConfig.sendOtpUrl,
        'http://192.168.1.162:8080/api/v1/auth/send-otp',
      );
      expect(
        ApiConfig.verifyOtpUrl,
        'http://192.168.1.162:8080/api/v1/auth/verify-otp',
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
        expect(request.url.path, '/api/v1/auth/send-otp');
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
        expect(request.url.path, '/api/v1/auth/verify-otp');
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
    test('login returns success when server responds 200 OK', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/login');
        return http.Response(
          '''{
            "success": true,
            "statusCode": 200,
            "message": "AUTH.LOGIN_SUCCESS",
            "data": {
              "user": {
                "id": "user-uuid-123",
                "email": "chef.linh@example.com",
                "fullName": "Chef Linh Đan",
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
      });

      final service = ApiService(client: mockClient);
      final result = await service.login(
        email: 'chef.linh@example.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.statusCode, 200);
      expect(result.user?.email, 'chef.linh@example.com');
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
    test('getProfile returns user data with Bearer token', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer valid-jwt-token');
        return http.Response(
          '{"success":true,"statusCode":200,"data":{"id":"01a0","email":"test@test.com","fullName":"Test User","roles":["USER"]}}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.getProfile('valid-jwt-token');

      expect(result.isSuccess, isTrue);
      expect(result.user?.fullName, 'Test User');
    });

    test('updateUserProfile updates user profile successfully', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PATCH');
        return http.Response(
          '{"success":true,"statusCode":200,"data":{"id":"01a0","email":"test@test.com","displayName":"Chef Updated","username":"chefup","gender":"MALE","dateOfBirth":"1995-05-10","bio":"My new bio"}}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final result = await service.updateUserProfile(
        accessToken: 'valid-jwt-token',
        userId: '01a0',
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
  });
}
