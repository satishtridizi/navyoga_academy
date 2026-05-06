import 'package:flutter/material.dart';
import 'package:navyoga_academy/widgets/app_background.dart';

class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Redeem Rewards")),
      body: AppBackground(
        child: const Center(child: Text("Redeem Flow Coming Soon 🚀")),
      ),
    );
  }
}
