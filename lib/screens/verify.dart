import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minor4/screens/profile.dart';
import 'package:minor4/screens/ride_sharing_page.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyVerify extends StatefulWidget {
  final String verificationId;
  final String name;
  final String address;
  final String phone_number;
  final String imageUrl;

  const MyVerify(
      {Key? key,
      required this.verificationId,
      required this.name,
      required this.address,
      required this.phone_number,
      required this.imageUrl})
      : super(key: key);

  @override
  State<MyVerify> createState() => _MyVerifyState();
}

class _MyVerifyState extends State<MyVerify> {
  final TextEditingController otpController = TextEditingController();
  String? errorMessage;

  void submitOTP(BuildContext context) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpController.text,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('login', true);
      storeUserDataInFirebase(
          widget.imageUrl, widget.phone_number, widget.name, widget.address);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Invalid OTP. Please try again.';
      });
    }
  }

  Future<void> storeLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('login', true);
  }

  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  void storeUserDataInFirebase(
      String imageUrl, String phoneNumber, String name, String address) async {
    _userCollection.doc(FirebaseAuth.instance.currentUser?.uid).set({
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'image_url': imageUrl,
    }).then((value) {
      print("User data stored successfully");
    }).catchError((error) {
      print("Error storing user data: $error");
    });
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
    );

    var focusedPinTheme;
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'asset/otp.png',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "OTP Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "We need to register your phone without getting started!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Pinput(
                controller: otpController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,

                onChanged: (value) {
                  setState(() {
                    errorMessage = null;
                  });
                },
              ),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 245, 77, 77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      submitOTP(context);
                    } catch (e) {
                      setState(() {
                        errorMessage = 'Invalid OTP. Please try again.';
                      });
                    }
                  },
                  child: Text("Verify Phone Number",
                    style: TextStyle(color: Colors.white)
                 ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Edit Phone Number?",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
