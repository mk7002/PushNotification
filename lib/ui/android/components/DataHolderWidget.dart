import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/data/DataHandler.dart';

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
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          ImportDataWidget(),
          Expanded(
            child: Consumer<AndroidProvider>(
                builder: (context, appProvider, child) {
              return ListView.builder(
                itemCount: appProvider.payloadList.length,
                // Define the number of items
                itemBuilder: (context, index) {
                  return item(index, appProvider.payloadList[index]);
                },
              );
            }),
          )
        ],
      ),
    );
  }

  Widget item(int index, Map<String, dynamic> data) {
    bool isDefaultPayload = data["isDefaultPayload"] ?? false;
    return Container(
      margin: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () {
          selectedIndex = index;
          Singleton().provider.setSelectedPayloadData(DataHandler().getUrl(),
              data["headers"], data["body"], data["token"]);
        },
        child: Container(
          decoration: BoxDecoration(
            color: selectedIndex == index ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${data["name"]}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                isDefaultPayload
                    ? SizedBox()
                    : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          DataHandler()
                              .deleteAndroidTemplatePayload(index, data);
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
