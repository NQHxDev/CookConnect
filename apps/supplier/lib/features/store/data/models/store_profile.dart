class StoreProfile {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? bannerUrl;
  final String? avatarUrl;
  final bool isOpen;
  final String openTime;
  final String closeTime;

  StoreProfile({
    required this.id,
    required this.name,
    this.address = '',
    this.phone = '',
    this.bannerUrl,
    this.avatarUrl,
    this.isOpen = true,
    this.openTime = '08:00',
    this.closeTime = '22:00',
  });

  factory StoreProfile.fromJson(Map<String, dynamic> json) {
    return StoreProfile(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['storeName']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      bannerUrl: json['bannerUrl']?.toString() ?? json['banner']?.toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar']?.toString(),
      isOpen: json['isOpen'] as bool? ?? true,
      openTime: json['openTime']?.toString() ?? '08:00',
      closeTime: json['closeTime']?.toString() ?? '22:00',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'phone': phone,
    'bannerUrl': bannerUrl,
    'avatarUrl': avatarUrl,
    'isOpen': isOpen,
    'openTime': openTime,
    'closeTime': closeTime,
  };
}
