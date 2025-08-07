import 'package:flutter/material.dart';
import '../bus_widgets/bus_drawer.dart';
import '../bus_widgets/driver_seat_selection_page.dart';
import 'package:provider/provider.dart';
import '../bus_providers/bus_provider.dart';

class DriverSeatUiScreen extends StatefulWidget {
  const DriverSeatUiScreen({Key? key}) : super(key: key);
  static const routeName = '/driver-seat-ui';

  @override
  DriverSeatUiScreenState createState() => DriverSeatUiScreenState();
}

class DriverSeatUiScreenState extends State<DriverSeatUiScreen> {
  @override
  Widget build(BuildContext context) {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final bus = busProvider.currentBus;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        title: Text(
          '${bus?.busNumber} - Available Seat Interface',
          style: TextStyle(fontSize: 15.5),
        ),
      ),
      body: SafeArea(
        child: DriverSeatSelectionPage(
          busId: "${bus?.busNumber}",
        ),
      ),
    );
  }
}
