class CouponModel {
  final String id;
  final String code;
  final double discount;
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    required this.discount,
    required this.isActive,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json["id"] ?? "",
      code: json["code"] ?? "",
      discount: (json["discount"] ?? 0).toDouble(),
      isActive: json["isActive"] ?? false,
    );
  }
}
