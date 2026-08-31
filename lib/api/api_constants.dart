class ApiConstants {
  static const String prodBaseUrl = 'https://dist.navyogawellness.com';
  static const String prodLiveApiBaseUrl = 'https://d20fx2gucmvzba.cloudfront.net';
  static const String prodLiveRecordingBaseUrl = 'https://navyoga.s3.ap-south-1.amazonaws.com/assets';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: prodBaseUrl,
  );

  static const String liveApiBaseUrl = String.fromEnvironment(
    'LIVE_API_BASE_URL',
    defaultValue: prodLiveApiBaseUrl,
  );

  static const String liveRecordingBaseUrl = String.fromEnvironment(
    'LIVE_RECORDING_BASE_URL',
    defaultValue: prodLiveRecordingBaseUrl,
  );


  static const String studentDashboard =
      '/api/dashboard/student';

  static String get studentDashboardUrl =>
      '$baseUrl$studentDashboard';


  static const String studentProfile =
      '/api/auth/student/me';

  static const String changePassword =
      '/api/auth/student/change-password';

  static const String deleteAccount =
      '/api/auth/student/delete';

  static const String downloadData =
      '/api/auth/student/export';


  static const String platform = '/api/platform';


  static const String myClasses =
      '/api/live/my-classes';

  static const String livePlans =
      '/api/live/plans';

  static const String myEnrollment =
      '/api/live/my-enrollment';

  static String get myClassesUrl =>
      '$liveApiBaseUrl$myClasses';

  static String get myEnrollmentUrl =>
      '$liveApiBaseUrl$myEnrollment';

  static String attendClassUrl(String classId) =>
      '$liveApiBaseUrl/api/live/$classId/attend';

  static String buildLiveMediaUrl(String path) {
    final value = path.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }


    final normalizedPath = value.startsWith('/') ? value : '/$value';
    if (normalizedPath.startsWith('/assets/')) {
      return 'https://navyoga.s3.ap-south-1.amazonaws.com$normalizedPath';
    }
    return '$liveRecordingBaseUrl$normalizedPath';
  }

  static const String studentClassAttendanceUrl =
      '$baseUrl/api/attendance/students/me/classes';


  static const String selfPacedPlans =
      '/api/self-paced/plans';

  static const String selfPacedModules =
      '/api/self-paced/modules';

  static const String selfPacedSubscription =
      '/api/self-paced/my-subscription';


  static const String yttLivePlans =
      '/api/ytt-live/plans';

  static const String yttLiveEnrollments =
      '/api/ytt-live/my-enrollments';


  static const String yttRecordedPlans =
      '/api/ytt-recorded/plans';

  static const String yttRecordedEnrollments =
      '/api/ytt-recorded/my-enrollments';


  static const String renewalPrompt =
      '/api/subscriptions/renewal-prompt';


  static const String upcomingEvents =
      '/api/events/upcoming';

  static const String pastEvents =
      '/api/events/past';

  static const String eventStats =
      '/api/events/upcoming/stats';

  static const String myEventEnrollments =
      '/api/events/my-enrollments';

  static String upcomingEventsWithLimit({
    int limit = 20,
  }) {
    return '$upcomingEvents?limit=$limit';
  }

  static String pastEventsWithLimit({
    int limit = 10,
  }) {
    return '$pastEvents?limit=$limit';
  }

  static String enrollEvent(String eventId) {
    return '/api/events/$eventId/enroll';
  }


  static const String upcomingWorkshops =
      '/api/workshops/upcoming';

  static const String workshopStats =
      '/api/workshops/upcoming/stats';

  static const String myWorkshopEnrollments =
      '/api/workshops/my-enrolled-ids';

  static String upcomingWorkshopsWithLimit({
    int limit = 20,
  }) {
    return '$upcomingWorkshops?limit=$limit';
  }


  static const String initiatePayment =
      '/api/payments/initiate';

  static const String verifyPayment =
      '/api/payments/verify';


  static const String leads = '/leads';
  static const String batches = '/api/batches';
  static const String employees = '/api/employees';
  static const String financials = '/api/financials';
  static const String frontline = '/api/frontline';
  static const String students = '/api/students';
  static const String tutors = '/api/tutors';
  static const String workshops = '/api/workshops';


  static String buildUrl(String endpoint) {
    if (endpoint.startsWith('http://') ||
        endpoint.startsWith('https://')) {
      return endpoint;
    }

    if (endpoint.startsWith('/')) {
      return '$baseUrl$endpoint';
    }

    return '$baseUrl/$endpoint';
  }

  static String? buildMediaUrl(dynamic value) {
    final path = value?.toString().trim() ?? '';

    if (path.isEmpty) {
      return null;
    }

    return buildUrl(path);
  }
}
