import 'package:flutter/foundation.dart';

class PassengerDetailsProvider with ChangeNotifier {
  String _documentId = '';
  String _passengerTypeField = '';
  String _contactNum = '';
  bool _passengerTypeValue = false;

  void setPassengerDetails({
    required String documentId,
    required String passengerTypeField,
    required String contactNum,
    required bool passengerTypeValue,
  }) {
    _documentId = documentId;
    _passengerTypeField = passengerTypeField;
    _passengerTypeValue = passengerTypeValue;
    _contactNum = contactNum;
    notifyListeners();
  }

  String get documentId => _documentId;
  String get contactNum => _contactNum;
  String get passengerTypeField => _passengerTypeField;
  bool get passengerTypeValue => _passengerTypeValue;
}
