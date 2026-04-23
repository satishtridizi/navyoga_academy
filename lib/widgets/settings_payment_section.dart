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
          /// 🔥 HEADER
          Row(
            children: const [
              Icon(Icons.credit_card, color: Colors.deepOrange),
              SizedBox(width: 8),
              Text(
                "Payment & Billing",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// 🔥 MEMBERSHIP CARD (UPDATED)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffF4F7F6), // ✅ soft bg
              border: Border.all(color: Colors.green, width: 1.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      paymentData["plan"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    /// 🔥 ACTIVE PILL
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Active",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  "Active until ${paymentData["validTill"]}",
                  style: const TextStyle(color: Colors.blueGrey),
                ),

                const SizedBox(height: 14),

                /// 🔥 PRICE ROW (NEW)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Monthly Plan",
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                    Text(
                      paymentData["price"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🔥 PAYMENT METHOD (UPDATED BUTTON)
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
                    const Text(
                      "Payment Method",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(paymentData["card"]),
                  ],
                ),

                /// 🔥 ROUNDED BUTTON
                OutlinedButton(
                  onPressed: onManagePayment,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Manage"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🔥 AUTO RENEW (UPDATED)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepOrange.withOpacity(.2)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                /// TEXT BLOCK
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Auto-Renewal",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Automatically renew your membership",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ),

                /// SWITCH
                Switch(
                  value: paymentData["autoRenew"],
                  onChanged: onAutoRenewChanged,
                  activeColor: Colors.purple,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🔥 BOTTOM BUTTON (FULL WIDTH STYLE)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xffF3F3F3),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: GestureDetector(
              onTap: onViewPaymentDetails,
              child: const Text(
                "View Full Payment Details",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
