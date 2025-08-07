import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../bus/auth/bus_registration.dart';
import '../auth/admin_landingscreen.dart';
import '../admin_screens/all_earnings_screen.dart';
import '../admin_screens/admin_verificationlist.dart';
import '../admin_screens/admin_location_screen.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final FirebaseAuth auth = FirebaseAuth.instance;
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      surfaceTintColor: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            child: Stack(
              children: [
                UserAccountsDrawerHeader(
                  margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  accountName: const Text(
                    'ADMIN',
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(user?.email ?? ''),
                  currentAccountPictureSize: const Size.square(55),
                  currentAccountPicture: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.black,
                      child: Icon(
                        Icons.supervisor_account,
                        color: Theme.of(context).colorScheme.primary,
                        size: 45,
                      )),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.dashboard_outlined,
              color: Colors.black,
            ),
            title: const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushNamed(AllEarningsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.bus_alert_outlined,
              color: Colors.black,
            ),
            title: const Text(
              'Bus Registration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushNamed(BusRegistrationScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.verified_user_outlined,
              color: Colors.black,
            ),
            title: const Text(
              'User Verification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(AdminVerificationScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.bus_alert,
              color: Colors.black,
            ),
            title: const Text(
              'Buses on The Road',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushNamed(AdminLocationScreen.routeName);
            },
          ),
          const Divider(),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.black,
                ),
                title: const Text('Logout'),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text('Logout'),
                            onPressed: () async {
                              await auth.signOut();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AdminLandingScreen.routeName,
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
