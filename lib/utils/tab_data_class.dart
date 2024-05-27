import "package:flutter/cupertino.dart";

class TabData {
  TabData();
  String selectedValue = "";
  String selectedSerializer = "";
  String sendButtonText = "Send";
  TextEditingController linkController = TextEditingController();
  TextEditingController realmController = TextEditingController();
  TextEditingController topicProcedureController = TextEditingController();

  void disposeControllers() {
    linkController.dispose();
    realmController.dispose();
    topicProcedureController.dispose();
  }
}
