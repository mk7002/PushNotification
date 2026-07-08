import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/Singleton/app_provider.dart';
import 'package:pushapp/ui/components/Utils.dart';
import 'package:pushapp/utils/file_manager.dart';

import '../../../../provider/ios_provider.dart';
import '../../../res/colors.dart';
import '../../apns_service_status_widget.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Import buttons
        Row(
          children: [
            Expanded(
              child: _importButton(
                icon: Icons.vpn_key_outlined,
                label: "Import .p8 File",
                onTap: _importFile,
                onInfo: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _importButton(
                icon: Icons.file_copy_outlined,
                label: "Template File",
                onTap: _importTemplateFile,
                onInfo: () {
                  Utils().showJsonDialog(context, Utils().sample_ios_payload);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Form Fields
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
                const SizedBox(height: 10),
                Utils().buildTextField(
                  controller: _keyIdController,
                  label: 'Key ID',
                  hint: 'Enter the Key id',
                  validator:
                      Utils().requiredValidator('Please enter the Key id'),
                ),
                const SizedBox(height: 10),
                Utils().buildTextField(
                  controller: _bundleIdController,
                  label: 'Bundle ID',
                  hint: 'Enter the Bundle id',
                  validator:
                      Utils().requiredValidator('Please enter the Bundle id'),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 14),

        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save_rounded, size: 18),
            label: const Text("Save Configuration",
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                AppProvider().iosProvider.saveTeamData({
                  "teamId": _teamIdController.text,
                  "keyId": _keyIdController.text,
                  "bundleId": _bundleIdController.text
                });
              }
            },
          ),
        ),
        const SizedBox(height: 14),

        // Status Row
        Row(
          children: [
            Expanded(
              flex: 6,
              child: Consumer<IosPlatformProvider>(
                builder: (context, appProvider, child) {
                  var fileName = appProvider.fileName;
                  final hasFile = fileName.isNotEmpty;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: hasFile
                          ? const Color(0xFF007AFF).withOpacity(0.08)
                          : Colors.red.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasFile
                              ? Icons.check_circle_rounded
                              : Icons.info_outline_rounded,
                          size: 16,
                          color: hasFile ? const Color(0xFF007AFF) : Colors.red[400],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hasFile
                                ? "Key: $fileName"
                                : "No .p8 file selected",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                                  hasFile ? const Color(0xFF007AFF) : Colors.red[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: kIsWeb
                  ? const ApnsServiceStatusWidget()
                  : const SizedBox(),
            ),
          ],
        ),
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
