class PaymentApiModel {
  final String id;
  final String amount;
  final String status;
  final String method;
  final String date;

  PaymentApiModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
  });

  factory PaymentApiModel.fromJson(Map<String, dynamic> json) {
    return PaymentApiModel(
      id: json["_id"] ?? "",

      amount: json["amount"].toString(),

      status: json["status"] ?? "",

      method: json["method"] ?? "",

      date: json["date"] ?? "",
    );
  }
}
