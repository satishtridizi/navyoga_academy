import 'package:navyoga_academy/models/class_model.dart';

class EnrollmentService {
  static List<ClassModel> enrolledClasses = [];

  static int totalClasses = 0;
  static int achievementsCount = 0;

  static int recordingsWatched = 0;
  static int hoursCompleted = 0;
  static double attendanceRate = 0;

  static String memberSince = "";
  static String skillLevel = "Beginner";
}
