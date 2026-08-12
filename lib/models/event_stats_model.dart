class EventStatsModel {
  final int total;
  final int registered;
  final int upcoming;
  final int featured;

  const EventStatsModel({
    required this.total,
    required this.registered,
    required this.upcoming,
    required this.featured,
  });

  const EventStatsModel.empty()
      : total = 0,
        registered = 0,
        upcoming = 0,
        featured = 0;

  factory EventStatsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EventStatsModel(
      total: _toInt(json['total']),
      registered: _toInt(json['registered']),
      upcoming: _toInt(json['upcoming']),
      featured: _toInt(json['featured']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}