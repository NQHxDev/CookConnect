import 'package:cookconnect/core/storage/address_storage_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';

/// Manages the current user's saved delivery addresses.
/// The first element of the list is always the default / most recently used.
class SavedAddressService {
  SavedAddressService._();
  static final SavedAddressService instance = SavedAddressService._();

  AddressStorageService _storage = SecureAddressStorageService();

  void setStorage(AddressStorageService storage) => _storage = storage;

  String? get _userId => AuthService.instance.currentUser?.id;

  Future<List<SavedAddress>> getAll() async {
    final uid = _userId;
    if (uid == null) return [];
    final list = await _storage.getAddresses(uid);
    // Default first
    list.sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));
    return list;
  }

  Future<void> _persist(List<SavedAddress> list) async {
    final uid = _userId;
    if (uid == null) return;
    await _storage.saveAddresses(uid, list);
  }

  /// Add or update. Returns the stored address.
  Future<SavedAddress> upsert({
    String? id,
    required String label,
    required String receiverName,
    required String phone,
    required String address,
    bool makeDefault = false,
  }) async {
    final list = await getAll();
    final idx = id != null ? list.indexWhere((a) => a.id == id) : -1;
    final dupIdx = idx >= 0
        ? idx
        : list.indexWhere((a) => a.isSameAs(receiverName, phone, address));

    SavedAddress saved;
    if (dupIdx >= 0) {
      saved = list[dupIdx].copyWith(
        label: label.isNotEmpty ? label : list[dupIdx].label,
        receiverName: receiverName,
        phone: phone,
        address: address,
      );
      list[dupIdx] = saved;
    } else {
      saved = SavedAddress(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        label: label,
        receiverName: receiverName,
        phone: phone,
        address: address,
        isDefault: list.isEmpty,
      );
      list.add(saved);
    }
    if (makeDefault) return setDefaultInternal(list, saved.id);
    await _persist(list);
    return saved;
  }

  Future<SavedAddress> setDefaultInternal(
    List<SavedAddress> list,
    String id,
  ) async {
    final updated = [
      for (final a in list) a.copyWith(isDefault: a.id == id),
    ];
    await _persist(updated);
    return updated.firstWhere((a) => a.id == id);
  }

  Future<void> setDefault(String id) async =>
      setDefaultInternal(await getAll(), id);

  Future<void> delete(String id) async {
    final list = await getAll()..removeWhere((a) => a.id == id);
    if (list.isNotEmpty && !list.any((a) => a.isDefault)) {
      list[0] = list[0].copyWith(isDefault: true);
    }
    await _persist(list);
  }
}

