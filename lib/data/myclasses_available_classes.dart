import 'package:flutter/material.dart';
import '../models/myclasses_class_model.dart';

List<ClassModel> availableClasses = [
  ClassModel(
    title: "Hot Yoga Basics",
    trainer: "Vikram Singh",
    rating: "4.5",
    level: "Beginner",
    duration: "60 min",
    students: "10/20",
    progress: 0.0,
    schedule: "Mon, Wed • 5:00 PM",
    next: "Enroll Now",
    color: Colors.green,
  ),

  ClassModel(
    title: "Aerial Yoga",
    trainer: "Meera Joshi",
    rating: "4.7",
    level: "Intermediate",
    duration: "55 min",
    students: "8/15",
    progress: 0.0,
    schedule: "Tue, Thu • 7:00 PM",
    next: "Enroll Now",
    color: Colors.orange,
  ),

  ClassModel(
    title: "Prenatal Yoga",
    trainer: "Priya Sharma",
    rating: "4.9",
    level: "All Levels",
    duration: "45 min",
    students: "12/15",
    progress: 0.0,
    schedule: "Mon, Fri • 10:00 AM",
    next: "Enroll Now",
    color: Colors.purple,
  ),
];
