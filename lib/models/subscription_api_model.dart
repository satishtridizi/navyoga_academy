class SubscriptionApiModel {
  final String name;

  final String price;

  final String duration;

  final bool isActive;

  final String expiryDate;

  SubscriptionApiModel({
    required this.name,

    required this.price,

    required this.duration,

    required this.isActive,

    required this.expiryDate,
  });

  factory SubscriptionApiModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionApiModel(
      name: json["name"] ?? "",

      price: json["price"].toString(),

      duration: json["duration"] ?? "",

      isActive: json["isActive"] ?? false,

      expiryDate: json["expiryDate"] ?? "",
    );
  }
}
