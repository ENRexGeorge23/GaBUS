import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gabus_build/screens/edit_profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../common/size_config.dart';
import '../../common/theme_helper.dart';

enum UserType { Student, Senior, PWD }

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  static const routename = '/verification';

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  OverlayEntry? _overlayEntry;

  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();
  UserType? _selectedUserType;
  File? _frontIdImage;
  File? _backIdImage;
  File? _selfieImage;

  Future<void> _updateUserVerification(
      String userId, UserType userType, bool isVerified) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    Map<String, bool> userData = {
      'isVerified': isVerified,
    };

    await userDoc.update(userData);
  }

  Widget _imageInput(String label, String imageType, File? imageFile) {
    SizeConfig().init(context);
    return Container(
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Column(
        children: [
          SizedBox(height: SizeConfig.safeBlockVertical * 1.0),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: SizeConfig.blockSizeHorizontal * 4.5,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: SizeConfig.safeBlockVertical * 1.0),
          if (imageFile != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Image.file(imageFile, width: 150),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: () => _pickImage(ImageSource.camera, imageType),
                icon: Icon(Icons.camera_alt),
                label: Text('Take a photo'),
              ),
              TextButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery, imageType),
                icon: Icon(Icons.photo_library),
                label: Text('Pick from gallery'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLoadingIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 10.0, // Adjust this value for the desired size
          ),
        );
      },
    );
  }

  void _hideLoadingIndicator() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<String> _uploadImage(
      File image, String userId, String imageType) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('userImages')
        .child(userId)
        .child('$imageType.jpg');

    final uploadTask = ref.putFile(image);
    final taskSnapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _submitVerificationRequest(
      String userId,
      UserType userType,
      String frontIdImageUrl,
      String backIdImageUrl,
      String selfieImageUrl,
      String displayName) async {
    final verificationRequestRef = FirebaseFirestore.instance
        .collection('verificationRequest')
        .doc(userId);

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Check if isDeclined is true and delete the isDeclined field if found
    if (userDoc.data()!.containsKey('isDeclined') &&
        userDoc['isDeclined'] == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isDeclined': FieldValue.delete()});
    }

    final verificationData = {
      'displayName': displayName,
      'frontIdImage': frontIdImageUrl,
      'backIdImage': backIdImageUrl,
      'selfieImage': selfieImageUrl,
      'userType': userType.toString().split('.').last,
    };

    await verificationRequestRef.set(verificationData);

    // Update isVerified in the users collection
    Map<String, bool> userData = {
      'isVerified': false,
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update(userData);
  }

  Future<void> _pickImage(ImageSource source, String imageType) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (imageType == 'front') {
          _frontIdImage = File(pickedFile.path);
        } else if (imageType == 'back') {
          _backIdImage = File(pickedFile.path);
        } else {
          _selfieImage = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 238, 192),
      appBar: AppBar(
          title: Text(
        'Identity Verification',
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
        ),
      )),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(10.0, 30, 10, 10),
                  child: Text('Avail a discount by verifying your identity!')),
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 30, 10, 10),
                child: DropdownButtonFormField<UserType>(
                  decoration: ThemeHelper().textInputDecoration(
                      'Discount Type', 'Select your Account type'),
                  items: UserType.values.map((userType) {
                    return DropdownMenuItem<UserType>(
                      value: userType,
                      child: Text(userType.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (UserType? newValue) {
                    setState(() {
                      _selectedUserType = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a user type';
                    }
                    return null;
                  },
                ),
              ),
              _imageInput('Front of ID Card', 'front', _frontIdImage),
              _imageInput('Back of ID Card', 'back', _backIdImage),
              _imageInput('Selfie with ID', 'selfie', _selfieImage),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _frontIdImage != null &&
                      _backIdImage != null &&
                      _selfieImage != null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 20),
                              Text("Submitting images..."),
                            ],
                          ),
                        );
                      },
                    );

                    final frontIdImageUrl =
                        await _uploadImage(_frontIdImage!, userId, 'frontId');
                    final backIdImageUrl =
                        await _uploadImage(_backIdImage!, userId, 'backId');
                    final selfieImageUrl =
                        await _uploadImage(_selfieImage!, userId, 'selfie');

                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get();
                    final displayName = userDoc['displayName'];

                    await _submitVerificationRequest(
                        userId,
                        _selectedUserType!,
                        frontIdImageUrl,
                        backIdImageUrl,
                        selfieImageUrl,
                        displayName);

                    // Hide the alert dialog.
                    Navigator.pop(context);

                    // Show a success message and navigate back to the previous screen.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Verification request submitted successfully')),
                    );
                    Navigator.of(context)
                        .pushNamed(EditProfileScreen.routename);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Please fill out all fields and upload all images')),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(60, 15, 60, 15),
                  child: Text(
                    "Submit",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        fontSize: SizeConfig.blockSizeHorizontal * 4.5),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20), // Set the desired radius here
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 3),
            ],
          ),
        ),
      ),
    );
  }
}
