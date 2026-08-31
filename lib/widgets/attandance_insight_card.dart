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


  Widget _simpleInsightCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),

              Container(
                padding: const EdgeInsets.all(8),
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
                child: Icon(data.icon, color: data.color, size: 14),
              ),
            ],
          ),

          const SizedBox(height: 8),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

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
                      fontSize: 12,
                    ),
                  ),
                ],
              ),


              Text(
                data.value + (data.unit.isNotEmpty ? " ${data.unit}" : ""),
                style: const TextStyle(
                  fontSize: 15,
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


  Widget _streakCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.orange[50],

        border: Border.all(color: Colors.orange.shade200),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
                  size: 32,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Practice Streak",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text("days"),
                ],
              ),
            ],
          ),

          SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(10),
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


  Widget _goalProgressCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.green,
                child: Icon(Icons.gps_fixed, color: Colors.white, size: 26),
              ),

              SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Monthly Goal Progress",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      style: const TextStyle(fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),

              Text(
                data.value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          LinearProgressIndicator(
            value: .85,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(Colors.green),
          ),

          SizedBox(height: 8),

          Align(alignment: Alignment.centerRight, child: Text(data.extra)),
        ],
      ),
    );
  }


  Widget _achievementCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        color: Colors.teal[50],
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
            radius: 28,
            backgroundColor: Colors.teal.withOpacity(.12),
            child: Icon(Icons.workspace_premium, color: Colors.teal, size: 42),
          ),

          SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Excellent Attendance!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  data.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                fontSize: 20,
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
