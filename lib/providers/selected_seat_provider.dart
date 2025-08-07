import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectedSeatProvider with ChangeNotifier {
  List<String> _selectedSeats = [];
  LatLng? _origin;
  LatLng? _destination;

  List<String> get selectedSeats => _selectedSeats;
  LatLng? get origin => _origin;
  LatLng? get destination => _destination;

  ///Changes
  void updateSelectedSeats(List<String> newSelectedSeats) {
    _selectedSeats = newSelectedSeats;
    notifyListeners();
  }

  void addSelectedSeat(String seatTitle) {
    if (!_selectedSeats.contains(seatTitle)) {
      _selectedSeats.add(seatTitle);
      notifyListeners();
    }
  }

  void removeSelectedSeat(String seatTitle) {
    _selectedSeats.remove(seatTitle);
    notifyListeners();
  }

  void clearSelectedSeats() {
    _selectedSeats.clear();
    notifyListeners();
  }

  void setOriginAndDestination(LatLng origin, LatLng destination) {
    _origin = origin;
    _destination = destination;
    notifyListeners();
  }
}
