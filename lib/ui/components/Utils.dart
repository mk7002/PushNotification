import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Utils {
  var android_service_file_json = {
    "type": "service_account",
    "project_id": "",
    "private_key_id": "",
    "private_key": "",
    "client_email": "",
    "client_id": "",
    "auth_uri": "",
    "token_uri": "",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "",
    "universe_domain": "googleapis.com"
  };

  var sample_template_json = [
    {
      "name": "Sample Payload 1",
      "headers": {},
      "token": "token",
      "body": {
        "message": {
          "notification": {
            "title": "Portugal vs. Denmark",
            "body": "great match!"
          }
        }
      }
    }
  ];

  static TextStyle textStyleBold({double size = -1}) => TextStyle(
      fontWeight: FontWeight.bold, fontSize: size == -1 ? null : size);

  InputDecoration getInputDecoration({String? labelText, String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12.0), // Rounded corners when not focused
        borderSide: const BorderSide(
          color: Colors.grey, // Border color when not focused
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12.0), // Rounded corners when focused
        borderSide: const BorderSide(
          color: Colors.blue, // Border color when focused
        ),
      ),
    );
  }

  BoxDecoration shadow({double radius = 20}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(0, 1), // changes position of shadow
        ),
      ],
    );
  }

  BoxDecoration sampleShadow() {
    bool darkMode = false;
    var unit = 1;
    return BoxDecoration(
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white, // Background color
      boxShadow: [
        BoxShadow(
          color: darkMode
              ? Colors.white.withOpacity(0.2)
              : Colors.grey[500]!, // Shadow color
          offset: Offset(-unit / 2, -unit / 2),
          blurRadius: 1.5 * unit,
        ),
        BoxShadow(
          color: Colors.grey[400]!, // Inner shadow color
          offset: Offset(unit / 2, unit / 2),
          blurRadius: 1.5 * unit,
        ),
      ],
    );
  }

  Widget button(String name, VoidCallback? onPressed) {
    return Material(
      elevation: 10, // Adjust the elevation for shadow depth
      shadowColor: Colors.brown.withOpacity(0.7), // Color of the shadow
      borderRadius:
          BorderRadius.circular(10), // Optional: Adjust the border radius
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3DDC84).withOpacity(0.4),
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 15), // Button padding
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Optional: Adjust the border radius
          ),
        ),
        child: Text(
          name,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void showSaveTitleDialog({
    required BuildContext context,
    required void Function(String title) onSave,
  }) {
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Title'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Enter title here'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                Navigator.pop(context); // Close dialog
                onSave(title); // Callback with entered title
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int? minLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      maxLines: minLines == null ? 1 : null,
      minLines: minLines,
      decoration: Utils().getInputDecoration(
        labelText: label,
        hintText: hint,
      ),
      validator: validator,
    );
  }

  String? Function(String?) requiredValidator(String message) {
    return (value) {
      if (value == null || value.isEmpty) {
        return message;
      }
      return null;
    };
  }

  void showMessage(String message, {bool error = false}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        webPosition: "center",
        timeInSecForIosWeb: 2,
        webBgColor: error ? "#fc031c" : "#8ff268",
        textColor: error ? Colors.white : Colors.red,
        fontSize: 16.0);
  }

  void showJsonDialog(BuildContext context, sampleJson) {
    String prettyJson = const JsonEncoder.withIndent('  ').convert(sampleJson);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('JSON Data'),
        content: SingleChildScrollView(
          child: SelectableText(
            prettyJson,
            style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  static var versionCode = "";

  Future<void> getAppVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    String vN = info.version; // e.g. "1.0.0"
    String vC = info.buildNumber; // e.g. "1"
    versionCode = "$vN.$vC";
  }
}
