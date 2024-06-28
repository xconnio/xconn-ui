import "package:flutter/cupertino.dart";
import "package:xconn/xconn.dart";

class RouterStateProvider with ChangeNotifier {
  late Server _serverRouter;

  Server get serverRouter => _serverRouter;

  void setServerRouter(Server server) {
    _serverRouter = server;
    notifyListeners();
  }
}
