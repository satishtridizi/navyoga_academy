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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffF5D8CB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepOrange],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(width: 12),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff202033),
                  ),
                ),

                const SizedBox(height: 2),

                if (user.email.isNotEmpty)
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff64748B),
                      fontSize: 12,
                    ),
                  ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      size: 18,
                      color: Color(0xff64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Joined ${user.date}",
                      style: const TextStyle(
                        color: Color(0xff64748B),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),


          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statusBadge(user.status),

              const SizedBox(height: 8),

              Text(
                "₹ ${user.amount}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff202033),
                ),
              ),

              const SizedBox(height: 8),

              _earningBadge(user.earning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isPending = status.toLowerCase() == "pending";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xffFFF1CC) : const Color(0xffDDE8FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPending ? const Color(0xffF4D87A) : const Color(0xffB8CCFF),
        ),
      ),
      child: Text(
        status.toLowerCase(),
        style: TextStyle(
          color: isPending ? const Color(0xffB77700) : const Color(0xff2155F5),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _earningBadge(String earning) {
    final isPending = earning.toLowerCase() == "pending";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xffFBE6D2) : const Color(0xffD4F0DA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        earning.toLowerCase(),
        style: TextStyle(
          color: isPending ? const Color(0xffD35400) : const Color(0xff008A2E),
          fontWeight: FontWeight.w600,
        ),
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
