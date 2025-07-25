import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/models/travel_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DbFunc {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'travel_plans';

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Save travel plan to Firestore for current user
  Future<bool> saveTravelPlan(TravelPlan travelPlan) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        print('No authenticated user found');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(travelPlan.id)
          .set({
            'id': travelPlan.id,
            'title': travelPlan.title,
            'destination': travelPlan.destination,
            'duration': travelPlan.duration,
            'summary': travelPlan.summary,
            'travel_image': travelPlan.travel_image,
            'user_id': userId,
            'itinerary': {
              'destination': travelPlan.itinerary.destination,
              'duration_days': travelPlan.itinerary.duration_days,
              'days': travelPlan.itinerary.days
                  .map(
                    (day) => {
                      'day_number': day.day_number,
                      'theme': day.theme,
                      'activities': day.activities
                          .map(
                            (activity) => {
                              'time': activity.time,
                              'location': {
                                'name': activity.location.name,
                                'address': activity.location.address,
                                'maps_link': activity.location.maps_link,
                              },
                              'category': activity.category,
                              'description': activity.description,
                              'culturalConnection': activity.culturalConnection,
                              'category_icon': activity.category_icon,
                            },
                          )
                          .toList(),
                    },
                  )
                  .toList(),
            },
            'created_at': FieldValue.serverTimestamp(),
          });
      return true;
    } catch (e) {
      print('Error saving travel plan: $e');
      return false;
    }
  }

  // Get all travel plans from Firestore for current user
  Future<List<TravelPlan>> getTravelPlans() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        print('No authenticated user found');
        return [];
      }

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return TravelPlan.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting travel plans: $e');
      return [];
    }
  }

  // Delete travel plan from Firestore for current user
  Future<bool> deleteTravelPlan(String planId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        print('No authenticated user found');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(planId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting travel plan: $e');
      return false;
    }
  }

  // Check if user is authenticated
  bool get isUserAuthenticated => _currentUserId != null;

  // Get current user info
  User? get currentUser => _auth.currentUser;
}
