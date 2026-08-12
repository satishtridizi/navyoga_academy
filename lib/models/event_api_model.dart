class EventApiModel {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final bool featured;
  final DateTime? date;
  final String duration;
  final String location;
  final int capacity;
  final double price;
  final int occupancy;
  final bool isEnrolled;

  const EventApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.featured,
    required this.date,
    required this.duration,
    required this.location,
    required this.capacity,
    required this.price,
    required this.occupancy,
    required this.isEnrolled,
  });

  factory EventApiModel.fromJson(
    Map<String, dynamic> json, {
    bool isEnrolled = false,
  }) {
    return EventApiModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Event',
      description: json['description']?.toString() ?? '',
      thumbnail: _buildImageUrl(json['thumbnail']),
      featured: json['featured'] == true,
      date: DateTime.tryParse(
        json['date']?.toString() ?? '',
      )?.toLocal(),
      duration: json['duration']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      capacity: _toInt(json['capacity']),
      price: _toDouble(json['price']),
      occupancy: _toInt(json['occupancy']),
      isEnrolled: isEnrolled,
    );
  }

  EventApiModel copyWith({
    bool? isEnrolled,
  }) {
    return EventApiModel(
      id: id,
      title: title,
      description: description,
      thumbnail: thumbnail,
      featured: featured,
      date: date,
      duration: duration,
      location: location,
      capacity: capacity,
      price: price,
      occupancy: occupancy,
      isEnrolled: isEnrolled ?? this.isEnrolled,
    );
  }

  static String _buildImageUrl(dynamic value) {
    const baseUrl =
        'https://d20fx2gucmvzba.cloudfront.net';

    final path = value?.toString().trim() ?? '';

    if (path.isEmpty) return '';

    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    return path.startsWith('/')
        ? '$baseUrl$path'
        : '$baseUrl/$path';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}