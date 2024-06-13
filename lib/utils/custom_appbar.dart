import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wick_ui/constants.dart";
import "package:wick_ui/providers/router_state_provider.dart";
import "package:wick_ui/providers/router_toggleswitch_provider.dart";
import "package:wick_ui/screens/mobile/router_dialogbox.dart";
import "package:wick_ui/screens/mobile/settings_screen.dart";

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.tabNames,
    required this.tabController,
    required this.addTab,
    required this.removeTab,
    super.key,
  });

  final List<String> tabNames;
  final TabController tabController;
  final Function() addTab;
  final Function(int index) removeTab;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<String>("tabNames", tabNames))
      ..add(DiagnosticsProperty<TabController>("tabController", tabController))
      ..add(ObjectFlagProperty<Function()>.has("addTab", addTab))
      ..add(ObjectFlagProperty<Function(int index)>.has("removeTab", removeTab));
  }
}

class _CustomAppBarState extends State<CustomAppBar> {
  Future<void> _showRouterDialog(
    BuildContext context,
    RouterToggleSwitchProvider routerResult,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const RouterDialogBox();
        },
      );
    } on Exception catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("An error occurred. Please try again. $e")));
    }

    if (routerResult.isServerStarted) {
      routerResult.toggleSwitch(value: true);
    }
  }

  Future<void> _showCloseRouterDialog(
    BuildContext context,
    RouterStateProvider routerProvider,
    RouterToggleSwitchProvider routerResult,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Router Connection",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: iconSize,
              ),
            ),
            content: InkWell(
              onTap: () {
                routerProvider.serverRouter.close();
                routerResult.setServerStarted(started: false);
                Navigator.of(context).pop();
              },
              child: Container(
                height: 35,
                width: MediaQuery.of(context).size.width,
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
                child: const Text(
                  "Close",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      );
      routerResult.toggleSwitch(value: false);
    } on Exception catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text("An error occurred. Please try again. $e")));
    }
  }

  Widget _buildTabWithDeleteButton(int index, String tabName) {
    final isSelected = widget.tabController.index == index;

    return GestureDetector(
      onTap: () {
        widget.tabController.animateTo(index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tabName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: closeIconColor,
                size: iconSize,
              ),
              onPressed: () => widget.removeTab(index),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPopupMenu(BuildContext context) async {
    await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(90, 90, 20, 0),
      items: [
        PopupMenuItem(
          value: "Settings",
          child: ListTile(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
            leading: const Icon(
              Icons.settings,
            ),
            title: const Text(
              "Settings",
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var routerProvider = Provider.of<RouterStateProvider>(context, listen: false);
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return AppBar(
      title: isMobile
          ? const Text(
              "Wick",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          : const SizedBox(),
      actions: [
        if (!kIsWeb)
          Consumer<RouterToggleSwitchProvider>(
            builder: (context, routerResult, _) {
              var scaffoldMessenger = ScaffoldMessenger.of(context);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: horizontalPadding),
                child: Row(
                  children: [
                    const Text(
                      "Router",
                      style: TextStyle(fontSize: iconSize),
                    ),
                    const SizedBox(width: 5),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        activeColor: blueAccentColor,
                        value: routerResult.isSelected,
                        onChanged: (value) async {
                          try {
                            if (value) {
                              await _showRouterDialog(context, routerResult, scaffoldMessenger);
                            } else {
                              await _showCloseRouterDialog(context, routerProvider, routerResult, scaffoldMessenger);
                            }
                          } on Exception catch (e) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(content: Text("An error occurred: ${e.runtimeType} - $e. Please try again.")),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        if (widget.tabNames.isEmpty)
          IconButton(
            onPressed: widget.addTab,
            icon: const Icon(
              Icons.add_circle,
              size: 25,
            ),
          )
        else
          const SizedBox(),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: () async {
              await _showPopupMenu(context);
            },
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ),
      ],
      bottom: widget.tabNames.isNotEmpty
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: widget.tabController,
                        isScrollable: true,
                        indicatorWeight: 1,
                        tabs: widget.tabNames
                            .asMap()
                            .entries
                            .map((entry) => _buildTabWithDeleteButton(entry.key, entry.value))
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        onPressed: widget.addTab,
                        icon: const Icon(
                          Icons.add_circle,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
