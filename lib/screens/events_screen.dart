import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/attendance_stat_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
//import '../data/app_data.dart';
import '../widgets/stat_card.dart';
import '../widgets/event_card.dart';
import '../models/event_model.dart';
import 'event_details.dart';
import 'package:navyoga_academy/models/event_api_model.dart';
import 'package:navyoga_academy/services/event_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int get totalEvents => events.length;
  bool isLoading = true;
  final eventService = EventService();

  List<EventApiModel> events = [];

  @override
  initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    final token = await AuthManager.getToken();

    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {
      final list = await eventService.getEvents(token);
      print("EVENTS API RESPONSE");
      print(list);
      print("EVENT RESPONSE = $list");
      final mapped = list.map((e) => EventApiModel.fromJson(e)).toList();

      setState(() {
        events = mapped;
        isLoading = false;
      });
    } catch (e) {
      if (e.toString().contains("UNAUTHORIZED")) {
        await AuthManager.clearToken();

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
        return;
      }

      // 🔥 ROLE / ACCESS ERROR
      setState(() {
        events = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You don’t have access to events")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final featuredEvents = events.where((e) => e.featured).toList();
    final stats = [
      AttendanceStatModel(
        title: "Total Events",
        value: events.length.toString(),
        icon: Icons.calendar_today,
        color: Colors.orange,
      ),

      AttendanceStatModel(
        title: "Registered",
        value: events.where((e) => e.isEnrolled).length.toString(),
        icon: Icons.school,
        color: Colors.green,
      ),

      AttendanceStatModel(
        title: "Upcoming",
        value: events
            .where((e) => DateTime.parse(e.date).isAfter(DateTime.now()))
            .length
            .toString(),
        icon: Icons.self_improvement,
        color: Colors.purple,
      ),

      AttendanceStatModel(
        title: "Featured",
        value: events.where((e) => e.featured).length.toString(),
        icon: Icons.people,
        color: Colors.blue,
      ),
    ];
    return AppScaffold(
      currentIndex: null,
      drawer: const CustomDrawer(currentPage: "Events"),

      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),

        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 60,
        ),
        centerTitle: true,

        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔥 HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFFFF7A18)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 26,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Events & Workshops",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        Text(
                          "Discover and join exclusive yoga events, workshops, and retreats",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// 🔥 STATS GRID
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stats.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 1.25,
                        ),
                    itemBuilder: (context, index) {
                      return StatCard(stats[index]);
                    },
                  ),

                  const SizedBox(height: 30),

                  /// 🔥 FEATURED EVENTS
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.star, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Featured Events (${featuredEvents.length})",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: featuredEvents.length,
                    itemBuilder: (context, index) {
                      final event = featuredEvents[index];

                      return EventCard(
                        event: EventModel(
                          occupancy: event.occupancy.toString(),
                          isEnrolled: event.isEnrolled,
                          id: event.id,
                          title: event.title,
                          description: event.description,
                          date: event.date,
                          location: event.location,
                          price: "₹${event.price}",
                          seats: event.capacity.toString(),
                          image: event.thumbnail,
                          tags: [],
                        ),
                        isCompact: true,
                        onTap: () => _openDetails(
                          context,
                          EventModel(
                            occupancy: event.occupancy.toString(),
                            isEnrolled: event.isEnrolled,
                            id: event.id,
                            title: event.title,
                            description: event.description,
                            date: event.date,
                            location: event.location,
                            price: "₹${event.price}",
                            seats: event.capacity.toString(),
                            image: event.thumbnail,
                            tags: [],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "All Events (${totalEvents})",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),

                  const SizedBox(height: 20),

                  events.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "No events available for your account",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            return EventCard(
                              event: EventModel(
                                occupancy: events[index].occupancy.toString(),
                                isEnrolled: events[index].isEnrolled,
                                id: events[index].id,
                                title: events[index].title,
                                description: events[index].description,
                                date: events[index].date,
                                location: events[index].location,
                                price: "₹${events[index].price}",
                                seats: events[index].capacity.toString(),
                                image: events[index].thumbnail,
                                tags: [],
                              ),
                              isCompact: true,
                              onTap: () => _openDetails(
                                context,
                                EventModel(
                                  occupancy: events[index].occupancy.toString(),
                                  isEnrolled: events[index].isEnrolled,
                                  id: events[index].id,
                                  title: events[index].title,
                                  description: events[index].description,
                                  date: events[index].date,
                                  location: events[index].location,
                                  price: "₹${events[index].price}",
                                  seats: events[index].capacity.toString(),
                                  image: events[index].thumbnail,
                                  tags: [],
                                ),
                              ),
                            );
                          },
                        ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Future<void> _openDetails(BuildContext context, EventModel event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
    );

    if (result == true) {
      await loadEvents();
    }
  }
}
