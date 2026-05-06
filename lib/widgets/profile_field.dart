import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/profile_field_model.dart';

class ProfileField extends StatelessWidget {
  final ProfileFieldModel item;
  final TextEditingController controller;

  const ProfileField(this.item, this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final multi = item.isMultiline;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LABEL
          Text(
            item.label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xff1E1B39),
            ),
          ),

          const SizedBox(height: 8),

          /// TEXT FIELD
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: TextField(
              controller: controller,
              maxLines: multi ? 3 : 1,
              decoration: InputDecoration(
                hintText: item.helperText, // ✅ HERE
                prefixIcon: item.icon != null ? Icon(item.icon) : null,

                filled: true,
                fillColor: const Color(0xffEEF1F5),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.orange.withOpacity(.25)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.orange.withOpacity(.25)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
