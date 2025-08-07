import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gabus_build/bus/bus_providers/bus_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/selected_seat_provider.dart';
import '../providers/bus_stops_provider.dart';
import '../providers/user_provider.dart';
import '../bus/bus_providers/passenger_details_provider.dart';

class TerminalSeatsProvider with ChangeNotifier {
  BusStop? originBusStop;
  BusStop? destinationBusStop;
  String? fare;
  String? receiptId;
  DateTime? date;
  String? notDiscountedFare;
  bool _isOnBusPayScreen = false;

  late BusStopProvider busStopProvider;

  TerminalSeatsProvider({
    required this.busStopProvider,
  });

  void setIsOnBusPayScreen(bool value) {
    _isOnBusPayScreen = value;
    notifyListeners();
  }

  void onOriginSelected(String originTitle, BuildContext context) {
    BusProvider busProvider = Provider.of<BusProvider>(context, listen: false);
    if (busProvider.selectedRoute == "CSBT to Bato (via Oslob)" ||
        busProvider.selectedRoute == "Bato to CSBT (via Oslob)") {
      originBusStop = busStopProvider.getBusStopByTitle(originTitle);
    } else if (busProvider.selectedRoute == "CSBT to Bato (via Barili)" ||
        busProvider.selectedRoute == "Bato to CSBT (via Barili)") {
      originBusStop = busStopProvider.getBusStopBariliByTitle(originTitle);
    }
    if (destinationBusStop != null) {
      if (_isOnBusPayScreen) {
        calculateFare(context);
      } else {
        calculateFare(context);
        getDiscountedFare(context);
      }
    }
    notifyListeners();
  }

  void onDestinationSelected(String destinationTitle, BuildContext context) {
    BusProvider busProvider = Provider.of<BusProvider>(context, listen: false);
    if (busProvider.selectedRoute == "CSBT to Bato (via Oslob)" ||
        busProvider.selectedRoute == "Bato to CSBT (via Oslob)") {
      destinationBusStop = busStopProvider.getBusStopByTitle(destinationTitle);
    } else if (busProvider.selectedRoute == "CSBT to Bato (via Barili)" ||
        busProvider.selectedRoute == "Bato to CSBT (via Barili)") {
      destinationBusStop =
          busStopProvider.getBusStopBariliByTitle(destinationTitle);
    }
    if (destinationBusStop != null) {
      if (_isOnBusPayScreen) {
        calculateFare(context);
      } else {
        calculateFare(context);
        getDiscountedFare(context);
      }
    }
    notifyListeners();
  }

  void getDiscountedFare(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    double distanceInKm = calculateDistance(
        originBusStop!.position, destinationBusStop!.position);
    bool isVerified = userProvider.userData?['isVerified'] ?? false;
    double? _fare = double.parse(notDiscountedFare!);

    if (isVerified) {
      // Subtract the fare for one seat
      double fareForOneSeat = 35.0 + (distanceInKm * 2.5);
      _fare -= fareForOneSeat;

      // Apply discount to the fare for one seat and add it back to the total fare
      fareForOneSeat *= 0.80; // 20% discount
      _fare += fareForOneSeat;
    }
    _fare = _fare.roundToDouble(); // Round off the fare
    fare = _fare.toStringAsFixed(2); // Convert the rounded fare to a string
    notifyListeners();
  }

  void calculateFare(BuildContext context) {
    SelectedSeatProvider selectedSeatProvider =
        Provider.of<SelectedSeatProvider>(context, listen: false);
    PassengerDetailsProvider passengerDetails =
        Provider.of<PassengerDetailsProvider>(context, listen: false);
    double distanceInKm = calculateDistance(
        originBusStop!.position, destinationBusStop!.position);
    int _numOfSeats = selectedSeatProvider.selectedSeats.length;

    double? _fare = ((35.0 + (distanceInKm * 2.5)) * _numOfSeats);
    double baseFare = ((35.0 + (distanceInKm * 2.5)) * _numOfSeats);

    if (_isOnBusPayScreen) {
      if (passengerDetails.passengerTypeField == 'isStudent' &&
              passengerDetails.passengerTypeValue == true ||
          passengerDetails.passengerTypeField == 'isPWD' &&
              passengerDetails.passengerTypeValue == true ||
          passengerDetails.passengerTypeField == 'isSenior' &&
              passengerDetails.passengerTypeValue == true) {
        _fare = baseFare - (baseFare * .2);
      } else if (passengerDetails.passengerTypeField == 'isRegular' &&
          passengerDetails.passengerTypeValue == true) {
        _fare = baseFare;
      } else {
        _fare = baseFare;
      }
    }

    _fare = _fare.roundToDouble(); // Round off the fare
    notDiscountedFare =
        _fare.toStringAsFixed(2); // Save the total fare without any discount
    fare = _fare.toStringAsFixed(2); // Convert the rounded fare to a string
    notifyListeners();
  }

  double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371.0; // in km

    double lat1 = start.latitude * pi / 180.0;
    double lon1 = start.longitude * pi / 180.0;
    double lat2 = end.latitude * pi / 180.0;
    double lon2 = end.longitude * pi / 180.0;

    double dLon = lon2 - lon1;
    double dLat = lat2 - lat1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distanceInKm = earthRadius * c;

    return distanceInKm;
  }

  void generateRandomId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    String id = '';
    for (int i = 0; i < 10; i++) {
      id += chars[random.nextInt(chars.length)];
    }
    receiptId = id;
    notifyListeners();
  }

  DateTime getCurrentDateTime() {
    date = DateTime.now();
    notifyListeners();
    return date!;
  }

  void reset() {
    // set the properties to their initial values
    originBusStop = null;
    destinationBusStop = null;
    fare = null;
  }
}
