import 'package:navyoga_academy/models/payments_models.dart';
import 'package:navyoga_academy/data/payment_data.dart';

class PaymentData {
  static List<PaymentMethod> methods = [
    PaymentMethod(
      brand: "Visa",
      number: "4242",
      expiry: "12/26",
      isDefault: true,
    ),
    PaymentMethod(brand: "Mastercard", number: "5678", expiry: "08/25"),
    PaymentMethod(brand: "RuPay", number: "1122", expiry: "03/27"),
  ];
}
