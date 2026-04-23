import 'package:flutter/material.dart';
import '../models/referral_stat_model.dart';

class ReferralStatCard extends StatelessWidget {
  final ReferralStatModel stat;

  const ReferralStatCard({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: stat.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stat.title, style: TextStyle(color: Colors.blueGrey)),
              SizedBox(height: 6),
              Text(
                stat.value,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          CircleAvatar(
            backgroundColor: stat.iconBg,
            radius: 28,
            child: Icon(stat.icon, color: stat.iconColor),
          ),
        ],
      ),
    );
  }
}
