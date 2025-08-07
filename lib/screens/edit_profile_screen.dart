import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:gabus_build/screens/verification/verification_screen.dart';

import '../common/edit_theme.dart';
import '../common/size_config.dart';
import '../common/theme_helper.dart';
import '../widgets/app_drawer.dart';
import '../widgets/gradient_scaffold.dart';

import '../widgets/header_widget.dart';
import './authentication/users/validators.dart';
import 'authentication/users/change_password.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  static const routename = '/edit-profile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

late ConnectivityResult _connectivityResult;

class _EditProfileScreenState extends State<EditProfileScreen> {
  final double _headerHeight = 250;
  TextEditingController? _usernameController;
  TextEditingController? _displayNameController;
  TextEditingController? _phoneNumberController;
  TextEditingController? _addressController;
  TextEditingController? _passwordController;

  String? _username;
  String? _displayName;
  String? _phoneNumber;
  String? _address;

  Future<DocumentSnapshot> fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
    }
    throw Exception('User not logged in');
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  void updateData() {
    fetchUserData().then((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _username = userData['username'];
          _displayName = userData['displayName'];
          _phoneNumber = userData['phoneNumber'];
          _address = userData['address'];

          // Set the text editing controllers to the current values
          _usernameController?.text = _username!;
          _displayNameController?.text = _displayName!;
          _phoneNumberController?.text = _phoneNumber!;
          _addressController?.text = _address!;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize the text editing controllers
    _usernameController = TextEditingController();
    _displayNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();

    // Fetch the user data and update the state variables
    updateData();

    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _connectivityResult = result;
        if (_connectivityResult == ConnectivityResult.none) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("No Internet Connection"),
                content: Text(
                    "Please check your internet connection and try again."),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        }
      });
    });
  }

  void _updateProfile() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'username': _usernameController?.text.trim(),
          'displayName': _displayNameController?.text.trim(),
          'phoneNumber': _phoneNumberController?.text.trim(),
          'address': _addressController?.text.trim(),
        });
        // Update the displayName field in Firebase Authentication
        await currentUser
            .updateDisplayName(_displayNameController?.text.trim() ?? '');
        // Reload the user object after updating the profile
        await currentUser.reload();
        // Call updateData() to reflect the updated profile data in the local state variables
        updateData();
      } catch (e) {
        // Show an error message if there was a problem updating the profile data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.toString()}')),
        );
      }
    }
  }

  Future<String?> _showPasswordDialog() {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: const Text('Verify Identity')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please verify your identiy by entering your current password before making changes to your account.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: ThemeHelper().textInputDecoration(
                    'Confirm Password', 'Enter your password'),
                obscureText: true,
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Your Password is required';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String password = controller.text;
                User? currentUser = FirebaseAuth.instance.currentUser;

                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please enter your password to save changes.')),
                  );
                  return;
                }

                if (currentUser != null) {
                  AuthCredential credential = EmailAuthProvider.credential(
                      email: currentUser.email!, password: password);

                  try {
                    await currentUser.reauthenticateWithCredential(credential);
                    Navigator.of(context).pop(password);
                  } catch (e) {
                    // Show error message if reauthentication fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect password')),
                    );
                  }
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _addressController?.dispose();
    _usernameController?.dispose();
    _phoneNumberController?.dispose();
    _displayNameController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 238, 192),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Container(
            height: _headerHeight,
            child: HeaderWidget(_headerHeight, true, Icons.person_rounded),
          ),
          const SizedBox(height: 175),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 150, 20, 0),
            padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
            child: ListView(
              children: [
                Container(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: _getUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {}

                      if (snapshot.hasData) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        final isVerified = data?['isVerified'];
                        final isDeclined = data?['isDeclined'];

                        IconData? iconData;
                        String verificationText;
                        Color fontColor;
                        bool isClickable;

                        if (isVerified == null) {
                          iconData = Icons.new_releases_outlined;
                          verificationText = "Verify here to avail a Discount.";
                          fontColor = Colors.black;
                          isClickable = true;
                        } else if (isVerified == false) {
                          if (isDeclined == true) {
                            verificationText =
                                "Please submit your verification request again.";
                            fontColor = Colors.red;
                            isClickable = true;
                          } else {
                            verificationText =
                                "Verification request submitted. Check back soon.";
                            fontColor = Colors.red;
                            isClickable = false;
                          }
                        } else {
                          iconData = Icons.verified;
                          verificationText =
                              "Verified: Applicable for Discounts";
                          fontColor = Colors.green;
                          isClickable = false;
                        }

                        return GestureDetector(
                          onTap: isClickable
                              ? () {
                                  Navigator.of(context)
                                      .pushNamed(VerificationScreen.routename);
                                }
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (iconData != null)
                                Icon(
                                  iconData,
                                  color: fontColor,
                                  size: 16,
                                ),
                              SizedBox(width: 3),
                              Text(
                                verificationText,
                                style: TextStyle(
                                  color: fontColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return Text(
                        "Error fetching user data",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  decoration: EditTheme().textInputDecoration(
                      labelText: 'Username', icon: Icons.person_rounded),
                  controller: _usernameController,
                  validator: validateUsername,
                  onChanged: (value) {
                    setState(() {
                      _username = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Display Name TextField
                TextFormField(
                  decoration: EditTheme().textInputDecoration(
                    labelText: 'Full Name',
                    icon: Icons.perm_contact_cal_rounded,
                  ),
                  controller: _displayNameController,
                  onChanged: (value) {
                    setState(() {
                      _displayName = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Phone Number TextField
                TextFormField(
                  decoration: EditTheme().textInputDecoration(
                    labelText: 'Mobile Number',
                    icon: Icons.phone,
                  ),
                  controller: _phoneNumberController,
                  onChanged: (value) {
                    setState(() {
                      _phoneNumber = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Address TextField
                TextFormField(
                  decoration: EditTheme().textInputDecoration(
                    labelText: 'Current Address',
                    icon: Icons.home,
                  ),
                  controller: _addressController,
                  onChanged: (value) {
                    setState(() {
                      _address = value;
                    });
                  },
                ),

                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePasswordScreen()),
                      );
                    },
                    child: Text(
                      'Reset your password',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    )),

                const SizedBox(height: 20),

                // Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      String? usernameError =
                          validateUsername(_usernameController?.text);
                      if (usernameError != null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Invalid Username'),
                              content: Text(usernameError),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      // Get the current user
                      User? currentUser = FirebaseAuth.instance.currentUser;

                      _showPasswordDialog().then((password) {
                        if (password != null) {
                          AuthCredential credential =
                              EmailAuthProvider.credential(
                                  email: currentUser?.email ?? '',
                                  password: password);
                          currentUser
                              ?.reauthenticateWithCredential(credential)
                              .then((_) {
                            // If the user entered the correct password, update the profile
                            _updateProfile();
                            updateData();

                            // Show a snackbar message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile updated')),
                            );
                          });
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(60, 15, 60, 15),
                      child: Text(
                        "Save",
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
