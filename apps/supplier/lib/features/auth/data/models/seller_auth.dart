import 'package:cook_connect_seller/core/storage/token_storage_service.dart';

/// Supplier store profile linked to the authenticated user
class SupplierProfile {
  final String supplierId;
  final String supplierName;
  final String? supplierSlug;
  final String? supplierCode;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final String? city;
  final double rating;
  final bool isVerified;
  final String supplierStatus;
  final String? supplierLogoUrl;
  final String? role;
  final String? memberStatus;

  SupplierProfile({
    required this.supplierId,
    required this.supplierName,
    this.supplierSlug,
    this.supplierCode,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.city,
    this.rating = 5.0,
    this.isVerified = false,
    this.supplierStatus = 'ACTIVE',
    this.supplierLogoUrl,
    this.role,
    this.memberStatus,
  });

  SupplierProfile copyWith({
    String? supplierId,
    String? supplierName,
    String? supplierSlug,
    String? supplierCode,
    String? contactEmail,
    String? contactPhone,
    String? address,
    String? city,
    double? rating,
    bool? isVerified,
    String? supplierStatus,
    String? supplierLogoUrl,
    String? role,
    String? memberStatus,
  }) {
    return SupplierProfile(
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierSlug: supplierSlug ?? this.supplierSlug,
      supplierCode: supplierCode ?? this.supplierCode,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
      supplierStatus: supplierStatus ?? this.supplierStatus,
      supplierLogoUrl: supplierLogoUrl ?? this.supplierLogoUrl,
      role: role ?? this.role,
      memberStatus: memberStatus ?? this.memberStatus,
    );
  }

  factory SupplierProfile.fromJson(Map<String, dynamic> json) {
    return SupplierProfile(
      supplierId: json['supplierId']?.toString() ?? json['id']?.toString() ?? '',
      supplierName: json['supplierName']?.toString() ?? json['name']?.toString() ?? '',
      supplierSlug: json['supplierSlug']?.toString() ?? json['slug']?.toString(),
      supplierCode: json['supplierCode']?.toString() ?? json['code']?.toString(),
      contactEmail: json['contactEmail']?.toString() ?? json['email']?.toString(),
      contactPhone: json['contactPhone']?.toString() ?? json['phone']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      isVerified: json['isVerified'] as bool? ?? false,
      supplierStatus: json['supplierStatus']?.toString() ?? 'ACTIVE',
      supplierLogoUrl: json['supplierLogoUrl']?.toString() ?? json['logoUrl']?.toString(),
      role: json['role']?.toString(),
      memberStatus: json['memberStatus']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'supplierId': supplierId,
    'supplierName': supplierName,
    if (supplierSlug != null) 'supplierSlug': supplierSlug,
    if (supplierCode != null) 'supplierCode': supplierCode,
    if (contactEmail != null) 'contactEmail': contactEmail,
    if (contactPhone != null) 'contactPhone': contactPhone,
    if (address != null) 'address': address,
    if (city != null) 'city': city,
    'rating': rating,
    'isVerified': isVerified,
    'supplierStatus': supplierStatus,
    if (supplierLogoUrl != null) 'supplierLogoUrl': supplierLogoUrl,
    if (role != null) 'role': role,
    if (memberStatus != null) 'memberStatus': memberStatus,
  };
}

/// Result returned from GET /api/v1/suppliers/me
class MySupplierResult {
  final bool hasSupplier;
  final SupplierProfile? supplier;
  final String? role;
  final String? memberStatus;

  MySupplierResult({
    required this.hasSupplier,
    this.supplier,
    this.role,
    this.memberStatus,
  });

  factory MySupplierResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final hasSupp = data['hasSupplier'] as bool? ?? false;
    final supplierMap = data['supplier'] is Map<String, dynamic>
        ? data['supplier'] as Map<String, dynamic>
        : null;

    return MySupplierResult(
      hasSupplier: hasSupp,
      supplier: supplierMap != null ? SupplierProfile.fromJson(supplierMap) : null,
      role: data['role']?.toString(),
      memberStatus: data['memberStatus']?.toString(),
    );
  }
}

