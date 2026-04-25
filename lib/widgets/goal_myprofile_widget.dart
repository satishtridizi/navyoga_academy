import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/goal_model.dart';

class GoalWidget extends StatelessWidget {
  final GoalModel data;

  const GoalWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text("${(data.progress * 100).toInt()}%"),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: data.progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation(Colors.purple),
          ),
          const SizedBox(height: 6),
          Text(data.subtitle, style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }
}
