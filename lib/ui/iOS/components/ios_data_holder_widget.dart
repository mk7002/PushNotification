import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/provider/ios_provider.dart';
import 'package:pushapp/ui/iOS/components/ios_import_data_widget/ios_data_import_widget.dart';

import '../../components/header_name_widget.dart';
import '../../components/payload_list_tiles.dart';
import '../apns_service_status_widget.dart';

class IosDataContainerWidget extends StatefulWidget {
  const IosDataContainerWidget({super.key});

  @override
  State<IosDataContainerWidget> createState() => _IosDataContainerWidget();
}

class _IosDataContainerWidget extends State<IosDataContainerWidget> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          IosDataImportWidget(),
          const SizedBox(
            height: 20,
          ),
          ApnsServiceStatusWidget(),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: HeaderNameWidget(
              label: "Saved Payloads",
              child: Expanded(
                child: Consumer<IosPlatformProvider>(
                    builder: (context, appProvider, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 12) / 2;
                      const minItemHeight = 60.0;
                      final aspectRatio = itemWidth / minItemHeight;
                      return GridView.builder(
                        itemCount: appProvider.payloadList.length,
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio:
                              aspectRatio, // Ensures min height of ~100
                        ),
                        itemBuilder: (context, index) {
                          return PayloadListTile(
                            onDeleted: (index) {
                              var data = appProvider.payloadList[index];
                              appProvider.deleteTemplatePayload(index, data);
                            },
                            index: index,
                            data: appProvider.payloadList[index],
                            selectedIndex: selectedIndex,
                            onSelected: (int selected) {
                              setState(() {
                                selectedIndex = selected;
                              });
                              appProvider.onPayloadSelected(
                                  appProvider.payloadList[index]);
                            },
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
