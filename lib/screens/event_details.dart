import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../utils/auth_manager.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final EventService _eventService = EventService();

  bool isEnrolled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isEnrolled = widget.event.isEnrolled;
  }

  Future<void> _enrollEvent() async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = await AuthManager.getToken();

      if (token == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      final res = await _eventService.enrollEvent(widget.event.id, token);

      print("EVENT ENROLL RESPONSE = $res");
      if (res["success"] == true) {
        setState(() {
          isEnrolled = true;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Enrolled successfully")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Enrollment failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: AppBackground(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),

          slivers: [
            /// 🔥 APP BAR IMAGE
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: Colors.white,

              iconTheme: const IconThemeData(color: Colors.white),

              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.event.image,
                      fit: BoxFit.cover,

                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),

                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),

                    /// DARK OVERLAY
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,

                          colors: [
                            Colors.black.withOpacity(0.15),
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),

                    /// TITLE
                    Positioned(
                      left: 20,
                      bottom: 30,
                      right: 20,

                      child: AnimatedItem(
                        index: 0,

                        child: Text(
                          widget.event.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 🔥 CONTENT
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// TAGS
                    AnimatedItem(
                      index: 1,

                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,

                        children: widget.event.tags.map((tag) {
                          return _tag(tag);
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// DESCRIPTION CARD
                    AnimatedItem(
                      index: 2,

                      child: Container(
                        padding: const EdgeInsets.all(22),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              "About Event",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),

                            const SizedBox(height: 14),

                            Text(
                              widget.event.description,
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                height: 1.6,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// EVENT DETAILS
                    AnimatedItem(
                      index: 3,

                      child: Container(
                        padding: const EdgeInsets.all(22),

                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepOrange.withOpacity(0.08),
                              Colors.orange.withOpacity(0.03),
                            ],
                          ),

                          borderRadius: BorderRadius.circular(26),

                          border: Border.all(
                            color: Colors.deepOrange.withOpacity(0.15),
                          ),
                        ),

                        child: Column(
                          children: [
                            _detailRow(
                              Icons.calendar_today,
                              "Date",
                              widget.event.date,
                            ),

                            const SizedBox(height: 18),

                            _detailRow(
                              Icons.location_on,
                              "Location",
                              widget.event.location,
                            ),

                            const SizedBox(height: 18),

                            _detailRow(
                              Icons.payments,
                              "Price",
                              widget.event.price,
                            ),

                            const SizedBox(height: 18),

                            _detailRow(
                              Icons.people,
                              "Seats Registered",
                              "${widget.event.seats}",
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// JOIN BUTTON
                    AnimatedItem(
                      index: 4,

                      child: SizedBox(
                        width: double.infinity,
                        child: isEnrolled
                            ? ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                ),
                                child: const Text("Already Enrolled"),
                              )
                            : ElevatedButton(
                                onPressed: isLoading ? null : _enrollEvent,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  elevation: 6,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: const Text(
                                  "Register Now",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 TAG CHIP
  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        text,
        style: const TextStyle(
          color: Colors.deepOrange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 🔥 DETAIL ROW
  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),

          child: Icon(icon, color: Colors.deepOrange),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1E1B39),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
