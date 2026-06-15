class PaymentMethod {
  final String id;
  final String brand;
  final String number;
  final String expiry;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.brand,
    required this.number,
    required this.expiry,
    required this.isDefault,
  });
}
