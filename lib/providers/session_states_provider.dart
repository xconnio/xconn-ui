import "package:flutter/cupertino.dart";
import "package:xconn/xconn.dart";

class SessionStateProvider with ChangeNotifier {
  Session? _sessionUnRegister;
  Session? _sessionUnSubscribe;
  Object? _unregister;
  Object? _unSubscribe;

  Session? get sessionUnRegister => _sessionUnRegister;

  Session? get sessionUnSubscribe => _sessionUnSubscribe;

  Object? get unregister => _unregister;

  Object? get subscription => _unSubscribe;

  void setSessionUnRegister(Session? session) {
    _sessionUnRegister = session;
    notifyListeners();
  }

  void setSessionUnSubscribe(Session? session) {
    _sessionUnSubscribe = session;
    notifyListeners();
  }

  void setUnregister(Object? unregister) {
    _unregister = unregister;
    notifyListeners();
  }

  void setUnSubscribe(Object? unsubscribe) {
    _unSubscribe = unsubscribe;
    notifyListeners();
  }
}
