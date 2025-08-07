//new
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gabus_build/bus/bus_providers/bus_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BusLocationScreen extends StatefulWidget {
  static const routeName = '/bus-location';

  static Route route() {
    return MaterialPageRoute(
      builder: (BuildContext context) => BusLocationScreen(),
    );
  }

  @override
  _BusLocationScreenState createState() => _BusLocationScreenState();
}

class _BusLocationScreenState extends State<BusLocationScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng _busLocation = const LatLng(10.298333, 123.893366);
  StreamSubscription<Position>? _positionStreamSubscription;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _subscribeToLocationUpdates();
  }

  Future<void> _requestLocationPermission() async {
    await Permission.location.request();
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

    final BusProvider busProvider =
        Provider.of<BusProvider>(context, listen: false);
    final bus = busProvider.currentBus;
    _positionStreamSubscription = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best, // Request best accuracy
      distanceFilter: 5, // Update every 5 meters
      intervalDuration: const Duration(seconds: 1), // Update every 1 second
    ).listen((Position position) async {
      final busIcon = await busMarker();
      if (mounted) {
        setState(() {
          _busLocation = LatLng(position.latitude, position.longitude);
          _markers.clear(); // Clear previous markers
          _markers.add(
            Marker(
              markerId: MarkerId(bus?.busNumber ?? 'bus'),
              position: _busLocation,
              icon: busIcon, // Use custom bus marker icon
              infoWindow: InfoWindow(title: bus?.busPlateNumber ?? 'Bus'),
            ),
          );
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _busLocation, zoom: 20),
            ),
          );
          // Update the bus location and plate number in Firebase
          if (bus != null) {
            _database.child('busLocation').child(bus.busNumber).set({
              'location': {
                'latitude': _busLocation.latitude,
                'longitude': _busLocation.longitude,
              },
              'plate_number': bus.busPlateNumber,
            }).catchError((error) {
              print('Error updating bus location in Firebase: $error');
            });
          }
        });
      }
    });
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
      appBar: AppBar(title: const Text('Bus Current Location')),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _busLocation,
          zoom: 20,
        ),
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _busLocation, zoom: 15),
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
