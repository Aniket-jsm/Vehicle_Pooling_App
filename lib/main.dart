import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:minor4/screens/profile.dart';
import 'package:minor4/screens/ride_selection_page.dart';
import 'package:minor4/screens/ride_sharing_page.dart';
import 'package:minor4/screens/phone.dart';
import 'package:provider/provider.dart';
import 'package:minor4/providers/user_provider.dart';
import 'package:minor4/providers/shared_ride_provider.dart';
import 'package:minor4/screens/verify.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDnJwtKnUwL4RDOXQHoK8XpqTvBti52iJc",
        appId: "1:900413415266:android:e223f758bd10b6d7c4563b",
        messagingSenderId: "900413415266",
        projectId: "minor4-b7811",
        storageBucket: "minor4-b7811.appspot.com"),
  );
  await FirebaseAppCheck.instance.activate();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => SharedRideProvider()),
      ],

      child: MaterialApp(
       
         debugShowCheckedModeBanner: false,
        title: 'Vehicle Pool App',
        home: SplashScreen(), // Set splash screen as initial route
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 1)); // 2-second delay

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('login');

    Widget nextScreen = isLoggedIn == true ? HomePage() : MyPhone();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        backgroundColor:Color.fromARGB(255, 235, 236, 221),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('asset/minorlogo.png'), // Replace with your logo path
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );

  }
}

