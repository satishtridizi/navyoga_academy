class CourseModel {
  final String title;
  final String description;
  final String instructor;

  final String duration;
  final String lessons;

  final String level;
  final String status;

  final String rating;
  final String progressLabel;

  final String image;

  final double progress;

  const CourseModel({
    required this.title,
    required this.description,
    required this.instructor,

    required this.duration,
    required this.lessons,

    required this.level,
    required this.status,

    required this.rating,
    required this.progressLabel,

    required this.image,

    required this.progress,
  });
}
