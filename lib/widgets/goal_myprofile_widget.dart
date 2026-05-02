import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/goal_model.dart';

class GoalWidget extends StatelessWidget {
  final GoalModel data;

  const GoalWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final percent = (data.progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 TITLE + %
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1E1B39),
                ),
              ),
              Text(
                "$percent%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1E1B39),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// 🔥 PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: data.progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(Colors.deepPurple),
            ),
          ),

          const SizedBox(height: 8),

          /// 🔥 SUBTITLE
          Text(data.subtitle, style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }
}
