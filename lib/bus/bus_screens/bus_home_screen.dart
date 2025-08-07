import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../widgets/gradient_scaffold.dart';
import '../bus_providers/bus_provider.dart';
import '/bus/bus_widgets/bus_drawer.dart';
import 'bus_location_screen.dart';

class BusHomeScreen extends StatefulWidget {
  const BusHomeScreen({super.key});
  static const routeName = '/bus-home';

  @override
  State<BusHomeScreen> createState() => _BusHomeScreenState();
}

class _BusHomeScreenState extends State<BusHomeScreen> {
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    _loadInitialStatus();
  }

  Future<void> _loadInitialStatus() async {
    String status = await _getStatus();
    setState(() {
      _statusText = status;
    });
  }

  Future<void> _setStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('busStatus', status);
  }

  Future<String> _getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('busStatus') ?? '';
  }

  Future<void> _onLoggedOffPressed() async {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final bus = busProvider.currentBus;
    busProvider.currentBusStatus = 'Logged Off';

    if (bus != null) {
      await FirebaseFirestore.instance
          .collection('busStatuses')
          .doc(bus.busNumber)
          .update({
        'status': 'loggedOff',
        'route': '',
        'time': FieldValue.delete(), // Add this line to delete the time field
      });
      setState(() {
        _statusText = 'Not Available: Logged Off';
      });
      await _setStatus(_statusText);
    }
  }

  Future<void> _onCsbtPressed() async {
    BusProvider busProvider = Provider.of<BusProvider>(context, listen: false);
    final bus = busProvider.currentBus;
    busProvider.currentBusStatus = 'CSBT road';

    if (bus != null) {
      // Get the time from the buses collection
      DocumentSnapshot busDoc = await FirebaseFirestore.instance
          .collection('buses')
          .doc(busProvider.currentBusDocId)
          .get();
      String time = busDoc['timeOne'];

      // parse time with AM/PM
      DateTime parsedTime = DateFormat.jm().parse(time);

      // convert time to 24 hour format
      String time24 = DateFormat.Hm().format(parsedTime);

      await FirebaseFirestore.instance
          .collection('busStatuses')
          .doc(bus.busNumber)
          .set({
        'busNumber': bus.busNumber,
        'plateNumber': bus.busPlateNumber,
        'route': bus.routeOne,
        'status': 'CSBT road',
        'time': time24, // add the time field here
      });

      // Write to Firebase Realtime Database
      final databaseReference = FirebaseDatabase.instance.ref();
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await databaseReference
          .child('buses')
          .child(bus.busNumber)
          .child(currentDate)
          .child("timeStamps")
          .set({'chosenTime': time24});

      setState(() {
        _statusText = 'CSBT road';
        if (bus != null) {
          busProvider.currentRoute = bus.routeOne;
        }
      });
      await _setStatus(_statusText);
      Navigator.push(
        context,
        BusLocationScreen.route(),
      );
    }
  }

  Future<void> _onBatoPressed() async {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final bus = busProvider.currentBus;
    busProvider.currentBusStatus = 'Bato road';

    if (bus != null) {
      // Get the time from the buses collection
      DocumentSnapshot busDoc = await FirebaseFirestore.instance
          .collection('buses')
          .doc(busProvider.currentBusDocId)
          .get();
      String time = busDoc['timeTwo'];
      // parse time with AM/PM
      DateTime parsedTime = DateFormat.jm().parse(time);

      // convert time to 24 hour format
      String time24 = DateFormat.Hm().format(parsedTime);

      await FirebaseFirestore.instance
          .collection('busStatuses')
          .doc(bus.busNumber)
          .set({
        'busNumber': bus.busNumber,
        'plateNumber': bus.busPlateNumber,
        'route': bus.routeTwo,
        'status': 'Bato road',
        'time': time24, // add the time field here
      });

      // Write to Firebase Realtime Database
      final databaseReference = FirebaseDatabase.instance.ref();
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await databaseReference
          .child('buses')
          .child(bus.busNumber)
          .child(currentDate)
          .child("timeStamps")
          .set({'chosenTime': time24});

      setState(() {
        _statusText = 'Bato road';
        if (bus != null) {
          busProvider.currentRoute = bus.routeTwo;
        }
      });
      await _setStatus(_statusText);
      Navigator.push(
        context,
        BusLocationScreen.route(),
      );
    }
  }

  Color _statusTextColor() {
    switch (_statusText) {
      case 'CSBT road':
        return Colors.green;
      case 'Bato road':
        return Colors.green;
      case 'Logged Off':
        return Colors.red;
      default:
        return Colors.red;
    }
  }

  Color _buttonBackgroundColor(String buttonText) {
    if (_statusText.contains(buttonText)) {
      return _statusTextColor();
    } else {
      return Theme.of(context).colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final bus = busProvider.currentBus;
    String routeOne = bus?.routeOne ?? '';
    String routeTwo = bus?.routeTwo ?? '';

    String buttonTextOne = routeOne.contains('via Oslob')
        ? 'CSBT to Bato (via Oslob)'
        : 'CSBT to Bato (via Barili)';
    String buttonTextTwo = routeTwo.contains('via Oslob')
        ? 'Bato to CSBT (via Oslob)'
        : 'Bato to CSBT (via Barili)';
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'Bus Status',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const BusDrawer(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    const Text(
                      'What\'s Your Status?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _statusTextColor(),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      _buttonBackgroundColor('CSBT road'),
                    ),
                  ),
                  onPressed: _onCsbtPressed,
                  child: Text(
                    buttonTextOne,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      _buttonBackgroundColor('Bato road'),
                    ),
                  ),
                  onPressed: _onBatoPressed,
                  child: Text(
                    buttonTextTwo,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        _buttonBackgroundColor('Logged Off')),
                  ),
                  onPressed: _onLoggedOffPressed,
                  child: const Text(
                    'Logged off',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
