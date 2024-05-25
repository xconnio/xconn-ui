import "package:flutter/cupertino.dart";

class InvocationProvider extends ChangeNotifier {
  final List<String> _invocations = [];

  List<String> get invocations => _invocations;

  void addInvocation(String result, int index) {
    _invocations.add(result);
    notifyListeners();
  }
}
