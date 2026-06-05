import 'package:flutter/material.dart';

class IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const IconBox(this.icon, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10), // reduced from 12
      ),
      child: Icon(
        icon,
        color: color,
        size: 14, // reduced from 18
      ),
    );
  }
}
