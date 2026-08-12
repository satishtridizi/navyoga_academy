import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/event_api_model.dart';
import 'package:navyoga_academy/models/event_model.dart';
import 'package:navyoga_academy/models/event_stats_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/screens/event_details.dart';
import 'package:navyoga_academy/services/event_service.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';

enum EventTab {
  events,
  workshops,
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() =>
      _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();

  EventTab selectedTab = EventTab.events;

  bool isLoading = true;
  bool isRefreshing = false;
  String? errorMessage;

  EventStatsModel eventStats =
      const EventStatsModel.empty();

  EventStatsModel workshopStats =
      const EventStatsModel.empty();

  List<EventApiModel> upcomingEvents = [];
  List<EventApiModel> pastEvents = [];
  List<EventApiModel> upcomingWorkshops = [];

  Set<String> enrolledEventIds = {};
  Set<String> enrolledWorkshopIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({
    bool refreshing = false,
  }) async {
    if (!mounted) return;

    setState(() {
      isRefreshing = refreshing;

      if (!refreshing) {
        isLoading = true;
      }

      errorMessage = null;
    });

    try {
      final token = await AuthManager.getToken();

      if (token == null || token.trim().isEmpty) {
        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (_) => false,
        );

        return;
      }

      final responses = await Future.wait([
        _eventService.getUpcomingEvents(token),
        _eventService.getPastEvents(token),
        _eventService.getEventStats(token),
        _eventService.getMyEventEnrollments(token),
        _eventService.getUpcomingWorkshops(token),
        _eventService.getWorkshopStats(token),
        _eventService.getMyWorkshopEnrollments(token),
      ]);

      final eventIds = _parseIds(
        responses[3],
        key: 'eventIds',
      );

      final workshopIds = _parseIds(
        responses[6],
        key: 'workshopIds',
      );

      final parsedUpcoming = _parseItems(
        responses[0],
        enrolledIds: eventIds,
      );

      final parsedPast = _parseItems(
        responses[1],
        enrolledIds: eventIds,
      );

      final parsedWorkshops = _parseItems(
        responses[4],
        enrolledIds: workshopIds,
      );

      if (!mounted) return;

      setState(() {
        enrolledEventIds = eventIds;
        enrolledWorkshopIds = workshopIds;

        upcomingEvents = parsedUpcoming;
        pastEvents = parsedPast;
        upcomingWorkshops = parsedWorkshops;

        eventStats = _parseStats(responses[2]);

        final rawWorkshopStats = _asMap(
          responses[5]['data'],
        );

        workshopStats = EventStatsModel(
          total: _toInt(rawWorkshopStats['total']),
          registered:
              _toInt(rawWorkshopStats['registered']),
          upcoming:
              _toInt(rawWorkshopStats['upcoming']),
          featured: 0,
        );
      });
    } catch (error, stackTrace) {
      debugPrint('LOAD EVENTS ERROR => $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        errorMessage =
            'Unable to load events and workshops.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  List<EventApiModel> _parseItems(
    Map<String, dynamic> response, {
    required Set<String> enrolledIds,
  }) {
    final data = _asMap(response['data']);
    final items = data['items'];

    if (response['success'] != true ||
        items is! List) {
      return [];
    }

    return items
        .whereType<Map>()
        .map((item) {
          final json =
              Map<String, dynamic>.from(item);

          final id = json['id']?.toString() ?? '';

          return EventApiModel.fromJson(
            json,
            isEnrolled: enrolledIds.contains(id),
          );
        })
        .toList();
  }

  Set<String> _parseIds(
    Map<String, dynamic> response, {
    required String key,
  }) {
    final data = _asMap(response['data']);
    final rawIds = data[key];

    if (rawIds is! List) {
      return {};
    }

    return rawIds
        .map((id) => id.toString())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  EventStatsModel _parseStats(
    Map<String, dynamic> response,
  ) {
    final data = _asMap(response['data']);

    if (response['success'] != true) {
      return const EventStatsModel.empty();
    }

    return EventStatsModel.fromJson(data);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  EventStatsModel get selectedStats {
    return selectedTab == EventTab.events
        ? eventStats
        : workshopStats;
  }

  List<EventApiModel> get selectedUpcomingItems {
    return selectedTab == EventTab.events
        ? upcomingEvents
        : upcomingWorkshops;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 2,
      drawer: const CustomDrawer(
        currentPage: 'Events',
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: Color(0xff261C34),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 56,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xff8509A8),
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                return _loadData(refreshing: true);
              },
              color: const Color(0xff8509A8),
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  32,
                ),
                children: [
                  if (isRefreshing)
                    const Padding(
                      padding:
                          EdgeInsets.only(bottom: 10),
                      child:
                          LinearProgressIndicator(),
                    ),

                  _buildHeader(),

                  const SizedBox(height: 16),

                  _buildStatsGrid(),

                  const SizedBox(height: 22),

                  if (errorMessage != null)
                    _buildErrorCard(),

                  _buildUpcomingSection(),

                  if (selectedTab == EventTab.events) ...[
                    const SizedBox(height: 24),
                    _buildPastEventsSection(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff74109D),
            Color(0xffA20CB6),
            Color(0xffFF6A29),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: Colors.white,
                size: 27,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Events & Workshops',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            'Discover and join exclusive yoga events, '
            'workshops and retreats.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              _buildHeaderTab(
                tab: EventTab.events,
                label: 'Events',
              ),
              const SizedBox(width: 9),
              _buildHeaderTab(
                tab: EventTab.workshops,
                label: 'Workshops',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTab({
    required EventTab tab,
    required String label,
  }) {
    final selected = selectedTab == tab;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = tab;
        });
      },
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color(0xff74109D)
                : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = selectedStats;

    final items = [
      _StatItem(
        title: selectedTab == EventTab.events
            ? 'Total Events'
            : 'Total Workshops',
        value: stats.total.toString(),
        icon: Icons.calendar_month_outlined,
        iconColor: const Color(0xffFF5A1F),
        background: const Color(0xffFFF8F4),
      ),
      _StatItem(
        title: 'Registered',
        value: stats.registered.toString(),
        icon: Icons.star_border_rounded,
        iconColor: const Color(0xff02B978),
        background: const Color(0xffF2FCF8),
      ),
      _StatItem(
        title: 'Upcoming',
        value: stats.upcoming.toString(),
        icon: Icons.trending_up_rounded,
        iconColor: const Color(0xffC21ACF),
        background: const Color(0xffFBF4FC),
      ),
      _StatItem(
        title: selectedTab == EventTab.events
            ? 'Featured'
            : 'Enrolled',
        value: selectedTab == EventTab.events
            ? stats.featured.toString()
            : stats.registered.toString(),
        icon: Icons.emoji_events_outlined,
        iconColor: const Color(0xffF09A00),
        background: const Color(0xffFFF9EF),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: item.background,
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff596276),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    width: 35,
                    height: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: item.iconColor,
                      borderRadius:
                          BorderRadius.circular(11),
                    ),
                    child: Icon(
                      item.icon,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ],
              ),
              Text(
                item.value,
                style: const TextStyle(
                  color: Color(0xff171A29),
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        )
            .animate(
              delay: Duration(
                milliseconds: index * 70,
              ),
            )
            .fadeIn()
            .slideY(
              begin: 0.07,
              end: 0,
            );
      },
    );
  }

  Widget _buildUpcomingSection() {
    final items = selectedUpcomingItems;

    final title = selectedTab == EventTab.events
        ? 'All Events (${items.length})'
        : 'All Workshops (${items.length})';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xffF0E9F2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xffFF5A1F),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          if (items.isEmpty)
            _buildEmptyUpcoming()
          else
            ...items.asMap().entries.map(
              (entry) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 13),
                child: _buildEventCard(entry.value)
                    .animate(
                      delay: Duration(
                        milliseconds: entry.key * 70,
                      ),
                    )
                    .fadeIn(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPastEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 35,
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xff536174),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Past Events (${pastEvents.length})',
              style: const TextStyle(
                color: Color(0xff4E5768),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        if (pastEvents.isEmpty)
          _buildEmptyPast()
        else
          ...pastEvents.asMap().entries.map(
            (entry) => Padding(
              padding:
                  const EdgeInsets.only(bottom: 13),
              child: _buildEventCard(
                entry.value,
                isPast: true,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventCard(
    EventApiModel event, {
    bool isPast = false,
  }) {
    return InkWell(
      onTap: () {
        _openDetails(event);
      },
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: const Color(0xffE9E7EC),
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 92,
                    height: 90,
                    child: event.thumbnail.isEmpty
                        ? _buildImagePlaceholder()
                        : Image.network(
                            event.thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) {
                              return _buildImagePlaceholder();
                            },
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isPast)
                            Container(
                              margin:
                                  const EdgeInsets.only(
                                right: 7,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xff566174,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: const Text(
                                'Past',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          if (event.featured)
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xffF09A00),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff202438),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        event.description,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff647087),
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildMeta(
                  Icons.calendar_today_outlined,
                  event.date == null
                      ? 'Date unavailable'
                      : DateFormat(
                          'dd MMM yyyy',
                        ).format(event.date!),
                ),
                _buildMeta(
                  Icons.schedule_outlined,
                  event.date == null
                      ? 'Time unavailable'
                      : DateFormat(
                          'h:mm a',
                        ).format(event.date!),
                ),
                _buildMeta(
                  Icons.timer_outlined,
                  event.duration.isEmpty
                      ? 'Duration unavailable'
                      : event.duration,
                ),
                _buildMeta(
                  Icons.videocam_outlined,
                  event.location.isEmpty
                      ? 'Location unavailable'
                      : event.location,
                ),
              ],
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${event.occupancy}/${event.capacity} attended',
                    style: const TextStyle(
                      color: Color(0xff697286),
                      fontSize: 11,
                    ),
                  ),
                ),
                if (event.isEnrolled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffEAF9F1),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Color(0xff0CAF67),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Registered',
                          style: TextStyle(
                            color: Color(0xff0CAF67),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeta(
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xff758196),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xff667186),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xffF1EEF4),
      alignment: Alignment.center,
      child: const Icon(
        Icons.event_outlined,
        color: Color(0xff9A91A2),
        size: 34,
      ),
    );
  }

  Widget _buildEmptyUpcoming() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 46,
        horizontal: 20,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 50,
              color: Color(0xffC8CBD2),
            ),
            SizedBox(height: 13),
            Text(
              'No events found',
              style: TextStyle(
                color: Color(0xff41495A),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'New events will appear here when available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff778196),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPast() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF8F7F9),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Center(
        child: Text(
          'No past events available',
          style: TextStyle(
            color: Color(0xff737B8B),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(errorMessage!),
          ),
          TextButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetails(
    EventApiModel event,
  ) async {
    final eventModel = EventModel(
      occupancy: event.occupancy.toString(),
      isEnrolled: event.isEnrolled,
      id: event.id,
      title: event.title,
      description: event.description,
      date: event.date?.toIso8601String() ?? '',
      location: event.location,
      price: event.price == 0
          ? 'Free'
          : '₹${event.price.toStringAsFixed(0)}',
      seats: event.capacity.toString(),
      image: event.thumbnail,
      tags: const [],
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailsScreen(
          event: eventModel,
        ),
      ),
    );

    if (result == true) {
      await _loadData(refreshing: true);
    }
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color background;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.background,
  });
}