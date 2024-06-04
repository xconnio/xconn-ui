import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:theme_provider/theme_provider.dart";
import "package:wick_ui/providers/args_provider.dart";
import "package:wick_ui/providers/event_provider.dart";
import "package:wick_ui/providers/invocation_provider.dart";
import "package:wick_ui/providers/kwargs_provider.dart";
import "package:wick_ui/providers/result_provider.dart";
import "package:wick_ui/providers/router_realm_provider.dart";
import "package:wick_ui/providers/router_state_provider.dart";
import "package:wick_ui/providers/router_toggleswitch_provider.dart";
import "package:wick_ui/providers/session_states_provider.dart";
import "package:wick_ui/responsive/responsive_layout.dart";
import "package:wick_ui/screens/mobile/mobile_home.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ArgsProvider()),
        ChangeNotifierProvider(create: (context) => KwargsProvider()),
        ChangeNotifierProvider(create: (context) => InvocationProvider()),
        ChangeNotifierProvider(create: (context) => EventProvider()),
        ChangeNotifierProvider(create: (context) => ResultProvider()),
        ChangeNotifierProvider(create: (context) => SessionStateProvider()),
        ChangeNotifierProvider(create: (context) => RouterToggleSwitchProvider()),
        ChangeNotifierProvider(create: (context) => RouterRealmProvider()),
        ChangeNotifierProvider(create: (context) => RouterStateProvider()),
      ],
      child: ThemeProvider(
        saveThemesOnChange: true,
        onInitCallback: (controller, previouslySavedThemeFuture) async {
          final view = View.of(context);
          String? savedTheme = await previouslySavedThemeFuture;
          if (savedTheme != null) {
            controller.setTheme(savedTheme);
          } else {
            Brightness platformBrightness = view.platformDispatcher.platformBrightness;
            if (platformBrightness == Brightness.dark) {
              controller.setTheme("dark");
            } else {
              controller.setTheme("light");
            }
            await controller.forgetSavedTheme();
          }
        },
        themes: <AppTheme>[
          AppTheme.light(id: "light"),
          AppTheme.dark(id: "dark"),
        ],
        child: ThemeConsumer(
          child: Builder(
            builder: (themeContext) => MaterialApp(
              title: "Wick",
              debugShowCheckedModeBanner: false,
              theme: ThemeProvider.themeOf(themeContext).data,
              home: const ResponsiveLayout(
                mobileScaffold: MobileHomeScaffold(),
                tabletScaffold: MobileHomeScaffold(),
                desktopScaffold: MobileHomeScaffold(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
