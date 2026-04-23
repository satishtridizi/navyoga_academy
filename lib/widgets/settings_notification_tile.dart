import 'package:flutter/material.dart';

class SettingsNotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;

  final bool value;

  final ValueChanged<bool> onChanged;

  const SettingsNotificationTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(subtitle, style: const TextStyle(color: Colors.blueGrey)),
              ],
            ),
          ),

          Switch(
            value: value,
            activeColor: Colors.purple,

            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
