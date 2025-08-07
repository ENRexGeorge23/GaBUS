import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gabus_build/bus/bus_screens/bus_home_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/bus_stops_provider.dart';
import '../../providers/selected_seat_provider.dart';
import '../../providers/terminal_seats_provider.dart';
import '../bus_providers/bus_provider.dart';
import '../bus_screens/bus_pay_screen.dart';

class MapPickerBusScreen extends StatefulWidget {
  static const routeName = 'map-picker-bus-screen';

  @override
  _MapPickerBusScreenState createState() => _MapPickerBusScreenState();
}

class _MapPickerBusScreenState extends State<MapPickerBusScreen>
    with WidgetsBindingObserver {
  LatLng? _origin;
  LatLng? _destination;
  String _originTitle = '';
  String? _destinationTitle;
  bool _showOriginMarkers = false;
  bool _showDestinationMarkers = false;
  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  Set<Marker> _markers = {};
  bool _isOriginFixed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initMarkers();

    // start the transaction timer
    // _transactionTimer = Timer(Duration(minutes: 1), _onTransactionTimeout);
  }

  void _onTransactionTimeout() {
    SelectedSeatProvider selectedSeatProvider =
        Provider.of<SelectedSeatProvider>(context, listen: false);

    BusProvider busProvider = Provider.of<BusProvider>(context, listen: false);

    DateTime? selectedDate = busProvider.selectedDate;
    TimeOfDay? selectedTime = busProvider.selectedTime;
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    String formattedTime = DateFormat('HH:mm').format(DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime!.hour,
        selectedTime.minute));

    // Update Firebase Realtime Database
    final ref = FirebaseDatabase.instance.reference();
    final busNumber = busProvider.currentBus?.busNumber;
    final date = formattedDate;
    final time = formattedTime;
    final seatNumbers = selectedSeatProvider.selectedSeats;

    for (var seatNumber in seatNumbers) {
      ref.child('buses/$busNumber/$date/$time/seats/$seatNumber').update({
        'selectedBy': '',
        'selectedSeat': false,
      });
    }
    // Show a dialog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Reservation Failed sa Map Picker Bus Screen ni'),
            content: Text(
                'You did not complete the transaction within the allotted time.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushReplacementNamed(BusHomeScreen.routeName);
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _showMarkerActions(
      MarkerId markerId, LatLng position, String title) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            if (!_isOriginFixed)
              ListTile(
                leading: const Icon(Icons.pin_drop_outlined),
                title: const Text('Make Origin (Asa ka gikan?)'),
                onTap: () {
                  setState(() {
                    _origin = position;
                    _originTitle = title;
                    _originController.text = title;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ListTile(
              leading: const Icon(Icons.pin_drop_outlined),
              title: const Text('Make Destination (Asa ka padulong?)'),
              onTap: () {
                setState(() {
                  _destination = position;
                  _destinationTitle = title;
                  _destinationController.text = title;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _initMarkers() async {
    BusProvider busProvider = Provider.of<BusProvider>(context, listen: false);
    final busStops = context.read<BusStopProvider>().busStops;
    final busStopsBarili = context.read<BusStopProvider>().busStopsBarili;
    final markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/marker.png',
    );

    setState(() {
      if (busProvider.selectedRoute == "CSBT to Bato (via Oslob)" ||
          busProvider.selectedRoute == "Bato to CSBT (via Oslob)") {
        _markers = busStops
            .map(
              (busStop) => Marker(
                markerId: MarkerId(busStop.id),
                position: busStop.position,
                infoWindow: InfoWindow(
                  title: busStop.title,
                  snippet: busStop.snippet,
                ),
                icon: markerIcon,
                onTap: () => _showMarkerActions(
                  MarkerId(busStop.id),
                  busStop.position,
                  busStop.title,
                ),
              ),
            )
            .toSet();
      } else if (busProvider.selectedRoute == "CSBT to Bato (via Barili)" ||
          busProvider.selectedRoute == "Bato to CSBT (via Barili)") {
        _markers = busStopsBarili.map(
          (busStopsBarili) {
            return Marker(
              markerId: MarkerId(busStopsBarili.id),
              position: busStopsBarili.position,
              infoWindow: InfoWindow(
                title: busStopsBarili.title,
                snippet: busStopsBarili.snippet,
              ),
              icon: markerIcon,
              onTap: () => _showMarkerActions(
                MarkerId(busStopsBarili.id),
                busStopsBarili.position,
                busStopsBarili.title,
              ),
            );
          },
        ).toSet();
      }
    });
  }

  Widget _buildOriginField() {
    return _originTitle == null
        ? const Text('')
        : TextFormField(
            readOnly: true,
            controller: _originController,
            decoration: InputDecoration(
              hintText: 'Select origin',
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              suffixIcon: const Icon(Icons.pin_drop_outlined),
            ),
            onTap: _isOriginFixed
                ? null
                : () {
                    setState(() {
                      _origin = null;
                      _originTitle = '';
                      _originController.clear();
                      _showOriginMarkers = true;
                      _showDestinationMarkers = false;
                    });
                  },
          );
  }

  Widget _buildDestinationField() {
    return TextFormField(
      readOnly: true,
      controller: _destinationController,
      decoration: InputDecoration(
        hintText: 'Select destination',
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        suffixIcon: const Icon(Icons.pin_drop_outlined),
      ),
      onTap: () {
        setState(() {
          _destination = null;
          _destinationTitle = null;
          _destinationController.clear();
          _showOriginMarkers = false;
          _showDestinationMarkers = true;
        });
      },
    );
  }

  bool get _canConfirm =>
      _origin != null && _destination != null && _origin != _destination;

  @override
  Widget build(BuildContext context) {
    SelectedSeatProvider selectedSeatProvider =
        Provider.of<SelectedSeatProvider>(context, listen: false);
    TerminalSeatsProvider terminalSeatsProvider =
        Provider.of<TerminalSeatsProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Seats ${selectedSeatProvider.selectedSeats.join(', ')}'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(10.298333, 123.893366),
              zoom: 16,
            ),
            markers: _markers,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                _buildOriginField(),
                const SizedBox(height: 8),
                _buildDestinationField(),
              ],
            ),
          ),
          if (_canConfirm)
            Positioned(
              left: 16,
              bottom: 16,
              child: ElevatedButton(
                onPressed: () {
                  selectedSeatProvider.setOriginAndDestination(
                      _origin!, _destination!);
                  terminalSeatsProvider.onOriginSelected(_originTitle, context);
                  terminalSeatsProvider.onDestinationSelected(
                      _destinationTitle!, context);
                  Navigator.of(context).pushNamed(BusPayScreen.routeName);
                },
                child: const Text('Proceed to Payment'),
              ),
            ),
        ],
      ),
    );
  }
}
