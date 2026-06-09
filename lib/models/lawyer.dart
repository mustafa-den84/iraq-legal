class Lawyer {
  final int id;
  final String fullName;
  final String phone;
  final String? whatsappNumber;
  final String? gender;
  final String? birthDate;
  final String? city;
  final String? area;
  final String? address;
  final String? officeName;
  final String? specialization;
  final int? experienceYears;
  final String? nationalId;
  final String? barAssociationId;
  final String? licenseNumber;
  final String status;
  final bool isVerified;
  final bool isVisible;
  final double rating;
  final int reviewsCount;
  final DateTime? createdAt;
  final String? profileImage;
  final String? officeImage;
  final String? licenseImage;

  Lawyer({
    required this.id,
    required this.fullName,
    required this.phone,
    this.whatsappNumber,
    this.gender,
    this.birthDate,
    this.city,
    this.area,
    this.address,
    this.officeName,
    this.specialization,
    this.experienceYears,
    this.nationalId,
    this.barAssociationId,
    this.licenseNumber,
    required this.status,
    required this.isVerified,
    required this.isVisible,
    required this.rating,
    required this.reviewsCount,
    this.createdAt,
    this.profileImage,
    this.officeImage,
    this.licenseImage,
  });

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    return Lawyer(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      whatsappNumber: json['whatsapp_number'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birth_date'] as String?,
      city: json['city'] as String?,
      area: json['area'] as String?,
      address: json['address'] as String?,
      officeName: json['office_name'] as String?,
      specialization: json['specialization'] as String?,
      experienceYears: json['experience_years'] as int?,
      nationalId: json['national_id'] as String?,
      barAssociationId: json['bar_association_id'] as String?,
      licenseNumber: json['license_number'] as String?,
      status: json['status'] as String,
      isVerified: json['is_verified'] as bool,
      isVisible: json['is_visible'] as bool,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      profileImage: json['profile_image'] as String?,
      officeImage: json['office_image'] as String?,
      licenseImage: json['license_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'whatsapp_number': whatsappNumber,
      'gender': gender,
      'birth_date': birthDate,
      'city': city,
      'area': area,
      'address': address,
      'office_name': officeName,
      'specialization': specialization,
      'experience_years': experienceYears,
      'national_id': nationalId,
      'bar_association_id': barAssociationId,
      'license_number': licenseNumber,
      'status': status,
      'is_verified': isVerified,
      'is_visible': isVisible,
      'rating': rating,
      'reviews_count': reviewsCount,
      'created_at': createdAt?.toIso8601String(),
      'profile_image': profileImage,
      'office_image': officeImage,
      'license_image': licenseImage,
    };
  }
}
