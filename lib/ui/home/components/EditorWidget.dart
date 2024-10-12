import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/data/DataHandler.dart';
import 'package:pushapp/extension/AppExtension.dart';
import 'package:pushapp/ui/components/Utils.dart';

import '../../../provider/AppProvider.dart';
import '../../../push/PushHelper.dart';

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
  Map<String, String>? _cachedHeaders;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Extract data from provider and populate fields
    final data = Provider.of<AppProvider>(
      context,
      listen: true,
    ).selectedPayloadData;

    _urlController.text = DataHandler().getUrl();
    _headerController.text = data.headers();
    _bodyController.text = data.body();
    _tokenController.text = DataHandler().appConfig.token();

    // Format JSON for display
    _formatJson(_headerController);
    _formatJson(_bodyController);
  }

  Map<String, String> _parseHeaders(String headerInput) {
    // Converts header input (key: value pairs) into a Map
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
      // Log the error or handle it
      //debugPrint('Error formatting JSON: $e');
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _headerController.dispose();
    _bodyController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            TextFormField(
              controller: _urlController,
              decoration: Utils().getInputDecoration(
                  labelText: 'FCM Endpoint URL',
                  hintText: 'Enter the URL of the FCM endpoint'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            TextFormField(
              controller: _tokenController,
              decoration: Utils().getInputDecoration(
                labelText: 'Push Token',
                hintText: 'Enter the Token',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the Token';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Headers Text Field
            TextFormField(
              controller: _headerController,
              decoration: Utils().getInputDecoration(
                labelText: 'Custom Headers',
                hintText: 'Enter headers (key: value) per line',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter headers';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Body Text Field (for JSON input)
            TextFormField(
              controller: _bodyController,
              decoration: Utils().getInputDecoration(
                labelText: 'Notification Body (JSON)',
                hintText: 'Enter the notification body in JSON format',
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the notification body';
                }
                try {
                  jsonDecode(value); // Validate JSON format
                } catch (e) {
                  return 'Invalid JSON format';
                }
                return null;
              },
            ),
            const Expanded(child: SizedBox()),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5.0,
                    ),
                    onPressed: () {
                      _formatJson(_headerController);
                      _formatJson(_bodyController);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        'Format JSON',
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 24,
                ),

                // Send Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5.0,
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        sendFCMMessage();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        'Send FCM Message',
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
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
        // debugPrint('Error sending FCM message: $e');
      }
    });
  }

  Map<String, dynamic> _getCachedPayload() {
    _cachedPayload ??= getPayload(_bodyController.text);
    return _cachedPayload!;
  }

  Map<String, String> _getCachedHeaders() {
    _cachedHeaders ??= getPayloadHeaders(_headerController.text);
    return _cachedHeaders!;
  }

  Map<String, dynamic> getPayload(String text) {
    try {
      var json = jsonDecode(text);
      return json;
    } catch (e) {
      // debugPrint('Invalid JSON payload: $e');
      return {};
    }
    return {};
  }

  Map<String, String> getPayloadHeaders(String text) {
    try {
      return _parseHeaders(text);
    } catch (e) {
      // debugPrint('Error parsing headers: $e');
      return {};
    }
  }
}
