class CurrentSubscription {
  final String name;
  final String status;
  final double monthlyPrice;
  final String billingCycle;
  final String nextBillingDate;
  final String activeSince;
  final List<String> features;

  CurrentSubscription({
    required this.name,
    required this.status,
    required this.monthlyPrice,
    required this.billingCycle,
    required this.nextBillingDate,
    required this.activeSince,
    required this.features,
  });

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) {
    return CurrentSubscription(
      name: json["name"] ?? "",
      status: json["status"] ?? "",
      monthlyPrice: (json["monthlyPrice"] ?? 0).toDouble(),
      billingCycle: json["billingCycle"] ?? "",
      nextBillingDate: json["nextBillingDate"] ?? "",
      activeSince: json["activeSince"] ?? "",
      features: List<String>.from(json["features"] ?? []),
    );
  }
}
