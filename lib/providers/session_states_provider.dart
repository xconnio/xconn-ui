import "package:flutter/cupertino.dart";
import "package:xconn/exports.dart";

class SessionStateProvider with ChangeNotifier {
  Session? _session;
  Object? _unregister;
  Object? _unSubscribe;

  Session? get session => _session;
  Object? get unregister => _unregister;
  Object? get subscription => _unSubscribe;

  void setSession(Session? session) {
    _session = session;
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
