import 'package:flutter/foundation.dart';

class SeatSelectionProvider extends ChangeNotifier {
  List<String> _selectedSeats = [];

  List<String> get selectedSeats => _selectedSeats;

  void addSeat(String seatKey) {
    _selectedSeats.add(seatKey);
    notifyListeners();
  }

  void removeSeat(String seatKey) {
    _selectedSeats.remove(seatKey);
    notifyListeners();
  }

  void clearSeats() {
    _selectedSeats.clear();
    notifyListeners();
  }
}
