import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/data/DataHandler.dart';
import 'package:pushapp/extension/AppExtension.dart';
import 'package:pushapp/ui/components/AppButton.dart';
import 'package:pushapp/ui/components/Utils.dart';
import 'package:pushapp/ui/components/header_name_widget.dart';
import 'package:pushapp/ui/res/colors.dart';
import 'package:pushapp/utils/file_manager.dart';

import '../../../Singleton/app_provider.dart';
import '../../../provider/android_provider.dart';

class ImportDataWidget extends StatefulWidget {
  const ImportDataWidget({super.key});

  @override
  State<ImportDataWidget> createState() => _ImportDataWidgetState();
}

class _ImportDataWidgetState extends State<ImportDataWidget> {
  final _urlController = TextEditingController(text: "");

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _loadData(dynamic _jsonData) {
    try {
      var jsonData = _jsonData;

      final projectId = (_jsonData as Map<String, dynamic>).getProjectId();

      if (projectId?.isEmpty ?? true) {
        var data = _jsonData as Map<String, dynamic>;
        if (data.isOldConfig()) {
          jsonData = data["serviceAccountJson"];
          if (data["payloads"] != null) {
            _loadTemplateData(data["payloads"]);
          }
        } else {
          Utils().showMessage('Invalid Json file', error: true);
          AppProvider().androidProvider.setConfigFileLoaded(false);
          return;
        }
      }

      DataHandler().setAppConfig(jsonData);

      var data = DataHandler().getAndroidTemplatePayloads();
      data = data.cast<Map<String, dynamic>>();
      AppProvider().androidProvider.setPayloadList(data);
      AppProvider().androidProvider.setConfigFileLoaded(true);
      Utils().showMessage('File loaded successfully');
    } catch (e, stack) {
      print("❌ Error: $e");
      print("🪵 Stack: $stack");
      Utils().showMessage('Unexpected error occurred', error: true);
    }
  }

  void _loadTemplateData(jsonData) {
    if (jsonData is List) {
      final List<Map<String, dynamic>> typedList = jsonData
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      DataHandler().saveAndroidTemplatePayloadList(typedList);
    } else {
      Utils().showMessage('Invalid template JSON format', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderNameWidget(
      label: "Import Configurations",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: ConfigButton(
                      label: "Import Android Service File",
                      onPressed: () {
                        _importFile();
                      },
                      onInfoPressed: () {
                        Utils().showJsonDialog(
                            context, Utils().android_service_file_json);
                      },
                    )),
                  ],
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ConfigButton(
                          label: "Import Sample Template File",
                          onInfoPressed: () {
                            Utils().showJsonDialog(
                                context, Utils().sample_template_json);
                          },
                          onPressed: () {
                            _importTemplateFile();
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Consumer<AndroidProvider>(builder: (context, appProvider, child) {
            var project_id = "";
            if (appProvider.isConfigFileLoaded) {
              project_id = DataHandler().appConfig["project_id"];
            }
            return !appProvider.isConfigFileLoaded
                ? Text("No service file selected",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500))
                : Text(
                    "Service file loaded for project id : $project_id",
                    style: TextStyle(
                        color: COLOR_ANDROID_GREEN,
                        fontWeight: FontWeight.w500),
                  );
          })
        ],
      ),
    );
  }

  Future<void> _importFile() async {
    var response = await FileManager().pickAndReadJsonFile();
    if (response != null) _loadData(response);
  }

  Future<void> _importTemplateFile() async {
    var response = await FileManager().pickAndReadJsonFile();
    if (response != null) _loadTemplateData(response);
  }
}
