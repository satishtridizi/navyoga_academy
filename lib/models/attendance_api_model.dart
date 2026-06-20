import 'package:navyoga_academy/models/ClassWiseStatModel.dart';
import 'package:navyoga_academy/models/MonthlyStatModel.dart';

class AttendanceApiModel {
  final int attendanceRate;
  final int classesAttended;
  final int missedClasses;
  final int? streak;
  final int? totalMinutesThisMonth;
  final int? previousMonthMinutes;
  final int? monthlyGoalMinutes;
  final List<MonthlyStatModel> monthlyStats;
  final List<ClassWiseStatModel> classWiseStats;

  AttendanceApiModel({
    required this.attendanceRate,
    required this.classesAttended,
    required this.missedClasses,
    this.streak,
    this.totalMinutesThisMonth,
    this.previousMonthMinutes,
    this.monthlyGoalMinutes,
    required this.monthlyStats,
    required this.classWiseStats,
  });

  factory AttendanceApiModel.fromJson(Map<String, dynamic> json) {
    return AttendanceApiModel(
      monthlyStats:
          (json["monthlyStats"] as List<dynamic>?)
              ?.map((e) => MonthlyStatModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      classWiseStats:
          (json["classWiseStats"] as List<dynamic>?)
              ?.map(
                (e) => ClassWiseStatModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      attendanceRate: json["attendanceRate"] ?? 0,
      classesAttended: json["classesAttended"] ?? 0,
      missedClasses: json["missedClasses"] ?? 0,
      streak: json["streak"],

      totalMinutesThisMonth: json["totalMinutesThisMonth"],

      previousMonthMinutes: json["previousMonthMinutes"],

      monthlyGoalMinutes: json["monthlyGoalMinutes"],
    );
  }
}
