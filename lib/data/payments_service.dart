import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/payments_models.dart';

class SubscriptionService {
  Future<Subscription> fetchSubscription() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return Subscription(
      planName: "Premium",
      activeSince: "Jan 10, 2026",
      price: "₹999",
      nextBilling: "May 10, 2026",
      billingCycle: "Monthly",
      isActive: true,
      features: [
        "Unlimited class access",
        "All recording sessions",
        "Priority booking",
        "Personal progress tracking",
        "Mobile app access",
      ],
    );
  }

  List<Plan> getPlans() => [
    Plan(
      id: "",
      name: "Basic",
      price: "₹499",
      yearly: "₹4990/year",
      color: Colors.green,
      icon: Icons.shield,
      features: [
        "10 classes per month",
        "Access to recordings",
        "Basic progress tracking",
        "Mobile app access",
        "Email support",
      ],
    ),
    Plan(
      id: "",
      name: "Premium",
      price: "₹999",
      yearly: "₹9990/year",
      color: Colors.deepOrange,
      isPopular: true,
      isCurrent: true,
      icon: Icons.flash_on,
      features: [
        "Unlimited class access",
        "All recording sessions",
        "Priority booking",
        "Personal progress tracking",
        "Mobile app access",
        "Live chat support",
        "Exclusive workshops",
      ],
    ),
    Plan(
      id: "",
      name: "Platinum",
      price: "₹1999",
      yearly: "₹19990/year",
      color: Colors.purple,
      icon: Icons.workspace_premium,
      features: [
        "Everything in Premium",
        "1-on-1 personal sessions",
        "Custom meal plans",
        "Dedicated instructor",
        "Home visit option",
        "Priority support 24/7",
        "Exclusive VIP events",
        "Free merchandise",
      ],
    ),
  ];

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
