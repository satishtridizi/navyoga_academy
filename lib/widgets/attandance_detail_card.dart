import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/detail_model.dart';
import 'package:navyoga_academy/widgets/attandance_icon_box.dart';

class DetailCard extends StatelessWidget {
  final DetailModel data;
  const DetailCard(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 30, end: 0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,

      builder: (context, value, child) {
        return Transform.translate(offset: Offset(0, value), child: child);
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: Colors.black.withOpacity(0.08)),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff64748B),
                    letterSpacing: 0.2,
                  ),
                ),
                IconBox(data.icon, data.color),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.trending_up, size: 16, color: data.color),
                const SizedBox(width: 4),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xff64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                data.value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1E1B39),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
