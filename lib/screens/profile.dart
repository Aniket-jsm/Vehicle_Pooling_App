import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minor4/screens/login.dart';
import 'package:minor4/screens/phone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic> currentUser = {};

  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await _userCollection.doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        currentUser = userDoc.data() as Map<String, dynamic>;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _auth.signOut();
    print("Uid");

    // print(_auth.currentUser!.uid);
    await prefs.setBool('login', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MyPhone()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
        style: TextStyle(color:Colors.white),
        textAlign: TextAlign.center,),
        backgroundColor: Color.fromARGB(255, 240, 101, 101),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 235, 236, 221),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: currentUser['image_url'] != null &&
                            currentUser['image_url'].isNotEmpty
                        ? NetworkImage(currentUser['image_url'])
                        : AssetImage('asset/man.png') as ImageProvider,
                  ),
                  SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Name'),
                      subtitle:
                          Text(currentUser['name'] ?? 'Name not available'),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.phone),
                      title: Text('Phone Number'),
                      subtitle: Text(currentUser['phone_number'] ??
                          'Phone number not available'),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.home),
                      title: Text('Address'),
                      subtitle: Text(
                          currentUser['address'] ?? 'Address not available'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
