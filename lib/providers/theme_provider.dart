import "package:flutter/material.dart";

class MyThemeProvider extends ChangeNotifier {
  ThemeData _themeData = ThemeData.dark();

  ThemeData get themeData => _themeData;

  void setThemeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}
