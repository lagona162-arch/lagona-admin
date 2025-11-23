import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    if (size.width >= 1100) {
      return desktop;
    } else if (size.width >= 650 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

class ResponsiveHelper {
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (Responsive.isMobile(context)) {
      return baseSize * 0.85;
    } else if (Responsive.isTablet(context)) {
      return baseSize * 0.95;
    } else {
      return baseSize;
    }
  }

  static int getGridColumns(BuildContext context, int maxColumns) {
    if (Responsive.isMobile(context)) {
      return maxColumns == 4 ? 2 : 1;
    } else if (Responsive.isTablet(context)) {
      return maxColumns == 4 ? 2 : maxColumns;
    } else {
      return maxColumns;
    }
  }

  static double getHorizontalPadding(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return 16.0;
    } else if (Responsive.isTablet(context)) {
      return 20.0;
    } else {
      return 24.0;
    }
  }
}

