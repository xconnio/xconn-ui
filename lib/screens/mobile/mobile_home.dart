import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wick_ui/constants.dart";
import "package:wick_ui/providers/args_provider.dart";
import "package:wick_ui/providers/event_provider.dart";
import "package:wick_ui/providers/invocation_provider.dart";
import "package:wick_ui/providers/kwargs_provider.dart";
import "package:wick_ui/providers/result_provider.dart";
import "package:wick_ui/providers/session_states_provider.dart";
import "package:wick_ui/providers/tab_provider.dart";
import "package:wick_ui/screens/mobile/settings_screen.dart";
import "package:wick_ui/utils/args_screen.dart";
import "package:wick_ui/utils/custom_appbar.dart";
import "package:wick_ui/utils/kwargs_screen.dart";
import "package:wick_ui/utils/tab_data_class.dart";
import "package:wick_ui/wamp_util.dart";
import "package:xconn/exports.dart";

class MobileHomeScaffold extends StatefulWidget {
  const MobileHomeScaffold({super.key});

  @override
  State<MobileHomeScaffold> createState() => _MobileHomeScaffoldState();
}

class _MobileHomeScaffoldState extends State<MobileHomeScaffold> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabNames = ["Tab"];
  final List<String> _tabContents = ["Content for Tab 1"];
  final List<TabData> _tabData = [TabData()];
  final List<ArgsProvider> _argsProviders = [];
  final List<KwargsProvider> _kwargsProviders = [];

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _initializeProviders();
  }

  void _initializeTabController() {
    _tabController = TabController(length: _tabNames.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {});
  }

  void _initializeProviders() {
    for (int i = 0; i < _tabNames.length; i++) {
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
      _updateTabController();
      _tabController.index = newIndex;
    });
  }

  void _removeTab(int index) {
    setState(() {
      _tabNames.removeAt(index);
      _tabContents.removeAt(index);
      _tabData[index].disposeControllers();
      _tabData.removeAt(index);
      _argsProviders.removeAt(index);
      _kwargsProviders.removeAt(index);
      _updateTabController();
    });
  }

  void _updateTabController() {
    if (_tabController.length != _tabNames.length) {
      _initializeTabController();
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabSelection)
      ..dispose();
    _disposeProviders();
    super.dispose();
  }

  void _disposeProviders() {
    for (final provider in _argsProviders) {
      provider.dispose();
    }
    for (final kProvider in _kwargsProviders) {
      kProvider.dispose();
    }
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
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: tabControllerProvider.tabController,
                    children: tabControllerProvider.tabContents
                        .asMap()
                        .entries
                        .map((entry) => _buildTab(entry.key, tabControllerProvider))
                        .toList(),
                  ),
                )
              : Container(),
        );
      },
    );
  }

  Widget _buildTab(int index, TabControllerProvider tabControllerProvider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildTabActionDropdown(index, tabControllerProvider),
          const SizedBox(height: 20),
          _buildTabSerializerDropdown(index, tabControllerProvider),
          const SizedBox(height: 20),
          buildTopicProcedure(
            tabControllerProvider.tabData[index].topicProcedureController,
            tabControllerProvider.tabData[index].sendButtonText,
          ),
          const SizedBox(height: 20),
          buildArgs(tabControllerProvider.tabData[index].sendButtonText, tabControllerProvider.argsProviders[index]),
          const SizedBox(height: 20),
          buildKwargs(_tabData[index].sendButtonText, _kwargsProviders[index]),
          if (_tabData[index].sendButtonText != "Subscribe" && _tabData[index].sendButtonText != "UnSubscribe")
            const Divider(),
          Consumer3<InvocationProvider, EventProvider, ResultProvider>(
            builder: (context, invocationProvider, eventProvider, resultProvider, child) {
              final hasInvocationResults = _hasResults(index, invocationProvider.invocations);
              final hasEventsResults = _hasResults(index, eventProvider.events);
              final hasCallResults = _hasResults(index, resultProvider.results);
              if (hasInvocationResults || hasEventsResults || hasCallResults) {
                return resultText(_tabData[index].sendButtonText);
              } else {
                return Container();
              }
             },
          ),
          const Divider(),
          buildKwargs(
            tabControllerProvider.tabData[index].sendButtonText,
            tabControllerProvider.kwargsProviders[index],
          ),
          const SizedBox(height: 50),
          _buildInvocationResults(index),
          _buildEventResults(index),
          _buildCallResults(index, tabControllerProvider),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  bool _hasResults(int index, List<String> results) {
    return results.where((result) => result.startsWith("$index:")).isNotEmpty;
  }

  Widget _buildTabActionDropdown(int index, TabControllerProvider tabControllerProvider) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextFormField(
                controller: tabControllerProvider.tabData[index].linkController,
                decoration: const InputDecoration(
                  hintText: "ws://localhost:8080/ws",
                  hintStyle: TextStyle(fontWeight: FontWeight.w200),
                  labelText: "Enter URL here",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "URL cannot be empty";
                  }
                  const urlPattern = r"^(ws|wss):\/\/[^\s$.?#]+(\.[^\s$.?#]+)*(:\d+)?(\/[^\s]*)?$";
                  final result = RegExp(urlPattern, caseSensitive: false).hasMatch(value);
                  if (!result) {
                    return "Enter a valid WebSocket URL";
                  }
                  return null; // return null if the validation passes
                },
              ),
            ),
          ),
          sendButton(tabControllerProvider.tabData[index].sendButtonText, index, tabControllerProvider),
          Container(width: 1, height: 45, color: Colors.black),
          if (_tabData[index].sendButtonText == "UnRegister" || _tabData[index].sendButtonText == "UnSubscribe")
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Please ${_tabData[index].sendButtonText} first"),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                height: 45,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  color: Colors.grey,
                ),
                child: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
              ),
            )
          else
            Container(
                height: 45,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  color: Colors.blue,
                ),
                child: PopupMenuButton<String>(
                    onSelected: (String newValue) {
                      setState(() {
                        _tabData[index].selectedValue = newValue;
                        _tabData[index].sendButtonText = newValue;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return ["Register", "Subscribe", "Call", "Publish"].map((String value) {
                        return PopupMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList();
                    },
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (String newValue) {
                        setState(() {
                          tabControllerProvider.tabData[index].selectedValue = newValue;
                          tabControllerProvider.tabData[index].sendButtonText = newValue;
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return ["Register", "Subscribe", "Call", "Publish"].map((String value) {
                          return PopupMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList();
                      },
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                    )))
        ],
      ),
    );
  }

  Widget _buildTabSerializerDropdown(int index, TabControllerProvider tabControllerProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: tabControllerProvider.tabData[index].selectedSerializer.isEmpty
                  ? null
                  : tabControllerProvider.tabData[index].selectedSerializer,
              focusColor: Colors.transparent,
              hint: const Text("Serializers"),
              items: [jsonSerializer, cborSerializer, msgPackSerializer].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  tabControllerProvider.tabData[index].selectedSerializer = newValue!;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: tabControllerProvider.tabData[index].realmController,
              decoration: InputDecoration(
                hintText: "Enter realm here",
                hintStyle: const TextStyle(fontWeight: FontWeight.w200),
                labelText: "Enter realm here",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Realm cannot be empty";
                }
                const regexPattern = r"^([^\s\.#]+\.)*([^\s\.#]+)$";
                if (!RegExp(regexPattern).hasMatch(value)) {
                  return "Enter a valid realm";
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvocationResults(int index) {
    return Consumer<InvocationProvider>(
      builder: (context, invocationResult, _) {
        List<String> results = invocationResult.invocations;
        List<String> invocationRslt = results.where((result) => result.startsWith("$index:")).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: invocationRslt.map(_buildResultContainer).toList(),
        );
      },
    );
  }

  Widget _buildEventResults(int index) {
    return Consumer<EventProvider>(
      builder: (context, eventResult, _) {
        List<String> results = eventResult.events;
        List<String> eventRslt = results.where((result) => result.startsWith("$index:")).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: eventRslt.map(_buildResultContainer).toList(),
        );
      },
    );
  }

  Widget _buildCallResults(int index, TabControllerProvider tabControllerProvider) {
    return Consumer<ResultProvider>(
      builder: (context, callResult, _) {
        List<String> results = callResult.results;
        tabControllerProvider.tabData[index].callRslt =
            results.where((result) => result.startsWith("$index:")).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: tabControllerProvider.tabData[index].callRslt!.map(_buildResultContainer).toList(),
        );
      },
    );
  }

  Widget _buildResultContainer(String result) {
    String finalResult = result.replaceFirst(RegExp(r"^\d+: "), "");
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            finalResult,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget resultText(String buttonText) {
    String resultLabel;

    switch (buttonText) {
      case "Register":
      case "UnRegister":
        resultLabel = "Invocation";
      case "Call":
        resultLabel = "Result";
      case "Subscribe":
      case "UnSubscribe":
        resultLabel = "Event";
      default:
        return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          height: 30,
          width: MediaQuery.of(context).size.width,
          child: Text(
            resultLabel,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _publish(int index, TabControllerProvider tabControllerProvider) async {
    List<String> argsData =
        tabControllerProvider.argsProviders[index].controllers.map((controller) => controller.text).toList();
    Map<String, String> kWarValues = {};
    for (final mapEntry in tabControllerProvider.kwargsProviders[index].tableData) {
      kWarValues[mapEntry.key] = mapEntry.value;
    }

    try {
      var session = await connect(
        tabControllerProvider.tabData[index].linkController.text,
        tabControllerProvider.tabData[index].realmController.text,
        tabControllerProvider.tabData[index].selectedSerializer,
      );

      await session.publish(
        tabControllerProvider.tabData[index].topicProcedureController.text,
        args: argsData,
        kwargs: kWarValues,
      );
      setState(() {});
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  Widget sendButton(String sendButton, int index, TabControllerProvider tabControllerProvider) {
    var sessionStateProvider = Provider.of<SessionStateProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    double baseHeight = 45;
    double baseWidth = 150;
    double pixelDensity = MediaQuery.of(context).devicePixelRatio;
    double buttonHeight = baseHeight / pixelDensity;
    double buttonWidth = baseWidth / pixelDensity;
    Widget buildButton(String label, Future<void> Function() action) {
      return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
              onPressed: () async {
                if (label == "UnRegister" || label == "UnSubscribe" || (formkey.currentState?.validate() ?? false)) {
                  try {
                    await action();
                  } on Exception catch (error) {
                    if (context.mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text("Send Button Error: $error"),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _tabData[index].sendButtonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ))));
    }

    switch (sendButton) {
      case "Publish":
        return buildButton(sendButton, () async {
          try {
            await _publish(index, tabControllerProvider);
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text("Publish Successful"),
                duration: Duration(seconds: 2),
              ),
            );
          } on Exception catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text("Error in publishing $e"),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      case "Subscribe":
        return buildButton(sendButton, () async {
          try {
            await _subscribe(index, tabControllerProvider);
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text("Subscribe Successful"),
                duration: Duration(seconds: 2),
              ),
            );
          } on Exception catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text("Error in Subscribing $e"),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      case "UnSubscribe":
        return buildButton(sendButton, () async {
          try {
            await _unSubscribe(
              index,
              sessionStateProvider.sessionUnSubscribe,
              sessionStateProvider.subscription,
              tabControllerProvider,
            );
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text("UnSubscribe Successfully"),
                duration: Duration(seconds: 2),
              ),
            );
          } on Exception catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text("Error in Subscribing: $e"),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      case "Call":
        return buildButton(sendButton, () async {
          try {
            await _call(index, tabControllerProvider);
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text("Call Successful"),
                duration: Duration(seconds: 2),
              ),
            );
          } on Exception catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text("Error in Calling: $e"),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      case "Register":
        return buildButton(sendButton, () async {
          try {
            await _registerAndStoreResult(index, tabControllerProvider);
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text("Registration Successful"),
                duration: Duration(seconds: 2),
              ),
            );
          } on Exception catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text("Error in Registration $e"),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      case "UnRegister":
        return buildButton(sendButton, () async {
          try {
            await _unRegister(
              index,
              sessionStateProvider.sessionUnRegister,
              sessionStateProvider.unregister,
              tabControllerProvider,
            );
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text("UnRegister Successfully"),
                duration: Duration(seconds: 2),
              ),
            );
          } on Exception catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text("Error in UnRegistering: $e"),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      default:
        return Container();
    }
  }

  Future<void> _unRegister(int index, Session? session, var reg, TabControllerProvider tabControllerProvider) async {
    await session?.unregister(reg);
    setState(() {
      _tabData[index].sendButtonText = "Register";
      Provider.of<InvocationProvider>(context, listen: false).invocations.clear();
    });
  }

  Future<void> _unSubscribe(int index, Session? session, var sub, TabControllerProvider tabControllerProvider) async {
    await session?.unsubscribe(sub);
    setState(() {
      _tabData[index].sendButtonText = "Subscribe";
      Provider.of<EventProvider>(context, listen: false).events.clear();
    });
  }

  Future<void> _registerAndStoreResult(int index, TabControllerProvider tabControllerProvider) async {
    var sessionProvider = Provider.of<SessionStateProvider>(context, listen: false);
    List<String> argsData =
        tabControllerProvider.argsProviders[index].controllers.map((controller) => controller.text).toList();
    Map<String, String> kWarValues = {};
    for (final mapEntry in tabControllerProvider.kwargsProviders[index].tableData) {
      kWarValues[mapEntry.key] = mapEntry.value;
    }

    try {
      var session = await connect(
        tabControllerProvider.tabData[index].linkController.text,
        tabControllerProvider.tabData[index].realmController.text,
        tabControllerProvider.tabData[index].selectedSerializer,
      );

      var registration = await session.register(
        tabControllerProvider.tabData[index].topicProcedureController.text,
        (invocation) {
          String invocations = "$index: args=${invocation.args}, kwargs=${invocation.kwargs}";
          Provider.of<InvocationProvider>(context, listen: false).addInvocation(invocations);
          return Result(args: argsData, kwargs: kWarValues);
        },
      );

      sessionProvider
        ..setSessionUnRegister(session)
        ..setUnregister(registration);
      setState(() {
        var unregister = _tabData[index].sendButtonText = "UnRegister";
        sendButton(unregister, index, tabControllerProvider);
      });
    } on Exception catch (error) {
      throw Exception(error);
    }
  }

  Future<void> _subscribe(int index, TabControllerProvider tabControllerProvider) async {
    var sessionProvider = Provider.of<SessionStateProvider>(context, listen: false);
    try {
      var session = await connect(
        tabControllerProvider.tabData[index].linkController.text,
        tabControllerProvider.tabData[index].realmController.text,
        tabControllerProvider.tabData[index].selectedSerializer,
      );
      var subscription = await session.subscribe(
        tabControllerProvider.tabData[index].topicProcedureController.text,
        (event) {
          String events = "$index: args=${event.args}, kwargs=${event.kwargs}";
          Provider.of<EventProvider>(context, listen: false).addEvents(events);
        },
      );
      sessionProvider
        ..setSessionUnSubscribe(session)
        ..setUnSubscribe(subscription);
      setState(() {
        var unsubscribe = _tabData[index].sendButtonText = "UnSubscribe";
        sendButton(unsubscribe, index, tabControllerProvider);
      });
    } on Exception catch (error) {
      throw Exception(error);
    }
  }

  Future<void> _call(int index, TabControllerProvider tabControllerProvider) async {
    var resultProvider = Provider.of<ResultProvider>(context, listen: false);
    try {
      List<String> argsData =
          tabControllerProvider.argsProviders[index].controllers.map((controller) => controller.text).toList();
      Map<String, String> kWarValues = {};
      for (final mapEntry in tabControllerProvider.kwargsProviders[index].tableData) {
        kWarValues[mapEntry.key] = mapEntry.value;
      }
      var session = await connect(
        tabControllerProvider.tabData[index].linkController.text,
        tabControllerProvider.tabData[index].realmController.text,
        tabControllerProvider.tabData[index].selectedSerializer,
      );

      var calls = await session.call(
        tabControllerProvider.tabData[index].topicProcedureController.text,
        args: argsData,
        kwargs: kWarValues,
      );

      resultProvider.results.clear();
      String result = "$index: args=${calls.args}, kwargs=${calls.kwargs}";
      resultProvider.addResult(result);
    } on Exception catch (error) {
      throw Exception(error);
    }
  }

  Widget buildTopicProcedure(TextEditingController controller, String sendButtonText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: sendButtonText.contains("Publish") || sendButtonText.contains("Subscribe")
              ? "Enter topic here"
              : "Enter procedure here",
          hintStyle: const TextStyle(fontWeight: FontWeight.w200),
          labelText: sendButtonText.contains("Publish") || sendButtonText.contains("Subscribe")
              ? "Enter topic here"
              : "Enter procedure here",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.all(10),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return "${sendButtonText.contains("Publish") || sendButtonText.contains("Subscribe") ? "Topic" : "Procedure"} cannot be empty";
          }
          const regexPattern = r"^([^\s.#]+\.)*([^\s.#]+)$";
          if (!RegExp(regexPattern).hasMatch(value!)) {
            return sendButtonText.contains("Publish") || sendButtonText.contains("Subscribe")
                ? "Enter a valid topic"
                : "Enter a valid procedure";
          }
          return null;
        },
      ),
    );
  }

  Widget buildArgs(String argsSendButton, ArgsProvider argsProvider) {
    return argsSendButton.contains("Publish") || argsSendButton.contains("Call") || argsSendButton.contains("Register")
        ? ArgsTextFormFields(provider: argsProvider)
        : Container();
  }

  Widget buildKwargs(String kWargSendButton, KwargsProvider kwargsProvider) {
    return kWargSendButton.contains("Publish") ||
            kWargSendButton.contains("Call") ||
            kWargSendButton.contains("Register")
        ? DynamicKeyValuePairs(provider: kwargsProvider)
        : Container();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GlobalKey<FormState>>("formkey", formkey));
  }
}
