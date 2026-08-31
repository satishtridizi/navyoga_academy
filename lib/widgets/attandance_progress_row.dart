import 'package:flutter/material.dart';
import '../models/progress_model.dart';

class ProgressRow extends StatelessWidget {
  final ProgressModel data;

  const ProgressRow(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),

      child: Column(
        children: [

          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff1E1B39),
                  ),
                ),
              ),

              Text(
                data.sub1,
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 14),

              Text(
                data.sub2,
                style: const TextStyle(color: Color(0xff64748B), fontSize: 16),
              ),
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
                        minHeight: 12,
                        backgroundColor: Color(0xffD9DEE7),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xff17B978),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Text(
                "${(data.progress * 100).toInt()}%",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
