import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/attendance_stat_model.dart';

class StatCard extends StatelessWidget {
  final AttendanceStatModel data;

  const StatCard(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 500)),

        SlideEffect(
          begin: Offset(0, 0.15),
          end: Offset(0, 0),
          duration: Duration(milliseconds: 500),
        ),
      ],

      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),

          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [data.color.withOpacity(0.12), Colors.white],
          ),

          border: Border.all(color: data.color.withOpacity(0.15)),

          boxShadow: [
            BoxShadow(
              color: data.color.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),

            BoxShadow(
              color: Colors.white.withOpacity(0.7),
              blurRadius: 6,
              offset: const Offset(-2, -2),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xff64748B),
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                Animate(
                  effects: const [
                    ScaleEffect(
                      begin: Offset(0.7, 0.7),
                      end: Offset(1, 1),
                      duration: Duration(milliseconds: 600),
                    ),
                  ],

                  child: Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: data.color.withOpacity(.15),
                      borderRadius: BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color: data.color.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Icon(data.icon, color: data.color, size: 26),
                  ),
                ),

                Text(
                  data.value,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E1B39),
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
