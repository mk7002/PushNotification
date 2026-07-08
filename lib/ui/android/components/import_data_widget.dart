import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/data/DataHandler.dart';
import 'package:pushapp/extension/AppExtension.dart';
import 'package:pushapp/ui/components/Utils.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _importButton(
              icon: Icons.description_outlined,
              label: "Service Account",
              onTap: _importFile,
              onInfo: () {
                Utils().showJsonDialog(
                    context, Utils().android_service_file_json);
              },
            )),
            const SizedBox(width: 12),
            Expanded(child: _importButton(
              icon: Icons.file_copy_outlined,
              label: "Template File",
              onTap: _importTemplateFile,
              onInfo: () {
                Utils().showJsonDialog(
                    context, Utils().sample_template_json);
              },
            )),
          ],
        ),
        const SizedBox(height: 14),
        Consumer<AndroidProvider>(builder: (context, appProvider, child) {
          var projectId = "";
          if (appProvider.isConfigFileLoaded) {
            projectId = DataHandler().appConfig["project_id"];
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: appProvider.isConfigFileLoaded
                  ? COLOR_ANDROID_GREEN.withOpacity(0.08)
                  : Colors.red.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  appProvider.isConfigFileLoaded
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  size: 16,
                  color: appProvider.isConfigFileLoaded
                      ? COLOR_ANDROID_GREEN
                      : Colors.red[400],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appProvider.isConfigFileLoaded
                        ? "Project: $projectId"
                        : "No service file loaded",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: appProvider.isConfigFileLoaded
                          ? COLOR_ANDROID_GREEN
                          : Colors.red[400],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _importButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required VoidCallback onInfo,
  }) {
    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              GestureDetector(
                onTap: onInfo,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
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
