import "package:flutter/cupertino.dart";

class KwargsProvider extends ChangeNotifier {
  final List<MapEntry<String, String>> _tableData = [];

  List<MapEntry<String, String>> get tableData => _tableData;

  void addRow(String key, String value) {
    _tableData.add(MapEntry(key, value));
    notifyListeners();
  }

  void removeRow(int index) {
    _tableData.removeAt(index);
    notifyListeners();
  }
}
