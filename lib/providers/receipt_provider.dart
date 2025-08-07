import 'package:flutter/foundation.dart';

class Receipt {
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

  Receipt({
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

class ReceiptProvider with ChangeNotifier {
  Receipt? _currentReceipt;

  Receipt? get currentReceipt => _currentReceipt;

  void createReceipt({
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
    _currentReceipt = Receipt(
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

class ReceiptsProvider with ChangeNotifier {
  Receipt? _currentReceipt;

  Receipt? get currentReceipt => _currentReceipt;

  set currentReceipt(Receipt? receipt) {
    _currentReceipt = receipt;
    notifyListeners();
  }
}
