import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/Singleton/Singleton.dart';
import 'package:pushapp/extension/AppExtension.dart';
import 'package:pushapp/ui/components/Utils.dart';

import '../../../data/DataHandler.dart';
import '../../../provider/android_provider.dart';
import '../../../push/PushHelper.dart';
import 'ResultWidget.dart';

class EditorWidget extends StatefulWidget {
  @override
  _EditorWidgetState createState() => _EditorWidgetState();
}

class _EditorWidgetState extends State<EditorWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  Map<String, dynamic>? _cachedPayload;
  Map<String, dynamic>? _cachedHeaders;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Singleton().provider.addListeners(updateData);
    });
  }

  void updateData(Map<String, dynamic> data) {
    var headers = data.headers();
    _urlController.text = DataHandler().getUrl();
    _headerController.text = headers.isEmpty ? "{}" : headers;
    _bodyController.text = data.body();
    _tokenController.text = data.token();

    _formatJson(_headerController);
    _formatJson(_bodyController);
    setState(() {});
  }

  Map<String, String> _parseHeaders(String headerInput) {
    final headersMap = <String, String>{};
    final headersList = headerInput.split('\n');
    for (var header in headersList) {
      final keyValue = header.split(':');
      if (keyValue.length == 2) {
        headersMap[keyValue[0].trim()] = keyValue[1].trim();
      }
    }
    return headersMap;
  }

  void _formatJson(TextEditingController controller) {
    try {
      final decodedJson = jsonDecode(controller.text);
      final formattedJson =
          const JsonEncoder.withIndent('  ').convert(decodedJson);
      controller.text = formattedJson;
    } catch (e) {
      // Handle JSON formatting error
    }
  }

  @override
  void dispose() {
    // Provider.of<AndroidProvider>(
    //   context,
    //   listen: false,
    // ).addListeners(updateData, remove: true);
    _urlController.dispose();
    _headerController.dispose();
    _bodyController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: Utils().shadow(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _editView(),
                    const SizedBox(height: 20),
                    SizedBox(height: 100, child: ResultWidget()),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomSheet: Material(
        elevation: 20, // This adds the floating shadow
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
        color: Colors.transparent, // Let child Container's color show through
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: _buttons(),
        ),
      ),
    );
  }

  Widget _editView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Utils().buildTextField(
          controller: _urlController,
          label: 'FCM Endpoint URL',
          hint: 'Enter the URL of the FCM endpoint',
          validator: Utils().requiredValidator('Please enter the URL'),
        ),
        const SizedBox(height: 16.0),
        Utils().buildTextField(
          controller: _tokenController,
          label: 'Push Token',
          hint: 'Enter the Token',
          validator: Utils().requiredValidator('Please enter the Token'),
        ),
        const SizedBox(height: 16.0),
        Utils().buildTextField(
          controller: _headerController,
          label: 'Custom Headers',
          hint: 'Enter headers (key: value) per line',
          minLines: 6,
          validator: Utils().requiredValidator('Please enter headers'),
        ),
        const SizedBox(height: 16.0),
        Utils().buildTextField(
          controller: _bodyController,
          label: 'Notification Body (JSON)',
          hint: 'Enter the notification body in JSON format',
          minLines: 6,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the notification body';
            }
            try {
              jsonDecode(value);
            } catch (_) {
              return 'Invalid JSON format';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buttons() {
    return Consumer<AndroidProvider>(builder: (context, appProvider, child) {
      return !appProvider.isConfigFileLoaded
          ? SizedBox()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(
                  label: 'Format JSON',
                  color: Colors.red,
                  onPressed: () {
                    _formatJson(_headerController);
                    _formatJson(_bodyController);
                  },
                ),
                const SizedBox(width: 24),
                _buildButton(
                  label: 'Send FCM Message',
                  color: Colors.lightBlueAccent,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      sendFCMMessage();
                    }
                  },
                ),
                const SizedBox(width: 24),
                _buildButton(
                  label: 'Save Template',
                  color: Colors.orangeAccent,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Utils().showSaveTitleDialog(
                          context: context,
                          onSave: (title) {
                            DataHandler().saveAndroidTemplatePayload({
                              "name": title,
                              "headers": getPayload(_headerController.text),
                              "body": getPayload(_bodyController.text),
                              "token": _tokenController.text
                            });
                          });
                    }
                  },
                ),
              ],
            );
    });
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5.0,
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            label,
            maxLines: 3,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendFCMMessage() async {
    Future.delayed(const Duration(milliseconds: 200), () {
      try {
        PushHelper().sendFCMMessage(
          null,
          _urlController.text,
          _tokenController.text,
          _getCachedPayload(),
          _getCachedHeaders(),
        );
      } catch (e) {
        // Handle errors
      }
    });
  }

  Map<String, dynamic> _getCachedPayload() {
    _cachedPayload = getPayload(_bodyController.text);
    return _cachedPayload!;
  }

  Map<String, dynamic> _getCachedHeaders() {
    _cachedHeaders = getPayload(_headerController.text);
    return _cachedHeaders!;
  }

  Map<String, dynamic> getPayload(String text) {
    try {
      var json = jsonDecode(text);
      return json;
    } catch (e) {
      return {};
    }
  }

  Map<String, String> getPayloadHeaders(String text) {
    try {
      return _parseHeaders(text);
    } catch (e) {
      return {};
    }
  }
}
