import 'package:flutter/material.dart';
import '../models/referral_user_model.dart';

class ReferralUserCard extends StatelessWidget {
  final ReferralUserModel user;

  const ReferralUserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color earningColor;

    switch (user.status) {
      case "completed":
        statusColor = Colors.green;
        break;
      case "active":
        statusColor = Colors.blue;
        break;
      case "pending":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    switch (user.earning) {
      case "earned":
        earningColor = Colors.green;
        break;
      case "pending":
        earningColor = Colors.orange;
        break;
      case "redeemed":
        earningColor = Colors.purple;
        break;
      default:
        earningColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xffF2DED2)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          /// AVATAR
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.orange],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              user.name[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.blueGrey),
                ),

                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        user.date,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// RIGHT SIDE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _chip(user.status, statusColor),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    user.amount,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  _chip(user.earning, earningColor),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
