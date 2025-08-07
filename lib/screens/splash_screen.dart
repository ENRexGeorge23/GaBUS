import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gabus_build/bus/auth/bus_login.dart';
import 'package:gabus_build/bus/bus_providers/bus_provider.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';

import '../bus/bus_screens/bus_home_screen.dart';
import 'authentication/users/login_screen.dart';
import '/providers/auth_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const routeName = '/splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isVisible = false;
  bool _isAuthenticatedChecked = false;
  late ConnectivityResult _connectivityResult;

  @override
  void initState() {
    super.initState();
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.checkEmailVerified().then((isEmailVerified) {
      if (isEmailVerified && authProvider.isAuthenticated) {
        Timer(const Duration(milliseconds: 1800), () {
          setState(() {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomePageScreen()),
                (route) => false);
          });
        });
      } else {
        Timer(
          const Duration(milliseconds: 3000),
          () {
            setState(() {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false);
            });
          },
        );
      }
      Timer(const Duration(milliseconds: 10), () {
        setState(() {
          _isVisible =
              true; // Now it is showing fade effect and navigating to Login/Home page
        });
      });
      _isAuthenticatedChecked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 139, 0),
            Color.fromARGB(255, 243, 170, 60),
          ],
          begin: FractionalOffset(0, 0),
          end: FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0,
        duration: const Duration(milliseconds: 2000),
        child: Center(
          child: Container(
            height: 250.0,
            width: 250.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 2.0,
                    offset: const Offset(5.0, 3.0),
                    spreadRadius: 2.0,
                  )
                ]),
            child: Center(
              child: Image.asset(
                'assets/images/Gabus-Logo.png',
                fit: BoxFit.cover,
                //put your logo here
              ),
            ),
          ),
        ),
      ),
    );
  }
}
