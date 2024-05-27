import "package:flutter/material.dart";

class EventProvider with ChangeNotifier {
  final List<String> _events = [];
  List<String> get events => _events;

  void addEvents(String event) {
    _events.add(event);
    notifyListeners();
  }
}
