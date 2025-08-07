import 'package:flutter/material.dart';
import '/common/theme_helper.dart';
import 'admin_login.dart';
import '/bus/auth/bus_login.dart';

class AdminLandingScreen extends StatefulWidget {
  const AdminLandingScreen({super.key});
  static const routeName = '/admin-landing';

  @override
  State<AdminLandingScreen> createState() => _AdminLandingScreenState();
}

class _AdminLandingScreenState extends State<AdminLandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFFDB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(25, 150, 25, 10),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              height: 250,
              child: Icon(
                Icons.manage_accounts_sharp,
                size: 250,
                color: Colors.orange,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 50, 25, 10),
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              decoration: ThemeHelper().buttonBoxDecoration(context),
              child: ElevatedButton(
                style: ThemeHelper().buttonStyle(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(80, 15, 80, 15),
                  child: Text(
                    "As Driver",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BusLoginScreen()));
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 20, 25, 0),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: ThemeHelper().buttonBoxDecoration(context),
              child: ElevatedButton(
                style: ThemeHelper().buttonStyle(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(80, 15, 80, 15),
                  child: Text(
                    "As Admin",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminLoginScreen()));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
