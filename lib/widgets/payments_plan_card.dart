import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/payments_models.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;

  const PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = plan.isPopular;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: plan.color.withOpacity(0.08), // 🔥 dynamic background
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isHighlighted
              ? plan
                    .color // 🔥 strong for premium
              : plan.color.withOpacity(0.3),
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: plan.color.withOpacity(0.15), // 🔥 FIXED
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(plan.icon, color: plan.color), // 🔥 FIXED
                  ),
                  const SizedBox(width: 10),
                  Text(
                    plan.name,
                    style: TextStyle(
                      color: plan.color, // 🔥 dynamic
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              /// 🔥 MOST POPULAR
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: plan.color, // 🔥 solid color
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Most Popular",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          /// 🔹 PRICE
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan.price,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 5),
              const Text("/month", style: TextStyle(color: Colors.blueGrey)),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "or ${plan.yearly}",
            style: const TextStyle(color: Colors.blueGrey),
          ),

          const SizedBox(height: 16),

          /// 🔹 FEATURES
          ...plan.features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.check, color: plan.color, size: 18), // 🔥 FIXED
                  const SizedBox(width: 8),
                  Text(f),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔹 BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: plan.isCurrent ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: plan.isCurrent
                    ? Colors
                          .grey
                          .shade400 // 🔥 disabled
                    : plan.color, // 🔥 dynamic
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Text(
                plan.isCurrent ? "Current Plan" : "Upgrade Now",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
