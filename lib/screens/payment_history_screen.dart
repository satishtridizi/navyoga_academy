import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/payments_models.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/widgets/payment_history_card.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final List<PaymentHistory> payments;

  const PaymentHistoryScreen({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 4,
      appBar: AppBar(title: const Text("Payment History")),
      body: ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          return AnimatedItem(
            index: index,
            child: paymentHistoryCard(payments[index]),
          );
        },
      ),
    );
  }
}
