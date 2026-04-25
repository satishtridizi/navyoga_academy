import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/class_model.dart';

import '../routes/app_routes.dart';

class CourseCard extends StatelessWidget {
  final ClassModel data;

  const CourseCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = data.color;
    final bool isCompleted = data.isCompleted;
    final bool isGradientProgress = data.isGradientProgress;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.myClasses, arguments: data);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),

          border: Border(top: BorderSide(color: mainColor, width: 4)),

          boxShadow: [
            BoxShadow(color: mainColor.withOpacity(.15), blurRadius: 12),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),

                      const SizedBox(width: 4),

                      Text(data.rating),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(data.trainer, style: const TextStyle(color: Colors.blueGrey)),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                chip(data.level, mainColor.withOpacity(.15), mainColor),

                chip("⏱ ${data.duration}", Colors.grey.shade200, Colors.black),

                chip("👥 ${data.students}", Colors.grey.shade200, Colors.black),

                if (isCompleted)
                  chip("✓ Completed", Colors.green.shade100, Colors.green),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Course Progress"),

                Text(
                  "${(data.progress * 100).toInt()}%",
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            isGradientProgress
                ? Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: data.progress,

                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.pink],
                          ),
                        ),
                      ),
                    ),
                  )
                : LinearProgressIndicator(
                    value: data.progress,
                    color: mainColor,
                    minHeight: 8,
                  ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 10),

            const Text("Schedule", style: TextStyle(color: Colors.grey)),

            Text(data.schedule),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.next,
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.liveClass,
                      arguments: data,
                    );
                  },

                  icon: const Icon(Icons.play_arrow),

                  label: const Text("Join Class"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(text, style: TextStyle(color: fg)),
    );
  }
}
