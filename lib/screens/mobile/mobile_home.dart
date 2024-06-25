import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wick_ui/providers/tab_provider.dart";
import "package:wick_ui/utils/build_main_tab.dart";
import "package:wick_ui/utils/custom_appbar.dart";

class MobileHomeScaffold extends StatefulWidget {
  const MobileHomeScaffold({super.key});

  @override
  State<MobileHomeScaffold> createState() => _MobileHomeScaffoldState();
}

class _MobileHomeScaffoldState extends State<MobileHomeScaffold> with TickerProviderStateMixin {
  final formkey = GlobalKey<FormState>();

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
              ? Form(
                  key: formkey,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
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
                              formKey: formkey,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
              : Container(),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GlobalKey<FormState>>("formkey", formkey));
  }
}
