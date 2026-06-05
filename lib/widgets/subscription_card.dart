import 'package:flutter/material.dart';
import '../models/currentSubscription.dart';
import 'package:navyoga_academy/widgets/subscription_card.dart';

class SubscriptionCard extends StatelessWidget {
  final CurrentSubscription plan;

  const SubscriptionCard(this.plan, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.deepOrange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Current Plan: ${plan.name}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),

          const SizedBox(height: 8),

          Text("Active since ${plan.activeSince}"),

          const SizedBox(height: 16),

          Text("Monthly Price: ₹${plan.monthlyPrice}"),
          Text("Billing Cycle: ${plan.billingCycle}"),
          Text("Next Billing Date: ${plan.nextBillingDate}"),
        ],
      ),
    );
  }
}
