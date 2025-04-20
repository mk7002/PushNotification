import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/extension/AppExtension.dart';
import 'package:pushapp/provider/android_provider.dart';
import 'package:pushapp/provider/ios_provider.dart';
import 'package:pushapp/ui/res/colors.dart';

import '../../components/Utils.dart';

class ResultWidget extends StatefulWidget {
  bool isAndroid;

  ResultWidget({super.key, this.isAndroid = true});

  @override
  State<ResultWidget> createState() => _ResultWidgetState();
}

class _ResultWidgetState extends State<ResultWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.isAndroid
        ? Consumer<AndroidProvider>(builder: (context, appProvider, child) {
            return Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: Utils()
                        .shadow(
                          radius: 10,
                        )
                        .copyWith(color: COLOR_BORDER_INNER),
                    padding: const EdgeInsets.all(10.0),
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Text(appProvider.result.showResult()),
                    ),
                  ),
                ),
              ],
            );
          })
        : Consumer<IosPlatformProvider>(builder: (context, appProvider, child) {
            return Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: Utils()
                        .shadow(
                          radius: 10,
                        )
                        .copyWith(color: COLOR_BORDER_INNER),
                    padding: const EdgeInsets.all(10.0),
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
