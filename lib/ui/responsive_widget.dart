import 'package:flutter/material.dart';

class ResponsiveParentWidget extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveParentWidget({
    super.key,
    this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 904;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 1280 &&
      MediaQuery.sizeOf(context).width >= 904;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1280;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 904) {
      return mobile ??
          const SizedBox.shrink(); // Return an empty widget if mobile is null
    } else if (width < 1280) {
      return tablet ??
          const SizedBox.shrink(); // Return an empty widget if tablet is null
    } else {
      return desktop;
    }
  }
}
