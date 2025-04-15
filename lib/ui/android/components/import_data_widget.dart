import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pushapp/data/DataHandler.dart';
import 'package:pushapp/extension/AppExtension.dart';
import 'package:pushapp/ui/components/Utils.dart';

import '../../../Singleton/Singleton.dart';

class ImportDataWidget extends StatefulWidget {
  const ImportDataWidget({super.key});

  @override
  State<ImportDataWidget> createState() => _ImportDataWidgetState();
}

class _ImportDataWidgetState extends State<ImportDataWidget> {
  final _urlController = TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

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
          Singleton().provider.setConfigFileLoaded(false);
          return;
        }
      }

      DataHandler().setAppConfig(jsonData);

      var data = DataHandler().getAndroidTemplatePayloads();
      data = data.cast<Map<String, dynamic>>();
      Singleton().provider.setPayloadList(data);
      Singleton().provider.setConfigFileLoaded(true);
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
    return Container(
      decoration: Utils().shadow(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Utils().button("Import Android Service File", () {
                  _importFile();
                }),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Utils().button("Import Sample Template File", () {
                  _importTemplateFile();
                }),
              ),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _importFile() async {
    var response = await pickAndReadJsonFile();
    if (response != null) _loadData(response);
  }

  Future<void> _importTemplateFile() async {
    var response = await pickAndReadJsonFile();
    if (response != null) _loadTemplateData(response);
  }

  Future<dynamic> pickAndReadJsonFile() async {
    // Pick a JSON file from the user's device
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'], // Limit to JSON files
    );

    if (result != null) {
      // For web, get bytes directly
      Uint8List? fileBytes = result.files.single.bytes;

      // If you are on mobile and the path is available
      String fileContent = '';
      if (fileBytes != null) {
        // Convert bytes to a string
        fileContent = utf8.decode(fileBytes);
      } else if (result.files.single.path != null) {
        // For mobile platforms
        File file = File(result.files.single.path!);
        fileContent = await file.readAsString();
      }

      // Decode the JSON data
      if (fileContent.isNotEmpty) {
        var jsonData = jsonDecode(fileContent);
        return jsonData;
      } else {
        Utils().showMessage('File content is Empty', error: true);
      }
    } else {
      // User canceled the file picking
      Utils().showMessage('File picking canceled or failed', error: true);
    }
    return null;
  }
}
