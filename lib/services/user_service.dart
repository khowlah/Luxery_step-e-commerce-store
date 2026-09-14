import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _usersRef => _db.collection('users');

  // Get user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _usersRef.doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Error getting user profile: $e");
      return null;
    }
  }

  // Update or create user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _usersRef.doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      print("Error updating user profile: $e");
      rethrow;
    }
  }

  // Stream for real-time updates
  Stream<UserProfile?> userProfileStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    });
  }
}
