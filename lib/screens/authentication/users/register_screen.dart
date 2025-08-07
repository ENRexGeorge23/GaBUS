import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../common/theme_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'login_screen.dart';
import 'validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
  static const routeName = '/register';
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _username;
  String? _usernameError;

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //butngan diri ug dispose
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    _sexController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
  }

  Future<bool> usernameExists(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> _checkUsername(String value) async {
    final exists = await usernameExists(value);
    if (exists) {
      setState(() {
        _usernameError = 'This username is already in use';
      });
    } else {
      setState(() {
        _usernameError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFDB),
      body: SingleChildScrollView(
        child: Consumer<AuthProvider>(builder: (context, state, _) {
          return Container(
            margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 60,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Create an Account, its free',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShaddow(),
                              child: TextFormField(
                                controller: _displayNameController,
                                decoration: ThemeHelper().textInputDecoration(
                                    'Full Name*', 'Enter your full name'),
                                validator: validateDisplayName,
                                onSaved: (value) {
                                  _displayNameController.text =
                                      value.toString();
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShaddow(),
                              child: TextFormField(
                                controller: _usernameController,
                                decoration: ThemeHelper().textInputDecoration(
                                    'Username*', 'Enter your username'),
                                onChanged: (value) {
                                  _username = value;
                                  _checkUsername(value);
                                },
                                validator: validateUsername,
                                onSaved: (value) {
                                  _usernameController.text = value.toString();
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShaddow(),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: ThemeHelper().textInputDecoration(
                                    'Email*', 'Enter your email'),
                                validator: validateEmail,
                                onSaved: (value) {
                                  _emailController.text = value.toString();
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShaddow(),
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: ThemeHelper().textInputDecoration(
                                  'Mobile Number*',
                                  'Enter your mobile number',
                                ),
                                validator: validatePhoneNumber,
                                inputFormatters: [
                                  MaskTextInputFormatter(mask: '+63##########')
                                ],
                                onSaved: (value) {
                                  _phoneController.text = value.toString();
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShaddow(),
                              child: TextFormField(
                                controller: _birthdateController,
                                decoration: ThemeHelper().textInputDecoration(
                                  'Birthdate*',
                                  'Select Your Birthdate',
                                ),
                                onTap: () async {
                                  DateTime? pickeddate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(2000),
                                      firstDate: DateTime(1940),
                                      lastDate: DateTime.now());

                                  if (pickeddate != null) {
                                    setState(() {
                                      _birthdateController.text =
                                          DateFormat.yMMMd().format(pickeddate);
                                    });
                                  }
                                },
                                validator: validateBirthdate,
                                onSaved: (value) {
                                  _birthdateController.text = value.toString();
                                },
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShaddow(),
                              child: DropdownButtonFormField<String>(
                                decoration: ThemeHelper().textInputDecoration(
                                  'Gender',
                                  'Select Your Gender',
                                ),
                                items: state.genderItems
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(item),
                                        ))
                                    .toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    state.updateSelectedGender(newValue);
                                  }
                                },
                                onSaved: (value) {
                                  _sexController.text = value.toString();
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShaddow(),
                              child: TextFormField(
                                controller: _addressController,
                                decoration: ThemeHelper().textInputDecoration(
                                    'Address*', 'Enter your current address'),
                                validator: validateAddress,
                                onSaved: (value) {
                                  _addressController.text = value.toString();
                                },
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShaddow(),
                              child: TextFormField(
                                obscureText: true,
                                controller: _passwordController,
                                decoration: ThemeHelper().textInputDecoration(
                                    "Password*", "Enter your password"),
                                validator: validatePassword,
                                onSaved: (value) {
                                  _passwordController.text = value.toString();
                                },
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShaddow(),
                              child: TextFormField(
                                obscureText: true,
                                decoration: ThemeHelper().textInputDecoration(
                                    "Confirm Password*",
                                    "Re-enter your password"),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Confirm password is required';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }

                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Container(
                              margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  backgroundColor: const Color(0xFFFF8B00),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final exists = await usernameExists(
                                        _usernameController.text);
                                    if (exists) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'The username is already in use'),
                                        ),
                                      );
                                      return;
                                    }

                                    _formKey.currentState!.save();
                                    UserCredential? userCredential =
                                        await state.registerUser(
                                      _emailController.text,
                                      _passwordController.text,
                                      _usernameController.text,
                                      _displayNameController.text,
                                      _phoneController.text,
                                      _birthdateController.text,
                                      state.selectedGender,
                                      _addressController.text,
                                    );
                                    if (userCredential != null) {
                                      bool isEmailVerified =
                                          await state.checkEmailVerified();
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      Navigator.pushReplacementNamed(
                                          context, LoginScreen.routeName);
                                      if (!isEmailVerified) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please check your email and verify your account before logging in.'),
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Email provided is already in use'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 10, 20),
                              //child: Text('Don\'t have an account? Create'),
                              child: Text.rich(TextSpan(children: [
                                const TextSpan(
                                    text: "Already have an account? "),
                                TextSpan(
                                  text: 'Log in',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen()));
                                    },
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ])),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
