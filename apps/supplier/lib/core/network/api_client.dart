import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cook_connect_seller/core/config/api_config.dart';
import 'package:cook_connect_seller/core/network/api_exception.dart';

/// Generic HTTP client with token refresh interceptor, error parsing, and timeout support
class ApiClient {
  /// Global default client override (useful for unit tests & mocks)
  static http.Client? defaultClient;

  /// Global handlers for token refresh and session expiration
  static Future<String?> Function()? tokenRefreshHandler;
  static void Function()? sessionExpiredHandler;

  final http.Client _client;
  final String baseUrl;

  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? defaultClient ?? http.Client(),
        baseUrl = baseUrl ?? ApiConfig.baseUrl;

  /// Performs a GET request
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    String? token,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, queryParams);
    final reqHeaders = _buildHeaders(headers: headers, token: token);

    try {
      var response = await _client
          .get(uri, headers: reqHeaders)
          .timeout(timeout ?? Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 401 &&
          token != null &&
          tokenRefreshHandler != null &&
          !token.startsWith('demo-')) {
        final newToken = await tokenRefreshHandler!();
        if (newToken != null && newToken.isNotEmpty) {
          reqHeaders['Authorization'] = 'Bearer $newToken';
          response = await _client
              .get(uri, headers: reqHeaders)
              .timeout(timeout ?? Duration(seconds: ApiConfig.timeoutSeconds));
        }
      }

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a POST request
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    String? token,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path);
    final reqHeaders = _buildHeaders(headers: headers, token: token);
    final reqBody = body is String ? body : (body != null ? jsonEncode(body) : null);

    try {
      var response = await _client
          .post(uri, headers: reqHeaders, body: reqBody)
          .timeout(timeout ?? Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 401 &&
          token != null &&
          tokenRefreshHandler != null &&
          !token.startsWith('demo-')) {
        final newToken = await tokenRefreshHandler!();
        if (newToken != null && newToken.isNotEmpty) {
          reqHeaders['Authorization'] = 'Bearer $newToken';
          response = await _client
              .post(uri, headers: reqHeaders, body: reqBody)
              .timeout(timeout ?? Duration(seconds: ApiConfig.timeoutSeconds));
        }
      }

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a PUT request
  Future<Map<String, dynamic>> put(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    String? token,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path);
    final reqHeaders = _buildHeaders(headers: headers, token: token);
    final reqBody = body is String ? body : (body != null ? jsonEncode(body) : null);

    try {
      var response = await _client
          .put(uri, headers: reqHeaders, body: reqBody)
          .timeout(timeout ?? Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 401 &&
          token != null &&
          tokenRefreshHandler != null &&
          !token.startsWith('demo-')) {
        final newToken = await tokenRefreshHandler!();
        if (newToken != null && newToken.isNotEmpty) {
          reqHeaders['Authorization'] = 'Bearer $newToken';
          response = await _client
              .put(uri, headers: reqHeaders, body: reqBody)
              .timeout(timeout ?? Duration(seconds: ApiConfig.timeoutSeconds));
        }
      }

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a PATCH request
  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    String? token,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path);
    final reqHeaders = _buildHeaders(headers: headers, token: token);
    final reqBody = body is String ? body : (body != null ? jsonEncode(body) : null);

    try {
      var response = await _client
          .patch(uri, headers: reqHeaders, body: reqBody)
          .timeout(timeout ?? Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 401 &&
          token != null &&
          tokenRefreshHandler != null &&
          !token.startsWith('demo-')) {
        final newToken = await tokenRefreshHandler!();
        if (newToken != null && newToken.isNotEmpty) {
          reqHeaders['Authorization'] = 'Bearer $newToken';
          response = await _client
              .patch(uri, headers: reqHeaders, body: reqBody)
              .timeout(timeout ?? Duration(seconds: ApiConfig.timeoutSeconds));
        }
      }

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a DELETE request
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? headers,
    String? token,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path);
    final reqHeaders = _buildHeaders(headers: headers, token: token);

    try {
      var response = await _client
          .delete(uri, headers: reqHeaders)
          .timeout(timeout ?? Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 401 &&
          token != null &&
          tokenRefreshHandler != null &&
          !token.startsWith('demo-')) {
        final newToken = await tokenRefreshHandler!();
        if (newToken != null && newToken.isNotEmpty) {
          reqHeaders['Authorization'] = 'Bearer $newToken';
          response = await _client
              .delete(uri, headers: reqHeaders)
              .timeout(timeout ?? Duration(seconds: ApiConfig.timeoutSeconds));
        }
      }

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a multipart file upload request
  Future<Map<String, dynamic>> uploadMultipart(
    String path, {
    required String fileField,
    required List<int> fileBytes,
    required String filename,
    MediaType? contentType,
    Map<String, String>? fields,
    Map<String, String>? headers,
    String? token,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path);

    Future<http.Response> sendWithToken(String? authToken) async {
      final request = http.MultipartRequest('POST', uri);
      final reqHeaders = _buildHeaders(headers: headers, token: authToken);
      request.headers.addAll(reqHeaders);
      if (fields != null) {
        request.fields.addAll(fields);
      }
      request.files.add(
        http.MultipartFile.fromBytes(
          fileField,
          fileBytes,
          filename: filename,
          contentType: contentType,
        ),
      );

      final streamed = await _client
          .send(request)
          .timeout(timeout ?? Duration(seconds: ApiConfig.timeoutSeconds * 2));
      return http.Response.fromStream(streamed);
    }

    try {
      var response = await sendWithToken(token);

      if (response.statusCode == 401 &&
          token != null &&
          tokenRefreshHandler != null &&
          !token.startsWith('demo-')) {
        final newToken = await tokenRefreshHandler!();
        if (newToken != null && newToken.isNotEmpty) {
          response = await sendWithToken(newToken);
        }
      }

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final fullUrl = path.startsWith('http://') || path.startsWith('https://')
        ? path
        : '$baseUrl$path';
    final uri = Uri.parse(fullUrl);
    if (queryParams == null || queryParams.isEmpty) {
      return uri;
    }
    final cleanParams = <String, String>{};
    queryParams.forEach((key, val) {
      if (val != null) cleanParams[key] = val.toString();
    });
    return uri.replace(queryParameters: cleanParams);
  }

  Map<String, String> _buildHeaders({Map<String, String>? headers, String? token}) {
    final defaultHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    if (token != null && token.isNotEmpty) {
      defaultHeaders['Authorization'] = 'Bearer $token';
    }
    return defaultHeaders;
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    Map<String, dynamic> decoded;
    try {
      final parsed = jsonDecode(response.body);
      decoded = parsed is Map<String, dynamic> ? parsed : {'data': parsed};
    } catch (_) {
      decoded = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      decoded['statusCode'] = response.statusCode;
      return decoded;
    }

    if (response.statusCode == 401) {
      sessionExpiredHandler?.call();
    }

    final message = decoded['message']?.toString() ?? 'Lỗi không xác định (${response.statusCode})';
    throw ApiException(
      statusCode: response.statusCode,
      message: message,
      errorCode: decoded['errorCode']?.toString(),
      error: decoded['error']?.toString(),
      data: decoded['data'] is Map<String, dynamic> ? decoded['data'] as Map<String, dynamic> : null,
      params: decoded['params'] is Map<String, dynamic> ? decoded['params'] as Map<String, dynamic> : null,
      errors: decoded['errors'] is List ? decoded['errors'] as List : null,
    );
  }

  dynamic _handleError(dynamic error) {
    if (error is ApiException) return error;

    final errStr = error.toString();
    String message = 'Lỗi kết nối: $errStr';

    if (errStr.contains('Connection refused') ||
        errStr.contains('SocketException') ||
        errStr.contains('Failed host lookup')) {
      message = 'Không thể kết nối đến máy chủ ($baseUrl). Vui lòng kiểm tra mạng hoặc đảm bảo Backend đang chạy.';
    } else if (errStr.contains('TimeoutException')) {
      message = 'Kết nối máy chủ bị quá thời gian (${ApiConfig.timeoutSeconds}s). Vui lòng thử lại.';
    }

    return ApiException(
      statusCode: 0,
      message: message,
      error: errStr,
    );
  }
}
