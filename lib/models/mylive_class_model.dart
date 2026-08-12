class MyClassesResponse {
  const MyClassesResponse({
    required this.enrolled,
    required this.recordingDays,
    required this.classes,
  });

  final bool enrolled;
  final int recordingDays;
  final List<MyLiveClassModel> classes;

  factory MyClassesResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawClasses = json['classes'];

    return MyClassesResponse(
      enrolled: json['enrolled'] == true,
      recordingDays: _parseInt(
        json['recordingDays'],
      ),
      classes: rawClasses is List
          ? rawClasses
              .whereType<Map>()
              .map(
                (item) => MyLiveClassModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const <MyLiveClassModel>[],
    );
  }
}

class MyLiveClassModel {
  const MyLiveClassModel({
    required this.id,
    required this.title,
    required this.yogaType,
    required this.duration,
    required this.difficulty,
    required this.state,
    required this.rawData,
    this.description,
    this.scheduledAt,
    this.tutor,
    this.batch,
  });

  final String id;
  final String title;
  final String yogaType;
  final int duration;
  final String difficulty;
  final LiveClassState state;

  final String? description;
  final DateTime? scheduledAt;

  final LiveClassTutorModel? tutor;
  final LiveClassBatchModel? batch;

  final Map<String, dynamic> rawData;

  bool get isLive {
    return state == LiveClassState.live;
  }

  bool get isUpcoming {
    return state == LiveClassState.upcoming;
  }

  bool get isPast {
    return state == LiveClassState.past;
  }

  bool get canJoin {
    if (isLive) return true;
    if (scheduledAt == null) return false;

    final now = DateTime.now();
    final windowStart = scheduledAt!.subtract(const Duration(minutes: 15));
    final effectiveDuration = duration > 0 ? duration : 60;
    final endTime = scheduledAt!.add(Duration(minutes: effectiveDuration));

    return !now.isBefore(windowStart) && now.isBefore(endTime);
  }

  factory MyLiveClassModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final scheduledAt = _parseDateTime(
      json['scheduledAt'] ??
          json['scheduledDateTime'] ??
          json['startTime'] ??
          json['startDateTime'],
    );

    final duration = _parseInt(
      json['duration'],
    );

    return MyLiveClassModel(
      id: _parseString(
        json['id'] ??
            json['_id'] ??
            json['liveClassId'] ??
            json['classId'],
      ),
      title: _parseString(
        json['title'] ??
            json['name'] ??
            json['className'],
        fallback: 'Live Class',
      ),
      yogaType: _parseString(
        json['yogaType'] ??
            json['type'] ??
            json['category'],
      ),
      duration: duration,
      difficulty: _parseString(
        json['difficulty'] ??
            json['level'],
      ),
      description: _parseNullableString(
        json['description'],
      ),
      scheduledAt: scheduledAt,
      tutor: _parseTutor(
        json['tutor'] ??
            json['instructor'],
      ),
      batch: _parseBatch(
        json['batch'],
      ),
      state: _resolveState(
        json: json,
        scheduledAt: scheduledAt,
        duration: duration,
      ),
      rawData: Map<String, dynamic>.from(
        json,
      ),
    );
  }

  static LiveClassState _resolveState({
    required Map<String, dynamic> json,
    required DateTime? scheduledAt,
    required int duration,
  }) {
    final status = _parseString(
      json['state'] ??
          json['status'] ??
          json['classStatus'] ??
          json['liveStatus'],
    ).toUpperCase();

    if (<String>{
      'LIVE',
      'LIVE_NOW',
      'ONGOING',
      'IN_PROGRESS',
      'STARTED',
      'ACTIVE',
    }.contains(status)) {
      return LiveClassState.live;
    }

    if (<String>{
      'PAST',
      'COMPLETED',
      'ENDED',
      'FINISHED',
      'CANCELLED',
    }.contains(status)) {
      return LiveClassState.past;
    }

    final explicitLive =
        json['isLive'] ??
        json['live'] ??
        json['is_live'];

    if (_parseBool(explicitLive)) {
      return LiveClassState.live;
    }

    if (scheduledAt == null) {
      return LiveClassState.upcoming;
    }

    final now = DateTime.now();

    final effectiveDuration =
        duration > 0 ? duration : 60;

    final endTime = scheduledAt.add(
      Duration(
        minutes: effectiveDuration,
      ),
    );

    if (!now.isBefore(scheduledAt) &&
        now.isBefore(endTime)) {
      return LiveClassState.live;
    }

    if (!now.isBefore(endTime)) {
      return LiveClassState.past;
    }

    return LiveClassState.upcoming;
  }
}

