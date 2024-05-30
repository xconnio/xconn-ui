import "dart:async";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:xconn_ui/constants.dart";
import "package:xconn_ui/providers/router_realm_provider.dart";
import "package:xconn_ui/providers/router_state_provider.dart";
import "package:xconn_ui/providers/router_toggleswitch_provider.dart";
import "package:xconn_ui/screens/mobile/mobile_home.dart";
import "package:xconn_ui/wamp_util.dart";

class RouterDialogBox extends StatefulWidget {
  const RouterDialogBox({super.key});

  @override
  State<RouterDialogBox> createState() => _RouterDialogBoxState();
}

class _RouterDialogBoxState extends State<RouterDialogBox> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var realmProvider = Provider.of<RouterRealmProvider>(context, listen: false);
    var routerProvider = Provider.of<RouterStateProvider>(context, listen: false);
    var switchProvider = Provider.of<RouterToggleSwitchProvider>(context, listen: false);
    return AlertDialog(
      scrollable: true,
      title: Text(
        "Router Connection",
        style: TextStyle(fontWeight: FontWeight.w700, color: homeAppBarTextColor, fontSize: iconSize),
      ),
      content: Form(
        key: _formKey,
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              cursorColor: blueAccentColor,
              controller: realmProvider.hostController,
              decoration: InputDecoration(
                labelText: "Enter host url here",
                labelStyle: TextStyle(color: blackColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: blackColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter host url";
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.number,
              cursorColor: blueAccentColor,
              controller: realmProvider.portController,
              decoration: InputDecoration(
                labelText: "Enter port here",
                labelStyle: TextStyle(color: blackColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: blackColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter port";
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Realms",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        realmProvider.addController();
                      });
                    },
                    icon: const Icon(
                      Icons.add_box_sharp,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                itemCount: realmProvider.realmControllers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: TextFormField(
                      cursorColor: blueAccentColor,
                      controller: realmProvider.realmControllers[index],
                      decoration: InputDecoration(
                        labelText: "Enter realm here",
                        labelStyle: TextStyle(color: blackColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: blackColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter realm here";
                        }
                        return null;
                      },
                    ),
                    trailing: InkWell(
                      hoverColor: Colors.blue.shade200,
                      onTap: () {
                        setState(() {
                          realmProvider.removeController(index);
                        });
                      },
                      child: Icon(
                        Icons.delete,
                        color: closeIconColor,
                      ),
                    ),
                  );
                },
              ),
            ),

            // InkWell(
            //   onTap: () async {
            //     final scaffoldMessenger = ScaffoldMessenger.of(context);
            //     if (_formKey.currentState!.validate()) {
            //       List<String> realms = realmProvider.realmControllers.map((controller) => controller.text).toList();
            //       String host = realmProvider.portController.text.trim();
            //       int? port;
            //       Navigator.of(context).pop();
            //       try {
            //         port = int.parse(host.trim());
            //         print("realm $realms");
            //         print("host ${realmProvider.hostController.text}");
            //         print("port $port");
            //         await startRouter(
            //           realmProvider.hostController.text, port, realms,);
            //
            //           Navigator.of(context).pop();
            //           await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MobileHomeScaffold()));
            //         Future.delayed(const Duration(seconds: 2), (){
            //           Fluttertoast.showToast(
            //             msg: "Server is running on this host: ${realmProvider.hostController.text} and on this port $port",
            //             toastLength: Toast.LENGTH_SHORT,
            //             gravity: ToastGravity.BOTTOM,
            //             timeInSecForIosWeb: 1,
            //             backgroundColor: Colors.green,
            //             textColor: Colors.white,
            //             fontSize: 16,
            //           );
            //
            //         });
            //
            //
            //       } on Exception catch (e) {
            //         scaffoldMessenger.showSnackBar(
            //           SnackBar(
            //             content: Text("Error is: $e"),
            //             duration: const Duration(seconds: 3),
            //           ),
            //         );
            //         print(e);
            //       }
            //
            //     }
            //   },
            //   child: Container(
            //     height: 35,
            //     width: MediaQuery.of(context).size.width,
            //     alignment: Alignment.center,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(5),
            //       gradient: LinearGradient(
            //         colors: [
            //           blueAccentColor,
            //           Colors.lightBlue,
            //         ],
            //       ),
            //     ),
            //     child: Text(
            //       "Start",
            //       style: TextStyle(color: whiteColor, fontSize: 18, fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MobileHomeScaffold()),
                    );
                  },
                  child: Container(
                    height: 35,
                    width: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: closeIconColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(color: blackColor, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    if (_formKey.currentState!.validate()) {
                      switchProvider.setServerStarted(started: true);
                      List<String> realms =
                          realmProvider.realmControllers.map((controller) => controller.text).toList();
                      String host = realmProvider.portController.text.trim();
                      int port;
                      try {
                        port = int.parse(host.trim());
                        var router = startRouter(
                          realmProvider.hostController.text,
                          port,
                          realms,
                        );
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              "Server is running on this host localhost: ${realmProvider.hostController.text}   and on this port $port",
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        routerProvider.setServerRouter(router);
                        unawaited(router.start(realmProvider.hostController.text, port));
                        realmProvider.resetControllers();
                        await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MobileHomeScaffold()),
                        );
                      } on Exception catch (e) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text("Error is: $e"),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    height: 35,
                    width: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        colors: [
                          blueAccentColor,
                          Colors.lightBlue,
                        ],
                      ),
                    ),
                    child: Text(
                      "Start",
                      style: TextStyle(color: whiteColor, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
