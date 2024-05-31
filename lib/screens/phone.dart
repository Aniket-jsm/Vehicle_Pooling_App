import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:minor4/screens/ride_sharing_page.dart';
import 'package:minor4/screens/verify.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPhone extends StatefulWidget {
  const MyPhone({Key? key}) : super(key: key);

  @override
  State<MyPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String? errorMessage;
  File? _selectedImage;
  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'IN');
  String? verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<String?> _uploadImage(File image, String name) async {
    try {
      // String uid = FirebaseAuth.instance.currentUser!.uid;
      Reference storageReference = FirebaseStorage.instance.ref().child(name);
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
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

  void verifyPhoneNumber(BuildContext context, String imageUrl, String name,
      String address) async {
    String phoneNumberStr = phoneNumber.phoneNumber ?? '';

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumberStr,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        navigateToHome(context);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          errorMessage = 'Verification failed. Please try again.';
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
          isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyVerify(
              verificationId: verificationId,
              name: name,
              address: address,
              phone_number: phoneNumberStr,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          this.verificationId = verificationId;
          isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : AssetImage('asset/man.png') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Text(
                "Make your profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 10),
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  phoneNumber = number;
                },
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.DROPDOWN,
                ),
                initialValue: phoneNumber,
                textFieldController: TextEditingController(),
                formatInput: false,
                inputDecoration: InputDecoration(labelText: 'Phone Number'),
              ),
              SizedBox(height: 20),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
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
                    if (nameController.text.isEmpty ||
                        addressController.text.isEmpty ||
                        phoneNumber.phoneNumber == null) {
                      setState(() {
                        errorMessage = 'Please enter all fields';
                      });
                    } else if (_selectedImage == null) {
                      final snackBar = SnackBar(
                        content: Text('Please add a photo.'),
                        backgroundColor: Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } 
                  //   else {
                  //     String? imageUrl;
                  //     if (_selectedImage != null) {
                  //       imageUrl = await _uploadImage(
                  //           _selectedImage!, nameController.text.trim());
                  //     }
                  //     if (imageUrl != null) {
                  //       verifyPhoneNumber(context, imageUrl,
                  //           nameController.text, addressController.text);
                  //     }
                  //   }
                  // },
                  else {
                      setState(() {
                        isLoading = true;
                      });
                      String? imageUrl;
                      if (_selectedImage != null) {
                        imageUrl = await _uploadImage(
                            _selectedImage!, nameController.text.trim());
                      }
                      if (imageUrl != null) {
                        verifyPhoneNumber(context, imageUrl,
                            nameController.text, addressController.text);
                      } else {
                        setState(() {
                          isLoading = false;
                          errorMessage = 'Image upload failed';
                        });
                      }
                    }
                  },
                  child: Text("Submit",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 232, 235, 237))),
                ),
              ),
               if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CircularProgressIndicator(),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have a profile?    ",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                  GestureDetector(
                    child: Text("Login",
                        style: TextStyle(
                          color: Color.fromARGB(255, 219, 95, 78),
                          decoration: TextDecoration.underline,
                        )),
                    onTap: () {
                      // Navigate to login page
                    },
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
