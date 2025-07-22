import 'package:dio/dio.dart';
import 'package:app/models/travel_model.dart';

class ApiFunc {
  final Dio _dio = Dio();

  ApiFunc() {
    // Configure Dio with better settings
    _dio.options = BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (object) => print('API: $object'),
      ),
    );
  }

  Future<TravelPlan?> generateItinerary(String prompt) async {
    const url =
        'https://ai-travel-planner-rc97.onrender.com/generate-itinerary';

    try {
      print('Making API request to: $url');
      print('Prompt: $prompt');

      final response = await _dio.post(url, data: {'prompt': prompt});

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return _parseApiResponse(response.data);
      }

      print('Invalid response: Status ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      print('DioException occurred:');
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Response: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  TravelPlan _parseApiResponse(Map<String, dynamic> data) {
    try {
      final itineraryData = data['itinerary'] ?? data;

      return TravelPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: data['title'] ?? 'Custom Travel Plan',
        destination: itineraryData['destination'] ?? 'Unknown',
        duration: '${itineraryData['duration_days'] ?? 1} days',
        summary: data['summary'] ?? 'Generated travel itinerary',
        travel_image:
            data['travel_image'] ??
            'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800&h=600&fit=crop',
        itinerary: TravelItinerary(
          destination: itineraryData['destination'] ?? 'Unknown',
          duration_days: itineraryData['duration_days'] ?? 1,
          days: (itineraryData['days'] as List<dynamic>? ?? [])
              .map(
                (dayData) => TravelDay(
                  day_number: dayData['day_number'] ?? 1,
                  theme: dayData['theme'] ?? 'Exploration',
                  activities: (dayData['activities'] as List<dynamic>? ?? [])
                      .map(
                        (activityData) => Activity(
                          time: activityData['time'] ?? '09:00',
                          location: Location(
                            name:
                                activityData['location']['name'] ??
                                'Unknown Location',
                            address: activityData['location']['address'] ?? '',
                            maps_link:
                                activityData['location']['maps_link'] ?? '',
                          ),
                          category: activityData['category'] ?? 'general',
                          description: activityData['description'] ?? '',
                          culturalConnection:
                              activityData['culturalConnection'] ??
                              activityData['cultural_connection'] ??
                              '',
                          category_icon: activityData['category_icon'] ?? '📍',
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      );
    } catch (e) {
      print('Error parsing API response: $e');
      throw Exception('Failed to parse API response: $e');
    }
  }
}
