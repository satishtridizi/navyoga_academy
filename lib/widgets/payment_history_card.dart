import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/payments_models.dart';

Widget paymentHistoryCard(PaymentHistory p) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(p.date, style: const TextStyle(color: Colors.blueGrey)),
          ],
        ),


        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              p.amount,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("Paid", style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ],
    ),
  );
}
