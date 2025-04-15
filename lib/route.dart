import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pushapp/ui/android/android_screen.dart';
import 'package:pushapp/ui/home/home_screen.dart';
import 'package:pushapp/ui/iOS/ios_screen.dart';

final GoRouter globalRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
        name: "home",
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
        routes: []),
    GoRoute(
      name: 'android',
      path: '/android',
      builder: (context, state) => const AndroidScreen(),
    ),
    GoRoute(
      name: 'ios',
      path: '/ios',
      builder: (context, state) => const iOSScreen(),
    ),
  ],
);

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red,
        child: Text("Hello"),
      ),
    );
  }
}
