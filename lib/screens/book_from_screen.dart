import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gabus_build/screens/home_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';

import '../providers/origin_provider.dart';
import '../providers/road_provider.dart';
import '../providers/terminal_provider.dart';
import 'user_location_screen.dart';
import 'terminal_bus_list_screen.dart';

import 'authentication/users/auth_service.dart';

import '../widgets/app_drawer.dart';
import '../widgets/gradient_scaffold.dart';

class BookFromScreen extends StatefulWidget {
  const BookFromScreen({super.key});
  static const routeName = '/book-from';

  @override
  State<BookFromScreen> createState() => _BookFromScreenState();
}

late ConnectivityResult _connectivityResult;

class _BookFromScreenState extends State<BookFromScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  double _balance = 0;
  late String _username = '';

  @override
  void initState() {
    super.initState();
    _getUserName();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Reset both OnTerminalProvider and OnRoadProvider every time the widget is rebuilt with new dependencies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OnTerminalProvider>(context, listen: false).reset();
      Provider.of<OnRoadProvider>(context, listen: false).reset();
    });
  }

  void _getUserName() async {
    final user = _auth.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    setState(() {
      _username = userDoc.get('username');
    });
  }

  @override
  Widget _cardMenu({
    required String title,
    required String icon,
    VoidCallback? onTap,
    Color color = const Color.fromARGB(255, 247, 159, 28),
    Color fontColor = Colors.black87,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade50,
              Colors.orange.shade500,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black87.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 50,
        ),
        width: 156,
        child: Column(
          children: [
            Image.asset(icon),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: fontColor),
            )
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed(HomePageScreen.routeName);
        return false; // Prevents the page from being popped
      },
      child: GradientScaffold(
        appBar: AppBar(
          title: const Text(
            'Reservation',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        drawer: const AppDrawer(),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  alignment: Alignment.center,
                  height: 120,
                  child: Image.asset(
                    'assets/images/Gabus-Logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Text(
                    'Hi, $_username!',
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: const Text(
                          "No matter where you start your journey, we've got you covered. Reserve your bus ticket now.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _cardMenu(
                              onTap: () {
                                Provider.of<OnTerminalProvider>(context,
                                        listen: false)
                                    .setOnTerminal(true);
                                Navigator.pushNamed(
                                    context, TerminalBusListScreen.routeName);
                              },
                              title: 'Terminal'.toUpperCase(),
                              icon: 'assets/images/ontheterminal.png'),
                          _cardMenu(
                            onTap: () {
                              Provider.of<OnRoadProvider>(context,
                                      listen: false)
                                  .setOnRoad(true);

                              Navigator.pushNamed(
                                  context, UserLocationScreen.routeName);
                            },
                            title: 'On the Road'.toUpperCase(),
                            icon: 'assets/images/ontheroad.png',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
