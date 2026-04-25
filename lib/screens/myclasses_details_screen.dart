import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/class_model.dart';

class ClassDetailsScreen extends StatelessWidget {
  const ClassDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classData = ModalRoute.of(context)!.settings.arguments as ClassModel;

    return Scaffold(
      appBar: AppBar(title: Text(classData.title)),

      body: Center(
        // HERE
        child: Text(classData.title),
      ),
    );
  }
}
