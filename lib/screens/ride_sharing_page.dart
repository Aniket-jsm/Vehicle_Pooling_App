import 'package:flutter/material.dart';
import 'package:minor4/screens/profile.dart';
import 'package:minor4/screens/ride_selection_page.dart';
import 'package:provider/provider.dart';
import 'package:minor4/providers/shared_ride_provider.dart';

class ShareRidePage extends StatefulWidget {
  @override
  _ShareRidePageState createState() => _ShareRidePageState();
}

class _ShareRidePageState extends State<ShareRidePage> {
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sharedRideProvider = Provider.of<SharedRideProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Buddy Ride',
        style: TextStyle(color:Colors.white),
        textAlign: TextAlign.center,),
        backgroundColor: Color.fromARGB(255, 240, 101, 101),
      ),
      backgroundColor: Color.fromARGB(255, 235, 236, 221),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: fromController,
                  decoration: InputDecoration(
                    hintText: 'Enter pick up location',
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 20),
                Text(
                  'To:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: toController,
                  decoration: InputDecoration(
                    hintText: 'Enter drop location',
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Rectangular shape
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 240, 101, 101),
                      ), // Background color
                      side: MaterialStateProperty.all<BorderSide>(
                        BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ), // Border color and width
                      ),
                    ),
                    onPressed: () {
                      // Validate input and share ride details
                      String from = fromController.text;
                      String to = toController.text;
                      // You can add validation here before sharing the ride
                      sharedRideProvider.addRideDetails(
                        from: from,
                        to: to,
                        name: sharedRideProvider.getName(),
                        phoneNumber: sharedRideProvider.getPhoneNumber(),
                      );
                      setState(() {
                        toController.text = "";
                        fromController.text = "";
                        print("RideAdded SuccessFully ");
                      });
                      final snackBar = SnackBar(
                        content: Text('Request For Ride Sent Successfully'),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    
                    child: Text(
                      'Share Ride',
                      
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<dynamic> _listItems = [
    ShareRidePage(),
    RideListPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      print('Current index: $_selectedIndex'); // Print current index
      _selectedIndex = index;
      print('New index: $index');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('home');
    return Scaffold(
      body: _listItems[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
