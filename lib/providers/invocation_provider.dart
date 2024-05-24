import "package:flutter/cupertino.dart";

class InvocationProvider extends ChangeNotifier {
  final List<String> _results = [];

  List<String> get results => _results;

  void addResult(String result, int index) {
    if (!_results.contains(result)) {
      _results.add(result);
      notifyListeners();
    }
  }
}
