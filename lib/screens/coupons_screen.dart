import 'package:flutter/material.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Coupons")),

      body: const Center(
        child: Text(
          "Apply coupons during checkout",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
