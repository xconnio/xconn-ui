import "package:flutter/cupertino.dart";

class InvocationProvider extends ChangeNotifier {
  final List<String> _invocations = [];

  List<String> get invocations => _invocations;

  void addInvocation(String invocation, int index) {
    _invocations.add(invocation);
    notifyListeners();
  }
}
