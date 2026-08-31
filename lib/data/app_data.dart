import 'package:flutter/material.dart';
import '../models/stat_model.dart';
import '../models/event_model.dart';

class AppData {
  static const List<StatModel> stats = [
    StatModel(
      label: "Total Events",
      count: "6",
      icon: Icons.event,
      color: Colors.orange,
    ),

    StatModel(
      label: "Registered",
      count: "3",
      icon: Icons.school,
      color: Colors.green,
    ),

    StatModel(
      label: "Upcoming",
      count: "5",
      icon: Icons.self_improvement,
      color: Colors.purple,
    ),

    StatModel(
      label: "Feature",
      count: "23",
      icon: Icons.people,
      color: Colors.blue,
    ),
  ];

  static const List<EventModel> featuredEvents = [
    EventModel(
      id: "1",
      isEnrolled: false,
      title: "Advanced Meditation Retreat",
      description: "A 3-day immersive meditation retreat",
      date: "15 Apr 2026",
      location: "Rishikesh, Uttarakhand",
      price: "₹12,000",
      seats: "18/30 seats",
      image: "https://images.unsplash.com/photo-1506126613408-eca07ce68773",
      tags: ["Retreat", "Featured"],
      occupancy: '',
    ),

    EventModel(
      id: "2",
      isEnrolled: false,
      title: "Pranayama Breathing Workshop",
      description: "Master the art of breath control",
      date: "8 Apr 2026",
      location: "Mumbai",
      price: "₹1,500",
      seats: "45/50 seats",
      image: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b",
      tags: ["Workshop", "Featured"],
      occupancy: '',
    ),

    EventModel(
      id: "3",
      isEnrolled: false,
      title: "Ayurveda & Yoga Wellness Retreat",
      description: "Combine Ayurveda with yoga",
      date: "20 Apr 2026",
      location: "Kerala",
      price: "₹25,000",
      seats: "22/25 seats",
      image: "https://images.unsplash.com/photo-1518611012118-696072aa579a",
      tags: ["Retreat", "Featured"],
      occupancy: '',
    ),

    EventModel(
      id: "4",
      isEnrolled: false,
      title: "International Yoga Day Celebration",
      description: "Special yoga celebration",
      date: "21 Jun 2026",
      location: "Delhi",
      price: "Free",
      seats: "234/500 seats",
      image: "https://images.unsplash.com/photo-1552196563-55cd4e45efb3",
      tags: ["Special Event", "Featured"],
      occupancy: '',
    ),
  ];

  static const List<EventModel> allEvents = [
    EventModel(
      id: "1",
      isEnrolled: false,
      title: "Advanced Meditation Retreat",
      description: "A 3-day immersive meditation retreat",
      date: "15 Apr",
      location: "Rishikesh",
      price: "₹12,000",
      seats: "18/30",
      image: "https://images.unsplash.com/photo-1506126613408-eca07ce68773",
      tags: ["Retreat"],
      occupancy: '',
    ),

    EventModel(
      id: "2",
      isEnrolled: false,
      title: "Pranayama Breathing Workshop",
      description: "Master breath control",
      date: "8 Apr",
      location: "Mumbai",
      price: "₹1,500",
      seats: "45/50",
      image: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b",
      tags: ["Workshop"],
      occupancy: '',
    ),

    EventModel(
      id: "3",
      isEnrolled: false,
      title: "Yoga for Athletes Masterclass",
      description: "Yoga for athletes",
      date: "12 Apr",
      location: "Online",
      price: "₹999",
      seats: "67/100",
      image: "https://images.unsplash.com/photo-1552196563-55cd4e45efb3",
      tags: ["Masterclass"],
      occupancy: '',
    ),

    EventModel(
      id: "4",
      isEnrolled: false,
      title: "Ayurveda & Yoga Wellness Retreat",
      description: "Ayurveda + Yoga",
      date: "20 Apr",
      location: "Kerala",
      price: "₹25,000",
      seats: "22/25",
      image: "https://images.unsplash.com/photo-1518611012118-696072aa579a",
      tags: ["Retreat"],
      occupancy: '',
    ),

    EventModel(
      id: "5",
      isEnrolled: false,
      title: "Chakra Balancing Webinar",
      description: "Chakra learning",
      date: "5 Apr",
      location: "Online",
      price: "₹499",
      seats: "142/200",
      image: "https://images.unsplash.com/photo-1506126613408-eca07ce68773",
      tags: ["Webinar"],
      occupancy: '',
    ),

    EventModel(
      id: "6",
      isEnrolled: false,
      title: "International Yoga Day Celebration",
      description: "Yoga event",
      date: "21 Jun",
      location: "Delhi",
      price: "Free",
      seats: "234/500",
      image: "https://images.unsplash.com/photo-1552196563-55cd4e45efb3",
      tags: ["Special Event"],
      occupancy: '',
    ),
  ];
}
