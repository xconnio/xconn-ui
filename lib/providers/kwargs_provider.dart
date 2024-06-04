import "package:flutter/cupertino.dart";

class KwargsProvider extends ChangeNotifier {
  final List<MapEntry<String, dynamic>> _tableData = [
    const MapEntry("", ""),
  ];

  List<MapEntry<String, dynamic>> get tableData => _tableData;

  void addRow(MapEntry<String, String> rowData) {
    _tableData.add(rowData);
    notifyListeners();
  }

  void removeRow(int index) {
    _tableData.removeAt(index);
    notifyListeners();
  }
}
