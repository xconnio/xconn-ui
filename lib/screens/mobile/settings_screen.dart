import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wick_ui/providers/theme_provider.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
              await showThemeDialog();
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

  Future<void> showThemeDialog() async {
    final themeProvider = context.read<MyThemeProvider>();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 120,
            width: double.infinity,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  onTap: () {
                    themeProvider.setThemeData(ThemeData.light());
                  },
                  leading: const Icon(
                    Icons.light_mode,
                    color: Colors.blueGrey,
                  ),
                  title: const Text(
                    "Light Mode",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                ListTile(
                  onTap: () {
                    themeProvider.setThemeData(ThemeData.dark());
                  },
                  leading: const Icon(
                    Icons.dark_mode,
                    color: Colors.blueGrey,
                  ),
                  title: const Text(
                    "Dark Mode",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
