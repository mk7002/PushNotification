import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/data/DataHandler.dart';
import 'package:pushapp/ui/components/header_name_widget.dart';
import 'package:pushapp/ui/res/colors.dart';

import '../../../Singleton/Singleton.dart';
import '../../../provider/android_provider.dart';
import 'import_data_widget.dart';

class DataHolderWidget extends StatefulWidget {
  const DataHolderWidget({super.key});

  @override
  State<DataHolderWidget> createState() => _DataHolderWidgetState();
}

class _DataHolderWidgetState extends State<DataHolderWidget> {
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Singleton()
          .provider
          .setPayloadList(DataHandler().getAndroidTemplatePayloads());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const ImportDataWidget(),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: HeaderNameWidget(
              label: "Saved Payloads",
              child: Expanded(
                child: Consumer<AndroidProvider>(
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
                          return item(index, appProvider.payloadList[index]);
                        },
                      );
                    },
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget item(int index, Map<String, dynamic> data) {
    bool isDefaultPayload = data["isDefaultPayload"] ?? false;
    return InkWell(
      onTap: () {
        selectedIndex = index;
        Singleton().provider.setSelectedPayloadData(DataHandler().getUrl(),
            data["headers"], data["body"], data["token"]);
      },
      child: Container(
        decoration: BoxDecoration(
            color: selectedIndex == index ? Colors.white : COLOR_BORDER_INNER,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                width: selectedIndex == index ? 2 : 1,
                color: selectedIndex == index
                    ? COLOR_ANDROID_GREEN
                    : COLOR_BORDER)),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "${data["name"]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              isDefaultPayload
                  ? const SizedBox()
                  : IconButton(
                      icon: const Icon(Icons.delete,
                          size: 16, color: Color(0xff757473)),
                      onPressed: () {
                        DataHandler().deleteAndroidTemplatePayload(index, data);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
