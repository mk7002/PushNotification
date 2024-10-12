import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/extension/AppExtension.dart';
import 'package:pushapp/provider/AppProvider.dart';

class ResultWidget extends StatefulWidget {
  const ResultWidget({super.key});

  @override
  State<ResultWidget> createState() => _ResultWidgetState();
}

class _ResultWidgetState extends State<ResultWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child:
                Consumer<AppProvider>(builder: (context, appProvider, child) {
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.all(20),
                      color: Colors.grey,
                      child: Text(appProvider.result.showResult()),
                    ),
                  )
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
