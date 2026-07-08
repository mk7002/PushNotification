import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/data/DataHandler.dart';
import 'package:pushapp/data/remote_payload_service.dart';
import 'package:pushapp/provider/profile_provider.dart';
import 'package:pushapp/ui/components/collapsible_section.dart';
import 'package:pushapp/ui/components/payload_list_tiles.dart';

import '../../../Singleton/app_provider.dart';
import '../../../provider/android_provider.dart';
import 'import_data_widget.dart';

class DataHolderWidget extends StatefulWidget {
  const DataHolderWidget({super.key});

  @override
  State<DataHolderWidget> createState() => _DataHolderWidgetState();
}

class _DataHolderWidgetState extends State<DataHolderWidget> {
  int selectedIndex = -1;
  bool _loadingRemote = false;
  List<Map<String, dynamic>> _remotePayloads = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppProvider()
          .androidProvider
          .setPayloadList(DataHandler().getAndroidTemplatePayloads());
      _loadRemotePayloads();
    });
  }

  Future<void> _loadRemotePayloads() async {
    final profileProvider = context.read<ProfileProvider>();
    final activeProfile = profileProvider.activeProfile;

    if (activeProfile?.remotePayloadUrl != null &&
        activeProfile!.remotePayloadUrl!.isNotEmpty) {
      setState(() => _loadingRemote = true);
      final payloads = await RemotePayloadService()
          .fetchPayloads(activeProfile.remotePayloadUrl!);
      if (mounted) {
        setState(() {
          _remotePayloads = payloads;
          _loadingRemote = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Import Configuration Section
          const CollapsibleSection(
            title: "Import Configurations",
            subtitle: "Load service account & template files",
            leadingIcon: Icons.cloud_upload_outlined,
            accentColor: Color(0xFF3DDC84),
            initiallyExpanded: true,
            child: ImportDataWidget(),
          ),

          // Remote Payloads Section (only shown for profiles with remote URLs)
          if (_loadingRemote || _remotePayloads.isNotEmpty)
            CollapsibleSection(
              title: "Remote Payloads",
              subtitle: "Fetched from remote config",
              leadingIcon: Icons.cloud_download_rounded,
              accentColor: const Color(0xFF9C27B0),
              initiallyExpanded: true,
              child: _loadingRemote
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : _buildRemotePayloadList(),
            ),

          // Saved Payloads Section
          CollapsibleSection(
            title: "Saved Payloads",
            subtitle: "Select a template to populate the editor",
            leadingIcon: Icons.list_alt_rounded,
            accentColor: Color(0xFF3DDC84),
            initiallyExpanded: true,
            child: Consumer<AndroidProvider>(
              builder: (context, appProvider, child) {
                if (appProvider.payloadList.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "No payloads saved yet",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  );
                }
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(
                    appProvider.payloadList.length,
                    (index) => SizedBox(
                      width: (MediaQuery.of(context).size.width / 4) - 40,
                      child: PayloadListTile(
                        onDeleted: (index) {
                          DataHandler().deleteAndroidTemplatePayload(
                              index, appProvider.payloadList[index]);
                        },
                        index: index,
                        data: appProvider.payloadList[index],
                        selectedIndex: selectedIndex,
                        onSelected: (int selected) {
                          setState(() {
                            selectedIndex = selected;
                          });
                          var data = appProvider.payloadList[index];
                          AppProvider()
                              .androidProvider
                              .setSelectedPayloadData(
                                  DataHandler().getUrl(),
                                  data["headers"],
                                  data["body"],
                                  data["token"]);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemotePayloadList() {
    if (_remotePayloads.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            "No remote payloads available",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    // Use a negative offset for selectedIndex so remote items don't conflict
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(
        _remotePayloads.length,
        (index) {
          final remoteIndex = -(index + 1); // negative so it doesn't conflict
          return SizedBox(
            width: (MediaQuery.of(context).size.width / 4) - 40,
            child: PayloadListTile(
              onDeleted: (_) {},
              index: remoteIndex,
              data: _remotePayloads[index],
              selectedIndex: selectedIndex,
              onSelected: (int selected) {
                setState(() {
                  selectedIndex = selected;
                });
                var data = _remotePayloads[index];
                AppProvider().androidProvider.setSelectedPayloadData(
                    DataHandler().getUrl(),
                    data["headers"],
                    data["body"],
                    data["token"]);
              },
            ),
          );
        },
      ),
    );
  }
}
