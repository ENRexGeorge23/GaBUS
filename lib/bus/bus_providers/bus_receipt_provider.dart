import 'package:flutter/foundation.dart';

class BusReceipt {
  final String id;
  final DateTime date;
  final String origin;
  final String destination;
  final String fare;
  final List<String> seatNum;
  final String busNum;
  final String plateNum;
  final String terminal;
  final String travelDate;

  BusReceipt({
    required this.id,
    required this.date,
    required this.origin,
    required this.destination,
    required this.fare,
    required this.busNum,
    required this.seatNum,
    required this.plateNum,
    required this.travelDate,
    required this.terminal,
  });
}

class BusReceiptProvider with ChangeNotifier {
  BusReceipt? _busCurrentReceipt;

  BusReceipt? get busCurrentReceipt => _busCurrentReceipt;

  void createBusReceipt({
    required String id,
    required DateTime date,
    required String origin,
    required String destination,
    required String fare,
    required List<String> seatNum,
    required String busNum,
    required String plateNum,
    required String travelDate,
    required String terminal,
  }) {
    _busCurrentReceipt = BusReceipt(
      id: id,
      date: date,
      origin: origin,
      destination: destination,
      fare: fare,
      busNum: busNum,
      plateNum: plateNum,
      seatNum: seatNum,
      travelDate: travelDate,
      terminal: terminal,
    );
    notifyListeners();
  }
}
