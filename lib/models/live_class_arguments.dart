class LiveClassArguments {
  const LiveClassArguments({
    required this.classId,
    required this.studentName,
    required this.title,
    required this.duration,
    this.tutorName,
    this.yogaType,
    this.scheduledAt,
    this.rawData = const <String, dynamic>{},
  });

  final String classId;
  final String studentName;
  final String title;
  final int duration;

  final String? tutorName;
  final String? yogaType;
  final DateTime? scheduledAt;

  final Map<String, dynamic> rawData;
}