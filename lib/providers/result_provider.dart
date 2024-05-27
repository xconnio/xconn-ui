import "package:flutter/material.dart";

class ResultProvider with ChangeNotifier {
  final List<String> _results = [];
  List<String> get results => _results;

  void addResult(String result, int index) {
    results.add(result);
    notifyListeners();
  }
}
