import "package:flutter/cupertino.dart";

class KwargsProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _tableData = [
    {"key": "", "value": ""},
  ];

  List<Map<String, dynamic>> get tableData => _tableData;

  void addRow(Map<String, String> rowData) {
    // print("Hello");
    _tableData.add(rowData);
    // print("length ${_tableData.length}");
    notifyListeners();
  }

  void removeRow(int index) {
    // print("Kassssss");
    _tableData.removeAt(index);
    // print("lenggggggg ${_tableData.length}");
    notifyListeners();
  }
}
