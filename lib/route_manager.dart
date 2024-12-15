import 'package:buckrate_calculator/data/local_storage_web.dart';
import 'package:buckrate_calculator/pages/admin_dashboard/admin_dashbaord.dart';
import 'package:buckrate_calculator/pages/admin_dashboard/admin_login_page.dart';
import 'package:buckrate_calculator/pages/auth/get_otp.dart';
import 'package:buckrate_calculator/pages/auth/verify_otp.dart';
import 'package:buckrate_calculator/pages/buyer_dashboard/buyer_dashboard.dart';
import 'package:buckrate_calculator/pages/calculator/calculator.dart';
import 'package:buckrate_calculator/pages/home.dart';
import 'package:buckrate_calculator/pages/recommendation/recommendation_breading.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter navigator = GoRouter(
  // observers: [
  //   GoRouterHistoryManagerAndObserver(),
  // ],
  redirect: (context, state) async {
    String? isLogin = WebSessionStorage.get("isLogin");
    if (state.matchedLocation == AdminDashboardPage.routeName) {
      if (isLogin != "true") {
        return AdminLoginPage.routeName;
      }
    }
    return null;
  },
  errorBuilder: (context, state) {
    return PageNotFoundWidget(
      state: state,
    );
  },
  routes: <GoRoute>[
    GoRoute(
      name: GetOtpPage.routeName,
      path: GetOtpPage.routeName,
      builder: (context, state) {
        return const GetOtpPage();
      },
    ),
    GoRoute(
      name: VerifyOtpPage.routeName,
      path: VerifyOtpPage.routeName,
      builder: (context, state) {
        return const VerifyOtpPage();
      },
    ),
    GoRoute(
      name: HomePage.routeName,
      path: HomePage.routeName,
      builder: (context, state) {
        return HomePage(
          tab: state.uri.queryParameters['tab'],
        );
      },
    ),
    GoRoute(
      name: CalculatorPage.routeName,
      path: CalculatorPage.routeName,
      builder: (context, state) {
        return const CalculatorPage();
      },
    ),
    GoRoute(
      name: RecommendationPage.routeName,
      path: RecommendationPage.routePath,
      builder: (context, state) {
        return RecommendationPage(price: state.pathParameters['price'] ?? '0');
      },
    ),
    GoRoute(
      name: BuyerDashboardPage.routeName,
      path: BuyerDashboardPage.routeName,
      builder: (context, state) {
        return const BuyerDashboardPage();
      },
    ),
    GoRoute(
      name: AdminLoginPage.routeName,
      path: AdminLoginPage.routeName,
      builder: (context, state) {
        return const AdminLoginPage();
      },
    ),
    GoRoute(
      name: AdminDashboardPage.routeName,
      path: AdminDashboardPage.routeName,
      builder: (context, state) {
        return const AdminDashboardPage();
      },
    ),
  ],
);

class PageNotFoundWidget extends StatefulWidget {
  const PageNotFoundWidget({
    super.key,
    required this.state,
  });
  final GoRouterState state;

  @override
  State<PageNotFoundWidget> createState() => _PageNotFoundWidgetState();
}

class _PageNotFoundWidgetState extends State<PageNotFoundWidget> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Page not found'),
      ),
    );
  }
}
