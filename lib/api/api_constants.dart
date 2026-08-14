class ApiConstants {
  static const String baseUrl =
      "https://dist.navyogawellness.com";

  static const String liveApiBaseUrl =
      'https://d20fx2gucmvzba.cloudfront.net';

  static const String liveRecordingBaseUrl =
      'https://navyoga.s3.ap-south-1.amazonaws.com/assets';

  // ─────────────────────────────────────────────
  // Dashboard
  // ─────────────────────────────────────────────

  static const String studentDashboard =
      '/api/dashboard/student';

  static String get studentDashboardUrl =>
      '$baseUrl$studentDashboard';

  // ─────────────────────────────────────────────
  // Authentication & Profile
  // ─────────────────────────────────────────────

  static const String studentProfile =
      '/api/auth/student/me';

  static const String changePassword =
      '/api/auth/student/change-password';

  static const String deleteAccount =
      '/api/auth/student/delete';

  static const String downloadData =
      '/api/auth/student/export';

  // ─────────────────────────────────────────────
  // Platform
  // ─────────────────────────────────────────────

  static const String platform = '/api/platform';

  // ─────────────────────────────────────────────
  // Live Yoga
  // ─────────────────────────────────────────────

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

  static String buildLiveMediaUrl(String path) {
    final value = path.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    // The live API returns paths such as `/live/<class-id>/recording.mp4`,
    // while the actual recordings are stored below the S3 `/assets` prefix.
    final normalizedPath = value.startsWith('/') ? value : '/$value';
    if (normalizedPath.startsWith('/assets/')) {
      return 'https://navyoga.s3.ap-south-1.amazonaws.com$normalizedPath';
    }
    return '$liveRecordingBaseUrl$normalizedPath';
  }

  static const String studentClassAttendanceUrl =
      '$baseUrl/api/attendance/students/me/classes';

  // ─────────────────────────────────────────────
  // Self-Paced
  // ─────────────────────────────────────────────

  static const String selfPacedPlans =
      '/api/self-paced/plans';

  static const String selfPacedModules =
      '/api/self-paced/modules';

  static const String selfPacedSubscription =
      '/api/self-paced/my-subscription';

  // ─────────────────────────────────────────────
  // YTT Live
  // ─────────────────────────────────────────────

  static const String yttLivePlans =
      '/api/ytt-live/plans';

  static const String yttLiveEnrollments =
      '/api/ytt-live/my-enrollments';

  // ─────────────────────────────────────────────
  // YTT Recorded
  // ─────────────────────────────────────────────

  static const String yttRecordedPlans =
      '/api/ytt-recorded/plans';

  static const String yttRecordedEnrollments =
      '/api/ytt-recorded/my-enrollments';

  // ─────────────────────────────────────────────
  // Subscriptions
  // ─────────────────────────────────────────────

  static const String renewalPrompt =
      '/api/subscriptions/renewal-prompt';

  // ─────────────────────────────────────────────
  // Events
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // Workshops
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // Payments
  // ─────────────────────────────────────────────

  static const String initiatePayment =
      '/api/payments/initiate';

  static const String verifyPayment =
      '/api/payments/verify';

  // ─────────────────────────────────────────────
  // Existing admin/general endpoints
  // ─────────────────────────────────────────────

  static const String leads = '/leads';
  static const String batches = '/api/batches';
  static const String employees = '/api/employees';
  static const String financials = '/api/financials';
  static const String frontline = '/api/frontline';
  static const String students = '/api/students';
  static const String tutors = '/api/tutors';
  static const String workshops = '/api/workshops';

  // ─────────────────────────────────────────────
  // URL helpers
  // ─────────────────────────────────────────────

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
