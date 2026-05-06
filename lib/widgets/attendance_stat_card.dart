import 'package:flutter/material.dart';
import '../models/attendance_stat_model.dart';

class StatCard extends StatelessWidget {
  final AttendanceStatModel data;

  const StatCard(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,

      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),

        decoration: BoxDecoration(
          color: const Color(0xffFCFBFA),
          borderRadius: BorderRadius.circular(26),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: const TextStyle(fontSize: 17, color: Color(0xff64748B)),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconBox(),

                Text(
                  data.value,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: data.color.withOpacity(.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(data.icon, color: data.color),
    );
  }
}
