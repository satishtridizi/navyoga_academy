import 'package:flutter/material.dart';
import '../models/profile_stat_model.dart';

class ProfileStatCard extends StatelessWidget {
  final ProfileStat stat;

  const ProfileStatCard(this.stat, {super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,

      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },

      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xfff7f7f7),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: stat.color.withOpacity(.25),
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: stat.color.withOpacity(.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(stat.icon, color: stat.color, size: 18),
            ),

            const SizedBox(height: 16),


            Text(
              stat.title,
              style: const TextStyle(color: Color(0xff64748B), fontSize: 14),
            ),

            const SizedBox(height: 6),


            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stat.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E1B39),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
