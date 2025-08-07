import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gabus_build/screens/bus_schedule_screen.dart';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import '../common/app_layout.dart';
import '../common/size_config.dart';

import '../providers/road_provider.dart';
import '../providers/terminal_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/booking_widget.dart';
import 'book_from_screen.dart';
import 'wallet_screens.dart';
import 'our_mission_screen.dart';
import 'terminal_bus_list_screen.dart';
import 'user_location_screen.dart';
import 'about_us_screen.dart';

import 'authentication/users/login_screen.dart';
import 'authentication/users/auth_service.dart';

import '../widgets/app_drawer.dart';
import '../widgets/booking_card_cancelled.dart';
import '../widgets/menu_box.dart';
import '../widgets/booking_card.dart';
import '../widgets/carousel_card.dart';
import '../widgets/gradient_scaffold.dart';

class HomePageScreen extends StatefulWidget {
  static const routeName = '/home_page';

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

late ConnectivityResult _connectivityResult;

class _HomePageScreenState extends State<HomePageScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double _balance = 0;
  late String _username = '';

  @override
  void initState() {
    super.initState();
    _getUserName();
    _loadBalance();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Reset both OnTerminalProvider and OnRoadProvider every time the widget is rebuilt with new dependencies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OnTerminalProvider>(context, listen: false).reset();
      Provider.of<OnRoadProvider>(context, listen: false).reset();
    });
  }

  void _loadBalance() async {
    double balance = await _authService.getBalance();
    setState(() {
      _balance = balance;
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
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    User? currentUser = authProvider.getCurrentUser();
    userProvider.fetchUserDataRealTime(currentUser!.uid);

    final size = AppLayout.getSize(context);
    SizeConfig().init(context);
    return Consumer(builder: (context, cancellationProvider, child) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawer(),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade50,
                      Colors.orange.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SizeConfig.safeBlockVertical * 25.0),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Add your code to be executed on tap
                              Navigator.of(context).pushNamed(
                                BookFromScreen.routeName,
                              );
                            },
                            child: const MenuWidget(
                              icon: Icons.book_online_outlined,
                              text: "Book Now",
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Provider.of<OnTerminalProvider>(context,
                                      listen: false)
                                  .setOnTerminal(true);
                              Navigator.pushNamed(
                                  context, BusScheduleScreen.routeName);
                            },
                            child: const MenuWidget(
                              icon: Icons.schedule_outlined,
                              text: "Bus Schedules",
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, OurMissionScreen.routeName);
                            },
                            child: const MenuWidget(
                              icon: Icons.pending_actions_outlined,
                              text: "Our Mission",
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, AboutUsScreen.routeName);
                            },
                            child: const MenuWidget(
                              icon: Icons.groups_sharp,
                              text: "About Us",
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 3.0),
                    const BookingWidget(),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2.0),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade100,
                            Colors.orange.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black87.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Text(
                              'Popular Destinations'.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 3),
                          CarouselCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade100,
                      Colors.orange.shade100,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(5, 33, 5, 0),
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 15),
                              child: Image.asset(
                                'assets/images/Gabus-Logo.png',
                                height: 30,
                                width: 30,
                                //put your logo here
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            child: SizedBox(
                              width: 225,
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: Text(
                                  'Hello, $_username!',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 30),
                            child: IconButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Logout'),
                                      content: const Text(
                                          'Are you sure you want to logout?'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                        ElevatedButton(
                                          child: const Text('Logout'),
                                          onPressed: () async {
                                            await _auth.signOut();
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              LoginScreen.routeName,
                                              (route) => false,
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.logout_outlined,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 100,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.orange.shade300,
                        margin: const EdgeInsets.fromLTRB(0, 4, 0, 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available GaBus credits'.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '₱ ${NumberFormat('#,##0.00').format(_balance)}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.safeBlockHorizontal * 8,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                    WalletScreen.routeName,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add,
                                      size: 15,
                                    ),
                                    Text(
                                      '  Cash In',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
