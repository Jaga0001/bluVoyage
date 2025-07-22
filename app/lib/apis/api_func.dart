import 'package:dio/dio.dart';

class ApiFunc {
  final Dio _dio = Dio();

  Future<void> generateItinerary(Map<String, dynamic> data) async {
    final url =
        'http://localhost:8000/generate-itinerary'; // Replace with your server address

    try {
      final response = await _dio.post(
        url,
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print('Response: ${response.data}');
    } catch (e) {
      print('Error: $e');
    }
  }
}
