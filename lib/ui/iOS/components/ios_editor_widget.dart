import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/Singleton/app_provider.dart';
import 'package:pushapp/extension/AppExtension.dart';
import 'package:pushapp/provider/ios_provider.dart';
import 'package:pushapp/ui/components/code_editor_field.dart';
import 'package:pushapp/ui/components/collapsible_section.dart';
import 'package:pushapp/ui/components/Utils.dart';
import 'package:pushapp/ui/res/strings.dart';

import '../../android/components/ResultWidget.dart';
import '../../components/custom_dropdown_widget.dart';

class IosEditorWidget extends StatefulWidget {
  @override
  _IosEditorWidgetState createState() => _IosEditorWidgetState();
}

class _IosEditorWidgetState extends State<IosEditorWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  var pushType = Strings.LIST_PUSH_TYPE[0];
  var apnServer = Strings.LIST_APNS_SERVER[0];

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
      AppProvider().iosProvider.addListeners(updateData);
    });
  }

  void updateData(Map<String, dynamic> data) {
    var headers = data.headers();
    _headerController.text = headers.isEmpty ? "{}" : headers;
    _bodyController.text = data.body();
    _tokenController.text = data.token();
    apnServer = data.apnServer();
    pushType = data.pushType();
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
                      // APNs Configuration - Expand/Collapse
                      CollapsibleSection(
                        title: "APNs Configuration",
                        subtitle: "Push type, token & payload",
                        leadingIcon: Icons.settings_outlined,
                        accentColor: const Color(0xFF007AFF),
                        initiallyExpanded: true,
                        child: _editView(),
                      ),

                      // Result Section - Expand/Collapse
                      CollapsibleSection(
                        title: "Response",
                        subtitle: "Push notification result",
                        leadingIcon: Icons.terminal_rounded,
                        accentColor: const Color(0xFF5856D6),
                        initiallyExpanded: true,
                        child: SizedBox(
                          height: 140,
                          child: ResultWidget(isAndroid: false),
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
        CustomDropdown(
          label: 'Push Type',
          items: Strings.LIST_PUSH_TYPE,
          value: pushType,
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                pushType = newValue;
              });
            }
          },
        ),
        const SizedBox(height: 14),
        CustomDropdown(
          label: 'APN Server',
          items: Strings.LIST_APNS_SERVER,
          value: apnServer,
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                apnServer = newValue;
              });
            }
          },
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
          hint: '{\n  "apns-priority": "10"\n}',
          minLines: 5,
          validator: Utils().requiredValidator('Please enter headers'),
        ),
        const SizedBox(height: 14),
        CodeEditorField(
          controller: _bodyController,
          label: 'Notification Body (JSON)',
          hint: '{\n  "aps": {\n    "alert": {\n      "title": "Hello",\n      "body": "World"\n    },\n    "sound": "default"\n  }\n}',
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
    return Consumer<IosPlatformProvider>(
        builder: (context, appProvider, child) {
      return appProvider.privateKeyContent == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Import a .p8 key file to get started",
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
                  color: const Color(0xFF007AFF),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      sendApnsMessage();
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
                            appProvider.saveTemplatePayload({
                              "name": title,
                              Strings.HEADERS:
                                  getPayload(_headerController.text),
                              Strings.BODY: getPayload(_bodyController.text),
                              Strings.TOKEN: _tokenController.text,
                              Strings.APN_SERVER: apnServer,
                              Strings.PUSH_TYPE: pushType
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

  Future<void> sendApnsMessage() async {
    Future.delayed(const Duration(milliseconds: 200), () {
      try {
        AppProvider().iosProvider.sendPush({
          "token": _tokenController.text,
          "headers": _getCachedHeaders(),
          "environment": apnServer,
          "body": _getCachedPayload(),
          "push_type": pushType
        });
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
