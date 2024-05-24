import "package:flutter/cupertino.dart";
import "package:xconn/exports.dart";

class TabData {
  TabData() {
    linkController.addListener(_linkControllerListener);
    realmController.addListener(_realmControllerListener);
    topicProcedureController.addListener(_topicProcedureControllerListener);
  }
  String selectedValue = "";
  String selectedSerializer = "";
  String sendButtonText = "Send";
  TextEditingController linkController = TextEditingController();
  TextEditingController realmController = TextEditingController();
  TextEditingController topicProcedureController = TextEditingController();
  Future<Registration>? registration;

  void disposeControllers() {
    linkController.dispose();
    realmController.dispose();
    topicProcedureController.dispose();
  }

  void _linkControllerListener() {}

  void _realmControllerListener() {}

  void _topicProcedureControllerListener() {}
}
