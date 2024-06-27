import "package:flutter/material.dart";

import "package:wick_ui/utils/shared_pref.dart";

class MyThemeProvider extends ChangeNotifier {
  MyThemeProvider() {
    _loadThemeData();
  }

  static const String _themePreferenceKey = "themePreference";

  ThemeData _themeData = ThemeData.dark();

  ThemeData get themeData => _themeData;

  Future<void> setThemeData(ThemeData themeData) async {
    _themeData = themeData;
    await SharedPref.instance.preferences.setBool(_themePreferenceKey, themeData == ThemeData.light());
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeData == ThemeData.light()) {
      await setThemeData(ThemeData.dark());
    } else {
      await setThemeData(ThemeData.light());
    }
  }

  dynamic _loadThemeData() async {
    bool? isLightTheme = SharedPref.instance.preferences.getBool(_themePreferenceKey);
    _themeData = isLightTheme != null && isLightTheme ? ThemeData.light() : ThemeData.dark();
    notifyListeners();
  }
}
