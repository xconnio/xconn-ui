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
    final realmProvider = context.read<RouterRealmProvider>();
    final routerProvider = context.read<RouterStateProvider>();
    final switchProvider = context.read<RouterToggleSwitchProvider>();
    return AlertDialog(
      scrollable: true,
      title: Text(
        "Router Connection",
        style: TextStyle(fontWeight: FontWeight.w700, color: homeAppBarTextColor, fontSize: iconSize),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextFormField(
              controller: realmProvider.hostController,
              labelText: "Enter host here",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter host here";
                }
                return "";
              },
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 10),
            _buildTextFormField(
              controller: realmProvider.portController,
              labelText: "Enter port here",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter port here";
                }
                return "";
              },
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _buildRealmsSection(realmProvider),
            _buildRealmsList(realmProvider),
            _buildActionButtons(context, realmProvider, routerProvider, switchProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      cursorColor: blueAccentColor,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
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
      validator: validator,
    );
  }

  Widget _buildRealmsSection(RouterRealmProvider realmProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
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
              setState(realmProvider.addController);
            },
            icon: const Icon(Icons.add_box_sharp, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildRealmsList(RouterRealmProvider realmProvider) {
    return SizedBox(
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
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    RouterRealmProvider realmProvider,
    RouterStateProvider routerProvider,
    RouterToggleSwitchProvider switchProvider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCloseButton(context),
        _buildStartButton(context, realmProvider, routerProvider, switchProvider),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return InkWell(
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
    );
  }

  Widget _buildStartButton(
    BuildContext context,
    RouterRealmProvider realmProvider,
    RouterStateProvider routerProvider,
    RouterToggleSwitchProvider switchProvider,
  ) {
    return InkWell(
      onTap: () async {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        if (_formKey.currentState!.validate()) {
          switchProvider.setServerStarted(started: true);
          final realms = realmProvider.realmControllers.map((controller) => controller.text).toList();
          final host = realmProvider.portController.text.trim();
          int port;
          try {
            port = int.parse(host);
            final router = startRouter(
              realmProvider.hostController.text,
              port,
              realms,
            );
            routerProvider.setServerRouter(router);
            unawaited(router.start(realmProvider.hostController.text, port));
            realmProvider.resetControllers();
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(
                  "Server is running on this host localhost: ${realmProvider.hostController.text} and on this port $port",
                ),
                duration: const Duration(seconds: 3),
              ),
            );
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
          gradient: const LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.lightBlue,
            ],
          ),
        ),
        child: Text(
          "Start",
          style: TextStyle(color: whiteColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
