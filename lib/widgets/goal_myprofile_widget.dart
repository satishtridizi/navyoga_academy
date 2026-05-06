import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:navyoga_academy/models/goal_model.dart';

class GoalWidget extends StatelessWidget {
  final GoalModel data;

  const GoalWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final percent = (data.progress * 100).toInt();

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
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),

          /// 🌈 SOFT GRADIENT
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 203, 188, 228).withOpacity(0.08),
              Colors.white,
            ],
          ),

          border: Border.all(color: Colors.deepPurple.withOpacity(0.12)),

          /// 🌫 SHADOW
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 TITLE + %
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Expanded(
                  child: Text(
                    data.title,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E1B39),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    "$percent%",

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// 🔥 ANIMATED PROGRESS BAR
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: data.progress),

              duration: const Duration(milliseconds: 900),

              curve: Curves.easeOutCubic,

              builder: (context, value, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 10,

                    backgroundColor: Colors.grey.shade200,

                    valueColor: const AlwaysStoppedAnimation(Colors.deepPurple),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            /// 🔥 SUBTITLE
            Text(
              data.subtitle,

              style: const TextStyle(color: Colors.blueGrey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
