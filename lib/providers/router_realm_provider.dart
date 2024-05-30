import "package:flutter/material.dart";

class RouterRealmProvider extends ChangeNotifier {
  final TextEditingController hostController = TextEditingController();
  final TextEditingController portController = TextEditingController();

  List<TextEditingController> realmControllers = [TextEditingController()];

  void addController() {
    realmControllers.add(TextEditingController());
    notifyListeners();
  }

  void removeController(int index) {
    realmControllers.removeAt(index);
    notifyListeners();
  }

  void resetControllers() {
    realmControllers = [TextEditingController()];
    hostController.clear();
    portController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final controller in realmControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
