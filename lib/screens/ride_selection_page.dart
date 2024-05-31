import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:minor4/providers/shared_ride_provider.dart';

class RideListPage extends StatefulWidget {
  @override
  _RideListPageState createState() => _RideListPageState();
}

class _RideListPageState extends State<RideListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Rides',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color.fromARGB(255, 240, 101, 101),
      ),
      backgroundColor: Color.fromARGB(255, 235, 236, 221),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('rides').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    bool isAccepted = data['isAccepted'] ?? false;
                    bool isRejected = data['isRejected'] ?? false;

                    return GestureDetector(
                      onTap: () {
                        if (!isRejected) {
                          if (isAccepted) {
                            fetchRideDetails(context, document.id);
                          } else {
                            acceptRide(context, document.id);
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isRejected ? Colors.grey : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            'From: ${data['from']} To: ${data['to']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isAccepted && !isRejected)
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check),
                                      onPressed: () {
                                        acceptRide(context, document.id);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        rejectRide(context, document.id);
                                      },
                                    ),
                                  ],
                                )
                              else
                                Text(isRejected ? "Rejected" : "Accepted"),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void acceptRide(BuildContext context, String rideId) {
    FirebaseFirestore.instance
        .collection('rides')
        .doc(rideId)
        .update({'isAccepted': true, 'isRejected': false}).then((_) {
      // Ride is now accepted, but no need to fetch details immediately
    }).catchError((error) {
      print("Error updating ride status: $error");
    });
  }

  void fetchRideDetails(BuildContext context, String rideId) async {
    FirebaseFirestore.instance
        .collection('rides')
        .doc(rideId)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        String riderName = data['name'] ?? 'Unknown';
        String riderPhoneNumber = data['phoneNumber'] ?? 'Unknown';

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Rider Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rider Name: $riderName'),
                  InkWell(
                    onTap: () {
                      launch('tel:$riderPhoneNumber');
                    },
                    child: Text(
                      'Phone: $riderPhoneNumber',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        print("Document does not exist");
      }
    }).catchError((error) {
      print("Error fetching ride details: $error");
    });
  }

  void rejectRide(BuildContext context, String rideId) {
    FirebaseFirestore.instance
        .collection('rides')
        .doc(rideId)
        .update({'isAccepted': false, 'isRejected': true}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride rejected successfully!')),
      );
    }).catchError((error) {
      print("Error rejecting ride: $error");
    });
  }
}
