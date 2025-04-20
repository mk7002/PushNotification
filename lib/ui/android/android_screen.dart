import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/ui/components/custom_header.dart';
import 'package:pushapp/ui/responsive_widget.dart';

import '../../Singleton/app_provider.dart';
import '../../data/DataHandler.dart';
import '../../provider/android_provider.dart';
import 'components/DataHolderWidget.dart';
import 'components/EditorWidget.dart';

class AndroidScreen extends StatefulWidget {
  const AndroidScreen({super.key});

  @override
  State<AndroidScreen> createState() => _AndroidScreenState();
}

class _AndroidScreenState extends State<AndroidScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AndroidProvider(),
      child: const AndroidScreenWidget(),
    );
  }
}

class AndroidScreenWidget extends StatefulWidget {
  const AndroidScreenWidget({super.key});

  @override
  State<AndroidScreenWidget> createState() => _AndroidScreenWidgetState();
}

class _AndroidScreenWidgetState extends State<AndroidScreenWidget> {
  @override
  void initState() {
    super.initState();
    AppProvider().setAndroidProvider(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DataHandler().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: "Android Push Tool",
        desc: "Send test push notificaitons using FCM",
      ),
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
