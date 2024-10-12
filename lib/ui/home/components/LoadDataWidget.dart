import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pushapp/data/DataHandler.dart';
import 'package:pushapp/ui/components/Utils.dart';

import '../../../Singleton/Singleton.dart';

class LoadDataWidget extends StatefulWidget {
  const LoadDataWidget({super.key});

  @override
  State<LoadDataWidget> createState() => _LoadDataWidgetState();
}

class _LoadDataWidgetState extends State<LoadDataWidget> {
  final _urlController = TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();
  String _data = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  // Function to validate URL
  bool _isValidUrl(String url) {
    Uri? uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  // Fetch data from the provided URL
  Future<void> _fetchData() async {
    final url = _urlController.text;

    // Validate URL before making the request
    if (!_isValidUrl(url)) {
      setState(() {
        _errorMessage = 'Invalid URL. Please enter a valid URL.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _data = '';
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON data
        final jsonData = json.decode(response.body);
        _loadData(jsonData);
      } else {}
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadData(jsonData) {
    DataHandler().setAppConfig(jsonData);
    var data = DataHandler()
        .getAppConfigData<List<Map<String, dynamic>>>(AppConfigType.payloads);
    if (data != null) {
      data = data.cast<Map<String, dynamic>>();
    }
    Singleton().provider.setPayloadList(data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: SizedBox(
              height: 80,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: Utils().getInputDecoration(
                          labelText: 'Config Data Endpoint',
                          hintText: 'Enter the URL of the Config Data'),
                      controller: _urlController,
                      // decoration: const InputDecoration(
                      //   labelText: 'Config Data Endpoint',
                      //   hintText: 'Enter the URL of the Config Data',
                      // ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the URL';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _fetchData();
                      }
                    },
                    child: const Text("Fetch"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _importFile();
                    },
                    child: const Text("Import"),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_data.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Text(
                    _data,
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _importFile() {
    pickAndReadJsonFile();
  }

  Future<void> pickAndReadJsonFile() async {
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
        Map<String, dynamic> jsonData = jsonDecode(fileContent);

        _loadData(jsonData);
      }
    } else {
      // User canceled the file picking
      print('File picking canceled or failed');
    }
  }
}
