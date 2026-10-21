import 'package:cook_connect_seller/core/storage/token_storage_service.dart';

class SellerUser {
  final String id;
  final String email;
  final String? fullName;
  final String? storeName;
  final String? storeId;
  final String? phone;
  final String? role;

  SellerUser({
    required this.id,
    required this.email,
    this.fullName,
    this.storeName,
    this.storeId,
    this.phone,
    this.role,
  });

  factory SellerUser.fromJson(Map<String, dynamic> json) {
    return SellerUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString(),
      storeName: json['storeName']?.toString(),
      storeId: json['storeId']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'seller',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'storeName': storeName,
    'storeId': storeId,
    'phone': phone,
    'role': role,
  };
}

class SellerAuthResult {
  final bool success;
  final String message;
  final AuthTokens? tokens;
  final SellerUser? user;

  SellerAuthResult({
    required this.success,
    required this.message,
    this.tokens,
    this.user,
  });

  factory SellerAuthResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    AuthTokens? tokens;
    SellerUser? user;

    if (data != null) {
      if (data['tokens'] is Map<String, dynamic>) {
        tokens = AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>);
      } else if (data['token'] != null || data['accessToken'] != null) {
        tokens = AuthTokens.fromJson(data);
      }

      if (data['user'] is Map<String, dynamic>) {
        user = SellerUser.fromJson(data['user'] as Map<String, dynamic>);
      } else if (data['seller'] is Map<String, dynamic>) {
        user = SellerUser.fromJson(data['seller'] as Map<String, dynamic>);
      }
    }

    return SellerAuthResult(
      success: json['success'] as bool? ?? (json['statusCode'] == null || (json['statusCode'] as int) < 400),
      message: json['message']?.toString() ?? '',
      tokens: tokens,
      user: user,
    );
  }
}