class LiveClassTutorModel {
  const LiveClassTutorModel({
    required this.id,
    required this.tutorId,
    required this.name,
    required this.avatar,
    required this.specializations,
  });

  final String id;
  final String tutorId;
  final String name;
  final String? avatar;
  final List<String> specializations;

  factory LiveClassTutorModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawSpecializations =
        json['specializations'];

    return LiveClassTutorModel(
      id: _parseString(
        json['id'] ??
            json['_id'],
      ),
      tutorId: _parseString(
        json['tutorId'] ??
            json['userId'],
      ),
      name: _parseString(
        json['name'] ??
            json['fullName'] ??
            json['instructorName'],
        fallback: 'Instructor',
      ),
      avatar: _parseNullableString(
        json['avatar'] ??
            json['profileImage'] ??
            json['image'],
      ),
      specializations:
          rawSpecializations is List
              ? rawSpecializations
                  .map(
                    (item) =>
                        item.toString().trim(),
                  )
                  .where(
                    (item) =>
                        item.isNotEmpty,
                  )
                  .toList()
              : const <String>[],
    );
  }
}

class LiveClassBatchModel {
  const LiveClassBatchModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory LiveClassBatchModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return LiveClassBatchModel(
      id: _parseString(
        json['id'] ??
            json['_id'],
      ),
      name: _parseString(
        json['name'] ??
            json['batchName'],
      ),
    );
  }
}

enum LiveClassState {
  upcoming,
  live,
  past,
}

LiveClassTutorModel? _parseTutor(
  dynamic value,
) {
  if (value is Map<String, dynamic>) {
    return LiveClassTutorModel.fromJson(
      value,
    );
  }

  if (value is Map) {
    return LiveClassTutorModel.fromJson(
      Map<String, dynamic>.from(value),
    );
  }

  if (value is String &&
      value.trim().isNotEmpty) {
    return LiveClassTutorModel(
      id: '',
      tutorId: '',
      name: value.trim(),
      avatar: null,
      specializations:
          const <String>[],
    );
  }

  return null;
}

LiveClassBatchModel? _parseBatch(
  dynamic value,
) {
  if (value is Map<String, dynamic>) {
    return LiveClassBatchModel.fromJson(
      value,
    );
  }

  if (value is Map) {
    return LiveClassBatchModel.fromJson(
      Map<String, dynamic>.from(value),
    );
  }

  if (value is String &&
      value.trim().isNotEmpty) {
    return LiveClassBatchModel(
      id: '',
      name: value.trim(),
    );
  }

  return null;
}

DateTime? _parseDateTime(
  dynamic value,
) {
  if (value == null) {
    return null;
  }

  if (value is DateTime) {
    return value.toLocal();
  }

  if (value is int) {
    final milliseconds =
        value.toString().length <= 10
            ? value * 1000
            : value;

    return DateTime
        .fromMillisecondsSinceEpoch(
          milliseconds,
        )
        .toLocal();
  }

  if (value is num) {
    final numericValue = value.toInt();

    final milliseconds =
        numericValue.toString().length <= 10
            ? numericValue * 1000
            : numericValue;

    return DateTime
        .fromMillisecondsSinceEpoch(
          milliseconds,
        )
        .toLocal();
  }

  final rawValue = value.toString().trim();

  if (rawValue.isEmpty) {
    return null;
  }

  return DateTime.tryParse(
    rawValue,
  )?.toLocal();
}

int _parseInt(
  dynamic value,
) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.round();
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

bool _parseBool(
  dynamic value,
) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  final normalized =
      value?.toString().trim().toLowerCase();

  return normalized == 'true' ||
      normalized == '1' ||
      normalized == 'yes';
}

String _parseString(
  dynamic value, {
  String fallback = '',
}) {
  final result =
      value?.toString().trim() ?? '';

  return result.isEmpty
      ? fallback
      : result;
}

String? _parseNullableString(
  dynamic value,
) {
  final result =
      value?.toString().trim() ?? '';

  return result.isEmpty
      ? null
      : result;
}