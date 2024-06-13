import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:wick_ui/providers/args_provider.dart";
import "package:wick_ui/providers/kwargs_provider.dart";
import "package:wick_ui/utils/tab_data_class.dart";

class TabControllerProvider with ChangeNotifier {
  TabControllerProvider() {
    _initializeTabController();
    _initializeProviders();
  }

  late TabController _tabController;
  final List<String> _tabNames = ["Tab"];
  final List<String> _tabContents = ["Content for Tab 1"];
  final List<TabData> _tabData = [TabData()];
  final List<ArgsProvider> _argsProviders = [];
  final List<KwargsProvider> _kwargsProviders = [];
  final TickerProviderImpl _tickerProvider = TickerProviderImpl();

  TabController get tabController => _tabController;

  List<String> get tabNames => _tabNames;

  List<String> get tabContents => _tabContents;

  List<TabData> get tabData => _tabData;

  List<ArgsProvider> get argsProviders => _argsProviders;

  List<KwargsProvider> get kwargsProviders => _kwargsProviders;

  void _initializeTabController() {
    _tabController = TabController(length: _tabNames.length, vsync: _tickerProvider);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    notifyListeners();
  }

  void _initializeProviders() {
    for (int i = 0; i < _tabNames.length; i++) {
      _argsProviders.add(ArgsProvider());
      _kwargsProviders.add(KwargsProvider());
    }
  }

  void addTab() {
    int newIndex = _tabNames.length;
    _tabNames.add("Tab ${newIndex + 1}");
    _tabContents.add("Content for Tab ${newIndex + 1}");
    _tabData.add(TabData());
    _argsProviders.add(ArgsProvider());
    _kwargsProviders.add(KwargsProvider());
    _tabController = TabController(length: _tabNames.length, vsync: _tickerProvider);
    _tabController
      ..addListener(_handleTabSelection)
      ..index = newIndex;

    notifyListeners();
  }

  void removeTab(int index) {
    int newIndex = _tabController.index;
    _tabNames.removeAt(index);
    _tabContents.removeAt(index);
    _tabData[index].disposeControllers();
    _tabData.removeAt(index);
    _argsProviders.removeAt(index);
    _kwargsProviders.removeAt(index);
    if (newIndex >= _tabNames.length) {
      newIndex = _tabNames.length - 1;
    }

    _updateTabController(newIndex);
    notifyListeners();
  }

  void _updateTabController(int targetIndex) {
    final int currentLength = _tabController.length;
    final int newLength = _tabNames.length;

    if (currentLength != newLength) {
      if (newLength > 0) {
        _tabController.dispose();
        _initializeTabController();
        _tabController.index = targetIndex;
      }
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabSelection)
      ..dispose();
    _disposeProviders();
    _tickerProvider.dispose();
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
}

class TickerProviderImpl extends TickerProvider {
  final List<Ticker> _tickers = [];

  @override
  Ticker createTicker(TickerCallback onTick) {
    final ticker = Ticker(onTick);
    _tickers.add(ticker);
    return ticker;
  }

  void dispose() {
    for (final ticker in _tickers) {
      ticker.dispose();
    }
  }
}
