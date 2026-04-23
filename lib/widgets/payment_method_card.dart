import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/payments_models.dart';

Widget paymentCard(PaymentMethod m) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.deepOrange.withValues(alpha: 0.25), // ✅ ORANGE BORDER
      ),
    ),
    child: Row(
      children: [
        /// ICON BOX
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.credit_card, color: Colors.purple),
        ),

        const SizedBox(width: 12),

        /// TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${m.brand} •••• ${m.number}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                "Expires ${m.expiry}",
                style: const TextStyle(
                  color: Color.fromARGB(255, 136, 135, 135),
                ),
              ),
            ],
          ),
        ),

        /// DEFAULT TAG
        if (m.isDefault)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 177, 177, 177).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("Default"),
          ),

        const SizedBox(width: 10),

        /// DELETE
        const Icon(Icons.close, color: Colors.red),
      ],
    ),
  );
}
