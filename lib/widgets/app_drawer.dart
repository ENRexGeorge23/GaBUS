import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/book_from_screen.dart';
import '../screens/bus_schedule_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/home_screen.dart';
import '../screens/authentication/users/login_screen.dart';
import '../screens/terminal_bus_list_screen.dart';
import '../screens/wallet_screens.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int _selectedIndex = 0;

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    if (currentRoute == HomePageScreen.routeName && _selectedIndex != 0) {
      _selectedIndex = 0;
    } else if (currentRoute == TerminalBusListScreen.routeName &&
        _selectedIndex != 1) {
      _selectedIndex = 1;
    } else if (currentRoute == WalletScreen.routeName && _selectedIndex != 2) {
      _selectedIndex = 2;
    } else if (currentRoute == BookFromScreen.routeName &&
        _selectedIndex != 3) {
      _selectedIndex = 3;
    }

    List<Widget> _drawerTiles = [
      Container(
        margin: const EdgeInsets.only(right: 20),
        width: 250,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          selected: _selectedIndex == 0,
          selectedTileColor: Colors.white,
          leading: const Icon(
            Icons.home_filled,
            color: Colors.black,
          ),
          title: const Text(
            'Home',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            _onItemTap(0);
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 200), () {
              Navigator.of(context)
                  .pushReplacementNamed(HomePageScreen.routeName);
            });
          },
        ),
      ),
      Container(
        margin: const EdgeInsets.only(right: 20),
        width: 250,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          selected: _selectedIndex == 3,
          selectedTileColor: Colors.white,
          leading: const Icon(
            Icons.book_online_outlined,
            color: Colors.black,
          ),
          title: const Text(
            'Book Now',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            _onItemTap(3);
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 200), () {
              Navigator.of(context)
                  .pushReplacementNamed(BookFromScreen.routeName);
            });
          },
        ),
      ),
      Container(
        margin: const EdgeInsets.only(right: 20),
        width: 250,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          selected: _selectedIndex == 2,
          selectedTileColor: Colors.white,
          leading: const Icon(
            Icons.wallet,
            color: Colors.black,
          ),
          title: const Text(
            'Wallet',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            _onItemTap(2);
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 200), () {
              Navigator.of(context)
                  .pushReplacementNamed(WalletScreen.routeName);
            });
          },
        ),
      ),
      Container(
        margin: const EdgeInsets.only(right: 20),
        width: 250,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          selected: _selectedIndex == 1,
          selectedTileColor: Colors.white,
          leading: const Icon(
            Icons.schedule_outlined,
            color: Colors.black,
          ),
          title: const Text(
            'Bus Schedule',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            _onItemTap(1);
            Navigator.of(context)
                .pop(); // Add a null check before accessing Navigator object
            Future.delayed(const Duration(milliseconds: 50), () {
              Navigator.pushNamed(
                context, // Add a null check before accessing the BuildContext object
                BusScheduleScreen.routeName,
              );
            });
          },
        ),
      ),
    ];

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      width: 270,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                Container(
                  child: UserAccountsDrawerHeader(
                    accountName: Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.black,
                              child: Text(
                                user?.displayName
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    '',
                              ),
                              radius: 100, // Adjust the radius here
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user?.displayName ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user?.email ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    accountEmail: const Text(''),
                    margin: EdgeInsets.zero,
                    otherAccountsPictures: [],
                  ),
                ),
                Positioned(
                  top: 125,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(EditProfileScreen.routename);
                    },
                    child: Text(
                      'Manage your profile',
                      style: TextStyle(
                        color: Colors.orange.shade100,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          _drawerTiles[0],
          _drawerTiles[1],
          _drawerTiles[2],
          _drawerTiles[3],
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.black54,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
