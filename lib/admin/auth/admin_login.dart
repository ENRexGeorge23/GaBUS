import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gabus_build/admin/admin_screens/all_earnings_screen.dart';
import '/common/theme_helper.dart';

import '/screens/authentication/users/login_validator.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  static const routeName = '/admin-login';

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _adminLogin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: '${_usernameController.text}@admin.com',
        password: _passwordController.text,
      );
      User? user = userCredential.user;
      if (user != null) {
        // check if the user is an admin
        final CollectionReference adminCollection =
            FirebaseFirestore.instance.collection('admin');
        DocumentSnapshot adminSnapshot =
            await adminCollection.doc(user.uid).get();
        if (adminSnapshot.exists &&
            (adminSnapshot.data() as Map<String, dynamic>)['isAdmin'] == true) {
          // user is an admin, navigate to the admin screen
          // You can navigate to the admin screen using the Navigator class
          Navigator.pushNamed(context, AllEarningsScreen.routeName);
        } else {
          // user is not an admin, show an error message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('You are not authorized to access this page.')));
        }
      }
    } catch (e) {
      print(e);
      // show an error message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to login. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFFDB),
      body: Column(
        children: [
          SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: Column(
                children: [
                  Text(
                    'Admin',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 70,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Login',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  SizedBox(height: 30.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          child: TextFormField(
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            decoration: ThemeHelper().textInputDecoration(
                                'Admin Username', 'Enter admin username'),
                            validator: validateUsername,
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter admin password',
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: _togglePasswordVisibility,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 0, 20, 10),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade400)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide(
                                      color: Colors.red, width: 2.0)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide(
                                      color: Colors.red, width: 2.0)),
                            ),

                            validator: validatePassword,
                            // Add password validation logic here
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor: Color(0xFFFF8B00),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(60, 10, 60, 10),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _adminLogin();
                                }
                              }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
