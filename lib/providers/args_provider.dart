import "package:flutter/material.dart";

class ArgsProvider extends ChangeNotifier {
  List<TextEditingController> controllers = [TextEditingController()];

  void addController() {
    controllers.add(TextEditingController());
    notifyListeners();
  }

  void removeController(int index) {
    controllers.removeAt(index);
    notifyListeners();
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
