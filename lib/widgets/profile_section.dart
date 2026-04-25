import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final Widget child;

  const ProfileSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xfff7f7f7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(.25)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 12),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}
