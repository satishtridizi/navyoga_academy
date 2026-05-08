import 'package:flutter/material.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';

class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 4,
      appBar: AppBar(title: const Text("Redeem Rewards")),
      body: const Center(child: Text("Redeem Flow Coming Soon 🚀")),
    );
  }
}
