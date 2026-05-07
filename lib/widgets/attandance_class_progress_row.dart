import 'package:flutter/material.dart';
import '../models/progress_model.dart';

class ClassProgressRow extends StatelessWidget {
  final ProgressModel data;

  const ClassProgressRow(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xff1E1B39),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color(0xffF1F4F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 15,
                      color: const Color.fromARGB(255, 74, 103, 117),
                    ),

                    SizedBox(width: 4),

                    Text(data.sub1),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              Text(data.sub2, style: const TextStyle(color: Color(0xff64748B))),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: data.progress),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,

                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: Color(0xffD9DEE7),
                        valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 18),

              Text(
                "${(data.progress * 100).toInt()}%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
