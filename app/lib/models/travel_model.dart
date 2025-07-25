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

  // Convert from Firestore document
  factory TravelPlan.fromMap(Map<String, dynamic> map) {
    return TravelPlan(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      destination: map['destination'] ?? '',
      duration: map['duration'] ?? '',
      summary: map['summary'] ?? '',
      travel_image: map['travel_image'] ?? '',
      itinerary: TravelItinerary.fromMap(map['itinerary'] ?? {}),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'duration': duration,
      'summary': summary,
      'travel_image': travel_image,
      'itinerary': itinerary.toMap(),
    };
  }
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

  factory TravelItinerary.fromMap(Map<String, dynamic> map) {
    return TravelItinerary(
      destination: map['destination'] ?? '',
      duration_days: map['duration_days'] ?? 0,
      days: (map['days'] as List<dynamic>? ?? [])
          .map((day) => TravelDay.fromMap(day as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'destination': destination,
      'duration_days': duration_days,
      'days': days.map((day) => day.toMap()).toList(),
    };
  }
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

  factory TravelDay.fromMap(Map<String, dynamic> map) {
    return TravelDay(
      day_number: map['day_number'] ?? 0,
      theme: map['theme'] ?? '',
      activities: (map['activities'] as List<dynamic>? ?? [])
          .map((activity) => Activity.fromMap(activity as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day_number': day_number,
      'theme': theme,
      'activities': activities.map((activity) => activity.toMap()).toList(),
    };
  }
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

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      maps_link: map['maps_link'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'address': address, 'maps_link': maps_link};
  }
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

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      time: map['time'] ?? '',
      location: Location.fromMap(
        map['location'] as Map<String, dynamic>? ?? {},
      ),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      culturalConnection: map['culturalConnection'] ?? '',
      category_icon: map['category_icon'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'location': location.toMap(),
      'category': category,
      'description': description,
      'culturalConnection': culturalConnection,
      'category_icon': category_icon,
    };
  }
}
