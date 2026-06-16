import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/settings_security_field_model.dart';

class SettingsSecuritySection extends StatelessWidget {
  final List<SecurityField> securityFields;
  //final bool twoFactorEnabled;
  final ValueChanged<bool> onTwoFactorChanged;
  final VoidCallback onUpdatePassword;

  // ✅ ADD THESE THREE
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;

  const SettingsSecuritySection({
    super.key,
    required this.securityFields,
    //required this.twoFactorEnabled,
    required this.onTwoFactorChanged,
    required this.onUpdatePassword,
    // ✅ ADD THESE THREE
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
  });

  // ✅ Map each field index to its controller
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

          // ✅ Use indexed map to attach the right controller to each field
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
                  controller: _controllerFor(entry.key), // ✅ connected
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

          // const SizedBox(height: 20),

          // Container(height: 1, color: Colors.deepOrange.withOpacity(.2)),

          // const SizedBox(height: 16),

          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     border: Border.all(color: Colors.deepOrange.withOpacity(.2)),
          //     borderRadius: BorderRadius.circular(18),
          //   ),
          //   child: Row(
          //     children: [
          //       const Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               "Two-Factor Authentication",
          //               style: TextStyle(fontWeight: FontWeight.bold),
          //             ),
          //             SizedBox(height: 4),
          //             Text(
          //               "Add an extra layer of security",
          //               style: TextStyle(color: Colors.blueGrey),
          //             ),
          //           ],
          //         ),
          //       ),
          //       Switch(value: twoFactorEnabled, onChanged: onTwoFactorChanged),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
