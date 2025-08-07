import 'package:flutter/foundation.dart';

class OnRoadProvider with ChangeNotifier {
  bool _isOnRoad = false;

  bool get isOnRoad => _isOnRoad;

  void setOnRoad(bool value) {
    _isOnRoad = value;
    notifyListeners();
  }

  void reset() {
    _isOnRoad = false;
    notifyListeners();
  }
}
