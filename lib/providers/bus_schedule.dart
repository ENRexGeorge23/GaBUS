import 'package:flutter/material.dart';

class Trip {
  final String name;
  final String firstTripTime;
  final String lastTripTime;
  final String interval;

  Trip({
    required this.name,
    required this.firstTripTime,
    required this.lastTripTime,
    required this.interval,
  });
}

class ScheduleProvider extends ChangeNotifier {
  final List<Trip> _trips = [
    Trip(
      name: 'CSBT TO BATO VIA OSLOB',
      firstTripTime: '3:00 AM',
      lastTripTime: '7:00 PM',
      interval: '30 minutes',
    ),
    Trip(
      name: 'CSBT TO BATO VIA BARILI',
      firstTripTime: '3:00 AM',
      lastTripTime: '6:30 PM',
      interval: '30 minutes',
    ),
    Trip(
      name: 'CSBT TO MOALBOAL',
      firstTripTime: '6:00 AM',
      lastTripTime: '2:00 PM',
      interval: '3 hours',
    ),
    Trip(
      name: 'CSBT TO ARGAO',
      firstTripTime: '4:00 AM',
      lastTripTime: '6:30 PM',
      interval: '30 minutes',
    ),
    Trip(
      name: 'CSBT TO ALCOY',
      firstTripTime: '4:00 AM',
      lastTripTime: '4:00 PM',
      interval: '1 hour',
    ),
    Trip(
      name: 'BATO VIA OSLOB TO CSBT',
      firstTripTime: '2:30 AM',
      lastTripTime: '10:30 PM',
      interval: '30 minutes',
    ),
    Trip(
      name: 'BATO VIA BARILI TO CSBT',
      firstTripTime: '2:30 AM',
      lastTripTime: '10:30 PM',
      interval: '30 minutes',
    ),
    Trip(
      name: 'MOALBOAL TO CSBT',
      firstTripTime: '3:00 AM',
      lastTripTime: '2:00 PM',
      interval: '3 hours',
    ),
    Trip(
      name: 'ARGAO TO CSBT',
      firstTripTime: '4:00 AM',
      lastTripTime: '2:00 PM',
      interval: '3 hours',
    ),
    Trip(
      name: 'ALCOY TO CSBT',
      firstTripTime: '4:00 AM',
      lastTripTime: '4:00 PM',
      interval: '1 hour',
    ),

    // add more trips as needed
  ];

  List<Trip> get trips => _trips;

  // add methods to update the schedule as needed
}
