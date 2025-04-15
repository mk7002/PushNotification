import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/provider/android_provider.dart';
import 'package:pushapp/provider/app_provider.dart';

class ProviderSetup extends StatelessWidget {
  final Widget child;

  const ProviderSetup({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppProvider()),
        ChangeNotifierProvider(create: (context) => AndroidProvider())
      ],
      child: child,
    );
  }
}
