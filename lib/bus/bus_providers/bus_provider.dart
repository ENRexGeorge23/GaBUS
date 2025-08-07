import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Bus {
  final String busNumber;
  final String busPlateNumber;
  final int numberOfSeats;
  final String timeOne;
  final String timeTwo;
  final String routeOne;
  final String routeTwo;
  String currentBusDocId = '';
  String? currentBusStatus;

  Bus({
    required this.busNumber,
    required this.busPlateNumber,
    required this.numberOfSeats,
    required this.timeOne,
    required this.timeTwo,
    required this.routeOne,
    required this.routeTwo,
    this.currentBusStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'busNumber': busNumber,
      'busPlateNumber': busPlateNumber,
      'numberOfSeats': numberOfSeats,
      'timeOne': timeOne,
      'timeTwo': timeTwo,
      'routeOne': routeOne,
      'routeTwo': routeTwo,
    };
  }
}

class BusProvider extends ChangeNotifier {
  String _currentBusDocId = '';

  String get currentBusDocId => _currentBusDocId;

  set currentBusDocId(String value) {
    _currentBusDocId = value;
    notifyListeners();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _busRef =
      FirebaseDatabase.instance.ref().child('buses');

  final CollectionReference<Map<String, dynamic>> busesCollection =
      FirebaseFirestore.instance.collection('buses');
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedRoute;
  String? _currentBusStatus;

  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  String? get selectedRoute => _selectedRoute;
  String? get currentBusStatus => _currentBusStatus;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String _currentRoute = '';

  String get currentRoute => _currentRoute;

  // DateTime get dateTime => null;

  DateTime get dateTime {
    if (_selectedDate != null && _selectedTime != null) {
      return DateTime(_selectedDate!.year, _selectedDate!.month,
          _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
    }
    return DateTime.now(); // Return the current date and time as a fallback
  }

  set currentRoute(String newRoute) {
    _currentRoute = newRoute;
    notifyListeners();
  }

  BusProvider() {
    authProviderBus();
  }

  authProviderBus() {
    // Check if the user is already authenticated when the app starts up
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _isAuthenticated = user != null;
      if (_isAuthenticated) {
        // Fetch current bus data from Firestore for the authenticated user
        DocumentSnapshot<Map<String, dynamic>> busSnapshot =
            await busesCollection.doc(user!.uid).get();

        if (busSnapshot.exists) {
          Map<String, dynamic> busData = busSnapshot.data()!;
          _currentBus = Bus(
            busNumber: busData['busNumber'],
            busPlateNumber: busData['busPlateNumber'],
            numberOfSeats: busData['numberOfSeats'],
            timeOne: busData['timeOne'],
            timeTwo: busData['timeTwo'],
            routeOne: busData['routeOne'],
            routeTwo: busData['routeTwo'],
          );
        }
      } else {
        _currentBus = null;
      }
      notifyListeners();
    });
  }

  Bus? _currentBus;
  Bus? get currentBus => _currentBus;
  void setCurrentBus(Bus? bus) {
    _currentBus = bus;
    notifyListeners();
  }

  Future<void> addBus(Bus bus, String uid) async {
    await busesCollection.doc(uid).set(bus.toMap());
    notifyListeners();
  }

  Future<void> setCurrentBusByBusNumber(String busNumber) async {
    QuerySnapshot<Map<String, dynamic>> busSnapshot =
        await busesCollection.where('busNumber', isEqualTo: busNumber).get();

    if (busSnapshot.docs.isNotEmpty) {
      Map<String, dynamic> busData = busSnapshot.docs.first.data();
      _currentBus = Bus(
        busNumber: busData['busNumber'],
        busPlateNumber: busData['busPlateNumber'],
        numberOfSeats: busData['numberOfSeats'],
        timeOne: busData['timeOne'],
        timeTwo: busData['timeTwo'],
        routeOne: busData['routeOne'],
        routeTwo: busData['routeTwo'],
      );
      _currentBusDocId = busSnapshot.docs.first.id; // set the document ID here

      notifyListeners();
    }
  }

  set currentBusStatus(String? newStatus) {
    _currentBusStatus = newStatus;
    notifyListeners();
  }

  void setSelectedBusDetails(
      DateTime selectedDate, TimeOfDay selectedTime, String selectedRoute) {
    _selectedDate = selectedDate;
    _selectedTime = selectedTime;
    _selectedRoute = selectedRoute;
    notifyListeners();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
