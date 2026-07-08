import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/Singleton/app_provider.dart';
import 'package:pushapp/extension/AppExtension.dart';
import 'package:pushapp/ui/components/code_editor_field.dart';
import 'package:pushapp/ui/components/collapsible_section.dart';
import 'package:pushapp/ui/components/Utils.dart';
import 'package:pushapp/ui/res/style_extensions.dart';

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
      AppProvider().androidProvider.addListeners(updateData);
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
    _urlController.dispose();
    _headerController.dispose();
    _bodyController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Column(
                    children: [
                      // FCM Configuration - Expand/Collapse
                      CollapsibleSection(
                        title: "FCM Configuration",
                        subtitle: "Endpoint, token & message body",
                        leadingIcon: Icons.settings_outlined,
                        accentColor: const Color(0xFF2a93ef),
                        initiallyExpanded: true,
                        child: _editView(),
                      ),

                      // Result Section - Expand/Collapse
                      CollapsibleSection(
                        title: "Response",
                        subtitle: "Push notification result",
                        leadingIcon: Icons.terminal_rounded,
                        accentColor: const Color(0xFF6C63FF),
                        initiallyExpanded: true,
                        child: SizedBox(
                          height: 140,
                          child: ResultWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Action Buttons
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: _buttons(),
              ),
            ],
          ),
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
        const SizedBox(height: 14),
        Utils().buildTextField(
          controller: _tokenController,
          label: 'Push Token',
          hint: 'Enter the Token',
          validator: Utils().requiredValidator('Please enter the Token'),
        ),
        const SizedBox(height: 14),
        CodeEditorField(
          controller: _headerController,
          label: 'Custom Headers (JSON)',
          hint: '{\n  "key": "value"\n}',
          minLines: 5,
          validator: Utils().requiredValidator('Please enter headers'),
        ),
        const SizedBox(height: 14),
        CodeEditorField(
          controller: _bodyController,
          label: 'Notification Body (JSON)',
          hint: '{\n  "message": {\n    "notification": {\n      "title": "Hello",\n      "body": "World"\n    }\n  }\n}',
          minLines: 8,
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
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Import a service file to get started",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          : Row(
              children: [
                _buildActionButton(
                  label: 'Format',
                  icon: Icons.code_rounded,
                  color: const Color(0xfff35049),
                  onPressed: () {
                    _formatJson(_headerController);
                    _formatJson(_bodyController);
                  },
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  label: 'Send',
                  icon: Icons.send_rounded,
                  color: const Color(0xff2a93ef),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      sendFCMMessage();
                    }
                  },
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  label: 'Save',
                  icon: Icons.save_rounded,
                  color: const Color(0xfffcab3d),
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

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
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
