import 'package:buckrate_calculator/data/web_navigation_html_js.dart';
import 'package:buckrate_calculator/pages/buyer_dashboard/buyer_dashboard.dart';
import 'package:buckrate_calculator/pages/calculator/calculator.dart';
import 'package:buckrate_calculator/pages/settings/settings.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static const String routeName = "/";
  const HomePage({super.key, this.tab});
  final String? tab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool refreshPage = false;

  @override
  void initState() {
    currentIndex = int.parse(widget.tab ?? "0");
    super.initState();
  }

  void refresh() {
    setState(() {
      refreshPage = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        refreshPage = false;
      });
    });
  }

  int currentIndex = 0;
  List<Widget> pagesList = [
    const CalculatorPage(),
    // const BuyerDashboardPage(),
    const SettingsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MediaQuery.of(context).size.width > 750
              ? const SizedBox()
              : NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (value) {
                    // TODO: Enable when bot is ready
                    // if (value == 0) {
                    //   launchUrlString("https://wa.me/$tmMobileNo?text=hi");
                    // }
                    setState(() {
                      currentIndex = value;
                    });
                    WebNavigation.updateCurrentWebPathQueryParm({
                      "tab": value.toString(),
                    });
                    if (value == 1) {
                      refresh();
                    }
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.calculate_outlined),
                      selectedIcon: Icon(Icons.calculate),
                      label: 'बेचें',
                    ),
                    // NavigationDestination(
                    //   icon: Icon(Icons.storefront_outlined),
                    //   selectedIcon: Icon(Icons.storefront),
                    //   label: 'खरीदें',
                    // ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: 'सेटिंग्स',
                    ),
                  ],
                ),
        ],
      ),
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 750)
            NavigationRail(
              leading: Image.asset(
                "assets/buckrate.png",
                width: 40,
                height: 40,
              ),
              useIndicator: true,
              selectedIndex: currentIndex,
              onDestinationSelected: (value) {
                setState(() {
                  currentIndex = value;
                });
                WebNavigation.updateCurrentWebPathQueryParm({
                  "tab": value.toString(),
                });
                // if (value == 1) {
                //   refresh();
                // }
              },
              groupAlignment: 0.0,
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.calculate_outlined),
                  selectedIcon: Icon(Icons.calculate),
                  label: Text('बेचें'),
                ),
                // NavigationRailDestination(
                //   icon: Icon(Icons.storefront_outlined),
                //   selectedIcon: Icon(Icons.storefront),
                //   label: Text('खरीदें'),
                // ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('सेटिंग्स'),
                ),
              ],
            ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: refreshPage
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : pagesList[currentIndex],
          )
        ],
      ),
    );
  }
}
