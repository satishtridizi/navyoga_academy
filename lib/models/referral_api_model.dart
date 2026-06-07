class ReferralApiModel {
  final String name;
  final String status;
  final String reward;
  final String joinedDate;
  final String email;

  ReferralApiModel({
    required this.name,
    required this.status,
    required this.reward,
    required this.joinedDate,
    required this.email,
  });

  factory ReferralApiModel.fromJson(Map<String, dynamic> json) {
    return ReferralApiModel(
      name: json["name"] ?? "",
      email: json["email"] ?? "",

      status: json["status"] ?? "",

      reward: json["reward"].toString(),

      joinedDate: json["joinedDate"] ?? "",
    );
  }
}
