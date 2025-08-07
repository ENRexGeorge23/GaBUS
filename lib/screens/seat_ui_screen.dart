import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gabus_build/screens/terminal_bus_list_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';

import '../bus/bus_providers/bus_provider.dart';
import '../providers/selected_seat_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/seat_selection_page.dart'; // Add this import statement

class SeatUiScreen extends StatefulWidget {
  const SeatUiScreen({Key? key}) : super(key: key);
  static const routename = '/seat-ui';

  @override
  SeatUiScreenState createState() => SeatUiScreenState();
}

late ConnectivityResult _connectivityResult;

class SeatUiScreenState extends State<SeatUiScreen> {
  Timer? _transactionTimer;

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
  Widget build(BuildContext context) {
    final busPlateNumber = Provider.of<BusProvider>(context, listen: false);
    Bus? bus = busPlateNumber.currentBus;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        title: Text('${bus?.busNumber} - ${bus?.busPlateNumber}'),
      ),
      body: SafeArea(
        child: SeatSelectionPage(
          busId: "${bus?.busNumber}",
        ),
      ),
    );
  }
}
