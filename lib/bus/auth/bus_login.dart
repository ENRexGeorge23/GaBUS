import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/common/theme_helper.dart';

import '/bus/bus_screens/bus_home_screen.dart';

import '../auth/bus_validator.dart';
import '../bus_providers/bus_provider.dart';
import 'package:provider/provider.dart';

class BusLoginScreen extends StatefulWidget {
  const BusLoginScreen({super.key});
  static const routeName = '/bus-login';

  @override
  State<BusLoginScreen> createState() => _BusLoginScreenState();
}

class _BusLoginScreenState extends State<BusLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _busNumberController = TextEditingController();
  TextEditingController _busPlateNumberController = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _busLogin(BuildContext context) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: '${_busNumberController.text}@bus.com',
        password: _busPlateNumberController.text,
      );
      final user = userCredential.user;
      if (user != null) {
        // Get an instance of BusProvider
        BusProvider busProvider =
            Provider.of<BusProvider>(context, listen: false);
        final busSnapshot =
            await busProvider.busesCollection.doc(user.uid).get();
        if (busSnapshot.exists) {
          // Here, user.uid is the document id.
          busProvider.currentBusDocId = user.uid;

          Navigator.pushNamedAndRemoveUntil(
            context,
            BusHomeScreen.routeName,
            (route) => false,
          );
        } else {
          // user is not a bus, show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are not authorized to access this page.'),
            ),
          );
        }
      }
    } catch (e) {
      print(e);
      // show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to login. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFEFFDB),
      body: Column(
        children: [
          Form(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              alignment: Alignment.center,
              child: const Icon(
                Icons.directions_bus_filled,
                size: 110,
                color: Colors.orange,
              ),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'Bus Driver',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Login',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    const SizedBox(height: 30.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            decoration:
                                ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              controller: _busNumberController,
                              keyboardType: TextInputType.text,
                              decoration: ThemeHelper().textInputDecoration(
                                  'Bus Number', 'Enter Bus Number'),
                              validator: validateBusNumber,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration:
                                ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              controller: _busPlateNumberController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: 'Bus Plate Number',
                                hintText: 'Enter Bus Plate Number',
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: _togglePasswordVisibility,
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 10),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide:
                                        const BorderSide(color: Colors.grey)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 2.0)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 2.0)),
                              ),

                              validator: validateBusPlateNumber,
                              // Add password validation logic here
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor: Color(0xFFFF8B00),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
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
                                  _busLogin(context);
                                }
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
