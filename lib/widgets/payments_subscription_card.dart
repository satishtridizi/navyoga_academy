import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/payments_models.dart';
import 'package:navyoga_academy/widgets/payments_common_widgets.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription sub;

  const SubscriptionCard({super.key, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.deepOrange, width: 1.5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Plan: ${sub.planName}",
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "Active since ${sub.activeSince}",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 77, 88, 93),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Active",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),


          infoBox("Monthly Price", sub.price, const Color(0xfff3e6df)),
          infoBox(
            "Next Billing Date",
            sub.nextBilling,
            const Color(0xffebe7f2),
          ),
          infoBox("Billing Cycle", sub.billingCycle, const Color(0xffe3efea)),

          const SizedBox(height: 10),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 1,
            color: Colors.deepOrange.withOpacity(0.2),
          ),

          const SizedBox(height: 10),

          const Text(
            "Plan Features",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
          ),

          const SizedBox(height: 8),

          ...sub.features.map((f) => feature(f)),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(child: outlineButton("Change Billing Cycle")),
              const SizedBox(width: 10),
              Expanded(child: outlineButton("Cancel Subscription", red: true)),
            ],
          ),
        ],
      ),
    );
  }
}
