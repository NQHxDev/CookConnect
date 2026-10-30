import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A saved delivery address (self or a friend/relative).
class SavedAddress {
  final String id;
  final String label; // e.g. "Nhà", "Công ty", "Bạn Lan"
  final String receiverName;
  final String phone;
  final String address;
  final bool isDefault;

  const SavedAddress({
    required this.id,
    required this.label,
    required this.receiverName,
    required this.phone,
    required this.address,
    this.isDefault = false,
  });

  SavedAddress copyWith({
    String? label,
    String? receiverName,
    String? phone,
    String? address,
    bool? isDefault,
  }) => SavedAddress(
    id: id,
    label: label ?? this.label,
    receiverName: receiverName ?? this.receiverName,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    isDefault: isDefault ?? this.isDefault,
  );

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
    id: json['id'] as String,
    label: (json['label'] as String?) ?? '',
    receiverName: (json['receiverName'] as String?) ?? '',
    phone: (json['phone'] as String?) ?? '',
    address: (json['address'] as String?) ?? '',
    isDefault: (json['isDefault'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'receiverName': receiverName,
    'phone': phone,
    'address': address,
    'isDefault': isDefault,
  };

  /// Same receiver + phone + address (ignoring case/spacing) => duplicate.
  bool isSameAs(String name, String phoneNumber, String addr) =>
      _norm(receiverName) == _norm(name) &&
      _norm(phone) == _norm(phoneNumber) &&
      _norm(address) == _norm(addr);

  static String _norm(String s) => s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

abstract class AddressStorageService {
  Future<List<SavedAddress>> getAddresses(String userId);
  Future<void> saveAddresses(String userId, List<SavedAddress> addresses);
  Future<void> clear(String userId);
}

/// Stores saved addresses in Keychain / Android KeyStore (same mechanism as
/// JWT tokens). Data is namespaced per user id so accounts never share data.
class SecureAddressStorageService implements AddressStorageService {
  final FlutterSecureStorage _storage;

  SecureAddressStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  String _key(String userId) => 'cc_saved_addresses_$userId';

  @override
  Future<List<SavedAddress>> getAddresses(String userId) async {
    try {
      final raw = await _storage.read(key: _key(userId));
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SavedAddress.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveAddresses(
    String userId,
    List<SavedAddress> addresses,
  ) async {
    try {
      await _storage.write(
        key: _key(userId),
        value: jsonEncode(addresses.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      // Graceful fallback
    }
  }

  @override
  Future<void> clear(String userId) async {
    try {
      await _storage.delete(key: _key(userId));
    } catch (_) {}
  }
}

/// In-memory implementation for tests.
class InMemoryAddressStorageService implements AddressStorageService {
  final Map<String, List<SavedAddress>> _data = {};

  @override
  Future<List<SavedAddress>> getAddresses(String userId) async =>
      List.of(_data[userId] ?? const []);

  @override
  Future<void> saveAddresses(String userId, List<SavedAddress> a) async =>
      _data[userId] = List.of(a);

  @override
  Future<void> clear(String userId) async => _data.remove(userId);
}

