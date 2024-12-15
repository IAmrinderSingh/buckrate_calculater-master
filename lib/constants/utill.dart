import 'dart:developer';

import 'package:buckrate_calculator/constants/enums.dart';
import 'package:buckrate_calculator/main_app.dart';
import 'package:flutter/material.dart';

Future<dynamic> showDialogC({
  required BuildContext context,
  required Widget child,
  double verticalPadding = 0,
  bool barrierDismissible = true,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: ResponsiveD.d(context) == ResponsiveD.mobile
            ? MediaQuery.of(context).size.width * 0.01
            : ResponsiveD.d(context) == ResponsiveD.tablet
                ? MediaQuery.of(context).size.width * 0.1
                : MediaQuery.of(context).size.width * 0.3,
      ),
      child: child,
    ),
  );
}

Future<dynamic> showModalBottomSheetC({
  required BuildContext context,
  required Widget child,
  double? height,
  Color backgroundColor = Colors.white,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet(
    context: context,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    clipBehavior: Clip.hardEdge,
    backgroundColor: backgroundColor,
    isScrollControlled: isScrollControlled,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    constraints: BoxConstraints(
      maxWidth: ResponsiveD.d(context) == ResponsiveD.mobile
          ? MediaQuery.of(context).size.width
          : ResponsiveD.d(context) == ResponsiveD.tablet
              ? MediaQuery.of(context).size.width * 0.8
              : MediaQuery.of(context).size.width * 0.4,
    ),
    builder: (context) => SizedBox(height: height, child: child),
  );
}

void snackBarWithoutContext(String text, {Duration? d}) {
  try {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      width: 400.0,
      content: Text(text),
      duration: d ?? const Duration(milliseconds: 4000),
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: () {
          globalScaffoldKey.currentState?.hideCurrentSnackBar();
        },
      ),
    );
    globalScaffoldKey.currentState?.hideCurrentSnackBar();
    globalScaffoldKey.currentState?.showSnackBar(snackBar);
  } on Exception catch (e) {
    log(e.toString());
  }
}

double twoPointEquation(int x1, double y1, int x2, double y2, double x) {
  return (x - x1) * ((y2 - y1) / (x2 - x1)) + y1;
}
