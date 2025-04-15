import 'package:flutter/material.dart';

class iOSScreen extends StatefulWidget {
  const iOSScreen({super.key});

  @override
  State<iOSScreen> createState() => _iOSScreenState();
}

class _iOSScreenState extends State<iOSScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(child: Text("Coming Soon")),
      ),
    );
  }
}
