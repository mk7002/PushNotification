import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                context.go("/android");
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Container(
                  color: Color(0xFF3DDC84),
                  alignment: Alignment.center,
                  child: Text(
                    "Android",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                context.go("/ios");
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Text(
                    "iOS",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 50,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//context.go("/android");
