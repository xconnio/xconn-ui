import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wick_ui/providers/tab_provider.dart";
import "package:wick_ui/utils/build_main_tab.dart";
import "package:wick_ui/utils/custom_appbar.dart";

class DesktopHomeScaffold extends StatefulWidget {
  const DesktopHomeScaffold({super.key});

  @override
  State<DesktopHomeScaffold> createState() => _DesktopHomeScaffoldState();
}

class _DesktopHomeScaffoldState extends State<DesktopHomeScaffold> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TabControllerProvider>(
      builder: (context, tabControllerProvider, child) {
        return Scaffold(
          appBar: CustomAppBar(
            tabController: tabControllerProvider.tabController,
            tabNames: tabControllerProvider.tabNames,
            removeTab: tabControllerProvider.removeTab,
            addTab: tabControllerProvider.addTab,
          ),
          body: tabControllerProvider.tabNames.isNotEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    double horizontalPadding = screenWidth > 1300 ? (screenWidth - 800) / 2 : 20.0;

                    return Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Center(
                        child: AnimatedPadding(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800, minWidth: 300),
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: tabControllerProvider.tabController,
                              children: tabControllerProvider.tabContents
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => BuildMainTab(
                                      index: entry.key,
                                      tabControllerProvider: tabControllerProvider,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(child: Text("No Tabs")),
        );
      },
    );
  }
}
