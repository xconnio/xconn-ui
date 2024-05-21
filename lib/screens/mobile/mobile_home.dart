import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:xconn_ui/Providers/args_provider.dart";
import "package:xconn_ui/Providers/kwargs_provider.dart";
import "package:xconn_ui/constants.dart";
import "package:xconn_ui/utils/args_screen.dart";
import "package:xconn_ui/utils/kwargs_screen.dart";
import "package:xconn_ui/utils/tab_data_class.dart";

class MobileHomeScaffold extends StatefulWidget {
  const MobileHomeScaffold({super.key});

  @override
  State<MobileHomeScaffold> createState() => _MobileHomeScaffoldState();
}

class _MobileHomeScaffoldState extends State<MobileHomeScaffold> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabNames = ["Tab 1"];
  final List<String> _tabContents = ["Content for Tab 1"];
  final List<TabData> _tabData = [TabData()];
  final TextEditingController linkController = TextEditingController();
  final TextEditingController realmController = TextEditingController();
  final TextEditingController topicProcedureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabNames.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  // HANDLE TABS SELECTION
  void _handleTabSelection() {
    setState(() {});
  }

  void _addTab() {
    setState(() {
      int newIndex = _tabNames.length + 1;
      _tabNames.add("Tab $newIndex");
      _tabContents.add("Content for Tab $newIndex");
      _tabData.add(TabData());
      if (_tabController.length != _tabNames.length) {
        _tabController = TabController(length: _tabNames.length, vsync: this);
        _tabController.addListener(_handleTabSelection);
      }
    });
  }

  void _removeTab(int index) {
    setState(() {
      _tabNames.removeAt(index);
      _tabContents.removeAt(index);
      _tabData.removeAt(index);

      if (_tabController.length != _tabNames.length) {
        _tabController = TabController(length: _tabNames.length, vsync: this);
        _tabController.addListener(_handleTabSelection);
      }
    });
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabSelection)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "XConn",
          style: TextStyle(color: homeAppBarTextColor, fontSize: 15),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: _addTab,
              icon: const Icon(Icons.add_box_sharp),
            ),
          ),
        ],
        bottom: _tabNames.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: blueAccentColor,
                  indicatorWeight: 1,
                  tabs: _tabNames
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildTabWithDeleteButton(entry.key, entry.value),
                      )
                      .toList(),
                ),
              )
            : null,
      ),
      drawer: const Drawer(),
      body: _tabNames.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: _tabContents.asMap().entries.map((entry) => _buildTab(entry.key)).toList(),
              ),
            )
          : const Center(child: Text("No Tabs")),
    );
  }

  // Delete Tab
  Widget _buildTabWithDeleteButton(int index, String tabName) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tabName,
              style: TextStyle(
                color: isSelected ? blueAccentColor : blackColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: closeIconColor,
                size: iconSize,
              ),
              onPressed: () => _removeTab(index),
            ),
          ],
        ),
      ),
    );
  }

  // Main Build Tab
  Widget _buildTab(int index) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: DropdownButton<String>(
                      value: _tabData[index].selectedValue.isEmpty ? null : _tabData[index].selectedValue,
                      hint: Text(
                        "Actions",
                        style: TextStyle(color: dropDownTextColor),
                      ),
                      items: <String>[
                        "Register",
                        "Subscribe",
                        "Call",
                        "Publish",
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(color: dropDownTextColor),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _tabData[index].selectedValue = newValue!;
                          switch (newValue) {
                            case "Subscribe":
                              {
                                _tabData[index].sendButtonText = "Subscribe";
                                break;
                              }
                            case "Register":
                              {
                                _tabData[index].sendButtonText = "Register";
                                break;
                              }
                            case "Call":
                              {
                                _tabData[index].sendButtonText = "Call";
                                break;
                              }
                            case "Publish":
                              {
                                _tabData[index].sendButtonText = "Publish";
                                break;
                              }
                            default:
                              {
                                _tabData[index].sendButtonText = "Send";
                              }
                          }
                        });
                      },
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: linkController,
                      decoration: const InputDecoration(
                        hintText: "Enter URL or paste text",
                        labelText: "Enter URL or paste text",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _tabData[index].selectedSerializer.isEmpty ? null : _tabData[index].selectedSerializer,
                    hint: const Text("Serializers"),
                    items: <String>[
                      "JSON",
                      "CBOR",
                      "Msg Pack",
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _tabData[index].selectedSerializer = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextFormField(
                    controller: realmController,
                    decoration: InputDecoration(
                      hintText: "Enter realm here",
                      labelText: "Enter realm here",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          // Topic Procedure TextFormFields
          buildTopicProcedure(_tabData[index].sendButtonText),

          const SizedBox(
            height: 20,
          ),

          // Args
          buildArgs(_tabData[index].sendButtonText),

          const SizedBox(
            height: 20,
          ),

          // K-Wargs
          buildKwargs(_tabData[index].sendButtonText),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Result",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: blackColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 110),
            child: MaterialButton(
              onPressed: () {},
              color: Colors.blueAccent,
              minWidth: 200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _tabData[index].sendButtonText,
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  // Topic and Procedure TextFormFields Widget
  Widget buildTopicProcedure(String sendButtonText) {
    switch (sendButtonText) {
      case "Publish":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextFormField(
            controller: topicProcedureController,
            decoration: InputDecoration(
              hintText: "Enter topic here",
              labelText: "Enter topic here",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        );

      case "Call":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextFormField(
            controller: topicProcedureController,
            decoration: InputDecoration(
              hintText: "Enter procedure here",
              labelText: "Enter procedure here",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        );

      case "Register":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextFormField(
            controller: topicProcedureController,
            decoration: InputDecoration(
              hintText: "Enter procedure here",
              labelText: "Enter procedure here",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        );

      case "Subscribe":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextFormField(
            controller: topicProcedureController,
            decoration: InputDecoration(
              hintText: "Enter topic here",
              labelText: "Enter topic here",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        );

      default:
        return Container();
    }
  }

  // Build Args Widget
  Widget buildArgs(String argsSendButton) {
    switch (argsSendButton) {
      case "Publish":
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Args",
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
                          Provider.of<ArgsProvider>(
                            context,
                            listen: false,
                          ).addController();
                        },
                        icon: const Icon(
                          Icons.add_box_sharp,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const ArgsTextFormFields(),
          ],
        );

      case "Call":
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Args",
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
                          Provider.of<ArgsProvider>(
                            context,
                            listen: false,
                          ).addController();
                        },
                        icon: const Icon(
                          Icons.add_box_sharp,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const ArgsTextFormFields(),
          ],
        );

      default:
        return Container();
    }
  }

  // BUILD Kwargs Widget
  Widget buildKwargs(String kWargSendButton) {
    switch (kWargSendButton) {
      case "Publish":
        return Column(
          children: [
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
                        "Kwargs",
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
                      Provider.of<KwargsProvider>(
                        context,
                        listen: false,
                      ).addRow({
                        "key": "",
                        "value": "",
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
            const DynamicKeyValuePairs(),
          ],
        );

      case "Call":
        return Column(
          children: [
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
                        "Kwargs",
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
                      Provider.of<KwargsProvider>(
                        context,
                        listen: false,
                      ).addRow({
                        "key": "",
                        "value": "",
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
            const DynamicKeyValuePairs(),
          ],
        );

      default:
        return Container();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TextEditingController>("linkController", linkController))
      ..add(
        DiagnosticsProperty<TextEditingController>("realmController", realmController),
      )
      ..add(
        DiagnosticsProperty<TextEditingController>("topicProcedureController", topicProcedureController),
      );
  }
}
