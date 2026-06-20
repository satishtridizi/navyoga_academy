import 'package:flutter/material.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';

class EnrollmentSuccessScreen extends StatelessWidget {
  const EnrollmentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classData = ModalRoute.of(context)!.settings.arguments as ClassModel;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 120),

            const SizedBox(height: 20),

            const Text(
              "Enrollment Successful",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text("Your payment has been verified."),

            const SizedBox(height: 30),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.deepOrange,
                ),
                title: Text(classData.title),
                subtitle: Text(classData.trainer),
                trailing: const Icon(Icons.arrow_forward_ios),

                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.liveClass, // change later if needed
                    arguments: classData,
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.myClasses,
                  (route) => false,
                );
              },
              child: const Text("Go To Classes"),
            ),
          ],
        ),
      ),
    );
  }
}
