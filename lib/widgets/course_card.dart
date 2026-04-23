import 'package:flutter/material.dart';
import '../models/referral_course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),

                child: Image.network(
                  course.image,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              if (course.completed == true)
                Positioned(top: 16, left: 16, child: _pill("Completed")),

              if (course.enrolled == true)
                Positioned(top: 16, right: 16, child: _pill("Enrolled")),

              Positioned(left: 14, bottom: 14, child: _pill(course.level)),

              Positioned(
                right: 14,
                bottom: 14,
                child: _pill("⭐ ${course.rating}"),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(26),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  course.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 12),

                Text(
                  course.description,
                  style: TextStyle(color: Colors.blueGrey),
                ),

                SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [Text(course.instructor), Text(course.duration)],
                ),

                if (course.progress != null) ...[
                  SizedBox(height: 18),

                  LinearProgressIndicator(value: course.progress!),

                  SizedBox(height: 20),
                ],

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: course.showEnrollButton == true
                          ? Colors.deepOrange
                          : Colors.deepPurple,
                    ),

                    child: Text(course.actionText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(text),
    );
  }
}
