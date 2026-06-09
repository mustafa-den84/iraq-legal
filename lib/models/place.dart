class Place {
  final String id;
  final String type;
  final String? subType;
  final String nameAr;
  final String nameEn;
  final String nameKu;
  final String city;
  final String? addressAr;
  final String? addressEn;
  final String? addressKu;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final String? hoursAr;
  final String? hoursEn;
  final String? hoursKu;
  final DateTime createdAt;

  Place({
    required this.id,
    required this.type,
    this.subType,
    required this.nameAr,
    required this.nameEn,
    required this.nameKu,
    required this.city,
    this.addressAr,
    this.addressEn,
    this.addressKu,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
    this.hoursAr,
    this.hoursEn,
    this.hoursKu,
    required this.createdAt,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      type: json['type'] as String,
      subType: json['sub_type'] as String?,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      nameKu: json['name_ku'] as String,
      city: json['city'] as String,
      addressAr: json['address_ar'] as String?,
      addressEn: json['address_en'] as String?,
      addressKu: json['address_ku'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      hoursAr: json['hours_ar'] as String?,
      hoursEn: json['hours_en'] as String?,
      hoursKu: json['hours_ku'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String getName(String lang) {
    switch (lang) {
      case 'ar':
        return nameAr;
      case 'ku':
        return nameKu;
      default:
        return nameEn;
    }
  }

  String getAddress(String lang) {
    switch (lang) {
      case 'ar':
        return addressAr ?? addressEn ?? '';
      case 'ku':
        return addressKu ?? addressEn ?? '';
      default:
        return addressEn ?? '';
    }
  }

  String getHours(String lang) {
    switch (lang) {
      case 'ar':
        return hoursAr ?? hoursEn ?? '';
      case 'ku':
        return hoursKu ?? hoursEn ?? '';
      default:
        return hoursEn ?? '';
    }
  }
}
