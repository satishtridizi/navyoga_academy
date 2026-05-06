import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/achievement_model.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel data;

  const AchievementCard({super.key, required this.data});

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

      child: SizedBox(
        width: double.infinity,

        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),

            /// 🌈 SOFT GRADIENT
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.green.withOpacity(0.10), Colors.white],
            ),

            border: Border.all(
              color: Colors.green.withOpacity(0.25),
              width: 1.5,
            ),

            /// 🌫 PREMIUM SHADOW
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Column(
            children: [
              /// 🎉 EMOJI
              Animate(
                effects: const [
                  ScaleEffect(
                    begin: Offset(0.7, 0.7),
                    end: Offset(1, 1),
                    duration: Duration(milliseconds: 700),
                  ),
                ],

                child: Text(data.emoji, style: const TextStyle(fontSize: 42)),
              ),

              const SizedBox(height: 16),

              /// 🔥 TITLE
              Text(
                data.title,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1E1B39),
                ),
              ),

              const SizedBox(height: 10),

              /// 🔹 SUBTITLE
              Text(
                data.subtitle,
                textAlign: TextAlign.center,

                style: const TextStyle(color: Colors.blueGrey, height: 1.4),
              ),

              const SizedBox(height: 18),

              /// 📅 DATE CHIP
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.green,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      data.date,

                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
