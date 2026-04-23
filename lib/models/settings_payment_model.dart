class PaymentModel {
  final String plan;
  final String status;
  final String validTill;
  final String price;
  final String card;

  bool autoRenew;

  PaymentModel({
    required this.plan,
    required this.status,
    required this.validTill,
    required this.price,
    required this.card,
    required this.autoRenew,
  });
}
