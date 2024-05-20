import "package:flutter/cupertino.dart";

class TableDataProvider extends ChangeNotifier {
  final List<Map<String, String>> _tableData = [
    {"key": "", "value": ""}
  ];

  List<Map<String, String>> get tableData => _tableData;

  void addRow(Map<String, String> rowData) {
    _tableData.add(rowData);
    notifyListeners();
  }

  void removeRow(int index) {
    _tableData.removeAt(index);
    notifyListeners();
  }
}
