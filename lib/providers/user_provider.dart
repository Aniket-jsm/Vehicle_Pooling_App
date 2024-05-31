import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minor4/models/user.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic> currentUser = {};

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc('8J0mjyf7xnbIkF7g7oWH')
          .get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?; // Explicit cast
            
        currentUser['name'] = userData?['name'] ?? '';
        currentUser['address'] = userData?['address'] ?? '';
        currentUser['phoneNumber'] = userData?['phone_number'] ?? '';

        print(currentUser);
        return currentUser;
      } else {
        print('User with ID $userId does not exist');
        return currentUser;
      }
    } catch (error) {
      print('Error fetching user data: $error');
      throw error;
    }
  }

  void updateUserImage(String imageUrl) {
    // Implement logic to update user image
  }
}
