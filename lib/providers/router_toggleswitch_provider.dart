import "package:flutter/foundation.dart";

class RouterToggleSwitchProvider with ChangeNotifier {
  bool _isSelected = false;
  bool _isServerStarted = false;

  bool get isSelected => _isSelected;

  bool get isServerStarted => _isServerStarted;

  void toggleSwitch({required bool value}) {
    _isSelected = value;
    notifyListeners();
  }

  void setServerStarted({required bool started}) {
    _isServerStarted = started;
    notifyListeners();
  }
}
