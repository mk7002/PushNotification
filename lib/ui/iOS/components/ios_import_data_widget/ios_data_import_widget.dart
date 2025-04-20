import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/Singleton/app_provider.dart';
import 'package:pushapp/ui/components/AppButton.dart';
import 'package:pushapp/ui/components/Utils.dart';
import 'package:pushapp/ui/components/header_name_widget.dart';
import 'package:pushapp/utils/file_manager.dart';

import '../../../../provider/ios_provider.dart';
import '../../../res/colors.dart';

class IosDataImportWidget extends StatefulWidget {
  const IosDataImportWidget({super.key});

  @override
  State<IosDataImportWidget> createState() => _IosDataImportWidgetState();
}

class _IosDataImportWidgetState extends State<IosDataImportWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _teamIdController =
      TextEditingController(text: AppProvider().iosProvider.teamId);
  final TextEditingController _bundleIdController =
      TextEditingController(text: AppProvider().iosProvider.bundleId);
  final TextEditingController _keyIdController =
      TextEditingController(text: AppProvider().iosProvider.keyId);

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
                      label: "Import iOS .p8 File",
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
              const SizedBox(
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
          const SizedBox(
            height: 15,
          ),
          Consumer<IosPlatformProvider>(builder: (context, appProvider, child) {
            _teamIdController.text = appProvider.teamId;
            _keyIdController.text = appProvider.keyId;
            _bundleIdController.text = appProvider.bundleId;
            return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Utils().buildTextField(
                      controller: _teamIdController,
                      label: 'Team ID',
                      hint: 'Enter the team id',
                      validator:
                          Utils().requiredValidator('Please enter the team id'),
                    ),
                    SizedBox(height: 10),
                    Utils().buildTextField(
                      controller: _keyIdController,
                      label: 'Key ID',
                      hint: 'Enter the Key id',
                      validator:
                          Utils().requiredValidator('Please enter the Key id'),
                    ),
                    SizedBox(height: 10),
                    Utils().buildTextField(
                      controller: _bundleIdController,
                      label: 'Bundle ID',
                      hint: 'Enter the Bundle id',
                      validator: Utils()
                          .requiredValidator('Please enter the Bundle id'),
                    ),
                  ],
                ));
          }),
          SizedBox(height: 10),
          Utils().buildButton(
              label: "Save",
              color: COLOR_ANDROID_GREEN,
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  AppProvider().iosProvider.saveTeamData({
                    "teamId": _teamIdController.text,
                    "keyId": _keyIdController.text,
                    "bundleId": _bundleIdController.text
                  });
                }
              }),
          SizedBox(height: 10),
          Consumer<IosPlatformProvider>(builder: (context, appProvider, child) {
            var fileName = "";
            if (appProvider.fileName != null) {
              fileName = appProvider.fileName!;
            }
            return fileName == null || fileName.isEmpty
                ? const Text("No .p8 file selected",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500))
                : Text(
                    "P8 file loaded for  : $fileName",
                    style: const TextStyle(
                        color: COLOR_ANDROID_GREEN,
                        fontWeight: FontWeight.w500),
                  );
          })
        ],
      ),
    );
  }

  Future<void> _importFile() async {
    var response = await FileManager().pickAndReadP8File();
    if (response != null) {
      AppProvider().iosProvider.setP8FileData(response);
    }
  }

  Future<void> _importTemplateFile() async {
    var fileManger = FileManager();
    var response = await fileManger.pickAndReadJsonFile();
    if (response != null) {
      var list = fileManger.parseJsonToList(response);
      if (list != null) {
        AppProvider().iosProvider.setPayloadList(list);
      }
    }
  }
}
