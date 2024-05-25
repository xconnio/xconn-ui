import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:xconn/exports.dart";
import "package:xconn_ui/constants.dart";
import "package:xconn_ui/providers/args_provider.dart";
import "package:xconn_ui/providers/invocation_provider.dart";
import "package:xconn_ui/providers/kwargs_provider.dart";
import "package:xconn_ui/utils/args_screen.dart";
import "package:xconn_ui/utils/kwargs_screen.dart";
import "package:xconn_ui/utils/tab_data_class.dart";
import "package:xconn_ui/wamp_actions.dart";

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
  final List<ArgsProvider> _argsProviders = [];
  final List<KwargsProvider> _kwargsProviders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabNames.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _initializeProviders();
  }

  // HANDLE TABS SELECTION
  void _handleTabSelection() {
    setState(() {});
  }

  // INITIALIZE PROVIDERS
  void _initializeProviders() {
    for (final _ in _tabNames) {
      _argsProviders.add(ArgsProvider());
      _kwargsProviders.add(KwargsProvider());
    }
  }

  void _addTab() {
    setState(() {
      int newIndex = _tabNames.length;
      _tabNames.add("Tab ${newIndex + 1}");
      _tabContents.add("Content for Tab ${newIndex + 1}");
      _tabData.add(TabData());
      _argsProviders.add(ArgsProvider());
      _kwargsProviders.add(KwargsProvider());
      if (_tabController.length != _tabNames.length) {
        _tabController = TabController(length: _tabNames.length, vsync: this);
        _tabController.addListener(_handleTabSelection);
      }
      _tabController.index = newIndex;
    });
  }

  // REMOVE TABS
  void _removeTab(int index) {
    setState(() {
      _tabNames.removeAt(index);
      _tabContents.removeAt(index);
      _tabData[index].disposeControllers();
      _tabData.removeAt(index);
      _argsProviders.removeAt(index);
      _kwargsProviders.removeAt(index);

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
    for (final provider in _argsProviders) {
      provider.dispose();
    }
    for (final kProvider in _kwargsProviders) {
      kProvider.dispose();
    }
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

  // MAIN BUILD TAB
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
                      controller: _tabData[index].linkController,
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
                      jsonSerializer,
                      cborSerializer,
                      msgPackSerializer,
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
                    controller: _tabData[index].realmController,
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
          buildTopicProcedure(_tabData[index].topicProcedureController, _tabData[index].sendButtonText),

          const SizedBox(height: 20),

          // Args
          buildArgs(_tabData[index].sendButtonText, _argsProviders[index]),

          const SizedBox(height: 20),

          // K-Wargs
          buildKwargs(_tabData[index].sendButtonText, _kwargsProviders[index]),

          const SizedBox(height: 20),

          // Send Button
          sendButton(_tabData[index].sendButtonText, index),

          const SizedBox(height: 50),

          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: 30,
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

          Consumer<InvocationProvider>(
            builder: (context, registrationResult, _) {
              List<String> results = registrationResult.invocations;
              List<String> tabResults = results.where((result) => result.startsWith("$index:")).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tabResults.map((result) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          result,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: blackColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  // SEND BUTTON WIDGET
  Widget sendButton(String sendButton, int index, [Session? session, Object? unregister]) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    switch (sendButton) {
      case "Publish":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 110),
          child: MaterialButton(
            onPressed: () async {
              try {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                // Args
                List<String> argsData = _argsProviders[index].controllers.map((controller) => controller.text).toList();
                Map<String, dynamic> kWarValues = {};
                for (final map in _kwargsProviders[index].tableData) {
                  String key = map["key"];
                  dynamic value = map["value"];
                  kWarValues[key] = value;
                }
                Map<String, dynamic> formattedResult = kWarValues;
                var session = await connect(
                  _tabData[index].linkController.text,
                  _tabData[index].realmController.text,
                  _tabData[index].selectedSerializer,
                );
                await session.publish(
                  _tabData[index].topicProcedureController.text,
                  args: argsData,
                  kwargs: formattedResult,
                );
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text("Publish Successful"),
                    duration: Duration(seconds: 3),
                  ),
                );
                setState(() {
                  _tabData[index].linkController.clear();
                  _tabData[index].realmController.clear();
                  _tabData[index].topicProcedureController.clear();
                  _argsProviders[index].controllers.clear();
                  _kwargsProviders[index].tableData.clear();
                  _tabData[index].selectedSerializer = "";
                });
              } on Exception catch (error) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text("Publish Error: $error"),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            color: Colors.blueAccent,
            minWidth: 200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              sendButton,
              style: TextStyle(
                color: whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

      case "Subscribe":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 110),
          child: MaterialButton(
            onPressed: () async {
              await _subscribe(index);
            },
            color: Colors.blueAccent,
            minWidth: 200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              sendButton,
              style: TextStyle(
                color: whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

      case "UnSubscribe":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 110),
          child: MaterialButton(
            onPressed: () async {
              await _unSubscribe(index, session, unregister);
            },
            color: Colors.blueAccent,
            minWidth: 200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              sendButton,
              style: TextStyle(
                color: whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

      case "Call":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 110),
          child: MaterialButton(
            onPressed: () async {
              try {
                List<String> argsData = _argsProviders[index].controllers.map((controller) => controller.text).toList();
                Map<String, dynamic> kWarValues = {};
                for (final map in _kwargsProviders[index].tableData) {
                  String key = map["key"];
                  dynamic value = map["value"];
                  kWarValues[key] = value;
                }
                Map<String, dynamic> formattedResult = kWarValues;
                var session = await connect(
                  _tabData[index].linkController.text,
                  _tabData[index].realmController.text,
                  _tabData[index].selectedSerializer,
                );

                Future.delayed(const Duration(seconds: 1), () {
                  session.call(_tabData[index].topicProcedureController.text, args: argsData, kwargs: formattedResult);
                  _tabData[index].linkController.clear();
                  _tabData[index].realmController.clear();
                  _tabData[index].selectedSerializer = "";
                  _argsProviders[index].controllers.clear();
                  _kwargsProviders[index].tableData.clear();
                });
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text("Call Successful"),
                    duration: Duration(seconds: 3),
                  ),
                );
              } on Exception catch (error) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text("Call Error: $error"),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            color: Colors.blueAccent,
            minWidth: 200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              sendButton,
              style: TextStyle(
                color: whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

      case "Register":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 110),
          child: MaterialButton(
            onPressed: () async {
              await _registerAndStoreResult(index);
            },
            color: Colors.blueAccent,
            minWidth: 200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              sendButton,
              style: TextStyle(
                color: whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

      case "UnRegister":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 110),
          child: MaterialButton(
            onPressed: () async {
              await _unRegister(index, session, unregister);
            },
            color: Colors.blueAccent,
            minWidth: 200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              sendButton,
              style: TextStyle(
                color: whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

      default:
        return Container();
    }
  }

  // UNREGISTER
  Future<void> _unRegister(int index, Session? session, var reg) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await session?.unregister(reg);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("UnRegister Successfully"),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _tabData[index].sendButtonText = "send";
        _tabData[index].selectedSerializer = "";
        _tabData[index].selectedValue = "";
        Provider.of<InvocationProvider>(context, listen: false).invocations.clear();
      });
    } on Exception catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // UNSUBSCRIBE
  Future<void> _unSubscribe(int index, Session? session, var sub) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await session?.unsubscribe(sub);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("UnSubscribe Successfully"),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _tabData[index].sendButtonText = "send";
        _tabData[index].selectedSerializer = "";
        _tabData[index].selectedValue = "";
      });
    } on Exception catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // REGISTER AND STORE RESULT FUNCTION
  Future<void> _registerAndStoreResult(int index) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      var session = await connect(
        _tabData[index].linkController.text,
        _tabData[index].realmController.text,
        _tabData[index].selectedSerializer,
      );

      Future.delayed(const Duration(seconds: 2), () async {
        try {
          var registration = await session.register(
            _tabData[index].topicProcedureController.text,
            (invocation) {
              String result = "$index: args=${invocation.args}, kwargs=${invocation.kwargs}";
              Provider.of<InvocationProvider>(context, listen: false).addInvocation(result, index);
              return Result();
            },
          );
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text("Registration Successful"),
              duration: Duration(seconds: 3),
            ),
          );

          setState(() {
            var unregister = _tabData[index].sendButtonText = "UnRegister";
            Future.delayed(const Duration(seconds: 1), () {
              sendButton(unregister, index, session, registration);
              _tabData[index].linkController.clear();
              _tabData[index].realmController.clear();
              _tabData[index].selectedSerializer = "";
            });
          });
        } on Exception catch (error) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text("Registration Error: $error"),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    } on Exception catch (error) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Connection Error: $error"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // SUBSCRIBE
  Future<void> _subscribe(int index) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      Map<String, dynamic> kWarValues = {};
      for (final map in _kwargsProviders[index].tableData) {
        String key = map["key"];
        dynamic value = map["value"];
        kWarValues[key] = value;
      }
      var session = await connect(
        _tabData[index].linkController.text,
        _tabData[index].realmController.text,
        _tabData[index].selectedSerializer,
      );
      var sub = await session.subscribe(_tabData[index].topicProcedureController.text, (event) {});
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Subscribe Successful"),
          duration: Duration(seconds: 3),
        ),
      );

      setState(() {
        var unregister = _tabData[index].sendButtonText = "UnSubscribe";
        Future.delayed(const Duration(seconds: 1), () {
          sendButton(unregister, index, session, sub);
          _tabData[index].linkController.clear();
          _tabData[index].realmController.clear();
          _tabData[index].selectedSerializer = "";
        });
      });
    } on Exception catch (error) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Subscribe Error: $error"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // BUILD TOPIC PROCEDURE WIDGET
  Widget buildTopicProcedure(TextEditingController controller, String sendButtonText) {
    switch (sendButtonText) {
      case "Publish":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextFormField(
            controller: controller,
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
            controller: controller,
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
            controller: controller,
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
            controller: controller,
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

  // BUILD ARGS WIDGET
  Widget buildArgs(String argsSendButton, ArgsProvider argsProvider) {
    switch (argsSendButton) {
      case "Publish":
        return ArgsTextFormFields(
          provider: argsProvider,
        );

      case "Call":
        return ArgsTextFormFields(
          provider: argsProvider,
        );

      default:
        return Container();
    }
  }

  // BUILD KWARGS WIDGET
  Widget buildKwargs(String kWargSendButton, KwargsProvider kwargsProvider) {
    switch (kWargSendButton) {
      case "Publish":
        return DynamicKeyValuePairs(
          provider: kwargsProvider,
        );

      case "Call":
        return DynamicKeyValuePairs(
          provider: kwargsProvider,
        );

      default:
        return Container();
    }
  }
}
