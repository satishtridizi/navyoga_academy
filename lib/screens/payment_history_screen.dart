import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/payments_models.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:navyoga_academy/widgets/payment_history_card.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final List<PaymentHistory> payments;

  const PaymentHistoryScreen({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment History")),
      body: AppBackground(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            return AnimatedItem(
              index: index,
              child: paymentHistoryCard(payments[index]),
            );
          },
        ),
      ),
    );
  }
}
