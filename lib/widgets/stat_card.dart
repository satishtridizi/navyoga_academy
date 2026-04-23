import 'package:flutter/material.dart';
import '../models/attendance_stat_model.dart';

class StatCard extends StatelessWidget {
  final AttendanceStatModel data;

  const StatCard(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          /// Title
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xff64748B),
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          /// Icon + Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(data.icon, color: data.color, size: 26),
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
    );
  }
}
