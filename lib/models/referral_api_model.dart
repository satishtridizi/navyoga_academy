class ReferralApiModel {
  final String name;
  final String status;
  final String reward;
  final String joinedDate;

  ReferralApiModel({
    required this.name,
    required this.status,
    required this.reward,
    required this.joinedDate,
  });

  factory ReferralApiModel.fromJson(Map<String, dynamic> json) {
    return ReferralApiModel(
      name: json["name"] ?? "",

      status: json["status"] ?? "",

      reward: json["reward"].toString(),

      joinedDate: json["joinedDate"] ?? "",
    );
  }
}
