import "package:flutter/material.dart";
import "package:theme_provider/theme_provider.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.blueGrey,
          ),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            onTap: () async {
              await showDialog(context: context, builder: (_) => ThemeDialog());
            },
            leading: const Icon(
              Icons.sunny_snowing,
              color: Colors.blueGrey,
            ),
            title: const Text(
              "Select Theme",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
