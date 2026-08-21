import 'package:flutter/material.dart';

class ReferralCard extends StatelessWidget {
  const ReferralCard(this.value, this.title, this.color, this.badge, {super.key});

  final String value;
  final String title;
  final Color color;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.22),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(_getIcon(title), color: Colors.white, size: 19),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String label) {
    if (label.contains('Referral')) return Icons.group_outlined;
    if (label.contains('Badge')) return Icons.emoji_events_outlined;
    if (label.contains('Balance')) return Icons.account_balance_wallet_outlined;
    return Icons.currency_rupee_rounded;
  }
}
