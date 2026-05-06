import 'package:flutter/material.dart';
import '../models/insight_model.dart';

class InsightCard extends StatelessWidget {
  final InsightModel data;

  const InsightCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    switch (data.type) {
      case "streak":
        return _streakCard();

      case "progress":
        return _goalProgressCard();

      case "achievement":
        return _achievementCard();

      default:
        return _simpleInsightCard();
    }
  }

  /// ----------------------------
  /// IMAGE 6 style
  /// ----------------------------

  Widget _simpleInsightCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),

      decoration: BoxDecoration(
        color: const Color(0xffFCFBFA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔝 TITLE + ICON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xff64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(.18),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: data.color.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(data.icon, color: data.color, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// 🔻 SUBTITLE + VALUE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              /// LEFT (subtitle + icon)
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      color: Color(0xff64748B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              /// RIGHT (value)
              Text(
                data.value + (data.unit.isNotEmpty ? " ${data.unit}" : ""),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1E1B39),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ----------------------------
  /// IMAGE 7 Practice Streak
  /// ----------------------------

  Widget _streakCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.deepOrange, Colors.orange],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: data.color.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 48,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Practice Streak",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(data.subtitle, style: TextStyle(height: 1.5)),
                  ],
                ),
              ),

              Column(
                children: [
                  Text(
                    data.value,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text("days"),
                ],
              ),
            ],
          ),

          SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: data.color.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Personal Best"),
                Text("18 days", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ----------------------------
  /// IMAGE 8 Monthly Goal Progress
  /// ----------------------------

  Widget _goalProgressCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green,
                child: Icon(Icons.gps_fixed, color: Colors.white, size: 40),
              ),

              SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monthly Goal Progress",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 12),

                    Text(data.subtitle),
                  ],
                ),
              ),

              Text(
                data.value,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 30),

          LinearProgressIndicator(
            value: .85,
            minHeight: 14,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(Colors.green),
          ),

          SizedBox(height: 8),

          Align(alignment: Alignment.centerRight, child: Text(data.extra)),
        ],
      ),
    );
  }

  /// ----------------------------
  /// IMAGE 9 Excellent Attendance
  /// ----------------------------

  Widget _achievementCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.teal.withOpacity(.12),
            child: Icon(Icons.workspace_premium, color: Colors.teal, size: 42),
          ),

          SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Excellent Attendance!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 14),

                Text(data.subtitle, style: TextStyle(height: 1.5)),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(.12),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: data.color.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              data.value,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
