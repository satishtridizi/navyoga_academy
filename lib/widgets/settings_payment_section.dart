import 'package:flutter/material.dart';

class SettingsPaymentSection extends StatelessWidget {
  final Map<String, dynamic> paymentData;

  final ValueChanged<bool> onAutoRenewChanged;

  final VoidCallback onManagePayment;

  final VoidCallback onViewPaymentDetails;

  const SettingsPaymentSection({
    super.key,
    required this.paymentData,
    required this.onAutoRenewChanged,
    required this.onManagePayment,
    required this.onViewPaymentDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.deepOrange.withOpacity(.2)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: const [
              Icon(Icons.credit_card, color: Colors.deepOrange),

              SizedBox(width: 8),

              Text(
                "Payment & Billing",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 1.5),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(paymentData["plan"]),

                    Text(paymentData["status"]),
                  ],
                ),

                const SizedBox(height: 8),

                Text("Active until ${paymentData["validTill"]}"),

                const SizedBox(height: 8),

                Text(paymentData["price"]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepOrange.withOpacity(.2)),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text("Payment Method"),

                    Text(paymentData["card"]),
                  ],
                ),

                OutlinedButton(
                  onPressed: onManagePayment,

                  child: const Text("Manage"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepOrange.withOpacity(.2)),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Row(
              children: [
                const Expanded(child: Text("Auto-Renewal")),

                Switch(
                  value: paymentData["autoRenew"],

                  onChanged: onAutoRenewChanged,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,

            child: OutlinedButton(
              onPressed: onViewPaymentDetails,

              child: const Text("View Full Payment Details"),
            ),
          ),
        ],
      ),
    );
  }
}
