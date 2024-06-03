import "package:flutter/cupertino.dart";

class KwargsProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _tableData = [
    {"key": "", "value": ""},
  ];

  List<Map<String, dynamic>> get tableData => _tableData;

  void addRow(Map<String, String> rowData) {
    print("len ${_tableData.length}");
    _tableData.add(rowData);
    print("len1 ${_tableData.length}");
    notifyListeners();
  }

  void removeRow(int index) {
    _tableData.removeAt(index);
    notifyListeners();
  }
}
