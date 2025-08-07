import 'package:flutter/foundation.dart';

class CancellationProvider extends ChangeNotifier {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void processCancellation() {
    _isCancelled = !_isCancelled;
    notifyListeners();
  }
}
