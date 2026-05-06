import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/attendance_stat_model.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import '../data/app_data.dart';
import '../widgets/stat_card.dart';
import '../widgets/event_card.dart';
import '../models/event_model.dart';
import 'event_details.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

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
      body: SingleChildScrollView(
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
                      Icon(Icons.calendar_month, color: Colors.white, size: 26),
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

            Column(
              children: AppData.featuredEvents.map((event) {
                return EventCard(
                  event: event,
                  isCompact: false,
                  onTap: () => _openDetails(context, event),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Text(
              "All Events (${AppData.allEvents.length})",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 20),

            /// 🔥 OTHER EVENTS LIST
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              cacheExtent: 500,
              itemCount: AppData.allEvents.length,
              itemBuilder: (context, index) {
                return EventCard(
                  event: AppData.allEvents[index],
                  isCompact: true,
                  onTap: () => _openDetails(context, AppData.allEvents[index]),
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
