import 'package:flutter/material.dart';

class SettingsPrivacySection extends StatelessWidget {
  final List<Map<String, dynamic>> privacyOptions;

  final Function(String title)? onOptionTap;

  const SettingsPrivacySection({
    super.key,
    required this.privacyOptions,
    this.onOptionTap,
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
              Icon(Icons.shield_outlined, color: Colors.deepOrange),

              SizedBox(width: 8),

              Text(
                "Privacy & Data",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...privacyOptions.map((item) {
            return GestureDetector(
              onTap: () {
                if (onOptionTap != null) {
                  onOptionTap!(item["title"]);
                }
              },

              child: Container(
                width: double.infinity,

                margin: const EdgeInsets.only(bottom: 12),

                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),

                decoration: BoxDecoration(
                  color: Colors.grey.shade50,

                  borderRadius: BorderRadius.circular(25),

                  border: Border.all(color: Colors.deepOrange.withOpacity(.2)),
                ),

                child: Text(
                  item["title"],

                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,

                    color: item["isDanger"] ? Colors.red : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
