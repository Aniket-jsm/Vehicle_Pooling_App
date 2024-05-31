import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:minor4/screens/home_page.dart'; // Make sure to import the correct home page file
import 'package:minor4/screens/ride_sharing_page.dart';
import 'package:minor4/screens/verify.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _phoneNumberController = TextEditingController();
  String? errorMessage;

  void verifyPhoneNumber(BuildContext context) async {
    // Retrieve user details from Firebase using the current user's ID
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        String name = userData['name'];
        String address = userData['address'];
        String imageUrl = userData['imageUrl'];

        // Proceed to phone number verification
        String phoneNumber = _phoneNumberController.text;
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
            navigateToHome(context);
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() {
              errorMessage = 'Verification failed. Please try again.';
            });
          },
          codeSent: (String verificationId, int? resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyVerify(
                  verificationId: verificationId,
                  name: name,
                  address: address,
                  phone_number: phoneNumber,
                  imageUrl: imageUrl,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Handle auto retrieval timeout if needed
          },
        );
      } else {
        // Handle if user data does not exist
      }
    } else {
      // Handle if user is not authenticated
    }
  }

  void navigateToHome(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('login', true);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter phone number',
              ),
            ),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                verifyPhoneNumber(context);
              },
              child: Text('Verify Phone Number'),
            ),
          ],
        ),
      ),
    );
  }
}
