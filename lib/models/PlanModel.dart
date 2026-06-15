class PlanModel {
  final String id;
  final String name;
  final double price;
  final double yearlyPrice;
  final List<String> features;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.yearlyPrice,
    required this.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json["id"],
      name: json["name"],
      price: (json["price"] as num).toDouble(),
      yearlyPrice: (json["yearlyPrice"] as num).toDouble(),
      features: List<String>.from(json["features"] ?? []),
    );
  }
}
