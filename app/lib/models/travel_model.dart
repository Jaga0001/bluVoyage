class TravelPlan {
  final String id;
  final String title;
  final String destination;
  final String duration;
  final String summary;
  final String travel_image;
  final TravelItinerary itinerary;

  TravelPlan({
    required this.id,
    required this.title,
    required this.destination,
    required this.duration,
    required this.summary,
    required this.travel_image,
    required this.itinerary,
  });
}

class TravelItinerary {
  final String destination;
  final int duration_days;
  final List<TravelDay> days;

  TravelItinerary({
    required this.destination,
    required this.duration_days,
    required this.days,
  });
}

class TravelDay {
  final int day_number;
  final String theme;
  final List<Activity> activities;

  TravelDay({
    required this.day_number,
    required this.theme,
    required this.activities,
  });
}

class Location {
  final String name;
  final String address;
  final String maps_link;

  Location({
    required this.name,
    required this.address,
    required this.maps_link,
  });
}

class Activity {
  final String time;
  final Location location;
  final String category;
  final String description;
  final String culturalConnection;
  final String category_icon;

  Activity({
    required this.time,
    required this.location,
    required this.category,
    required this.description,
    required this.culturalConnection,
    required this.category_icon,
  });
}
