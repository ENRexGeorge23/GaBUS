import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gabus_build/screens/book_from_screen.dart';
import 'package:gabus_build/screens/pay_now_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../bus/bus_providers/bus_provider.dart';
import '../providers/bus_stops_provider.dart';
import '../providers/origin_provider.dart';
import '../providers/selected_seat_provider.dart';
import '../screens/terminal_bus_list_screen.dart';
import '../providers/terminal_seats_provider.dart';

class MapPickerScreen extends StatefulWidget {
  static const routeName = 'map-picker-screen';

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late AnimationController _controller;
  int _start = 40;
  Timer? _secondTracker;
  int _secondsRemaining =
      40; // Set this to the total duration of your timer in seconds
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
  Timer? _transactionTimer;

  void _resetTimer() {
    _transactionTimer?.cancel();
    _controller.reset();
    _controller.forward();
    _transactionTimer = Timer(Duration(seconds: 40), _onTransactionTimeout);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _start),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onTransactionTimeout();
      }
    });

    _secondTracker = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _secondTracker?.cancel();
      }
    });

    _resetTimer();

    WidgetsBinding.instance.addObserver(this);
    _initMarkers();
    Future.microtask(() {
      _setOriginFromRoute();
    });

    _controller.forward();
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
            title: Text('Reservation Failed'),
            content: Text(
                'You did not complete the transaction within the allotted time.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      BookFromScreen.routeName,
                      (Route<dynamic> route) => false);
                },
              ),
            ],
          );
        });
  }

  void _setOriginFromRoute() {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final originProvider = Provider.of<OriginProvider>(context, listen: false);

    setState(() {
      if (originProvider.origin != null) {
        _origin = originProvider.origin;
        _originTitle = originProvider.originTitle!;
        _originController.text = _originTitle;
        _isOriginFixed = true;
      } else {
        if (busProvider.selectedRoute == "CSBT to Bato (via Oslob)" ||
            busProvider.selectedRoute == "CSBT to Bato (via Barili)") {
          _origin = const LatLng(
            10.298333,
            123.893366,
          ); // South Bus Terminal LatLng
          _originTitle = "South Bus Terminal (Cebu)";
        } else if (busProvider.selectedRoute == "Bato to CSBT (via Oslob)" ||
            busProvider.selectedRoute == "Bato to CSBT (via Barili)") {
          _origin = const LatLng(
            9.454354021169785,
            123.30355890147524,
          );
          _originTitle = "Bato Bus Terminal (Santander)";
        }
        _originController.text = _originTitle;
        _isOriginFixed = true;
        originProvider.setOrigin(_origin!, _originTitle);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _transactionTimer?.cancel();
    _secondTracker?.cancel(); // Add this
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

    print('busStopsBarili: $busStopsBarili');

    setState(() {
      _markers.clear(); // Clear the markers first

      if (busProvider.selectedRoute == "CSBT to Bato (via Oslob)" ||
          busProvider.selectedRoute == "Bato to CSBT (via Oslob)") {
        _markers.addAll(
          busStops
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
                      MarkerId(busStop.id), busStop.position, busStop.title),
                ),
              )
              .toSet(),
        );
      } else if (busProvider.selectedRoute == "CSBT to Bato (via Barili)" ||
          busProvider.selectedRoute == "Bato to CSBT (via Barili)") {
        if (busStopsBarili.isNotEmpty) {
          _markers.addAll(
            busStopsBarili
                .map(
                  (busStopsBarili) => Marker(
                    markerId: MarkerId(busStopsBarili.id),
                    position: busStopsBarili.position,
                    infoWindow: InfoWindow(
                      title: busStopsBarili.title,
                      snippet: busStopsBarili.snippet,
                    ),
                    icon: markerIcon,
                    onTap: () => _showMarkerActions(MarkerId(busStopsBarili.id),
                        busStopsBarili.position, busStopsBarili.title),
                  ),
                )
                .toSet(),
          );
        }
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
            onCameraMove: (position) {
              _resetTimer();
            },
            onCameraIdle: () {
              _resetTimer();
            },
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
                  _transactionTimer?.cancel();
                  selectedSeatProvider.setOriginAndDestination(
                      _origin!, _destination!);
                  terminalSeatsProvider.onOriginSelected(_originTitle, context);
                  terminalSeatsProvider.onDestinationSelected(
                      _destinationTitle!, context);
                  Navigator.of(context)
                      .pushReplacementNamed(PayNowScreen.routeName);
                },
                child: const Text('Proceed to Payment'),
              ),
            ),
        ],
      ),
    );
  }
}
