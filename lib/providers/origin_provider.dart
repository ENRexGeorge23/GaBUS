import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OriginProvider with ChangeNotifier {
  LatLng? _origin;
  String? _originTitle;

  LatLng? get origin => _origin;
  String? get originTitle => _originTitle;

  void resetOrigin() {
    _origin = null;
    _originTitle = null;
    notifyListeners();
  }

  void setOrigin(LatLng origin, String originTitle) {
    _origin = origin;
    _originTitle = originTitle;
    notifyListeners();
  }

  void clearOrigin() {
    _origin = null;
    _originTitle = null;
    notifyListeners();
  }
}
