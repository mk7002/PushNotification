import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/data/DataHandler.dart';
import 'package:pushapp/ui/home/components/LoadDataWidget.dart';

import '../../../Singleton/Singleton.dart';
import '../../../provider/AppProvider.dart';

class DataHolderWidget extends StatefulWidget {
  const DataHolderWidget({super.key});

  @override
  State<DataHolderWidget> createState() => _DataHolderWidgetState();
}

class _DataHolderWidgetState extends State<DataHolderWidget> {
  int selectedIndex = -1;

  @override
  void initState() {
    Singleton().provider.setPayloadList(DataHandler()
        .getAppConfigData<List<Map<String, dynamic>>>(AppConfigType.payloads));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          LoadDataWidget(),
          Expanded(
            child:
                Consumer<AppProvider>(builder: (context, appProvider, child) {
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

  Widget item(index, data) {
    return Container(
      margin: EdgeInsets.all(20),
      child: InkWell(
        onTap: () {
          selectedIndex = index;
          Singleton()
              .provider
              .setSelectedPayloadData(DataHandler().getUrl(), {}, data["body"]);
        },
        child: Container(
          decoration: BoxDecoration(
            color: selectedIndex == index
                ? Colors.blue
                : Colors.grey, // Background color here
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
            padding: const EdgeInsets.all(20),
            child: Text(
              "${data["name"]}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
