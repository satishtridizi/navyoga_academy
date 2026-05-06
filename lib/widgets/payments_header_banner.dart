import 'package:flutter/material.dart';

Widget HeaderBanner() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text(
        "Payments &\nSubscription",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ),
      SizedBox(height: 8),
      Text(
        "Manage your subscription plans and\npayment methods",
        style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 0, 0, 0)),
      ),
    ],
  );
}
