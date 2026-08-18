class StudentModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool phoneVerified;
  final String? avatar;
  final String? city;
  final String? country;
  final String? gender;
  final int? age;
  final String? bloodGroup;
  final String? emergencyContact;
  final String? medicalConditions;
  final String? yogaExperience;
  final String? currentLevel;
  final String? areasOfInterest;
  final String? referralCode;
  final bool isActive;
  final String? termsAcceptedAt;
  final String? createdAt;
  final String? updatedAt;

  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.phoneVerified,
    required this.isActive,
    this.avatar,
    this.city,
    this.country,
    this.gender,
    this.age,
    this.bloodGroup,
    this.emergencyContact,
    this.medicalConditions,
    this.yogaExperience,
    this.currentLevel,
    this.areasOfInterest,
    this.referralCode,
    this.termsAcceptedAt,
    this.createdAt,
    this.updatedAt,
  });

 static const String _bucketUrl =
    'https://navyoga.s3.ap-south-1.amazonaws.com';
 static const String _baseUrl = '$_bucketUrl/assets';

factory StudentModel.fromJson(Map<String, dynamic> json) {
  return StudentModel(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    phone: (json['phone'] ?? '').toString(),
    phoneVerified: json['phoneVerified'] == true,

    avatar: _buildImageUrl(
      json['avatar'] ?? json['profileImage'],
    ),

    city: _nullableString(json['city']),
    country: _nullableString(json['country']),
    gender: _nullableString(json['gender']),
    age: _nullableInt(json['age']),
    bloodGroup: _nullableString(json['bloodGroup']),
    emergencyContact:
        _nullableString(json['emergencyContact']),
    medicalConditions:
        _nullableString(json['medicalConditions']),
    yogaExperience:
        _nullableString(json['yogaExperience']),
    currentLevel:
        _nullableString(json['currentLevel']),
    areasOfInterest:
        _nullableString(json['areasOfInterest']),
    referralCode:
        _nullableString(json['referralCode']),
    isActive: json['isActive'] != false,
    termsAcceptedAt:
        _nullableString(json['termsAcceptedAt']),
    createdAt: _nullableString(json['createdAt']),
    updatedAt: _nullableString(json['updatedAt']),
  );
}

static String? _buildImageUrl(dynamic value) {
  final path = _nullableString(value);

  if (path == null) {
    return null;
  }

  if (path.startsWith('http://') ||
      path.startsWith('https://')) {
    if (path.startsWith('$_bucketUrl/') &&
        !path.startsWith('$_baseUrl/')) {
      return '$_baseUrl/${path.substring(_bucketUrl.length + 1)}';
    }
    return path;
  }

  if (path.startsWith('/')) {
    return '$_baseUrl$path';
  }

  return '$_baseUrl/$path';
}

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'country': country,
      'gender': gender,
      'age': age,
      'bloodGroup': bloodGroup,
      'emergencyContact': emergencyContact,
      'medicalConditions': medicalConditions,
      'yogaExperience': yogaExperience,
      'currentLevel': currentLevel,
      'areasOfInterest': areasOfInterest,
    }..removeWhere((key, value) => value == null);
  }

  StudentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    bool? phoneVerified,
    String? avatar,
    String? city,
    String? country,
    String? gender,
    int? age,
    String? bloodGroup,
    String? emergencyContact,
    String? medicalConditions,
    String? yogaExperience,
    String? currentLevel,
    String? areasOfInterest,
    String? referralCode,
    bool? isActive,
    String? termsAcceptedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      avatar: avatar ?? this.avatar,
      city: city ?? this.city,
      country: country ?? this.country,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      yogaExperience: yogaExperience ?? this.yogaExperience,
      currentLevel: currentLevel ?? this.currentLevel,
      areasOfInterest: areasOfInterest ?? this.areasOfInterest,
      referralCode: referralCode ?? this.referralCode,
      isActive: isActive ?? this.isActive,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
