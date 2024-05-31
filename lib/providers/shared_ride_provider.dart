import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SharedRideProvider extends ChangeNotifier {
  String _name = '';
  String _phoneNumber = '';

  SharedRideProvider() {
    _fetchUserData();
  }

  String getName() {
    return _name;
  }

  String getPhoneNumber() {
    return _phoneNumber;
  }

  void _fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _name = userDoc['name'] ?? '';
        _phoneNumber = userDoc['phone_number'] ?? '';
        notifyListeners();
      }
    }
  }

  void addRideDetails({
    required String from,
    required String to, required String name, required String phoneNumber,
  }) {
    FirebaseFirestore.instance.collection('rides').add({
      'from': from,
      'to': to,
      'name': _name,
      'phoneNumber': _phoneNumber,
    }).then((value) {
      print('Ride details added successfully with ID: ${value.id}');
    }).catchError((error) {
      print('Error adding ride details: $error');
    });

    notifyListeners();
  }
}
