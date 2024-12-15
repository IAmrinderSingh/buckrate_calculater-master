import 'package:buckrate_calculator/constants/colors.dart';
import 'package:buckrate_calculator/route_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

final GlobalKey<ScaffoldMessengerState> globalScaffoldKey =
    GlobalKey<ScaffoldMessengerState>();

void runAppFunc() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    ThemeData lightThemeData = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryColor,
        brightness: Brightness.light,
        background: kBackgroundColorLightColor,
      ),
      useMaterial3: true,
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: kBackgroundColorLightColor,
        indicatorColor: Colors.white,
        elevation: 4,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: kBackgroundColorLightColor,
        indicatorColor: Colors.white,
        elevation: 5,
      ),
    );
    ThemeData darkThemeData = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
    return MaterialApp.router(
      title: 'Buckrate',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      scaffoldMessengerKey: globalScaffoldKey,
      routerConfig: navigator,
    );
  }
}
