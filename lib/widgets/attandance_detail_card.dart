import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/detail_model.dart';
import 'package:navyoga_academy/widgets/attandance_icon_box.dart';

class DetailCard extends StatelessWidget {
  final DetailModel data;
  const DetailCard(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(data.title), IconBox(data.icon, data.color)],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: data.color),
              const SizedBox(width: 4),
              Text(data.subtitle),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              data.value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
