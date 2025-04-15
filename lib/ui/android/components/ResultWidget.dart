import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/extension/AppExtension.dart';
import 'package:pushapp/provider/android_provider.dart';

import '../../components/Utils.dart';

class ResultWidget extends StatefulWidget {
  const ResultWidget({super.key});

  @override
  State<ResultWidget> createState() => _ResultWidgetState();
}

class _ResultWidgetState extends State<ResultWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AndroidProvider>(builder: (context, appProvider, child) {
      return Column(
        children: [
          Expanded(
            child: Container(
              decoration: Utils().shadow(radius: 10),
              padding: const EdgeInsets.all(5.0),
              width: double.infinity,
              child: SingleChildScrollView(
                child: Text(appProvider.result.showResult()),
              ),
            ),
          ),
        ],
      );
    });
  }
}
