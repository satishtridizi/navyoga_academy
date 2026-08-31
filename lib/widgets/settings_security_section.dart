import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/settings_security_field_model.dart';

class SettingsSecuritySection extends StatelessWidget {
  final List<SecurityField> securityFields;
  final ValueChanged<bool> onTwoFactorChanged;
  final VoidCallback onUpdatePassword;

  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;

  const SettingsSecuritySection({
    super.key,
    required this.securityFields,
    required this.onTwoFactorChanged,
    required this.onUpdatePassword,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
  });

  TextEditingController _controllerFor(int index) {
    switch (index) {
      case 0:
        return currentPasswordController;
      case 1:
        return newPasswordController;
      case 2:
        return confirmPasswordController;
      default:
        return TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lock_outline, color: Colors.deepOrange),
              SizedBox(width: 8),
              Text(
                "Security Settings",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            "Change Password",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 12),

          ...securityFields.asMap().entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.value.label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _controllerFor(entry.key),
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: entry.value.hint,
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Colors.deepOrange.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Colors.deepOrange.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            );
          }).toList(),

          Center(
            child: SizedBox(
              width: 330,
              child: ElevatedButton(
                onPressed: onUpdatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  "Update Password",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
