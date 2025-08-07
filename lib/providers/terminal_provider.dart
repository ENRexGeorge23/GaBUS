import 'package:flutter/foundation.dart';

class OnTerminalProvider with ChangeNotifier {
  bool _isOnTerminal = false;

  bool get isOnTerminal => _isOnTerminal;

  void setOnTerminal(bool value) {
    _isOnTerminal = value;
    notifyListeners();
  }

  void reset() {
    _isOnTerminal = false;
    notifyListeners();
  }
}
