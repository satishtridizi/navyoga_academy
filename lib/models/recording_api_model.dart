class RecordingApiModel {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String yogaType;
  final String level;
  final String videoUrl;

  const RecordingApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.yogaType,
    required this.level,
    required this.videoUrl,
  });

  factory RecordingApiModel.fromJson(Map<String, dynamic> json) {
    return RecordingApiModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      thumbnail:
          json['thumbnail']?.toString() ??
          json['thumbnailUrl']?.toString() ??
          '',
      yogaType:
          json['yogaType']?.toString() ??
          json['moduleTitle']?.toString() ??
          '',
      level: json['level']?.toString() ?? '',
      videoUrl:
          json['videoUrl']?.toString() ??
          json['recordingUrl']?.toString() ??
          json['url']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'yogaType': yogaType,
      'level': level,
      'videoUrl': videoUrl,
    };
  }

  RecordingApiModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnail,
    String? yogaType,
    String? level,
    String? videoUrl,
  }) {
    return RecordingApiModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      yogaType: yogaType ?? this.yogaType,
      level: level ?? this.level,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}