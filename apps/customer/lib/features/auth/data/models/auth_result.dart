import 'package:cookconnect/features/auth/data/models/auth_user.dart';
import 'package:cookconnect/features/auth/data/models/auth_tokens.dart';

class AuthResult {
  final bool isSuccess;
  final int statusCode;
  final String? message;
  final AuthUser? user;
  final AuthTokens? tokens;
  final String? error;

  AuthResult({
    required this.isSuccess,
    required this.statusCode,
    this.message,
    this.user,
    this.tokens,
    this.error,
  });
}
