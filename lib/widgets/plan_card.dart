import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/payments_models.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;
  final String currentPlanName;
  final VoidCallback? onUpgrade;

  const PlanCard({
    super.key,
    required this.plan,
    required this.currentPlanName,
    this.onUpgrade,
  });
  Color get planColor {
    switch (plan.name.toLowerCase()) {
      case "basic":
        return const Color(0xffFF6B1A);

      case "premium":
        return const Color(0xffFF6B1A);

      case "platinum":
        return const Color(0xffFF6B1A);

      default:
        return const Color(0xffFF6B1A);
    }
  }

  IconData get planIcon {
    switch (plan.name.toLowerCase()) {
      case "basic":
        return Icons.shield_outlined;

      case "premium":
        return Icons.flash_on;

      case "platinum":
        return Icons.workspace_premium;

      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrent = currentPlanName.toLowerCase() == plan.name.toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: planColor.withOpacity(.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: planColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(planIcon, color: planColor),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: planColor,
                  ),
                ),
              ),

              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "Most Popular",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          /// PRICE
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${plan.price}",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff20203A),
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      "/month",
                      style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                "or ₹${(double.tryParse(plan.price) ?? 0) * 10}/year",
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const SizedBox(height: 24),

          /// FEATURES
          ...plan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.check, size: 18, color: planColor),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(feature, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent ? null : onUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent ? Colors.grey : planColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                isCurrent ? "Current Plan" : "Get Started",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
