import "package:shared_preferences/shared_preferences.dart";

class SharedPref {
  SharedPref._privateConstructor();

  late SharedPreferences _preferences;

  static final SharedPref _instance = SharedPref._privateConstructor();

  static SharedPref get instance => _instance;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  SharedPreferences get preferences => _preferences;
}