/// Seller / Supplier Admin User Model
class SellerUser {
  final String id;
  final String email;
  final List<String> roles;
  final String? fullName;
  final String? storeName;
  final String? storeId;
  final String? phone;
  final String? role;
  final String? category;
  final String? address;
  final String? description;
  final SupplierProfile? supplierProfile;

  SellerUser({
    required this.id,
    required this.email,
    this.roles = const ['SUPPLIER_ADMIN'],
    this.fullName,
    this.storeName,
    this.storeId,
    this.phone,
    this.role,
    this.category,
    this.address,
    this.description,
    this.supplierProfile,
  });

  bool get isSupplierAdmin =>
      roles.contains('SUPPLIER_ADMIN') || role == 'SUPPLIER_ADMIN' || role == 'seller';

  SellerUser copyWith({
    String? id,
    String? email,
    List<String>? roles,
    String? fullName,
    String? storeName,
    String? storeId,
    String? phone,
    String? role,
    String? category,
    String? address,
    String? description,
    SupplierProfile? supplierProfile,
  }) {
    return SellerUser(
      id: id ?? this.id,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      fullName: fullName ?? this.fullName,
      storeName: storeName ?? this.storeName,
      storeId: storeId ?? this.storeId,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      category: category ?? this.category,
      address: address ?? this.address,
      description: description ?? this.description,
      supplierProfile: supplierProfile ?? this.supplierProfile,
    );
  }

  factory SellerUser.fromJson(Map<String, dynamic> json) {
    List<String> parsedRoles = const ['SUPPLIER_ADMIN'];
    if (json['roles'] is List) {
      parsedRoles = (json['roles'] as List).map((e) => e.toString()).toList();
    }

    SupplierProfile? parsedSupplier;
    if (json['supplierProfile'] is Map<String, dynamic>) {
      parsedSupplier = SupplierProfile.fromJson(json['supplierProfile'] as Map<String, dynamic>);
    } else if (json['supplier'] is Map<String, dynamic>) {
      parsedSupplier = SupplierProfile.fromJson(json['supplier'] as Map<String, dynamic>);
    }

    return SellerUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roles: parsedRoles,
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? json['displayName']?.toString(),
      storeName: json['storeName']?.toString() ?? json['shopName']?.toString() ?? parsedSupplier?.supplierName,
      storeId: json['storeId']?.toString() ?? json['shopId']?.toString() ?? parsedSupplier?.supplierId,
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString() ?? parsedSupplier?.contactPhone,
      role: json['role']?.toString() ?? (parsedRoles.isNotEmpty ? parsedRoles.first : 'SUPPLIER_ADMIN'),
      category: json['category']?.toString() ?? json['storeCategory']?.toString(),
      address: json['address']?.toString() ?? json['storeAddress']?.toString() ?? parsedSupplier?.address,
      description: json['description']?.toString() ?? json['bio']?.toString(),
      supplierProfile: parsedSupplier,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'roles': roles,
    if (fullName != null) 'fullName': fullName,
    if (storeName != null) 'storeName': storeName,
    if (storeId != null) 'storeId': storeId,
    if (phone != null) 'phone': phone,
    if (role != null) 'role': role,
    if (category != null) 'category': category,
    if (address != null) 'address': address,
    if (description != null) 'description': description,
    if (supplierProfile != null) 'supplierProfile': supplierProfile!.toJson(),
  };
}

/// Authentication result returned by registration or login
class SellerAuthResult {
  final bool success;
  final String message;
  final AuthTokens? tokens;
  final SellerUser? user;
  final int? statusCode;

  SellerAuthResult({
    required this.success,
    required this.message,
    this.tokens,
    this.user,
    this.statusCode,
  });

  factory SellerAuthResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    AuthTokens? tokens;
    SellerUser? user;

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

    final rawStatusCode = (json['statusCode'] as num?)?.toInt();
    final isSuccess = json['success'] as bool? ??
        (rawStatusCode == null || rawStatusCode < 400);

    return SellerAuthResult(
      success: isSuccess,
      message: json['message']?.toString() ?? json['error']?.toString() ?? (isSuccess ? 'Thành công' : 'Thất bại'),
      tokens: tokens,
      user: user,
      statusCode: rawStatusCode,
    );
  }
}
