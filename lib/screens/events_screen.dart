import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/attendance_stat_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import '../data/app_data.dart';
import '../widgets/stat_card.dart';
import '../widgets/event_card.dart';
import '../models/event_model.dart';
import 'event_details.dart';
import 'package:navyoga_academy/models/event_api_model.dart';
import 'package:navyoga_academy/services/event_service.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/utils/api_helper.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
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

    if (token == null) return;

    final response = await eventService.getEvents(token);

    if (response["unauthorized"] == true) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
      return;
    }

    if (ApiHelper.isSuccess(response) && response["data"] != null) {
      final List data = response["data"];

      setState(() {
        events = data.map((e) => EventApiModel.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      // 🔥 HANDLE ROLE ERROR SAFELY
      if (response["message"] == "Access denied for this role") {
        setState(() {
          events = []; // no events
          isLoading = false;
        });
        return;
      }

      // fallback error
      AppSnackbar.showError(context, ApiHelper.getMessage(response));

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 2,
      drawer: const CustomDrawer(),

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

        title: const Text(
          "NavYoga Academy",
          style: TextStyle(color: Colors.deepOrange),
        ),

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
                              "Events &\nWorkshops",
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
                    itemCount: AppData.stats.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 1.25,
                        ),
                    itemBuilder: (context, index) {
                      return StatCard(
                        AttendanceStatModel(
                          title: AppData.stats[index].label,
                          value: AppData.stats[index].count,
                          icon: AppData.stats[index].icon,
                          color: AppData.stats[index].color,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  /// 🔥 FEATURED TITLE
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
                      const Text(
                        "Featured Events",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Text(
                    "All Events (${events.length})",
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
                                description: "",
                                location: "",
                                price: "",
                                seats: "",
                                image: "",
                                tags: [],
                                title: events[index].title,
                                date: events[index].date,
                              ),
                              isCompact: true,
                              onTap: () => _openDetails(
                                context,
                                EventModel(
                                  location: "",
                                  price: "",
                                  seats: "",
                                  image: "",
                                  tags: [],
                                  description: "",
                                  title: events[index].title,
                                  date: events[index].date,
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

  void _openDetails(BuildContext context, EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
    );
  }
}
