import 'package:flutter/foundation.dart';

import '../api/api_constants.dart';
import '../api/api_service.dart';

class EventService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getUpcomingEvents(
    String token, {
    int limit = 20,
  }) async {
    return _get(
      endpoint: '/api/events/upcoming?limit=$limit',
      token: token,
      fallbackData: {
        'items': <dynamic>[],
        'page': 1,
        'limit': limit,
        'total': 0,
        'totalPages': 1,
      },
    );
  }

  Future<Map<String, dynamic>> getPastEvents(
    String token, {
    int limit = 10,
  }) async {
    return _get(
      endpoint: '/api/events/past?limit=$limit',
      token: token,
      fallbackData: {
        'items': <dynamic>[],
      },
    );
  }

  Future<Map<String, dynamic>> getEventStats(
    String token,
  ) async {
    return _get(
      endpoint: '/api/events/upcoming/stats',
      token: token,
      fallbackData: {
        'total': 0,
        'registered': 0,
        'upcoming': 0,
        'featured': 0,
      },
    );
  }

  Future<Map<String, dynamic>> getMyEventEnrollments(
    String token,
  ) async {
    return _get(
      endpoint: '/api/events/my-enrollments',
      token: token,
      fallbackData: {
        'eventIds': <dynamic>[],
      },
    );
  }

  Future<Map<String, dynamic>> getUpcomingWorkshops(
    String token, {
    int limit = 20,
  }) async {
    return _get(
      endpoint: '/api/workshops/upcoming?limit=$limit',
      token: token,
      fallbackData: {
        'items': <dynamic>[],
        'page': 1,
        'limit': limit,
        'total': 0,
        'totalPages': 1,
      },
    );
  }

  Future<Map<String, dynamic>> getWorkshopStats(
    String token,
  ) async {
    return _get(
      endpoint: '/api/workshops/upcoming/stats',
      token: token,
      fallbackData: {
        'total': 0,
        'registered': 0,
        'upcoming': 0,
        'totalCapacity': 0,
      },
    );
  }

  Future<Map<String, dynamic>>
      getMyWorkshopEnrollments(
    String token,
  ) async {
    return _get(
      endpoint: '/api/workshops/my-enrolled-ids',
      token: token,
      fallbackData: {
        'workshopIds': <dynamic>[],
      },
    );
  }

  Future<Map<String, dynamic>> enrollEvent(
    String eventId,
    String token,
  ) async {
    try {
      final response = await _api.postRequest(
        url:
            '${ApiConstants.baseUrl}/api/events/$eventId/enrollment',
        body: <String, dynamic>{},
        token: token,
      );

      return _asMap(
        response,
        fallbackData: <String, dynamic>{},
      );
    } catch (error, stackTrace) {
      debugPrint(
        'EVENT ENROLLMENT ERROR [$eventId] => $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      return {
        'success': false,
        'message': 'Unable to register for this event',
        'data': <String, dynamic>{},
      };
    }
  }

  Future<Map<String, dynamic>> enrollWorkshop(
    String workshopId,
    String token,
  ) async {
    try {
      final response = await _api.postRequest(
        url:
            '${ApiConstants.baseUrl}/api/workshops/$workshopId/enrollment',
        body: <String, dynamic>{},
        token: token,
      );

      return _asMap(
        response,
        fallbackData: <String, dynamic>{},
      );
    } catch (error, stackTrace) {
      debugPrint(
        'WORKSHOP ENROLLMENT ERROR '
        '[$workshopId] => $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      return {
        'success': false,
        'message':
            'Unable to register for this workshop',
        'data': <String, dynamic>{},
      };
    }
  }

  Future<Map<String, dynamic>> _get({
    required String endpoint,
    required String token,
    required dynamic fallbackData,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}$endpoint';

      final response = await _api.getRequest(
        url: url,
        token: token,
      );

      debugPrint(
        'EVENT API [$endpoint] => $response',
      );

      return _asMap(
        response,
        fallbackData: fallbackData,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'EVENT API ERROR [$endpoint] => $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      final message = error.toString();

      return {
        'success': false,
        'message': message.contains('UNAUTHORIZED')
            ? 'UNAUTHORIZED'
            : 'Unable to load event information',
        'data': fallbackData,
      };
    }
  }

  Map<String, dynamic> _asMap(
    dynamic response, {
    required dynamic fallbackData,
  }) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    return {
      'success': false,
      'message': 'Invalid server response',
      'data': fallbackData,
    };
  }
}