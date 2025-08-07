import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gabus_build/bus/auth/bus_login.dart';
import 'package:gabus_build/bus/bus_providers/bus_provider.dart';
import 'package:gabus_build/bus/bus_screens/bus_earnings_screen.dart';
import 'package:gabus_build/bus/bus_screens/bus_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../bus_screens/driver_seat_ui_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Add this extension to support the toDateTime method for TimeOfDay
extension TimeOfDayExtension on TimeOfDay {
  DateTime toDateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

class BusDrawer extends StatelessWidget {
  const BusDrawer({super.key});

  Future<void> _handleOnTap(BuildContext context) async {
    BusProvider busProvider = Provider.of<BusProvider>(context, listen: false);
    DateTime currentDate = DateTime.now(); // Get the current date
    String? busStatus = busProvider.currentBusStatus;

    if (busStatus == 'Logged Off') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bus Status Logged Off'),
            content: Text(
                'The bus status is currently logged off. Please select a status first.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  print("FROM DRAWER");
                  print(busProvider.currentBusDocId);
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushNamed(BusHomeScreen.routeName);
                },
                child: Text('Go To Bus Status'),
              ),
            ],
          );
        },
      );
    } else {
      // Fetch the current bus details
      await busProvider
          .setCurrentBusByBusNumber(busProvider.currentBus?.busNumber ?? '');

      // Get the current bus instance from the provider
      Bus? currentBus = busProvider.currentBus;
      String providerCurrentRoute = busProvider.currentRoute;

      // Define the current route and time based on the selected route
      String currentRoute;
      TimeOfDay currentTime;

      if (currentBus != null) {
        if (currentBus.routeOne == providerCurrentRoute) {
          currentRoute = currentBus.routeOne;
          currentTime =
              parseTimeString(currentBus.timeOne); // Use the utility function
        } else {
          currentRoute = currentBus.routeTwo;
          currentTime =
              parseTimeString(currentBus.timeTwo); // Use the utility function
        }

        _initializeSeats(
          busProvider.currentBus?.busNumber ??
              '', // Pass busNumber as an argument
          DateFormat('yyyy-MM-dd').format(currentDate),
          DateFormat('HH:mm').format(currentTime.toDateTime(DateTime.now())),
        );

        // Pass the current date, time, and route to the BusProvider
        busProvider.setSelectedBusDetails(
            currentDate, currentTime, currentRoute);

        Navigator.of(context).pop();
        Navigator.pushNamed(context, DriverSeatUiScreen.routeName);
      }
    }
  }

// Parsing Function
  TimeOfDay parseTimeString(String time) {
    final format = DateFormat.jm(); // 12-hour format with AM/PM
    final dt = format.parse(time);
    return TimeOfDay.fromDateTime(dt);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String busNumber, // Add busNumber as an argument
    DateTime selectedDate,
    TimeOfDay selectedTime,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Date and Time'),
              content: Text(
                'You have selected ${DateFormat.yMMMd().format(selectedDate)} at ${DateFormat.jm().format(selectedTime.toDateTime(DateTime.now()))}. Do you want to proceed?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Proceed'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  //Initialize the seats on firebase realtime database

  void _initializeSeats(String busID, String date, String time) async {
    final DatabaseReference busRef = FirebaseDatabase.instance
        .ref()
        .child('buses')
        .child(busID)
        .child(date)
        .child(time)
        .child('seats');

    // Check if the path already exists
    final DataSnapshot dataSnapshot = (await busRef.once()).snapshot;
    if (dataSnapshot.exists && dataSnapshot.value != null) {
      // Path exists and has children, no need to initialize seats again
      return;
    }

    final seatRows = 'ABCDEFGHIJK';
    final seatCols = '123456';

    for (int i = 0; i < seatRows.length; i++) {
      for (int j = 0; j < (i == seatRows.length - 1 ? 6 : 4); j++) {
        final seatId = '${seatRows[i]}${seatCols[j]}';
        busRef.child(seatId).set({
          'isBooked': false,
          'status': 'available',
        });
      }
    }
  }

  Future<void> _showDateTimePicker(
    BuildContext context,
    String busNumber,
    String timeOne,
    String timeTwo,
    String routeOne,
    String routeTwo,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (selectedDate == null) return;

    final timeFormat = DateFormat.jm();
    final timeOptions = [
      TimeOfDay.fromDateTime(timeFormat.parse(timeOne)),
      TimeOfDay.fromDateTime(timeFormat.parse(timeTwo)),
    ];

    final selectedTime = await showModalBottomSheet<TimeOfDay>(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: Text(
                  'Select a Time',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: timeOptions.length,
                  itemBuilder: (ctx, index) {
                    return ListTile(
                      title: Text(
                        DateFormat.jm().format(
                          timeOptions[index].toDateTime(DateTime.now()),
                        ),
                      ),
                      subtitle: Text(
                        index == 0 ? 'Route: $routeOne' : 'Route: $routeTwo',
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop(
                          timeOptions[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedTime == null) return;
    final selectedDateTime = selectedTime.toDateTime(selectedDate);

    final confirm = await _showConfirmationDialog(
      context,
      busNumber, // Pass the busNumber here
      selectedDate,
      selectedTime,
    );
    if (!confirm) return;

    await Provider.of<BusProvider>(context, listen: false)
        .setCurrentBusByBusNumber(busNumber);
    final selectedRoute =
        timeOptions.indexOf(selectedTime) == 0 ? routeOne : routeTwo;
    Provider.of<BusProvider>(context, listen: false).setSelectedBusDetails(
      selectedDate,
      selectedTime,
      selectedRoute,
    );

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const DriverSeatUiScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    BusProvider busProvider = Provider.of<BusProvider>(context);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      surfaceTintColor: Colors.black,
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          DrawerHeader(
            child: Stack(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    'Bus No. ${busProvider.currentBus?.busNumber}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  accountEmail: Text(
                    'Plate No. ${busProvider.currentBus?.busPlateNumber}',
                  ),
                  currentAccountPictureSize: const Size.square(50),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.black,
                    child: Text(
                        // user?.displayName?.substring(0, 1).toUpperCase() ?? '',
                        busProvider.currentBus?.busPlateNumber
                                .substring(0, 1)
                                .toUpperCase() ??
                            ''),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.home_filled,
              color: Colors.black,
            ),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pushNamed(BusHomeScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.monetization_on,
              color: Colors.black,
            ),
            title: const Text('Earnings'),
            onTap: () {
              Navigator.pushNamed(context, BusEarningsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.chair_alt_outlined,
              color: Colors.black,
            ),
            title: const Text('Bus Seats'),
            onTap: () async {
              await _handleOnTap(context);
            },
          ),
          const Divider(),
          ListTile(
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
                      ElevatedButton(
                        child: const Text('Logout'),
                        onPressed: () async {
                          await _auth.signOut();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            BusLoginScreen.routeName,
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
        ],
      ),
    );
  }
}
