import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gabus_build/screens/seat_ui_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../bus/bus_providers/bus_provider.dart';

// Add this extension to support the toDateTime method for TimeOfDay
extension TimeOfDayExtension on TimeOfDay {
  DateTime toDateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

class UserLocationScreen extends StatefulWidget {
  static const routeName = '/user-location';
  @override
  _UserLocationScreenState createState() => _UserLocationScreenState();
}

class _UserLocationScreenState extends State<UserLocationScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Marker> _busMarkers = {};
  LatLng _userLocation = const LatLng(10.298333, 123.893366);
  StreamSubscription<Position>? _positionStreamSubscription;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _subscribeToLocationUpdates();
    _subscribeToBusLocationUpdates();
  }

  Future<void> _requestLocationPermission() async {
    await Permission.location.request();
  }

  void _subscribeToBusLocationUpdates() {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    final busLocationRef = database.child('busLocation');

    busLocationRef.onValue.listen((DatabaseEvent event) async {
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic> buses = dataSnapshot.value as Map<dynamic, dynamic>;

      if (buses != null) {
        buses.forEach((busNumber, busData) async {
          LatLng busLocation = LatLng(busData['location']['latitude'],
              busData['location']['longitude']);
          String busPlateNumber = busData['plate_number'];

          // Fetch the bus status from Firestore
          DocumentSnapshot busStatusSnapshot = await FirebaseFirestore.instance
              .collection('busStatuses')
              .doc(busNumber)
              .get();
          String status = busStatusSnapshot['status'];
          String route = busStatusSnapshot['route'];

          final busIcon = await busMarker();

          if (status == 'CSBT road' || status == 'Bato road') {
            _busMarkers.add(
              Marker(
                  markerId: MarkerId(busNumber),
                  position: busLocation,
                  icon: busIcon,
                  infoWindow: InfoWindow(
                    title: busPlateNumber,
                    snippet: route,
                  ),
                  onTap: () {
                    onMarkerTapped(busNumber);
                  }),
            );
          } else if (status == 'loggedOff') {
            _busMarkers
                .removeWhere((marker) => marker.markerId.value == busNumber);
          }

          if (mounted) {
            setState(() {
              _markers.addAll(_busMarkers);
            });
          }
        });
      }
    });
  }

  TimeOfDay parseTimeString(String timeString) {
    try {
      final timeFormat = DateFormat('HH:mm');
      final dateTime = timeFormat.parse(timeString);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      // Fallback to default time (00:00) if the time string cannot be parsed
      return TimeOfDay(hour: 0, minute: 0);
    }
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

  void onMarkerTapped(String busNumber) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a new BuildContext variable for the AlertDialog
        return AlertDialog(
          title: const Text('Book a Seat'),
          content: const Text('Do you want to book a seat on this bus?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () async {
                DateTime currentDate = DateTime.now(); // Get the current date

                // Fetch the current bus details
                await Provider.of<BusProvider>(dialogContext, listen: false)
                    .setCurrentBusByBusNumber(busNumber);

                // Get the current bus instance from the provider
                Bus? currentBus =
                    Provider.of<BusProvider>(dialogContext, listen: false)
                        .currentBus;
                String providerCurrentRoute =
                    Provider.of<BusProvider>(dialogContext, listen: false)
                        .currentRoute;

                // Define the current route
                String currentRoute;

                await FirebaseFirestore.instance
                    .collection('busStatuses')
                    .doc(currentBus?.busNumber)
                    .get()
                    .then((DocumentSnapshot doc) {
                  if (doc.exists) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    currentRoute = data['route'];
                    TimeOfDay currentTime = parseTimeString(
                        data['time']); // currentTime defined here as TimeOfDay
                    String currentStringTime = data['time'];

                    print("Current Route: $currentRoute");
                    print("Current Time: $currentTime");

                    _initializeSeats(
                      busNumber, // Pass busNumber as an argument
                      DateFormat('yyyy-MM-dd').format(currentDate),
                      currentStringTime,
                    );

                    // Pass the current date, time, and route to the BusProvider
                    Provider.of<BusProvider>(dialogContext, listen: false)
                        .setSelectedBusDetails(
                            currentDate, currentTime, currentRoute);

                    Navigator.of(dialogContext).pop(); // Close the AlertDialog
                    Navigator.pushNamed(context, SeatUiScreen.routename);
                  }
                });
              },
            )
          ],
        );
      },
    );
  }

  void _subscribeToLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return;
    }
    final userIcon = await userMarker();
    _positionStreamSubscription = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best, // Request best accuracy
      distanceFilter: 5, // Update every 5 meters
      intervalDuration: const Duration(seconds: 1), // Update every 1 second
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          Marker userMarker = Marker(
            markerId: MarkerId(user?.displayName ?? 'User'),
            position: _userLocation,
            icon: userIcon,
            infoWindow: InfoWindow(
              title: user?.displayName ?? 'User',
            ),
          );
          _markers
            ..clear()
            ..add(userMarker)
            ..addAll(_busMarkers);
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _userLocation,
                zoom: 15,
              ),
            ),
          );
        });
      }
    });
  }

  Future<BitmapDescriptor> userMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/user_marker.png',
    );
  }

  Future<BitmapDescriptor> busMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/bus_location_marker.png',
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bus on the Road')),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _userLocation,
          zoom: 20,
        ),
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _userLocation,
              zoom: 15,
            ),
          ),
        ),
        child: const Icon(
          Icons.center_focus_strong,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
