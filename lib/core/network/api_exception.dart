/// Standardized Exception for HTTP and API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? errorCode;
  final String? error;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? params;
  final List<dynamic>? errors;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errorCode,
    this.error,
    this.data,
    this.params,
    this.errors,
  });

  @override
  String toString() => 'ApiException(status: $statusCode, code: $errorCode, message: $message)';
}
