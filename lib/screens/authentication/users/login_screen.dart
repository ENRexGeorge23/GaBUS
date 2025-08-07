import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:gabus_build/screens/home_screen.dart';
import 'package:gabus_build/screens/wallet_screens.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';

import '/common/theme_helper.dart';

import '/admin/auth/admin_landingscreen.dart';

import 'register_screen.dart';
import 'forgot_password.dart';
import 'connectivity_utils.dart';
import 'login_validator.dart';

import '/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login_user';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

late ConnectivityResult _connectivityResult;

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailorUsernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  int _tapCount = 0;

  void _handleTap() {
    setState(() {
      _tapCount++;
      if (_tapCount == 4) {
        Navigator.pushNamed(context, AdminLandingScreen.routeName);
        _tapCount = 0;
      }
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void dispose() {
    super.dispose();
    _emailorUsernameController.dispose();
    _passwordController.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Check for internet connectivity when the screen is loaded
    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _connectivityResult = result;
        if (_connectivityResult == ConnectivityResult.none) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("No Internet Connection"),
                content: const Text(
                    "Please check your internet connection and try again."),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
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

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      UserCredential? registerUser =
          await authProvider.signInWithEmailOrUsernameAndPassword(
              _emailorUsernameController.text, _passwordController.text);

      if (registerUser != null) {
        if (registerUser.user!.emailVerified) {
          Navigator.pushReplacementNamed(
            context,
            HomePageScreen.routeName,
          );
        } else {
          // Show error message
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Error',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Please verify your email before logging in.',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      } else {
        // Show error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Invalid email/username or password.',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFDB),
      body: Column(
        children: [
          Form(
            child: Expanded(
              flex: 25,
              child: GestureDetector(
                onTap: _handleTap,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  margin: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new AssetImage('assets/images/Gabus-Logo.png'),
                        fit: BoxFit.scaleDown),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              // margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                children: [
                  const Text(
                    'Sign In',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 70,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Welcome to GaBus!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 30.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            controller: _emailorUsernameController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: ThemeHelper().textInputDecoration(
                                'Email/Username',
                                'Enter your email or username'),
                            validator: validateEmailOrUsername,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).nextFocus(),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
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
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade400)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2.0)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2.0)),
                            ),
                            validator: validatePassword,
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, ForgotPasswordScreen.routeName);
                            },
                            child: Text(
                              "Forgot your password?",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        Container(
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
                                "Login",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              bool isConnected =
                                  await checkConnectivityAndHandleLogin(
                                      context);
                              if (isConnected) {
                                _handleLogin();
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                          //child: Text('Don\'t have an account? Create'),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                    text: "Don\'t have an account? "),
                                TextSpan(
                                  text: 'Create',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RegisterScreen()));
                                    },
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
