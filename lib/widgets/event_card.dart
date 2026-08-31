import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final bool isCompact;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
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
            _image(),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        event.price,
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),


                  Align(
                    alignment: Alignment.centerRight,
                    child: _chip("${event.seats} seats"),
                  ),

                  const SizedBox(height: 8),


                  if (!isCompact)
                    Text(
                      event.description,
                      style: const TextStyle(color: Colors.grey),
                    ),

                  if (isCompact) const SizedBox.shrink(),

                  const SizedBox(height: 10),


                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      _info(
                        Icons.calendar_today,
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(DateTime.parse(event.date)),
                      ),
                      _info(Icons.location_on, event.location),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _image() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: CachedNetworkImage(
            imageUrl: event.image,
            height: isCompact ? 100 : 200,
            width: double.infinity,
            fit: BoxFit.cover,


            placeholder: (context, url) => Container(
              height: isCompact ? 140 : 200,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),


            errorWidget: (context, url, error) => Container(
              height: isCompact ? 140 : 200,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Row(
            children: event.tags.map((tag) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _tagChip(tag),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }


  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }

  Widget _tagChip(String tag) {
    final isFeatured = tag.toLowerCase() == "featured";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFeatured ? Colors.white : _getTagColor(tag),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFeatured)
            const Icon(Icons.auto_awesome, size: 14, color: Colors.black),
          if (isFeatured) const SizedBox(width: 4),

          Text(
            tag,
            style: TextStyle(
              color: isFeatured ? Colors.black : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case "retreat":
        return Colors.green;
      case "workshop":
        return Colors.orange;
      case "masterclass":
        return Colors.purple;
      case "webinar":
        return Colors.blue;
      case "special event":
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }


  Widget _info(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.purple),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
