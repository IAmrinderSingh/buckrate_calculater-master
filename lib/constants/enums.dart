import 'package:flutter/material.dart';

enum CalculatorType {
  length,
  weight,
  image,
}

enum CalculatorStep {
  priceCalculate,
  formFill,
  submit,
}

enum ResponsiveD {
  mobile,
  tablet,
  desktop,
  dialog;

  static double mobileBreakPoint = 500;
  static double tabBreakPoint = 950;
  static double dialogHeight = 650;

  static ResponsiveD d(context) {
    if (MediaQuery.of(context).size.width <= mobileBreakPoint) {
      if (MediaQuery.of(context).size.height < dialogHeight) {
        return ResponsiveD.dialog;
      }
      return ResponsiveD.mobile;
    } else if (MediaQuery.of(context).size.width <= tabBreakPoint) {
      if (MediaQuery.of(context).size.height < dialogHeight) {
        return ResponsiveD.dialog;
      }
      return ResponsiveD.tablet;
    } else {
      if (MediaQuery.of(context).size.height < dialogHeight) {
        return ResponsiveD.dialog;
      }
      return ResponsiveD.desktop;
    }
  }
}