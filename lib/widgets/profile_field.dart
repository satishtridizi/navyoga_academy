import 'package:flutter/material.dart';

class ProfileField extends StatelessWidget {
  final Map<String, dynamic> item;

  const ProfileField(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final multi = (item["isMultiline"] ?? false) as bool;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LABEL
          Text(
            item["label"] as String,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xff1E1B39),
            ),
          ),

          const SizedBox(height: 8),

          /// FIELD
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: multi ? 22 : 14,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffEEF1F5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withOpacity(.25)),
            ),
            child: Row(
              crossAxisAlignment: multi
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                if (item["icon"] != null) ...[
                  Icon(item["icon"], size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                ],

                Expanded(
                  child: Text(
                    item["value"] as String,
                    style: const TextStyle(
                      color: Color(0xff64748B),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
