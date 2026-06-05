class StudentModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;

  StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      profileImage: json["profileImage"],
    );
  }
}
