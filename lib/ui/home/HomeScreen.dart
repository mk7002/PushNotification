import 'package:flutter/material.dart';
import 'package:pushapp/Singleton/Singleton.dart';
import 'package:pushapp/data/DataHandler.dart';
import 'package:pushapp/ui/home/components/DataHolderWidget.dart';
import 'package:pushapp/ui/home/components/EditorWidget.dart';
import 'package:pushapp/ui/home/components/ResultWidget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Singleton().setProvider(context);
    DataHandler().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Android Push"),
      ),
      body: Row(
        children: [
          const Expanded(child: DataHolderWidget()),
          Expanded(child: EditorWidget()),
          const Expanded(child: ResultWidget()),
        ],
      ),
    );
  }
}
