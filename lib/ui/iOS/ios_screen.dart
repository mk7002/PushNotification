import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/provider/ios_provider.dart';
import 'package:pushapp/ui/iOS/components/ios_data_holder_widget.dart';

import '../../Singleton/app_provider.dart';
import '../components/custom_header.dart';
import '../responsive_widget.dart';
import 'components/ios_editor_widget.dart';

class iOSScreen extends StatefulWidget {
  const iOSScreen({super.key});

  @override
  State<iOSScreen> createState() => _iOSScreenState();
}

class _iOSScreenState extends State<iOSScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IosPlatformProvider(),
      child: const IosScreenWidget(),
    );
  }
}

class IosScreenWidget extends StatefulWidget {
  const IosScreenWidget({super.key});

  @override
  State<IosScreenWidget> createState() => _IosScreenWidgetState();
}

class _IosScreenWidgetState extends State<IosScreenWidget> {
  @override
  void initState() {
    AppProvider().setIosProvider(context);
    AppProvider().iosProvider.loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: "iOS Push Tool",
        desc: "Send test push notificaitons using ANPS",
        showIcon: false,
      ),
      body: ResponsiveParentWidget(
        desktop: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: IosDataContainerWidget()),
            Expanded(child: IosEditorWidget())
          ],
        ),
      ),
    );
  }
}
