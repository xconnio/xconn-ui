import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wick_ui/constants.dart";
import "package:wick_ui/providers/args_provider.dart";
import "package:wick_ui/providers/event_provider.dart";
import "package:wick_ui/providers/invocation_provider.dart";
import "package:wick_ui/providers/kwargs_provider.dart";
import "package:wick_ui/providers/result_provider.dart";
import "package:wick_ui/providers/session_states_provider.dart";
import "package:wick_ui/utils/args_screen.dart";
import "package:wick_ui/utils/kwargs_screen.dart";
import "package:wick_ui/utils/tab_data_class.dart";
import "package:wick_ui/wamp_util.dart";
import "package:xconn/exports.dart";

class DesktopHomeScaffold extends StatefulWidget {
  const DesktopHomeScaffold({super.key});

  @override
  State<DesktopHomeScaffold> createState() => _DesktopHomeScaffoldState();
}

class _DesktopHomeScaffoldState extends State<DesktopHomeScaffold> with TickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Wick",
          style: TextStyle(
            color: homeAppBarTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
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
                .map((entry) => _buildTabWithDeleteButton(entry.key, entry.value))
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

  Widget _buildTab(int index) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildTabActionDropdown(index),
          const SizedBox(height: 20),
          _buildTabSerializerDropdown(index),
          const SizedBox(height: 20),
          buildTopicProcedure(_tabData[index].topicProcedureController, _tabData[index].sendButtonText),
          const SizedBox(height: 20),
          buildArgs(_tabData[index].sendButtonText, _argsProviders[index]),
          const SizedBox(height: 20),
          buildKwargs(_tabData[index].sendButtonText, _kwargsProviders[index]),
          const SizedBox(height: 20),
          sendButton(_tabData[index].sendButtonText, index),
          const SizedBox(height: 50),
          resultText(_tabData[index].sendButtonText),
          _buildInvocationResults(index),
          _buildEventResults(index),
          _buildCallResults(index),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTabActionDropdown(int index) {
    return Padding(
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
                items: ["Register", "Subscribe", "Call", "Publish"].map((String value) {
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
                    _tabData[index].sendButtonText = newValue;
                  });
                },
              ),
            ),
            Container(height: 30, width: 1, color: Colors.grey),
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
    );
  }

  Widget _buildTabSerializerDropdown(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _tabData[index].selectedSerializer.isEmpty ? null : _tabData[index].selectedSerializer,
              hint: const Text("Serializers"),
              items: [jsonSerializer, cborSerializer, msgPackSerializer].map((String value) {
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
          const SizedBox(width: 10),
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

  Widget _buildCallResults(int index) {
    return Consumer<ResultProvider>(
      builder: (context, callResult, _) {
        List<String> results = callResult.results;
        _tabData[index].callRslt = results.where((result) => result.startsWith("$index:")).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _tabData[index].callRslt!.map(_buildResultContainer).toList(),
        );
      },
    );
  }

  Widget _buildResultContainer(String result) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: blackColor,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _publish(int index) async {
    List<String> argsData = _argsProviders[index].controllers.map((controller) => controller.text).toList();
    Map<String, dynamic> kWarValues = {};
    for (final map in _kwargsProviders[index].tableData) {
      String key = map["key"];
      dynamic value = map["value"];
      kWarValues[key] = value;
    }

    try {
      var session = await connect(
        _tabData[index].linkController.text,
        _tabData[index].realmController.text,
        _tabData[index].selectedSerializer,
      );

      await session.publish(
        _tabData[index].topicProcedureController.text,
        args: argsData,
        kwargs: kWarValues,
      );
      setState(() {
        _tabData[index].linkController.clear();
        _tabData[index].realmController.clear();
        _tabData[index].topicProcedureController.clear();
        _argsProviders[index].controllers.clear();
        _kwargsProviders[index].tableData.clear();
        _tabData[index].selectedSerializer = "";
      });
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  Widget sendButton(String sendButton, int index) {
    var sessionStateProvider = Provider.of<SessionStateProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    Widget buildButton(String label, Future<void> Function() action) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 110),
        child: MaterialButton(
          onPressed: () async {
            try {
              await action();
            } on Exception catch (error) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text("$sendButton Error: $error"),
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
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    switch (sendButton) {
      case "Publish":
        return buildButton(sendButton, () async {
          try {
            await _publish(index);
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
            await _subscribe(index);
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
            await _unSubscribe(index, sessionStateProvider.session, sessionStateProvider.subscription);
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
            await _call(index);
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
            await _registerAndStoreResult(index);
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
            await _unRegister(index, sessionStateProvider.session, sessionStateProvider.unregister);
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

  Future<void> _unRegister(int index, Session? session, var reg) async {
    await session?.unregister(reg);
    setState(() {
      _tabData[index].sendButtonText = "send";
      _tabData[index].selectedSerializer = "";
      _tabData[index].selectedValue = "";
      _tabData[index].topicProcedureController.clear();
      Provider.of<InvocationProvider>(context, listen: false).invocations.clear();
    });
  }

  Future<void> _unSubscribe(int index, Session? session, var sub) async {
    await session?.unsubscribe(sub);
    setState(() {
      _tabData[index].sendButtonText = "send";
      _tabData[index].selectedSerializer = "";
      _tabData[index].selectedValue = "";
    });
  }

  Future<void> _registerAndStoreResult(int index) async {
    var sessionProvider = Provider.of<SessionStateProvider>(context, listen: false);

    try {
      var session = await connect(
        _tabData[index].linkController.text,
        _tabData[index].realmController.text,
        _tabData[index].selectedSerializer,
      );

      var registration = await session.register(
        _tabData[index].topicProcedureController.text,
            (invocation) {
          String invocations = "$index: args=${invocation.args}, kwargs=${invocation.kwargs}";
          Provider.of<InvocationProvider>(context, listen: false).addInvocation(invocations);
          return Result();
        },
      );

      sessionProvider
        ..setSession(session)
        ..setUnregister(registration);
      setState(() {
        var unregister = _tabData[index].sendButtonText = "UnRegister";
        sendButton(unregister, index);
        _tabData[index].linkController.clear();
        _tabData[index].realmController.clear();
        _tabData[index].selectedSerializer = "";
      });
    } on Exception catch (error) {
      throw Future.error(error);
    }
  }

  Future<void> _subscribe(int index) async {
    var sessionProvider = Provider.of<SessionStateProvider>(context, listen: false);
    try {
      var session = await connect(
        _tabData[index].linkController.text,
        _tabData[index].realmController.text,
        _tabData[index].selectedSerializer,
      );
      var subscription = await session.subscribe(
        _tabData[index].topicProcedureController.text,
            (event) {
          String events = "$index: args=${event.args}, kwargs=${event.kwargs}";
          Provider.of<EventProvider>(context, listen: false).addEvents(events);
        },
      );
      sessionProvider
        ..setSession(session)
        ..setUnSubscribe(subscription);
      setState(() {
        var unsubscribe = _tabData[index].sendButtonText = "UnSubscribe";
        sendButton(unsubscribe, index);
        _tabData[index].linkController.clear();
        _tabData[index].realmController.clear();
        _tabData[index].selectedSerializer = "";
      });
    } on Exception catch (error) {
      throw Future.error(error);
    }
  }

  Future<void> _call(int index) async {
    var resultProvider = Provider.of<ResultProvider>(context, listen: false);
    try {
      List<String> argsData = _argsProviders[index].controllers.map((controller) => controller.text).toList();
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

      var calls = await session.call(
        _tabData[index].topicProcedureController.text,
        args: argsData,
        kwargs: kWarValues,
      );

      resultProvider.results.clear();
      String result = "$index: args=${calls.args}, kwargs=${calls.kwargs}";
      resultProvider.addResult(result);

      _tabData[index].linkController.clear();
      _tabData[index].realmController.clear();
      _tabData[index].selectedSerializer = "";
      _argsProviders[index].controllers.clear();
      _kwargsProviders[index].tableData.clear();
    } on Exception catch (error) {
      throw Future.error(error);
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
          labelText: sendButtonText.contains("Publish") || sendButtonText.contains("Subscribe")
              ? "Enter topic here"
              : "Enter procedure here",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.all(10),
        ),
      ),
    );
  }

  Widget buildArgs(String argsSendButton, ArgsProvider argsProvider) {
    return argsSendButton.contains("Publish") || argsSendButton.contains("Call")
        ? ArgsTextFormFields(provider: argsProvider)
        : Container();
  }

  Widget buildKwargs(String kWargSendButton, KwargsProvider kwargsProvider) {
    return kWargSendButton.contains("Publish") || kWargSendButton.contains("Call")
        ? DynamicKeyValuePairs(provider: kwargsProvider)
        : Container();
  }
}
