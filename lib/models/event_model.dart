class EventModel {
  final String title;
  final String description;
  final String date;
  final String location;
  final String price;
  final String seats;
  final String image;
  final List<String> tags;

  const EventModel({
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.price,
    required this.seats,
    required this.image,
    required this.tags,
  });
}
