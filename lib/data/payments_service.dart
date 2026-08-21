import 'package:navyoga_academy/models/payments_models.dart';

@Deprecated(
  'Legacy local payment data. Subscription plans must come from services/subscription_service.dart.',
)
class SubscriptionService {
  Future<Subscription?> fetchSubscription() async => null;

  List<Plan> getPlans() => const <Plan>[];

  List<PaymentMethod> getPaymentMethods() => [
    PaymentMethod(
      brand: "Visa",
      number: "•••• 1234",
      expiry: "12/28",
      isDefault: true,
    ),
    PaymentMethod(brand: "Mastercard", number: "•••• 5678", expiry: "09/27"),
  ];

  List<PaymentHistory> getPayments() => [
    PaymentHistory(
      title: "Premium Monthly",
      date: "Apr 10, 2026",
      amount: "₹999",
    ),
    PaymentHistory(
      title: "Premium Monthly",
      date: "Mar 10, 2026",
      amount: "₹999",
    ),
    PaymentHistory(
      title: "Premium Monthly",
      date: "Feb 10, 2026",
      amount: "₹999",
    ),
  ];
}
