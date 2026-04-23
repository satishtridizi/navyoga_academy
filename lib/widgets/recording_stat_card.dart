import 'package:flutter/material.dart';
import '../models/recording_stat_model.dart';

class StatsCard extends StatelessWidget {
  final RecordingStatModel stat;

  const StatsCard({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(child: Text(stat.title));
  }
}
