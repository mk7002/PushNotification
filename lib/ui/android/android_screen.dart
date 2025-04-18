import 'package:flutter/material.dart';
import 'package:pushapp/ui/components/custom_header.dart';
import 'package:pushapp/ui/responsive_widget.dart';

import '../../Singleton/Singleton.dart';
import '../../data/DataHandler.dart';
import 'components/DataHolderWidget.dart';
import 'components/EditorWidget.dart';

class AndroidScreen extends StatefulWidget {
  const AndroidScreen({super.key});

  @override
  State<AndroidScreen> createState() => _AndroidScreenState();
}

class _AndroidScreenState extends State<AndroidScreen> {
  @override
  void initState() {
    super.initState();
    Singleton().setProvider(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DataHandler().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(),
      body: ResponsiveParentWidget(
        tablet: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Expanded(child: DataHolderWidget()),
          Expanded(child: EditorWidget()),
        ]),
        desktop: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: DataHolderWidget()),
            Expanded(child: EditorWidget()),
          ],
        ),
      ),
    );
  }
}
